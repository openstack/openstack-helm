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
export HOME=/tmp

cp -fv /etc/ceph/ceph.conf.template /etc/ceph/ceph.conf

KEYRING=/etc/ceph/ceph.client.${CEPH_CINDER_USER}.keyring
{{- if .Values.conf.ceph.cinder.keyring }}
cat > ${KEYRING} <<EOF
[client.{{ .Values.conf.ceph.cinder.user }}]
    key = {{ .Values.conf.ceph.cinder.keyring }}
EOF
{{- else }}
if ! [ "x${CEPH_CINDER_USER}" == "xadmin" ]; then
  #
  # If user is not client.admin, check if it already exists. If not create
  # the user. If the cephx user does not exist make sure the caps are set
  # according to best practices
  #
  if USERINFO=$(ceph auth get client.${CEPH_CINDER_USER}); then
    echo "Cephx user client.${CEPH_CINDER_USER} already exist"
    echo "Update user client.${CEPH_CINDER_USER} caps"
    ceph auth caps client.${CEPH_CINDER_USER} \
       mon "profile rbd" \
       osd "profile rbd"
    ceph auth get client.${CEPH_CINDER_USER} -o ${KEYRING}
  else
    echo "Creating Cephx user client.${CEPH_CINDER_USER}"
    ceph auth get-or-create client.${CEPH_CINDER_USER} \
      mon "profile rbd" \
      osd "profile rbd" \
      -o ${KEYRING}
  fi
  rm -f /etc/ceph/ceph.client.admin.keyring
fi
{{- end }}
