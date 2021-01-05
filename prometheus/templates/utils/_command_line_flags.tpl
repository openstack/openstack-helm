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

# This function generates the command line flags passed to Prometheus at time of
# execution. This allows the Prometheus service configuration to be flexible, as
# the only way to define Prometheus's configuration is via command line flags.
# The yaml definition for these flags uses the full yaml path as the key, and
# replaces underscores with hyphens to match the syntax required for the flags
# generated (This is required due to Go's yaml parsing capabilities).
# For example:
#
# conf:
#   prometheus:
#     command_line_flags:
#       storage.tsdb.max_block_duration: 2h
#
# Will generate the following flag:
#   --storage.tsdb.max-block-duration=2h
#
# Prometheus's command flags can be found by either running 'prometheus -h' or
# 'prometheus --help-man'

{{- define "prometheus.utils.command_line_flags" -}}
{{- range $flag, $value := . -}}
{{- $flag := $flag | replace "_" "-" }}
{{- if eq $flag "web.enable-admin-api" "web.enable-lifecycle" "storage.tsdb.wal-compression" -}}
{{- if $value }}
{{- printf " --%s " $flag -}}
{{- end -}}
{{- else -}}
{{- $value := $value | toString }}
{{- printf " --%s=%s " $flag $value }}
{{- end -}}
{{- end -}}
{{- end -}}
