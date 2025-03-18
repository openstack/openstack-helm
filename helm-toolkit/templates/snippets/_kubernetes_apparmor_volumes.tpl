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
  Renders the volumes used by the apparmor loader.
values: |
  pod:
    mandatory_access_control:
      type: apparmor
      configmap_apparmor: true
inputs: |
  envAll: "Environment or Context."
  component: "Name of the component used for the name of configMap."
  requireSys: "Boolean. True if it needs the hostpath /sys in volumes."
usage: |
  {{ dict "envAll" . "component" "keystone" "requireSys" true | include "helm-toolkit.snippets.kubernetes_apparmor_volumes" }}
return: |
- name: sys
  hostPath:
    path: /sys
- name: includes
  hostPath:
    path: /etc/apparmor.d
- name: profiles
  configMap:
    name: RELEASENAME-keystone-apparmor
    defaultMode: 0555
*/}}
{{- define "helm-toolkit.snippets.kubernetes_apparmor_volumes" -}}
{{- $envAll := index . "envAll" -}}
{{- $component := index . "component" -}}
{{- $requireSys := index . "requireSys" | default false -}}
{{- $configName := printf "%s-%s-%s" $envAll.Release.Name $component "apparmor" -}}
{{- if hasKey $envAll.Values.pod "mandatory_access_control" -}}
{{- if hasKey $envAll.Values.pod.mandatory_access_control "type" -}}
{{- if hasKey $envAll.Values.pod.mandatory_access_control "configmap_apparmor" -}}
{{- if eq $envAll.Values.pod.mandatory_access_control.type "apparmor" -}}
{{- if $envAll.Values.pod.mandatory_access_control.configmap_apparmor }}
{{- if $requireSys }}
- name: sys
  hostPath:
    path: /sys
{{- end }}
- name: includes
  hostPath:
    path: /etc/apparmor.d
- name: profiles
  configMap:
    name: {{ $configName | quote }}
    defaultMode: 0555
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
