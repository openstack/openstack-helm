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

mongod --auth &

t=0
until mongo --eval "db.adminCommand('ping')"; do
  echo "waiting for mongodb to start"
  sleep 1
  t=$(($t+1))
  if [ $t -ge 30 ] ; then
      echo "mongodb did not start, giving up"
      exit 1
  fi
done

#NOTE(portdirect): stop sending commands to stdout to prevent root password
# being sent to logs.
set +x
mongo admin \
  --username "${ADMIN_USER}" \
  --password "${ADMIN_PASS}" \
  --eval "db.changeUserPassword(\"${ADMIN_USER}\", \"${ADMIN_PASS}\")" || \
    mongo admin \
      --eval "db.createUser({ user: \"${ADMIN_USER}\", \
                              pwd: \"${ADMIN_PASS}\", \
                              roles: [ { role: \"userAdminAnyDatabase\", \
                                         db: \"admin\" } ] });"
set -x
wait
