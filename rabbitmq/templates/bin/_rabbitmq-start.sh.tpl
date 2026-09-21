#!/bin/bash

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

set -ex

{{- if .Values.pod.nofile.server }}
# RabbitMQ sizes its file-handle cache from the soft open-file limit it sees at
# boot, logging "Limiting to approx N file handles (M sockets)". That budget has
# to cover both client sockets and the segment/WAL files every quorum queue
# keeps open, and with quorum queues enabled a deployment reaches a few hundred
# of them easily -- neutron alone declares around 200.
#
# The container otherwise inherits the runtime's default soft limit, typically
# 1024, which leaves roughly 180 handles for sockets once the quorum queues have
# taken theirs. Past that the broker stops admitting connections and only lets a
# new one in as an old one closes: clients then sit unanswered until they give
# up, and the ones that suffer are whichever services open connections most
# often rather than whichever are at fault.
target={{ .Values.pod.nofile.server }}
hard="$(ulimit -Hn)"
if [ "${hard}" != "unlimited" ] && [ "${target}" -gt "${hard}" ]; then
  # Cannot exceed the hard limit set by the container runtime; take what we can
  # and say so, rather than failing to start.
  echo "WARNING: requested nofile ${target} exceeds the hard limit ${hard}; using ${hard}"
  target="${hard}"
fi
ulimit -n "${target}" || echo "WARNING: could not raise the open-file limit to ${target}"
echo "open file limit: soft=$(ulimit -Sn) hard=$(ulimit -Hn)"
{{- end }}

function check_if_open () {
  HOST=$1
  PORT=$2
  timeout 10 bash -c "true &>/dev/null </dev/tcp/${HOST}/${PORT}"
}

function check_rabbit_node_health () {
  CLUSTER_SEED_NAME=$1
  rabbitmq-diagnostics node_health_check -n "${CLUSTER_SEED_NAME}" -t 10 &>/dev/null
}

get_node_name () {
  TARGET_POD=$1
  POD_NAME_PREFIX="$(echo "${MY_POD_NAME}" | awk 'BEGIN{FS=OFS="-"}{NF--; print}')"
  echo "${RABBITMQ_NODENAME}" | awk -F "@${MY_POD_NAME}." "{ print \$1 \"@${POD_NAME_PREFIX}-${TARGET_POD}.\" \$2 }"
}

function check_rabbit_node_ready () {
  TARGET_POD=$1
  CLUSTER_SEED_NAME="$(get_node_name ${TARGET_POD})"
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
  touch /tmp/rabbit-disable-liveness-probe
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

  function reset_rabbit () {
    rabbitmqctl shutdown || true
    find /var/lib/rabbitmq/* ! -name 'definitions.json' ! -name '.erlang.cookie' -exec rm -rf {} +
    exit 1
  }

  # Start RabbitMQ, but disable readiness from being reported so the pod is not
  # marked as up prematurely.
  touch /tmp/rabbit-disable-readiness
  rabbitmq-server &

  # Wait for server to start, and reset if it does not
  END=$(($(date +%s) + 180))
  while ! rabbitmqctl -q cluster_status; do
      sleep 5
      NOW=$(date +%s)
      [ $NOW -gt $END ] && reset_rabbit
  done

  # Wait for server to join cluster, reset if it does not
  POD_INCREMENT=$(echo "${MY_POD_NAME}" | awk -F '-' '{print $NF}')
  END=$(($(date +%s) + 180))
  while ! rabbitmqctl -l --node $(get_node_name 0) -q cluster_status | grep -q "$(get_node_name ${POD_INCREMENT})"; do
    sleep 5
    NOW=$(date +%s)
    [ $NOW -gt $END ] && reset_rabbit
  done

  # Shutdown the inital server
  rabbitmqctl shutdown

  rm -fv /tmp/rabbit-disable-readiness /tmp/rabbit-disable-liveness-probe
fi

{{- if .Values.forceBoot.enabled }}
if [ "${POD_INCREMENT}" -eq "0" ] && [ -d "/var/lib/rabbitmq/mnesia/${RABBITMQ_NODENAME}" ]; then rabbitmqctl force_boot; fi
{{- end}}
exec rabbitmq-server
