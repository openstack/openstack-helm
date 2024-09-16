#!/bin/sh

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

export ETCDCTL_API=3

{{- if .Values.jobs.db_compact.command_timeout }}
COMMAND_TIMEOUT='--command-timeout={{ .Values.jobs.db_compact.command_timeout }}'
{{- else }}
COMMAND_TIMEOUT=''
{{- end }}

ENDPOINTS=$(etcdctl member list --endpoints=http://${ETCD_SERVICE_HOST}:${ETCD_SERVICE_PORT} ${COMMAND_TIMEOUT}| cut -d, -f5 | sed -e 's/ //g' | paste -sd ',')

etcdctl --endpoints=${ENDPOINTS} endpoint status --write-out="table" ${COMMAND_TIMEOUT}

rev=$(etcdctl --endpoints=http://${ETCD_SERVICE_HOST}:${ETCD_SERVICE_PORT} endpoint status --write-out="json" ${COMMAND_TIMEOUT}| egrep -o '"revision":[0-9]*' | egrep -o '[0-9].*')
compact_result=$(etcdctl compact --physical=true --endpoints=${ENDPOINTS} $rev ${COMMAND_TIMEOUT} 2>&1 > /dev/null)
compact_res=$?

if [[ $compact_res -ne 0 ]]; then
    match_pattern=$(echo ${compact_result} | egrep '(mvcc: required revision has been compacted.*$)')
    match_pattern_res=$?
    if [[ $match_pattern_res -eq 0 ]]; then
        exit 0
    else
        echo "Failed to compact database: $compact_result"
        exit $compact_res
    fi
else
    etcdctl defrag --endpoints=${ENDPOINTS} ${COMMAND_TIMEOUT}
    etcdctl --endpoints=${ENDPOINTS} endpoint status --write-out="table" ${COMMAND_TIMEOUT}
fi
