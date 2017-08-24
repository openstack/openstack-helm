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

# Create default private network
$NEUTRON net-create ${OSH_PRIVATE_NET_NAME}
$NEUTRON subnet-create \
  --name ${OSH_PRIVATE_SUBNET_NAME} \
  --ip-version 4 \
  --dns-nameserver ${OSH_EXT_DNS} \
  $($NEUTRON net-show private -f value -c id) \
  ${OSH_PRIVATE_SUBNET}

# Create default router and link networks
$NEUTRON router-create ${OSH_ROUTER}
$NEUTRON router-interface-add \
  $($NEUTRON router-show ${OSH_ROUTER} -f value -c id) \
  $($NEUTRON subnet-show private-subnet -f value -c id)
$NEUTRON router-gateway-set \
  $($NEUTRON router-show ${OSH_ROUTER} -f value -c id) \
  $($NEUTRON net-show ${OSH_EXT_NET_NAME} -f value -c id)

ROUTER_PUBLIC_IP=$($NEUTRON router-show ${OSH_ROUTER} -f value -c external_gateway_info | jq -r '.external_fixed_ips[].ip_address')
wait_for_ping ${ROUTER_PUBLIC_IP}

# Loosen up security group to allow access to the VM
PROJECT=$($OPENSTACK project show admin -f value -c id)
SECURITY_GROUP=$($OPENSTACK security group list -f csv | grep ${PROJECT} | grep "default" | awk -F "," '{ print $1 }'  | tr -d '"')
$OPENSTACK security group rule create ${SECURITY_GROUP} \
  --protocol icmp \
  --src-ip 0.0.0.0/0
$OPENSTACK security group rule create ${SECURITY_GROUP} \
  --protocol tcp \
  --dst-port 22:22 \
  --src-ip 0.0.0.0/0

# Setup SSH Keypair in Nova
KEYPAIR_LOC="$(mktemp).pem"
$OPENSTACK keypair create ${OSH_VM_KEY_CLI} > ${KEYPAIR_LOC}
chmod 600 ${KEYPAIR_LOC}

# Boot a vm and wait for it to become active
FLAVOR=$($OPENSTACK flavor show "${OSH_VM_FLAVOR}" -f value -c id)
IMAGE=$($OPENSTACK image list -f csv | awk -F ',' '{ print $2 "," $1 }' | grep "^\"Cirros" | head -1 | awk -F ',' '{ print $2 }' | tr -d '"')
NETWORK=$($NEUTRON net-show ${OSH_PRIVATE_NET_NAME} -f value -c id)
$NOVA boot \
    --nic net-id=${NETWORK} \
    --flavor=${FLAVOR} \
    --image=${IMAGE} \
    --key-name=${OSH_VM_KEY_CLI} \
    --security-groups="default" \
    ${OSH_VM_NAME_CLI}
openstack_wait_for_vm ${OSH_VM_NAME_CLI}

# Assign a floating IP to the VM
FLOATING_IP=$($OPENSTACK floating ip create ${OSH_EXT_NET_NAME} -f value -c floating_ip_address)
$OPENSTACK server add floating ip ${OSH_VM_NAME_CLI} ${FLOATING_IP}

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


if $OPENSTACK service list -f value -c Type | grep -q volume; then
  $OPENSTACK volume create \
    --size ${OSH_VOL_SIZE_CLI} \
    --type ${OSH_VOL_TYPE_CLI} \
    ${OSH_VOL_NAME_CLI}
  openstack_wait_for_volume ${OSH_VOL_NAME_CLI} available ${SERVICE_TEST_TIMEOUT}

  $OPENSTACK server add volume ${OSH_VM_NAME_CLI} ${OSH_VOL_NAME_CLI}
  openstack_wait_for_volume ${OSH_VOL_NAME_CLI} in-use ${SERVICE_TEST_TIMEOUT}

  VOL_DEV=$($OPENSTACK volume show ${OSH_VOL_NAME_CLI} \
    -f value -c attachments | \
    ${WORK_DIR}/tools/gate/funcs/python-data-to-json.py | \
    jq -r '.[] | .device')
  ssh -i ${KEYPAIR_LOC} cirros@${FLOATING_IP} sudo /usr/sbin/mkfs.ext4 ${VOL_DEV}

  $OPENSTACK server remove volume  ${OSH_VM_NAME_CLI} ${OSH_VOL_NAME_CLI}
  openstack_wait_for_volume ${OSH_VOL_NAME_CLI} available ${SERVICE_TEST_TIMEOUT}

  $OPENSTACK volume delete ${OSH_VOL_NAME_CLI}
fi

# Remove the test vm
$NOVA delete ${OSH_VM_NAME_CLI}
