#!/bin/bash

{{/*
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/}}

set -ex

# NOTE(mnaser): This will move the VNC certificates into the expected location.
if [ -f /tmp/vnc.crt ]; then
  mkdir -p /etc/pki/libvirt-vnc
  mv /tmp/vnc.key /etc/pki/libvirt-vnc/server-key.pem
  mv /tmp/vnc.crt /etc/pki/libvirt-vnc/server-cert.pem
  mv /tmp/vnc-ca.crt /etc/pki/libvirt-vnc/ca-cert.pem
fi

# TODO: We disable cgroup functionality for cgroup v2, we should fix this in the future
if $(stat -fc %T /sys/fs/cgroup/ | grep -q cgroup2fs); then
  CGROUP_VERSION=v2
else
  CGROUP_VERSION=v1
fi

if [ -n "$(cat /proc/*/comm 2>/dev/null | grep -w libvirtd)" ]; then
  set +x
  for proc in $(ls /proc/*/comm 2>/dev/null); do
    if [ "x$(cat $proc 2>/dev/null | grep -w libvirtd)" == "xlibvirtd" ]; then
      set -x
      libvirtpid=$(echo $proc | cut -f 3 -d '/')
      echo "WARNING: libvirtd daemon already running on host" 1>&2
      echo "$(cat "/proc/${libvirtpid}/status" 2>/dev/null | grep State)" 1>&2
      kill -9 "$libvirtpid" || true
      set +x
    fi
  done
  set -x
fi

rm -f /var/run/libvirtd.pid

if [[ -c /dev/kvm ]]; then
    chmod 660 /dev/kvm
    chown root:kvm /dev/kvm
fi

if [ $CGROUP_VERSION != "v2" ]; then
  #Setup Cgroups to use when breaking out of Kubernetes defined groups
  CGROUPS=""
  for CGROUP in cpu rdma hugetlb; do
    if [ -d /sys/fs/cgroup/${CGROUP} ]; then
      CGROUPS+="${CGROUP},"
    fi
  done
  cgcreate -g ${CGROUPS%,}:/osh-libvirt
fi

# We assume that if hugepage count > 0, then hugepages should be exposed to libvirt/qemu
hp_count="$(cat /proc/meminfo | grep HugePages_Total | tr -cd '[:digit:]')"
if [ 0"$hp_count" -gt 0 ]; then

  echo "INFO: Detected hugepage count of '$hp_count'. Enabling hugepage settings for libvirt/qemu."

  # Enable KVM hugepages for QEMU
  if [ -n "$(grep KVM_HUGEPAGES=0 /etc/default/qemu-kvm)" ]; then
    sed -i 's/.*KVM_HUGEPAGES=0.*/KVM_HUGEPAGES=1/g' /etc/default/qemu-kvm
  else
    echo KVM_HUGEPAGES=1 >> /etc/default/qemu-kvm
  fi

  # Ensure that the hugepage mount location is available/mapped inside the
  # container. This assumes use of the default ubuntu dev-hugepages.mount
  # systemd unit which mounts hugepages at this location.
  if [ ! -d /dev/hugepages ]; then
    echo "ERROR: Hugepages configured in kernel, but libvirtd container cannot access /dev/hugepages"
    exit 1
  fi

  if [ $CGROUP_VERSION != "v2" ]; then
    # Kubernetes 1.10.x introduced cgroup changes that caused the container's
    # hugepage byte limit quota to zero out. This workaround sets that pod limit
    # back to the total number of hugepage bytes available to the baremetal host.
    if [ -d /sys/fs/cgroup/hugetlb ]; then
      limits="$(ls /sys/fs/cgroup/hugetlb/{{ .Values.conf.kubernetes.cgroup }}/hugetlb.*.limit_in_bytes)" || \
        (echo "ERROR: Failed to locate any hugetable limits. Did you set the correct cgroup in your values used for this chart?"
         exit 1)
      for limit in $limits; do
        target="/sys/fs/cgroup/hugetlb/$(dirname $(awk -F: '($2~/hugetlb/){print $3}' /proc/self/cgroup))/$(basename $limit)"
        # Ensure the write target for the hugepage limit for the pod exists
        if [ ! -f "$target" ]; then
          echo "ERROR: Could not find write target for hugepage limit: $target"
        fi

        # Write hugetable limit for pod
        echo "$(cat $limit)" > "$target"
      done
    fi

    # Determine OS default hugepage size to use for the hugepage write test
    default_hp_kb="$(cat /proc/meminfo | grep Hugepagesize | tr -cd '[:digit:]')"

    # Attempt to write to the hugepage mount to ensure it is operational, but only
    # if we have at least 1 free page.
    num_free_pages="$(cat /sys/kernel/mm/hugepages/hugepages-${default_hp_kb}kB/free_hugepages | tr -cd '[:digit:]')"
    echo "INFO: '$num_free_pages' free hugepages of size ${default_hp_kb}kB"
    if [ 0"$num_free_pages" -gt 0 ]; then
      (fallocate -o0 -l "$default_hp_kb" /dev/hugepages/foo && rm /dev/hugepages/foo) || \
        (echo "ERROR: fallocate failed test at /dev/hugepages with size ${default_hp_kb}kB"
         rm /dev/hugepages/foo
         exit 1)
    fi
  fi
fi

if [ -n "${LIBVIRT_CEPH_CINDER_SECRET_UUID}" ] || [ -n "${LIBVIRT_EXTERNAL_CEPH_CINDER_SECRET_UUID}" ] ; then
  if [ $CGROUP_VERSION != "v2" ]; then
    #NOTE(portdirect): run libvirtd as a transient unit on the host with the osh-libvirt cgroups applied.
    cgexec -g ${CGROUPS%,}:/osh-libvirt systemd-run --scope --slice=system libvirtd --listen &
  else
    systemd-run --scope --slice=system libvirtd --listen &
  fi

  tmpsecret=$(mktemp --suffix .xml)
  if [ -n "${LIBVIRT_EXTERNAL_CEPH_CINDER_SECRET_UUID}" ] ; then
    tmpsecret2=$(mktemp --suffix .xml)
  fi
  function cleanup {
    rm -f "${tmpsecret}"
    if [ -n "${LIBVIRT_EXTERNAL_CEPH_CINDER_SECRET_UUID}" ] ; then
      rm -f "${tmpsecret2}"
    fi
  }
  trap cleanup EXIT

  # Wait for the libvirtd is up
  TIMEOUT=60
  while [[ ! -f /var/run/libvirtd.pid ]]; do
    if [[ ${TIMEOUT} -gt 0 ]]; then
      let TIMEOUT-=1
      sleep 1
    else
      echo "ERROR: libvirt did not start in time (pid file missing)"
      exit 1
    fi
  done

  # Even though we see the pid file the socket immediately (this is
  # needed for virsh)
  TIMEOUT=10
  while [[ ! -e /var/run/libvirt/libvirt-sock ]]; do
    if [[ ${TIMEOUT} -gt 0 ]]; then
      let TIMEOUT-=1
      sleep 1
    else
      echo "ERROR: libvirt did not start in time (socket missing)"
      exit 1
    fi
  done

  function create_virsh_libvirt_secret {
    sec_user=$1
    sec_uuid=$2
    sec_ceph_keyring=$3
    cat > ${tmpsecret} <<EOF
<secret ephemeral='no' private='no'>
  <uuid>${sec_uuid}</uuid>
  <usage type='ceph'>
    <name>client.${sec_user}. secret</name>
  </usage>
</secret>
EOF
    virsh secret-define --file ${tmpsecret}
    virsh secret-set-value --secret "${sec_uuid}" --base64 "${sec_ceph_keyring}"
  }

  if [ -z "${CEPH_CINDER_KEYRING}" ] && [ -n "${CEPH_CINDER_USER}" ] ; then
    CEPH_CINDER_KEYRING=$(awk '/key/{print $3}' /etc/ceph/ceph.client.${CEPH_CINDER_USER}.keyring)
  fi
  if [ -n "${CEPH_CINDER_USER}" ] ; then
    create_virsh_libvirt_secret ${CEPH_CINDER_USER} ${LIBVIRT_CEPH_CINDER_SECRET_UUID} ${CEPH_CINDER_KEYRING}
  fi

  if [ -n "${LIBVIRT_EXTERNAL_CEPH_CINDER_SECRET_UUID}" ] ; then
    EXTERNAL_CEPH_CINDER_KEYRING=$(cat /tmp/external-ceph-client-keyring)
    create_virsh_libvirt_secret ${EXTERNAL_CEPH_CINDER_USER} ${LIBVIRT_EXTERNAL_CEPH_CINDER_SECRET_UUID} ${EXTERNAL_CEPH_CINDER_KEYRING}
  fi

  cleanup

  # stop libvirtd; we needed it up to create secrets
  LIBVIRTD_PID=$(cat /var/run/libvirtd.pid)
  kill $LIBVIRTD_PID
  tail --pid=$LIBVIRTD_PID -f /dev/null

fi

if [ $CGROUP_VERSION != "v2" ]; then
  #NOTE(portdirect): run libvirtd as a transient unit on the host with the osh-libvirt cgroups applied.
  cgexec -g ${CGROUPS%,}:/osh-libvirt systemd-run --scope --slice=system libvirtd --listen
else
  systemd-run --scope --slice=system libvirtd --listen
fi
