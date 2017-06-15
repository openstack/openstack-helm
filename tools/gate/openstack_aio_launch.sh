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

: ${KS_USER:="admin"}
: ${KS_PROJECT:="admin"}
: ${KS_PASSWORD:="password"}
: ${KS_USER_DOMAIN:="default"}
: ${KS_PROJECT_DOMAIN:="default"}
: ${KS_URL:="http://keystone.openstack/v3"}

: ${OSH_BR_EX_ADDR:="172.24.4.1/24"}
: ${OSH_EXT_SUBNET:="172.24.4.0/24"}
: ${OSH_EXT_DNS:="8.8.8.8"}
: ${OSH_EXT_NET_NAME:="public"}
: ${OSH_EXT_SUBNET_NAME:="public-subnet"}
: ${OSH_ROUTER:="router1"}
: ${OSH_PRIVATE_NET_NAME:="private"}
: ${OSH_PRIVATE_SUBNET:="10.0.0.0/24"}
: ${OSH_PRIVATE_SUBNET_NAME:="private-subnet"}
: ${OSH_PRIVATE_SUBNET_POOL:="10.0.0.0/8"}
: ${OSH_PRIVATE_SUBNET_POOL_NAME:="shared-default-subnetpool"}
: ${OSH_PRIVATE_SUBNET_POOL_DEF_PREFIX:="24"}
: ${OSH_VM_NAME:="osh-smoketest"}
: ${OSH_VM_KEY:="osh-smoketest-key"}

# Source some functions that will help us
source ${WORK_DIR}/tools/gate/funcs/openstack.sh

# Setup openstack clients
KEYSTONE_CREDS="--os-username ${KS_USER} \
  --os-project-name ${KS_PROJECT} \
  --os-auth-url ${KS_URL} \
  --os-project-domain-name ${KS_PROJECT_DOMAIN} \
  --os-user-domain-name ${KS_USER_DOMAIN} \
  --os-password ${KS_PASSWORD}"
NEUTRON_POD=$(kubectl get -n openstack pods -l app=neutron-server --no-headers -o name | head -1 | awk -F '/' '{ print $NF }')
NEUTRON="kubectl exec -n openstack ${NEUTRON_POD} -- neutron ${KEYSTONE_CREDS}"
OPENSTACK_POD=$(kubectl get -n openstack pods -l app=keystone-api --no-headers -o name | head -1 | awk -F '/' '{ print $NF }')
OPENSTACK="kubectl exec -n openstack ${OPENSTACK_POD} -- openstack ${KEYSTONE_CREDS} --os-identity-api-version 3 --os-image-api-version 2"
NOVA_POD=$(kubectl get -n openstack pods -l app=nova-api-osapi --no-headers -o name | head -1 | awk -F '/' '{ print $NF }')
NOVA="kubectl exec -n openstack ${NOVA_POD} -- nova ${KEYSTONE_CREDS}"

# Turn on ip forwarding if its not already
if [ $(cat /proc/sys/net/ipv4/ip_forward) -eq 0 ]; then
  sudo bash -c "echo 1 > /proc/sys/net/ipv4/ip_forward"
fi

# Assign IP address to br-ex
sudo ip addr add ${OSH_BR_EX_ADDR} dev br-ex
sudo ip link set br-ex up

# Disable In-Band rules on br-ex bridge to ease debugging
OVS_VSWITCHD_POD=$(kubectl get -n openstack pods -l app=ovs-vswitchd --no-headers -o name | head -1 | awk -F '/' '{ print $NF }')
kubectl exec -n openstack ${OVS_VSWITCHD_POD} -- ovs-vsctl set Bridge br-ex other_config:disable-in-band=true

# Setup masquerading on default route dev to public subnet
DEFAULT_GW_DEV=$(sudo ip -4 route list 0/0 | cut -d ' ' -f 5)
sudo iptables -t nat -A POSTROUTING -o ${DEFAULT_GW_DEV} -s ${OSH_EXT_SUBNET} -j MASQUERADE

# Create default networks
$NEUTRON net-create ${OSH_PRIVATE_NET_NAME}
$NEUTRON subnet-create \
    --name ${OSH_PRIVATE_SUBNET_NAME} \
    --ip-version 4 \
    --dns-nameserver ${OSH_EXT_DNS} \
    $($NEUTRON net-show private -f value -c id) \
    ${OSH_PRIVATE_SUBNET}
$NEUTRON router-create ${OSH_ROUTER}
$NEUTRON subnetpool-create \
    ${OSH_PRIVATE_SUBNET_POOL_NAME} \
    --default-prefixlen ${OSH_PRIVATE_SUBNET_POOL_DEF_PREFIX} \
    --pool-prefix ${OSH_PRIVATE_SUBNET_POOL} \
    --shared \
    --is-default=True
$NEUTRON net-create ${OSH_EXT_NET_NAME} -- --is-default \
    --router:external \
    --provider:network_type=flat \
    --provider:physical_network=public
$NEUTRON router-interface-add $($NEUTRON router-show ${OSH_ROUTER} -f value -c id) $($NEUTRON subnet-show private-subnet -f value -c id)
$NEUTRON subnet-create \
  --name ${OSH_EXT_SUBNET_NAME} \
  --ip-version 4 \
  $($NEUTRON net-show ${OSH_EXT_NET_NAME} -f value -c id) ${OSH_EXT_SUBNET} -- --enable_dhcp=False
$NEUTRON router-gateway-set $($NEUTRON router-show ${OSH_ROUTER} -f value -c id) $($NEUTRON net-show ${OSH_EXT_NET_NAME} -f value -c id)

ROUTER_PUBLIC_IP=$($NEUTRON router-show ${OSH_ROUTER} -f value -c external_gateway_info | jq -r '.external_fixed_ips[].ip_address')
wait_for_ping ${ROUTER_PUBLIC_IP}

# Setup SSH Keypair in Nova
KEYPAIR_LOC="$(mktemp).pem"
$OPENSTACK keypair create ${OSH_VM_KEY} > ${KEYPAIR_LOC}
chmod 600 ${KEYPAIR_LOC}

# Boot a vm and wait for it to become active
FLAVOR=$($OPENSTACK flavor show "m1.tiny" -f value -c id)
IMAGE=$($OPENSTACK image list -f csv | awk -F ',' '{ print $2 "," $1 }' | grep "^\"Cirros" | head -1 | awk -F ',' '{ print $2 }' | tr -d '"')
NETWORK=$($NEUTRON net-show private -f value -c id)
$NOVA boot \
    --nic net-id=${NETWORK} \
    --flavor=${FLAVOR} \
    --image=${IMAGE} \
    --key-name=${OSH_VM_KEY} \
    --security-groups="default" \
    ${OSH_VM_NAME}
openstack_wait_for_vm ${OSH_VM_NAME}

# Assign a floating IP to the VM
FLOATING_IP=$($OPENSTACK floating ip create ${OSH_EXT_NET_NAME} -f value -c floating_ip_address)
$OPENSTACK server add floating ip ${OSH_VM_NAME} ${FLOATING_IP}

# Loosen up security group to allow access to the VM
PROJECT=$($OPENSTACK project show admin -f value -c id)
SECURITY_GROUP=$($OPENSTACK security group list -f csv | grep ${PROJECT} | grep "default" | awk -F "," '{ print $1 }'  | tr -d '"')
$OPENSTACK security group rule create ${SECURITY_GROUP} --protocol icmp --src-ip  0.0.0.0/0
$OPENSTACK security group rule create ${SECURITY_GROUP} --protocol tcp --dst-port 22:22 --src-ip 0.0.0.0/0

# Ping our VM
wait_for_ping ${FLOATING_IP}

# SSH into the VM and check it can reach the outside world
ssh-keyscan "$FLOATING_IP" >> ~/.ssh/known_hosts
ssh -i ${KEYPAIR_LOC} cirros@${FLOATING_IP} ping -q -c 1 -W 2 ${OSH_BR_EX_ADDR%/*}

# SSH into the VM and check it can reach the metadata server
ssh -i ${KEYPAIR_LOC} cirros@${FLOATING_IP} curl -sSL 169.254.169.254

# Bonus round - display a Unicorn
ssh -i ${KEYPAIR_LOC} cirros@${FLOATING_IP} curl http://artscene.textfiles.com/asciiart/unicorn || true

# Remove the test vm
$NOVA delete ${OSH_VM_NAME}
