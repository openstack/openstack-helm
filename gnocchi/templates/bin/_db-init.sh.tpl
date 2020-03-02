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
export HOME=/tmp

pgsql_superuser_cmd () {
  DB_COMMAND="$1"
  if [[ ! -z $2 ]]; then
      EXPORT PGDATABASE=$2
  fi
  if [[ ! -z "${ROOT_DB_PASS}" ]]; then
      export PGPASSWORD="${ROOT_DB_PASS}"
  fi
  psql \
  -h ${DB_FQDN} \
  -p ${DB_PORT} \
  -U ${ROOT_DB_USER} \
  --command="${DB_COMMAND}"
  unset PGPASSWORD
}

if [[ ! -v ROOT_DB_CONNECTION ]]; then
    echo "environment variable ROOT_DB_CONNECTION not set"
    exit 1
else
    echo "Got DB root connection"
fi

if [[ -v OPENSTACK_CONFIG_FILE ]]; then
    if [[ ! -v OPENSTACK_CONFIG_DB_SECTION ]]; then
        echo "Environment variable OPENSTACK_CONFIG_DB_SECTION not set"
        exit 1
    elif [[ ! -v OPENSTACK_CONFIG_DB_KEY ]]; then
        echo "Environment variable OPENSTACK_CONFIG_DB_KEY not set"
        exit 1
    fi

    echo "Using ${OPENSTACK_CONFIG_FILE} as db config source"
    echo "Trying to load db config from ${OPENSTACK_CONFIG_DB_SECTION}:${OPENSTACK_CONFIG_DB_KEY}"

    DB_CONN=$(awk -v key=$OPENSTACK_CONFIG_DB_KEY "/^\[${OPENSTACK_CONFIG_DB_SECTION}\]/{f=1} f==1&&/^$OPENSTACK_CONFIG_DB_KEY/{print \$3;exit}" "${OPENSTACK_CONFIG_FILE}")

    echo "Found DB connection: $DB_CONN"
elif [[ -v DB_CONNECTION ]]; then
    DB_CONN=${DB_CONNECTION}
    echo "Got config from DB_CONNECTION env var"
else
    echo "Could not get dbconfig"
    exit 1
fi

ROOT_DB_PROTO="$(echo $ROOT_DB_CONNECTION | grep '//' | sed -e's,^\(.*://\).*,\1,g')"
ROOT_DB_URL="$(echo $ROOT_DB_CONNECTION | sed -e s,$ROOT_DB_PROTO,,g)"
ROOT_DB_USER="$(echo $ROOT_DB_URL | grep @ | cut -d@ -f1 | cut -d: -f1)"
ROOT_DB_PASS="$(echo $ROOT_DB_URL | grep @ | cut -d@ -f1 | cut -d: -f2)"

DB_FQDN="$(echo $ROOT_DB_URL | sed -e s,$ROOT_DB_USER:$ROOT_DB_PASS@,,g | cut -d/ -f1 | cut -d: -f1)"
DB_PORT="$(echo $ROOT_DB_URL | sed -e s,$ROOT_DB_USER:$ROOT_DB_PASS@,,g | cut -d/ -f1 | cut -d: -f2)"
DB_NAME="$(echo $ROOT_DB_URL | sed -e s,$ROOT_DB_USER:$ROOT_DB_PASS@,,g | cut -d/ -f2 | cut -d? -f1)"

DB_PROTO="$(echo $DB_CONN | grep '//' | sed -e's,^\(.*://\).*,\1,g')"
DB_URL="$(echo $DB_CONN | sed -e s,$DB_PROTO,,g)"
DB_USER="$( echo $DB_URL | grep @ | cut -d@ -f1 | cut -d: -f1)"
DB_PASS="$( echo $DB_URL | grep @ | cut -d@ -f1 | cut -d: -f2)"

#create db
pgsql_superuser_cmd "SELECT 1 FROM pg_database WHERE datname = '$DB_NAME'" | grep -q 1 || pgsql_superuser_cmd "CREATE DATABASE $DB_NAME"

#create db user
pgsql_superuser_cmd "SELECT * FROM pg_roles WHERE rolname = '$DB_USER';" | tail -n +3 | head -n -2 | grep -q 1 || \
    pgsql_superuser_cmd "CREATE ROLE ${DB_USER} LOGIN PASSWORD '$DB_PASS';" && pgsql_superuser_cmd "ALTER USER ${DB_USER} WITH SUPERUSER"

#give permissions to user
pgsql_superuser_cmd "GRANT ALL PRIVILEGES ON DATABASE $DB_NAME to $DB_USER;"

