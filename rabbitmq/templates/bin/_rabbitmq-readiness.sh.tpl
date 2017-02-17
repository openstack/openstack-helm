#!/usr/bin/env bash
# This is taken from https://github.com/openstack/fuel-ccp-rabbitmq/blob/master/service/files/rabbitmq-readiness.sh.j2
set -eu
set -o pipefail
exec 1>/proc/1/fd/2 2>/proc/1/fd/2

source $(readlink -f $(dirname $0))/rabbitmq-check-helpers.sh
set-log-prefix "readiness:$$"
log-it "Starting readiness probe at $(date +'%Y-%m-%d %H:%M:%S')"

main() {
    if [[ "$(marker-state)" == missing ]]; then
        log-it "Startup marker missing, probably probe was executed too early"
        return 1
    fi
    if ! is-node-healthy; then
        log-it "Node is unhealthy"
        return 1
    fi
    if ! is-node-properly-clustered; then
        log-it "Node is inconsistent with the rest of the cluster"
        return 1
    fi
    return 0
}

if main; then
    rc=0
else
    rc=$?
fi
log-it "Ready to return $rc"
exit $rc
