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

set -x

ALERTA_DB_NAME={{ .Values.conf.alerta.alertadb }}

function create_db() {
  export PGPASSWORD=${ADMIN_PASSWORD}
  if `psql -h ${DB_FQDN} -p ${DB_PORT} -U ${DB_ADMIN_USER} -lqt | cut -d \| -f 1 | grep -qw ${ALERTA_DB_NAME}`; then
    echo "Database ${ALERTA_DB_NAME} is already exist."
  else
    echo "Database ${ALERTA_DB_NAME} not exist, create it."
    psql_cmd "postgres" ${DB_ADMIN_USER} ${ADMIN_PASSWORD} "CREATE DATABASE ${ALERTA_DB_NAME};"
    echo "Database ${ALERTA_DB_NAME} is created."
  fi
}


function psql_cmd {
  DATABASE=$1
  DB_USER=$2
  export PGPASSWORD=$3
  DB_COMMAND=$4
  EXIT_ON_FAIL=${5:-1}

  psql \
  -h $DB_FQDN \
  -p $DB_PORT \
  -U $DB_USER \
  -d $DATABASE \
  -v "ON_ERROR_STOP=1" \
  --command="${DB_COMMAND}"

  RC=$?

  if [[ $RC -ne 0 ]]
  then
    echo 'FAIL!'
    if [[ $EXIT_ON_FAIL -eq 1 ]]
    then
      exit $RC
    fi
  fi

  return 0
}


# Create db
sleep 10
create_db
exit 0