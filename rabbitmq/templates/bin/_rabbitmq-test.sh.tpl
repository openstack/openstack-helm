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

# Extract connection details
RABBIT_HOSTNAME=`echo $RABBITMQ_ADMIN_CONNECTION | awk -F'[@]' '{print $2}' \
  | awk -F'[:/]' '{print $1}'`
RABBIT_PORT=`echo $RABBITMQ_ADMIN_CONNECTION | awk -F'[@]' '{print $2}' \
  | awk -F'[:/]' '{print $2}'`

set +x
# Extract Admin User creadential
RABBITMQ_ADMIN_USERNAME=`echo $RABBITMQ_ADMIN_CONNECTION | awk -F'[@]' '{print $1}' \
  | awk -F'[//:]' '{print $4}'`
RABBITMQ_ADMIN_PASSWORD=`echo $RABBITMQ_ADMIN_CONNECTION | awk -F'[@]' '{print $1}' \
  | awk -F'[//:]' '{print $5}'`
set -x

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

function rabbit_check_node_count () {
  echo "Checking node count "
  NODES_IN_CLUSTER=$(rabbitmqadmin_authed list nodes -f bash | wc -w)
  if [ "$NODES_IN_CLUSTER" -eq "$RABBIT_REPLICA_COUNT" ]; then
    echo "Number of nodes in cluster ($NODES_IN_CLUSTER) match number of desired pods ($NODES_IN_CLUSTER)"
  else
    echo "Number of nodes in cluster ($NODES_IN_CLUSTER) does not match number of desired pods ($RABBIT_REPLICA_COUNT)"
    exit 1
  fi
}
# Check node count
rabbit_check_node_count

function rabbit_find_partitions () {
  NODE_INFO=$(mktemp)
  rabbitmqadmin_authed list nodes -f pretty_json | tee "${NODE_INFO}"
  cat "${NODE_INFO}" | python3 -c "
import json, sys, traceback
print('Checking cluster partitions')
obj=json.load(sys.stdin)
for num, node in enumerate(obj):
  try:
    partition = node['partitions']
    if partition:
      raise Exception('cluster partition found: %s' % partition)
  except KeyError:
    print('Error: partition key not found for node %s' % node)
print('No cluster partitions found')
  "
  rm -vf "${NODE_INFO}"
}
rabbit_find_partitions

function rabbit_check_users_match () {
  echo "Checking users match on all nodes"
  NODES=$(rabbitmqadmin_authed list nodes -f bash)
  USER_LIST=$(mktemp --directory)
  echo "Found the following nodes: ${NODES}"
  for NODE in ${NODES}; do
    echo "Checking Node: ${NODE#*@}"
    rabbitmqadmin_authed list users -f bash > ${USER_LIST}/${NODE#*@}
  done
  cd ${USER_LIST}; diff -q --from-file $(ls ${USER_LIST})
  echo "User lists match for all nodes"
}
# Check users match on all nodes
rabbit_check_users_match
