# Kubeadm AIO Container

This container builds a small AIO Kubeadm based Kubernetes deployment for Development and Gating use.

## Instructions

### OS Specific Host setup:

#### Ubuntu:

From a freshly provisioned Ubuntu 16.04 LTS host run:
``` bash
sudo apt-get update -y
sudo apt-get install -y \
        docker.io \
        nfs-common \
        git \
        make
```

### OS Independent Host setup:

You should install the `kubectl` and `helm` binaries:

``` bash
KUBE_VERSION=v1.6.0
HELM_VERSION=v2.3.0

TMP_DIR=$(mktemp -d)
curl -sSL https://storage.googleapis.com/kubernetes-release/release/${KUBE_VERSION}/bin/linux/amd64/kubectl -o ${TMP_DIR}/kubectl
chmod +x ${TMP_DIR}/kubectl
sudo mv ${TMP_DIR}/kubectl /usr/local/bin/kubectl
curl -sSL https://storage.googleapis.com/kubernetes-helm/helm-${HELM_VERSION}-linux-amd64.tar.gz | tar -zxv --strip-components=1 -C ${TMP_DIR}
sudo mv ${TMP_DIR}/helm /usr/local/bin/helm
rm -rf ${TMP_DIR}
```

And clone the OpenStack-Helm repo:

``` bash
git clone https://git.openstack.org/openstack/openstack-helm
```

### Build and deploy the AIO environment

From the root directory of the OpenStack-Helm repo run:

``` bash
export KUBEADM_IMAGE=openstack-helm/kubeadm-aio:v1.6
sudo docker build --pull -t ${KUBEADM_IMAGE} tools/kubeadm-aio
```

To launch the environment then run:

``` bash
export KUBEADM_IMAGE=openstack-helm/kubeadm-aio:v1.6
export KUBE_VERSION=v1.6.0
./tools/kubeadm-aio/kubeadm-aio-launcher.sh
export KUBECONFIG=${HOME}/.kubeadm-aio/admin.conf
```

One this has run, you should hopefully have a Kubernetes single node environment
running, with Helm, Calico, a NFS PVC provisioner and appropriate RBAC rules and
node labels to get developing.

If you wish to use this environment at the primary Kubernetes environment on
your host you may run the following, but note that this will wipe any previous
client configuration you may have.

``` bash
mkdir -p  ${HOME}/.kube
cat ${HOME}/.kubeadm-aio/admin.conf > ${HOME}/.kube/config
```

If you wish to create dummy network devices for Neutron to manage there is a
helper script that can set them up for you:

``` bash
sudo docker exec kubelet /usr/bin/openstack-helm-aio-network-prep
```

### Logs

You can get the logs from your `kubeadm-aio` container by running:

``` bash
sudo docker logs -f kubeadm-aio
```
