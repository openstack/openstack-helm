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

# Env. variables matching the pattern "<module>_" will be
# found and parsed for config-key settings by
#  ceph config-key set mgr/<module>/<key> <value>
MODULES_TO_DISABLE=`ceph mgr dump | python -c "import json, sys; print ' '.join(json.load(sys.stdin)['modules'])"`

for module in ${ENABLED_MODULES}; do
    # This module may have been enabled in the past
    # remove it from the disable list if present
    MODULES_TO_DISABLE=${MODULES_TO_DISABLE/$module/}

    options=`env | grep ^${module}_ || true`
    for option in ${options}; do
        #strip module name
        option=${option/${module}_/}
        key=`echo $option | cut -d= -f1`
        value=`echo $option | cut -d= -f2`
        ceph ${CLI_OPTS} config-key set mgr/$module/$key $value
    done
    ceph ${CLI_OPTS} mgr module enable ${module} --force
done

for module in $MODULES_TO_DISABLE; do
  ceph ${CLI_OPTS} mgr module disable ${module}
done

log "SUCCESS"
# start ceph-mgr
exec /usr/bin/ceph-mgr $DAEMON_OPTS -i "$MGR_NAME"
