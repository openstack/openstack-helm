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

# rabbitmqadmin v2, shipped by the RabbitMQ 4.x management image, is a different
# program from the python v1 tool in the 3.x images: node listing moved from
# "list nodes" to "nodes list" and the TLS flags were renamed. Detect which one
# is installed, the same way the rabbit-init script does. This job cannot avoid
# the HTTP API the way it avoids rabbitmqadmin elsewhere: it has to discover
# node names before it can address a node with rabbitmqctl.
# Detection looks at what the program *is*, not at what it prints. Probing the
# grammar with "users --help" does not work: v1 parses options with python's
# option parser, which handles --help globally and exits 0 even for a
# subcommand it does not have, so v1 would be taken for v2. v1 is a python
# script and v2 is a compiled binary, which a shebang distinguishes reliably.
RABBITMQADMIN_PATH="$(command -v rabbitmqadmin || true)"
if [ -n "${RABBITMQADMIN_PATH}" ] && \
   [ "$(head -c 2 "${RABBITMQADMIN_PATH}" 2>/dev/null)" = '#!' ]
then
  RABBITMQADMIN_MAJOR=1
else
  RABBITMQADMIN_MAJOR=2
fi
echo "Detected rabbitmqadmin v${RABBITMQADMIN_MAJOR}"

function rabbitmqadmin_authed () {
  set +x
  if [ "${RABBITMQADMIN_MAJOR}" -eq 2 ]
  then
    rabbitmqadmin \
{{- if .Values.manifests.certificates }}
      --use-tls \
      --tls-ca-cert-file="/etc/rabbitmq/certs/ca.crt" \
      --tls-cert-file="/etc/rabbitmq/certs/tls.crt" \
      --tls-key-file="/etc/rabbitmq/certs/tls.key" \
{{- end }}
      --host="${RABBIT_HOSTNAME}" \
      --port="${RABBIT_PORT}" \
      --username="${RABBITMQ_ADMIN_USERNAME}" \
      --password="${RABBITMQ_ADMIN_PASSWORD}" \
      --non-interactive \
      "$@"
  else
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
      "$@"
  fi
  set -x
}

# Node names are pulled out by looking for the @ that every one contains, rather
# than by column position: v1 asked for a bash-formatted list of bare names and
# v2 prints a table whose shape is its own business. No other field either tool
# reports contains an @.
function node_list () {
  if [ "${RABBITMQADMIN_MAJOR}" -eq 2 ]
  then
    rabbitmqadmin_authed nodes list
  else
    rabbitmqadmin_authed list nodes -f bash
  fi | tr -s ' \t' '\n' | grep '@' | sort -u
}

function active_rabbit_nodes () {
  node_list | wc -l
}

until test "$(active_rabbit_nodes)" -ge "$RABBIT_REPLICA_COUNT"; do
    echo "Waiting for number of nodes in cluster to meet or exceed number of desired pods ($RABBIT_REPLICA_COUNT)"
    sleep 10
done

function sorted_node_list () {
  node_list | tr '\n' ' '
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
