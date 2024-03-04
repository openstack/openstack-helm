#!/bin/bash
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

: "${HELM_VERSION:="v3.6.3"}"
: "${KUBE_VERSION:="v1.26.3"}"
: "${CRICTL_VERSION:="v1.26.0"}"
: "${CRI_DOCKERD_VERSION:="v0.3.1"}"
: "${CRI_DOCKERD_PACKAGE_VERSION:="0.3.1.3-0.ubuntu-focal"}"
: "${MINIKUBE_VERSION:="v1.29.0"}"
: "${CALICO_VERSION:="v3.25"}"
: "${CORE_DNS_VERSION:="v1.9.4"}"
: "${YQ_VERSION:="v4.6.0"}"
: "${KUBE_DNS_IP="10.96.0.10"}"

export DEBCONF_NONINTERACTIVE_SEEN=true
export DEBIAN_FRONTEND=noninteractive

sudo swapoff -a

echo "DefaultLimitMEMLOCK=16384" | sudo tee -a /etc/systemd/system.conf
sudo systemctl daemon-reexec

function configure_resolvconf {
  # here with systemd-resolved disabled, we'll have 2 separate resolv.conf
  # 1 - /run/systemd/resolve/resolv.conf automatically passed by minikube
  # to coredns via kubelet.resolv-conf extra param
  # 2 - /etc/resolv.conf - to be used for resolution on host

  kube_dns_ip="${KUBE_DNS_IP}"
  # keep all nameservers from both resolv.conf excluding local addresses
  old_ns=$(grep -P --no-filename "^nameserver\s+(?!127\.0\.0\.|${kube_dns_ip})" \
           /etc/resolv.conf /run/systemd/resolve/resolv.conf | sort | uniq)

  if [[ -f "/run/systemd/resolve/resolv.conf" ]]; then
    sudo cp --remove-destination /run/systemd/resolve/resolv.conf /etc/resolv.conf
  fi

  sudo systemctl disable systemd-resolved
  sudo systemctl stop systemd-resolved

  # Remove localhost as a nameserver, since we stopped systemd-resolved
  sudo sed -i  "/^nameserver\s\+127.*/d" /etc/resolv.conf

  # Insert kube DNS as first nameserver instead of entirely overwriting /etc/resolv.conf
  grep -q "nameserver ${kube_dns_ip}" /etc/resolv.conf || \
    sudo sed -i -e "1inameserver ${kube_dns_ip}" /etc/resolv.conf

  local dns_servers
  if [ -z "${HTTP_PROXY}" ]; then
    dns_servers="nameserver 8.8.8.8\nnameserver 8.8.4.4\n"
  else
    dns_servers="${old_ns}"
  fi

  grep -q "${dns_servers}" /etc/resolv.conf || \
    echo -e ${dns_servers} | sudo tee -a /etc/resolv.conf

  grep -q "${dns_servers}" /run/systemd/resolve/resolv.conf || \
    echo -e ${dns_servers} | sudo tee /run/systemd/resolve/resolv.conf

  local search_options='search svc.cluster.local cluster.local'
  grep -q "${search_options}" /etc/resolv.conf || \
    echo "${search_options}" | sudo tee -a /etc/resolv.conf

  grep -q "${search_options}" /run/systemd/resolve/resolv.conf || \
    echo "${search_options}" | sudo tee -a /run/systemd/resolve/resolv.conf

  local dns_options='options ndots:5 timeout:1 attempts:1'
  grep -q "${dns_options}" /etc/resolv.conf || \
    echo ${dns_options} | sudo tee -a /etc/resolv.conf

  grep -q "${dns_options}" /run/systemd/resolve/resolv.conf || \
    echo ${dns_options} | sudo tee -a /run/systemd/resolve/resolv.conf
}

# NOTE: Clean Up hosts file
sudo sed -i '/^127.0.0.1/c\127.0.0.1 localhost localhost.localdomain localhost4localhost4.localdomain4' /etc/hosts
sudo sed -i '/^::1/c\::1 localhost6 localhost6.localdomain6' /etc/hosts
if ! grep -qF "127.0.1.1" /etc/hosts; then
  echo "127.0.1.1 $(hostname)" | sudo tee -a /etc/hosts
fi
configure_resolvconf

# shellcheck disable=SC1091
. /etc/os-release

# NOTE: Add docker repo
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
sudo add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) \
  stable"

# NOTE: Configure docker
docker_resolv="/run/systemd/resolve/resolv.conf"
docker_dns_list="$(awk '/^nameserver/ { printf "%s%s",sep,"\"" $NF "\""; sep=", "} END{print ""}' "${docker_resolv}")"

sudo -E mkdir -p /etc/docker
sudo -E tee /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2",
  "live-restore": true,
  "dns": [${docker_dns_list}]
}
EOF

if [ -n "${HTTP_PROXY}" ]; then
  sudo mkdir -p /etc/systemd/system/docker.service.d
  cat <<EOF | sudo -E tee /etc/systemd/system/docker.service.d/http-proxy.conf
[Service]
Environment="HTTP_PROXY=${HTTP_PROXY}"
Environment="HTTPS_PROXY=${HTTPS_PROXY}"
Environment="NO_PROXY=${NO_PROXY}"
EOF
fi

# Install required packages for K8s on host
wget -q -O- 'https://download.ceph.com/keys/release.asc' | sudo apt-key add -
RELEASE_NAME=$(grep 'CODENAME' /etc/lsb-release | awk -F= '{print $2}')
sudo add-apt-repository "deb https://download.ceph.com/debian-18.2.1/
${RELEASE_NAME} main"

sudo -E apt-get update
sudo -E apt-get install -y \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  socat \
  jq \
  util-linux \
  bridge-utils \
  iptables \
  conntrack \
  libffi-dev \
  ipvsadm \
  make \
  bc \
  git-review \
  notary \
  ceph-common \
  rbd-nbd \
  nfs-common \
  ethtool

sudo -E tee /etc/modprobe.d/rbd.conf << EOF
install rbd /bin/true
EOF

# Prepare tmpfs for etcd when running on CI
# CI VMs can have slow I/O causing issues for etcd
# Only do this on CI (when user is zuul), so that local development can have a kubernetes
# environment that will persist on reboot since etcd data will stay intact
if [ "$USER" = "zuul" ]; then
  sudo mkdir -p /var/lib/minikube/etcd
  sudo mount -t tmpfs -o size=512m tmpfs /var/lib/minikube/etcd
fi

# Install YQ
wget https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64.tar.gz -O - | tar xz && sudo mv yq_linux_amd64 /usr/local/bin/yq

# Install minikube and kubectl
URL="https://storage.googleapis.com"
sudo -E curl -sSLo /usr/local/bin/minikube "${URL}"/minikube/releases/"${MINIKUBE_VERSION}"/minikube-linux-amd64
sudo -E curl -sSLo /usr/local/bin/kubectl "${URL}"/kubernetes-release/release/"${KUBE_VERSION}"/bin/linux/amd64/kubectl
sudo -E chmod +x /usr/local/bin/minikube
sudo -E chmod +x /usr/local/bin/kubectl


# Install cri-dockerd
# from https://github.com/Mirantis/cri-dockerd/releases
CRI_TEMP_DIR=$(mktemp -d)
pushd "${CRI_TEMP_DIR}"
wget https://github.com/Mirantis/cri-dockerd/releases/download/${CRI_DOCKERD_VERSION}/cri-dockerd_${CRI_DOCKERD_PACKAGE_VERSION}_amd64.deb
sudo dpkg -i "cri-dockerd_${CRI_DOCKERD_PACKAGE_VERSION}_amd64.deb"
sudo dpkg --configure -a
popd
if [ -d "${CRI_TEMP_DIR}" ]; then
  rm -rf mkdir "${CRI_TEMP_DIR}"
fi

# Install cri-tools
wget https://github.com/kubernetes-sigs/cri-tools/releases/download/${CRICTL_VERSION}/crictl-${CRICTL_VERSION}-linux-amd64.tar.gz
sudo tar zxvf "crictl-${CRICTL_VERSION}-linux-amd64.tar.g"z -C /usr/local/bin
rm -f "crictl-${CRICTL_VERSION}-linux-amd64.tar.gz"


# Install Helm
TMP_DIR=$(mktemp -d)
sudo -E bash -c \
  "curl -sSL https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz | tar -zxv --strip-components=1 -C ${TMP_DIR}"
sudo -E mv "${TMP_DIR}"/helm /usr/local/bin/helm
rm -rf "${TMP_DIR}"

# NOTE: Deploy kubernetes using minikube. A CNI that supports network policy is
# required for validation; use calico for simplicity.
sudo -E minikube config set kubernetes-version "${KUBE_VERSION}"
sudo -E minikube config set vm-driver none

# NOTE: set RemoveSelfLink to false, to enable it as it is required by the ceph-rbd-provisioner.
# SelfLinks were deprecated in k8s v1.16, and in k8s v1.20, they are
# disabled by default.
# https://github.com/kubernetes/enhancements/issues/1164
export CHANGE_MINIKUBE_NONE_USER=true
export MINIKUBE_IN_STYLE=false

set +e
api_server_status="$(set +e; sudo -E minikube status --format='{{.APIServer}}')"
set -e
echo "Minikube api server status is \"${api_server_status}\""
if [[ "${api_server_status}" != "Running" ]]; then
  sudo -E minikube start \
    --docker-env HTTP_PROXY="${HTTP_PROXY}" \
    --docker-env HTTPS_PROXY="${HTTPS_PROXY}" \
    --docker-env NO_PROXY="${NO_PROXY},10.96.0.0/12" \
    --network-plugin=cni \
    --wait=apiserver,system_pods \
    --apiserver-names="$(hostname -f)" \
    --extra-config=controller-manager.allocate-node-cidrs=true \
    --extra-config=controller-manager.cluster-cidr=192.168.0.0/16 \
    --extra-config=kube-proxy.mode=ipvs \
    --extra-config=apiserver.service-node-port-range=1-65535 \
    --embed-certs
fi

sudo -E systemctl enable --now kubelet

sudo -E minikube addons list

curl -LSs https://docs.projectcalico.org/archive/"${CALICO_VERSION}"/manifests/calico.yaml -o /tmp/calico.yaml

sed -i -e 's#docker.io/calico/#quay.io/calico/#g' /tmp/calico.yaml

# Download images needed for calico before applying manifests, so that `kubectl wait` timeout
# for `k8s-app=kube-dns` isn't reached by slow download speeds
awk '/image:/ { print $2 }' /tmp/calico.yaml | xargs -I{} sudo docker pull {}

kubectl apply -f /tmp/calico.yaml

# Note: Patch calico daemonset to enable Prometheus metrics and annotations
tee /tmp/calico-node.yaml << EOF
spec:
  template:
    metadata:
      annotations:
        prometheus.io/scrape: "true"
        prometheus.io/port: "9091"
    spec:
      containers:
        - name: calico-node
          env:
            - name: FELIX_PROMETHEUSMETRICSENABLED
              value: "true"
            - name: FELIX_PROMETHEUSMETRICSPORT
              value: "9091"
            - name: FELIX_IGNORELOOSERPF
              value: "true"
EOF
kubectl -n kube-system patch daemonset calico-node --patch "$(cat /tmp/calico-node.yaml)"

kubectl get pod -A
kubectl -n kube-system get pod -l k8s-app=kube-dns

# NOTE: Wait for dns to be running.
END=$(($(date +%s) + 240))
until kubectl --namespace=kube-system \
        get pods -l k8s-app=kube-dns --no-headers -o name | grep -q "^pod/coredns"; do
  NOW=$(date +%s)
  [ "${NOW}" -gt "${END}" ] && exit 1
  echo "still waiting for dns"
  sleep 10
done
kubectl -n kube-system wait --timeout=240s --for=condition=Ready pods -l k8s-app=kube-dns

# Validate DNS now to save a lot of headaches later
sleep 5
if ! dig svc.cluster.local ${KUBE_DNS_IP} | grep ^cluster.local. >& /dev/null; then
  echo k8s DNS Failure. Are you sure you disabled systemd-resolved before running this script?
  exit 1
fi

# Remove stable repo, if present, to improve build time
helm repo remove stable || true

# Add labels to the core namespaces & nodes
kubectl label --overwrite namespace default name=default
kubectl label --overwrite namespace kube-system name=kube-system
kubectl label --overwrite namespace kube-public name=kube-public
kubectl label --overwrite nodes --all openstack-control-plane=enabled
kubectl label --overwrite nodes --all openstack-compute-node=enabled
kubectl label --overwrite nodes --all openvswitch=enabled
kubectl label --overwrite nodes --all linuxbridge=enabled
kubectl label --overwrite nodes --all ceph-mon=enabled
kubectl label --overwrite nodes --all ceph-osd=enabled
kubectl label --overwrite nodes --all ceph-mds=enabled
kubectl label --overwrite nodes --all ceph-rgw=enabled
kubectl label --overwrite nodes --all ceph-mgr=enabled

for NAMESPACE in ceph openstack osh-infra; do
tee /tmp/${NAMESPACE}-ns.yaml << EOF
apiVersion: v1
kind: Namespace
metadata:
  labels:
    kubernetes.io/metadata.name: ${NAMESPACE}
    name: ${NAMESPACE}
  name: ${NAMESPACE}
EOF

kubectl apply -f /tmp/${NAMESPACE}-ns.yaml
done

# Update CoreDNS and enable recursive queries
PATCH=$(mktemp)
kubectl get configmap coredns -n kube-system -o json | jq -r "{data: .data}"  | sed 's/ready\\n/header \{\\n        response set ra\\n    \}\\n    ready\\n/g' > "${PATCH}"
kubectl patch configmap coredns -n kube-system --patch-file "${PATCH}"
kubectl set image deployment coredns -n kube-system "coredns=registry.k8s.io/coredns/coredns:${CORE_DNS_VERSION}"
rm -f "${PATCH}"
kubectl rollout restart -n kube-system deployment/coredns

make all
