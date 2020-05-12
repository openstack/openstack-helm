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
if [ "x$STORAGE_BACKEND" == "xceph-rgw" ]; then
  SECRET=$(mktemp --suffix .yaml)
  KEYRING=$(mktemp --suffix .keyring)
  function cleanup {
      rm -f ${SECRET} ${KEYRING}
  }
  trap cleanup EXIT
fi

function kube_ceph_keyring_gen () {
  CEPH_KEY=$1
  CEPH_KEY_TEMPLATE=$2
  sed "s|{{"{{"}} key {{"}}"}}|${CEPH_KEY}|" /tmp/ceph-templates/${CEPH_KEY_TEMPLATE} | base64 -w0 | tr -d '\n'
}

set -ex
if [ "x$STORAGE_BACKEND" == "xceph-rgw" ]; then
  ceph -s
  if USERINFO=$(ceph auth get client.bootstrap-rgw); then
    KEYSTR=$(echo $USERINFO | sed 's/.*\( key = .*\) caps mon.*/\1/')
    echo $KEYSTR  > ${KEYRING}
  else
    #NOTE(Portdirect): Determine proper privs to assign keyring
    ceph auth get-or-create client.bootstrap-rgw \
      mon "allow profile bootstrap-rgw" \
      -o ${KEYRING}
  fi
  FINAL_KEYRING=$(sed -n 's/^[[:blank:]]*key[[:blank:]]\+=[[:blank:]]\(.*\)/\1/p' ${KEYRING})
  cat > ${SECRET} <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: "os-ceph-bootstrap-rgw-keyring"
type: Opaque
data:
 ceph.keyring: $( kube_ceph_keyring_gen ${FINAL_KEYRING} "bootstrap.keyring.rgw"  )
EOF
  kubectl apply --namespace ${NAMESPACE} -f ${SECRET}

fi
