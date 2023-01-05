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

set -exo pipefail
COMMAND="${@:-start}"
PORT={{ tuple "grafana" "internal" "grafana" . | include "helm-toolkit.endpoints.endpoint_port_lookup" }}
PIDFILE=/tmp/pid
DB_HOST={{ tuple "oslo_db" "direct" . | include "helm-toolkit.endpoints.hostname_fqdn_endpoint_lookup" }}
DB_PORT={{ tuple "oslo_db" "direct" "mysql" . | include "helm-toolkit.endpoints.endpoint_port_lookup" }}
MYSQL_PARAMS=" \
  --defaults-file=/tmp/my.cnf \
  --host=${DB_HOST} \
  --port=${DB_PORT}
{{- if .Values.manifests.certificates }}
  --ssl-verify-server-cert=false \
  --ssl-ca=/etc/mysql/certs/ca.crt \
  --ssl-key=/etc/mysql/certs/tls.key \
  --ssl-cert=/etc/mysql/certs/tls.crt \
{{- end }}
  "

function start () {
  exec /usr/share/grafana/bin/grafana-server -homepath=/usr/share/grafana -config=/etc/grafana/grafana.ini --pidfile="$PIDFILE"
}

function run_migrator () {
  BACKUP_FILE=$(mktemp)
  LOG_FILE=$(mktemp)
  STOP_FLAG=$(mktemp)
  echo "Making sure the database is reachable...."
  set +e
  until mysql ${MYSQL_PARAMS} grafana -e "select 1;"
  do
    echo \"Database ${DB_HOST} is not reachable. Sleeping for 10 seconds...\"
    sleep 10
  done
  set -e
  echo "Preparing initial database backup..."
  mysqldump ${MYSQL_PARAMS} --add-drop-table --quote-names grafana > "${BACKUP_FILE}"
  echo "Backup SQL file ${BACKUP_FILE}"
  ls -lh "${BACKUP_FILE}"
  {
    # this is the background process that re-starts grafana-server
    # in prder to process grafana database migration
    set +e
    while true
    do
      start 2>&1 | tee "$LOG_FILE"
      sleep 10
      echo "Restarting the grafana-server..."
      stop
      echo "Emptying log file..."
      echo > "$LOG_FILE"
      while [ -f ${STOP_FLAG} ]
      do
        echo "Lock file still exists - ${STOP_FLAG}..."
        ls -la ${STOP_FLAG}
        echo "Waiting for lock file to get removed..."
        sleep 5
      done
      echo "Lock file is removed, proceeding with grafana re-start.."
    done
    set -e
  } &
  until cat "${LOG_FILE}" | grep -E "migrations completed"
  do
    echo "The migrations are not completed yet..."
    if cat "${LOG_FILE}" | grep -E "migration failed"
    then
      echo "Locking server restart by placing a flag file ${STOP_FLAG} .."
      touch "${STOP_FLAG}"
      echo "Migration failure has been detected. Stopping the grafana-server..."
      set +e
      stop
      set -e
      echo "Making sure the database is reachable...."
      set +e
      until mysql ${MYSQL_PARAMS} grafana -e "select 1;"
      do
        echo \"Database ${DB_HOST} is not reachable. Sleeping for 10 seconds...\"
        sleep 10
      done
      set -e
      echo "Cleaning the database..."
      TABLES=$(
        mysql ${MYSQL_PARAMS} grafana -e "show tables\G;" | grep Tables | cut -d " " -f 2
      )
      for TABLE in ${TABLES}
      do
        echo ${TABLE}
        mysql ${MYSQL_PARAMS} grafana -e "drop table ${TABLE};"
      done
      echo "Restoring the database backup..."
      mysql ${MYSQL_PARAMS} grafana < "${BACKUP_FILE}"
      echo "Removing lock file ${STOP_FLAG} ..."
      rm -f "${STOP_FLAG}"
      echo "${STOP_FLAG} has been removed"
    fi
    sleep 10
  done
  stop
  rm -f "${BACKUP_FILE}"
}

function stop () {
  if [ -f "$PIDFILE" ]; then
    echo -e "Found pidfile, killing running grafana-server"
    kill -9 `cat $PIDFILE`
    rm $PIDFILE
  else
    kill -TERM 1
  fi
}

$COMMAND
