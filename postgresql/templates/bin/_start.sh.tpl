#!/usr/bin/env bash

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

# Disable echo mode while setting the password
# unless we are in debug mode
{{- if .Values.conf.debug }}
set -x
{{- end }}
set -e

POSTGRES_DB=${POSTGRES_DB:-"postgres"}

# Check if the Postgres data directory exists before attempting to
# set the password
if [[ -d "$PGDATA" && -s "$PGDATA/PG_VERSION" ]]
then
  postgres --single -D "$PGDATA" "$POSTGRES_DB" <<EOF
ALTER ROLE $POSTGRES_USER WITH PASSWORD '$POSTGRES_PASSWORD'
EOF

fi

set -x

exec /docker-entrypoint.sh postgres -N {{ .Values.conf.postgresql.max_connections | quote }} -B {{ .Values.conf.postgresql.shared_buffers | quote }}
