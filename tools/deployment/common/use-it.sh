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
openstack stack show "heat-public-net-deployment" || \
  openstack stack create --wait \
    --parameter network_name=${OSH_EXT_NET_NAME} \
    --parameter physical_network_name=public \
    --parameter subnet_name=${OSH_EXT_SUBNET_NAME} \
    --parameter subnet_cidr=${OSH_EXT_SUBNET} \
    --parameter subnet_gateway=${OSH_BR_EX_ADDR%/*} \
    -t ${HEAT_DIR}/heat-public-net-deployment.yaml \
    heat-public-net-deployment

: ${OSH_PRIVATE_SUBNET_POOL:="10.0.0.0/8"}
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
: ${OSH_PRIVATE_SUBNET:="10.0.0.0/24"}
# NOTE(portdirect): We do this fancy, and seemingly pointless, footwork to get
# the full image name for the cirros Image without having to be explicit.
IMAGE_NAME=$(openstack image show -f value -c name \
  $(openstack image list -f csv | awk -F ',' '{ print $2 "," $1 }' | \
    grep "^\"Cirros" | head -1 | awk -F ',' '{ print $2 }' | tr -d '"'))

# Setup SSH Keypair in Nova
mkdir -p ${SSH_DIR}

openstack keypair show "${OSH_VM_KEY_STACK}" || \
  openstack keypair create --private-key ${SSH_DIR}/osh_key ${OSH_VM_KEY_STACK}
sudo chown $(id -un) ${SSH_DIR}/osh_key
chmod 600 ${SSH_DIR}/osh_key

openstack stack show "heat-basic-vm-deployment" || \
  openstack stack create --wait \
      --parameter public_net=${OSH_EXT_NET_NAME} \
      --parameter image="${IMAGE_NAME}" \
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

function wait_for_ssh_port {
  # Default wait timeout is 300 seconds
  set +x
  end=$(date +%s)
  if ! [ -z $2 ]; then
   end=$((end + $2))
  else
   end=$((end + 300))
  fi
  while true; do
      # Use Nmap as its the same on Ubuntu and RHEL family distros
      nmap -Pn -p22 $1 | awk '$1 ~ /22/ {print $2}' | grep -q 'open' && \
          break || true
      sleep 1
      now=$(date +%s)
      [ $now -gt $end ] && echo "Could not connect to $1 port 22 in time" && exit -1
  done
  set -x
}
wait_for_ssh_port $FLOATING_IP

# accept diffie-hellman-group1-sha1 algo for SSH (cirros image should probably be updated to replace this)
sudo tee -a /etc/ssh/ssh_config <<EOF
    KexAlgorithms +diffie-hellman-group1-sha1
    HostKeyAlgorithms +ssh-rsa
    PubkeyAcceptedKeyTypes +ssh-rsa
EOF

# SSH into the VM and check it can reach the outside world
# note: ssh-keyscan should be re-enabled to prevent skip host key checking
#   ssh-keyscan does not use ssh_config so ignore host key checking for now
#ssh-keyscan "$FLOATING_IP" >> ~/.ssh/known_hosts
ssh -o "StrictHostKeyChecking no" -i ${SSH_DIR}/osh_key cirros@${FLOATING_IP} ping -q -c 1 -W 2 ${OSH_BR_EX_ADDR%/*}

# Check the VM can reach the metadata server
ssh -i ${SSH_DIR}/osh_key cirros@${FLOATING_IP} curl --verbose --connect-timeout 5 169.254.169.254

# Check the VM can reach the keystone server
ssh -i ${SSH_DIR}/osh_key cirros@${FLOATING_IP} curl --verbose --connect-timeout 5 keystone.openstack.svc.cluster.local

# Check to see if cinder has been deployed, if it has then perform a volume attach.
if openstack service list -f value -c Type | grep -q "^volume"; then
  # Get the devices that are present on the instance
  DEVS_PRE_ATTACH=$(mktemp)
  ssh -i ${SSH_DIR}/osh_key cirros@${FLOATING_IP} lsblk > ${DEVS_PRE_ATTACH}

  openstack stack list show "heat-vm-volume-attach" || \
  # Create and attach a block device to the instance
    openstack stack create --wait \
      --parameter instance_uuid=${INSTANCE_ID} \
      -t ${HEAT_DIR}/heat-vm-volume-attach.yaml \
      heat-vm-volume-attach

  # Get the devices that are present on the instance
  DEVS_POST_ATTACH=$(mktemp)
  ssh -i ${SSH_DIR}/osh_key cirros@${FLOATING_IP} lsblk > ${DEVS_POST_ATTACH}

  # Check that we have the expected number of extra devices on the instance post attach
  if ! [ "$(comm -13 ${DEVS_PRE_ATTACH} ${DEVS_POST_ATTACH} | wc -l)" -eq "1" ]; then
    echo "Volume not successfully attached"
    exit 1
  fi
fi
