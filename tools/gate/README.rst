Openstack-Helm Gate Scripts
===========================

These scripts are used in the OpenStack-Helm Gates and can also be run
locally to aid development and for demonstration purposes. Please note
that they assume full control of a machine, and may be destructive in
nature, so should only be run on a dedicated host.

Supported Platforms
~~~~~~~~~~~~~~~~~~~

Currently supported host platforms are:
  * Ubuntu 16.04
  * CentOS 7
  * Fedora 25


Usage (Single Node)
-------------------

The Gate scripts use the ``setup_gate.sh`` as an entrypoint and are
controlled by environment variables, an example of use to run the basic
integration test is below:

.. code:: bash

    export INTEGRATION=aio
    export INTEGRATION_TYPE=basic
    export PVC_BACKEND=ceph
    ./tools/gate/setup_gate.sh


Usage (Multi Node)
------------------

To use for a multinode deployment you simply need to set a few extra environment
variables:

.. code:: bash

    export INTEGRATION=multi
    export INTEGRATION_TYPE=basic
    export PVC_BACKEND=ceph
    #IP of primary node:
    export PRIMARY_NODE_IP=1.2.3.4
    #IP's of subnodes:
    export SUB_NODE_IPS="1.2.3.5 1.2.3.6 1.2.3.7"
    #Location of SSH private key to use with subnodes:
    export SSH_PRIVATE_KEY=/etc/nodepool/id_rsa
    ./tools/gate/setup_gate.sh


Options
-------

Rather than ceph, you may use a nfs based backend. This option is especially
useful on old or low spec machines, though is not currently supported with
Linux Kernels >=4.10:

.. code:: bash

    export PVC_BACKEND=nfs
