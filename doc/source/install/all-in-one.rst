==========
All-in-One
==========

Overview
========

Below are some instructions and suggestions to help you get started with a Kubeadm All-in-One environment on Ubuntu 16.04.
*Also tested on Centos and Fedora.*

Requirements
============

We've tried to minimize the number of prerequisites required in order to get started. For most users, the main prerequisites are to install the most recent versions of Kubectl and Helm.

Setup etc/hosts
---------------

::

        #Replace eth0 with your interface name
        LOCAL_IP=$(ip addr | awk '/inet/ && /eth0/{sub(/\/.*$/,"",$2); print $2}')
        cat << EOF | sudo tee -a /etc/hosts
        ${LOCAL_IP} $(hostname)
        EOF

Packages
--------

Install the latest versions of Docker, Network File System, Git & Make

::

        sudo apt-get update -y
        sudo apt-get install -y --no-install-recommends -qq \
                docker.io \
                nfs-common \
                git \
                make

Kubectl
-------

Download and install kubectl, the command line interface for running commands against your Kubernetes cluster.

::

        KUBE_VERSION=v1.6.5
        HELM_VERSION=v2.3.1
        TMP_DIR=$(mktemp -d)

        curl -sSL https://storage.googleapis.com/kubernetes-release/release/${KUBE_VERSION}/bin/linux/amd64/kubectl -o ${TMP_DIR}/kubectl
        chmod +x ${TMP_DIR}/kubectl
        sudo mv ${TMP_DIR}/kubectl /usr/local/bin/kubectl

Helm
----

Download and install Helm, the package manager for Kubernetes

::

        curl -sSL https://storage.googleapis.com/kubernetes-helm/helm-${HELM_VERSION}-linux-amd64.tar.gz | tar -zxv --strip-components=1 -C ${TMP_DIR}
        sudo mv ${TMP_DIR}/helm /usr/local/bin/helm
        rm -rf ${TMP_DIR}

OpenStack-Helm
==============

Using git, clone the repository that holds all of the openstack helm-based charts.

::

        git clone https://github.com/openstack/openstack-helm.git && cd openstack-helm

Setup Helm client
-----------------

Initialize the helm client and start listening on localhost:8879.  Once the helm client is available, add the local repository to the helm client.  Use ``helm| [command] --help`` if you need more information about the helm commands you are running.

::

        helm init --client-only
        helm serve &
        helm repo add local http://localhost:8879/charts
        helm repo remove stable

Make
----

Run ``make`` from the root of your openstack-helm repository to achieve the following:

* **Lint:** Validate that your helm charts have no basic syntax errors
* **Package:** Each chart will be compiled into a helm package that will contain all of the resource definitions necessary to run an application,tool, or service inside of a Kubernetes cluster.
* **Push:** Push the Helm packages to your local Helm repository

::

        make

Kubeadm-AIO Container
=====================

Using the Dockerfile defined in tools/kubeadm-aio directory, build the openstack-helm/kubeadm-aio:v1.6 image. You can verify that your Docker image was successfully created by issuing ``sudo docker images | grep openstack-helm/kubeadm-aio`` from the command line.  After the image is built, execute the kubeadm-aio-launcher script which will create your Kubernetes single node environment with Helm, Calico, an NFS PVC provisioner with appropriate RBAC rules and node labels to get developing.

Build
-----

::

        export KUBEADM_IMAGE=openstack-helm/kubeadm-aio:v1.6.5
        sudo docker build --pull -t ${KUBEADM_IMAGE} tools/kubeadm-aio

Deploy
------

::

        export KUBE_VERSION=v1.6.5
        ./tools/kubeadm-aio/kubeadm-aio-launcher.sh
        export KUBECONFIG=${HOME}/.kubeadm-aio/admin.conf
        mkdir -p  ${HOME}/.kube
        cat ${KUBECONFIG} > ${HOME}/.kube/config

Helm Chart Installation
=======================

Using the helm packages that were previously pushed to your local helm repository run the following commands to instruct tiller to create an instance of the given chart.  During installation, the helm client will print useful information about which resources were created, what the state of the release is, and also whether there are additional configuration steps you can or should take.

Helm Install Examples
---------------------

The below snippet will install the given chart name from the local repository using the default values.

::

        helm install --name=mariadb local/mariadb --namespace=openstack
        helm install --name=memcached local/memcached --namespace=openstack
        helm install --name=etcd-rabbitmq local/etcd --namespace=openstack
        helm install --name=rabbitmq local/rabbitmq --namespace=openstack
        helm install --name=keystone local/keystone --namespace=openstack


In the below examples the default values that would be used in a production-like environment have been overridden with more sensible values for your All-in-One environment using the ``--values`` and ``--set`` options.

::

        helm install --name=glance local/glance --namespace=openstack --values=./tools/overrides/mvp/glance.yaml
        helm install --name=nova local/nova --namespace=openstack --values=./tools/overrides/mvp/nova.yaml --set=conf.nova.libvirt.nova.conf.virt_type=qemu
        helm install --name=neutron local/neutron --namespace=openstack --values=./tools/overrides/mvp/neutron.yaml
        helm install --name=horizon local/horizon --namespace=openstack --set=network.enable_node_port=true
