=================
Ubuntu HWE Kernel
=================

To make use of CephFS in Ubuntu the HWE Kernel is required, until the issue
described `here <https://github.com/kubernetes-incubator/external-storage/issues/345>`_
is fixed.

Installation
============

To deploy the HWE kernel, prior to deploying Kubernetes and OpenStack-Helm
the following commands should be run on each node:

.. code-block:: shell

    #!/bin/bash
    sudo -H apt-get update
    sudo -H apt-get install -y linux-generic-hwe-16.04
    sudo -H reboot now
