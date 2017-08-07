#!/usr/bin/env bash

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

# This is taken from https://github.com/openstack/fuel-ccp-rabbitmq/blob/master/service/files/rabbitmq-liveness.sh.j2
set -eu
set -o pipefail
exec 1>/proc/1/fd/2 2>/proc/1/fd/2

source $(readlink -f $(dirname $0))/rabbitmq-check-helpers.sh
set-log-prefix "liveness:$$"
log-it "Starting liveness probe at $(date +'%Y-%m-%d %H:%M:%S')"

main() {
    local marker_state
    marker_state="$(marker-state)"
    case $marker_state in
        missing)
            log-it "Startup marker missing, probably probe was executed too early"
            return 0
            ;;
        fresh) # node has recently started - it can still be booting
            if ! ping-node; then
                log-it "Fresh node, erlang VM hasn't started yet - giving it another chance"
                # Erlang VM hasn't started yet
                return 0
            fi
            if is-node-booting; then
                log-it "Node is still booting, giving it some time to finish"
                return 0
            fi
            if ! is-node-healthy; then
                log-it "Node is unhealthy"
                return 1
            fi
            if ! is-node-properly-clustered; then
                log-it "Found clustering inconsistency, giving up"
                return 1
            fi
            return 0
            ;;
        stale) # node has started long ago - it shoud be either ready or dead
            if ! is-node-healthy; then
                log-it "Long-running node become unhealthy"
                return 1
            fi
            if ! is-node-properly-clustered; then
                echo "Long-running node became inconsistent with the rest of the cluster"
                return 1
            fi
            return 0
            ;;
        *)
            log-it "Unexpected marker-state '$marker-state'"
            return 1
            ;;
    esac
}

if main; then
    rc=0
else
    rc=$?
fi
log-it "Ready to return $rc"
exit $rc
