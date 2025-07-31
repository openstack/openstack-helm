#!/bin/bash

#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.

set -xe

export OS_CLOUD=openstack_helm

HEAT_DIR="$(readlink -f ./tools/deployment/component/octavia)"
SSH_DIR="${HOME}/.ssh"

OPENSTACK_CLIENT_CONTAINER_EXTRA_ARGS="${OPENSTACK_CLIENT_CONTAINER_EXTRA_ARGS} -v ${HEAT_DIR}:${HEAT_DIR} -v ${SSH_DIR}:${SSH_DIR}"
export OPENSTACK_CLIENT_CONTAINER_EXTRA_ARGS

COMPUTE_FLAVOR_ID=$(openstack flavor show -f value -c id m1.amphora)
# The /tmp/inventory_k8s_nodes.txt file is created by the deploy-env role and contains the list
# of all K8s nodes. Amphora instance is run on the first K8s node from the list.
# Worker VM instances are run on the rest of the nodes.
TARGET_HOST_1=$(sed -n '2p' /tmp/inventory_k8s_nodes.txt)
TARGET_HOST_2=$(sed -n '3p' /tmp/inventory_k8s_nodes.txt)

openstack stack show "octavia-env" || \
  openstack stack create --wait \
    --parameter compute_flavor_id=${COMPUTE_FLAVOR_ID} \
    --parameter az_1="nova:${TARGET_HOST_1}" \
    --parameter az_2="nova:${TARGET_HOST_2}" \
    -t ${HEAT_DIR}/heat_octavia_env.yaml \
    octavia-env

sleep 30

LB_FLOATING_IP=$(openstack floating ip list --port $(openstack loadbalancer show osh -c vip_port_id -f value) -f value -c "Floating IP Address" | head -n1)

echo -n > /tmp/curl.txt
curl http://${LB_FLOATING_IP} >> /tmp/curl.txt
curl http://${LB_FLOATING_IP} >> /tmp/curl.txt
grep "Hello from server_1" /tmp/curl.txt
grep "Hello from server_2" /tmp/curl.txt
