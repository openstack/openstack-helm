{{/*
Copyright 2017 The Openstack-Helm Authors.

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

# This function generates fluentd configuration files with entries in the
# fluent-logging values.yaml.  It results in a configuration section with either
# of the following formats (for as many key/value pairs defined in values for a
section):
# <HEADER>
#   key value
#   key value
#   key value
# </HEADER>
# or
# <HEADER>
#   key value
#   <INNER_HEADER>
#     key value
#   </INNER_HEADER>
# </HEADER>
# The configuration schema can be found here:
# https://docs.fluentd.org/v0.12/articles/config-file

{{- define "fluent_logging.utils.to_fluentd_conf" -}}
{{- range $values := . -}}
{{- range $section := . -}}
{{- $header := pick . "header" -}}
{{- $config := omit . "header" "expression" -}}
{{- if hasKey . "expression" -}}
{{ $regex := pick . "expression" }}
{{ printf "<%s %s>" $header.header $regex.expression }}
{{- else }}
{{ printf "<%s>" $header.header }}
{{- end }}
{{- range $key, $value := $config -}}
{{- if kindIs "slice" $value }}
{{- range $value := . -}}
{{- range $innerSection := . -}}
{{- $innerHeader := pick . "header" -}}
{{- $innerConfig := omit . "header" "expression" -}}
{{- if hasKey . "expression" -}}
{{ $innerRegex := pick . "expression" }}
{{ printf "<%s %s>" $innerHeader.header $innerRegex.expression | indent 2 }}
{{- else }}
{{ printf "<%s>" $innerHeader.header | indent 2 }}
{{- end }}
{{- range $innerKey, $innerValue := $innerConfig -}}
{{- if eq $innerKey "type" -}}
{{ $type := list "@" "type" | join "" }}
{{ $type | indent 4 }} {{ $innerValue }}
{{- else if contains "ENV" ($innerValue | quote) }}
{{ $innerKey | indent 4 }} {{ $innerValue | quote }}
{{- else if eq $innerKey "flush_interval" }}
{{ $innerKey | indent 4 }} {{ printf "%ss" $innerValue }}
{{- else }}
{{ $innerKey | indent 4 }} {{ $innerValue }}
{{- end }}
{{- end }}
{{ printf "</%s>" $innerHeader.header | indent 2 }}
{{- end -}}
{{ end -}}
{{- else }}
{{- if eq $key "type" -}}
{{ $type := list "@" "type" | join "" }}
{{ $type | indent 2 }} {{ $value }}
{{- else if contains "ENV" ($value | quote) }}
{{ $key | indent 2 }} {{ $value | quote }}
{{- else if eq $key "flush_interval" }}
{{ $key | indent 2 }} {{ printf "%ss" $value }}
{{- else }}
{{ $key | indent 2 }} {{ $value }}
{{- end -}}
{{- end -}}
{{- end }}
{{ printf "</%s>" $header.header }}
{{- end }}
{{ end -}}
{{- end -}}
