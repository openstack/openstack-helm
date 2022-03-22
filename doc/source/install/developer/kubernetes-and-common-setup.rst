===========================
Kubernetes and Common Setup
===========================

Install Basic Utilities
^^^^^^^^^^^^^^^^^^^^^^^

To get started with OSH, we will need  ``git``,  ``curl`` and ``make``.

.. code-block:: shell

  sudo apt install git curl make

Clone the OpenStack-Helm Repos
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Once the host has been configured the repos containing the OpenStack-Helm charts
should be cloned:

.. code-block:: shell

    #!/bin/bash
    set -xe

    git clone https://opendev.org/openstack/openstack-helm-infra.git
    git clone https://opendev.org/openstack/openstack-helm.git

OSH Proxy & DNS Configuration
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. note::

  If you are not deploying OSH behind a proxy, skip this step and
  continue with "Deploy Kubernetes & Helm".

In order to deploy OSH behind a proxy, add the following entries to
``openstack-helm-infra/tools/gate/devel/local-vars.yaml``:

.. code-block:: shell

  proxy:
    http: http://PROXY_URL:PORT
    https: https://PROXY_URL:PORT
    noproxy: 127.0.0.1,localhost,172.17.0.1,.svc.cluster.local

.. note::
  Depending on your specific proxy, https_proxy may be the same as http_proxy.
  Refer to your specific proxy documentation.

By default OSH will use Google DNS Server IPs (8.8.8.8, 8.8.4.4) and will
update resolv.conf as a result. If those IPs are blocked by your proxy, running
the OSH scripts will result in the inability to connect to anything on the
network. These DNS nameserver entries can be changed by updating the
external_dns_nameservers entry in the file
``openstack-helm-infra/tools/images/kubeadm-aio/assets/opt/playbooks/vars.yaml``.

.. code-block:: shell

  external_dns_nameservers:
    - YOUR_PROXY_DNS_IP
    - ALT_PROXY_DNS_IP

These values can be retrieved by running:

.. code-block:: shell

  systemd-resolve --status

Deploy Kubernetes & Helm
^^^^^^^^^^^^^^^^^^^^^^^^

You may now deploy kubernetes, and helm onto your machine, first move into the
``openstack-helm`` directory and then run the following:

.. literalinclude:: ../../../../tools/deployment/developer/common/010-deploy-k8s.sh
    :language: shell
    :lines: 1,17-

Alternatively, this step can be performed by running the script directly:

.. code-block:: shell

  ./tools/deployment/developer/common/010-deploy-k8s.sh

This command will deploy a single node minikube cluster. This will use the
parameters in ``${OSH_INFRA_PATH}/playbooks/vars.yaml`` to control the
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

.. literalinclude:: ../../../../tools/deployment/component/common/ingress.sh
    :language: shell
    :lines: 1,17-

Alternatively, this step can be performed by running the script directly:

.. code-block:: shell

  ./tools/deployment/component/common/ingress.sh

To continue to deploy OpenStack on Kubernetes via OSH, see
:doc:`Deploy NFS<./deploy-with-nfs>` or :doc:`Deploy Ceph<./deploy-with-ceph>`.
