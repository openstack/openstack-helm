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

MONGO_URL=$(echo $ROOT_DB_CONNECTION | awk -F '@' '{ print $NF }' | awk -F '/' '{ print $1 }')
MONGO_HOST=$(echo $MONGO_URL | awk -F ':' '{ print $1 }')
MONGO_PORT=$(echo $MONGO_URL | awk -F ':' '{ print $2 }')

MONGO_ADMIN_CREDS=$(echo $ROOT_DB_CONNECTION | awk -F '@' '{ print $1 }')
MONGO_ADMIN_USER=$(echo ${MONGO_ADMIN_CREDS#mongodb://} | awk -F ':' '{ print $1 }')
MONGO_ADMIN_PASS=$(echo ${MONGO_ADMIN_CREDS#mongodb://} | awk -F ':' '{ print $NF }')

MONGO_USER_CREDS=$(echo $USER_DB_CONNECTION | awk -F '@' '{ print $1 }')
MONGO_USER_USER=$(echo ${MONGO_USER_CREDS#mongodb://} | awk -F ':' '{ print $1 }')
MONGO_USER_PASS=$(echo ${MONGO_USER_CREDS#mongodb://} | awk -F ':' '{ print $NF }')
MONGO_USER_DB=$(echo $USER_DB_CONNECTION | awk -F '/' '{ print $NF }')

mongo admin \
  --host "${MONGO_HOST}" \
  --port "${MONGO_PORT}" \
  --username "${MONGO_ADMIN_USER}" \
  --password "${MONGO_ADMIN_PASS}" \
  --eval "db = db.getSiblingDB(\"${MONGO_USER_DB}\"); \
          db.changeUserPassword(\"${MONGO_USER_USER}\", \"${MONGO_USER_PASS}\")" || \
    mongo admin \
      --host "${MONGO_HOST}" \
      --port "${MONGO_PORT}" \
      --username "${MONGO_ADMIN_USER}" \
      --password "${MONGO_ADMIN_PASS}" \
      --eval "db = db.getSiblingDB(\"${MONGO_USER_DB}\");
              db.createUser({user: \"${MONGO_USER_USER}\",
              pwd: \"${MONGO_USER_PASS}\",
              roles: [ \"readWrite\", \"dbAdmin\" ]})"
