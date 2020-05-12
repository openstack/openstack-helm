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

{{- define "rabbitmq.utils.to_rabbit_config" -}}
{{- range $top_key, $top_value :=  . }}
{{- if kindIs "map" $top_value -}}
{{- range $second_key, $second_value :=  . }}
{{- if kindIs "map" $second_value -}}
{{- range $third_key, $third_value :=  . }}
{{- if kindIs "map" $third_value -}}
{{ $top_key }}.{{ $second_key }}.{{ $third_key }} = wow
{{ else -}}
{{ $top_key }}.{{ $second_key }}.{{ $third_key }} = {{ $third_value }}
{{ end -}}
{{- end -}}
{{ else -}}
{{ $top_key }}.{{ $second_key }} = {{ $second_value }}
{{ end -}}
{{- end -}}
{{ else -}}
{{ $top_key }} = {{ $top_value }}
{{ end -}}
{{- end -}}
{{- end -}}
