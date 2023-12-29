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
if [ "x$STORAGE_BACKEND" == "xrbd" ]; then
  SECRET=$(mktemp --suffix .yaml)
  KEYRING=$(mktemp --suffix .keyring)
  function cleanup {
      rm -f ${SECRET} ${KEYRING}
  }
  trap cleanup EXIT
fi

set -ex
if [ "x$STORAGE_BACKEND" == "xrbd" ]; then
  ceph -s
  function ensure_pool () {
    ceph osd pool stats $1 || ceph osd pool create $1 $2
    if [[ $(ceph mgr versions | awk '/version/{print $3}' | cut -d. -f1) -ge 12 ]]; then
        ceph osd pool application enable $1 $3
    fi
    size_protection=$(ceph osd pool get $1 nosizechange | cut -f2 -d: | tr -d '[:space:]')
    ceph osd pool set $1 nosizechange 0
    ceph osd pool set $1 size ${RBD_POOL_REPLICATION}
    ceph osd pool set $1 nosizechange ${size_protection}
    ceph osd pool set $1 crush_rule "${RBD_POOL_CRUSH_RULE}"
  }
  ensure_pool ${RBD_POOL_NAME} ${RBD_POOL_CHUNK_SIZE} ${RBD_POOL_APP_NAME}
fi