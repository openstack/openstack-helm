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
export LC_ALL=C
: "${CEPH_GET_ADMIN_KEY:=0}"
: "${RGW_NAME:=$(uname -n)}"
: "${RGW_ZONEGROUP:=}"
: "${RGW_ZONE:=}"
: "${ADMIN_KEYRING:=/etc/ceph/${CLUSTER}.client.admin.keyring}"
: "${RGW_KEYRING:=/var/lib/ceph/radosgw/${RGW_NAME}/keyring}"
: "${RGW_BOOTSTRAP_KEYRING:=/var/lib/ceph/bootstrap-rgw/${CLUSTER}.keyring}"

if [[ ! -e "/etc/ceph/${CLUSTER}.conf" ]]; then
  echo "ERROR- /etc/ceph/${CLUSTER}.conf must exist; get it from your existing mon"
  exit 1
fi

if [ "${CEPH_GET_ADMIN_KEY}" -eq 1 ]; then
  if [[ ! -e "${ADMIN_KEYRING}" ]]; then
      echo "ERROR- ${ADMIN_KEYRING} must exist; get it from your existing mon"
      exit 1
  fi
fi

# Check to see if our RGW has been initialized
if [ ! -e "${RGW_KEYRING}" ]; then

  if [ ! -e "${RGW_BOOTSTRAP_KEYRING}" ]; then
    echo "ERROR- ${RGW_BOOTSTRAP_KEYRING} must exist. You can extract it from your current monitor by running 'ceph auth get client.bootstrap-rgw -o ${RGW_BOOTSTRAP_KEYRING}'"
    exit 1
  fi

  timeout 10 ceph --cluster "${CLUSTER}" --name "client.bootstrap-rgw" --keyring "${RGW_BOOTSTRAP_KEYRING}" health || exit 1

  # Generate the RGW key
  ceph --cluster "${CLUSTER}" --name "client.bootstrap-rgw" --keyring "${RGW_BOOTSTRAP_KEYRING}" auth get-or-create "client.rgw.${RGW_NAME}" osd 'allow rwx' mon 'allow rw' -o "${RGW_KEYRING}"
  chown ceph. "${RGW_KEYRING}"
  chmod 0600 "${RGW_KEYRING}"
fi

/usr/bin/radosgw \
  --cluster "${CLUSTER}" \
  --setuser "ceph" \
  --setgroup "ceph" \
  -d \
  -n "client.rgw.${RGW_NAME}" \
  -k "${RGW_KEYRING}" \
  --rgw-socket-path="" \
  --rgw-zonegroup="${RGW_ZONEGROUP}" \
  --rgw-zone="${RGW_ZONE}"
