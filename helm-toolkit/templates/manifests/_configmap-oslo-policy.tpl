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
  Renders out the configmap <service>-oslo-policy.
values: |
  conf:
    policy.d:
      file1:
        foo: bar
      file2:
        foo: baz
usage: |
{{- include "helm-toolkit.manifests.configmap_oslo_policy" (dict "envAll" $envAll "serviceName" "keystone") }}
return: |
  ---
  apiVersion: v1
  kind: Secret
  metadata:
    name: keystone-oslo-policy
  data:
    file1: base64of(foo: bar)
    file2: base64of(foo: baz)
*/}}
{{- define "helm-toolkit.manifests.configmap_oslo_policy" -}}
{{- $envAll := index . "envAll" -}}
{{- $serviceName := index . "serviceName" -}}
---
apiVersion: v1
kind: Secret
metadata:
  name: {{ $serviceName }}-oslo-policy
type: Opaque
data:
  {{- range $key, $value := index $envAll.Values.conf "policy.d" }}
  {{- if $value }}
  {{ $key }}: {{ toYaml $value | b64enc }}
  {{- else }}
  {{ $key }}: {{ "\n" | b64enc }}
  {{- end }}
  {{- end }}
{{- end -}}
