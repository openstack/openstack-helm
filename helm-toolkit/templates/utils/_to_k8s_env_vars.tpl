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
  Returns key value pair formatted to be used in k8s templates as container
  env vars.
values: |
  test:
    foo: bar
usage: |
  {{ include "helm-toolkit.utils.to_k8s_env_vars" .Values.test }}
return: |
  - name: foo
    value: "bar"
*/}}

{{- define "helm-toolkit.utils.to_k8s_env_vars" -}}
{{range $key, $value := . -}}
{{- if kindIs "slice" $value -}}
- name: {{ $key }}
  value: {{ include "helm-toolkit.utils.joinListWithComma" $value | quote }}
{{else -}}
- name: {{ $key }}
  value: {{ $value | quote }}
{{ end -}}
{{- end -}}
{{- end -}}
