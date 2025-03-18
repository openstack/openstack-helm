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
  Gets the token for an endpoint
values: |
  endpoints:
    keystone:
      auth:
        admin:
          token: zh78JzXgw6YUKy2e
usage: |
  {{ tuple "keystone" "admin" . | include "helm-toolkit.endpoints.endpoint_token_lookup" }}
return: |
  zh78JzXgw6YUKy2e
*/}}

{{- define "helm-toolkit.endpoints.endpoint_token_lookup" -}}
{{- $type := index . 0 -}}
{{- $userName := index . 1 -}}
{{- $context := index . 2 -}}
{{- $serviceToken := index $context.Values.endpoints ( $type | replace "-" "_" ) "auth" $userName "token" }}
{{- printf "%s" $serviceToken -}}
{{- end -}}
