# aic-helm/ceph

This chart installs a working version of ceph.  It is based on the ceph-docker work and follows closely with the setup [examples](https://github.com/ceph/ceph-docker/tree/master/examples/kubernetes) for kubernetes.

It attempts to simplify that process by wrapping up much of the setup into a helm-chart.  A few items are still necessary, however until they can be refined:

### SkyDNS Resolution

The Ceph MONs are what clients talk to when mounting Ceph storage. Because Ceph MON IPs can change, we need a Kubernetes service to front them. Otherwise your clients will eventually stop working over time as MONs are rescheduled.

To get skyDNS resolution working, the resolv.conf on your nodes should look something like this:

```
domain <EXISTING_DOMAIN>
search <EXISTING_DOMAIN>

search svc.cluster.local #Your kubernetes cluster ip domain

nameserver 10.0.0.10     #The cluster IP of skyDNS
nameserver <EXISTING_RESOLVER_IP>
```

### Ceph and RBD utilities installed on the nodes

The Kubernetes kubelet shells out to system utilities to mount Ceph volumes. This means that every system must have these utilities installed. This requirement extends to the control plane, since there may be interactions between kube-controller-manager and the Ceph cluster.

For Debian-based distros:

```
apt-get install ceph-fs-common ceph-common
```

For Redhat-based distros:

```
yum install ceph
```

### Linux Kernel version 4.2.0 or newer

You'll need a newer kernel to use this. Kernel panics have been observed on older versions. Your kernel should also have RBD support.

This has been tested on:

- Ubuntu 15.10

This will not work on:

- Debian 8.5


### Override the default network settings

By default, `10.244.0.0/16` is used for the `cluster_network` and `public_network` in ceph.conf. To change these defaults, set the following environment variables according to your network requirements. These IPs should be set according to the range of your Pod IPs in your kubernetes cluster:

```
export osd_cluster_network=192.168.0.0/16
export osd_public_network=192.168.0.0/16
```

For a kubeadm installed weave cluster, you will likely want to run:

```
export osd_cluster_network=10.32.0.0/12
export osd_public_network=10.32.0.0/12
```

### Label your storage nodes

You must label your storage nodes in order to run Ceph pods on them.

```
kubectl label node <nodename> node-type=storage
```

If you want all nodes in your Kubernetes cluster to be a part of your Ceph cluster, label them all.

```
kubectl label nodes node-type=storage --all
```

### Quickstart

You will need to generate ceph keys and configuration.  There is a simple to use utility that can do this quickly.  Please note the generator utility (per ceph-docker) requires the sigil template framework: (https://github.com/gliderlabs/sigil) to be installed and on the current path.

```
cd common/utils/secret-generator
./generate_secrets.sh all `./generate_secrets.sh fsid`
cd ../../..
```

At this point, you're ready to generate base64 encoded files based on the secrets generated above.  This is done automatically if you run make which rebuilds all charts.

```
make
```

You can also trigger it specifically:

```
make base64
make ceph
```

Finally, you can now deploy your ceph chart:

```
helm --debug install local/ceph --namespace=ceph
```

You should see a deployed/successful helm deployment:

```
# helm ls
NAME     	REVISION	UPDATED                 	STATUS  	CHART     
saucy-elk	1       	Thu Nov 17 13:43:27 2016	DEPLOYED	ceph-0.1.0
```

as well as all kubernetes resources deployed into the ceph namespace:

```
# kubectl get all --namespace=ceph
NAME           CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
svc/ceph-mon   None            <none>        6789/TCP   1h
svc/ceph-rgw   100.76.18.187   <pending>     80/TCP     1h
NAME                                 READY     STATUS             RESTARTS   AGE
po/ceph-mds-840702866-0n24u          1/1       Running            3          1h
po/ceph-mon-1870970076-7h5zw         1/1       Running            2          1h
po/ceph-mon-1870970076-d4uu2         1/1       Running            3          1h
po/ceph-mon-1870970076-s6d2p         1/1       Running            1          1h
po/ceph-mon-check-4116985937-ggv4m   1/1       Running            0          1h
po/ceph-osd-2m2mf                    1/1       Running            2          1h
po/ceph-rgw-2085838073-02154         0/1       Pending            0          1h
po/ceph-rgw-2085838073-0d6z7         0/1       CrashLoopBackOff   21         1h
po/ceph-rgw-2085838073-3trec         0/1       Pending            0          1h
```

Note that the ceph-rgw image is crashing because of an issue processing the mon_host name 'ceph-mon' in ceph.conf.  This is an upstream issue that needs to be worked but is not required to test ceph rbd or ceph filesystem functionality.

Finally, you can now test a ceph rbd volume:

```
export PODNAME=`kubectl get pods --selector="app=ceph,daemon=mon" --output=template --template="{{with index .items 0}}{{.metadata.name}}{{end}}" --namespace=ceph`
kubectl exec -it $PODNAME --namespace=ceph -- rbd create ceph-rbd-test --size 20G
kubectl exec -it $PODNAME --namespace=ceph -- rbd info ceph-rbd-test
```

If that works, you can create a container and attach it to that volume:

```
cd ceph/utils/test
kubectl create -f ceph-rbd-test.yaml --namespace=ceph
kubectl exec -it --namespace=ceph ceph-rbd-test -- df -h
```

### Cleanup

Always make sure to delete any test instances that have ceph volumes mounted before you delete your ceph cluster.  Otherwise, kubelet may get stuck trying to unmount volumes which can only be recovered with a reboot.  If you ran the tests above, this can be done with:

```
kubectl delete ceph-rbd-test --namespace=ceph
```

The easiest way to delete your environment is to delete the helm install:

```
# helm ls
NAME            REVISION        UPDATED                         STATUS          CHART
saucy-elk       1               Thu Nov 17 13:43:27 2016        DEPLOYED        ceph-0.1.0

# helm delete saucy-elk
```

And finally, because helm does not appear to cleanup all artifacts, you will want to delete the ceph namespace to remove any secrets helm installed:

```
kubectl delete namespace ceph
```
