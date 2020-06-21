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
  Renders a secret volume for tls.

  Dictionary Parameters:
    enabled: boolean check if you want to conditional disable this snippet (optional)
    name: name of the volume (required)
    secretName: name of a kuberentes/tls secret, if not specified, use the volume name (optional)

values: |
  manifests:
    certificates: true

usage: |
  {{- $opts := dict "enabled" "true" "name" "glance-tls-api" -}}
  {{- $opts | include "helm-toolkit.snippets.tls_volume" -}}

return: |
  - name: glance-tls-api
    secret:
      secretName: glance-tls-api
      defaultMode: 292
*/}}
{{- define "helm-toolkit.snippets.tls_volume" }}
{{- $enabled := index . "enabled" -}}
{{- $name := index . "name" -}}
{{- $secretName := index . "secretName" | default $name -}}
{{- if and $enabled (ne $name "") }}
- name: {{ $name }}
  secret:
    secretName: {{ $secretName }}
    defaultMode: 292
{{- end }}
{{- end }}
