{{/*
Copyright 2017-2018 OpenStack Foundation.

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

# This function generates fluentbit configuration files with entries in the
# ceph-osd values.yaml.  It results in a configuration section with the
# following format (for as many key/value pairs defined in values for a section):
# [HEADER]
#     key value
#     key value
#     key value
# The configuration schema can be found here:
# http://fluentbit.io/documentation/0.12/configuration/schema.html

{{- define "ceph-osd.utils.to_fluentbit_conf" -}}
{{- range $values := . -}}
{{- range $section := . -}}
{{- $header := pick . "header" -}}
{{- $config := omit . "header" }}
[{{$header.header | upper }}]
{{range $key, $value := $config -}}
{{ $key | indent 4 }} {{ $value }}
{{end -}}
{{- end -}}
{{- end -}}
{{- end -}}
