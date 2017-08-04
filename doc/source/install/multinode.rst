=========
Multinode
=========

Overview
========

In order to drive towards a production-ready Openstack solution, our
goal is to provide containerized, yet stable `persistent
volumes <https://kubernetes.io/docs/concepts/storage/persistent-volumes/>`_
that Kubernetes can use to schedule applications that require state,
such as MariaDB (Galera). Although we assume that the project should
provide a “batteries included” approach towards persistent storage, we
want to allow operators to define their own solution as well. Examples
of this work will be documented in another section, however evidence of
this is found throughout the project. If you have any questions or
comments, please create an `issue
<https://bugs.launchpad.net/openstack-helm>`_.

.. warning::
  Please see the latest published information about our
  application versions.

  .. list-table::
     :widths: 45 155 200
     :header-rows: 1

     * -
       - Version
       - Notes
     * - **Kubernetes**
       - `v1.6.8 <https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG.md#v165>`_
       - `Custom Controller for RDB tools <https://quay.io/repository/attcomdev/kube-controller-manager?tab=tags>`_
     * - **Helm**
       - `v2.5.1 <https://github.com/kubernetes/helm/releases/tag/v2.5.1>`_
       -
     * - **Calico**
       - `v2.1 <http://docs.projectcalico.org/v2.1/releases/>`_
       - `calicoct v1.1 <https://github.com/projectcalico/calicoctl/releases>`_
     * - **Docker**
       - `v1.12.6 <https://github.com/docker/docker/releases/tag/v1.12.6>`_
       - `Per kubeadm Instructions <https://kubernetes.io/docs/getting-started-guides/kubeadm/>`_

Other versions and considerations (such as other CNI SDN providers),
config map data, and value overrides will be included in other
documentation as we explore these options further.

The installation procedures below, will take an administrator from a new
``kubeadm`` installation to Openstack-Helm deployment.

Kubernetes Preparation
======================

This walkthrough will help you set up a bare metal environment with 5
nodes, using ``kubeadm`` on Ubuntu 16.04. The assumption is that you
have a working ``kubeadm`` environment and that your environment is at a
working state, ***prior*** to deploying a CNI-SDN. This deployment
procedure is opinionated *only to standardize the deployment process for
users and developers*, and to limit questions to a known working
deployment. Instructions will expand as the project becomes more mature.

KubeADM Deployment
-----------------------

Once the dependencies are installed, bringing up a ``kubeadm`` environment
should just require a single command on the master node:

::

    admin@kubenode01:~$ kubeadm init --kubernetes-version v1.6.8


If your environment looks like this after all nodes have joined the
cluster, you are ready to continue:

::

    admin@kubenode01:~$ kubectl get pods -o wide --all-namespaces
    NAMESPACE     NAME                                       READY     STATUS              RESTARTS   AGE       IP              NODE
    kube-system   dummy-2088944543-lg0vc                     1/1       Running             1          5m        192.168.3.21    kubenode01
    kube-system   etcd-kubenode01                            1/1       Running             1          5m        192.168.3.21    kubenode01
    kube-system   kube-apiserver-kubenode01                  1/1       Running             3          5m        192.168.3.21    kubenode01
    kube-system   kube-controller-manager-kubenode01         1/1       Running             0          5m        192.168.3.21    kubenode01
    kube-system   kube-discovery-1769846148-8g4d7            1/1       Running             1          5m        192.168.3.21    kubenode01
    kube-system   kube-dns-2924299975-xxtrg                  0/4       ContainerCreating   0          5m        <none>          kubenode01
    kube-system   kube-proxy-7kxpr                           1/1       Running             0          5m        192.168.3.22    kubenode02
    kube-system   kube-proxy-b4xz3                           1/1       Running             0          5m        192.168.3.24    kubenode04
    kube-system   kube-proxy-b62rp                           1/1       Running             0          5m        192.168.3.23    kubenode03
    kube-system   kube-proxy-s1fpw                           1/1       Running             1          5m        192.168.3.21    kubenode01
    kube-system   kube-proxy-thc4v                           1/1       Running             0          5m        192.168.3.25    kubenode05
    kube-system   kube-scheduler-kubenode01                  1/1       Running             1          5m        192.168.3.21    kubenode01
    admin@kubenode01:~$

Deploying a CNI-Enabled SDN (Calico)
------------------------------------

After an initial ``kubeadmn`` deployment has been scheduled, it is time
to deploy a CNI-enabled SDN. We have selected **Calico**, but have also
confirmed that this works for Weave, and Romana. For Calico version
v2.1, you can apply the provided `Kubeadm Hosted
Install <http://docs.projectcalico.org/v2.1/getting-started/kubernetes/installation/hosted/kubeadm/>`_
manifest:

::

    kubectl create -f http://docs.projectcalico.org/v2.1/getting-started/kubernetes/installation/hosted/kubeadm/1.6/calico.yaml

.. note::

    After the container CNI-SDN is deployed, Calico has a tool you can use
    to verify your deployment. You can download this tool,
    ```calicoctl`` <https://github.com/projectcalico/calicoctl/releases>`__
    to execute the following command:

    ::

        admin@kubenode01:~$ sudo calicoctl node status
        Calico process is running.

        IPv4 BGP status
        +--------------+-------------------+-------+----------+-------------+
        | PEER ADDRESS |     PEER TYPE     | STATE |  SINCE   |    INFO     |
        +--------------+-------------------+-------+----------+-------------+
        | 192.168.3.22 | node-to-node mesh | up    | 16:34:03 | Established |
        | 192.168.3.23 | node-to-node mesh | up    | 16:33:59 | Established |
        | 192.168.3.24 | node-to-node mesh | up    | 16:34:00 | Established |
        | 192.168.3.25 | node-to-node mesh | up    | 16:33:59 | Established |
        +--------------+-------------------+-------+----------+-------------+

        IPv6 BGP status
        No IPv6 peers found.

        admin@kubenode01:~$

    It is important to call out that the Self Hosted Calico manifest for
    v2.1 (above) supports ``nodetonode`` mesh, and ``nat-outgoing`` by
    default. This is a change from version 1.6.

Setting Up RBAC
---------------

Kubernetes >=v1.6 makes RBAC the default admission controller. OpenStack
Helm does not currently have RBAC roles and permissions for each
component so we relax the access control rules:

.. code:: bash

    kubectl update -f https://raw.githubusercontent.com/openstack/openstack-helm/master/tools/kubeadm-aio/assets/opt/rbac/dev.yaml

Enabling Cron Jobs
------------------

OpenStack-Helm's default Keystone token provider is `fernet
<https://docs.openstack.org/keystone/latest/admin/identity-fernet-token-faq.html>`_.
To provide sufficient security, keys used to generate fernet tokens need to be
rotated regularly. Keystone chart provides Cron Job for that task, but it is
only deployed when Cron Jobs API is enabled on Kubernetes cluster. To enable
Cron Jobs add ``--runtime-config=batch/v2alpha1=true`` to your kube-apiserver
startup arguments (e.g. in your
``/etc/kubernetes/manifests/kube-apiserver.yaml`` manifest). By default fernet
keys will be rotated weekly.

Please note that similar solution is used for keys used to encrypt credentials
saved by Keystone. Those keys are also rotated by another Cron Job. By default
it is run in a monthly manner.

Preparing Persistent Storage
----------------------------

Persistent storage is improving. Please check our current and/or
resolved
`issues <https://bugs.launchpad.net/openstack-helm?field.searchtext=ceph>`__
to find out how we're working with the community to improve persistent
storage for our project. For now, a few preparations need to be
completed.

Installing Ceph Host Requirements
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

You need to ensure that ``ceph-common`` or equivalent is installed on each of
our hosts. Using our Ubuntu example:

::

    sudo apt-get install ceph-common -y

Kubernetes Node DNS Resolution
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

For each of the nodes to know how to reach Ceph endpoints, each host much also
have an entry for ``kube-dns``. Since we are using Ubuntu for our example, place
these changes in ``/etc/network/interfaces`` to ensure they remain after reboot.

To do this you will first need to find out what the IP Address of your
``kube-dns`` deployment is:

::

    admin@kubenode01:~$ kubectl get svc kube-dns --namespace=kube-system
    NAME       CLUSTER-IP   EXTERNAL-IP   PORT(S)         AGE
    kube-dns   10.96.0.10   <none>        53/UDP,53/TCP   1d
    admin@kubenode01:~$

Now we are ready to continue with the Openstack-Helm installation.

Openstack-Helm Preparation
==========================

Please ensure that you have verified and completed the steps above to
prevent issues with your deployment. Since our goal is to provide a
Kubernetes environment with reliable, persistent storage, we will
provide some helpful verification steps to ensure you are able to
proceed to the next step.

Although Ceph is mentioned throughout this guide, our deployment is
flexible to allow you the option of bringing any type of persistent
storage. Although most of these verification steps are the same, if not
very similar, we will use Ceph as our example throughout this guide.

Node Labels
-----------

First, we must label our nodes according to their role. Although we are
labeling ``all`` nodes, you are free to label only the nodes you wish.
You must have at least one, although a minimum of three are recommended.
In the case of Ceph, it is important to note that Ceph monitors
and OSDs are each deployed as a ``DaemonSet``.  Be aware that
labeling an even number of monitor nodes can result in trouble
when trying to reach a quorum.

Nodes are labeled according to their Openstack roles:

* **Ceph MON Nodes:** ``ceph-mon``
* **Ceph OSD Nodes:** ``ceph-osd``
* **Ceph MDS Nodes:** ``ceph-mds``
* **Control Plane:** ``openstack-control-plane``
* **Compute Nodes:** ``openvswitch``, ``openstack-compute-node``

::

    kubectl label nodes openstack-control-plane=enabled --all
    kubectl label nodes ceph-mon=enabled --all
    kubectl label nodes ceph-osd=enabled --all
    kubectl label nodes ceph-mds=enabled --all
    kubectl label nodes openvswitch=enabled --all
    kubectl label nodes openstack-compute-node=enabled --all

Obtaining the Project
---------------------

Download the latest copy of Openstack-Helm:

::

    git clone https://github.com/openstack/openstack-helm.git
    cd openstack-helm

Ceph Preparation and Installation
---------------------------------

Ceph takes advantage of host networking.  For Ceph to be aware of the
OSD cluster and public networks, you must set the CIDR ranges to be the
subnet range that your host machines are running on.  In the example provided,
the host's subnet CIDR is ``10.26.0.0/26``, but you will need to replace this
to reflect your cluster. Export these variables to your deployment environment
by issuing the following commands:

::

    export osd_cluster_network=10.26.0.0/26
    export osd_public_network=10.26.0.0/26

Helm Preparation
----------------

Now we need to install and prepare Helm, the core of our project. Please
use the installation guide from the
`Kubernetes/Helm <https://github.com/kubernetes/helm/blob/master/docs/install.md#from-the-binary-releases>`__
repository. Please take note of our required versions above.

Once installed, and initiated (``helm init``), you will need your local
environment to serve helm charts for use. You can do this by:

::

    helm serve &
    helm repo add local http://localhost:8879/charts

Openstack-Helm Installation
===========================

Now we are ready to deploy, and verify our Openstack-Helm installation.
The first required is to build out the deployment secrets, lint and
package each of the charts for the project. Do this my running ``make``
in the ``openstack-helm`` directory:

::

    make

.. note::
  If you need to make any changes to the deployment, you may run
  ``make`` again, delete your helm-deployed chart, and redeploy
  the chart (update). If you need to delete a chart for any reason,
  do the following:

::

    helm list

    # NAME              REVISION    UPDATED                     STATUS      CHART
    # bootstrap         1           Fri Dec 23 13:37:35 2016    DEPLOYED    bootstrap-0.2.0
    # bootstrap-ceph    1           Fri Dec 23 14:27:51 2016    DEPLOYED    bootstrap-0.2.0
    # ceph              3           Fri Dec 23 14:18:49 2016    DEPLOYED    ceph-0.2.0
    # keystone          1           Fri Dec 23 16:40:56 2016    DEPLOYED    keystone-0.2.0
    # mariadb           1           Fri Dec 23 16:15:29 2016    DEPLOYED    mariadb-0.2.0
    # memcached         1           Fri Dec 23 16:39:15 2016    DEPLOYED    memcached-0.2.0
    # rabbitmq          1           Fri Dec 23 16:40:34 2016    DEPLOYED    rabbitmq-0.2.0

    helm delete --purge keystone

Please ensure that you use ``--purge`` whenever deleting a project.

Ceph Installation and Verification
----------------------------------

Install the first service, which is Ceph. If all instructions have been
followed as mentioned above, this installation should go smoothly. Use
the following command to install Ceph:

::

    helm install --namespace=ceph local/ceph --name=ceph \
      --set manifests_enabled.client_secrets=false \
      --set network.public=$osd_public_network \
      --set network.cluster=$osd_cluster_network \
      --set bootstrap.enabled=true

You may want to validate that Ceph is deployed successfully. For more
information on this, please see the section entitled `Ceph
Troubleshooting <../../operator/troubleshooting/persistent-storage.html>`__.

Activating Control-Plane Namespace for Ceph
-------------------------------------------

In order for Ceph to fulfill PersistentVolumeClaims within Kubernetes namespaces
outside of Ceph's namespace, a client keyring needs to be present within that
namespace.  For the rest of the OpenStack and supporting core services, this guide
will be deploying the control plane to a seperate namespace ``openstack``.  To
deploy the client keyring and ``ceph.conf`` to the ``openstack`` namespace:

::

    helm install --namespace=openstack local/ceph --name=ceph-openstack-config \
      --set manifests_enabled.storage_secrets=false \
      --set manifests_enabled.deployment=false \
      --set ceph.namespace=ceph \
      --set network.public=$osd_public_network \
      --set network.cluster=$osd_cluster_network

MariaDB Installation and Verification
-------------------------------------

To install MariaDB, issue the following command:

::

    helm install --name=mariadb local/mariadb --namespace=openstack

Installation of Other Services
------------------------------

Now you can easily install the other services simply by going in order:

**Install Memcached/Etcd/RabbitMQ/Ingress:**

::

    helm install --name=memcached local/memcached --namespace=openstack
    helm install --name=etcd-rabbitmq local/etcd --namespace=openstack
    helm install --name=rabbitmq local/rabbitmq --namespace=openstack
    helm install --name=ingress local/ingress --namespace=openstack

**Install Keystone:**

::

    helm install --namespace=openstack --name=keystone local/keystone \
      --set pod.replicas.api=2

**Install Horizon:**

::

    helm install --namespace=openstack --name=horizon local/horizon \
      --set network.enable_node_port=true

**Install Glance:**

::

    helm install --namespace=openstack --name=glance local/glance \
      --set pod.replicas.api=2 \
      --set pod.replicas.registry=2

**Install Heat:**

::

    helm install --namespace=openstack --name=heat local/heat

**Install Neutron:**

::

    helm install --namespace=openstack --name=neutron local/neutron \
      --set pod.replicas.server=2

**Install Nova:**

::

    helm install --namespace=openstack --name=nova local/nova \
      --set pod.replicas.api_metadata=2 \
      --set pod.replicas.osapi=2 \
      --set pod.replicas.conductor=2 \
      --set pod.replicas.consoleauth=2 \
      --set pod.replicas.scheduler=2 \
      --set pod.replicas.novncproxy=2

**Install Cinder:**

::

    helm install --namespace=openstack --name=cinder local/cinder \
      --set pod.replicas.api=2

Final Checks
------------

Now you can run through your final checks. Wait for all services to come
up:

::

    watch kubectl get all --namespace=openstack

Finally, you should now be able to access horizon at http:// using
admin/password
