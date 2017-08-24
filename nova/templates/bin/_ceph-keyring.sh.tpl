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
export HOME=/tmp

CEPH_CINDER_KEYRING_FILE="/etc/ceph/ceph.client.${CEPH_CINDER_USER}.keyring"
echo "[client.${CEPH_CINDER_USER}]" > ${CEPH_CINDER_KEYRING_FILE}
if ! [ -z "${CEPH_CINDER_KEYRING}" ] ; then
  echo "    key = ${CEPH_CINDER_KEYRING}" >> ${CEPH_CINDER_KEYRING_FILE}
else
  echo "    key = $(cat /tmp/client-keyring)" >> ${CEPH_CINDER_KEYRING_FILE}
fi
