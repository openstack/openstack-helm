Ceph Config Helper Container
============================

This container builds a small image with kubectl and some other utilites for
use in the ceph-config chart.

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

Build the Ceph-Helper Image environment (optional)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

A known good image is published to dockerhub on a fairly regular basis, but if
you wish to build your own image, from the root directory of the OpenStack-Helm
repo run:

.. code:: bash

    export KUBE_VERSION=v1.10.3
    sudo docker build \
      --network host \
      --build-arg KUBE_VERSION=${KUBE_VERSION} \
      -t docker.io/port/ceph-config-helper:${KUBE_VERSION} \
      tools/images/ceph-config-helper
    sudo docker push docker.io/port/ceph-config-helper:${KUBE_VERSION}
