#!/bin/bash

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

set -ex
export HOME=/tmp

{{ if .Values.bootstrap.structured.flavors.enabled }}
{{- range $i, $params := .Values.bootstrap.structured.flavors.options }}
{
openstack flavor show {{ $params.name }} || \
  openstack flavor create \
  {{- range $key, $val := $params }}
    {{- if ne $key "name" }}
      {{- if eq $key "extra_specs" }}
        {{- if kindIs "slice" $val }}
          {{- range $idx, $spec := $val }}
  --property {{ $spec }} \
          {{- end }}
        {{- end }}
      {{- else if eq $key "is_public" }}
        {{- if $val }}
  --public \
        {{- else if not $val }}
  --private \
        {{- end }}
      {{- else }}
  --{{ $key }} {{ $val }} \
      {{- end }}
    {{- end }}
  {{- end }}
  {{ $params.name }}
} &
{{ end }}
wait
{{ end }}

{{ if .Values.bootstrap.wait_for_computes.enabled }}
{{ .Values.bootstrap.wait_for_computes.scripts.wait_script }}
{{ else }}
echo 'Wait for Computes script not enabled'
{{ end }}

{{ .Values.bootstrap.script | default "echo 'No other bootstrap customizations found.'" }}
