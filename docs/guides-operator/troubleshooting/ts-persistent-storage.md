# Troubleshooting - Persistent Storage

This guide is to help users debug any general storage issues when deploying Charts in this repository.

# Ceph

**CHART:** openstack-helm/ceph

### Ceph Validating PVC
To validate persistent volume claim (PVC) creation, we've placed a test manifest in the `./test/` directory. Deploy this pvc and explore the deployment:
```
admin@kubenode01:~$ kubectl get pvc -o wide --all-namespaces -w
NAMESPACE   NAME                   STATUS    VOLUME                                     CAPACITY   ACCESSMODES   AGE
ceph        pvc-test               Bound     pvc-bc768dea-c93e-11e6-817f-001fc69c26d1   1Gi        RWO           9h
admin@kubenode01:~$
```
The output above indicates that the PVC is 'bound' correctly. Now digging deeper:
```
admin@kubenode01:~/projects/openstack-helm$ kubectl describe pvc pvc-test -n ceph
Name:		pvc-test
Namespace:	ceph
StorageClass:	general
Status:		Bound
Volume:		pvc-bc768dea-c93e-11e6-817f-001fc69c26d1
Labels:		<none>
Capacity:	1Gi
Access Modes:	RWO
No events.
admin@kubenode01:~/projects/openstack-helm$
```
We can see that we have a VolumeID, and the 'capacity' is 1GB. It is a 'general' storage class. It is just a simple test. You can safely delete this test by issuing the following:
```
admin@kubenode01:~/projects/openstack-helm$ kubectl delete pvc pvc-test -n ceph
persistentvolumeclaim "pvc-test" deleted
admin@kubenode01:~/projects/openstack-helm$
```

### Ceph Validating StorageClass
Next we can look at the storage class, to make sure that it was created correctly:
```
admin@kubenode01:~$ kubectl describe storageclass/general
Name:		general
IsDefaultClass:	No
Annotations:	<none>
Provisioner:	kubernetes.io/rbd
Parameters:	adminId=admin,adminSecretName=pvc-ceph-conf-combined-storageclass,adminSecretNamespace=ceph,monitors=ceph-mon.ceph:6789,pool=rbd,userId=admin,userSecretName=pvc-ceph-client-key
No events.
admin@kubenode01:~$
```
The parameters is what we're looking for here. If we see parameters passed to the StorageClass correctly, we will see the `ceph-mon.ceph:6789` hostname/port, things like `userid`, and appropriate secrets used for volume claims. This all looks great, and it time to Ceph itself.

### Ceph Validation
Most commonly, we want to validate that Ceph is working correctly. This can be done with the following ceph command:
```
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
```
Use one of your Ceph Monitors to check the status of the cluster. A couple of things to note above; our health is 'HEALTH_OK', we have 3 mons, we've established a quorum, and we can see that our active mds is 'ceph-mds-2810413505-gtjgv'. We have a healthy environment.

For Glance and Cinder to operate, you will need to create some storage pools for these systems.   Additionally, Nova can be configured to use a pool as well, but this is off by default.

```
kubectl exec -n ceph -it ceph-mon-0 ceph osd pool create volumes 128
kubectl exec -n ceph -it ceph-mon-0 ceph osd pool create images 128
```

Nova storage would be added like this:
```
kubectl exec -n ceph -it ceph-mon-0 ceph osd pool create vms 128
```

The choosing the amount of storage is up to you and can be changed by replacing the 128 to meet your needs.

We are now ready to install our next chart, MariaDB.
