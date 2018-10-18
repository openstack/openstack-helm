===================================
Requirements and Host Configuration
===================================

Overview
========

Below are some instructions and suggestions to help you get started with a
Kubeadm All-in-One environment on Ubuntu 16.04.
Other supported versions of Linux can also be used, with the appropriate changes
to package installation.

Requirements
============

.. warning:: Until the Ubuntu kernel shipped with 16.04 supports CephFS
   subvolume mounts by default the `HWE Kernel
   <../../troubleshooting/ubuntu-hwe-kernel.html>`__ is required to use CephFS.

System Requirements
-------------------

The recommended minimum system requirements for a full deployment are:

- 16GB of RAM
- 8 Cores
- 48GB HDD

For a deployment without cinder and horizon the system requirements are:

- 8GB of RAM
- 4 Cores
- 48GB HDD

This guide covers the minimum number of requirements to get started.

All commands below should be run as a normal user, not as root.
Appropriate versions of Docker, Kubernetes, and Helm will be installed
by the playbooks used below, so there's no need to install them ahead of time.

.. warning:: By default the Calico CNI will use ``192.168.0.0/16`` and
   Kubernetes services will use ``10.96.0.0/16`` as the CIDR for services. Check
   that these CIDRs are not in use on the development node before proceeding, or
   adjust as required.

Host Configuration
------------------

OpenStack-Helm uses the hosts networking namespace for many pods including,
Ceph, Neutron and Nova components. For this, to function, as expected pods need
to be able to resolve DNS requests correctly. Ubuntu Desktop and some other
distributions make use of ``mdns4_minimal`` which does not operate as Kubernetes
expects with its default TLD of ``.local``. To operate at expected either
change the ``hosts`` line in the ``/etc/nsswitch.conf``, or confirm that it
matches:

.. code-block:: ini

  hosts:          files dns
