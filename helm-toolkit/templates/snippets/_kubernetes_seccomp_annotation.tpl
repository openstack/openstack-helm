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
  Deprecated, renders nothing. This snippet used to render seccomp
  annotations, which Kubernetes replaced with the seccompProfile field of
  the pod and container securityContext, set through pod.security_context.
  It now fails the render when pod.seccomp sets a profile for one of the
  containers, so that a deployment relying on it is not silently left
  running without its profile.
values: |
  pod:
    seccomp:
      myPodName:
        myContainerName: localhost/mySeccomp
usage: |
  {{ dict "envAll" . "podName" "myPodName" "containerNames" (list "myContainerName") | include "helm-toolkit.snippets.kubernetes_seccomp_annotation" }}
return: |
  Nothing when no profile is set. Otherwise the render fails with:
  pod.seccomp.myPodName.myContainerName: seccomp profiles can no longer be
  set per container under pod.seccomp, set seccompProfile under
  pod.security_context instead.
note: |
  This snippet is kept for backward compatibility only, so that charts still
  calling it keep rendering and values still setting a profile are rejected
  rather than ignored. It will be removed in a future release. Set the
  profile through pod.security_context instead:

  pod:
    security_context:
      myApplication:
        container:
          myContainerName:
            seccompProfile:
              type: Localhost
              localhostProfile: mySeccomp
*/}}
{{- define "helm-toolkit.snippets.kubernetes_seccomp_annotation" -}}
{{- $envAll := index . "envAll" -}}
{{- $podName := index . "podName" -}}
{{- $containerNames := index . "containerNames" -}}
{{- if hasKey $envAll.Values.pod "seccomp" -}}
{{- if hasKey $envAll.Values.pod.seccomp $podName -}}
{{- range $name := $containerNames -}}
{{- $seccompProfile := index $envAll.Values.pod.seccomp $podName $name -}}
{{- if $seccompProfile }}
{{- fail (printf "pod.seccomp.%s.%s: seccomp profiles can no longer be set per container under pod.seccomp, set seccompProfile under pod.security_context instead." $podName $name) }}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}
