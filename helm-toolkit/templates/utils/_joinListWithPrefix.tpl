{/*
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
  Joins a list of prefixed values into a space separated string
values: |
  test:
    - foo
    - bar
usage: |
  {{ tuple "prefix" .Values.test | include "helm-toolkit.utils.joinListWithPrefix" }}
return: |
  prefixfoo prefixbar
*/}}

{{- define "helm-toolkit.utils.joinListWithPrefix" -}}
{{- $prefix := index . 0 -}}
{{- $local := dict "first" true -}}
{{- range $k, $v := index . 1 -}}{{- if not $local.first -}}{{- " " -}}{{- end -}}{{- $prefix -}}{{- $v -}}{{- $_ := set $local "first" false -}}{{- end -}}
{{- end -}}
