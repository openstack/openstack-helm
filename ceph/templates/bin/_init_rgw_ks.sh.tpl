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

cp -va /tmp/ceph.conf /etc/ceph/ceph.conf

cat >> /etc/ceph/ceph.conf <<EOF

[client.rgw.${POD_NAME}]
rgw_frontends = "civetweb port=${RGW_CIVETWEB_PORT}"
rgw_keystone_url = "${KEYSTONE_URL}"
rgw_keystone_admin_user = "${OS_USERNAME}"
rgw_keystone_admin_password = "${OS_PASSWORD}"
rgw_keystone_admin_project = "${OS_PROJECT_NAME}"
rgw_keystone_admin_domain = "${OS_USER_DOMAIN_NAME}"
{{ range $key, $value := .Values.conf.rgw_ks.config -}}
{{- if kindIs "slice" $value -}}
{{ $key }} = {{ include "helm-toolkit.joinListWithComma" $value | quote }}
{{ else -}}
{{ $key }} = {{ $value | quote  }}
{{ end -}}
{{- end -}}
EOF
