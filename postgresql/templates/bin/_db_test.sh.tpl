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

trap cleanup EXIT SIGTERM SIGINT SIGKILL

TEST_DATABASE_NAME="pg_helmtest_db"
TEST_DATABASE_USER="pg_helmtest_user"
TEST_DATABASE_PASSWORD=$RANDOM
TEST_TABLE_NAME="pg_helmtest"

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

function cleanup {
  echo 'Cleaning up the database...'
  psql_cmd "postgres" ${DB_ADMIN_USER} ${ADMIN_PASSWORD} "DROP DATABASE IF EXISTS ${TEST_DATABASE_NAME};" 0
  psql_cmd "postgres" ${DB_ADMIN_USER} ${ADMIN_PASSWORD} "DROP ROLE IF EXISTS ${TEST_DATABASE_USER};" 0
  echo 'Cleanup Finished.'
}

# Create db
echo 'Testing database connectivity as admin user...'
psql_cmd "postgres" ${DB_ADMIN_USER} ${ADMIN_PASSWORD} "SELECT 1 FROM pg_database;"
echo 'Connectivity Test SUCCESS!'

echo 'Testing creation of an application database...'
psql_cmd "postgres" ${DB_ADMIN_USER} ${ADMIN_PASSWORD} "CREATE DATABASE ${TEST_DATABASE_NAME};"
echo 'Database Creation Test SUCCESS!'

echo 'Testing creation of an application user...'
psql_cmd "postgres" ${DB_ADMIN_USER} ${ADMIN_PASSWORD} "CREATE ROLE ${TEST_DATABASE_USER} LOGIN PASSWORD '${TEST_DATABASE_PASSWORD}';"
psql_cmd "postgres" ${DB_ADMIN_USER} ${ADMIN_PASSWORD} "GRANT ALL PRIVILEGES ON DATABASE ${TEST_DATABASE_NAME} to ${TEST_DATABASE_USER};"
echo 'User Creation SUCCESS!'

echo 'Testing creation of an application table...'
psql_cmd ${TEST_DATABASE_NAME} ${TEST_DATABASE_USER} ${TEST_DATABASE_PASSWORD} "CREATE TABLE ${TEST_TABLE_NAME} (name text);"
echo 'Table Creation SUCCESS!'

echo 'Testing DML...'
psql_cmd ${TEST_DATABASE_NAME} ${TEST_DATABASE_USER} ${TEST_DATABASE_PASSWORD} "INSERT INTO ${TEST_TABLE_NAME} (name) VALUES ('test.');"
psql_cmd ${TEST_DATABASE_NAME} ${TEST_DATABASE_USER} ${TEST_DATABASE_PASSWORD} "SELECT * FROM ${TEST_TABLE_NAME};"
psql_cmd ${TEST_DATABASE_NAME} ${TEST_DATABASE_USER} ${TEST_DATABASE_PASSWORD} "DELETE FROM ${TEST_TABLE_NAME};"
echo 'DML Test SUCCESS!'

exit 0
