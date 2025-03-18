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
  Renders securityContext for a Kubernetes container.
  For container level, see here: https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#securitycontext-v1-core
examples:
  - values: |
      pod:
        security_context:
          myApp:
            container:
              foo:
                runAsUser: 34356
                readOnlyRootFilesystem: true
    usage: |
      {{ dict "envAll" . "application" "myApp" "container" "foo" | include "helm-toolkit.snippets.kubernetes_container_security_context" }}
    return: |
      securityContext:
        readOnlyRootFilesystem: true
        runAsUser: 34356
*/}}

{{- define "helm-toolkit.snippets.kubernetes_container_security_context" -}}
{{- $envAll := index . "envAll" -}}
{{- $application := index . "application" -}}
{{- $container := index . "container" -}}
{{- if hasKey $envAll.Values.pod "security_context" }}
{{- if hasKey ( index $envAll.Values.pod.security_context ) $application }}
{{- if hasKey ( index $envAll.Values.pod.security_context $application "container" ) $container }}
securityContext:
{{ toYaml ( index $envAll.Values.pod.security_context $application "container" $container ) | indent 2 }}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}
