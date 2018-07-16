=====================
Gate-Based Kubernetes
=====================

Overview
========

You can use any Kubernetes deployment tool to bring up a working Kubernetes
cluster for use with OpenStack-Helm. This guide describes how to simply stand
up a multinode Kubernetes cluster via the OpenStack-Helm gate scripts,
which use KubeADM and Ansible. Although this cluster won't be
production-grade, it will serve as a quick starting point in a lab or
proof-of-concept environment.

OpenStack-Helm-Infra KubeADM deployment
=======================================

On the worker nodes:

.. code-block:: shell

    #!/bin/bash
    set -xe
    sudo apt-get update
    sudo apt-get install --no-install-recommends -y git


SSH-Key preparation
-------------------

Create an ssh-key on the master node, and add the public key to each node that
you intend to join the cluster.

.. note::
   1. To generate the key you can use ``ssh-keygen -t rsa``
   2. To copy the ssh key to each node, this can be accomplished with
      the ``ssh-copy-id`` command, for example: *ssh-copy-id
      ubuntu@192.168.122.178*
   3. Copy the key: ``sudo cp ~/.ssh/id_rsa /etc/openstack-helm/deploy-key.pem``
   4. Set correct ownership: ``sudo chown ubuntu
      /etc/openstack-helm/deploy-key.pem``

   Test this by ssh'ing to a node and then executing a command with
   'sudo'. Neither operation should require a password.

Clone the OpenStack-Helm Repos
------------------------------

Once the host has been configured the repos containing the OpenStack-Helm charts
should be cloned onto each node in the cluster:

.. code-block:: shell

    #!/bin/bash
    set -xe

    sudo chown -R ubuntu: /opt
    git clone https://git.openstack.org/openstack/openstack-helm-infra.git /opt/openstack-helm-infra
    git clone https://git.openstack.org/openstack/openstack-helm.git /opt/openstack-helm


Create an inventory file
------------------------

On the master node create an inventory file for the cluster:

.. note::
   node_one, node_two and node_three below are all worker nodes,
   children of the master node that the commands below are executed on.

.. code-block:: shell

    #!/bin/bash
    set -xe
    cat > /opt/openstack-helm-infra/tools/gate/devel/multinode-inventory.yaml <<EOF
    all:
      children:
        primary:
          hosts:
            node_one:
              ansible_port: 22
              ansible_host: $node_one_ip
              ansible_user: ubuntu
              ansible_ssh_private_key_file: /etc/openstack-helm/deploy-key.pem
              ansible_ssh_extra_args: -o StrictHostKeyChecking=no
        nodes:
          hosts:
            node_two:
              ansible_port: 22
              ansible_host: $node_two_ip
              ansible_user: ubuntu
              ansible_ssh_private_key_file: /etc/openstack-helm/deploy-key.pem
              ansible_ssh_extra_args: -o StrictHostKeyChecking=no
            node_three:
              ansible_port: 22
              ansible_host: $node_three_ip
              ansible_user: ubuntu
              ansible_ssh_private_key_file: /etc/openstack-helm/deploy-key.pem
              ansible_ssh_extra_args: -o StrictHostKeyChecking=no
    EOF

Create an environment file
--------------------------

On the master node create an environment file for the cluster:

.. code-block:: shell

    #!/bin/bash
    set -xe
    function net_default_iface {
     sudo ip -4 route list 0/0 | awk '{ print $5; exit }'
    }
    cat > /opt/openstack-helm-infra/tools/gate/devel/multinode-vars.yaml <<EOF
    kubernetes_network_default_device: $(net_default_iface)
    EOF

Additional configuration variables can be found `here
<https://github.com/openstack/openstack-helm-infra/blob/master/roles/deploy-kubeadm-aio-common/defaults/main.yml>`_.
In particular, ``kubernetes_cluster_pod_subnet`` can be used to override the
pod subnet set up by Calico (the default container SDN), if you have a
preexisting network that conflicts with the default pod subnet of 192.168.0.0/16.

.. note::
  This installation, by default will use Google DNS servers, 8.8.8.8 or 8.8.4.4
  and updates resolv.conf. These DNS nameserver entries can be changed by
  updating file ``/opt/openstack-helm-infra/tools/images/kubeadm-aio/assets/opt/playbooks/vars.yaml``
  under section ``external_dns_nameservers``. This change must be done on each
  node in your cluster.


Run the playbooks
-----------------

On the master node run the playbooks:

.. code-block:: shell

    #!/bin/bash
    set -xe
    cd /opt/openstack-helm-infra
    make dev-deploy setup-host multinode
    make dev-deploy k8s multinode

