Before starting
===============

The OpenStack-Helm charts are published in the `openstack-helm`_ and
`openstack-helm-infra`_ helm repositories. Let's enable them:

.. code-block:: bash

    helm repo add openstack-helm https://tarballs.opendev.org/openstack/openstack-helm
    helm repo add openstack-helm-infra https://tarballs.opendev.org/openstack/openstack-helm-infra

The OpenStack-Helm `plugin`_ provides some helper commands used later on.
So, let's install it:

.. code-block:: bash

    helm plugin install https://opendev.org/openstack/openstack-helm-plugin

.. _openstack-helm: https://tarballs.opendev.org/openstack/openstack-helm
.. _openstack-helm-infra: https://tarballs.opendev.org/openstack/openstack-helm-infra
.. _plugin: https://opendev.org/openstack/openstack-helm-plugin.git
