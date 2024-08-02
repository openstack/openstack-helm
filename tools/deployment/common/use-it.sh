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

DPDK_ENABLED=disabled
if [[ ${FEATURE_GATES//,/ } =~ (^|[[:space:]])dpdk($|[[:space:]]) ]]; then
    DPDK_ENABLED=enabled
fi

export OS_CLOUD=openstack_helm

: ${HEAT_DIR:="$(readlink -f ./tools/deployment/common)"}
: ${SSH_DIR:="${HOME}/.ssh"}

if [[ -n ${HEAT_DIR} ]]; then
  OPENSTACK_CLIENT_CONTAINER_EXTRA_ARGS="${OPENSTACK_CLIENT_CONTAINER_EXTRA_ARGS} -v ${HEAT_DIR}:${HEAT_DIR}"
fi

if [[ -n ${SSH_DIR} ]]; then
  OPENSTACK_CLIENT_CONTAINER_EXTRA_ARGS="${OPENSTACK_CLIENT_CONTAINER_EXTRA_ARGS} -v ${SSH_DIR}:${SSH_DIR}"
fi

export OPENSTACK_CLIENT_CONTAINER_EXTRA_ARGS

: ${OSH_EXT_NET_NAME:="public"}
: ${OSH_EXT_SUBNET_NAME:="public-subnet"}
: ${OSH_EXT_SUBNET:="172.24.4.0/24"}
: ${OSH_BR_EX_ADDR:="172.24.4.1/24"}
: ${OSH_ALLOCATION_POOL_START:="172.24.4.10"}
: ${OSH_ALLOCATION_POOL_END:="172.24.4.254"}
openstack stack show "heat-public-net-deployment" || \
  openstack stack create --wait \
    --parameter network_name=${OSH_EXT_NET_NAME} \
    --parameter physical_network_name=public \
    --parameter subnet_name=${OSH_EXT_SUBNET_NAME} \
    --parameter subnet_cidr=${OSH_EXT_SUBNET} \
    --parameter subnet_gateway=${OSH_BR_EX_ADDR%/*} \
    --parameter allocation_pool_start=${OSH_ALLOCATION_POOL_START} \
    --parameter allocation_pool_end=${OSH_ALLOCATION_POOL_END} \
    -t ${HEAT_DIR}/heat-public-net-deployment.yaml \
    heat-public-net-deployment

: ${OSH_PRIVATE_SUBNET_POOL:="192.168.128.0/20"}
: ${OSH_PRIVATE_SUBNET_POOL_NAME:="shared-default-subnetpool"}
: ${OSH_PRIVATE_SUBNET_POOL_DEF_PREFIX:="24"}
openstack stack show "heat-subnet-pool-deployment" || \
  openstack stack create --wait \
    --parameter subnet_pool_name=${OSH_PRIVATE_SUBNET_POOL_NAME} \
    --parameter subnet_pool_prefixes=${OSH_PRIVATE_SUBNET_POOL} \
    --parameter subnet_pool_default_prefix_length=${OSH_PRIVATE_SUBNET_POOL_DEF_PREFIX} \
    -t ${HEAT_DIR}/heat-subnet-pool-deployment.yaml \
    heat-subnet-pool-deployment

: ${OSH_EXT_NET_NAME:="public"}
: ${OSH_VM_KEY_STACK:="heat-vm-key"}
: ${OSH_PRIVATE_SUBNET:="192.168.128.0/24"}


if [[ ${USE_UBUNTU_IMAGE:="false"} == "true" ]]; then
    IMAGE_ID=$(openstack image list -f value | grep -i "ubuntu" | head -1 | awk '{ print $1 }')
    IMAGE_USER=ubuntu
else
    IMAGE_ID=$(openstack image list -f value | grep -i "cirros" | head -1 | awk '{ print $1 }')
    IMAGE_USER=cirros
fi

# Setup SSH Keypair in Nova
mkdir -p ${SSH_DIR}
openstack keypair show "${OSH_VM_KEY_STACK}" || \
  openstack keypair create --private-key ${SSH_DIR}/osh_key ${OSH_VM_KEY_STACK}
sudo chown $(id -un) ${SSH_DIR}/osh_key
chmod 600 ${SSH_DIR}/osh_key

openstack stack show "heat-basic-vm-deployment" || \
  openstack stack create --wait \
      --parameter public_net=${OSH_EXT_NET_NAME} \
      --parameter image="${IMAGE_ID}" \
      --parameter is_ubuntu=${USE_UBUNTU_IMAGE} \
      --parameter ssh_key=${OSH_VM_KEY_STACK} \
      --parameter cidr=${OSH_PRIVATE_SUBNET} \
      --parameter dns_nameserver=${OSH_BR_EX_ADDR%/*} \
      --parameter dpdk=${DPDK_ENABLED} \
      -t ${HEAT_DIR}/heat-basic-vm-deployment.yaml \
      heat-basic-vm-deployment

FLOATING_IP=$(openstack stack output show \
    heat-basic-vm-deployment \
    floating_ip \
    -f value -c output_value)

INSTANCE_ID=$(openstack stack output show \
    heat-basic-vm-deployment \
    instance_uuid \
    -f value -c output_value)

openstack server show ${INSTANCE_ID}

# accept diffie-hellman-group1-sha1 algo for SSH (for compatibility with older images)
sudo tee -a /etc/ssh/ssh_config <<EOF
    KexAlgorithms +diffie-hellman-group1-sha1
    HostKeyAlgorithms +ssh-rsa
    PubkeyAcceptedKeyTypes +ssh-rsa
EOF

[ ${USE_UBUNTU_IMAGE} == "true" ] \
  && wait_for_ssh_timeout=$(date -d '+900 sec' +%s) \
  || wait_for_ssh_timeout=$(date -d '+300 sec' +%s)

while true; do
    nmap -Pn -p22 ${FLOATING_IP} | awk '$1 ~ /22/ {print $2}' | grep -q 'open' \
        && echo "SSH port is open." \
        && ssh -o "StrictHostKeyChecking no" -i ${SSH_DIR}/osh_key ${IMAGE_USER}@${FLOATING_IP} true \
        && echo "SSH session successfully established" \
        && if [ ${USE_UBUNTU_IMAGE} == "true" ]; then
            ssh -o "StrictHostKeyChecking no" -i ${SSH_DIR}/osh_key ${IMAGE_USER}@${FLOATING_IP} cloud-init status | grep -q 'done' \
            && echo "Cloud-init status is done."
        fi \
        && break \
        || true
    sleep 30
    if [ $(date +%s) -gt $wait_for_ssh_timeout ]; then
        {
            echo "Could not establish ssh session to ${IMAGE_USER}@${FLOATING_IP} in time"
            openstack console log show ${INSTANCE_ID}
            exit 1
        }
    fi
done

# SSH into the VM and check it can reach the outside world
ssh -o "StrictHostKeyChecking no" -i ${SSH_DIR}/osh_key ${IMAGE_USER}@${FLOATING_IP} ping -q -c 1 -W 2 ${OSH_BR_EX_ADDR%/*}

# Check the VM can reach the metadata server
ssh -i ${SSH_DIR}/osh_key ${IMAGE_USER}@${FLOATING_IP} curl --verbose --connect-timeout 5 169.254.169.254

# Check the VM can reach the keystone server
ssh -i ${SSH_DIR}/osh_key ${IMAGE_USER}@${FLOATING_IP} curl --verbose --connect-timeout 5 keystone.openstack.svc.cluster.local

# Check to see if cinder has been deployed, if it has then perform a volume attach.
if openstack service list -f value -c Type | grep -q "^volume"; then
  # Get the devices that are present on the instance
  DEVS_PRE_ATTACH=$(mktemp)
  ssh -i ${SSH_DIR}/osh_key ${IMAGE_USER}@${FLOATING_IP} lsblk > ${DEVS_PRE_ATTACH}

  openstack stack list show "heat-vm-volume-attach" || \
  # Create and attach a block device to the instance
    openstack stack create --wait \
      --parameter instance_uuid=${INSTANCE_ID} \
      -t ${HEAT_DIR}/heat-vm-volume-attach.yaml \
      heat-vm-volume-attach

  # Get the devices that are present on the instance
  DEVS_POST_ATTACH=$(mktemp)
  ssh -i ${SSH_DIR}/osh_key ${IMAGE_USER}@${FLOATING_IP} lsblk > ${DEVS_POST_ATTACH}

  # Check that we have the expected number of extra devices on the instance post attach
  if ! [ "$(comm -13 ${DEVS_PRE_ATTACH} ${DEVS_POST_ATTACH} | wc -l)" -eq "1" ]; then
    echo "Volume not successfully attached"
    exit 1
  fi
fi
