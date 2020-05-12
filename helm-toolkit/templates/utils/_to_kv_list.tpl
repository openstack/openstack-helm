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
  Returns key value pair in INI format (key = value)
values: |
  conf:
    libvirt:
      log_level: 3
usage: |
  {{ include "helm-toolkit.utils.to_kv_list" .Values.conf.libvirt }}
return: |
  log_level = 3
*/}}

{{- define "helm-toolkit.utils.to_kv_list" -}}
{{- range $key, $value :=  . -}}
{{- if kindIs "slice" $value }}
{{ $key }} = {{ include "helm-toolkit.utils.joinListWithComma" $value | quote }}
{{- else if kindIs "string" $value }}
{{- if regexMatch "^[0-9]+$" $value }}
{{ $key }} = {{ $value }}
{{- else }}
{{ $key }} = {{ $value | quote }}
{{- end }}
{{- else }}
{{ $key }} = {{ $value }}
{{- end }}
{{- end -}}
{{- end -}}
