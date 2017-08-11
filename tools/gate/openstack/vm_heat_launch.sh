#!/bin/bash
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
set -xe
: ${WORK_DIR:="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/.."}
source ${WORK_DIR}/tools/gate/vars.sh
source ${WORK_DIR}/tools/gate/funcs/network.sh
source ${WORK_DIR}/tools/gate/funcs/openstack.sh

# Setup SSH Keypair in Nova
KEYPAIR_LOC="$(mktemp).pem"
$OPENSTACK keypair create ${OSH_VM_KEY_STACK} > ${KEYPAIR_LOC}
chmod 600 ${KEYPAIR_LOC}

# NOTE(portdirect): We do this fancy, and seemingly pointless, footwork to get
# the full image name for the cirros Image without having to be explicit.
IMAGE_NAME=$($OPENSTACK image show -f value -c name \
  $($OPENSTACK image list -f csv | awk -F ',' '{ print $2 "," $1 }' | \
    grep "^\"Cirros" | head -1 | awk -F ',' '{ print $2 }' | tr -d '"'))

HEAT_TEMPLATE=$(cat ${WORK_DIR}/tools/gate/files/${OSH_BASIC_VM_STACK}.yaml | base64 -w 0)
kubectl exec -n openstack ${OPENSTACK_POD} -- bash -c "echo $HEAT_TEMPLATE | base64 -d > /tmp/${OSH_BASIC_VM_STACK}.yaml"
$OPENSTACK stack create \
  --parameter public_net=${OSH_EXT_NET_NAME} \
  --parameter image="${IMAGE_NAME}" \
  --parameter flavor=${OSH_VM_FLAVOR} \
  --parameter ssh_key=${OSH_VM_KEY_STACK} \
  --parameter cidr=${OSH_PRIVATE_SUBNET} \
  -t /tmp/${OSH_BASIC_VM_STACK}.yaml \
  ${OSH_BASIC_VM_STACK}
openstack_wait_for_stack ${OSH_BASIC_VM_STACK} ${SERVICE_TEST_TIMEOUT}

FLOATING_IP=$($OPENSTACK floating ip show \
  $($OPENSTACK stack resource show \
      ${OSH_BASIC_VM_STACK} \
      server_floating_ip \
      -f value -c physical_resource_id) \
      -f value -c floating_ip_address)

# Ping our VM
wait_for_ping ${FLOATING_IP} ${SERVICE_TEST_TIMEOUT}

# Wait for SSH to come up
wait_for_ssh_port ${FLOATING_IP} ${SERVICE_TEST_TIMEOUT}

# SSH into the VM and check it can reach the outside world
ssh-keyscan "$FLOATING_IP" >> ~/.ssh/known_hosts
ssh -i ${KEYPAIR_LOC} cirros@${FLOATING_IP} ping -q -c 1 -W 2 ${OSH_BR_EX_ADDR%/*}

# SSH into the VM and check it can reach the metadata server
ssh -i ${KEYPAIR_LOC} cirros@${FLOATING_IP} curl -sSL 169.254.169.254

# Bonus round - display a Unicorn
ssh -i ${KEYPAIR_LOC} cirros@${FLOATING_IP} curl http://artscene.textfiles.com/asciiart/unicorn || true

# Remove the test stack
$OPENSTACK stack delete ${OSH_BASIC_VM_STACK}
