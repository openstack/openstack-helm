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
  Builds a libvirt compatible config file.
values: |
  conf:
    libvirt:
      log_level: 3
      cgroup_controllers:
        - cpu
        - cpuacct
usage: |
  {{ include "libvirt.utils.to_libvirt_conf" .Values.conf.libvirt }}
return: |
  cgroup_controllers = [ "cpu", "cpuacct" ]
  log_level = 3
*/}}

{{- define "libvirt.utils._to_libvirt_conf.list_to_string" -}}
{{- $local := dict "first" true -}}
{{- range $k, $v := . -}}{{- if not $local.first -}}, {{ end -}}{{- $v | quote -}}{{- $_ := set $local "first" false -}}{{- end -}}
{{- end -}}

{{- define "libvirt.utils.to_libvirt_conf" -}}
{{- range $key, $value :=  . -}}
{{- if kindIs "slice" $value }}
{{ $key }} = [ {{ include "libvirt.utils._to_libvirt_conf.list_to_string" $value }} ]
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
