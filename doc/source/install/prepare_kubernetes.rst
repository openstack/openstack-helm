Prepare Kubernetes
==================

In this section we assume you have a working Kubernetes cluster and
Kubectl and Helm properly configured to interact with the cluster.

Before deploying OpenStack components using OpenStack-Helm you have to set
labels on Kubernetes worker nodes which are used as node selectors.

Also necessary namespaces must be created.

You can use the `prepare-k8s.sh`_ script as an example of how to prepare
the Kubernetes cluster for OpenStack deployment. The script is assumed to be run
from the openstack-helm repository

.. code-block:: bash

    cd ~/osh/openstack-helm
    ./tools/deployment/common/prepare-k8s.sh


.. note::
   Pay attention that in the above script we set labels on all Kubernetes nodes including
   Kubernetes control plane nodes which are usually not aimed to run workload pods
   (OpenStack in our case). So you have to either untaint control plane nodes or modify the
   `prepare-k8s.sh`_ script so it sets labels only on the worker nodes.

.. _prepare-k8s.sh: https://opendev.org/openstack/openstack-helm/src/branch/master/tools/deployment/common/prepare-k8s.sh
