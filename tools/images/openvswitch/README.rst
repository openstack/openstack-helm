OpenvSwitch Container
=====================

This container builds a small image with OpenvSwitch.

Instructions
------------

OS Specific Host setup:
~~~~~~~~~~~~~~~~~~~~~~~

Ubuntu:
^^^^^^^

From a freshly provisioned Ubuntu 16.04 LTS host run:

.. code:: bash

    sudo apt-get update -y
    sudo apt-get install -y \
            docker.io \
            git

Build the VBMC Image environment
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

A known good image is published to dockerhub on a fairly regular basis, but if
you wish to build your own image, from the root directory of the OpenStack-Helm
repo run:

.. code:: bash

    OVS_VERSION=2.8.1
    sudo docker build \
      --network=host \
      --build-arg OVS_VERSION="${OVS_VERSION}" \
      -t docker.io/openstackhelm/openvswitch:v${OVS_VERSION} \
      tools/images/openvswitch
    sudo docker push docker.io/openstackhelm/openvswitch:v${OVS_VERSION}
