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
Note: This function is deprecated and will be removed in the future.

abstract: |
  Renders kubernetes resource limits for pods
values: |
  pod:
    resources:
      enabled: true
      api:
        requests:
          memory: "128Mi"
          cpu: "100m"
        limits:
          memory: "1024Mi"
          cpu: "2000m"
          hugepages-1Gi: "1Gi"

usage: |
  {{ include "helm-toolkit.snippets.kubernetes_resources" ( tuple . .Values.pod.resources.api ) }}
return: |
  resources:
    limits:
      cpu: "2000m"
      memory: "1024Mi"
      hugepages-1Gi: "1Gi"
    requests:
      cpu: "100m"
      memory: "128Mi
*/}}

{{- define "helm-toolkit.snippets.kubernetes_resources" -}}
{{- $envAll := index . 0 -}}
{{- $component := index . 1 -}}
{{- if $envAll.Values.pod.resources.enabled -}}
resources:
{{ toYaml $component | trim | indent 2 }}
{{- end -}}
{{- end -}}
