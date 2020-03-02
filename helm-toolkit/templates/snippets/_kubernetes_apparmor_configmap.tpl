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
  Renders a configmap used for loading custom AppArmor profiles.
values: |
  pod:
    mandatory_access_control:
      type: apparmor
      configmap_apparmor: true
      apparmor_profiles: |-
        my_apparmor-v1.profile: |-
          #include <tunables/global>
          profile my-apparmor-v1 flags=(attach_disconnected,mediate_deleted) {
            <profile_data>
          }
usage: |
  {{ dict "envAll" . "component" "myComponent" | include "helm-toolkit.snippets.kubernetes_apparmor_configmap" }}
return: |
apiVersion: v1
kind: ConfigMap
metadata:
  name: releaseName-myComponent-apparmor
  namespace: myNamespace
data:
  my_apparmor-v1.profile: |-
    #include <tunables/global>
    profile my-apparmor-v1 flags=(attach_disconnected,mediate_deleted) {
      <profile_data>
    }
*/}}
{{- define "helm-toolkit.snippets.kubernetes_apparmor_configmap" -}}
{{- $envAll := index . "envAll" -}}
{{- $component := index . "component" -}}
{{- if hasKey $envAll.Values.pod "mandatory_access_control" -}}
{{- if hasKey $envAll.Values.pod.mandatory_access_control "type" -}}
{{- if eq $envAll.Values.pod.mandatory_access_control.type "apparmor" -}}
{{- if hasKey $envAll.Values.pod.mandatory_access_control "configmap_apparmor" -}}
{{- if $envAll.Values.pod.mandatory_access_control.configmap_apparmor }}
{{- $mapName := printf "%s-%s-%s" $envAll.Release.Name $component "apparmor" -}}
{{- if $envAll.Values.conf.apparmor_profiles }}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ $mapName }}
  namespace: {{ $envAll.Release.Namespace }}
data:
{{ $envAll.Values.conf.apparmor_profiles | toYaml | indent 2 }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
