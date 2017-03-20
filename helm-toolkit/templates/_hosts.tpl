# Copyright 2017 The Openstack-Helm Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# fqdn
{{- define "helm-toolkit.region"}}cluster{{- end}}
{{- define "helm-toolkit.tld"}}local{{- end}}

{{- define "helm-toolkit.fqdn" -}}
{{- $fqdn := .Release.Namespace -}}
{{- if .Values.endpoints.fqdn -}}
{{- $fqdn := .Values.endpoints.fqdn -}}
{{- end -}}
{{- $fqdn -}}
{{- end -}}

#-----------------------------------------
# hosts
#-----------------------------------------

# infrastructure services
{{- define "helm-toolkit.rabbitmq_host"}}rabbitmq.{{.Release.Namespace}}.svc.{{ include "helm-toolkit.region" . }}.{{ include "helm-toolkit.tld" . }}{{- end}}
{{- define "helm-toolkit.mariadb_host"}}mariadb.{{.Release.Namespace}}.svc.{{ include "helm-toolkit.region" . }}.{{ include "helm-toolkit.tld" . }}{{- end}}
{{- define "helm-toolkit.postgresql_host"}}postgresql.{{.Release.Namespace}}.svc.{{ include "helm-toolkit.region" . }}.{{ include "helm-toolkit.tld" . }}{{- end}}

# nova defaults
{{- define "helm-toolkit.nova_metadata_host"}}nova-api.{{ include "helm-toolkit.fqdn" . }}{{- end}}
