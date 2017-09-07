#!/bin/bash

{{/*
Copyright 2017 The Openstack-Helm Authors.

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
if [ "x$STORAGE_BACKEND" == "xpvc" ] || [ "x$STORAGE_BACKEND" == "xswift" ]; then
  echo "No action required."
elif [ "x$STORAGE_BACKEND" == "xrbd" ]; then
  ceph -s
  function ensure_pool () {
    ceph osd pool stats $1 || ceph osd pool create $1 $2
  }
  ensure_pool ${RBD_POOL_NAME} ${RBD_POOL_CHUNK_SIZE}

  #NOTE(Portdirect): Determine proper privs to assign keyring
  ceph auth get-or-create client.${RBD_POOL_USER} \
    mon "allow *" \
    osd "allow *" \
    -o ${KEYRING}

  ENCODED_KEYRING=$(sed -n 's/^[[:blank:]]*key[[:blank:]]\+=[[:blank:]]\(.*\)/\1/p' ${KEYRING} | base64 -w0)
  cat > ${SECRET} <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: "${RBD_POOL_SECRET}"
type: kubernetes.io/rbd
data:
  key: |
    $( echo ${ENCODED_KEYRING} )
EOF
  kubectl create --namespace ${NAMESPACE} -f ${SECRET}
elif [ "x$STORAGE_BACKEND" == "xradosgw" ]; then
  radosgw-admin user stats --uid="${RADOSGW_USERNAME}" || \
    radosgw-admin user create \
      --uid="${RADOSGW_USERNAME}" \
      --display-name="${RADOSGW_USERNAME} user"

  radosgw-admin subuser create \
    --uid=${RADOSGW_USERNAME} \
    --subuser=${RADOSGW_USERNAME}:swift \
    --access=full

  radosgw-admin key create \
    --subuser=${RADOSGW_USERNAME}:swift \
    --key-type=swift \
    --secret=${RADOSGW_PASSWORD}

  radosgw-admin user modify \
    --uid=${RADOSGW_USERNAME} \
    --temp-url-key=${RADOSGW_TMPURL_KEY}
fi
