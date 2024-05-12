Kubernetes
==========

OpenStack-Helm provides charts that can be deployed on any Kubernetes cluster if it meets
the version :doc:`requirements </readme>`. However, deploying the Kubernetes cluster itself is beyond
the scope of OpenStack-Helm.

You can use any Kubernetes deployment tool for this purpose. In this guide, we detail how to set up
a Kubernetes cluster using Kubeadm and Ansible. While not production-ready, this cluster is ideal
as a starting point for lab or proof-of-concept environments.

All OpenStack projects test their code through an infrastructure managed by the CI
tool, Zuul, which executes Ansible playbooks on one or more test nodes. Therefore, we employ Ansible
roles/playbooks to install required packages, deploy Kubernetes, and then execute tests on it.

To establish a test environment, the Ansible role `deploy-env`_ is employed. This role deploys
a basic single/multi-node Kubernetes cluster, used to prove the functionality of commonly used
deployment configurations. The role is compatible with Ubuntu Focal and Ubuntu Jammy distributions.

.. note::
   The role `deploy-env`_ is not idempotent and assumed to be applied to a clean environment.

Clone roles git repositories
----------------------------

Before proceeding with the steps outlined in the following sections, it is
imperative that you clone the git repositories containing the required Ansible roles.

.. code-block:: bash

    mkdir ~/osh
    cd ~/osh
    git clone https://opendev.org/openstack/openstack-helm-infra.git
    git clone https://opendev.org/zuul/zuul-jobs.git

Install Ansible
---------------

.. code-block:: bash

    pip install ansible

Set roles lookup path
---------------------

Now let's set the environment variable ``ANSIBLE_ROLES_PATH`` which specifies
where Ansible will lookup roles

.. code-block:: bash

    export ANSIBLE_ROLES_PATH=~/osh/openstack-helm-infra/roles:~/osh/zuul-jobs/roles

To avoid setting it every time when you start a new terminal instance you can define this
in the Ansible configuration file. Please see the Ansible documentation.

Prepare inventory
-----------------

The example below assumes that there are four nodes which must be available via
SSH using the public key authentication and a ssh user (let say ``ubuntu``)
must have passwordless sudo on the nodes.

.. code-block:: bash

    cat > ~/osh/inventory.yaml <<EOF
    ---
    all:
      vars:
        ansible_port: 22
        ansible_user: ubuntu
        ansible_ssh_private_key_file: /home/ubuntu/.ssh/id_rsa
        ansible_ssh_extra_args: -o StrictHostKeyChecking=no
        # The user and group that will be used to run Kubectl and Helm commands.
        kubectl:
          user: ubuntu
          group: ubuntu
        # The user and group that will be used to run Docker commands.
        docker_users:
          - ununtu
        # The MetalLB controller will be installed on the Kubernetes cluster.
        metallb_setup: true
        # Loopback devices will be created on all cluster nodes which then can be used
        # to deploy a Ceph cluster which requires block devices to be provided.
        # Please use loopback devices only for testing purposes. They are not suitable
        # for production due to performance reasons.
        loopback_setup: true
        loopback_device: /dev/loop100
        loopback_image: /var/lib/openstack-helm/ceph-loop.img
        loopback_image_size: 12G
      children:
        # The primary node where Kubectl and Helm will be installed. If it is
        # the only node then it must be a member of the groups k8s_cluster and
        # k8s_control_plane. If there are more nodes then the wireguard tunnel
        # will be established between the primary node and the k8s_control_plane node.
        primary:
          hosts:
            primary:
              ansible_host: 10.10.10.10
        # The nodes where the Kubernetes components will be installed.
        k8s_cluster:
          hosts:
            node-1:
              ansible_host: 10.10.10.11
            node-2:
              ansible_host: 10.10.10.12
            node-3:
              ansible_host: 10.10.10.13
        # The control plane node where the Kubernetes control plane components will be installed.
        # It must be the only node in the group k8s_control_plane.
        k8s_control_plane:
          hosts:
            node-1:
              ansible_host: 10.10.10.11
        # These are Kubernetes worker nodes. There could be zero such nodes.
        # In this case the Openstack workloads will be deployed on the control plane node.
        k8s_nodes:
          hosts:
            node-2:
              ansible_host: 10.10.10.12
            node-3:
              ansible_host: 10.10.10.13
    EOF

.. note::
   If you would like to set up a Kubernetes cluster on the local host,
   configure the Ansible inventory to designate the ``primary`` node as the local host.
   For further guidance, please refer to the Ansible documentation.

.. note::
   The full list of variables that you can define in the inventory file can be found in the
   file `deploy-env/defaults/main.yaml`_.

Prepare playbook
----------------

Create an Ansible playbook that will deploy the environment

.. code-block:: bash

    cat > ~/osh/deploy-env.yaml <<EOF
    ---
    - hosts: all
      become: true
      gather_facts: true
      roles:
        - ensure-python
        - ensure-pip
        - clear-firewall
        - deploy-env
    EOF

Run the playbook
-----------------

.. code-block:: bash

    cd ~/osh
    ansible-playbook -i inventory.yaml deploy-env.yaml

The playbook only changes the state of the nodes listed in the inventory file.

It installs necessary packages, deploys and configures Containerd and Kubernetes. For
details please refer to the role `deploy-env`_ and other roles (`ensure-python`_,
`ensure-pip`_, `clear-firewall`_) used in the playbook.

.. note::
   The role `deploy-env`_ configures cluster nodes to use Google DNS servers (8.8.8.8).

   By default, it also configures internal Kubernetes DNS server (Coredns) to work
   as a recursive DNS server and adds its IP address (10.96.0.10 by default) to the
   ``/etc/resolv.conf`` file.

   Processes running on the cluster nodes will be able to resolve internal
   Kubernetes domain names ``*.svc.cluster.local``.

.. _deploy-env: https://opendev.org/openstack/openstack-helm-infra/src/branch/master/roles/deploy-env
.. _deploy-env/defaults/main.yaml: https://opendev.org/openstack/openstack-helm-infra/src/branch/master/roles/deploy-env/defaults/main.yaml
.. _zuul-jobs: https://opendev.org/zuul/zuul-jobs.git
.. _ensure-python: https://opendev.org/zuul/zuul-jobs/src/branch/master/roles/ensure-python
.. _ensure-pip: https://opendev.org/zuul/zuul-jobs/src/branch/master/roles/ensure-pip
.. _clear-firewall: https://opendev.org/zuul/zuul-jobs/src/branch/master/roles/clear-firewall
.. _openstack-helm-infra: https://opendev.org/openstack/openstack-helm-infra.git
