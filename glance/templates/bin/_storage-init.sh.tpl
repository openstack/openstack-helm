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
      rm -f "${SECRET}" "${KEYRING}"
  }
  trap cleanup EXIT
fi

SCHEME={{ tuple "object_store" "internal" "api" . | include "helm-toolkit.endpoints.keystone_endpoint_scheme_lookup" }}
if [[ "$SCHEME" == "https" && -f /etc/ssl/certs/openstack-helm.crt ]]; then
  export CURL_CA_BUNDLE="/etc/ssl/certs/openstack-helm.crt"
fi

set -ex
if [ "x$STORAGE_BACKEND" == "xpvc" ]; then
  echo "No action required."
elif [ "x$STORAGE_BACKEND" == "xswift" ]; then
  : ${OS_INTERFACE:="internal"}
  OS_TOKEN="$(openstack token issue -f value -c id)"
  OS_PROJECT_ID="$(openstack project show service -f value -c id)"
  OS_SWIFT_ENDPOINT_PREFIX="$(openstack endpoint list --service swift --interface ${OS_INTERFACE} -f value -c URL | awk -F '$' '{ print $1 }')"
  OS_SWIFT_SCOPED_ENDPOINT="${OS_SWIFT_ENDPOINT_PREFIX}${OS_PROJECT_ID}"
  curl --fail -i -X POST "${OS_SWIFT_SCOPED_ENDPOINT}" \
    -H "X-Auth-Token: ${OS_TOKEN}" \
    -H "X-Account-Meta-Temp-URL-Key: ${SWIFT_TMPURL_KEY}"
elif [ "x$STORAGE_BACKEND" == "xrbd" ]; then
  ceph -s
  function ensure_pool () {
    ceph osd pool stats "$1" || ceph osd pool create "$1" "$2"
    local test_version
    test_version=$(ceph tell osd.* version | egrep -c "nautilus|mimic|luminous" | xargs echo)
    if [[ ${test_version} -gt 0 ]]; then
      ceph osd pool application enable "$1" "$3"
    fi
    ceph osd pool set "$1" size "${RBD_POOL_REPLICATION}"
    ceph osd pool set "$1" crush_rule "${RBD_POOL_CRUSH_RULE}"
  }
  ensure_pool "${RBD_POOL_NAME}" "${RBD_POOL_CHUNK_SIZE}" "${RBD_POOL_APP_NAME}"

  if USERINFO=$(ceph auth get "client.${RBD_POOL_USER}"); then
    echo "Cephx user client.${RBD_POOL_USER} already exist."
    echo "Update its cephx caps"
    ceph auth caps client.${RBD_POOL_USER} \
      mon "profile rbd" \
      osd "profile rbd pool=${RBD_POOL_NAME}"
    ceph auth get client.${RBD_POOL_USER} -o ${KEYRING}
  else
    #NOTE(JCL): Restrict Glance user to only what is needed. MON Read only and RBD access to the Glance Pool
    ceph auth get-or-create "client.${RBD_POOL_USER}" \
      mon "profile rbd" \
      osd "profile rbd pool=${RBD_POOL_NAME}" \
      -o "${KEYRING}"
  fi

  ENCODED_KEYRING=$(sed -n 's/^[[:blank:]]*key[[:blank:]]\+=[[:blank:]]\(.*\)/\1/p' "${KEYRING}" | base64 -w0)
  cat > "${SECRET}" <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: "${RBD_POOL_SECRET}"
type: kubernetes.io/rbd
data:
  key: "${ENCODED_KEYRING}"
EOF
  kubectl apply --namespace "${NAMESPACE}" -f "${SECRET}"
elif [ "x${STORAGE_BACKEND}" == "xradosgw" ]; then
  radosgw-admin user stats --uid="${RADOSGW_USERNAME}" || \
    radosgw-admin user create \
      --uid="${RADOSGW_USERNAME}" \
      --display-name="${RADOSGW_USERNAME} user"

  radosgw-admin subuser create \
    --uid="${RADOSGW_USERNAME}" \
    --subuser="${RADOSGW_USERNAME}:swift" \
    --access=full

  radosgw-admin key create \
    --subuser="${RADOSGW_USERNAME}:swift" \
    --key-type=swift \
    --secret="${RADOSGW_PASSWORD}"

  radosgw-admin user modify \
    --uid="${RADOSGW_USERNAME}" \
    --temp-url-key="${RADOSGW_TMPURL_KEY}"
fi
