#!/bin/bash
set -ex
export LC_ALL=C

source variables_entrypoint.sh
source common_functions.sh

if [[ ! -e /etc/ceph/${CLUSTER}.conf ]]; then
  log "ERROR- /etc/ceph/${CLUSTER}.conf must exist; get it from your existing mon"
  exit 1
fi

if [[ ! -e $ADMIN_KEYRING ]]; then
   log "ERROR- $ADMIN_KEYRING must exist; get it from your existing mon"
   exit 1
fi

# Make sure rbd pool exists
if ! ceph ${CLI_OPTS} osd pool stats rbd > /dev/null 2>&1; then
   ceph ${CLI_OPTS} osd pool create rbd "${RBD_POOL_PG}"
   rbd pool init rbd
   ceph osd crush tunables hammer
fi

log "SUCCESS"
