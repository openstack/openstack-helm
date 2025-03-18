#!/bin/bash -ex

#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.

log () {
  msg_default="Need some text to log"
  level_default="INFO"
  component_default="Mariadb Backup Verifier"

  msg=${1:-$msg_default}
  level=${2:-$level_default}
  component=${3:-"$component_default"}

  echo "$(date +'%Y-%m-%d %H:%M:%S,%3N') - ${component} - ${level} - ${msg}"
}

log "Starting Mariadb server for backup verification..."
mysql_install_db --user=nobody --ldata=/var/lib/mysql >/dev/null 2>&1
MYSQL_ALLOW_EMPTY_PASSWORD=1 mysqld --user=nobody --verbose >/dev/null 2>&1
