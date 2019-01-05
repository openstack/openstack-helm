Libvirt Container
=================

This container builds a small image with Libvirt for use with OpenStack-Helm.

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

Build the Libvirt Image
~~~~~~~~~~~~~~~~~~~~~~~

A known good image is published to dockerhub on a fairly regular basis, but if
you wish to build your own image, from the root directory of the OpenStack-Helm
repo run:

.. code:: bash

    LIBVIRT_VERSION=1.3.1-1ubuntu10.24
    DISTRO=ubuntu
    DISTRO_RELEASE=xenial
    CEPH_RELEASE=mimic

    sudo docker build \
      --network=host \
      --force-rm \
      --pull \
      --no-cache \
      --file=./tools/images/libvirt/Dockerfile.${DISTRO}.xenial \
      --build-arg LIBVIRT_VERSION="${LIBVIRT_VERSION}" \
      --build-arg CEPH_RELEASE="${CEPH_RELEASE}" \
      -t docker.io/openstackhelm/libvirt:${DISTRO}-${DISTRO_RELEASE}-${LIBVIRT_VERSION} \
      tools/images/libvirt
    sudo docker push docker.io/openstackhelm/libvirt:${DISTRO}-${DISTRO_RELEASE}-${LIBVIRT_VERSION}
