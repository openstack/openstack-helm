VBMC Container
==============

This container builds a small image with kubectl and some other utilities for
use in both the ironic checks and development.

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

    sudo docker build \
      --network=host \
      -t docker.io/openstackhelm/vbmc:centos-0.1 \
      tools/images/vbmc
    sudo docker push docker.io/openstackhelm/vbmc:centos-0.1
