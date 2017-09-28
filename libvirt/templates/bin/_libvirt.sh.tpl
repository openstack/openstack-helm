#!/bin/bash

{{/*
Copyright 2017 The Openstack-Helm Authors.

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

if [ -n "$(cat /proc/*/comm 2>/dev/null | grep libvirtd)" ]; then
    echo "ERROR: libvirtd daemon already running on host" 1>&2
    exit 1
fi

rm -f /var/run/libvirtd.pid

if [[ -c /dev/kvm ]]; then
    chmod 660 /dev/kvm
    chown root:kvm /dev/kvm
fi

if [ "x${LIBVIRT_CEPH_ENABLED}" == "xTrue" ] ; then
  libvirtd --listen &

  LIBVIRT_SECRET_DEF=$(mktemp --suffix .xml)
  function cleanup {
      rm -f ${LIBVIRT_SECRET_DEF}
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

  if [ -z "${LIBVIRT_CEPH_SECRET_UUID}" ] ; then
    echo "ERROR: No libvirt Secret UUID Supplied"
    exit 1
  fi

  if [ -z "${CEPH_CINDER_KEYRING}" ] ; then
    CEPH_CINDER_KEYRING=$(sed -n 's/^[[:space:]]*key[[:blank:]]\+=[[:space:]]\(.*\)/\1/p' /etc/ceph/ceph.client.${CEPH_CINDER_USER}.keyring)
  fi

  cat > ${LIBVIRT_SECRET_DEF} <<EOF
<secret ephemeral='no' private='no'>
  <uuid>${LIBVIRT_CEPH_SECRET_UUID}</uuid>
  <usage type='ceph'>
    <name>client.${CEPH_CINDER_USER}. secret</name>
  </usage>
</secret>
EOF

  virsh secret-define --file ${LIBVIRT_SECRET_DEF}
  virsh secret-set-value --secret "${LIBVIRT_CEPH_SECRET_UUID}" --base64 "${CEPH_CINDER_KEYRING}"

  # rejoin libvirtd
  wait
else
  exec libvirtd --listen
fi
