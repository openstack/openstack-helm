Deploy OpenStack
================

Now we are ready for the deployment of OpenStack components.
Some of them are mandatory while others are optional.

Keystone
--------

OpenStack Keystone is the identity and authentication service
for the OpenStack cloud computing platform. It serves as the
central point of authentication and authorization, managing user
identities, roles, and access to OpenStack resources. Keystone
ensures secure and controlled access to various OpenStack services,
making it an integral component for user management and security
in OpenStack deployments.

This is a ``mandatory`` component of any OpenStack cluster.

To deploy the Keystone service run the script `keystone.sh`_

.. code-block:: bash

    cd ~/osh/openstack-helm
    ./tools/deployment/component/keystone/keystone.sh


Heat
----

OpenStack Heat is an orchestration service that provides templates
and automation for deploying and managing cloud resources. It enables
users to define infrastructure as code, making it easier to create
and manage complex environments in OpenStack through templates and
automation scripts.

Here is the script `heat.sh`_ for the deployment of Heat service.

.. code-block:: bash

    cd ~/osh/openstack-helm
    ./tools/deployment/component/heat/heat.sh

Glance
------

OpenStack Glance is the image service component of OpenStack.
It manages and catalogs virtual machine images, such as operating
system images and snapshots, making them available for use in
OpenStack compute instances.

This is a ``mandatory`` component.

The Glance deployment script is here `glance.sh`_.

.. code-block:: bash

    cd ~/osh/openstack-helm
    ./tools/deployment/component/glance/glance.sh

Placement, Nova, Neutron
------------------------

OpenStack Placement is a service that helps manage and allocate
resources in an OpenStack cloud environment. It helps Nova (compute)
find and allocate the right resources (CPU, memory, etc.)
for virtual machine instances.

OpenStack Nova is the compute service responsible for managing
and orchestrating virtual machines in an OpenStack cloud.
It provisions and schedules instances, handles their lifecycle,
and interacts with underlying hypervisors.

OpenStack Neutron is the networking service that provides network
connectivity and enables users to create and manage network resources
for their virtual machines and other services.

These three services are ``mandatory`` and together constitue
so-called ``compute kit``.

To set up the compute service, the first step involves deploying the
hypervisor backend using the `libvirt.sh`_ script. By default, the
networking service is deployed with OpenvSwitch as the networking
backend, and the deployment script for OpenvSwitch can be found
here: `openvswitch.sh`_. And finally the deployment script for
Placement, Nova and Neutron is here: `compute-kit.sh`_.

.. code-block:: bash

    cd ~/osh/openstack-helm
    ./tools/deployment/component/compute-kit/openvswitch.sh
    ./tools/deployment/component/compute-kit/libvirt.sh
    ./tools/deployment/component/compute-kit/compute-kit.sh

Cinder
------

OpenStack Cinder is the block storage service component of the
OpenStack cloud computing platform. It manages and provides persistent
block storage to virtual machines, enabling users to attach and detach
persistent storage volumes to their VMs as needed.

To deploy the OpenStack Cinder service use the script `cinder.sh`_

.. code-block:: bash

    cd ~/osh/openstack-helm
    ./tools/deployment/component/cinder/cinder.sh

Horizon
-------

OpenStack Horizon is the web application that is intended to provide a graphic
user interface to Openstack services.

To deploy the OpenStack Horizon use the following script `horizon.sh`_

.. code-block:: bash

    cd ~/osh/openstack-helm
    ./tools/deployment/component/horizon/horizon.sh

.. _keystone.sh: https://opendev.org/openstack/openstack-helm/src/branch/master/tools/deployment/component/keystone/keystone.sh
.. _heat.sh: https://opendev.org/openstack/openstack-helm/src/branch/master/tools/deployment/component/heat/heat.sh
.. _glance.sh: https://opendev.org/openstack/openstack-helm/src/branch/master/tools/deployment/component/glance/glance.sh
.. _libvirt.sh: https://opendev.org/openstack/openstack-helm/src/branch/master/tools/deployment/component/compute-kit/libvirt.sh
.. _openvswitch.sh: https://opendev.org/openstack/openstack-helm/src/branch/master/tools/deployment/component/compute-kit/openvswitch.sh
.. _compute-kit.sh: https://opendev.org/openstack/openstack-helm/src/branch/master/tools/deployment/component/compute-kit/compute-kit.sh
.. _cinder.sh: https://opendev.org/openstack/openstack-helm/src/branch/master/tools/deployment/component/cinder/cinder.sh
.. _horizon.sh: https://opendev.org/openstack/openstack-helm/src/branch/master/tools/deployment/component/horizon/horizon.sh
