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
  Renders upgradeStrategy configuration for Kubernetes statefulsets.
  See: https://kubernetes.io/docs/tutorials/stateful-application/basic-stateful-set/#updating-statefulsets
  Types:
    - RollingUpdate (default)
    - OnDelete
  Partitions:
    - Stage updates to a statefulset by keeping pods at current version while
      allowing mutations to statefulset's .spec.template
values: |
  pod:
    lifecycle:
      upgrades:
        statefulsets:
          pod_replacement_strategy: RollingUpdate
          partition: 2
usage: |
  {{ tuple $envAll | include "helm-toolkit.snippets.kubernetes_upgrades_statefulset" | indent 2 }}
return: |
  updateStrategy:
    type: RollingUpdate
    rollingUpdate:
      partition: 2
*/}}

{{- define "helm-toolkit.snippets.kubernetes_upgrades_statefulset" -}}
{{- $envAll := index . 0 -}}
{{- with $envAll.Values.pod.lifecycle.upgrades.statefulsets -}}
updateStrategy:
  type: {{ .pod_replacement_strategy }}
  {{ if .partition -}}
  rollingUpdate:
    partition: {{ .partition }}
  {{- end -}}
{{- end -}}
{{- end -}}
