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

set -e

# Extract connection details
RABBIT_HOSTNAME=`echo $RABBITMQ_ADMIN_CONNECTION | awk -F'[@]' '{print $2}' \
  | awk -F'[:/]' '{print $1}'`
RABBIT_PORT=`echo $RABBITMQ_ADMIN_CONNECTION | awk -F'[@]' '{print $2}' \
  | awk -F'[:/]' '{print $2}'`

# Extract Admin User creadential
RABBITMQ_ADMIN_USERNAME=`echo $RABBITMQ_ADMIN_CONNECTION | awk -F'[@]' '{print $1}' \
  | awk -F'[//:]' '{print $4}'`
RABBITMQ_ADMIN_PASSWORD=`echo $RABBITMQ_ADMIN_CONNECTION | awk -F'[@]' '{print $1}' \
  | awk -F'[//:]' '{print $5}'`

set -ex

function rabbitmqadmin_authed () {
  set +x
  rabbitmqadmin \
{{- if .Values.manifests.certificates }}
    --ssl \
    --ssl-disable-hostname-verification \
    --ssl-ca-cert-file="/etc/rabbitmq/certs/ca.crt" \
    --ssl-cert-file="/etc/rabbitmq/certs/tls.crt" \
    --ssl-key-file="/etc/rabbitmq/certs/tls.key" \
{{- end }}
    --host="${RABBIT_HOSTNAME}" \
    --port="${RABBIT_PORT}" \
    --username="${RABBITMQ_ADMIN_USERNAME}" \
    --password="${RABBITMQ_ADMIN_PASSWORD}" \
    ${@}
  set -x
}

function active_rabbit_nodes () {
  rabbitmqadmin_authed list nodes -f bash | wc -w
}

until test "$(active_rabbit_nodes)" -ge "$RABBIT_REPLICA_COUNT"; do
    echo "Waiting for number of nodes in cluster to meet or exceed number of desired pods ($RABBIT_REPLICA_COUNT)"
    sleep 10
done

function sorted_node_list () {
  rabbitmqadmin_authed list nodes -f bash | tr ' ' '\n' | sort | tr '\n' ' '
}

if test "$(active_rabbit_nodes)" -gt "$RABBIT_REPLICA_COUNT"; then
    echo "There are more nodes registed in the cluster than desired, pruning the cluster"
    PRIMARY_NODE="$(sorted_node_list | awk '{ print $1; exit }')"
    until rabbitmqctl -l -n "${PRIMARY_NODE}" cluster_status >/dev/null 2>&1 ; do
      echo "Waiting for primary node to return cluster status"
      sleep 10
    done
    echo "Current cluster:"
    rabbitmqctl -l -n "${PRIMARY_NODE}" cluster_status
    NODES_TO_REMOVE="$(sorted_node_list | awk "{print substr(\$0, index(\$0,\$$((RABBIT_REPLICA_COUNT+1))))}")"
    for NODE in ${NODES_TO_REMOVE}; do
      rabbitmqctl -l -n "${NODE}" stop_app || true
      rabbitmqctl -l -n "${PRIMARY_NODE}" forget_cluster_node "${NODE}"
    done
    echo "Updated cluster:"
    rabbitmqctl -l -n "${PRIMARY_NODE}" cluster_status
fi
