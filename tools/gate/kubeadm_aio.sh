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

source ${WORK_DIR}/tools/gate/funcs/network.sh
source ${WORK_DIR}/tools/gate/funcs/kube.sh

kubeadm_aio_reqs_install
sudo docker pull ${KUBEADM_IMAGE} || kubeadm_aio_build

if [ "x$PVC_BACKEND" == "xceph" ]; then
  ceph_kube_controller_manager_replace
fi

kubeadm_aio_launch
