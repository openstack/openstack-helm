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

    TARGET_OPENSTACK_VERSION=ocata
    DISTRO=ubuntu
    DISTRO_RELEASE=xenial
    CEPH_RELEASE=luminous

    sudo docker build \
      --network=host \
      --force-rm \
      --pull \
      --no-cache \
      --file=./tools/images/libvirt/Dockerfile.${DISTRO}.xenial \
      --build-arg TARGET_OPENSTACK_VERSION="${TARGET_OPENSTACK_VERSION}" \
      --build-arg CEPH_RELEASE="${CEPH_RELEASE}" \
      -t docker.io/openstackhelm/libvirt:${DISTRO}-${DISTRO_RELEASE}-${TARGET_OPENSTACK_VERSION} \
      tools/images/libvirt
    sudo docker push docker.io/openstackhelm/libvirt:${DISTRO}-${DISTRO_RELEASE}-${TARGET_OPENSTACK_VERSION}
