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
  Resolves database, or basic auth, style endpoints
values: |
  endpoints:
    cluster_domain_suffix: cluster.local
    oslo_db:
      auth:
        admin:
          username: root
          password: password
        service_username:
          username: username
          password: password
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
  {{ tuple "oslo_db" "internal" "service_username" "mysql" . | include "helm-toolkit.endpoints.authenticated_endpoint_uri_lookup" }}
return: |
  mysql+pymysql://serviceuser:password@mariadb.default.svc.cluster.local:3306/dbname
*/}}

{{- define "helm-toolkit.endpoints.authenticated_endpoint_uri_lookup" -}}
{{- $type := index . 0 -}}
{{- $endpoint := index . 1 -}}
{{- $userclass := index . 2 -}}
{{- $port := index . 3 -}}
{{- $context := index . 4 -}}
{{- $endpointScheme := tuple $type $endpoint $port $context | include "helm-toolkit.endpoints.keystone_endpoint_scheme_lookup" }}
{{- $userMap := index $context.Values.endpoints ( $type | replace "-" "_" ) "auth" $userclass }}
{{- $endpointUser := index $userMap "username" }}
{{- $endpointPass := index $userMap "password" }}
{{- $endpointHost := tuple $type $endpoint $context | include "helm-toolkit.endpoints.endpoint_host_lookup" }}
{{- $endpointPort := tuple $type $endpoint $port $context | include "helm-toolkit.endpoints.endpoint_port_lookup" }}
{{- $endpointPath := tuple $type $endpoint $port $context | include "helm-toolkit.endpoints.keystone_endpoint_path_lookup" }}
{{- printf "%s://%s:%s@%s:%s%s" $endpointScheme $endpointUser $endpointPass $endpointHost $endpointPort $endpointPath -}}
{{- end -}}
