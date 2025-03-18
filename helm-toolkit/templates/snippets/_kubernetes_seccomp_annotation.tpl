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
  Renders seccomp annotations for a list of containers driven by values.yaml.
values: |
  pod:
    seccomp:
      myPodName:
        myContainerName: localhost/mySeccomp
        mySecondContainerName: localhost/secondProfile # optional
        myThirdContainerName: localhost/thirdProfile # optional
usage: |
  {{ dict "envAll" . "podName" "myPodName" "containerNames" (list "myContainerName" "mySecondContainerName" "myThirdContainerName") | include "helm-toolkit.snippets.kubernetes_seccomp_annotation" }}
return: |
  container.seccomp.security.alpha.kubernetes.io/myContainerName: localhost/mySeccomp
  container.seccomp.security.alpha.kubernetes.io/mySecondContainerName: localhost/secondProfile
  container.seccomp.security.alpha.kubernetes.io/myThirdContainerName: localhost/thirdProfile
note: |
  The number of container underneath is a variable arguments. It loops through
  all the container names specified.
*/}}
{{- define "helm-toolkit.snippets.kubernetes_seccomp_annotation" -}}
{{- $envAll := index . "envAll" -}}
{{- $podName := index . "podName" -}}
{{- $containerNames := index . "containerNames" -}}
{{- if hasKey (index $envAll.Values.pod "seccomp") $podName -}}
{{- range $name := $containerNames -}}
{{- $seccompProfile := index $envAll.Values.pod.seccomp $podName $name -}}
{{- if $seccompProfile }}
container.seccomp.security.alpha.kubernetes.io/{{ $name }}: {{ $seccompProfile }}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}
