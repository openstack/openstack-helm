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

: "${CEPH_CONF:="/etc/ceph/${CLUSTER}.conf"}"
: "${EP:=ceph-mon-discovery}"
{{- if empty .Values.endpoints.ceph_mon.namespace -}}
MON_NS=ceph
{{ else }}
MON_NS={{ .Values.endpoints.ceph_mon.namespace }}
{{- end }}

{{ include "helm-toolkit.snippets.mon_host_from_k8s_ep" . }}

if [[ ! -e ${CEPH_CONF}.template ]]; then
  echo "ERROR- ${CEPH_CONF}.template must exist."
  exit 1
fi

ENDPOINT=$(mon_host_from_k8s_ep "${MON_NS}" "${EP}")

if [[ -z "${ENDPOINT}" ]]; then
   /bin/sh -c -e "cat ${CEPH_CONF}.template | tee ${CEPH_CONF}" || true
else
   /bin/sh -c -e "cat ${CEPH_CONF}.template | sed 's#mon_host.*#mon_host = ${ENDPOINT}#g' | tee ${CEPH_CONF}" || true
fi

cat >> ${CEPH_CONF} <<EOF

[client.rgw.$(hostname -s)]
{{ range $key, $value := .Values.conf.rgw.config -}}
{{- if kindIs "slice" $value -}}
{{ $key }} = {{ include "helm-toolkit.joinListWithComma" $value | quote }}
{{ else -}}
{{ $key }} = {{ $value | quote  }}
{{ end -}}
{{- end -}}
{{- if .Values.conf.rgw_ks.enabled }}
{{- if .Values.manifests.certificates }}
rgw_frontends = "beast ssl_port=${RGW_FRONTEND_PORT} ssl_certificate=/etc/tls/tls.crt ssl_private_key=/etc/tls/tls.key"
{{- else }}
rgw_frontends = "beast port=${RGW_FRONTEND_PORT}"
{{- end }}
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
{{ end }}
{{- if .Values.conf.rgw_s3.enabled }}
{{- if .Values.manifests.certificates }}
rgw_frontends = "beast ssl_port=${RGW_FRONTEND_PORT} ssl_certificate=/etc/tls/tls.crt ssl_private_key=/etc/tls/tls.key"
{{- else }}
rgw_frontends = "beast port=${RGW_FRONTEND_PORT}"
{{- end }}
{{ range $key, $value := .Values.conf.rgw_s3.config -}}
{{- if kindIs "slice" $value -}}
{{ $key }} = {{ include "helm-toolkit.joinListWithComma" $value | quote }}
{{ else -}}
{{ $key }} = {{ $value | quote  }}
{{ end -}}
{{- end -}}
{{ end }}
EOF
