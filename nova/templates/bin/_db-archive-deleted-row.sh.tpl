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

exec nova-manage db archive_deleted_rows \
{{- if .Values.conf.archive_deleted_rows.until_completion }}
   --until-complete \
{{- end}}
{{- if .Values.conf.archive_deleted_rows.purge_delete_rows }}
   --purge \
{{- end }}
{{- if .Values.conf.archive_deleted_rows.all_cells }}
   --all-cells \
{{- end}}
{{- if .Values.conf.archive_deleted_rows.max_rows.enabled }}
   --max_rows {{ .Values.conf.archive_deleted_rows.max_rows.rows }} \
{{- end }}
{{- if .Values.conf.archive_deleted_rows.before.enabled }}
   --before "{{ .Values.conf.archive_deleted_rows.before.date }}" \
{{- end }}
   --verbose
