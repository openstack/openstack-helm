# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

{{- define "helm-toolkit.scripts.pg_db_init" }}
#!/bin/bash
set -ex

if [[ ! -v DB_HOST ]]; then
    echo "environment variable DB_HOST not set"
    exit 1
elif [[ ! -v DB_ADMIN_USER ]]; then
    echo "environment variable DB_ADMIN_USER not set"
    exit 1
elif [[ ! -v PGPASSWORD ]]; then
    echo "environment variable PGPASSWORD not set"
    exit 1
elif [[ ! -v DB_PORT ]]; then
    echo "environment variable DB_PORT not set"
    exit 1
elif [[ ! -v USER_DB_USER ]]; then
    echo "environment variable USER_DB_USER not set"
    exit 1
elif [[ ! -v USER_DB_PASS ]]; then
    echo "environment variable USER_DB_PASS not set"
    exit 1
elif [[ ! -v USER_DB_NAME ]]; then
    echo "environment variable USER_DB_NAME not set"
    exit 1
else
    echo "Got DB connection info"
fi

pgsql_superuser_cmd () {
  DB_COMMAND="$1"
  if [[ ! -z $2 ]]; then
      EXPORT PGDATABASE=$2
  fi
  /usr/bin/psql \
  -h ${DB_HOST} \
  -p ${DB_PORT} \
  -U ${DB_ADMIN_USER} \
  --command="${DB_COMMAND}"
}

#create db
pgsql_superuser_cmd "SELECT 1 FROM pg_database WHERE datname = '$USER_DB_NAME'" | grep -q "(1 row)" || pgsql_superuser_cmd "CREATE DATABASE $USER_DB_NAME"

#create db user
pgsql_superuser_cmd "SELECT * FROM pg_roles WHERE rolname = '$USER_DB_USER';" | grep -q "(1 row)" || \
    pgsql_superuser_cmd "CREATE ROLE ${USER_DB_USER} LOGIN PASSWORD '$USER_DB_PASS';"

#Set password everytime. This is required for cases when we would want password rotation to take effect and set the updated password for a user.
pgsql_superuser_cmd "SELECT * FROM pg_roles WHERE rolname = '$USER_DB_USER';" && pgsql_superuser_cmd "ALTER USER ${USER_DB_USER} with password '$USER_DB_PASS'"

#give permissions to user
pgsql_superuser_cmd "GRANT ALL PRIVILEGES ON DATABASE $USER_DB_NAME to $USER_DB_USER;"

#revoke all privileges from PUBLIC role
pgsql_superuser_cmd "REVOKE ALL ON DATABASE $USER_DB_NAME FROM PUBLIC;"
{{- end }}
