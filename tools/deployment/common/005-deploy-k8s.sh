#!/bin/bash

# Copyright 2017 The Openstack-Helm Authors.
# Copyright 2019, AT&T Intellectual Property
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

: ${HELM_VERSION:="v2.13.0"}
: ${KUBE_VERSION:="v1.12.2"}
: ${MINIKUBE_VERSION:="v0.30.0"}
: ${CALICO_VERSION:="v3.3"}

: "${HTTP_PROXY:=""}"
: "${HTTPS_PROXY:=""}"

export DEBCONF_NONINTERACTIVE_SEEN=true
export DEBIAN_FRONTEND=noninteractive

function configure_resolvconf {
  # Setup resolv.conf to use the k8s api server, which is required for the
  # kubelet to resolve cluster services.
  sudo mv /etc/resolv.conf /etc/resolv.conf.backup

  sudo bash -c "echo 'search svc.cluster.local cluster.local' > /etc/resolv.conf"
  sudo bash -c "echo 'nameserver 10.96.0.10' >> /etc/resolv.conf"

  # NOTE(drewwalters96): Use the Google DNS servers to prevent local addresses in
  # the resolv.conf file unless using a proxy, then use the existing DNS servers,
  # as custom DNS nameservers are commonly required when using a proxy server.
  if [ -z "${HTTP_PROXY}" ]; then
    sudo bash -c "echo 'nameserver 8.8.8.8' >> /etc/resolv.conf"
    sudo bash -c "echo 'nameserver 8.8.4.4' >> /etc/resolv.conf"
  else
    sed -ne "s/nameserver //p" /etc/resolv.conf.backup | while read -r ns; do
      sudo bash -c "echo 'nameserver ${ns}' >> /etc/resolv.conf"
    done
  fi

  sudo bash -c "echo 'options ndots:5 timeout:1 attempts:1' >> /etc/resolv.conf"
  sudo rm /etc/resolv.conf.backup
}

# NOTE: Clean Up hosts file
sudo sed -i '/^127.0.0.1/c\127.0.0.1 localhost localhost.localdomain localhost4localhost4.localdomain4' /etc/hosts
sudo sed -i '/^::1/c\::1 localhost6 localhost6.localdomain6' /etc/hosts

# Install required packages for K8s on host
sudo apt-key adv --keyserver keyserver.ubuntu.com  --recv 460F3994
RELEASE_NAME=$(grep 'CODENAME' /etc/lsb-release | awk -F= '{print $2}')
#NOTE (srwilkers): Use the luminous repository until the issues with the mimic
# repository are sorted out
sudo add-apt-repository "deb https://download.ceph.com/debian-luminous/
${RELEASE_NAME} main"
sudo -E apt-get update
# NOTE(srwilkers): Pin docker version to validated docker version for k8s 1.12.2
sudo -E apt-get install -y \
    docker.io=18.06.1-0ubuntu1.2~16.04.1 \
    socat \
    jq \
    util-linux \
    ceph-common \
    rbd-nbd \
    nfs-common \
    bridge-utils \
    libxtables11

sudo -E tee /etc/modprobe.d/rbd.conf << EOF
install rbd /bin/true
EOF

configure_resolvconf

# Install minikube and kubectl
URL="https://storage.googleapis.com"
sudo -E curl -sSLo /usr/local/bin/minikube \
  "${URL}"/minikube/releases/"${MINIKUBE_VERSION}"/minikube-linux-amd64

sudo -E curl -sSLo /usr/local/bin/kubectl \
  "${URL}"/kubernetes-release/release/"${KUBE_VERSION}"/bin/linux/amd64/kubectl

sudo -E chmod +x /usr/local/bin/minikube
sudo -E chmod +x /usr/local/bin/kubectl

# Install Helm
TMP_DIR=$(mktemp -d)
sudo -E bash -c \
  "curl -sSL ${URL}/kubernetes-helm/helm-${HELM_VERSION}-linux-amd64.tar.gz | \
    tar -zxv --strip-components=1 -C ${TMP_DIR}"

sudo -E mv "${TMP_DIR}"/helm /usr/local/bin/helm
rm -rf "${TMP_DIR}"

# NOTE: Deploy kubenetes using minikube. A CNI that supports network policy is
# required for validation; use calico for simplicity.
sudo -E minikube config set embed-certs true
sudo -E minikube config set kubernetes-version "${KUBE_VERSION}"
sudo -E minikube config set vm-driver none
sudo -E minikube addons disable addon-manager
sudo -E minikube addons disable dashboard

export CHANGE_MINIKUBE_NONE_USER=true
sudo -E minikube start \
  --docker-env HTTP_PROXY="${HTTP_PROXY}" \
  --docker-env HTTPS_PROXY="${HTTPS_PROXY}" \
  --docker-env NO_PROXY="${NO_PROXY},10.96.0.0/12" \
  --extra-config=kubelet.network-plugin=cni \
  --extra-config=controller-manager.allocate-node-cidrs=true \
  --extra-config=controller-manager.cluster-cidr=192.168.0.0/16

kubectl apply -f \
  https://docs.projectcalico.org/"${CALICO_VERSION}"/getting-started/kubernetes/installation/hosted/rbac-kdd.yaml
kubectl apply -f \
  https://docs.projectcalico.org/"${CALICO_VERSION}"/getting-started/kubernetes/installation/hosted/kubernetes-datastore/calico-networking/1.7/calico.yaml

# NOTE: Wait for node to be ready.
kubectl wait --timeout=240s --for=condition=Ready nodes/minikube

# NOTE: Wait for dns to be running.
END=$(($(date +%s) + 240))
until kubectl --namespace=kube-system \
        get pods -l k8s-app=kube-dns --no-headers -o name | grep -q "^pod/coredns"; do
  NOW=$(date +%s)
  [ "${NOW}" -gt "${END}" ] && exit 1
  echo "still waiting for dns"
  sleep 10
done
kubectl --namespace=kube-system wait --timeout=240s --for=condition=Ready pods -l k8s-app=kube-dns

# Deploy helm/tiller into the cluster
kubectl create -n kube-system serviceaccount helm-tiller
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: helm-tiller
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  - kind: ServiceAccount
    name: helm-tiller
    namespace: kube-system
EOF

helm init --service-account helm-tiller

kubectl --namespace=kube-system wait \
  --timeout=240s \
  --for=condition=Ready \
  pod -l app=helm,name=tiller

# Set up local helm server
sudo -E tee /etc/systemd/system/helm-serve.service << EOF
[Unit]
Description=Helm Server
After=network.target

[Service]
User=$(id -un 2>&1)
Restart=always
ExecStart=/usr/local/bin/helm serve

[Install]
WantedBy=multi-user.target
EOF

sudo chmod 0640 /etc/systemd/system/helm-serve.service

sudo systemctl daemon-reload
sudo systemctl restart helm-serve
sudo systemctl enable helm-serve

# Set up local helm repo
helm repo add local http://localhost:8879/charts
helm repo update
make

# Set required labels on host(s)
kubectl label nodes --all openstack-control-plane=enabled
kubectl label nodes --all openstack-compute-node=enabled
kubectl label nodes --all openvswitch=enabled
kubectl label nodes --all linuxbridge=enabled
kubectl label nodes --all ceph-mon=enabled
kubectl label nodes --all ceph-osd=enabled
kubectl label nodes --all ceph-mds=enabled
kubectl label nodes --all ceph-rgw=enabled
kubectl label nodes --all ceph-mgr=enabled
