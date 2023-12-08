Deploy Ceph
===========

Ceph is a highly scalable and fault-tolerant distributed storage
system designed to store vast amounts of data across a cluster of
commodity hardware. It offers object storage, block storage, and
file storage capabilities, making it a versatile solution for
various storage needs. Ceph's architecture is based on a distributed
object store, where data is divided into objects, each with its
unique identifier, and distributed across multiple storage nodes.
It uses a CRUSH algorithm to ensure data resilience and efficient
data placement, even as the cluster scales. Ceph is widely used
in cloud computing environments and provides a cost-effective and
flexible storage solution for organizations managing large volumes of data.

Kubernetes introduced the CSI standard to allow storage providers
like Ceph to implement their drivers as plugins. Kubernetes can
use the CSI driver for Ceph to provision and manage volumes
directly. By means of CSI stateful applications deployed on top
of Kubernetes can use Ceph to store their data.

At the same time, Ceph provides the RBD API, which applications
can utilize to create and mount block devices distributed across
the Ceph cluster. The OpenStack Cinder service utilizes this Ceph
capability to offer persistent block devices to virtual machines
managed by the OpenStack Nova.

The recommended way to deploy Ceph on top of Kubernetes is by means
of `Rook`_ operator. Rook provides Helm charts to deploy the operator
itself which extends the Kubernetes API adding CRDs that enable
managing Ceph clusters via Kuberntes custom objects. For details please
refer to the `Rook`_ documentation.

To deploy the Rook Ceph operator and a Ceph cluster you can use the script
`ceph-rook.sh`_. Then to generate the client secrets to interface with the Ceph
RBD API use this script `ceph-adapter-rook.sh`_

.. code-block:: bash

    cd ~/osh/openstack-helm-infra
    ./tools/deployment/ceph/ceph-rook.sh
    ./tools/deployment/ceph/ceph-adapter-rook.sh

.. note::
    Please keep in mind that these are the deployment scripts that we
    use for testing. For example we place Ceph OSD data object on loop devices
    which are slow and are not recommended to use in production.


.. _Rook: https://rook.io/
.. _ceph-rook.sh: https://opendev.org/openstack/openstack-helm-infra/src/branch/master/tools/deployment/ceph/ceph-rook.sh
.. _ceph-adapter-rook.sh: https://opendev.org/openstack/openstack-helm-infra/src/branch/master/tools/deployment/ceph/ceph-adapter-rook.sh
