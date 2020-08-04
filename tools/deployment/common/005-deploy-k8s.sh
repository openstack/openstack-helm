#!/bin/bash

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

: ${MINIKUBE_AIO:="docker.io/openstackhelm/minikube-aio:latest-ubuntu_bionic"}

export DEBCONF_NONINTERACTIVE_SEEN=true
export DEBIAN_FRONTEND=noninteractive

# Install required packages for K8s on host
wget -q -O- 'https://download.ceph.com/keys/release.asc' | sudo apt-key add -
RELEASE_NAME=$(grep 'CODENAME' /etc/lsb-release | awk -F= '{print $2}')
sudo add-apt-repository "deb https://download.ceph.com/debian-nautilus/
${RELEASE_NAME} main"
sudo -E apt-get update
sudo -E apt-get install -y \
    docker.io

# Starting to pull early in parallel
sudo -E docker pull -q ${MINIKUBE_AIO} &

sudo -E apt-get install -y \
    socat \
    jq \
    util-linux \
    ceph-common \
    rbd-nbd \
    nfs-common \
    bridge-utils \
    iptables

sudo -E tee /etc/modprobe.d/rbd.conf << EOF
install rbd /bin/true
EOF

set +x;
# give 2 minutes to pull the image (usually takes less than 30-60s) and proceed. If something bad
# happens we'll see it on 'docker create'
echo "Waiting for ${MINIKUBE_AIO} image is pulled"
i=0
while [ "$i" -le "60" ]; do
  (( ++i ))
  sudo docker inspect ${MINIKUBE_AIO} && break || sleep 2;
done &> /dev/null; set -x
TMP_DIR=$(mktemp -d)
sudo docker create --name minikube-aio ${MINIKUBE_AIO} bash
sudo docker export minikube-aio | tar x -C ${TMP_DIR}
sudo docker rm minikube-aio
sudo docker rmi ${MINIKUBE_AIO}
${TMP_DIR}/install.sh
rm ${TMP_DIR} -rf

make
