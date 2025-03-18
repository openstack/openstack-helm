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
  Resolves the port for an endpoint
values: |
  endpoints:
    cluster_domain_suffix: cluster.local
    oslo_db:
      port:
        mysql:
          default: 3306
usage: |
  {{ tuple "oslo_db" "internal" "mysql" . | include "helm-toolkit.endpoints.endpoint_port_lookup" }}
return: |
  3306
*/}}

{{- define "helm-toolkit.endpoints.endpoint_port_lookup" -}}
{{- $type := index . 0 -}}
{{- $endpoint := index . 1 -}}
{{- $port := index . 2 -}}
{{- $context := index . 3 -}}
{{- $typeYamlSafe := $type | replace "-" "_" }}
{{- $endpointMap := index $context.Values.endpoints $typeYamlSafe }}
{{- $endpointPortMAP := index $endpointMap.port $port }}
{{- $endpointPort := index $endpointPortMAP $endpoint | default ( index $endpointPortMAP "default" ) }}
{{- printf "%1.f" $endpointPort -}}
{{- end -}}
