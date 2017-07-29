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

function kube_wait_for_pods {
  # From Kolla-Kubernetes, orginal authors Kevin Fox & Serguei Bezverkhi
  # Default wait timeout is 180 seconds
  set +x
  end=$(date +%s)
  if ! [ -z $2 ]; then
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
          kubectl get pods --namespace $1 -o wide && exit -1
  done
  set -x
}

function kube_wait_for_nodes {
  # Default wait timeout is 180 seconds
  set +x
  end=$(date +%s)
  if ! [ -z $2 ]; then
   end=$((end + $2))
  else
   end=$((end + 180))
  fi
  while true; do
      NUMBER_OF_NODES_EXPECTED=$1
      NUMBER_OF_NODES=$(kubectl get nodes --no-headers -o name | wc -l)
      [ $NUMBER_OF_NODES -eq $NUMBER_OF_NODES_EXPECTED ] && \
          NODES_ONLINE="True" || NODES_ONLINE="False"
      while read SUB_NODE; do
        echo $SUB_NODE | grep -q ^Ready && NODES_READY="True" || NODES_READY="False"
      done < <(kubectl get nodes --no-headers | awk '{ print $2 }')
      [ $NODES_ONLINE == "True" -a $NODES_READY == "True"  ] && \
          break || true
      sleep 5
      now=$(date +%s)
      [ $now -gt $end ] && echo "Nodes Failed to be ready in time." && \
          kubectl get nodes -o wide && exit -1
  done
  set -x
}

function kubeadm_aio_reqs_install {
  if [ "x$HOST_OS" == "xubuntu" ]; then
    sudo apt-get update -y
    sudo apt-get install -y --no-install-recommends -qq \
            docker.io \
            jq
  elif [ "x$HOST_OS" == "xcentos" ]; then
    sudo yum install -y \
            epel-release
    sudo yum install -y \
            docker-latest \
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
            jq
    sudo cp -f /usr/lib/systemd/system/docker-latest.service /etc/systemd/system/docker.service
    sudo sed -i "s|/var/lib/docker-latest|/var/lib/docker|g" /etc/systemd/system/docker.service
    echo "DOCKER_STORAGE_OPTIONS=--storage-driver=overlay2" | sudo tee /etc/sysconfig/docker-latest-storage
    sudo setenforce 0 || true
    sudo systemctl daemon-reload
    sudo systemctl restart docker
  fi

  if CURRENT_KUBECTL_LOC=$(type -p kubectl); then
    CURRENT_KUBECTL_VERSION=$(${CURRENT_KUBECTL_LOC} version --client --short | awk '{ print $NF }' | awk -F '+' '{ print $1 }')
  fi
  [ "x$KUBE_VERSION" == "x$CURRENT_KUBECTL_VERSION" ] || ( \
    TMP_DIR=$(mktemp -d)
    curl -sSL https://storage.googleapis.com/kubernetes-release/release/${KUBE_VERSION}/bin/linux/amd64/kubectl -o ${TMP_DIR}/kubectl
    chmod +x ${TMP_DIR}/kubectl
    sudo mv ${TMP_DIR}/kubectl /usr/local/bin/kubectl
    rm -rf ${TMP_DIR} )
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

function kubeadm_aio_clean {
  sudo docker rm -f kubeadm-aio || true
  sudo docker rm -f kubelet || true
  sudo docker ps -aq | xargs -r -l1 -P16 sudo docker rm -f
  sudo rm -rfv \
      /etc/cni/net.d \
      /etc/kubernetes \
      /var/lib/etcd \
      /var/etcd \
      /var/lib/kubelet/* \
      /run/openvswitch \
      /var/lib/nova \
      ${HOME}/.kubeadm-aio/admin.conf \
      /var/lib/openstack-helm \
      /var/lib/nfs-provisioner || true
}

function ceph_kube_controller_manager_replace {
  sudo docker pull ${CEPH_KUBE_CONTROLLER_MANAGER_IMAGE}
  sudo docker tag ${CEPH_KUBE_CONTROLLER_MANAGER_IMAGE} ${BASE_KUBE_CONTROLLER_MANAGER_IMAGE}
}
