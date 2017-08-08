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

    {{ if gt (.Values.pod.replicas.server | int) 1 -}}
    if ! is-node-properly-clustered; then
        log-it "Node is inconsistent with the rest of the cluster"
        return 1
    fi
    {{- end }}
    return 0
}

if main; then
    rc=0
else
    rc=$?
fi
log-it "Ready to return $rc"
exit $rc
