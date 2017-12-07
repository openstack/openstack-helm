==========
All-in-One
==========

Overview
========

Below are some instructions and suggestions to help you get started with a
Kubeadm All-in-One environment on Ubuntu 16.04.

Requirements
============

System Requirements
-------------------

The recommended minimum system requirements for a full deployment are:

- 16GB of RAM
- 8 Cores
- 48GB HDD

For a deployment without cinder and horizon the system requirements are:

- 8GB of RAM
- 4 Cores
- 48GB HDD

This guide covers the minimum number of requirements to get started.

Host Configuration
------------------

OpenStack-Helm uses the hosts networking namespace for many pods including,
Ceph, Neutron and Nova components. For this, to function, as expected pods need
to be able to resolve DNS requests correctly. Ubuntu Desktop and some other
distributions make use of ``mdns4_minimal`` which does not operate as Kubernetes
expects with its default TLD of ``.local``. To operate at expected either
change the ``hosts`` line in the ``/etc/nsswitch.conf``, or confirm that it
matches:

.. code-block:: ini

  hosts:          files dns

Packages
--------

Install the latest versions of Git, CA Certs & Make if necessary

.. literalinclude:: ../../../../tools/deployment/developer/00-install-packages.sh
    :language: shell
    :lines: 1,17-

Clone the OpenStack-Helm Repos
------------------------------

Once the host has been configured the repos containing the OpenStack-Helm charts
should be cloned:

.. code-block:: shell

    #!/bin/bash
    set -xe

    git clone https://git.openstack.org/openstack/openstack-helm-infra.git
    git clone https://git.openstack.org/openstack/openstack-helm.git


Deploy Kubernetes & Helm
------------------------

You may now deploy kubernetes, and helm onto your machine, first move into the
``openstack-helm`` directory and then run the following:

.. literalinclude:: ../../../../tools/deployment/developer/01-deploy-k8s.sh
    :language: shell
    :lines: 1,17-

This command will deploy a single node KubeADM administered cluster. This will
use the parameters in ``${OSH_INFRA_PATH}/tools/gate/playbooks/vars.yaml`` to control the
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
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The OpenStack clients and Kubernetes RBAC rules, along with assembly of the
charts can be performed by running the following commands:

.. literalinclude:: ../../../../tools/deployment/developer/02-setup-client.sh
    :language: shell
    :lines: 1,17-

Alternatively, this step can be performed by running the script directly:

.. code-block:: shell

  ./tools/deployment/developer/02-setup-client.sh


Deploy the ingress controller
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. literalinclude:: ../../../../tools/deployment/developer/03-ingress.sh
    :language: shell
    :lines: 1,17-

Alternatively, this step can be performed by running the script directly:

.. code-block:: shell

  ./tools/deployment/developer/03-ingress.sh

Deploy Ceph
^^^^^^^^^^^

.. literalinclude:: ../../../../tools/deployment/developer/04-ceph.sh
    :language: shell
    :lines: 1,17-

Alternatively, this step can be performed by running the script directly:

.. code-block:: shell

  ./tools/deployment/developer/04-ceph.sh

Activate the openstack namespace to be able to use Ceph
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. literalinclude:: ../../../../tools/deployment/developer/05-ceph-ns-activate.sh
    :language: shell
    :lines: 1,17-

Alternatively, this step can be performed by running the script directly:

.. code-block:: shell

  ./tools/deployment/developer/05-ceph-ns-activate.sh

Deploy MariaDB
^^^^^^^^^^^^^^

.. literalinclude:: ../../../../tools/deployment/developer/06-mariadb.sh
    :language: shell
    :lines: 1,17-

Alternatively, this step can be performed by running the script directly:

.. code-block:: shell

  ./tools/deployment/developer/06-mariadb.sh

Deploy RabbitMQ
^^^^^^^^^^^^^^^

.. literalinclude:: ../../../../tools/deployment/developer/07-rabbitmq.sh
    :language: shell
    :lines: 1,17-

Alternatively, this step can be performed by running the script directly:

.. code-block:: shell

  ./tools/deployment/developer/07-rabbitmq.sh

Deploy Memcached
^^^^^^^^^^^^^^^^

.. literalinclude:: ../../../../tools/deployment/developer/08-memcached.sh
    :language: shell
    :lines: 1,17-

Alternatively, this step can be performed by running the script directly:

.. code-block:: shell

  ./tools/deployment/developer/08-memcached.sh

Deploy Keystone
^^^^^^^^^^^^^^^

.. literalinclude:: ../../../../tools/deployment/developer/09-keystone.sh
    :language: shell
    :lines: 1,17-

Alternatively, this step can be performed by running the script directly:

.. code-block:: shell

  ./tools/deployment/developer/09-keystone.sh

Create Ceph endpoints and service account for use with keystone
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. literalinclude:: ../../../../tools/deployment/developer/10-ceph-radosgateway.sh
    :language: shell
    :lines: 1,17-

Alternatively, this step can be performed by running the script directly:

.. code-block:: shell

  ./tools/deployment/developer/10-ceph-radosgateway.sh

Deploy Horizon
^^^^^^^^^^^^^^

.. warning:: Horizon deployment is not tested in the OSH development environment
   community gates

.. literalinclude:: ../../../../tools/deployment/developer/11-horizon.sh
    :language: shell
    :lines: 1,17-

Alternatively, this step can be performed by running the script directly:

.. code-block:: shell

  ./tools/deployment/developer/11-horizon.sh

Deploy Glance
^^^^^^^^^^^^^

.. literalinclude:: ../../../../tools/deployment/developer/12-glance.sh
    :language: shell
    :lines: 1,17-

Alternatively, this step can be performed by running the script directly:

.. code-block:: shell

  ./tools/deployment/developer/12-glance.sh

Deploy OpenvSwitch
^^^^^^^^^^^^^^^^^^

.. literalinclude:: ../../../../tools/deployment/developer/13-openvswitch.sh
    :language: shell
    :lines: 1,17-

Alternatively, this step can be performed by running the script directly:

.. code-block:: shell

  ./tools/deployment/developer/13-openvswitch.sh

Deploy Libvirt
^^^^^^^^^^^^^^

.. literalinclude:: ../../../../tools/deployment/developer/14-libvirt.sh
    :language: shell
    :lines: 1,17-

Alternatively, this step can be performed by running the script directly:

.. code-block:: shell

  ./tools/deployment/developer/14-libvirt.sh

Deploy Compute Kit (Nova and Neutron)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. literalinclude:: ../../../../tools/deployment/developer/15-compute-kit.sh
    :language: shell
    :lines: 1,17-

Alternatively, this step can be performed by running the script directly:

.. code-block:: shell

  ./tools/deployment/developer/15-compute-kit.sh

Setup the gateway to the public network
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. literalinclude:: ../../../../tools/deployment/developer/16-setup-gateway.sh
    :language: shell
    :lines: 1,17-

Alternatively, this step can be performed by running the script directly:

.. code-block:: shell

  ./tools/deployment/developer/16-setup-gateway.sh

Deploy Cinder
^^^^^^^^^^^^^

.. warning:: Cinder deployment is not tested in the OSH development environment
   community gates

.. literalinclude:: ../../../../tools/deployment/developer/17-cinder.sh
    :language: shell
    :lines: 1,17-

Alternatively, this step can be performed by running the script directly:

.. code-block:: shell

  ./tools/deployment/developer/17-cinder.sh

Deploy Heat
^^^^^^^^^^^

.. literalinclude:: ../../../../tools/deployment/developer/18-heat.sh
    :language: shell
    :lines: 1,17-

Alternatively, this step can be performed by running the script directly:

.. code-block:: shell

  ./tools/deployment/developer/18-heat.sh

Exercise the cloud
^^^^^^^^^^^^^^^^^^^

.. literalinclude:: ../../../../tools/deployment/developer/19-use-it.sh
    :language: shell
    :lines: 1,17-

Alternatively, this step can be performed by running the script directly:

.. code-block:: shell

  ./tools/deployment/developer/19-use-it.sh

Removing Helm Charts
====================

To delete an installed helm chart, use the following command:

.. code-block:: shell

  helm delete ${RELEASE_NAME} --purge

This will delete all Kubernetes resources generated when the chart was
instantiated. However for OpenStack charts, by default, this will not delete
the database and database users that were created when the chart was installed.
All OpenStack projects can be configured such that upon deletion, their database
will also be removed. To delete the database when the chart is deleted the
database drop job must be enabled before installing the chart. There are two
ways to enable the job, set the job_db_drop value to true in the chart's
values.yaml file, or override the value using the helm install command as
follows:

.. code-block:: shell

  helm install ${RELEASE_NAME} --set manifests.job_db_drop=true


Environment tear-down
=====================

To tear-down, the development environment charts should be removed firstly from
the 'openstack' namespace and then the 'ceph' namespace using the commands from
the `Removing Helm Charts`_ section. Once this has been done the namespaces
themselves can be cleaned by running:

.. code-block:: shell

  kubectl delete namespace <namespace_name>

Final cleanup of the development environment is then performed by removing the
``/var/lib/openstack-helm`` directory from the host. This will restore the
environment back to a clean Kubernetes deployment, that can either be manually
removed or over-written by restarting the deployment process.
