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
  Resolves the service name for an service type
values: |
  endpoints:
    identity:
      name: keystone
usage: |
  {{ tuple identity . | include "keystone_endpoint_name_lookup" }}
return: |
  "keystone"
*/}}

{{- define "helm-toolkit.endpoints.keystone_endpoint_name_lookup" -}}
{{- $type := index . 0 -}}
{{- $context := index . 1 -}}
{{- $endpointMap := index $context.Values.endpoints ( $type | replace "-" "_" ) }}
{{- $endpointName := index $endpointMap "name" }}
{{- $endpointName | quote -}}
{{- end -}}
