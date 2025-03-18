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
  Resolves the namespace scoped hostname for an endpoint
values: |
  endpoints:
    oslo_db:
      hosts:
        default: mariadb
      host_fqdn_override:
        default: null
usage: |
  {{ tuple "oslo_db" "internal" . | include "helm-toolkit.endpoints.hostname_namespaced_endpoint_lookup" }}
return: |
  mariadb.default
*/}}

{{- define "helm-toolkit.endpoints.hostname_namespaced_endpoint_lookup" -}}
{{- $type := index . 0 -}}
{{- $endpoint := index . 1 -}}
{{- $context := index . 2 -}}
{{- $endpointMap := index $context.Values.endpoints ( $type | replace "-" "_" ) }}
{{- $namespace := $endpointMap.namespace | default $context.Release.Namespace }}
{{- $endpointHost := tuple $type $endpoint $context | include "helm-toolkit.endpoints.hostname_short_endpoint_lookup" }}
{{- $endpointClusterHostname := printf "%s.%s" $endpointHost $namespace }}
{{- printf "%s" $endpointClusterHostname -}}
{{- end -}}
