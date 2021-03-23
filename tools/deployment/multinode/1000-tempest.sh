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

#NOTE: Lint and package chart
make tempest

#NOTE: Deploy command
export OS_CLOUD=openstack_helm

export OSH_EXT_NET_NAME="public"
export OSH_EXT_SUBNET_NAME="public-subnet"
export OSH_EXT_SUBNET="172.24.4.0/24"
export OSH_BR_EX_ADDR="172.24.4.1/24"
openstack stack delete --wait --yes heat-public-net-deployment >/dev/null 2>&1 || true
openstack stack create --wait \
  --parameter network_name=${OSH_EXT_NET_NAME} \
  --parameter physical_network_name=public \
  --parameter subnet_name=${OSH_EXT_SUBNET_NAME} \
  --parameter subnet_cidr=${OSH_EXT_SUBNET} \
  --parameter subnet_gateway=${OSH_BR_EX_ADDR%/*} \
  -t ./tools/gate/files/heat-public-net-deployment.yaml \
  heat-public-net-deployment

export OSH_PRIVATE_SUBNET_POOL="10.0.0.0/8"
export OSH_PRIVATE_SUBNET_POOL_NAME="shared-default-subnetpool"
export OSH_PRIVATE_SUBNET_POOL_DEF_PREFIX="24"
openstack stack delete --wait --yes heat-subnet-pool-deployment >/dev/null 2>&1 || true
openstack stack create --wait \
  --parameter subnet_pool_name=${OSH_PRIVATE_SUBNET_POOL_NAME} \
  --parameter subnet_pool_prefixes=${OSH_PRIVATE_SUBNET_POOL} \
  --parameter subnet_pool_default_prefix_length=${OSH_PRIVATE_SUBNET_POOL_DEF_PREFIX} \
  -t ./tools/gate/files/heat-subnet-pool-deployment.yaml \
  heat-subnet-pool-deployment

FLAVOR_ID=$(openstack flavor show m1.tiny -f value -c id)
IMAGE_ID=$(openstack image list -f value -c Name -c ID | \
  grep " Cirros " | head -1 | cut -f 1 -d ' ')
NETWORK_ID=$(openstack network show public -f value -c id)

if [ "x$(systemd-detect-virt)" == "xnone" ]; then
  HYPERVISOR_TYPE="qemu"
fi

#NOTE: Deploy tempest
tee /tmp/tempest.yaml << EOF
conf:
  tempest:
    compute:
      flavor_ref: ${FLAVOR_ID}
      image_ref: ${IMAGE_ID}
      image_ref_alt: ${IMAGE_ID}
      hypervisor_type: ${HYPERVISOR_TYPE}
    network:
      default_network: ${OSH_PRIVATE_SUBNET_POOL}
      project_network_cidr: 172.0.4.0/16
      floating_network_name: "public"
      public_network_id: ${NETWORK_ID}
    validation:
      image_ssh_user: "cirros"
      image_ssh_password: "gocubsgo"
      network_for_ssh: "public"
      floating_ip_range: ${OSH_EXT_SUBNET}
pvc:
  enabled: false
EOF

envsubst < /tmp/tempest.yaml

helm upgrade --install tempest ./tempest \
  --namespace=openstack \
  --values=/tmp/tempest.yaml \
  ${OSH_EXTRA_HELM_ARGS} \
  ${OSH_EXTRA_HELM_ARGS_TEMPEST}

#NOTE: Wait for deploy
./tools/deployment/common/wait-for-pods.sh openstack 2400

#NOTE: Validate Deployment info
kubectl get -n openstack jobs
