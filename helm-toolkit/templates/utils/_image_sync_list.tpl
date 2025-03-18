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

{{- define "helm-toolkit.utils.image_sync_list" -}}
{{- $imageExcludeList := .Values.images.local_registry.exclude -}}
{{- $imageDict := .Values.images.tags -}}
{{- $local := dict "first" true -}}
{{- range $k, $v := $imageDict -}}
{{- if not $local.first -}},{{- end -}}
{{- if (not (has $k $imageExcludeList )) -}}
{{- index $imageDict $k -}}
{{- $_ := set $local "first" false -}}
{{- end -}}{{- end -}}
{{- end -}}
