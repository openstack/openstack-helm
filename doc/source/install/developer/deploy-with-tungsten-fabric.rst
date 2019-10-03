===============================
Deployment with Tungsten Fabric
===============================

Intro
^^^^^

Tungsten Fabric is the multicloud and multistack network solution which you can
use for your OpenStack as a network plugin. This document decribes how you can deploy
a single node Open Stack based on Tungsten Fabric using openstack helm for development purpose.

Prepare host
^^^^^^^^^^^^

First you have to set up OpenStack and Linux versions and install needed packages

.. code-block:: shell

  export OPENSTACK_RELEASE=train
  export CONTAINER_DISTRO_NAME=ubuntu
  export CONTAINER_DISTRO_VERSION=bionic
  sudo apt update -y
  sudo apt install -y resolvconf
  cd ~/openstack-helm

Install OpenStack packages
^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: shell

  ./tools/deployment/common/install-packages.sh

Install k8s Minikube
^^^^^^^^^^^^^^^^^^^^

.. code-block:: shell

  ./tools/deployment/common/deploy-k8s.sh

Setup DNS for use cluster DNS
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: shell

  dns_cluster_ip=`kubectl get svc kube-dns -n kube-system --no-headers -o custom-columns=":spec.clusterIP"`
  echo "nameserver ${dns_cluster_ip}" | sudo tee -a /etc/resolvconf/resolv.conf.d/head > /dev/null
  sudo dpkg-reconfigure --force resolvconf
  sudo systemctl restart resolvconf


Setup env for apply values_overrides
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: shell

  export FEATURE_GATES=tf

Setup OpenStack client
^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: shell

  ./tools/deployment/common/setup-client.sh

Setup Ingress
^^^^^^^^^^^^^

.. code-block:: shell

  ./tools/deployment/component/common/ingress.sh

Setup MariaDB
^^^^^^^^^^^^^

.. code-block:: shell

  ./tools/deployment/component/common/mariadb.sh

Setup Memcached
^^^^^^^^^^^^^^^

.. code-block:: shell

  ./tools/deployment/component/common/memcached.sh

Setup RabbitMQ
^^^^^^^^^^^^^^

.. code-block:: shell

  ./tools/deployment/component/common/rabbitmq.sh

Setup NFS
^^^^^^^^^

.. code-block:: shell

  ./tools/deployment/component/nfs-provisioner/nfs-provisioner.sh

Setup Keystone
^^^^^^^^^^^^^^

.. code-block:: shell

  ./tools/deployment/component/keystone/keystone.sh

Setup Heat
^^^^^^^^^^

.. code-block:: shell

  ./tools/deployment/component/heat/heat.sh

Setup Glance
^^^^^^^^^^^^

.. code-block:: shell

  ./tools/deployment/component/glance/glance.sh

Prepare host and openstack helm for tf
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: shell

  ./tools/deployment/component/compute-kit/tungsten-fabric.sh prepare

Setup libvirt
^^^^^^^^^^^^^

.. code-block:: shell

  ./tools/deployment/component/compute-kit/libvirt.sh

Setup Neutron and Nova
^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: shell

  ./tools/deployment/component/compute-kit/compute-kit.sh

Setup Tungsten Fabric
^^^^^^^^^^^^^^^^^^^^^

.. code-block:: shell

  ./tools/deployment/component/compute-kit/tungsten-fabric.sh deploy