==================
Persistent Storage
==================

This guide is to help users debug any general storage issues when
deploying charts in this repository.

Ceph
====

Ceph Deployment Status
~~~~~~~~~~~~~~~~~~~~~~

First, we want to validate that Ceph is working correctly. This
can be done with the following ceph command:

::

    admin@kubenode01:~$ kubectl exec -t -i ceph-mon-0 -n ceph -- ceph status
        cluster 046de582-f8ee-4352-9ed4-19de673deba0
         health HEALTH_OK
         monmap e3: 3 mons at {ceph-mon-392438295-6q04c=10.25.65.131:6789/0,ceph-mon-392438295-ksrb2=10.25.49.196:6789/0,ceph-mon-392438295-l0pzj=10.25.79.193:6789/0}
                election epoch 6, quorum 0,1,2 ceph-mon-392438295-ksrb2,ceph-mon-392438295-6q04c,ceph-mon-392438295-l0pzj
          fsmap e5: 1/1/1 up {0=mds-ceph-mds-2810413505-gtjgv=up:active}
         osdmap e23: 5 osds: 5 up, 5 in
                flags sortbitwise
          pgmap v22012: 80 pgs, 3 pools, 12712 MB data, 3314 objects
                101 GB used, 1973 GB / 2186 GB avail
                      80 active+clean
    admin@kubenode01:~$

Use one of your Ceph Monitors to check the status of the cluster. A
couple of things to note above; our health is `HEALTH\_OK`, we have 3
mons, we've established a quorum, and we can see that all of our OSDs
are up and in the OSD map.

PVC Preliminary Validation
~~~~~~~~~~~~~~~~~~~~~~~~~~

Before proceeding, it is important to ensure that you have deployed a
client key in the namespace you wish to fulfill ``PersistentVolumeClaims``.
To verify that your deployment namespace has a client key:

::

    admin@kubenode01: $ kubectl get secret -n openstack
    NAME                  TYPE                                  DATA      AGE
    default-token-nvl10   kubernetes.io/service-account-token   3         7d
    pvc-ceph-client-key   kubernetes.io/rbd                     1         6m

Without this, your RBD-backed PVCs will never reach the ``Bound`` state.  For
more information, see how to `activate namespace for ceph <../install/multinode.html#activating-control-plane-namespace-for-ceph>`_.

Note: This step is not relevant for PVCs within the same namespace Ceph
was deployed.

Ceph Validating PVC Operation
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To validate persistent volume claim (PVC) creation, we've placed a test
manifest `here <https://raw.githubusercontent.com/openstack/openstack-helm/master/tests/pvc-test.yaml>`_.
Deploy this manifest and verify the job completes successfully.

Ceph Validating StorageClass
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Next we can look at the storage class, to make sure that it was created
correctly:

::

    admin@kubenode01:~$ kubectl describe storageclass/general
    Name:       general
    IsDefaultClass: No
    Annotations:    <none>
    Provisioner:    kubernetes.io/rbd
    Parameters: adminId=admin,adminSecretName=pvc-ceph-conf-combined-storageclass,adminSecretNamespace=ceph,monitors=ceph-mon.ceph:6789,pool=rbd,userId=admin,userSecretName=pvc-ceph-client-key
    No events.
    admin@kubenode01:~$

The parameters are what we're looking for here. If we see parameters
passed to the StorageClass correctly, we will see the
``ceph-mon.ceph:6789`` hostname/port, things like ``userid``, and
appropriate secrets used for volume claims.
