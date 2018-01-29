Gate Utils Container
====================

This container builds a small image with ipcalc for use in both the multinode
checks and development.

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

Build the Gate Utils Image
~~~~~~~~~~~~~~~~~~~~~~~~~~

A known good image is published to dockerhub on a fairly regular basis, but if
you wish to build your own image, from the root directory of the OpenStack-Helm
repo run:

.. code:: bash

    sudo docker build \
      -t docker.io/openstackhelm/gate-utils:v0.1.0 \
      tools/images/gate-utils
    sudo docker push docker.io/openstackhelm/gate-utils:v0.1.0
