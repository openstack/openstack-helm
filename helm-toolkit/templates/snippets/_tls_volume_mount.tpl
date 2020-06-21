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
  Renders a volume mount for TLS key, cert and CA.

  Dictionary Parameters:
    enabled: boolean check if you want to conditional disable this snippet (optional)
    name: name that of the volume and should match the volume name (required)
    path: path to place tls.crt tls.key ca.crt, do not suffix with '/' (required)
    certs: a tuple containing a nonempty subset of {tls.crt, tls.key, ca.crt}.
          the default is the full set. (optional)

values: |
  manifests:
    certificates: true

usage: |
  {{- $opts := dict "enabled" .Values.manifests.certificates "name" "glance-tls-api" "path" "/etc/glance/certs" -}}
  {{- $opts | include "helm-toolkit.snippets.tls_volume_mount" -}}

return: |
  - name: glance-tls-api
    mountPath: /etc/glance/certs/tls.crt
    subPath: tls.crt
    readOnly: true
  - name: glance-tls-api
    mountPath: /etc/glance/certs/tls.key
    subPath: tls.key
    readOnly: true
  - name: glance-tls-api
    mountPath: /etc/glance/certs/ca.crt
    subPath: ca.crt
    readOnly: true

abstract: |
  This mounts a specific issuing CA only for service validation

usage: |
  {{- $opts := dict "enabled" .Values.manifests.certificates "name" "glance-tls-api" "ca" true -}}
  {{- $opts | include "helm-toolkit.snippets.tls_volume_mount" -}}

return: |
  - name: glance-tls-api
    mountPath: /etc/ssl/certs/openstack-helm.crt
    subPath: ca.crt
    readOnly: true
*/}}
{{- define "helm-toolkit.snippets.tls_volume_mount" }}
{{- $enabled := index . "enabled" -}}
{{- $name := index . "name" -}}
{{- $path := index . "path" | default "" -}}
{{- $certs := index . "certs" | default ( tuple "tls.crt" "tls.key" "ca.crt" ) }}
{{- if $enabled }}
{{- if and (eq $path "") (ne $name "") }}
- name: {{ $name }}
  mountPath: "/etc/ssl/certs/openstack-helm.crt"
  subPath: ca.crt
  readOnly: true
{{- else }}
{{- if ne $name "" }}
{{- range $key, $value := $certs }}
- name: {{ $name }}
  mountPath: {{ printf "%s/%s" $path $value }}
  subPath: {{ $value }}
  readOnly: true
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
