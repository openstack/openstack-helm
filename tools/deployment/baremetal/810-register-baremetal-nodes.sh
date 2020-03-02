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
export OSH_IRONIC_NODE_DISC=${OSH_IRONIC_NODE_DISC:="5"}
export OSH_IRONIC_NODE_RAM=${OSH_IRONIC_NODE_RAM:="4096"}
export OSH_IRONIC_NODE_CPU=${OSH_IRONIC_NODE_CPU:="2"}
export OSH_IRONIC_NODE_ARCH=${OSH_IRONIC_NODE_ARCH:="x86_64"}

#NOTE: Register the baremetal nodes with ironic
DEPLOY_VMLINUZ_UUID=$(openstack image show ironic-agent.kernel -f value -c id)
DEPLOY_INITRD_UUID=$(openstack image show ironic-agent.initramfs -f value -c id)
MASTER_IP=$(kubectl get node $(hostname -f) -o json |  jq -r '.status.addresses[] | select(.type=="InternalIP").address')
while read NODE_DETAIL_RAW; do
  NODE_DETAIL=($(echo ${NODE_DETAIL_RAW}))
  NODE_BMC_IP=${NODE_DETAIL[0]}
  NODE_MAC=${NODE_DETAIL[1]}
  if [ "$(kubectl get node -o name | wc -l)" -eq "1" ] || [ "x${MASTER_IP}" != "x${NODE_BMC_IP}" ]; then
    BM_NODE=$(openstack baremetal node create \
              --driver agent_ipmitool \
              --driver-info ipmi_username=admin \
              --driver-info ipmi_password=password \
              --driver-info ipmi_address="${NODE_BMC_IP}" \
              --driver-info ipmi_port=623 \
              --driver-info deploy_kernel=${DEPLOY_VMLINUZ_UUID} \
              --driver-info deploy_ramdisk=${DEPLOY_INITRD_UUID} \
              --property local_gb=${OSH_IRONIC_NODE_DISC} \
              --property memory_mb=${OSH_IRONIC_NODE_RAM} \
              --property cpus=${OSH_IRONIC_NODE_CPU} \
              --property cpu_arch=${OSH_IRONIC_NODE_ARCH} \
              -f value -c uuid)
      openstack baremetal node manage "${BM_NODE}"
      openstack baremetal port create --node ${BM_NODE} "${NODE_MAC}"
      openstack baremetal node validate "${BM_NODE}"
      openstack baremetal node provide "${BM_NODE}"
      openstack baremetal node show "${BM_NODE}"
  fi
done < /tmp/bm-hosts.txt

#NOTE: Wait for our baremetal nodes to become avalible for provisioning
function wait_for_ironic_node {
  # Default wait timeout is 1200 seconds
  set +x
  end=$(date +%s)
  if ! [ -z $2 ]; then
   end=$((end + $2))
  else
   end=$((end + 1200))
  fi
  while true; do
      STATE=$(openstack baremetal node show $1 -f value -c provision_state)
      [ "x${STATE}" == "xavailable" ] && break
      sleep 1
      now=$(date +%s)
      [ $now -gt $end ] && echo "Node did not come up in time" && openstack baremetal node show $1 && exit -1
  done
  set -x
}
for NODE in $(openstack baremetal node list -f value -c UUID); do
  wait_for_ironic_node $NODE
done
openstack baremetal node list
