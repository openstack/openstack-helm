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

Next, you need to update the dependencies for all the charts in both OpenStack-Helm
repositories. This can be done by running the following commands:

.. code-block:: bash

    cd ~/osh/openstack-helm
    ./tools/deployment/common/prepare-charts.sh

Also before deploying the OpenStack cluster you have to specify the
OpenStack and the operating system version that you would like to use
for deployment. For doing this export the following environment variables

.. code-block:: bash

    export OPENSTACK_RELEASE=2024.1
    export FEATURES="${OPENSTACK_RELEASE} ubuntu_jammy"

.. note::
    The list of supported versions can be found :doc:`here </readme>`.
