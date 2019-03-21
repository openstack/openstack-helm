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

function check_if_open () {
  HOST=$1
  PORT=$2
  timeout 10 bash -c "true &>/dev/null </dev/tcp/${HOST}/${PORT}"
}

function check_rabbit_node_health () {
  CLUSTER_SEED_NAME=$1
  rabbitmq-diagnostics node_health_check -n "${CLUSTER_SEED_NAME}" -t 10 &>/dev/null
}

function check_rabbit_node_ready () {
  TARGET_POD=$1
  POD_NAME_PREFIX="$(echo "${MY_POD_NAME}" | awk 'BEGIN{FS=OFS="-"}{NF--; print}')"
  CLUSTER_SEED_NAME="$(echo "${RABBITMQ_NODENAME}" | awk -F "@${MY_POD_NAME}." "{ print \$1 \"@${POD_NAME_PREFIX}-${TARGET_POD}.\" \$2 }")"
  CLUSTER_SEED_HOST="$(echo "${CLUSTER_SEED_NAME}" | awk -F '@' '{ print $NF }')"
  check_rabbit_node_health "${CLUSTER_SEED_NAME}" && \
  check_if_open "${CLUSTER_SEED_HOST}" "${PORT_HTTP}" && \
  check_if_open "${CLUSTER_SEED_HOST}" "${PORT_AMPQ}" && \
  check_if_open "${CLUSTER_SEED_HOST}" "${PORT_CLUSTERING}"
}

POD_INCREMENT=$(echo "${MY_POD_NAME}" | awk -F '-' '{print $NF}')
if ! [ "${POD_INCREMENT}" -eq "0" ] && ! [ -d "/var/lib/rabbitmq/mnesia" ] ; then
  echo 'This is not the 1st rabbit pod & has not been initialised'
  # disable liveness probe as it may take some time for the pod to come online.
  touch /run/rabbit-disable-liveness-probe
  POD_NAME_PREFIX="$(echo "${MY_POD_NAME}" | awk 'BEGIN{FS=OFS="-"}{NF--; print}')"
  for TARGET_POD in $(seq 0 +1 $((POD_INCREMENT - 1 ))); do
    END=$(($(date +%s) + 900))
    while ! check_rabbit_node_ready "${TARGET_POD}"; do
      sleep 5
      if [ "$(date +%s)" -gt "$END" ]; then
        echo "RabbitMQ pod ${TARGET_POD} not ready in time"
        exit 1
      fi
    done
  done
  rm -fv /run/rabbit-disable-liveness-probe
fi

exec rabbitmq-server
