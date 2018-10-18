==============================
Common Deployment Requirements
==============================

Passwordless Sudo
=================

Throughout this guide the assumption is that the user is:
``ubuntu``. Because this user has to execute root level commands
remotely to other nodes, it is advised to add the following lines
to ``/etc/sudoers`` for each node:

.. code-block:: shell

  root    ALL=(ALL) NOPASSWD: ALL
  ubuntu  ALL=(ALL) NOPASSWD: ALL

Latest Version Installs
=======================

On the host or master node, install the latest versions of Git, CA Certs & Make if necessary

.. literalinclude:: ../../../tools/deployment/developer/common/000-install-packages.sh
    :language: shell
    :lines: 1,17-

Proxy Configuration
===================

.. note:: This guide assumes that users wishing to deploy behind a proxy have already
          defined the conventional proxy environment variables ``http_proxy``,
          ``https_proxy``, and ``no_proxy``.

In order to deploy OpenStack-Helm behind corporate proxy servers, add the
following entries to ``openstack-helm-infra/tools/gate/devel/local-vars.yaml``.

.. code-block:: yaml

  proxy:
    http: http://username:password@host:port
    https: https://username:password@host:port
    noproxy: 127.0.0.1,localhost,172.17.0.1,.svc.cluster.local

.. note:: The ``.svc.cluster.local`` address is required to allow the OpenStack
  client to communicate without being routed through proxy servers. The IP
  address ``172.17.0.1`` is the advertised IP address for the Kubernetes API
  server. Replace the addresses if your configuration does not match the
  one defined above.

Add the address of the Kubernetes API, ``172.17.0.1``, and
``.svc.cluster.local`` to your ``no_proxy`` and ``NO_PROXY`` environment
variables.

.. code-block:: bash

  export no_proxy=${no_proxy},172.17.0.1,.svc.cluster.local
  export NO_PROXY=${NO_PROXY},172.17.0.1,.svc.cluster.local

