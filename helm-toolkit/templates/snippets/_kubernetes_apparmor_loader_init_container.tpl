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
  Renders the init container used for apparmor loading.
values: |
  images:
    tags:
      apparmor_loader: my-repo.io/apparmor-loader:1.0.0
  pod:
    mandatory_access_control:
      type: apparmor
      configmap_apparmor: true
      apparmor-loader: unconfined
usage: |
  {{ dict "envAll" . | include "helm-toolkit.snippets.kubernetes_apparmor_loader_init_container" }}
return: |
  - name: apparmor-loader
    image: my-repo.io/apparmor-loader:1.0.0
    args:
      - /profiles
    securityContext:
      privileged: true
    volumeMounts:
      - name: sys
        mountPath: /sys
        readOnly: true
      - name: includes
        mountPath: /etc/apparmor.d
        readOnly: true
      - name: profiles
        mountPath: /profiles
        readOnly: true
*/}}
{{- define "helm-toolkit.snippets.kubernetes_apparmor_loader_init_container" -}}
{{- $envAll := index . "envAll" -}}
{{- if hasKey $envAll.Values.pod "mandatory_access_control" -}}
{{- if hasKey $envAll.Values.pod.mandatory_access_control "type" -}}
{{- if hasKey $envAll.Values.pod.mandatory_access_control "configmap_apparmor" -}}
{{- if eq $envAll.Values.pod.mandatory_access_control.type "apparmor" -}}
{{- if $envAll.Values.pod.mandatory_access_control.configmap_apparmor }}
- name: apparmor-loader
  image: {{ $envAll.Values.images.tags.apparmor_loader }}
  args:
    - /profiles
  securityContext:
    privileged: true
  volumeMounts:
    - name: sys
      mountPath: /sys
      readOnly: true
    - name: includes
      mountPath: /etc/apparmor.d
      readOnly: true
    - name: profiles
      mountPath: /profiles
      readOnly: true
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
