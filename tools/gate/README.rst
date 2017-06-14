Openstack-Helm Gate Scripts
===========================

These scripts are used in the OpenStack-Helm Gates and can also be run
locally to aid development and for demonstration purposes. Please note
that they assume full control of a machine, and may be destructive in
nature, so should only be run on a dedicated host.

Usage
-----

The Gate scripts use the ``setup_gate.sh`` as an entrypoint and are
controlled by environment variables, an example of use to run the basic
integration test is below:

.. code:: bash

    export INTEGRATION=aio
    export INTEGRATION_TYPE=basic
    export PVC_BACKEND=ceph
    ./tools/gate/setup_gate.sh

Supported Platforms
~~~~~~~~~~~~~~~~~~~

Currently supported host platforms are: \* Ubuntu 16.04 \* CentOS 7

With some preparation to docker, and disabling of SELinux operation of
Fedora 25 is also supported.
