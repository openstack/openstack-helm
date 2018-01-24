#!/bin/bash
set -ex
export LC_ALL=C

: "${RBD_POOL_PG:=128}"

: "${ADMIN_KEYRING:=/etc/ceph/${CLUSTER}.client.admin.keyring}"

if [[ ! -e /etc/ceph/${CLUSTER}.conf ]]; then
  echo "ERROR- /etc/ceph/${CLUSTER}.conf must exist; get it from your existing mon"
  exit 1
fi

if [[ ! -e ${ADMIN_KEYRING} ]]; then
   echo "ERROR- ${ADMIN_KEYRING} must exist; get it from your existing mon"
   exit 1
fi

# Make sure rbd pool exists
if ! ceph --cluster "${CLUSTER}" osd pool stats rbd > /dev/null 2>&1; then
   ceph --cluster "${CLUSTER}" osd pool create rbd "${RBD_POOL_PG}"
   rbd pool init rbd
   ceph --cluster "${CLUSTER}" osd crush tunables hammer
fi

echo "SUCCESS"
