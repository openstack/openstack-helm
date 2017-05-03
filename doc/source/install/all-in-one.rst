==========
All-in-one
==========


LOCAL_IP=$(ip addr | awk '/inet/ && /eth0/{sub(/\/.*$/,"",$2); print $2}')
cat << EOF | sudo tee -a /etc/hosts
${LOCAL_IP} $(hostname)
EOF
sudo apt-get update -y
sudo apt-get install -y \
        docker.io \
        nfs-common \
        git \
        make
KUBE_VERSION=v1.6.0
HELM_VERSION=v2.3.0
TMP_DIR=$(mktemp -d)
curl -sSL https://storage.googleapis.com/kubernetes-release/release/${KUBE_VERSION}/bin/linux/amd64/kubectl -o ${TMP_DIR}/kubectl
chmod +x ${TMP_DIR}/kubectl
sudo mv ${TMP_DIR}/kubectl /usr/local/bin/kubectl
curl -sSL https://storage.googleapis.com/kubernetes-helm/helm-${HELM_VERSION}-linux-amd64.tar.gz | tar -zxv --strip-components=1 -C ${TMP_DIR}
sudo mv ${TMP_DIR}/helm /usr/local/bin/helm
rm -rf ${TMP_DIR}
# Clone the project:
git clone https://github.com/openstack/openstack-helm.git && cd openstack-helm
# Start a local Helm Server:
helm init --client-only
helm serve &
helm repo add local http://localhost:8879/charts
helm repo remove stable
# Package the Openstack-Helm Charts, and push them to your local Helm repository:
make
# Build the Kubeadm-AIO Container
export KUBEADM_IMAGE=openstack-helm/kubeadm-aio:v1.6
sudo docker build --pull -t ${KUBEADM_IMAGE} tools/kubeadm-aio
export KUBE_VERSION=v1.6.2
./tools/kubeadm-aio/kubeadm-aio-launcher.sh
export KUBECONFIG=${HOME}/.kubeadm-aio/admin.conf
mkdir -p  ${HOME}/.kube
cat ${HOME}/.kubeadm-aio/admin.conf > ${HOME}/.kube/config
# Deploy each chart:
helm install --name mariadb local/mariadb --namespace=openstack
helm install --name=memcached local/memcached --namespace=openstack
helm install --name=etcd-rabbitmq local/etcd --namespace=openstack
helm install --name=rabbitmq local/rabbitmq --namespace=openstack
helm install --name=keystone local/keystone --namespace=openstack
helm install --name=glance local/glance --namespace=openstack --values=./glance/_values-mvp.yaml
helm install --name=nova local/nova --namespace=openstack --values=./nova/_values-mvp.yaml --set=conf.nova.libvirt.nova.conf.virt_type=qemu
helm install --name=neutron local/neutron --namespace=openstack --values=./neutron/_values-mvp.yaml
helm install --name=horizon local/horizon --namespace=openstack --set=network.enable_node_port=true
