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
  Adds custom annotations to the secret spec of a component.
examples:
  - values: |
      pod:
        priorityClassName:
          designate_api: "high-priority"
    usage: |
      {{ tuple "designate_api" . | include "helm-toolkit.snippets.kubernetes_pod_priority_class" }}
    return: |
      priorityClassName: "high-priority"
  - values: |
      pod:
        priorityClassName: {}
    usage: |
      {{ tuple "designate_api" . | include "helm-toolkit.snippets.kubernetes_pod_priority_class" }}
    return: |
      ""
*/}}

{{- define "helm-toolkit.snippets.kubernetes_pod_priority_class" -}}
{{- $component := index . 0 | replace "-" "_" -}}
{{- $envAll := index . 1 -}}
{{- $priorityClassName := dig "priorityClassName" $component false $envAll.Values.pod -}}
{{- if $priorityClassName -}}
{{- toYaml (dict "priorityClassName" $priorityClassName) -}}
{{- end -}}
{{- end -}}
