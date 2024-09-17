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

#Setup Cgroups to use when breaking out of Kubernetes defined groups
CGROUPS=""
for CGROUP in {{ .Values.conf.kubernetes.cgroup_controllers | include "helm-toolkit.utils.joinListWithSpace"  }}; do
  if [ -d /sys/fs/cgroup/${CGROUP} ] || grep -w $CGROUP /sys/fs/cgroup/cgroup.controllers; then
    CGROUPS+="${CGROUP},"
  fi
done
cgcreate -g ${CGROUPS%,}:/osh-libvirt

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
fi

if [ -n "${LIBVIRT_CEPH_CINDER_SECRET_UUID}" ] || [ -n "${LIBVIRT_EXTERNAL_CEPH_CINDER_SECRET_UUID}" ] ; then

  cgexec -g ${CGROUPS%,}:/osh-libvirt systemd-run --scope --slice=system libvirtd --listen &

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

# NOTE(vsaienko): changing CGROUP is required as restart of the pod will cause domains restarts
cgexec -g ${CGROUPS%,}:/osh-libvirt systemd-run --scope --slice=system libvirtd --listen
