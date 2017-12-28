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
can be done with the following Ceph command:

::

    admin@kubenode01:~$ MON_POD=$(kubectl get --no-headers pods -n=ceph -l="application=ceph,component=mon" | awk '{ print $1; exit }')
    admin@kubenode01:~$ kubectl exec -n ceph ${MON_POD} -- ceph -s
        cluster:
          id:     06a191c7-81bd-43f3-b5dd-3d6c6666af71
          health: HEALTH_OK

        services:
          mon: 1 daemons, quorum att.port.direct
          mgr: att.port.direct(active)
          mds: cephfs-1/1/1 up  {0=mds-ceph-mds-68c9c76d59-zqc55=up:active}
          osd: 1 osds: 1 up, 1 in
          rgw: 1 daemon active

        data:
          pools:   11 pools, 208 pgs
          objects: 352 objects, 464 MB
          usage:   62467 MB used, 112 GB / 173 GB avail
          pgs:     208 active+clean

        io:
          client:   253 B/s rd, 39502 B/s wr, 1 op/s rd, 8 op/s wr
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

    admin@kubenode01: $ kubectl get secret -n openstack pvc-ceph-client-key
    NAME                  TYPE                DATA      AGE
    pvc-ceph-client-key   kubernetes.io/rbd   1         8h

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
    Name:            general
    IsDefaultClass:  No
    Annotations:     <none>
    Provisioner:     ceph.com/rbd
    Parameters:      adminId=admin,adminSecretName=pvc-ceph-conf-combined-storageclass,adminSecretNamespace=ceph,imageFeatures=layering,imageFormat=2,monitors=ceph-mon.ceph.svc.cluster.local:6789,pool=rbd,userId=admin,userSecretName=pvc-ceph-client-key
    ReclaimPolicy:   Delete
    Events:          <none>
    admin@kubenode01:~$

The parameters are what we're looking for here. If we see parameters
passed to the StorageClass correctly, we will see the
``ceph-mon.ceph.svc.cluster.local:6789`` hostname/port, things like ``userid``,
and appropriate secrets used for volume claims.
