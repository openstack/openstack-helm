#!/usr/bin/env bash

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

set -e

MYSQL="mysql \
  --defaults-file=/etc/mysql/admin_user.cnf \
  --host=localhost \
{{- if .Values.manifests.certificates }}
  --ssl-verify-server-cert=false \
  --ssl-ca=/etc/mysql/certs/ca.crt \
  --ssl-key=/etc/mysql/certs/tls.key \
  --ssl-cert=/etc/mysql/certs/tls.crt \
{{- end }}
  --connect-timeout 2"

mysql_status_query () {
  STATUS=$1
  $MYSQL -e "show status like \"${STATUS}\"" | \
    awk "/${STATUS}/ { print \$NF; exit }"
}

if ! $MYSQL -e 'select 1' > /dev/null 2>&1 ; then
  exit 1
fi

{{- if gt (int .Values.pod.replicas.server) 1 }}
if [ "x$(mysql_status_query wsrep_ready)" != "xON" ]; then
  # WSREP says the node can receive queries
  exit 1
fi

if [ "x$(mysql_status_query wsrep_connected)" != "xON" ]; then
  # WSREP connected
  exit 1
fi

if [ "x$(mysql_status_query wsrep_cluster_status)" != "xPrimary" ]; then
  # Not in primary cluster
  exit 1
fi

if [ "x$(mysql_status_query wsrep_local_state_comment)" != "xSynced" ]; then
  # WSREP not synced
  exit 1
fi
{{- end }}
