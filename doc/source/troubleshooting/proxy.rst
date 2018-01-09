=============
Proxy Setting
=============

This guide is to help enterprise users who wish to deploy OpenStack-Helm
behind a corporate firewall and require a corporate proxy to reach the
internet.

Proxy Environment Variables
===========================

Ensure the following proxy environment variables are defined:

.. code-block:: shell

  export http_proxy="http://username:passwrd@host:port"
  export HTTP_PROXY="http://username:passwrd@host:port"
  export https_proxy="https://username:passwrd@host:port"
  export HTTPS_PROXY="https://username:passwrd@host:port"
  export no_proxy="127.0.0.1,localhost"
  export NO_PROXY="127.0.0.1,localhost"

External DNS
============

In ``tools/images/kubeadm-aio/assets/opt/playbooks/vars.yaml``, under
``external_dns_nameservers``, add the internal DNS IP addresses.
These entries will overwrite the ``/etc/resolv.conf`` on the system.
If your network cannot connect to the Google DNS servers,
``8.8.8.8`` or ``8.8.4.4``, the updates will fail as they cannot resolve
the URLs.

Ansible Playbook
================

Either globally or in the tasks with ``pip`` or ``apt``, ensure you add
the following to the task:

.. code-block:: yaml

  environment:
    http_proxy: http://username:password@host:port
    https_proxy: https://username:password@host:port
    no_proxy: 127.0.0.1,localhost


Docker
======

Docker needs to be configured to use the proxy to pull down external images.
For systemd, use a systemd drop-in directory outlined in
https://docs.docker.com/engine/admin/systemd/#httphttps-proxy.

1. Create a systemd drop-in directory for the docker service:

.. code-block:: shell

  $ sudo mkdir -p /etc/systemd/system/docker.service.d

2. Create a file called ``http-proxy.conf`` in the director created and add
   in the needed environment variable:

.. code-block:: ini

  [Service]
  Environment="HTTP_PROXY=http://username:password@host:port"
  Environment="HTTPS_PROXY=https://username:password@host:port"
  Environment="NO_PROXY=127.0.0.1,localhost,docker-registry.somecorporation.com"

3. Once that's completed, flush the change:

.. code-block:: shell

  $ systemctl daemon-reload

4. Restart Docker:

.. code-block:: shell

  $ systemctl restart docker

5. Verify the configuration has been loaded:

.. code-block:: shell

  $ systemctl show --property=Environment docker
  Environment=HTTP_PROXY=http://proxy.example.com:80/

Kubeadm-AIO Dockerfile
======================

In ``tools/images/kubeadm-aio/Dockerfile``, add the following to the
Dockerfile before ``RUN`` instructions.

.. code-block:: dockerfile

  ENV HTTP_PROXY http://username:password@host:port
  ENV HTTPS_PROXY http://username:password@host:port
  ENV http_proxy http://username:password@host:port
  ENV https_proxy http://username:password@host:port
  ENV no_proxy 127.0.0.1,localhost,172.17.0.1
  ENV NO_PROXY 127.0.0.1,localhost,172.17.0.1

Note the IP address ``172.17.0.1`` is the advertised IP for the kubernetes
API server.  Replace it with the appropriate IP if it is different.
