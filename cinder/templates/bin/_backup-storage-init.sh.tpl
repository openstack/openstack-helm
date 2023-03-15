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
if [[ $STORAGE_BACKEND =~ 'cinder.backup.drivers.ceph' ]]; then
  SECRET=$(mktemp --suffix .yaml)
  KEYRING=$(mktemp --suffix .keyring)
  function cleanup {
      rm -f ${SECRET} ${KEYRING}
  }
  trap cleanup EXIT
fi

set -ex
if [[ $STORAGE_BACKEND =~ 'cinder.backup.drivers.swift' ]] || \
     [[ $STORAGE_BACKEND =~ 'cinder.backup.drivers.posix' ]]; then
  echo "INFO: no action required to use $STORAGE_BACKEND"
elif [[ $STORAGE_BACKEND =~ 'cinder.backup.drivers.ceph' ]]; then
  ceph -s
  function ensure_pool () {
    ceph osd pool stats $1 || ceph osd pool create $1 $2
    if [[ $(ceph mgr versions | awk '/version/{print $3}' | cut -d. -f1) -ge 12 ]]; then
        ceph osd pool application enable $1 $3
    fi
    size_protection=$(ceph osd pool get $1 nosizechange | cut -f2 -d: | tr -d '[:space:]')
    ceph osd pool set $1 nosizechange 0
    ceph osd pool set $1 size ${RBD_POOL_REPLICATION} --yes-i-really-mean-it
    ceph osd pool set $1 nosizechange ${size_protection}
    ceph osd pool set $1 crush_rule "${RBD_POOL_CRUSH_RULE}"
  }
  ensure_pool ${RBD_POOL_NAME} ${RBD_POOL_CHUNK_SIZE} ${RBD_POOL_APP_NAME}

  if USERINFO=$(ceph auth get client.${RBD_POOL_USER}); then
    echo "Cephx user client.${RBD_POOL_USER} already exists"
    echo "Update its cephx caps"
    ceph auth caps client.${RBD_POOL_USER} \
      mon "profile rbd" \
      osd "profile rbd pool=${RBD_POOL_NAME}"
    ceph auth get client.${RBD_POOL_USER} -o ${KEYRING}
  else
    ceph auth get-or-create client.${RBD_POOL_USER} \
      mon "profile rbd" \
      osd "profile rbd pool=${RBD_POOL_NAME}" \
      -o ${KEYRING}
  fi

  ENCODED_KEYRING=$(sed -n 's/^[[:blank:]]*key[[:blank:]]\+=[[:blank:]]\(.*\)/\1/p' ${KEYRING} | base64 -w0)
  cat > ${SECRET} <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: "${RBD_POOL_SECRET}"
type: kubernetes.io/rbd
data:
  key: $( echo ${ENCODED_KEYRING} )
EOF
  kubectl apply --namespace ${NAMESPACE} -f ${SECRET}

fi
