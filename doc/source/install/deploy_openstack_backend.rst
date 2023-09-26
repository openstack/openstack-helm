Deploy OpenStack backend
========================

OpenStack is a cloud computing platform that consists of a variety of
services, and many of these services rely on backend services like RabbitMQ,
MariaDB, and Memcached for their proper functioning. These backend services
play crucial roles in OpenStack's architecture.

RabbitMQ
~~~~~~~~
RabbitMQ is a message broker that is often used in OpenStack to handle
messaging between different components and services. It helps in managing
communication and coordination between various parts of the OpenStack
infrastructure. Services like Nova (compute), Neutron (networking), and
Cinder (block storage) use RabbitMQ to exchange messages and ensure
proper orchestration.

MariaDB
~~~~~~~
Database services like MariaDB are used as the backend database for several
OpenStack services. These databases store critical information such as user
credentials, service configurations, and data related to instances, networks,
and volumes. Services like Keystone (identity), Nova, Glance (image), and
Cinder rely on MariaDB for data storage.

Memcached
~~~~~~~~~
Memcached is a distributed memory object caching system that is often used
in OpenStack to improve performance and reduce database load. OpenStack
services cache frequently accessed data in Memcached, which helps in faster
data retrieval and reduces the load on the database backend. Services like
Keystone and Nova can benefit from Memcached for caching.

Deployment
----------

The following scripts `rabbitmq.sh`_, `mariadb.sh`_, `memcached.sh`_ can be used to
deploy the backend services.

.. code-block:: bash

    cd ~/osh/openstack-helm
    ./tools/deployment/component/common/rabbitmq.sh
    ./tools/deployment/component/common/mariadb.sh
    ./tools/deployment/component/common/memcached.sh

.. note::
    These scripts use Helm charts from the `openstack-helm-infra`_ repository. We assume
    this repo is cloned to the `~/osh` directory. See this :doc:`section </install/before_deployment>`.

.. _rabbitmq.sh: https://opendev.org/openstack/openstack-helm/src/branch/master/tools/deployment/component/common/rabbitmq.sh
.. _mariadb.sh: https://opendev.org/openstack/openstack-helm/src/branch/master/tools/deployment/component/common/mariadb.sh
.. _memcached.sh: https://opendev.org/openstack/openstack-helm/src/branch/master/tools/deployment/component/common/memcached.sh
.. _openstack-helm-infra: https://opendev.org/openstack/openstack-helm-infra.git
