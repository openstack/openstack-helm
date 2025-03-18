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
  Renders mandatory access control annotations for a list of containers
  driven by values.yaml. As of now, it can only generate an apparmor
  annotation, but in the future could generate others.
values: |
  pod:
    mandatory_access_control:
      type: apparmor
      myPodName:
        myContainerName: localhost/myAppArmor
        mySecondContainerName: localhost/secondProfile # optional
        myThirdContainerName: localhost/thirdProfile # optional
usage: |
  {{ dict "envAll" . "podName" "myPodName" "containerNames" (list "myContainerName" "mySecondContainerName" "myThirdContainerName") | include "helm-toolkit.snippets.kubernetes_mandatory_access_control_annotation" }}
return: |
  container.apparmor.security.beta.kubernetes.io/myContainerName: localhost/myAppArmor
  container.apparmor.security.beta.kubernetes.io/mySecondContainerName: localhost/secondProfile
  container.apparmor.security.beta.kubernetes.io/myThirdContainerName: localhost/thirdProfile
note: |
  The number of container underneath is a variable arguments. It loops through
  all the container names specified.
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
container.apparmor.security.beta.kubernetes.io/{{ $name }}: {{ $apparmorProfile }}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}

