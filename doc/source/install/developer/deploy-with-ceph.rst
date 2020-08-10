====================
Deployment With Ceph
====================

.. note::
  For other deployment options, select appropriate ``Deployment with ...``
  option from `Index <../developer/index.html>`__ page.

Deploy Ceph
^^^^^^^^^^^

We are going to install Ceph OSDs backed by loopback devices as this will
help us not to attach extra disks, in case if you have enough disks
on the node then feel free to skip creating loopback devices by exporting
CREATE_LOOPBACK_DEVICES_FOR_CEPH to false and export the  block devices names
as environment variables(CEPH_OSD_DATA_DEVICE and CEPH_OSD_DB_WAL_DEVICE).

We are also going to seperate Ceph metadata and data onto a different devices
to replicate the ideal scenario of fast disks for metadata and slow disks to store data.
You can change this as per your design by referring to the documentation explained in
../openstack-helm-infra/ceph-osd/values.yaml

This script will create two loopback devices for Ceph as one disk for OSD data
and other disk for block DB and block WAL. If default devices (loop0 and loop1) are busy in
your case, feel free to change them by exporting environment variables(CEPH_OSD_DATA_DEVICE
and CEPH_OSD_DB_WAL_DEVICE).

.. note::
  if you are rerunning the below script then make sure to skip the loopback device creation
  by exporting CREATE_LOOPBACK_DEVICES_FOR_CEPH to false.

.. literalinclude:: ../../../../tools/deployment/developer/ceph/040-ceph.sh
    :language: shell
    :lines: 1,17-

Alternatively, this step can be performed by running the script directly:

.. code-block:: shell

  ./tools/deployment/developer/ceph/040-ceph.sh

Activate the OpenStack namespace to be able to use Ceph
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. literalinclude:: ../../../../tools/deployment/developer/ceph/045-ceph-ns-activate.sh
    :language: shell
    :lines: 1,17-

Alternatively, this step can be performed by running the script directly:

.. code-block:: shell

  ./tools/deployment/developer/ceph/045-ceph-ns-activate.sh

Deploy MariaDB
^^^^^^^^^^^^^^

.. literalinclude:: ../../../../tools/deployment/developer/ceph/050-mariadb.sh
    :language: shell
    :lines: 1,17-

Alternatively, this step can be performed by running the script directly:

.. code-block:: shell

  ./tools/deployment/developer/ceph/050-mariadb.sh

Deploy RabbitMQ
^^^^^^^^^^^^^^^

.. literalinclude:: ../../../../tools/deployment/developer/ceph/060-rabbitmq.sh
    :language: shell
    :lines: 1,17-

Alternatively, this step can be performed by running the script directly:

.. code-block:: shell

  ./tools/deployment/developer/ceph/060-rabbitmq.sh

Deploy Memcached
^^^^^^^^^^^^^^^^

.. literalinclude:: ../../../../tools/deployment/developer/ceph/070-memcached.sh
    :language: shell
    :lines: 1,17-

Alternatively, this step can be performed by running the script directly:

.. code-block:: shell

  ./tools/deployment/developer/ceph/070-memcached.sh

Deploy Keystone
^^^^^^^^^^^^^^^

.. literalinclude:: ../../../../tools/deployment/developer/ceph/080-keystone.sh
    :language: shell
    :lines: 1,17-

Alternatively, this step can be performed by running the script directly:

.. code-block:: shell

  ./tools/deployment/developer/ceph/080-keystone.sh

Deploy Heat
^^^^^^^^^^^

.. literalinclude:: ../../../../tools/deployment/developer/ceph/090-heat.sh
    :language: shell
    :lines: 1,17-

Alternatively, this step can be performed by running the script directly:

.. code-block:: shell

  ./tools/deployment/developer/ceph/090-heat.sh

Deploy Horizon
^^^^^^^^^^^^^^

.. warning:: Horizon deployment is not tested in the OSH development environment
   community gates

.. literalinclude:: ../../../../tools/deployment/developer/ceph/100-horizon.sh
    :language: shell
    :lines: 1,17-

Alternatively, this step can be performed by running the script directly:

.. code-block:: shell

  ./tools/deployment/developer/ceph/100-horizon.sh

Deploy Rados Gateway for object store
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. literalinclude:: ../../../../tools/deployment/developer/ceph/110-ceph-radosgateway.sh
    :language: shell
    :lines: 1,17-

Alternatively, this step can be performed by running the script directly:

.. code-block:: shell

  ./tools/deployment/developer/ceph/110-ceph-radosgateway.sh

Deploy Glance
^^^^^^^^^^^^^

.. literalinclude:: ../../../../tools/deployment/developer/ceph/120-glance.sh
    :language: shell
    :lines: 1,17-

Alternatively, this step can be performed by running the script directly:

.. code-block:: shell

  ./tools/deployment/developer/ceph/120-glance.sh

Deploy Cinder
^^^^^^^^^^^^^

.. warning:: Cinder deployment is not tested in the OSH development environment
   community gates

.. literalinclude:: ../../../../tools/deployment/developer/ceph/130-cinder.sh
    :language: shell
    :lines: 1,17-

Alternatively, this step can be performed by running the script directly:

.. code-block:: shell

  ./tools/deployment/developer/ceph/130-cinder.sh

Deploy OpenvSwitch
^^^^^^^^^^^^^^^^^^

.. literalinclude:: ../../../../tools/deployment/developer/ceph/140-openvswitch.sh
    :language: shell
    :lines: 1,17-

Alternatively, this step can be performed by running the script directly:

.. code-block:: shell

  ./tools/deployment/developer/ceph/140-openvswitch.sh

Deploy Libvirt
^^^^^^^^^^^^^^

.. literalinclude:: ../../../../tools/deployment/developer/ceph/150-libvirt.sh
    :language: shell
    :lines: 1,17-

Alternatively, this step can be performed by running the script directly:

.. code-block:: shell

  ./tools/deployment/developer/ceph/150-libvirt.sh

Deploy Compute Kit (Nova and Neutron)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. literalinclude:: ../../../../tools/deployment/developer/ceph/160-compute-kit.sh
    :language: shell
    :lines: 1,17-

Alternatively, this step can be performed by running the script directly:

.. code-block:: shell

  ./tools/deployment/developer/ceph/160-compute-kit.sh

Setup the gateway to the public network
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. literalinclude:: ../../../../tools/deployment/developer/ceph/170-setup-gateway.sh
    :language: shell
    :lines: 1,17-

Alternatively, this step can be performed by running the script directly:

.. code-block:: shell

  ./tools/deployment/developer/ceph/170-setup-gateway.sh
