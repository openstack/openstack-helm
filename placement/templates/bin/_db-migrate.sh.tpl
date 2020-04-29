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

# To make this migration idempotent and not break the chart deployment,
# we will treat a new deployment ($?==4) and migration completed ($?==3)
# as success so things can proceed.
function handler {
  rv=$?
  if [ $rv -eq 4 ] || [ $rv -eq 3 ]; then
    exit 0
  else
    exit $rv
  fi
}

trap handler EXIT

/tmp/mysql-migrate-db.sh --mkconfig /tmp/migrate-db.rc

sed -i \
  -e "s/NOVA_API_USER=.*/NOVA_API_USER=\"${NOVA_API_USER}\"/g" \
  -e "s/NOVA_API_PASS=.*/NOVA_API_PASS=\"${NOVA_API_PASS}\"/g" \
  -e "s/NOVA_API_DB_HOST=.*/NOVA_API_DB_HOST=\"${NOVA_API_DB_HOST}\"/g" \
  -e "s/PLACEMENT_USER=.*/PLACEMENT_USER=\"${PLACEMENT_USER}\"/g" \
  -e "s/PLACEMENT_PASS=.*/PLACEMENT_PASS=\"${PLACEMENT_PASS}\"/g" \
  -e "s/PLACEMENT_DB_HOST=.*/PLACEMENT_DB_HOST=\"${PLACEMENT_DB_HOST}\"/g" \
  /tmp/migrate-db.rc

/tmp/mysql-migrate-db.sh --migrate /tmp/migrate-db.rc
