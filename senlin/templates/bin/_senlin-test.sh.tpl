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

# Set defaults to use for testing.
: ${IMAGE_ID:="$(openstack image show -f value -c id \
  $(openstack image list -f csv | awk -F ',' '{ print $2 "," $1 }' | \
    grep "^\"Cirros" | head -1 | awk -F ',' '{ print $2 }' | tr -d '"'))"}
: ${FLAVOR_ID:="$(openstack flavor show m1.tiny -f value -c id)"}
: ${NETWORK_NAME:="public"}
: ${SUB_TIMEOUT:=1200}

# Define functions to use during tests.
function gen_uuid () {
  cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1
}

function wait_for_senlin_cluster {
  set +x
  end=$(($(date +%s) + ${SUB_TIMEOUT}))
  while true; do
      STATE=$(openstack cluster show "${1}" -f value -c status)
      [ "x${STATE}" == "xACTIVE" ] && break
      sleep 1
      now=$(date +%s)
      [ $now -gt $end ] && echo "Node did not come up in time" && openstack cluster show "${1}" && exit -1
  done
  set -x
  openstack cluster show "${1}"
}

function wait_for_senlin_node {
  set +x
  end=$(($(date +%s) + ${SUB_TIMEOUT}))
  while true; do
      STATE=$(openstack cluster node show "${1}" -f value -c status)
      [ "x${STATE}" == "xACTIVE" ] && break
      sleep 1
      now=$(date +%s)
      [ $now -gt $end ] && echo "Node did not come up in time" && openstack cluster node show "${1}" && exit -1
  done
  set -x
  openstack cluster node show "${1}"
}

function wait_for_senlin_profile_delete {
  set +x
  end=$(($(date +%s) + ${SUB_TIMEOUT}))
  until openstack cluster profile delete "${1}" --force; do
      sleep 1
      now=$(date +%s)
      [ $now -gt $end ] && echo "Profile did not delete in time" && exit -1
  done
  set -x
}

# Start test run.
SENLIN_CLUSTER_PROFILE=$(gen_uuid)
SENLIN_CLUSTER_NAME=$(gen_uuid)
SENLIN_NODE_NAME=$(gen_uuid)

# Create a cluster profile.
tee > /tmp/cirros_basic.yaml <<EOF
type: os.nova.server
version: 1.0
properties:
  name: osh-test
  flavor: "${FLAVOR_ID}"
  image: "${IMAGE_ID}"
  #key_name: oskey
  networks:
   - network: ${NETWORK_NAME}
  metadata:
    test_key: test_value
  user_data: |
    #!/bin/sh
    echo 'hello, world' > /tmp/test_file
EOF
openstack cluster profile create --spec-file /tmp/cirros_basic.yaml "${SENLIN_CLUSTER_PROFILE}"

# Create a 0 node cluster using the profile.
# NOTE(portdirect): There is a bug in the Newton era osc/senlin client
# interaction, so we fall back to calling senlin client directly to create
# a cluster, before outright failing.
openstack cluster create --profile "${SENLIN_CLUSTER_PROFILE}" "${SENLIN_CLUSTER_NAME}" || \
  senlin cluster-create -p "${SENLIN_CLUSTER_PROFILE}" "${SENLIN_CLUSTER_NAME}" || false

# Resize the cluster to contain a node.
openstack cluster resize --capacity 1 "${SENLIN_CLUSTER_NAME}"
wait_for_senlin_cluster "${SENLIN_CLUSTER_NAME}"

# Expand the cluster by one node.
openstack cluster expand "${SENLIN_CLUSTER_NAME}"
wait_for_senlin_cluster "${SENLIN_CLUSTER_NAME}"

# Shrink the cluster by one node.
openstack cluster shrink "${SENLIN_CLUSTER_NAME}"
wait_for_senlin_cluster "${SENLIN_CLUSTER_NAME}"

# Create a single node using the cluster profile.
# NOTE(portdirect): There is a bug in the Newton era osc/senlin client
# interaction, so we fall back to calling senlin client directly to create
# a node, before outright failing.
openstack cluster node create --profile "${SENLIN_CLUSTER_PROFILE}" "${SENLIN_NODE_NAME}" || \
  senlin node-create -p "${SENLIN_CLUSTER_PROFILE}" "${SENLIN_NODE_NAME}" || false
wait_for_senlin_node "${SENLIN_NODE_NAME}"

# Add the node to the cluster.
openstack cluster members add --nodes "${SENLIN_NODE_NAME}" "${SENLIN_CLUSTER_NAME}"
openstack cluster members list "${SENLIN_CLUSTER_NAME}"
wait_for_senlin_cluster "${SENLIN_CLUSTER_NAME}"
wait_for_senlin_node "${SENLIN_NODE_NAME}"

# Remove the node from the cluster.
openstack cluster members del --nodes "${SENLIN_NODE_NAME}" "${SENLIN_CLUSTER_NAME}"
openstack cluster members list "${SENLIN_CLUSTER_NAME}"
wait_for_senlin_cluster "${SENLIN_CLUSTER_NAME}"
wait_for_senlin_node "${SENLIN_NODE_NAME}"

# Cleanup the resources created.
openstack cluster node delete "${SENLIN_NODE_NAME}" --force
openstack cluster delete "${SENLIN_CLUSTER_NAME}" --force
wait_for_senlin_profile_delete "${SENLIN_CLUSTER_PROFILE}"

echo 'Tests Passed'
