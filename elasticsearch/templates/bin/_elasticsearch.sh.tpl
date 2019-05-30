#!/bin/bash
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

set -ex
COMMAND="${@:-start}"

function start () {
  ulimit -l unlimited
  exec /docker-entrypoint.sh elasticsearch
}

function stop () {
  kill -TERM 1
}

function allocate_data_node () {
  CLUSTER_SETTINGS=$(curl -K- <<< "--user ${ELASTICSEARCH_USERNAME}:${ELASTICSEARCH_PASSWORD}" \
    "${ELASTICSEARCH_ENDPOINT}/_cluster/settings")
  if echo "${CLUSTER_SETTINGS}" | grep -E "${NODE_NAME}"; then
    echo "Activate node ${NODE_NAME}"
    curl -K- <<< "--user ${ELASTICSEARCH_USERNAME}:${ELASTICSEARCH_PASSWORD}" -XPUT -H 'Content-Type: application/json' \
     "${ELASTICSEARCH_ENDPOINT}/_cluster/settings" -d "{
      \"transient\" :{
          \"cluster.routing.allocation.exclude._name\" : null
      }
    }"
  fi
  echo "Node ${NODE_NAME} is ready to be used"
}

function start_data_node () {
  ulimit -l unlimited
  allocate_data_node &
  /docker-entrypoint.sh elasticsearch &
  function drain_data_node () {
    echo "Prepare to migrate data off node ${NODE_NAME}"
    echo "Move all data from node ${NODE_NAME}"
    curl -K- <<< "--user ${ELASTICSEARCH_USERNAME}:${ELASTICSEARCH_PASSWORD}" -XPUT -H 'Content-Type: application/json' \
     "${ELASTICSEARCH_ENDPOINT}/_cluster/settings" -d "{
      \"transient\" :{
          \"cluster.routing.allocation.exclude._name\" : \"${NODE_NAME}\"
      }
    }"
    echo ""
    while true ; do
      echo -e "Wait for node ${NODE_NAME} to become empty"
      SHARDS_ALLOCATION=$(curl -K- <<< "--user ${ELASTICSEARCH_USERNAME}:${ELASTICSEARCH_PASSWORD}" \
        -XGET "${ELASTICSEARCH_ENDPOINT}/_cat/shards")
      if ! echo "${SHARDS_ALLOCATION}" | grep -E "${NODE_NAME}"; then
        break
      fi
      sleep 5
    done
    echo "Node ${NODE_NAME} is ready to shutdown"
    kill -TERM 1
  }
  trap drain_data_node TERM EXIT HUP INT
  wait
}

$COMMAND
