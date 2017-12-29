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

# Set work dir if not already done
: ${WORK_DIR:="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"}

# Set logs directory
export LOGS_DIR=${LOGS_DIR:-"/tmp/logs"}

# Get Host OS
source /etc/os-release
export HOST_OS=${HOST_OS:="${ID}"}

# Set versions of K8s and Helm to use
export HELM_VERSION=${HELM_VERSION:-"v2.7.2"}
export KUBE_VERSION=${KUBE_VERSION:-"v1.9.0"}

# Set K8s-AIO options
export KUBECONFIG=${KUBECONFIG:="${HOME}/.kubeadm-aio/admin.conf"}
export KUBEADM_IMAGE=${KUBEADM_IMAGE:="openstackhelm/kubeadm-aio:${KUBE_VERSION}"}

# Set K8s network options
export CNI_POD_CIDR=${CNI_POD_CIDR:="192.168.0.0/16"}
export KUBE_CNI=${KUBE_CNI:="calico"}

# Set PVC Backend
export PVC_BACKEND=${PVC_BACKEND:-"ceph"}

# Set Object Storage options
export CEPH_RGW_KEYSTONE_ENABLED=${CEPH_RGW_KEYSTONE_ENABLED:-"true"}
export OPENSTACK_OBJECT_STORAGE=${OPENSTACK_OBJECT_STORAGE:-"radosgw"}

# Set Glance Backend options
export GLANCE=${GLANCE:-"radosgw"}

# Set SDN Plugin
# possible values: ovs, linuxbridge
export SDN_PLUGIN=${SDN_PLUGIN:-"ovs"}

# Set Upstream DNS
export UPSTREAM_DNS1=${UPSTREAM_DNS1:-"8.8.8.8"}
export UPSTREAM_DNS2=${UPSTREAM_DNS2:-"8.8.4.4"}

# Set gate script timeouts
export NODE_START_TIMEOUT=${NODE_START_TIMEOUT:="480"}
export POD_START_TIMEOUT_SYSTEM=${POD_START_TIMEOUT_SYSTEM:="480"}
export POD_START_TIMEOUT_OPENSTACK=${POD_START_TIMEOUT_OPENSTACK:="900"}
export POD_START_TIMEOUT_DEFAULT=${POD_START_TIMEOUT_DEFAULT:="480"}
export POD_START_TIMEOUT_CEPH=${POD_START_TIMEOUT_CEPH:="600"}
export SERVICE_TEST_TIMEOUT=${SERVICE_TEST_TIMEOUT:="600"}

# Setup Loopback device options
export LOOPBACK_CREATE=${LOOPBACK_CREATE:="false"}
export LOOPBACK_DEV_COUNT=${LOOPBACK_DEV_COUNT:="3,3,3"}
export LOOPBACK_SIZES=${LOOPBACK_SIZES:="8192M,1024M,1024M"}
export LOOPBACK_NAMES=${LOOPBACK_NAMES:="cephosd,cephjournal,swift"}
export LOOPBACK_DIR=${LOOPBACK_DIR:="/var/lib/iscsi-loopback"}
export LOOPBACK_LOCAL_DISC_INFO=${LOOPBACK_LOCAL_DISC_INFO:="/tmp/loopback-local-disc-info"}
export LOOPBACK_DEV_INFO=${LOOPBACK_DEV_INFO:="/tmp/loopback-dev-info"}

# Setup Multinode params
export SSH_PRIVATE_KEY=${SSH_PRIVATE_KEY:="/etc/nodepool/id_rsa"}
export PRIMARY_NODE_IP=${PRIMARY_NODE_IP:="$(cat /etc/nodepool/primary_node | tail -1)"}
export SUB_NODE_IPS=${SUB_NODE_IPS:="$(cat /etc/nodepool/sub_nodes)"}
export SUB_NODE_COUNT="$(($(echo ${SUB_NODE_IPS} | wc -w) + 1))"

# Define OpenStack Test Params
export OSH_BR_EX_ADDR=${OSH_BR_EX_ADDR:="172.24.4.1/24"}
export OSH_EXT_SUBNET=${OSH_EXT_SUBNET:="172.24.4.0/24"}
export OSH_EXT_DNS=${OSH_EXT_DNS:="8.8.8.8"}
export OSH_EXT_NET_NAME=${OSH_EXT_NET_NAME:="public"}
export OSH_EXT_SUBNET_NAME=${OSH_EXT_SUBNET_NAME:="public-subnet"}
export OSH_ROUTER=${OSH_ROUTER:="router1"}
export OSH_PRIVATE_NET_NAME=${OSH_PRIVATE_NET_NAME:="private"}
export OSH_PRIVATE_SUBNET=${OSH_PRIVATE_SUBNET:="10.0.0.0/24"}
export OSH_PRIVATE_SUBNET_NAME=${OSH_PRIVATE_SUBNET_NAME:="private-subnet"}
export OSH_PRIVATE_SUBNET_POOL=${OSH_PRIVATE_SUBNET_POOL:="10.0.0.0/8"}
export OSH_PRIVATE_SUBNET_POOL_NAME=${OSH_PRIVATE_SUBNET_POOL_NAME:="shared-default-subnetpool"}
export OSH_PRIVATE_SUBNET_POOL_DEF_PREFIX=${OSH_PRIVATE_SUBNET_POOL_DEF_PREFIX:="24"}
export OSH_VM_FLAVOR=${OSH_VM_FLAVOR:="m1.tiny"}
export OSH_VM_NAME_CLI=${OSH_VM_NAME_CLI:="osh-smoketest"}
export OSH_VM_KEY_CLI=${OSH_VM_KEY_CLI:="osh-smoketest-key"}
export OSH_VOL_NAME_CLI=${OSH_VOL_NAME_CLI:="osh-volume"}
export OSH_VOL_SIZE_CLI=${OSH_VOL_SIZE_CLI:="1"}
export OSH_VOL_TYPE_CLI=${OSH_VOL_TYPE_CLI:="rbd1"}
export OSH_PUB_NET_STACK=${OSH_PUB_NET_STACK:="heat-public-net-deployment"}
export OSH_SUBNET_POOL_STACK=${OSH_SUBNET_POOL_STACK:="heat-subnet-pool-deployment"}
export OSH_BASIC_VM_STACK=${OSH_BASIC_VM_STACK:="heat-basic-vm-deployment"}
export OSH_VM_KEY_STACK=${OSH_VM_KEY_STACK:="heat-vm-key"}
export RALLY_CHART_ENABLED=${RALLY_CHART_ENABLED:="false"}
