Deploy OpenStack
================

Check list before deployment
----------------------------

At this point we assume all the prerequisites listed below are met:

- Kubernetes cluster is up and running.
- `kubectl`_ and `helm`_ command line tools are installed and
  configured to access the cluster.
- The OpenStack-Helm repositories are enabled, OpenStack-Helm
  plugin is installed and necessary environment variables are set.
- The ``openstack`` namespace is created.
- Ingress controller is deployed in the ``openstack`` namespace.
- MetalLB is deployed and configured. The service of type
  ``LoadBalancer`` is created and DNS is configured to resolve the
  Openstack endpoint names to the IP address of the service.
- Ceph is deployed and enabled for using by OpenStack-Helm.

.. _kubectl: https://kubernetes.io/docs/tasks/tools/install-kubectl/
.. _helm: https://helm.sh/docs/intro/install/


Environment variables
---------------------

First let's set environment variables that are later used in the subsequent sections:

.. code-block:: bash

    export OPENSTACK_RELEASE=2024.1
    # Features enabled for the deployment. This is used to look up values overrides.
    export FEATURES="${OPENSTACK_RELEASE} ubuntu_jammy"
    # Directory where values overrides are looked up or downloaded to.
    export OVERRIDES_DIR=$(pwd)/overrides

Get values overrides
--------------------

OpenStack-Helm provides values overrides for predefined feature sets and various
OpenStack/platform versions. The overrides are stored in the OpenStack-Helm
git repositories and OpenStack-Helm plugin provides a command to look them up
locally and download (optional) if not found.

Please read the help:

.. code-block:: bash

    helm osh get-values-overrides --help

For example, if you pass the feature set ``2024.1 ubuntu_jammy`` it will try to
look up the following files:

.. code-block:: bash

    2024.1.yaml
    ubuntu_jammy.yaml
    2024.1-ubuntu_jammy.yaml

Let's download the values overrides for the feature set defined above:

.. code-block:: bash

    INFRA_OVERRIDES_URL=https://opendev.org/openstack/openstack-helm-infra/raw/branch/master
    for chart in rabbitmq mariadb memcached openvswitch libvirt; do
        helm osh get-values-overrides -d -u ${INFRA_OVERRIDES_URL} -p ${OVERRIDES_DIR} -c ${chart} ${FEATURES}
    done

    OVERRIDES_URL=https://opendev.org/openstack/openstack-helm/raw/branch/master
    for chart in keystone heat glance cinder placement nova neutron horizon; do
        helm osh get-values-overrides -d -u ${OVERRIDES_URL} -p ${OVERRIDES_DIR} -c ${chart} ${FEATURES}
    done

Now you can inspect the downloaded files in the ``${OVERRIDES_DIR}`` directory and
adjust them if needed.

OpenStack backend
-----------------

OpenStack is a cloud computing platform that consists of a variety of
services, and many of these services rely on backend services like RabbitMQ,
MariaDB, and Memcached for their proper functioning. These backend services
play crucial role in OpenStack architecture.

RabbitMQ
~~~~~~~~
RabbitMQ is a message broker that is often used in OpenStack to handle
messaging between different components and services. It helps in managing
communication and coordination between various parts of the OpenStack
infrastructure. Services like Nova (compute), Neutron (networking), and
Cinder (block storage) use RabbitMQ to exchange messages and ensure
proper orchestration.

Use the following script to deploy RabbitMQ service:

.. code-block:: bash

    helm upgrade --install rabbitmq openstack-helm-infra/rabbitmq \
        --namespace=openstack \
        --set pod.replicas.server=1 \
        --timeout=600s \
        $(helm osh get-values-overrides -p ${OVERRIDES_DIR} -c rabbitmq ${FEATURES})

    helm osh wait-for-pods openstack

MariaDB
~~~~~~~
Database services like MariaDB are used as a backend database for majority of
OpenStack projects. These databases store critical information such as user
credentials, service configurations, and data related to instances, networks,
and volumes. Services like Keystone (identity), Nova, Glance (image), and
Cinder rely on MariaDB for data storage.

.. code-block:: bash

    helm upgrade --install mariadb openstack-helm-infra/mariadb \
        --namespace=openstack \
        --set pod.replicas.server=1 \
        $(helm osh get-values-overrides -p ${OVERRIDES_DIR} -c mariadb ${FEATURES})

    helm osh wait-for-pods openstack

Memcached
~~~~~~~~~
Memcached is a distributed memory object caching system that is often used
in OpenStack to improve performance. OpenStack services cache frequently
accessed data in Memcached, which helps in faster
data retrieval and reduces the load on the database backend.

.. code-block:: bash

    helm upgrade --install memcached openstack-helm-infra/memcached \
        --namespace=openstack \
        $(helm osh get-values-overrides -p ${OVERRIDES_DIR} -c memcached ${FEATURES})

    helm osh wait-for-pods openstack

OpenStack
---------

Now we are ready for the deployment of OpenStack components.
Some of them are mandatory while others are optional.

Keystone
~~~~~~~~

OpenStack Keystone is the identity and authentication service
for the OpenStack cloud computing platform. It serves as the
central point of authentication and authorization, managing user
identities, roles, and access to OpenStack resources. Keystone
ensures secure and controlled access to various OpenStack services,
making it an integral component for user management and security
in OpenStack deployments.

This is a ``mandatory`` component of any OpenStack cluster.

To deploy the Keystone service run the following:

.. code-block:: bash

    helm upgrade --install keystone openstack-helm/keystone \
        --namespace=openstack \
        $(helm osh get-values-overrides -p ${OVERRIDES_DIR} -c keystone ${FEATURES})

    helm osh wait-for-pods openstack

Heat
~~~~

OpenStack Heat is an orchestration service that provides templates
and automation for deploying and managing cloud resources. It enables
users to define infrastructure as code, making it easier to create
and manage complex environments in OpenStack through templates and
automation scripts.

Here are the commands for the deployment of Heat service.

.. code-block:: bash

    helm upgrade --install heat openstack-helm/heat \
        --namespace=openstack \
        $(helm osh get-values-overrides -p ${OVERRIDES_DIR} -c heat ${FEATURES})

    helm osh wait-for-pods openstack

Glance
~~~~~~

OpenStack Glance is the image service component of OpenStack.
It manages and catalogs virtual machine images, such as operating
system images and snapshots, making them available for use in
OpenStack compute instances.

This is a ``mandatory`` component.

The Glance deployment commands are as follows:

.. code-block:: bash

    tee ${OVERRIDES_DIR}/glance/values_overrides/glance_pvc_storage.yaml <<EOF
    storage: pvc
    volume:
      class_name: general
      size: 10Gi
    EOF

    helm upgrade --install glance openstack-helm/glance \
        --namespace=openstack \
        $(helm osh get-values-overrides -p ${OVERRIDES_DIR} -c glance glance_pvc_storage ${FEATURES})

    helm osh wait-for-pods openstack

.. note::

    In the above we prepare a values override file for ``glance`` chart which
    makes it use a Persistent Volume Claim (PVC) for storing images. We put
    the values in the ``${OVERRIDES_DIR}/glance/values_overrides/glance_pvc_storage.yaml``
    so the OpenStack-Helm plugin can pick it up if we pass the feature
    ``glance_pvc_storage`` to it.

Cinder
~~~~~~

OpenStack Cinder is the block storage service component of the
OpenStack cloud computing platform. It manages and provides persistent
block storage to virtual machines, enabling users to attach and detach
persistent storage volumes to their VMs as needed.

To deploy the OpenStack Cinder use the following

.. code-block:: bash

    helm upgrade --install cinder openstack-helm/cinder \
        --namespace=openstack \
        --timeout=600s \
        $(helm osh get-values-overrides -p ${OVERRIDES_DIR} -c cinder ${FEATURES})

    helm osh wait-for-pods openstack

Compute kit backend: Openvswitch and Libvirt
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

OpenStack-Helm recommends using OpenvSwitch as the networking backend
for the OpenStack cloud. OpenvSwitch is a software-based, open-source
networking solution that provides virtual switching capabilities.

To deploy the OpenvSwitch service use the following:

.. code-block:: bash

    helm upgrade --install openvswitch openstack-helm-infra/openvswitch \
        --namespace=openstack \
        $(helm osh get-values-overrides -p ${OVERRIDES_DIR} -c openvswitch ${FEATURES})

    helm osh wait-for-pods openstack

Libvirt is a toolkit that provides a common API for managing virtual
machines. It is used in OpenStack to interact with hypervisors like
KVM, QEMU, and Xen.

Let's deploy the Libvirt service using the following command:

.. code-block:: bash

    helm upgrade --install libvirt openstack-helm-infra/libvirt \
        --namespace=openstack \
        --set conf.ceph.enabled=true \
        $(helm osh get-values-overrides -p ${OVERRIDES_DIR} -c libvirt ${FEATURES})

.. note::
    Here we don't need to run ``helm osh wait-for-pods`` because the Libvirt pods
    depend on Neutron OpenvSwitch agent pods which are not yet deployed.

Compute kit: Placement, Nova, Neutron
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

OpenStack Placement is a service that helps manage and allocate
resources in an OpenStack cloud environment. It helps Nova (compute)
find and allocate the right resources (CPU, memory, etc.)
for virtual machine instances.

.. code-block:: bash

    helm upgrade --install placement openstack-helm/placement \
        --namespace=openstack \
        $(helm osh get-values-overrides -p ${OVERRIDES_DIR} -c placement ${FEATURES})

OpenStack Nova is the compute service responsible for managing
and orchestrating virtual machines in an OpenStack cloud.
It provisions and schedules instances, handles their lifecycle,
and interacts with underlying hypervisors.

.. code-block:: bash

    helm upgrade --install nova openstack-helm/nova \
        --namespace=openstack \
        --set bootstrap.wait_for_computes.enabled=true \
        --set conf.ceph.enabled=true \
        $(helm osh get-values-overrides -p ${OVERRIDES_DIR} -c nova ${FEATURES})

OpenStack Neutron is the networking service that provides network
connectivity and enables users to create and manage network resources
for their virtual machines and other services.

.. code-block:: bash

    PROVIDER_INTERFACE=<provider_interface_name>
    tee ${OVERRIDES_DIR}/neutron/values_overrides/neutron_simple.yaml << EOF
    conf:
      neutron:
        DEFAULT:
          l3_ha: False
          max_l3_agents_per_router: 1
      # <provider_interface_name> will be attached to the br-ex bridge.
      # The IP assigned to the interface will be moved to the bridge.
      auto_bridge_add:
        br-ex: ${PROVIDER_INTERFACE}
      plugins:
        ml2_conf:
          ml2_type_flat:
            flat_networks: public
        openvswitch_agent:
          ovs:
            bridge_mappings: public:br-ex
    EOF

    helm upgrade --install neutron openstack-helm/neutron \
        --namespace=openstack \
        $(helm osh get-values-overrides -p ${OVERRIDES_DIR} -c neutron neutron_simple ${FEATURES})

    helm osh wait-for-pods openstack

Horizon
~~~~~~~

OpenStack Horizon is the web application that is intended to provide a graphic
user interface to Openstack services.

Let's deploy it:

.. code-block:: bash

    helm upgrade --install horizon openstack-helm/horizon \
        --namespace=openstack \
        $(helm osh get-values-overrides -p ${OVERRIDES_DIR} -c horizon ${FEATURES})

    helm osh wait-for-pods openstack

OpenStack client
----------------

Installing the OpenStack client on the developer's machine is a vital step.
The easiest way to install the OpenStack client is to create a Python
virtual environment and install the client using ``pip``.

.. code-block:: bash

    python3 -m venv ~/openstack-client
    source ~/openstack-client/bin/activate
    pip install python-openstackclient

Now let's prepare the OpenStack client configuration file:

.. code-block:: bash

    mkdir -p ~/.config/openstack
    tee ~/.config/openstack/clouds.yaml << EOF
    clouds:
      openstack_helm:
        region_name: RegionOne
        identity_api_version: 3
        auth:
          username: 'admin'
          password: 'password'
          project_name: 'admin'
          project_domain_name: 'default'
          user_domain_name: 'default'
          auth_url: 'http://keystone.openstack.svc.cluster.local/v3'

That is it! Now you can use the OpenStack client. Try to run this:

.. code-block:: bash

    openstack --os-cloud openstack_helm endpoint list

.. note::

    In some cases it is more convenient to use the OpenStack client
    inside a Docker container. OpenStack-Helm provides the
    `openstackhelm/openstack-client`_ image. The below is an example
    of how to use it.


.. code-block:: bash

    docker run -it --rm --network host \
        -v ~/.config/openstack/clouds.yaml:/etc/openstack/clouds.yaml \
        -e OS_CLOUD=openstack_helm \
        docker.io/openstackhelm/openstack-client:${OPENSTACK_RELEASE} \
        openstack endpoint list

Remember that the container file system is ephemeral and is destroyed
when you stop the container. So if you would like to use the
Openstack client capabilities interfacing with the file system then you have to mount
a directory from the host file system where necessary files are located.
For example, this is useful when you create a key pair and save the private key in a file
which is then used for ssh access to VMs. Or it could be Heat templates
which you prepare in advance and then use with Openstack client.

For convenience, you can create an executable entry point that runs the
Openstack client in a Docker container. See for example `setup-client.sh`_.

.. _setup-client.sh: https://opendev.org/openstack/openstack-helm/src/branch/master/tools/deployment/common/setup-client.sh
.. _openstackhelm/openstack-client: https://hub.docker.com/r/openstackhelm/openstack-client/tags?page=&page_size=&ordering=&name=


Other Openstack components (optional)
-------------------------------------

Barbican
~~~~~~~~

OpenStack Barbican is a component within the OpenStack ecosystem that
provides secure storage, provisioning, and management of secrets,
such as encryption keys, certificates, and passwords.

If you want other OpenStack services to use Barbican for secret management,
you'll need to reconfigure those services to integrate with Barbican.
Each OpenStack service has its own configuration settings
that need to be updated.

.. code-block:: bash

    helm upgrade --install barbican openstack-helm/barbican \
        --namespace=openstack \
        $(helm osh get-values-overrides -p ${OVERRIDES_DIR} -c barbican ${FEATURES})

    helm osh wait-for-pods openstack

Tacker
~~~~~~

Tacker is an OpenStack service for NFV Orchestration with a general
purpose VNF Manager to deploy and operate Virtual Network Functions
(VNFs) and Network Services on an NFV Platform. It is based on ETSI MANO
Architectural Framework and provides OpenStack's NFV Orchestration API.

.. note::

    Barbican must be installed before Tacker, as it is a necessary component for
    Tacker's installation.

To deploy the OpenStack Tacker, use the following:

.. code-block:: bash

    helm upgrade --install tacker openstack-helm/tacker \
        --namespace=openstack \
        $(helm osh get-values-overrides -p ${OVERRIDES_DIR} -c tacker ${FEATURES})

    helm osh wait-for-pods openstack

For comprehensive instructions on installing Tacker using Openstack Helm,
please refer `Install Tacker via Openstack Helm`_.

.. _Install Tacker via Openstack Helm: https://docs.openstack.org/tacker/latest/install/openstack_helm.html
