# Troubleshooting - Database Deployments

This guide is to help users debug any general storage issues when deploying Charts in this repository.

# Galera Cluster

**CHART:** openstack-helm/mariadb (when `developer-mode: false`)

MariaDB is a `StatefulSet` (`PetSets` have been retired in Kubernetes v1.5.0). As such, it initiates a 'seed' which is used to deploy MariaDB members via [affinity/anti-affinity](http://kubernetes.io/docs/user-guide/node-selection/) features. Ceph uses this as well. So what you will notice is the following behavior:

```
openstack     mariadb-0                                  0/1       Running            0          28s       10.25.49.199    kubenode05
openstack     mariadb-seed-0ckf4                         1/1       Running            0          48s       10.25.162.197   kubenode01


NAMESPACE   NAME        READY     STATUS    RESTARTS   AGE       IP             NODE
openstack   mariadb-0   1/1       Running   0          1m        10.25.49.199   kubenode05
openstack   mariadb-1   0/1       Pending   0         0s        <none>
openstack   mariadb-1   0/1       Pending   0         0s        <none>    kubenode04
openstack   mariadb-1   0/1       ContainerCreating   0         0s        <none>    kubenode04
openstack   mariadb-1   0/1       Running   0         3s        10.25.178.74   kubenode04
```

What you're seeing is the output of `kubectl get pods -o wide --all-namespaces`, which is used to monitor the seed host preparing each of the MariaDB/Galera members in order: mariadb-0, then mariadb-1, then mariadb-2. This process can take up to a few minutes, so be patient.

To test MariaDB, do the following:

```
admin@kubenode01:~/projects/openstack-helm$ kubectl exec mariadb-0 -it -n openstack -- mysql -h mariadb.openstack -uroot -ppassword -e 'show databases;'
+--------------------+
| Database           |
+--------------------+
| information_schema |
| keystone           |
| mysql              |
| performance_schema |
+--------------------+
admin@kubenode01:~/projects/openstack-helm$
```

Now you can see that MariaDB is loaded, with databases intact! If you're at this point, the rest of the installation is easy. You can run the following to check on Galera:

```
admin@kubenode01:~/projects/openstack-helm$ kubectl describe po/mariadb-0 -n openstack
Name:       mariadb-0
Namespace:  openstack
Node:       kubenode05/192.168.3.25
Start Time: Fri, 23 Dec 2016 16:15:49 -0500
Labels:     app=mariadb
        galera=enabled
Status:     Running
IP:     10.25.49.199
Controllers:    StatefulSet/mariadb
...
...
...
  FirstSeen LastSeen    Count   From            SubObjectPath           Type        Reason      Message
  --------- --------    -----   ----            -------------           --------    ------      -------
  5s        5s      1   {default-scheduler }                    Normal      Scheduled   Successfully assigned mariadb-0 to kubenode05
  3s        3s      1   {kubelet kubenode05}    spec.containers{mariadb}    Normal      Pulling     pulling image "quay.io/stackanetes/stackanetes-mariadb:newton"
  2s        2s      1   {kubelet kubenode05}    spec.containers{mariadb}    Normal      Pulled      Successfully pulled image "quay.io/stackanetes/stackanetes-mariadb:newton"
  2s        2s      1   {kubelet kubenode05}    spec.containers{mariadb}    Normal      Created     Created container with docker id f702bd7c11ef; Security:[seccomp=unconfined]
  2s        2s      1   {kubelet kubenode05}    spec.containers{mariadb}    Normal      Started     Started container with docker id f702bd7c11ef
```

So you can see that galera is enabled.
