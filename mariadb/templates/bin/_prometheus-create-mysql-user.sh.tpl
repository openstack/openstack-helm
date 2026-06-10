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

set -e

{{- if .Values.manifests.certificates }}
# Connect over TLS, presenting the MariaDB server certificate (mounted at
# /etc/mysql/certs) as the client certificate. Skip server hostname
# verification: this job connects to the 'direct' service (mariadb-server),
# which is not a SAN in the server certificate. This matches the chart's
# other admin clients (see bin/_health.sh.tpl, bin/_start.py.tpl).
MYSQL_SSL_OPTS="--ssl-verify-server-cert=false"
{{- else }}
MYSQL_SSL_OPTS=""
{{- end }}

  # SLAVE MONITOR
  # Grants ability to SHOW SLAVE STATUS, SHOW REPLICA STATUS,
  # SHOW ALL SLAVES STATUS, SHOW ALL REPLICAS STATUS, SHOW RELAYLOG EVENTS.
  # New privilege added in MariaDB Enterprise Server 10.5.8-5. Alias for REPLICA MONITOR.
  #
  # REPLICATION CLIENT
  # Grants ability to SHOW MASTER STATUS, SHOW SLAVE STATUS, SHOW BINARY LOGS. In ES10.5,
  # is an alias for BINLOG MONITOR and the capabilities have changed. BINLOG MONITOR grants
  # ability to SHOW MASTER STATUS, SHOW BINARY LOGS, SHOW BINLOG EVENTS, and SHOW BINLOG STATUS.

  mariadb_version=$(mariadb --defaults-file=/etc/mysql/admin_user.cnf ${MYSQL_SSL_OPTS} -e "status" | grep -E '^Server\s+version:')
  echo "Current database ${mariadb_version}"

  if [[ ! -z ${mariadb_version} && -z $(grep -E '10.2|10.3|10.4' <<< ${mariadb_version}) ]]; then
    # In case MariaDB version is 10.2.x-10.4.x - we use old privileges definitions
    if ! mariadb --defaults-file=/etc/mysql/admin_user.cnf ${MYSQL_SSL_OPTS} -e \
      "CREATE OR REPLACE USER '${EXPORTER_USER}'@'127.0.0.1' IDENTIFIED BY '${EXPORTER_PASSWORD}'; \
      GRANT SLAVE MONITOR, PROCESS, BINLOG MONITOR, SLAVE MONITOR, SELECT ON *.* TO '${EXPORTER_USER}'@'127.0.0.1'; \
      FLUSH PRIVILEGES;" ; then
      echo "ERROR: Could not create user: ${EXPORTER_USER}"
      exit 1
    fi
  else
    # here we use new MariaDB privileges definitions defines since version 10.5
    if ! mariadb --defaults-file=/etc/mysql/admin_user.cnf ${MYSQL_SSL_OPTS} -e \
      "CREATE OR REPLACE USER '${EXPORTER_USER}'@'127.0.0.1' IDENTIFIED BY '${EXPORTER_PASSWORD}'; \
      GRANT SLAVE MONITOR, PROCESS, REPLICATION CLIENT, SELECT ON *.* TO '${EXPORTER_USER}'@'127.0.0.1'  ${MARIADB_X509}; \
      FLUSH PRIVILEGES;" ; then
      echo "ERROR: Could not create user: ${EXPORTER_USER}"
      exit 1
    fi
  fi
