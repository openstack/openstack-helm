#!/bin/sh

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

compareVersions() {
echo $1 $2 | \
awk '{ split($1, a, ".");
       split($2, b, ".");
       res = -1;
       for (i = 1; i <= 3; i++){
           if (a[i] < b[i]) {
               res =-1;
               break;
           } else if (a[i] > b[i]) {
               res = 1;
               break;
           } else if (a[i] == b[i]) {
               if (i == 3) {
               res = 0;
               break;
               } else {
               continue;
               }
           }
       }
       print res;
     }'
}

MYSQL_EXPORTER_VER=`/bin/mysqld_exporter --version 2>&1 | grep "mysqld_exporter" | awk '{print $3}'`

#in versions greater than 0.10.0 different configuration flags are used:
#https://github.com/prometheus/mysqld_exporter/commit/66c41ac7eb90a74518a6ecf6c6bb06464eb68db8
compverResult=`compareVersions "${MYSQL_EXPORTER_VER}" "0.10.0"`
CONFIG_FLAG_PREFIX='-'
if [ ${compverResult} -gt 0 ]; then
    CONFIG_FLAG_PREFIX='--'
fi

exec /bin/mysqld_exporter \
  ${CONFIG_FLAG_PREFIX}config.my-cnf=/etc/mysql/mysql_user.cnf \
  ${CONFIG_FLAG_PREFIX}web.listen-address="${POD_IP}:${LISTEN_PORT}" \
  ${CONFIG_FLAG_PREFIX}web.telemetry-path="$TELEMETRY_PATH"
