Before starting
===============

The OpenStack-Helm charts are published in the `openstack-helm`_ helm repository.
Let's enable it:

.. code-block:: bash

    helm repo add openstack-helm https://tarballs.opendev.org/openstack/openstack-helm

The OpenStack-Helm `plugin`_ provides some helper commands used later on.
So, let's install it:

.. code-block:: bash

    helm plugin install https://opendev.org/openstack/openstack-helm-plugin

.. _openstack-helm: https://tarballs.opendev.org/openstack/openstack-helm
.. _plugin: https://opendev.org/openstack/openstack-helm-plugin.git
