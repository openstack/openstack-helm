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

# Turn on ip forwarding if its not already
if [ $(cat /proc/sys/net/ipv4/ip_forward) -eq 0 ]; then
  sudo bash -c "echo 1 > /proc/sys/net/ipv4/ip_forward"
fi

# Assign IP address to br-ex
sudo ip addr add ${OSH_BR_EX_ADDR} dev br-ex
sudo ip link set br-ex up
# Setup masquerading on default route dev to public subnet
sudo iptables -t nat -A POSTROUTING -o $(net_default_iface) -s ${OSH_EXT_SUBNET} -j MASQUERADE

# Disable In-Band rules on br-ex bridge to ease debugging
OVS_VSWITCHD_POD=$(kubectl get -n openstack pods -l application=openvswitch,component=ovs-vswitchd --no-headers -o name | head -1 | awk -F '/' '{ print $NF }')
kubectl exec -n openstack ${OVS_VSWITCHD_POD} -- ovs-vsctl set Bridge br-ex other_config:disable-in-band=true


if ! $OPENSTACK service list -f value -c Type | grep -q orchestration; then
  echo "No orchestration service active: creating public network via CLI"
  $NEUTRON net-create ${OSH_EXT_NET_NAME} -- --is-default \
    --router:external \
    --provider:network_type=flat \
    --provider:physical_network=public
  $NEUTRON subnet-create \
    --name ${OSH_EXT_SUBNET_NAME} \
    --ip-version 4 \
    $($NEUTRON net-show ${OSH_EXT_NET_NAME} -f value -c id) ${OSH_EXT_SUBNET} -- \
        --enable_dhcp=False

  # Create default subnet pool
  $NEUTRON subnetpool-create \
    ${OSH_PRIVATE_SUBNET_POOL_NAME} \
    --default-prefixlen ${OSH_PRIVATE_SUBNET_POOL_DEF_PREFIX} \
    --pool-prefix ${OSH_PRIVATE_SUBNET_POOL} \
    --shared \
    --is-default=True
else
  echo "Orchestration service active: creating public network via Heat"
  HEAT_TEMPLATE=$(cat ${WORK_DIR}/tools/gate/files/${OSH_PUB_NET_STACK}.yaml | base64 -w 0)
  kubectl exec -n openstack ${OPENSTACK_POD} -- bash -c "echo $HEAT_TEMPLATE | base64 -d > /tmp/${OSH_PUB_NET_STACK}.yaml"
  $OPENSTACK stack create \
    --parameter network_name=${OSH_EXT_NET_NAME} \
    --parameter physical_network_name=public \
    --parameter subnet_name=${OSH_EXT_SUBNET_NAME} \
    --parameter subnet_cidr=${OSH_EXT_SUBNET} \
    --parameter subnet_gateway=${OSH_BR_EX_ADDR%/*} \
    -t /tmp/${OSH_PUB_NET_STACK}.yaml \
    ${OSH_PUB_NET_STACK}
  openstack_wait_for_stack ${OSH_PUB_NET_STACK}

  HEAT_TEMPLATE=$(cat ${WORK_DIR}/tools/gate/files/${OSH_SUBNET_POOL_STACK}.yaml | base64 -w 0)
  kubectl exec -n openstack ${OPENSTACK_POD} -- bash -c "echo $HEAT_TEMPLATE | base64 -d > /tmp/${OSH_SUBNET_POOL_STACK}.yaml"
  $OPENSTACK stack create \
    --parameter subnet_pool_name=${OSH_PRIVATE_SUBNET_POOL_NAME} \
    --parameter subnet_pool_prefixes=${OSH_PRIVATE_SUBNET_POOL} \
    --parameter subnet_pool_default_prefix_length=${OSH_PRIVATE_SUBNET_POOL_DEF_PREFIX} \
    -t /tmp/${OSH_SUBNET_POOL_STACK}.yaml \
    ${OSH_SUBNET_POOL_STACK}
  openstack_wait_for_stack ${OSH_SUBNET_POOL_STACK}
fi
