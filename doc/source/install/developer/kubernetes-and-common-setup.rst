===========================
Kubernetes and Common Setup
===========================

Clone the OpenStack-Helm Repos
------------------------------

Once the host has been configured the repos containing the OpenStack-Helm charts
should be cloned:

.. code-block:: shell

    #!/bin/bash
    set -xe

    git clone https://git.openstack.org/openstack/openstack-helm-infra.git
    git clone https://git.openstack.org/openstack/openstack-helm.git


.. warning::
  This installation, by default will use Google DNS servers, 8.8.8.8 or 8.8.4.4
  and updates ``resolv.conf``. These DNS nameserver entries can be changed by
  updating file ``openstack-helm-infra/tools/images/kubeadm-aio/assets/opt/playbooks/vars.yaml``
  under section ``external_dns_nameservers``.

Deploy Kubernetes & Helm
------------------------

You may now deploy kubernetes, and helm onto your machine, first move into the
``openstack-helm`` directory and then run the following:

.. literalinclude:: ../../../../tools/deployment/developer/common/010-deploy-k8s.sh
    :language: shell
    :lines: 1,17-

Alternatively, this step can be performed by running the script directly:

.. code-block:: shell

  ./tools/deployment/developer/common/010-deploy-k8s.sh

This command will deploy a single node KubeADM administered cluster. This will
use the parameters in ``${OSH_INFRA_PATH}/playbooks/vars.yaml`` to control the
deployment, which can be over-ridden by adding entries to
``${OSH_INFRA_PATH}/tools/gate/devel/local-vars.yaml``.

Helm Chart Installation
=======================

Using the Helm packages previously pushed to the local Helm repository, run the
following commands to instruct tiller to create an instance of the given chart.
During installation, the helm client will print useful information about
resources created, the state of the Helm releases, and whether any additional
configuration steps are necessary.

Install OpenStack-Helm
----------------------

.. note:: The following commands all assume that they are run from the
   ``openstack-helm`` directory and the repos have been cloned as above.

Setup Clients on the host and assemble the charts
=================================================

The OpenStack clients and Kubernetes RBAC rules, along with assembly of the
charts can be performed by running the following commands:

.. literalinclude:: ../../../../tools/deployment/developer/common/020-setup-client.sh
    :language: shell
    :lines: 1,17-

Alternatively, this step can be performed by running the script directly:

.. code-block:: shell

  ./tools/deployment/developer/common/020-setup-client.sh


Deploy the ingress controller
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. literalinclude:: ../../../../tools/deployment/developer/common/030-ingress.sh
    :language: shell
    :lines: 1,17-

Alternatively, this step can be performed by running the script directly:

.. code-block:: shell

  ./tools/deployment/developer/common/030-ingress.sh
