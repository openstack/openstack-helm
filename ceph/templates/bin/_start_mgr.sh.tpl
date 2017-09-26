#!/bin/bash
set -ex

source variables_entrypoint.sh
source common_functions.sh

if [[ ! -e /usr/bin/ceph-mgr ]]; then
    log "ERROR- /usr/bin/ceph-mgr doesn't exist"
    sleep infinity
fi

if [[ ! -e /etc/ceph/${CLUSTER}.conf ]]; then
    log "ERROR- /etc/ceph/${CLUSTER}.conf must exist; get it from your existing mon"
    exit 1
fi

if [ ${CEPH_GET_ADMIN_KEY} -eq 1 ]; then
    if [[ ! -e $ADMIN_KEYRING ]]; then
        log "ERROR- $ADMIN_KEYRING must exist; get it from your existing mon"
        exit 1
    fi
fi

# Check to see if our MGR has been initialized
if [ ! -e "$MGR_KEYRING" ]; then
    # Create ceph-mgr key
    timeout 10 ceph ${CLI_OPTS} auth get-or-create mgr."$MGR_NAME" mon 'allow profile mgr' osd 'allow *' mds 'allow *' -o "$MGR_KEYRING"
    chown --verbose ceph. "$MGR_KEYRING"
    chmod 600 "$MGR_KEYRING"
fi

log "SUCCESS"

ceph -v

if [[ "$MGR_DASHBOARD" == 1 ]]; then
    ceph ${CLI_OPTS} mgr module enable dashboard --force
    ceph ${CLI_OPTS} config-key put mgr/dashboard/server_addr "$MGR_IP"
    ceph ${CLI_OPTS} config-key put mgr/dashboard/server_port "$MGR_PORT"
fi

log "SUCCESS"
# start ceph-mgr
exec /usr/bin/ceph-mgr $DAEMON_OPTS -i "$MGR_NAME"
