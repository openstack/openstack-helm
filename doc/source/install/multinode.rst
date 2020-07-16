=========
Multinode
=========

Overview
========

In order to drive towards a production-ready OpenStack solution, our
goal is to provide containerized, yet stable `persistent
volumes <https://kubernetes.io/docs/concepts/storage/persistent-volumes/>`_
that Kubernetes can use to schedule applications that require state,
such as MariaDB (Galera). Although we assume that the project should
provide a "batteries included" approach towards persistent storage, we
want to allow operators to define their own solution as well. Examples
of this work will be documented in another section, however evidence of
this is found throughout the project. If you find any issues or gaps,
please create a `story <https://storyboard.openstack.org/#!/project/886>`_
to track what can be done to improve our documentation.

.. note::
  Please see the supported application versions outlined in the
  `source variable file <https://github.com/openstack/openstack-helm-infra/blob/master/roles/build-images/defaults/main.yml>`_.

Other versions and considerations (such as other CNI SDN providers),
config map data, and value overrides will be included in other
documentation as we explore these options further.

The installation procedures below, will take an administrator from a new
``kubeadm`` installation to OpenStack-Helm deployment.

.. note:: Many of the default container images that are referenced across
  OpenStack-Helm charts are not intended for production use; for example,
  while LOCI and Kolla can be used to produce production-grade images, their
  public reference images are not prod-grade.  In addition, some of the default
  images use ``latest`` or ``master`` tags, which are moving targets and can
  lead to unpredictable behavior.  For production-like deployments, we
  recommend building custom images, or at minimum caching a set of known
  images, and incorporating them into OpenStack-Helm via values overrides.

.. warning:: Until the Ubuntu kernel shipped with 16.04 supports CephFS
   subvolume mounts by default the `HWE Kernel
   <../troubleshooting/ubuntu-hwe-kernel.html>`__ is required to use CephFS.

Kubernetes Preparation
======================

You can use any Kubernetes deployment tool to bring up a working Kubernetes
cluster for use with OpenStack-Helm. For production deployments,
please choose (and tune appropriately) a highly-resilient Kubernetes
distribution, e.g.:

- `Airship <https://airshipit.org/>`_, a declarative open cloud
  infrastructure platform
- `KubeADM <https://kubernetes.io/docs/setup/independent/high-availability/>`_,
  the foundation of a number of Kubernetes installation solutions

For a lab or proof-of-concept environment, the OpenStack-Helm gate scripts
can be used to quickly deploy a multinode Kubernetes cluster using KubeADM
and Ansible. Please refer to the deployment guide
`here <./kubernetes-gate.html>`__.

Managing and configuring a Kubernetes cluster is beyond the scope
of OpenStack-Helm and this guide.

Deploy OpenStack-Helm
=====================

.. note::
  The following commands all assume that they are run from the
  ``/opt/openstack-helm`` directory.


Setup Clients on the host and assemble the charts
-------------------------------------------------

The OpenStack clients and Kubernetes RBAC rules, along with assembly of the
charts can be performed by running the following commands:

.. literalinclude:: ../../../tools/deployment/multinode/010-setup-client.sh
    :language: shell
    :lines: 1,17-

Alternatively, this step can be performed by running the script directly:

.. code-block:: shell

  ./tools/deployment/multinode/010-setup-client.sh


Deploy the ingress controller
-----------------------------

.. code-block:: shell

  export OSH_DEPLOY_MULTINODE=True

.. literalinclude:: ../../../tools/deployment/component/common/ingress.sh
    :language: shell
    :lines: 1,17-

Alternatively, this step can be performed by running the script directly:

.. code-block:: shell

  OSH_DEPLOY_MULTINODE=True ./tools/deployment/component/common/ingress.sh

Create loopback devices for CEPH
--------------------------------

Create two loopback devices for ceph as one disk for OSD data and other disk for
block DB and block WAL.
If loop0 and loop1  devices are busy in your case , feel free to change them in parameters
by using --ceph-osd-data and --ceph-osd-dbwal options.

.. code-block:: shell

  ansible all -i /opt/openstack-helm-infra/tools/gate/devel/multinode-inventory.yaml -m shell -s -a "/opt/openstack-helm/tools/deployment/common/setup-ceph-loopback-device.sh --ceph-osd-data /dev/loop0 --ceph-osd-dbwal /dev/loop1"

Deploy Ceph
-----------

The script below configures Ceph to use loopback devices created in previous step as backend for ceph osds.
To configure a custom block device-based backend, please refer
to the ``ceph-osd`` `values.yaml <https://github.com/openstack/openstack-helm/blob/master/ceph-osd/values.yaml>`_.

Additional information on Kubernetes Ceph-based integration can be found in
the documentation for the
`CephFS <https://github.com/kubernetes-incubator/external-storage/blob/master/ceph/cephfs/README.md>`_
and `RBD <https://github.com/kubernetes-incubator/external-storage/blob/master/ceph/rbd/README.md>`_
storage provisioners, as well as for the alternative
`NFS <https://github.com/kubernetes-incubator/external-storage/blob/master/nfs/README.md>`_ provisioner.

.. warning:: The upstream Ceph image repository does not currently pin tags to
  specific Ceph point releases.  This can lead to unpredictable results
  in long-lived deployments.  In production scenarios, we strongly recommend
  overriding the Ceph images to use either custom built images or controlled,
  cached images.

.. note::
  The `./tools/deployment/multinode/kube-node-subnet.sh` script requires docker
  to run.

.. literalinclude:: ../../../tools/deployment/multinode/030-ceph.sh
    :language: shell
    :lines: 1,17-

Alternatively, this step can be performed by running the script directly:

.. code-block:: shell

  ./tools/deployment/multinode/030-ceph.sh

Activate the openstack namespace to be able to use Ceph
-------------------------------------------------------

.. literalinclude:: ../../../tools/deployment/multinode/040-ceph-ns-activate.sh
    :language: shell
    :lines: 1,17-

Alternatively, this step can be performed by running the script directly:

.. code-block:: shell

  ./tools/deployment/multinode/040-ceph-ns-activate.sh

Deploy MariaDB
--------------

.. literalinclude:: ../../../tools/deployment/multinode/050-mariadb.sh
    :language: shell
    :lines: 1,17-

Alternatively, this step can be performed by running the script directly:

.. code-block:: shell

  ./tools/deployment/multinode/050-mariadb.sh

Deploy RabbitMQ
---------------

.. literalinclude:: ../../../tools/deployment/multinode/060-rabbitmq.sh
    :language: shell
    :lines: 1,17-

Alternatively, this step can be performed by running the script directly:

.. code-block:: shell

  ./tools/deployment/multinode/060-rabbitmq.sh

Deploy Memcached
----------------

.. literalinclude:: ../../../tools/deployment/multinode/070-memcached.sh
    :language: shell
    :lines: 1,17-

Alternatively, this step can be performed by running the script directly:

.. code-block:: shell

  ./tools/deployment/multinode/070-memcached.sh

Deploy Keystone
---------------

.. literalinclude:: ../../../tools/deployment/multinode/080-keystone.sh
    :language: shell
    :lines: 1,17-

Alternatively, this step can be performed by running the script directly:

.. code-block:: shell

  ./tools/deployment/multinode/080-keystone.sh

Deploy Rados Gateway for object store
-------------------------------------

.. literalinclude:: ../../../tools/deployment/multinode/090-ceph-radosgateway.sh
    :language: shell
    :lines: 1,17-

Alternatively, this step can be performed by running the script directly:

.. code-block:: shell

  ./tools/deployment/multinode/090-ceph-radosgateway.sh

Deploy Glance
-------------

.. literalinclude:: ../../../tools/deployment/multinode/100-glance.sh
    :language: shell
    :lines: 1,17-

Alternatively, this step can be performed by running the script directly:

.. code-block:: shell

  ./tools/deployment/multinode/100-glance.sh

Deploy Cinder
-------------

.. literalinclude:: ../../../tools/deployment/multinode/110-cinder.sh
    :language: shell
    :lines: 1,17-

Alternatively, this step can be performed by running the script directly:

.. code-block:: shell

  ./tools/deployment/multinode/110-cinder.sh

Deploy OpenvSwitch
------------------

.. literalinclude:: ../../../tools/deployment/multinode/120-openvswitch.sh
    :language: shell
    :lines: 1,17-

Alternatively, this step can be performed by running the script directly:

.. code-block:: shell

  ./tools/deployment/multinode/120-openvswitch.sh

Deploy Libvirt
--------------

.. literalinclude:: ../../../tools/deployment/multinode/130-libvirt.sh
    :language: shell
    :lines: 1,17-

Alternatively, this step can be performed by running the script directly:

.. code-block:: shell

  ./tools/deployment/multinode/130-libvirt.sh

Deploy Compute Kit (Nova and Neutron)
-------------------------------------

.. literalinclude:: ../../../tools/deployment/multinode/140-compute-kit.sh
    :language: shell
    :lines: 1,17-

Alternatively, this step can be performed by running the script directly:

.. code-block:: shell

  ./tools/deployment/multinode/140-compute-kit.sh

Deploy Heat
-----------

.. literalinclude:: ../../../tools/deployment/multinode/150-heat.sh
    :language: shell
    :lines: 1,17-

Alternatively, this step can be performed by running the script directly:

.. code-block:: shell

  ./tools/deployment/multinode/150-heat.sh

Deploy Barbican
---------------

.. literalinclude:: ../../../tools/deployment/multinode/160-barbican.sh
    :language: shell
    :lines: 1,17-

Alternatively, this step can be performed by running the script directly:

.. code-block:: shell

  ./tools/deployment/multinode/160-barbican.sh

Configure OpenStack
-------------------

Configuring OpenStack for a particular production use-case is beyond the scope
of this guide. Please refer to the
OpenStack `Configuration <https://docs.openstack.org/latest/configuration/>`_
documentation for your selected version of OpenStack to determine
what additional values overrides should be
provided to the OpenStack-Helm charts to ensure appropriate networking,
security, etc. is in place.
