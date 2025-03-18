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
  Renders kubernetes tolerations for pods
values: |
  pod:
    tolerations:
      api:
        enabled: true
        tolerations:
        - key: node-role.kubernetes.io/master
          operator: Exists
        - key: node-role.kubernetes.io/node
          operator: Exists

usage: |
  {{ include "helm-toolkit.snippets.kubernetes_tolerations" ( tuple . .Values.pod.tolerations.api ) }}
return: |
  tolerations:
  - key: node-role.kubernetes.io/master
    operator: Exists
  - key: node-role.kubernetes.io/node
    operator: Exists
*/}}

{{- define "helm-toolkit.snippets.kubernetes_tolerations" -}}
{{- $envAll := index . 0 -}}
{{- $component := index . 1 -}}
{{- $pod := index $envAll.Values.pod.tolerations $component }}
tolerations:
{{ toYaml $pod.tolerations }}
{{- end -}}
