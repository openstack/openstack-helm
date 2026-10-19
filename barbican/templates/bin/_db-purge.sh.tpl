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

args=(--min-days {{ .Values.conf.db_purge.min_days | quote }})
{{- if .Values.conf.db_purge.clean_unassociated_projects }}
args+=(--clean-unassociated-projects)
{{- end }}
{{- if .Values.conf.db_purge.soft_delete_expired_secrets }}
args+=(--soft-delete-expired-secrets)
{{- end }}

exec barbican-manage \
     --config-file /etc/barbican/barbican.conf \
     --config-dir /etc/barbican/barbican.conf.d \
     db clean "${args[@]}"
