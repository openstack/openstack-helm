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

KEYRING=/etc/ceph/ceph.client.${CEPH_CINDER_USER}.keyring
{{- if .Values.conf.ceph.cinder.keyring }}
cat > ${KEYRING} <<EOF
[client.{{ .Values.conf.ceph.cinder.user }}]
    key = {{ .Values.conf.ceph.cinder.keyring }}
EOF
{{- else }}
if ! [ "x${CEPH_CINDER_USER}" == "xadmin" ]; then
  #NOTE(Portdirect): Determine proper privs to assign keyring
  #NOTE(JCL): Restrict permissions to what is needed. So MON Read only and RBD access.
  ceph auth get-or-create client.${CEPH_CINDER_USER} \
    mon "profile rbd" \
    osd "profile rbd" \
    -o ${KEYRING}

  rm -f /etc/ceph/ceph.client.admin.keyring
fi
{{- end }}
