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
  Deprecated, renders nothing. This snippet used to render AppArmor
  annotations, which Kubernetes replaced with the appArmorProfile field of
  the pod and container securityContext, set through pod.security_context.
  It now fails the render when pod.mandatory_access_control sets an AppArmor
  profile for one of the containers, so that a deployment relying on it is
  not silently left running without its profile.
values: |
  pod:
    mandatory_access_control:
      type: apparmor
      myPodName:
        myContainerName: localhost/myAppArmor
usage: |
  {{ dict "envAll" . "podName" "myPodName" "containerNames" (list "myContainerName") | include "helm-toolkit.snippets.kubernetes_mandatory_access_control_annotation" }}
return: |
  Nothing when no profile is set. Otherwise the render fails with:
  pod.mandatory_access_control.myPodName.myContainerName: AppArmor profiles
  can no longer be set per container under pod.mandatory_access_control, set
  appArmorProfile under pod.security_context instead.
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
            appArmorProfile:
              type: Localhost
              localhostProfile: myAppArmor
*/}}
{{- define "helm-toolkit.snippets.kubernetes_mandatory_access_control_annotation" -}}
{{- $envAll := index . "envAll" -}}
{{- $podName := index . "podName" -}}
{{- $containerNames := index . "containerNames" -}}
{{- if hasKey $envAll.Values.pod "mandatory_access_control" -}}
{{- if hasKey $envAll.Values.pod.mandatory_access_control "type" -}}
{{- $macType := $envAll.Values.pod.mandatory_access_control.type -}}
{{- if $macType -}}
{{- if eq $macType "apparmor" -}}
{{- if hasKey $envAll.Values.pod.mandatory_access_control $podName -}}
{{- range $name := $containerNames -}}
{{- $apparmorProfile := index $envAll.Values.pod.mandatory_access_control $podName $name -}}
{{- if $apparmorProfile }}
{{- fail (printf "pod.mandatory_access_control.%s.%s: AppArmor profiles can no longer be set per container under pod.mandatory_access_control, set appArmorProfile under pod.security_context instead." $podName $name) }}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}
