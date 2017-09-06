==========
All-in-One
==========

Overview
========

Below are some instructions and suggestions to help you get started with a
Kubeadm All-in-One environment on Ubuntu 16.04.
*Also tested on Centos and Fedora.*

Requirements
============

System Requirements
-------------------

The minimum requirements for using the Kubeadm-AIO environment depend on the
desired backend for persistent volume claims.

For NFS, the minimum system requirements are:

- 8GB of RAM
- 4 Cores
- 48GB HDD

For Ceph, the minimum system requirements are:

- 16GB of RAM
- 8 Cores
- 48GB HDD

This guide covers the minimum number of requirements to get started. For most
users, the main prerequisites are to install the most recent versions of Kubectl
and Helm.

Setup etc/hosts
---------------

::

    HOST_IFACE=$(ip route | grep "^default" | head -1 | awk '{ print $5 }')
    LOCAL_IP=$(ip addr | awk "/inet/ && /${HOST_IFACE}/{sub(/\/.*$/,\"\",\$2); print \$2}")
    cat << EOF | sudo tee -a /etc/hosts
    ${LOCAL_IP} $(hostname)
    EOF

Packages
--------

Install the latest versions of Docker, Network File System, Git, Make & Curl if
necessary

::

      sudo apt-get update -y
      sudo apt-get install -y --no-install-recommends -qq \
              curl \
              docker.io \
              nfs-common \
              git \
              make

Kubectl
-------

Download and install kubectl, the command line interface for running commands
against your Kubernetes cluster.

::

      export KUBE_VERSION=v1.6.8
      export HELM_VERSION=v2.5.1
      export TMP_DIR=$(mktemp -d)

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

Using git, clone the repository that holds all of the OpenStack service charts.

::

      git clone https://git.openstack.org/openstack/openstack-helm.git
      cd openstack-helm

Setup Helm client
-----------------

Initialize the helm client and start listening on localhost:8879.  Once the helm
client is available, add the local repository to the helm client.  Use
``helm [command] --help`` for more information about the Helm commands.

::

      helm init --client-only
      helm serve &
      helm repo add local http://localhost:8879/charts
      helm repo remove stable

Make
----

The provided Makefile in OpenStack-Helm will perform the following:

* **Lint:** Validate that your helm charts have no basic syntax errors
* **Package:** Each chart will be compiled into a helm package that will contain
  all of the resource definitions necessary to run an application,tool, or service
  inside of a Kubernetes cluster.
* **Push:** Push the Helm packages to your local Helm repository

Run ``make`` from the root of the openstack-helm repository:

::

      make

Kubeadm-AIO Container
=====================

Build
-----

Using the Dockerfile defined in tools/kubeadm-aio directory, build the
'openstackhelm/kubeadm-aio:v1.6.8' image.

::

      export KUBEADM_IMAGE=openstackhelm/kubeadm-aio:v1.6.8
      sudo docker build --pull -t ${KUBEADM_IMAGE} tools/kubeadm-aio

CNI Configuration
-----------------

Before deploying AIO, you may optionally set additional parameters which
control aspects of the CNI used:

::

      export KUBE_CNI=calico # or "canal" "weave" "flannel"
      export CNI_POD_CIDR=192.168.0.0/16

Deploy
------

After the image is built, execute the kubeadm-aio-launcher script which creates
a single node Kubernetes environment by default with Helm, Calico, an NFS PVC
provisioner with appropriate RBAC rules and node labels to start developing. The
following deploys the Kubeadm-AIO environment.  It should be noted these
commands may take a few minutes to execute.  The output of these commands is
displayed during execution.

::

      export KUBE_VERSION=v1.6.8
      ./tools/kubeadm-aio/kubeadm-aio-launcher.sh
      export KUBECONFIG=${HOME}/.kubeadm-aio/admin.conf
      mkdir -p  ${HOME}/.kube
      cat ${KUBECONFIG} > ${HOME}/.kube/config

Dummy Neutron Networks
----------------------

If you wish to create dummy network devices for Neutron to manage there is a
helper script that can set them up for you:

::

      sudo docker exec kubelet /usr/bin/openstack-helm-aio-network-prep

Logs
----

You can get the logs from your kubeadm-aio container by running:

::

      sudo docker logs -f kubeadm-aio

Helm Chart Installation
=======================

Using the Helm packages previously pushed to the local Helm repository, run the
following commands to instruct tiller to create an instance of the given chart.
During installation, the helm client will print useful information about
resources created, the state of the Helm releases, and whether any additional
configuration steps are necessary.

Helm Install Examples
---------------------

To install a helm chart, use the general command:

.. code-block:: shell

  helm install --name=${NAME} ${PATH_TO_CHART}/${NAME} --namespace=${NAMESPACE}

The below snippet will install the given chart name from the local repository
using the default values.  These services must be installed first, as the
OpenStack services depend upon them.

.. code-block:: shell

  helm install --name=mariadb ./mariadb --namespace=openstack
  helm install --name=memcached ./memcached --namespace=openstack
  helm install --name=etcd-rabbitmq ./etcd --namespace=openstack
  helm install --name=rabbitmq ./rabbitmq --namespace=openstack
  helm install --name=ingress ./ingress --namespace=openstack
  helm install --name=libvirt ./libvirt --namespace=openstack
  helm install --name=openvswitch ./openvswitch --namespace=openstack

Once the OpenStack infrastructure components are installed and running, the
OpenStack services can be installed.  In the below examples the default values
that would be used in a production-like environment have been overridden with
more sensible values for the All-in-One environment using the ``--values`` and
``--set`` options.

.. code-block:: shell

  helm install --name=keystone ./keystone --namespace=openstack
  helm install --name=glance ./glance --namespace=openstack \
    --values=./tools/overrides/mvp/glance.yaml
  helm install --name=nova ./nova --namespace=openstack \
    --values=./tools/overrides/mvp/nova.yaml \
    --set=conf.nova.libvirt.nova.conf.virt_type=qemu
  helm install --name=neutron ./neutron \
    --namespace=openstack --values=./tools/overrides/mvp/neutron.yaml
  helm install --name=horizon ./horizon --namespace=openstack \
    --set=network.enable_node_port=true

Once the install commands have been issued, executing the following will provide
insight into the services' deployment status.

::

        watch kubectl get pods --namespace=openstack


Once the pods all register as Ready, the OpenStack services should be ready to
receive requests.
