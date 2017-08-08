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

# This is taken from https://github.com/openstack/fuel-ccp-rabbitmq/blob/master/service/files/rabbitmq-check-helpers.sh.j2
MARKER_PATH=/tmp/rabbit-startup-marker

# How many seconds we give a node before successfull liveness checks
# become mandatory.
FRESH_NODE_TIMEOUT={{ .Values.probes_delay }}

LP=""

set-log-prefix() {
    LP="[${1:?}]"
}

log-it() {
    echo "$LP" "$@"
}

prepend-log-prefix() {
    awk -v lp="$LP" '{print lp " " $0}'
}

marker-state() {
    if [[ ! -f $MARKER_PATH ]]; then
        echo "missing"
        return 0
    fi
    local marker_time
    marker_time="$(cat $MARKER_PATH)"

    local end_of_fresh_time=$((FRESH_NODE_TIMEOUT + $marker_time))
    local now
    now=$(date +%s)
    if [[ $now -le $end_of_fresh_time ]]; then
        echo "fresh"
        return 0
    fi
    echo "stale"
    return 0
}

ping-node() {
    local result
    result="$(rabbitmqctl eval 'ok.' 2>&1)"
    if [[ "$result" == "ok" ]]; then
        return 0
    fi
    log-it "ping-node error:"
    echo "$result" | prepend-log-prefix
    return 1
}

is-node-booting() {
    local result
    result="$(rabbitmqctl eval 'is_pid(erlang:whereis(rabbit_boot)).' 2>&1)"

    case "$result" in
        true)
            return 0
            ;;
        false)
            return 1
            ;;
        *)
            log-it "is-node-booting error:"
            echo "$result" | prepend-log-prefix
            return 1
            ;;
    esac
}

is-node-healthy() {
    local result
    result=$(rabbitmqctl node_health_check -t 30 2>&1)
    if [[ "$result" =~ "Health check passed" ]]; then
        return 0
    fi
    echo "$result" | prepend-log-prefix
    return 1
}

is-node-properly-clustered() {
    result="$(rabbitmqctl eval 'autocluster:cluster_health_check().' 2>&1)"
    if [[ $result =~ ^SUCCESS: ]]; then
        return 0
    elif [[ $result =~ ^FAILURE: ]]; then
        echo "$result" | prepend-log-prefix
        return 1
    fi
    log-it "Unexpected health-check output, giving the node the benefit of the doubt"
    echo "$result" | prepend-log-prefix
    return 0
}
