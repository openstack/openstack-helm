MariaDB Container
=================

This container builds an image with MariaDB for use with OpenStack-Helm.

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

Build the MariaDB Image
~~~~~~~~~~~~~~~~~~~~~~~

A known good image is published to dockerhub on a fairly regular basis, but if
you wish to build your own image, from the root directory of the OpenStack-Helm
repo run:

.. code:: bash

    sudo docker build \
      --network=host \
      --force-rm \
      --pull \
      --no-cache \
      --file=./tools/images/mariadb/Dockerfile \
      -t docker.io/openstackhelm/mariadb:10.2.18 \
      tools/images/mariadb
    sudo docker push docker.io/openstackhelm/mariadb:10.2.18
