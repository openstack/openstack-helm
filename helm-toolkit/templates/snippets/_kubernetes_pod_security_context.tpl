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
  Renders securityContext for a Kubernetes pod.
  For pod level, seurity context see here: https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#podsecuritycontext-v1-core
examples:
  - values: |
      pod:
        # NOTE: The 'user' key is deprecated, and will be removed shortly.
        user:
          myApp:
            uid: 34356
        security_context:
          myApp:
            pod:
              runAsNonRoot: true
    usage: |
      {{ dict "envAll" . "application" "myApp" | include "helm-toolkit.snippets.kubernetes_pod_security_context" }}
    return: |
      securityContext:
        runAsUser: 34356
        runAsNonRoot: true
  - values: |
      pod:
        security_context:
          myApp:
            pod:
              runAsUser: 34356
              runAsNonRoot: true
    usage: |
      {{ dict "envAll" . "application" "myApp" | include "helm-toolkit.snippets.kubernetes_pod_security_context" }}
    return: |
      securityContext:
        runAsNonRoot: true
        runAsUser: 34356
*/}}

{{- define "helm-toolkit.snippets.kubernetes_pod_security_context" -}}
{{- $envAll := index . "envAll" -}}
{{- $application := index . "application" -}}
securityContext:
{{- if hasKey $envAll.Values.pod "user" }}
{{- if hasKey $envAll.Values.pod.user $application }}
{{- if hasKey ( index $envAll.Values.pod.user $application ) "uid" }}
  runAsUser: {{ index $envAll.Values.pod.user $application "uid" }}
{{- end -}}
{{- end -}}
{{- end -}}
{{- if hasKey $envAll.Values.pod "security_context" }}
{{- if hasKey ( index $envAll.Values.pod.security_context ) $application }}
{{ toYaml ( index $envAll.Values.pod.security_context $application "pod" ) | indent 2 }}
{{- end -}}
{{- end -}}
{{- end -}}
