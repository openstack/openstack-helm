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

{{- define "helm-toolkit.utils.configmap_templater" }}
{{- $keyRoot := index . 0 -}}
{{- $configTemplate := index . 1 -}}
{{- $context := index . 2 -}}
{{ if $keyRoot.override -}}
{{ $keyRoot.override | indent 4 }}
{{- else -}}
{{- if $keyRoot.prefix -}}
{{ $keyRoot.prefix | indent 4 }}
{{- end }}
{{ tuple $configTemplate $context | include "helm-toolkit.utils.template" | indent 4 }}
{{- end }}
{{- if $keyRoot.append -}}
{{ $keyRoot.append | indent 4 }}
{{- end }}
{{- end -}}
