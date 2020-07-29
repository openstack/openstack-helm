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

[client]
user = {{ .Values.endpoints.oslo_db.auth.admin.username }}
password = {{ .Values.endpoints.oslo_db.auth.admin.password }}
host = {{ tuple "oslo_db" "direct" . | include "helm-toolkit.endpoints.hostname_short_endpoint_lookup" }}
port = {{ tuple "oslo_db" "direct" "mysql" . | include "helm-toolkit.endpoints.endpoint_port_lookup" }}
{{- if .Values.manifests.certificates }}
ssl-ca = /etc/mysql/certs/ca.crt
ssl-key = /etc/mysql/certs/tls.key
ssl-cert = /etc/mysql/certs/tls.crt
{{- end }}
