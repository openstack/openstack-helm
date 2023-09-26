Before deployment
=================

Before proceeding with the steps outlined in the following
sections and executing the actions detailed therein, it is
imperative that you clone the essential Git repositories
containing all the required Helm charts, deployment scripts,
and Ansible roles. This preliminary step will ensure that
you have access to the necessary assets for a seamless
deployment process.

.. code-block:: bash

    mkdir ~/osh
    cd ~/osh
    git clone https://opendev.org/openstack/openstack-helm.git
    git clone https://opendev.org/openstack/openstack-helm-infra.git


All further steps assume these two repositories are cloned into the
`~/osh` directory.

Also before deploying the OpenStack cluster you have to specify the
OpenStack and the operating system version that you would like to use
for deployment. For doing this export the following environment variables

.. code-block:: bash

    export OPENSTACK_RELEASE=2023.2
    export CONTAINER_DISTRO_NAME=ubuntu
    export CONTAINER_DISTRO_VERSION=jammy

.. note::
    The list of supported versions can be found :doc:`here </readme>`.
