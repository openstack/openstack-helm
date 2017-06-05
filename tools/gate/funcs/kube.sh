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
set -e

function kube_wait_for_pods {
  # From Kolla-Kubernetes, orginal authors Kevin Fox & Serguei Bezverkhi
  # Default wait timeout is 180 seconds
  set +x
  end=$(date +%s)
  if [ x$2 != "x" ]; then
   end=$((end + $2))
  else
   end=$((end + 180))
  fi
  while true; do
      kubectl get pods --namespace=$1 -o json | jq -r \
          '.items[].status.phase' | grep Pending > /dev/null && \
          PENDING=True || PENDING=False
      query='.items[]|select(.status.phase=="Running")'
      query="$query|.status.containerStatuses[].ready"
      kubectl get pods --namespace=$1 -o json | jq -r "$query" | \
          grep false > /dev/null && READY="False" || READY="True"
      kubectl get jobs -o json --namespace=$1 | jq -r \
          '.items[] | .spec.completions == .status.succeeded' | \
          grep false > /dev/null && JOBR="False" || JOBR="True"
      [ $PENDING == "False" -a $READY == "True" -a $JOBR == "True" ] && \
          break || true
      sleep 1
      now=$(date +%s)
      [ $now -gt $end ] && echo containers failed to start. && \
          kubectl get pods --namespace $1 && exit -1
  done
  set -x
}

function kubeadm_aio_reqs_install {
  TMP_DIR=$(mktemp -d)
  if [ "x$HOST_OS" == "xubuntu" ]; then
    sudo apt-get update -y
    sudo apt-get install -y --no-install-recommends -qq \
            docker.io \
            nfs-common \
            jq
  elif [ "x$HOST_OS" == "xcentos" ]; then
    sudo yum install -y \
            epel-release
    sudo yum install -y \
            docker-latest \
            nfs-utils \
            jq
    sudo cp -f /usr/lib/systemd/system/docker-latest.service /etc/systemd/system/docker.service
    sudo sed -i "s|/var/lib/docker-latest|/var/lib/docker|g" /etc/systemd/system/docker.service
    sudo sed -i 's/^OPTIONS/#OPTIONS/g' /etc/sysconfig/docker-latest
    sudo sed -i "s|^MountFlags=slave|MountFlags=share|g" /etc/systemd/system/docker.service
    sudo sed -i "/--seccomp-profile/,+1 d" /etc/systemd/system/docker.service
    echo "DOCKER_STORAGE_OPTIONS=--storage-driver=overlay" | sudo tee /etc/sysconfig/docker-latest-storage
    sudo setenforce 0 || true
    sudo systemctl daemon-reload
    sudo systemctl restart docker
  elif [ "x$HOST_OS" == "xfedora" ]; then
    sudo dnf install -y \
            docker-latest \
            nfs-utils \
            jq
    sudo cp -f /usr/lib/systemd/system/docker-latest.service /etc/systemd/system/docker.service
    sudo sed -i "s|/var/lib/docker-latest|/var/lib/docker|g" /etc/systemd/system/docker.service
    echo "DOCKER_STORAGE_OPTIONS=--storage-driver=overlay2" | sudo tee /etc/sysconfig/docker-latest-storage
    sudo setenforce 0 || true
    sudo systemctl daemon-reload
    sudo systemctl restart docker
  fi

  curl -sSL https://storage.googleapis.com/kubernetes-release/release/${KUBE_VERSION}/bin/linux/amd64/kubectl -o ${TMP_DIR}/kubectl
  chmod +x ${TMP_DIR}/kubectl
  sudo mv ${TMP_DIR}/kubectl /usr/local/bin/kubectl

  rm -rf ${TMP_DIR}
}

function kubeadm_aio_build {
  sudo docker build --pull -t ${KUBEADM_IMAGE} tools/kubeadm-aio
}

function kubeadm_aio_launch {
  ${WORK_DIR}/tools/kubeadm-aio/kubeadm-aio-launcher.sh
  mkdir -p ${HOME}/.kube
  cat ${KUBECONFIG} > ${HOME}/.kube/config
  kube_wait_for_pods kube-system 240
  kube_wait_for_pods default 240
}
