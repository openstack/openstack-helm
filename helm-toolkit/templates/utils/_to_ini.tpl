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
  Returns INI formatted output from yaml input
values: |
  conf:
    paste:
      filter:debug:
        use: egg:oslo.middleware#debug
      filter:request_id:
        use: egg:oslo.middleware#request_id
      filter:build_auth_context:
        use: egg:keystone#build_auth_context
usage: |
  {{ include "helm-toolkit.utils.to_ini" .Values.conf.paste }}
return: |
  [filter:build_auth_context]
  use = egg:keystone#build_auth_context
  [filter:debug]
  use = egg:oslo.middleware#debug
  [filter:request_id]
  use = egg:oslo.middleware#request_id
*/}}

{{- define "helm-toolkit.utils.to_ini" -}}
{{- range $section, $values := . -}}
{{- if kindIs "map" $values -}}
[{{ $section }}]
{{range $key, $value := $values -}}
{{- if kindIs "slice" $value -}}
{{ $key }} = {{ include "helm-toolkit.utils.joinListWithComma" $value }}
{{else -}}
{{ $key }} = {{ $value }}
{{end -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}
