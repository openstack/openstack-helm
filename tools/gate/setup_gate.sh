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
set -ex

export HELM_VERSION=${HELM_VERSION:-"v2.5.1"}
export KUBE_VERSION=${KUBE_VERSION:-"v1.6.8"}
export PVC_BACKEND=${PVC_BACKEND:-"ceph"}
export UPSTREAM_DNS=${UPSTREAM_DNS:-"8.8.8.8"}

export SERVICE_LAUNCH_TIMEOUT=${SERVICE_LAUNCH_TIMEOUT:="600"}
export SERVICE_TEST_TIMEOUT=${SERVICE_TEST_TIMEOUT:="600"}

export KUBECONFIG=${HOME}/.kubeadm-aio/admin.conf
export KUBEADM_IMAGE=openstackhelm/kubeadm-aio:${KUBE_VERSION}

export LOOPBACK_CREATE=${LOOPBACK_CREATE:="false"}
export LOOPBACK_DEVS=${LOOPBACK_DEVS:="3"}
export LOOPBACK_SIZE=${LOOPBACK_SIZE:="500M"}
export LOOPBACK_DIR=${LOOPBACK_DIR:="/var/lib/iscsi-loopback"}

export WORK_DIR=$(pwd)
source /etc/os-release
export HOST_OS=${ID}
source ${WORK_DIR}/tools/gate/funcs/common.sh
source ${WORK_DIR}/tools/gate/funcs/network.sh
source ${WORK_DIR}/tools/gate/funcs/helm.sh

# Setup the logging location: by default use the working dir as the root.
export LOGS_DIR=${LOGS_DIR:-"${WORK_DIR}/logs"}
rm -rf ${LOGS_DIR} || true
mkdir -p ${LOGS_DIR}

function dump_logs () {
  ${WORK_DIR}/tools/gate/dump_logs.sh
}
trap 'dump_logs "$?"' ERR

# Moving the ws-linter here to avoid it blocking all the jobs just for ws
if [ "x$INTEGRATION_TYPE" == "xlinter" ]; then
  bash ${WORK_DIR}/tools/gate/whitespace.sh
fi

# Do the basic node setup for running the gate
gate_base_setup

# We setup the network for pre kube here, to enable cluster restarts on
# development machines
net_resolv_pre_kube
net_hosts_pre_kube

# Setup helm
helm_install
helm_serve
helm_lint

# In the linter, we also run the helm template plugin to get a sanity check
# of the chart without verifying against the k8s API
if [ "x$INTEGRATION_TYPE" == "xlinter" ]; then
  helm_build > ${LOGS_DIR}/helm_build
  helm_plugin_template_install
  helm_template_run
fi

# Setup the K8s Cluster
if [ "x$INTEGRATION" == "xaio" ]; then
 bash ${WORK_DIR}/tools/gate/kubeadm_aio.sh
elif [ "x$INTEGRATION" == "xmulti" ]; then
 bash ${WORK_DIR}/tools/gate/kubeadm_aio.sh
 bash ${WORK_DIR}/tools/gate/setup_gate_worker_nodes.sh
fi

# Deploy OpenStack-Helm
if [ "x$INTEGRATION_TYPE" == "xbasic" ]; then
  bash ${WORK_DIR}/tools/gate/helm_dry_run.sh
  bash ${WORK_DIR}/tools/gate/basic_launch.sh
elif [ "x$INTEGRATION_TYPE" == "xarmada" ]; then
  bash ${WORK_DIR}/tools/gate/armada_launch.sh
fi

if ! [ "x$INTEGRATION_TYPE" == "x" ]; then
  # Run Basic Full Stack Tests
  if [ "x$INTEGRATION" == "xaio" ]; then
   bash ${WORK_DIR}/tools/gate/openstack_aio_launch.sh
  fi
  # Collect all logs from the environment
  bash ${WORK_DIR}/tools/gate/dump_logs.sh 0
fi
