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

: ${SSH_PRIVATE_KEY:="/etc/nodepool/id_rsa"}
sudo chown $(whoami) ${SSH_PRIVATE_KEY}
sudo chmod 600 ${SSH_PRIVATE_KEY}


PRIMARY_NODE_IP=$(cat /etc/nodepool/primary_node_private | tail -1)
KUBEADM_TOKEN=$(sudo docker exec kubeadm-aio kubeadm token list | tail -n -1 | awk '{ print $1 }')

NODE_2=$(cat /etc/nodepool/sub_nodes_private | tail -1)

ssh-keyscan "${NODE_2}" >> ~/.ssh/known_hosts
ssh -i ${SSH_PRIVATE_KEY} $(whoami)@${NODE_2} mkdir -p ${WORK_DIR%/*}
scp -i ${SSH_PRIVATE_KEY} -r ${WORK_DIR} $(whoami)@${NODE_2}:${WORK_DIR%/*}
ssh -i ${SSH_PRIVATE_KEY} $(whoami)@${NODE_2} "export WORK_DIR=${WORK_DIR}; export KUBEADM_TOKEN=${KUBEADM_TOKEN}; export PRIMARY_NODE_IP=${PRIMARY_NODE_IP}; export KUBEADM_IMAGE=${KUBEADM_IMAGE}; bash ${WORK_DIR}/tools/gate/provision_gate_worker_node.sh"

sleep 120
source ${WORK_DIR}/tools/gate/funcs/kube.sh
kube_wait_for_pods kube-system 240
kubectl get nodes --show-all
kubectl get --all-namespaces all --show-all
sudo docker exec kubeadm-aio openstack-helm-dev-prep
