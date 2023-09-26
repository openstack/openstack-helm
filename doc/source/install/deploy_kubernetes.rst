Deploy Kubernetes
=================

OpenStack-Helm provides charts that can be deployed on any Kubernetes cluster if it meets
the supported version requirements. However, deploying the Kubernetes cluster itself is beyond
the scope of OpenStack-Helm.

You can use any Kubernetes deployment tool for this purpose. In this guide, we detail how to set up
a Kubernetes cluster using Kubeadm and Ansible. While not production-ready, this cluster is ideal
as a starting point for lab or proof-of-concept environments.

All OpenStack projects test their code through an infrastructure managed by the CI
tool, Zuul, which executes Ansible playbooks on one or more test nodes. Therefore, we employ Ansible
roles/playbooks to install required packages, deploy Kubernetes, and then execute tests on it.

To establish a test environment, the Ansible role deploy-env_ is employed. This role establishes
a basic single/multi-node Kubernetes cluster, ensuring the functionality of commonly used
deployment configurations. The role is compatible with Ubuntu Focal and Ubuntu Jammy distributions.

Install Ansible
---------------

.. code-block:: bash

    pip install ansible

Prepare Ansible roles
---------------------

Here is the Ansible `playbook`_ that is used to deploy Kubernetes. The roles used in this playbook
are defined in different repositories. So in addition to OpenStack-Helm repositories
that we assume have already been cloned to the `~/osh` directory you have to clone
yet another one

.. code-block:: bash

    cd ~/osh
    git clone https://opendev.org/zuul/zuul-jobs.git

Now let's set the environment variable ``ANSIBLE_ROLES_PATH`` which specifies
where Ansible will lookup roles

.. code-block:: bash

    export ANSIBLE_ROLES_PATH=~/osh/openstack-helm-infra/roles:~/osh/zuul-jobs/roles

To avoid setting it every time when you start a new terminal instance you can define this
in the Ansible configuration file. Please see the Ansible documentation.

Prepare Ansible inventory
-------------------------

We assume you have three nodes, usually VMs. Those nodes must be available via
SSH using the public key authentication and a ssh user (let say `ubuntu`)
must have passwordless sudo on the nodes.

Create the Ansible inventory file using the following command

.. code-block:: bash

    cat > ~/osh/inventory.yaml <<EOF
    all:
      vars:
        kubectl:
          user: ubuntu
          group: ubuntu
        calico_version: "v3.25"
        crictl_version: "v1.26.1"
        helm_version: "v3.6.3"
        kube_version: "1.26.3-00"
        yq_version: "v4.6.0"
      children:
        primary:
          hosts:
            primary:
              ansible_port: 22
              ansible_host: 10.10.10.10
              ansible_user: ubuntu
              ansible_ssh_private_key_file: ~/.ssh/id_rsa
              ansible_ssh_extra_args: -o StrictHostKeyChecking=no
        nodes:
          hosts:
            node-1:
              ansible_port: 22
              ansible_host: 10.10.10.11
              ansible_user: ubuntu
              ansible_ssh_private_key_file: ~/.ssh/id_rsa
              ansible_ssh_extra_args: -o StrictHostKeyChecking=no
            node-2:
              ansible_port: 22
              ansible_host: 10.10.10.12
              ansible_user: ubuntu
              ansible_ssh_private_key_file: ~/.ssh/id_rsa
              ansible_ssh_extra_args: -o StrictHostKeyChecking=no
    EOF

If you have just one node then it must be `primary` in the file above.

.. note::
   If you would like to set up a Kubernetes cluster on the local host,
   configure the Ansible inventory to designate the `primary` node as the local host.
   For further guidance, please refer to the Ansible documentation.

Deploy Kubernetes
-----------------

.. code-block:: bash

    cd ~/osh
    ansible-playbook -i inventory.yaml ~/osh/openstack-helm/tools/gate/playbooks/deploy-env.yaml

The playbook only changes the state of the nodes listed in the Ansible inventory.

It installs necessary packages, deploys and configures Containerd and Kubernetes. For
details please refer to the role `deploy-env`_ and other roles (`ensure-python`_, `ensure-pip`_, `clear-firewall`_)
used in the playbook.

.. note::
   The role `deploy-env`_ by default will use Google DNS servers, 8.8.8.8 or 8.8.4.4
   and update `/etc/resolv.conf` on the nodes. These DNS nameserver entries can be changed by
   updating the file ``~/osh/openstack-helm-infra/roles/deploy-env/files/resolv.conf``.

   It also configures internal Kubernetes DNS server (Coredns) to work as a recursive DNS server
   and adds its IP address (10.96.0.10 by default) to the `/etc/resolv.conf` file.

   Programs running on those nodes will be able to resolve names in the
   default Kubernetes domain `.svc.cluster.local`. E.g. if you run OpenStack command line
   client on one of those nodes it will be able to access OpenStack API services via
   these names.

.. note::
   The role `deploy-env`_ installs and confiugres Kubectl and Helm on the `primary` node.
   You can login to it via SSH, clone `openstack-helm`_ and `openstack-helm-infra`_ repositories
   and then run the OpenStack-Helm deployment scipts which employ Kubectl and Helm to deploy
   OpenStack.

.. _deploy-env: https://opendev.org/openstack/openstack-helm-infra/src/branch/master/roles/deploy-env
.. _ensure-python: https://opendev.org/zuul/zuul-jobs/src/branch/master/roles/ensure-python
.. _ensure-pip: https://opendev.org/zuul/zuul-jobs/src/branch/master/roles/ensure-pip
.. _clear-firewall: https://opendev.org/zuul/zuul-jobs/src/branch/master/roles/clear-firewall
.. _openstack-helm: https://opendev.org/openstack/openstack-helm.git
.. _openstack-helm-infra: https://opendev.org/openstack/openstack-helm-infra.git
.. _playbook: https://opendev.org/openstack/openstack-helm/src/branch/master/tools/gate/playbooks/deploy-env.yaml
