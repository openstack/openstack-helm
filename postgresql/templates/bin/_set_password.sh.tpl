#!/usr/bin/env bash

{{/*
Copyright 2019 The Openstack-Helm Authors.

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

PGDATABASE=${PGDATABASE:-'postgres'}
PGHOST=${PGHOST:-'127.0.0.1'}
PGPORT={{ tuple "postgresql" "internal" "postgresql" . | include "helm-toolkit.endpoints.endpoint_port_lookup" }}

# These are passed in via the Patroni callback interface
action="$1"
role="$2"
cluster="$3"

# Note: this script when rendered is stored in a secret and encrypted to disk.
PATRONI_SUPERUSER_USERNAME={{ .Values.endpoints.postgresql.auth.admin.username }}
PATRONI_SUPERUSER_PASSWORD={{ .Values.endpoints.postgresql.auth.admin.password }}
PATRONI_REPLICATION_USERNAME={{ .Values.endpoints.postgresql.auth.replica.username }}

if [[ x${role} == "xmaster" ]]; then
  echo "I have become the patroni master: updating superuser and replication passwords"

  # It can take a few seconds for a freshly promoted leader to become read/write.
  sleep 10
  if [[ ! -z "$PATRONI_SUPERUSER_PASSWORD" && ! -z "$PATRONI_SUPERUSER_USERNAME" ]]; then
    psql -U $PATRONI_SUPERUSER_USERNAME -p "$PGPORT" -d "$PGDATABASE" -c "ALTER ROLE $PATRONI_SUPERUSER_USERNAME WITH PASSWORD '$PATRONI_SUPERUSER_PASSWORD';"
  else
    echo "WARNING: Did not set superuser password!!!"
  fi

  echo "password update complete"
fi
