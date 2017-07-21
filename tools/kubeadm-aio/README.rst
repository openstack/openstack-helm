Kubeadm AIO Container
=====================

This container builds a small AIO Kubeadm based Kubernetes deployment
for Development and Gating use.

Instructions
------------

OS Specific Host setup:
~~~~~~~~~~~~~~~~~~~~~~~

Ubuntu:
^^^^^^^

From a freshly provisioned Ubuntu 16.04 LTS host run:

.. code:: bash

    sudo apt-get update -y
    sudo apt-get install -y \
            docker.io \
            nfs-common \
            git \
            make

OS Independent Host setup:
~~~~~~~~~~~~~~~~~~~~~~~~~~

You should install the ``kubectl`` and ``helm`` binaries:

.. code:: bash

    KUBE_VERSION=v1.6.7
    HELM_VERSION=v2.5.0

    TMP_DIR=$(mktemp -d)
    curl -sSL https://storage.googleapis.com/kubernetes-release/release/${KUBE_VERSION}/bin/linux/amd64/kubectl -o ${TMP_DIR}/kubectl
    chmod +x ${TMP_DIR}/kubectl
    sudo mv ${TMP_DIR}/kubectl /usr/local/bin/kubectl
    curl -sSL https://storage.googleapis.com/kubernetes-helm/helm-${HELM_VERSION}-linux-amd64.tar.gz | tar -zxv --strip-components=1 -C ${TMP_DIR}
    sudo mv ${TMP_DIR}/helm /usr/local/bin/helm
    rm -rf ${TMP_DIR}

And clone the OpenStack-Helm repo:

.. code:: bash

    git clone https://git.openstack.org/openstack/openstack-helm

Build the AIO environment (optional)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

A known good image is published to dockerhub on a fairly regular basis, but if
you wish to build your own image, from the root directory of the OpenStack-Helm
repo run:

.. code:: bash

    export KUBEADM_IMAGE=openstackhelm/kubeadm-aio:v1.6.7
    sudo docker build --pull -t ${KUBEADM_IMAGE} tools/kubeadm-aio

Deploy the AIO environment
~~~~~~~~~~~~~~~~~~~~~~~~~~

To launch the environment run:

.. code:: bash

    export KUBEADM_IMAGE=openstackhelm/kubeadm-aio:v1.6.7
    export KUBE_VERSION=v1.6.7
    ./tools/kubeadm-aio/kubeadm-aio-launcher.sh
    export KUBECONFIG=${HOME}/.kubeadm-aio/admin.conf

Once this has run without errors, you should hopefully have a Kubernetes single
node environment running, with Helm, Calico, appropriate RBAC rules and node
labels to get developing.

If you wish to use this environment as the primary Kubernetes environment on
your host you may run the following, but note that this will wipe any previous
client configuration you may have.

.. code:: bash

    mkdir -p  ${HOME}/.kube
    cat ${HOME}/.kubeadm-aio/admin.conf > ${HOME}/.kube/config

If you wish to create dummy network devices for Neutron to manage there
is a helper script that can set them up for you:

.. code:: bash

    sudo docker exec kubelet /usr/bin/openstack-helm-aio-network-prep

Logs
~~~~

You can get the logs from your ``kubeadm-aio`` container by running:

.. code:: bash

    sudo docker logs -f kubeadm-aio
