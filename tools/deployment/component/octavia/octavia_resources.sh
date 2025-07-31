#!/bin/bash

# Copyright 2019 Samsung Electronics Co., Ltd.
#
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

SSH_DIR="${HOME}/.ssh"
OPENSTACK_CLIENT_CONTAINER_EXTRA_ARGS="${OPENSTACK_CLIENT_CONTAINER_EXTRA_ARGS} -v ${SSH_DIR}:${SSH_DIR} -v /tmp:/tmp"
export OPENSTACK_CLIENT_CONTAINER_EXTRA_ARGS

: ${OSH_LB_SUBNET:="172.31.0.0/24"}
: ${OSH_LB_SUBNET_START:="172.31.0.2"}
: ${OSH_LB_SUBNET_END="172.31.0.200"}
: ${OSH_AMPHORA_IMAGE_NAME:="amphora-x64-haproxy-ubuntu-jammy"}
: ${OSH_AMPHORA_IMAGE_FILE:="test-only-amphora-x64-haproxy-ubuntu-jammy.qcow2"}
: ${OSH_AMPHORA_IMAGE_URL:="https://tarballs.opendev.org/openstack/octavia/test-images/test-only-amphora-x64-haproxy-ubuntu-jammy.qcow2"}

# # This is for debugging, to be able to connect via ssh to the amphora instance from the cluster node
# # and make the amphora able to connect to Internet.
# # The /tmp/inventory_default_dev.txt file is created by the deploy-env role and contains
# # the name of the default interface on a node.
# sudo iptables -t nat -I POSTROUTING -o $(cat /tmp/inventory_default_dev.txt) -s ${OSH_LB_SUBNET} -j MASQUERADE
# sudo iptables -t filter -I FORWARD -s ${OSH_LB_SUBNET} -j ACCEPT

# Create Octavia management network and its security group
openstack network show lb-mgmt-net || \
    openstack network create lb-mgmt-net -f value -c id
openstack subnet show lb-mgmt-subnet || \
    openstack subnet create --subnet-range $OSH_LB_SUBNET --allocation-pool start=$OSH_LB_SUBNET_START,end=$OSH_LB_SUBNET_END --network lb-mgmt-net lb-mgmt-subnet -f value -c id
openstack security group show lb-mgmt-sec-grp || \
    { openstack security group create lb-mgmt-sec-grp; \
      openstack security group rule create --protocol icmp lb-mgmt-sec-grp; \
      openstack security group rule create --protocol tcp --dst-port 22 lb-mgmt-sec-grp; \
      openstack security group rule create --protocol tcp --dst-port 9443 lb-mgmt-sec-grp; }

# Create security group for Octavia health manager
openstack security group show lb-health-mgr-sec-grp || \
    { openstack security group create lb-health-mgr-sec-grp; \
      openstack security group rule create --protocol udp --dst-port 5555 lb-health-mgr-sec-grp; }

# Create security group for Octavia worker
openstack security group show lb-worker-sec-grp || \
    { openstack security group create lb-worker-sec-grp; }

# Create ports for health manager (octavia-health-manager-port-{KUBE_NODE_NAME})
# and the same for worker (octavia-worker-port-{KUBE_NODE_NAME})
# octavia-health-manager and octavia-worker pods will be run on each network node as daemonsets.
# The pods will create NICs on each network node attached to lb-mgmt-net.
CONTROLLER_IP_PORT_LIST=''
CTRLS=$(kubectl get nodes -l openstack-network-node=enabled -o name | awk -F"/" '{print $2}')
for node in $CTRLS
do
  PORTNAME=octavia-health-manager-port-$node
  openstack port show $PORTNAME || \
    openstack port create --security-group lb-health-mgr-sec-grp --device-owner Octavia:health-mgr --host=$node -c id -f value --network lb-mgmt-net $PORTNAME
  IP=$(openstack port show $PORTNAME -f json | jq -r  '.fixed_ips[0].ip_address')
  if [ -z $CONTROLLER_IP_PORT_LIST ]; then
    CONTROLLER_IP_PORT_LIST=$IP:5555
  else
    CONTROLLER_IP_PORT_LIST=$CONTROLLER_IP_PORT_LIST,$IP:5555
  fi
  WORKER_PORTNAME=octavia-worker-port-$node
  openstack port show $WORKER_PORTNAME || \
    openstack port create --security-group lb-worker-sec-grp --device-owner Octavia:worker --host=$node -c id -f value --network lb-mgmt-net $WORKER_PORTNAME
  openstack port show $WORKER_PORTNAME -f json | jq -r  '.fixed_ips[0].ip_address'
done

# Each health manager information should be passed into octavia configuration.
echo $CONTROLLER_IP_PORT_LIST > /tmp/octavia_hm_controller_ip_port_list

# Create a flavor for amphora instance
openstack flavor show m1.amphora || \
    openstack flavor create --ram 1024 --disk 3 --vcpus 1 m1.amphora

# Create key pair to connect amphora instance via management network
mkdir -p ${SSH_DIR}
openstack keypair show octavia-key || \
  openstack keypair create --private-key ${SSH_DIR}/octavia_key octavia-key
sudo chown $(id -un) ${SSH_DIR}/octavia_key
chmod 600 ${SSH_DIR}/octavia_key

# accept diffie-hellman-group1-sha1 algo for SSH (for compatibility with older images)
sudo tee -a /etc/ssh/ssh_config <<EOF
    KexAlgorithms +diffie-hellman-group1-sha1
    HostKeyAlgorithms +ssh-rsa
    PubkeyAcceptedKeyTypes +ssh-rsa
EOF

if [ ! -f "/tmp/${OSH_AMPHORA_IMAGE_FILE}" ]; then
  curl --fail -sSL ${OSH_AMPHORA_IMAGE_URL} -o /tmp/${OSH_AMPHORA_IMAGE_FILE}
fi

openstack image show ${OSH_AMPHORA_IMAGE_NAME} || \
    openstack image create -f value -c id \
    --public \
    --container-format=bare \
    --disk-format qcow2 \
    --min-disk 2 \
    --file /tmp/${OSH_AMPHORA_IMAGE_FILE} \
    ${OSH_AMPHORA_IMAGE_NAME}
OSH_AMPHORA_IMAGE_ID=$(openstack image show ${OSH_AMPHORA_IMAGE_NAME} -f value -c id)
openstack image set --tag amphora ${OSH_AMPHORA_IMAGE_ID}
