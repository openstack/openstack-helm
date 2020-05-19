===================================
Requirements and Host Configuration
===================================

Overview
========

Below are some instructions and suggestions to help you get started with a
Kubeadm All-in-One environment on Ubuntu 18.04.
Other supported versions of Linux can also be used, with the appropriate changes
to package installation.

Requirements
============

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

Host Proxy & DNS Configuration
------------------------------

.. note::

  If you are not deploying OSH behind a proxy, skip this step.

Set your local environment variables to use the proxy information. This
involves adding or setting the following values in ``/etc/environment``:

.. code-block:: shell

  export http_proxy="YOUR_PROXY_ADDRESS:PORT"
  export https_proxy="YOUR_PROXY_ADDRESS:PORT"
  export ftp_proxy="YOUR_PROXY_ADDRESS:PORT"
  export no_proxy="localhost,127.0.0.1,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16,172.17.0.1,.svc.cluster.local,$YOUR_ACTUAL_IP"
  export HTTP_PROXY="YOUR_PROXY_ADDRESS:PORT"
  export HTTPS_PROXY="YOUR_PROXY_ADDRESS:PORT"
  export FTP_PROXY="YOUR_PROXY_ADDRESS:PORT"
  export NO_PROXY="localhost,127.0.0.1,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16,172.17.0.1,.svc.cluster.local,$YOUR_ACTUAL_IP"


.. note::
  Depending on your specific proxy, https_proxy may be the same as http_proxy.
  Refer to your specific proxy documentation.

Your changes to `/etc/environment` will not be applied until you source them:

.. code-block:: shell

  source /etc/environment

OSH runs updates for local apt packages, so we will need to set the proxy for
apt as well by adding these lines to `/etc/apt/apt.conf`:

.. code-block:: shell

  Acquire::http::proxy "YOUR_PROXY_ADDRESS:PORT";
  Acquire::https::proxy "YOUR_PROXY_ADDRESS:PORT";
  Acquire::ftp::proxy "YOUR_PROXY_ADDRESS:PORT";

.. note::
  Depending on your specific proxy, https_proxy may be the same as http_proxy.
  Refer to your specific proxy documentation.
