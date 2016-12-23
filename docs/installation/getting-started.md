# Overview
In order to drive towards a production-ready Openstack solution, our goal is to provide containerized, yet stable [persistent volumes](http://kubernetes.io/docs/user-guide/persistent-volumes/) that Kubernetes can use to schedule applications that require state, such as MariaDB (Galera). Although we make an assumption that the project should provide a “batteries included” approach towards persistent storage, we want to allow operators to define their own solution as well. Examples of this work will be documented in another section, however evidence of this is found throughout the project. If you have any questions or comments, please create an [issue](https://github.com/att-comdev/openstack-helm/issues).

**IMPORTANT**: Please see the latest published information about our application versions.


| | Version | Notes |
|--- |--- |--- |
| **Kubernetes** | [v1.5.1](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG.md#v151) | [Custom Controller for RDB tools](https://quay.io/repository/attcomdev/kube-controller-manager?tab=tags) |
| **Helm** | [v2.1.2](https://github.com/kubernetes/helm/wiki/Roadmap#210-decided) | Planning for [v2.2.0](https://github.com/kubernetes/helm/wiki/Roadmap#220-open-for-small-additions) |
| **Calico** | [v2.0](http://docs.projectcalico.org/v2.0/releases/) | [`calicoctl` v1.0](https://github.com/projectcalico/calicoctl/releases) |
| **Docker** | [v1.12.1](https://github.com/docker/docker/releases/tag/v1.12.1) | [Per kubeadm Instructions](http://kubernetes.io/docs/getting-started-guides/kubeadm/) | |

Other versions and considerations (such as other CNI SDN providers), config map data, and value overrides will be included in other documentation as we explore these options further.


# Quickstart (Bare Metal)
This walkthrough will help you set up a bare metal environment, using `kubeadm` on Ubuntu 16.04. The assumption is that you have a working `kubeadm` environment and that your environment is at a working state, ***prior*** to deploying a CNI-SDN. This deployment proceedure is opinionated *only to standardize the deployment process for users and developers*, and to limit questions to a known working deployment. Instructions will expand as the project becomes more mature.

If you’re environment looks like this, you are ready to continue:
```
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
```

## Deploying a CNI-Enabled SDN (Calico)

After an initial `kubeadmn` deployment has been scheduled, it is time to deploy a CNI-enabled SDN. We have selected **Calico**, but have also confirmed that this works for Weave, and Romana. For Calico version v2.0, you can apply the provided [Kubeadm Hosted Install](http://docs.projectcalico.org/v2.0/getting-started/kubernetes/installation/hosted/kubeadm/) manifest:

```
admin@kubenode01:~$ kubectl apply -f http://docs.projectcalico.org/v2.0/getting-started/kubernetes/installation/hosted/kubeadm/calico.yaml
```
**PLEASE NOTE:** If you are using a 192.168.0.0/16 CIDR for your Kubernetes hosts, you will need to modify [line 42](https://gist.github.com/v1k0d3n/a152b1f5b8db5a8ae9c8c7da575a9694#file-calico-kubeadm-hosted-yml-L42) for the `cidr` declaration within the `ippool`. This must be a `/16` range or more, as the `kube-controller` will hand out `/24` ranges to each node. We have included a sample comparison of the changes [here](http://docs.projectcalico.org/v2.0/getting-started/kubernetes/installation/hosted/kubeadm/calico.yaml) and [here](https://gist.githubusercontent.com/v1k0d3n/a152b1f5b8db5a8ae9c8c7da575a9694/raw/c950eef1123a7dcc4b0dedca1a202e0c06248e9e/calico-kubeadm-hosted.yml).

After the container CNI-SDN is deployed, Calico has a tool you can use to verify your deployment. You can download this tool, [`calicoctl`](https://github.com/projectcalico/calicoctl/releases) to execute the following command:
```
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
```

It is important to call out that the Self Hosted Calico manifest for v2.0 (above) supports `nodetonode` mesh, and `nat-outgoing` by default. This is a change from version 1.6.

## Preparing Persistent Storage
Persistant storage is improving. Please check our current and/or resolved [issues](https://github.com/att-comdev/openstack-helm/issues?utf8=✓&q=ceph) to find out how we're working with the community to improve persistent storage for our project. For now, a few preparations need to be completed.

### Kubernetes Controller Manager

Before deploying Ceph, you will need to re-deploy a custom Kubernetes Controller with the necessary [RDB](http://docs.ceph.com/docs/jewel/rbd/rbd/) utilities. For your convenience, we are maintaining this along with the Openstack-Helm project. If you would like to check the current [tags](https://quay.io/repository/attcomdev/kube-controller-manager?tab=tags) or the [security](https://quay.io/repository/attcomdev/kube-controller-manager/image/eedc2bf21cca5647a26e348ee3427917da8b17c25ead38e832e1ed7c2ef1b1fd?tab=vulnerabilities) of these pre-built containers, you may view them at [our public Quay container registry](https://quay.io/repository/attcomdev/kube-controller-manager?tab=tags). If you would prefer to build this container yourself, or add any additional packages, you are free to use our GitHub [dockerfiles](https://github.com/att-comdev/dockerfiles/tree/master/kube-controller-manager) repository to do so.

To make these changes, export your Kubernetes version, and edit the `image` line of your `kube-controller-manager` json manifest on your Kubernetes Master:
```
admin@kubenode01:~$ export kube_version=v1.5.1
admin@kubenode01:~$ sed -i "s|gcr.io/google_containers/kube-controller-manager-amd64:'$kube_version'|quay.io/attcomdev/kube-controller-manager:'$kube_version'|g" /etc/kubernetes/manifests/kube-controller-manager.json
```

Now you will want to `restart` your master server.

### Ceph Secrets Generation

Another thing of interest is that our deployment assumes that you can generate secrets at the time of the container deployment. We require the [`sigil`](https://github.com/gliderlabs/sigil/releases/download/v0.4.0/sigil_0.4.0_Linux_x86_64.tgz) binary on your deployment host in order to perform this action.
```
admin@kubenode01:~$ curl -L https://github.com/gliderlabs/sigil/releases/download/v0.4.0/sigil_0.4.0_Linux_x86_64.tgz | tar -zxC /usr/local/bin
```

### Kube Controller Manager DNS Resolution
Until the following [Kubernetes Pull Request](https://github.com/kubernetes/kubernetes/issues/17406) is merged, you will need to allow the Kubernetes Controller to use the internal container `skydns` endpoint as a DNS server, and add the Kubernetes search suffix into the controller's resolv.conf. As of now, the Kuberenetes controller only mirrors the host's `resolv.conf`. This is is not sufficent if you want the controller to know how to correctly resolve container service endpoints (in the case of DaemonSets).

First, find out what the IP Address of your `kube-dns` deployment is:
```
admin@kubenode01:~$ kubectl get svc kube-dns --namespace=kube-system
NAME       CLUSTER-IP   EXTERNAL-IP   PORT(S)         AGE
kube-dns   10.96.0.10   <none>        53/UDP,53/TCP   1d
admin@kubenode01:~$
```

As you can see by this example, `10.96.0.10` is the `CLUSTER-IP`IP. Now, have a look at the current `kube-controller-manager-kubenode01` `/etc/resolv.conf`:
```
admin@kubenode01:~$ kubectl exec kube-controller-manager-kubenode01 -n kube-system -- cat /etc/resolv.conf
# Dynamic resolv.conf(5) file for glibc resolver(3) generated by resolvconf(8)
#     DO NOT EDIT THIS FILE BY HAND -- YOUR CHANGES WILL BE OVERWRITTEN
nameserver 192.168.1.70
nameserver 8.8.8.8
search jinkit.com
admin@kubenode01:~$
```

What we need is for `kube-controller-manager-kubenode01` `/etc/resolv.conf` to look like this:
```
admin@kubenode01:~$ kubectl exec kube-controller-manager-kubenode01 -n kube-system -- cat /etc/resolv.conf
nameserver 10.96.0.10
nameserver 192.168.1.70
nameserver 8.8.8.8
search svc.cluster.local jinkit.com
admin@kubenode01:~$
```

You can change this by doing the following:
```
admin@kubenode01:~$ kubectl exec kube-controller-manager-kubenode01 -it -n kube-system -- /bin/bash
root@kubenode01:/# cat <<EOF > /etc/resolv.conf
nameserver 10.96.0.10
nameserver 192.168.1.70
nameserver 8.8.8.8
search svc.cluster.local jinkit.com
EOF
root@kubenode01:/# 
```

Now you can test your changes by deploying a service to your cluster, and resolving this from the controller. As an example, lets deploy something useful, like [Kubernetes dashboard](https://github.com/kubernetes/dashboard):
```
admin@kubenode01:~$ kubectl create -f https://rawgit.com/kubernetes/dashboard/master/src/deploy/kubernetes-dashboard.yaml
```

Note the `IP` field:
```
admin@kubenode01:~$ kubectl describe svc kubernetes-dashboard -n kube-system
Name:			kubernetes-dashboard
Namespace:		kube-system
Labels:			app=kubernetes-dashboard
Selector:		app=kubernetes-dashboard
Type:			NodePort
IP:			10.110.207.144
Port:			<unset>	80/TCP
NodePort:		<unset>	32739/TCP
Endpoints:		10.25.178.65:9090
Session Affinity:	None
No events.
admin@kubenode01:~$ 
```

Now you should be able to resolve the host `kubernetes-dashboard.kube-system.svc.cluster.local`:
```
bjozsa@kubenode01:~$ kubectl exec kube-controller-manager-kubenode01 -it -n kube-system -- ping kubernetes-dashboard.kube-system.svc.cluster.local
PING kubernetes-dashboard.kube-system.svc.cluster.local (10.110.207.144) 56(84) bytes of data.
...
...
bjozsa@kubenode01:~$
```
(Note: This host example above has `iputils-ping` installed)

Now we can continue with the deployment.


## Openstack-Helm Installation
Before you begin, make sure you have read and understand the project [Requirements](Requirements).

You can start openstack-helm fairly quickly.  Assuming the above requirements are met (above), you can install the charts in a layered approach.  The OpenStack parent chart, which installs all OpenStack services, is a work in progress and is simply a one-stack convenience.  For now, please install each individual service chart as noted below.

Note that the ```bootstrap``` chart is meant to be installed in every namespace you plan to use.  It helps install required secrets.

If any helm install step fails, you can back it out with ```helm delete --purge <releaseName>```

Make sure sigil is installed to perform the ceph secret generation, as noted in the [Requirements](Requirements).

```
# label all known nodes as candidates for pods
kubectl label nodes node-type=storage --all
kubectl label nodes openstack-control-plane=enabled --all
kubectl label nodes ceph-storage=enabled --all

# move into the aic-helm directory
cd aic-helm

# set your network cidr--these values are only
# appropriate for calico and may be different in your
# environment: using example above = 10.25.0.0/16 (avoiding 192.168.0.0/16 overlap)
export osd_cluster_network=10.25.0.0/16
export osd_public_network=10.25.0.0/16

# on every node that will receive ceph instances, 
# create some local directories used as nodeDirs
# for persistent storage
mkdir -p /var/lib/openstack-helm/ceph

# generate secrets (ceph, etc.)
cd common/utils/secret-generator
./generate_secrets.sh all `./generate_secrets.sh fsid`
cd ../../..

# now you are ready to build aic-helm
helm serve . &
helm repo add local http://localhost:8879/charts
make

# install ceph
helm install --name=ceph local/ceph --namespace=ceph

# bootstrap the openstack namespace for chart installation
helm install --name=bootstrap local/bootstrap --namespace=openstack

# install mariadb
helm install --name=mariadb local/mariadb --namespace=openstack

# install rabbitmq/memcache
helm install --name=memcached local/memcached --namespace=openstack
helm install --name=rabbitmq local/rabbitmq --namespace=openstack

# install keystone
helm install --name=keystone local/keystone --namespace=openstack

# install horizon
helm install --name=horizon local/horizon --namespace=openstack

# install glance
helm install --name=glance local/glance --namespace=openstack

# ensure all services enter a running state, with the
# exception of one jobs/glance-post and the ceph
# rgw containers, due to outstanding issues
watch kubectl get all --namespace=openstack
```

You should now be able to access horizon at http://<horizon-svc-ip> using admin/password
