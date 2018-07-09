====================
Deployment With Ceph
====================

.. note::
  For other deployment options, select appropriate ``Deployment with ...``
  option from `Index <../developer/index.html>`__ page.

Deploy Ceph
^^^^^^^^^^^

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
