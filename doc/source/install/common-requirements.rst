===============================
Commmon Deployment Requirements
===============================

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
