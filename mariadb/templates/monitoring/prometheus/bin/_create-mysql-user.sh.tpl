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

if ! mysql --defaults-file=/etc/mysql/admin_user.cnf -e \
  "CREATE OR REPLACE USER '${EXPORTER_USER}'@'%' IDENTIFIED BY '${EXPORTER_PASSWORD}'; \
   GRANT PROCESS, REPLICATION CLIENT, SELECT ON *.* TO '${EXPORTER_USER}'@'%' ${MARIADB_X509}; \
   FLUSH PRIVILEGES;" ; then
  echo "ERROR: Could not create user: ${EXPORTER_USER}"
  exit 1
fi
