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

: ${OSH_LB_SUBNET:="172.31.0.0/24"}
: ${OSH_LB_SUBNET_START:="172.31.0.2"}
: ${OSH_LB_SUBNET_END="172.31.0.200"}
: ${OSH_LB_AMPHORA_IMAGE_NAME:="amphora-x64-haproxy"}
: ${OSH_AMPHORA_IMAGE_FILE_PATH:=""}

sudo pip3 install python-octaviaclient==1.6.0

# NOTE(hagun.kim): These resources are required to use Octavia service.

# Create Octavia management network and its security group
openstack network create lb-mgmt-net -f value -c id
openstack subnet create --subnet-range $OSH_LB_SUBNET --allocation-pool start=$OSH_LB_SUBNET_START,end=$OSH_LB_SUBNET_END --network lb-mgmt-net lb-mgmt-subnet -f value -c id
openstack security group create lb-mgmt-sec-grp
openstack security group rule create --protocol icmp lb-mgmt-sec-grp
openstack security group rule create --protocol tcp --dst-port 22 lb-mgmt-sec-grp
openstack security group rule create --protocol tcp --dst-port 9443 lb-mgmt-sec-grp

# Create security group for Octavia health manager
openstack security group create lb-health-mgr-sec-grp
openstack security group rule create --protocol udp --dst-port 5555 lb-health-mgr-sec-grp

# Create ports for health manager (octavia-health-manager-port-{KUBE_NODE_NAME})
# octavia-health-manager pod will be run on each controller node as daemonset.
# The pod will create o-hm0 NIC to each controller node.
# Each o-hm0 NIC uses the IP of these ports.
CONTROLLER_IP_PORT_LIST=''
CTRLS=$(kubectl get nodes -l openstack-control-plane=enabled -o name | awk -F"/" '{print $2}')
for node in $CTRLS
do
  PORTNAME=octavia-health-manager-port-$node
  openstack port create --security-group lb-health-mgr-sec-grp --device-owner Octavia:health-mgr --host=$node -c id -f value --network lb-mgmt-net $PORTNAME
  IP=$(openstack port show $PORTNAME -c fixed_ips -f value | awk -F',' '{print $1}' | awk -F'=' '{print $2}' | tr -d \')
  if [ -z $CONTROLLER_IP_PORT_LIST ]; then
    CONTROLLER_IP_PORT_LIST=$IP:5555
  else
    CONTROLLER_IP_PORT_LIST=$CONTROLLER_IP_PORT_LIST,$IP:5555
  fi
done

# Each health manager information should be passed into octavia configuration.
echo $CONTROLLER_IP_PORT_LIST > /tmp/octavia_hm_controller_ip_port_list

# Create a flavor for amphora instance
openstack flavor create --id auto --ram 1024 --disk 2 --vcpus 1 --private m1.amphora

# Create key pair to connect amphora instance via management network
ssh-keygen -b 2048 -t rsa -N '' -f ~/.ssh/octavia_ssh_key
openstack keypair create --public-key ~/.ssh/octavia_ssh_key.pub octavia_ssh_key

# Create amphora image from file. Default is https://tarballs.openstack.org/octavia/test-images/
if [ "$OSH_AMPHORA_IMAGE_FILE_PATH" == "" ]; then
  curl https://tarballs.openstack.org/octavia/test-images/test-only-amphora-x64-haproxy-ubuntu-xenial.qcow2 \
  -o /tmp/test-only-amphora-x64-haproxy-ubuntu-xenial.qcow2

  OSH_AMPHORA_IMAGE_FILE_PATH=/tmp/test-only-amphora-x64-haproxy-ubuntu-xenial.qcow2
fi

OSH_AMPHORA_IMAGE_ID=$(openstack image create -f value -c id \
    --public \
    --container-format=bare \
    --disk-format qcow2 < $OSH_AMPHORA_IMAGE_FILE_PATH \
    $OSH_LB_AMPHORA_IMAGE_NAME)
openstack image set --tag amphora $OSH_AMPHORA_IMAGE_ID
