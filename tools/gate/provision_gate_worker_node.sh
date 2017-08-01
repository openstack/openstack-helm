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

cd ${WORK_DIR}
source /etc/os-release
export HOST_OS=${ID}
source ${WORK_DIR}/tools/gate/funcs/common.sh
source ${WORK_DIR}/tools/gate/funcs/network.sh
source ${WORK_DIR}/tools/gate/funcs/kube.sh

# Do the basic node setup for running the gate
gate_base_setup

# Install KubeadmAIO requirements and get image
kubeadm_aio_reqs_install
sudo docker pull ${KUBEADM_IMAGE} || kubeadm_aio_build

# Setup shared mounts for kubelet
sudo mkdir -p /var/lib/kubelet
sudo mount --bind /var/lib/kubelet /var/lib/kubelet
sudo mount --make-shared /var/lib/kubelet

# Clean up any old install
kubeadm_aio_clean

# Launch Container
sudo docker run \
    -dt \
    --name=kubeadm-aio \
    --net=host \
    --security-opt=seccomp:unconfined \
    --cap-add=SYS_ADMIN \
    --tmpfs=/run \
    --tmpfs=/run/lock \
    --volume=/etc/machine-id:/etc/machine-id:ro \
    --volume=${HOME}:${HOME}:rw \
    --volume=/etc/kubernetes:/etc/kubernetes:rw \
    --volume=/sys/fs/cgroup:/sys/fs/cgroup:ro \
    --volume=/var/run/docker.sock:/run/docker.sock \
    --env KUBE_ROLE="worker" \
    --env KUBELET_CONTAINER="${KUBEADM_IMAGE}" \
    --env KUBEADM_JOIN_ARGS="--token=${KUBEADM_TOKEN} ${PRIMARY_NODE_IP}:6443" \
    ${KUBEADM_IMAGE}
