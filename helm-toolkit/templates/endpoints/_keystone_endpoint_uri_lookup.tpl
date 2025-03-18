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

{{/*
abstract: |
  This function helps resolve uri style endpoints. It will omit the port for
  http when 80 is used, and 443 in the case of https.
values: |
  endpoints:
    cluster_domain_suffix: cluster.local
    oslo_db:
      hosts:
        default: mariadb
      host_fqdn_override:
        default: null
      path: /dbname
      scheme: mysql+pymysql
      port:
        mysql:
          default: 3306
usage: |
  {{ tuple "oslo_db" "internal" "mysql" . | include "helm-toolkit.endpoints.keystone_endpoint_uri_lookup" }}
return: |
  mysql+pymysql://mariadb.default.svc.cluster.local:3306/dbname
*/}}

{{- define "helm-toolkit.endpoints.keystone_endpoint_uri_lookup" -}}
{{- $type := index . 0 -}}
{{- $endpoint := index . 1 -}}
{{- $port := index . 2 -}}
{{- $context := index . 3 -}}
{{- $endpointScheme := tuple $type $endpoint $port $context | include "helm-toolkit.endpoints.keystone_endpoint_scheme_lookup" }}
{{- $endpointHost := tuple $type $endpoint $context | include "helm-toolkit.endpoints.endpoint_host_lookup" }}
{{- $endpointPort := tuple $type $endpoint $port $context | include "helm-toolkit.endpoints.endpoint_port_lookup" }}
{{- $endpointPath := tuple $type $endpoint $port $context | include "helm-toolkit.endpoints.keystone_endpoint_path_lookup" }}
{{- if or ( and ( eq $endpointScheme "http" ) ( eq $endpointPort "80" ) ) ( and ( eq $endpointScheme "https" ) ( eq $endpointPort "443" ) ) -}}
{{- printf "%s://%s%s" $endpointScheme $endpointHost $endpointPath -}}
{{- else -}}
{{- printf "%s://%s:%s%s" $endpointScheme $endpointHost $endpointPort $endpointPath -}}
{{- end -}}
{{- end -}}
