# Overview
In order to drive towards a production-ready Openstack solution, our goal is to provide containerized, yet stable [persistent volumes](http://kubernetes.io/docs/user-guide/persistent-volumes/) that Kubernetes can use to schedule applications that require state, such as MariaDB (Galera). Although we assume that the project should provide a “batteries included” approach towards persistent storage, we want to allow operators to define their own solution as well. Examples of this work will be documented in another section, however evidence of this is found throughout the project. If you have any questions or comments, please create an [issue](https://github.com/att-comdev/openstack-helm/issues).

**IMPORTANT**: Please see the latest published information about our application versions.


| | Version | Notes |
|--- |--- |--- |
| **Kubernetes** | [v1.5.3](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG.md#v153) | [Custom Controller for RDB tools](https://quay.io/repository/attcomdev/kube-controller-manager?tab=tags) |
| **Helm** | [v2.2.1](https://github.com/kubernetes/helm/releases/tag/v2.2.1) | Planning for [v2.3.0](https://github.com/kubernetes/helm/milestone/30) |
| **Calico** | [v2.0](http://docs.projectcalico.org/v2.0/releases/) | [`calicoctl` v1.0](https://github.com/projectcalico/calicoctl/releases) |
| **Docker** | [v1.12.6](https://github.com/docker/docker/releases/tag/v1.12.1) | [Per kubeadm Instructions](http://kubernetes.io/docs/getting-started-guides/kubeadm/) | |

Other versions and considerations (such as other CNI SDN providers), config map data, and value overrides will be included in other documentation as we explore these options further.

The installation procedures below, will take an administrator from a new `kubeadm` installation to Openstack-Helm deployment.

# Kubernetes Preparation
This walkthrough will help you set up a bare metal environment with 5 nodes, using `kubeadm` on Ubuntu 16.04. The assumption is that you have a working `kubeadm` environment and that your environment is at a working state, ***prior*** to deploying a CNI-SDN. This deployment procedure is opinionated *only to standardize the deployment process for users and developers*, and to limit questions to a known working deployment. Instructions will expand as the project becomes more mature.

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
kubectl apply -f http://docs.projectcalico.org/v2.0/getting-started/kubernetes/installation/hosted/kubeadm/calico.yaml
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
Persistent storage is improving. Please check our current and/or resolved [issues](https://github.com/att-comdev/openstack-helm/issues?utf8=✓&q=ceph) to find out how we're working with the community to improve persistent storage for our project. For now, a few preparations need to be completed.

### Installing Ceph Host Requirements
At some future point, we want to ensure that our solution is cloud-native, allowing installation on any host system without a package manager and only a container runtime (i.e. CoreOS). Until this happens, we will need to ensure that `ceph-common` is installed on each of our hosts. Using our Ubuntu example:

```
sudo apt-get install ceph-common -y
```

We will always attempt to keep host-specific requirements to a minimum, and we are working with the Ceph team (Sébastien Han) to quickly address this Ceph requirement.

### Ceph Secrets Generation

Another thing of interest is that our deployment assumes that you can generate secrets at the time of the container deployment. We require the [`sigil`](https://github.com/gliderlabs/sigil/releases/download/v0.4.0/sigil_0.4.0_Linux_x86_64.tgz) binary on your deployment host in order to perform this action.
```
curl -L https://github.com/gliderlabs/sigil/releases/download/v0.4.0/sigil_0.4.0_Linux_x86_64.tgz | tar -zxC /usr/local/bin
```

### Kubernetes Controller Manager

Before deploying Ceph, you will need to re-deploy a custom Kubernetes Controller with the necessary [RDB](http://docs.ceph.com/docs/jewel/rbd/rbd/) utilities. For your convenience, we are maintaining this along with the Openstack-Helm project. If you would like to check the current [tags](https://quay.io/repository/attcomdev/kube-controller-manager?tab=tags) or the [security](https://quay.io/repository/attcomdev/kube-controller-manager/image/eedc2bf21cca5647a26e348ee3427917da8b17c25ead38e832e1ed7c2ef1b1fd?tab=vulnerabilities) of these pre-built containers, you may view them at [our public Quay container registry](https://quay.io/repository/attcomdev/kube-controller-manager?tab=tags). If you would prefer to build this container yourself, or add any additional packages, you are free to use our GitHub [dockerfiles](https://github.com/att-comdev/dockerfiles/tree/master/kube-controller-manager) repository to do so.

To make these changes, export your Kubernetes version, and edit the `image` line of your `kube-controller-manager` json manifest on your Kubernetes Master:
```
export kube_version=v1.5.3
sed -i "s|gcr.io/google_containers/kube-controller-manager-amd64:'$kube_version'|quay.io/attcomdev/kube-controller-manager:'$kube_version'|g" /etc/kubernetes/manifests/kube-controller-manager.json
```

Now you will want to `restart` your Kubernetes master server to continue.

### Kube Controller Manager DNS Resolution

Until the following [Kubernetes Pull Request](https://github.com/kubernetes/kubernetes/issues/17406) is merged, you will need to allow the Kubernetes Controller to use the internal container `skydns` endpoint as a DNS server, and add the Kubernetes search suffix into the controller's resolv.conf. As of now, the Kubernetes controller only mirrors the host's `resolv.conf`. This is not sufficient if you want the controller to know how to correctly resolve container service endpoints (in the case of DaemonSets).

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
kubectl create -f https://rawgit.com/kubernetes/dashboard/master/src/deploy/kubernetes-dashboard.yaml
```

Note the `IP` field:
```
admin@kubenode01:~$ kubectl describe svc kubernetes-dashboard -n kube-system
Name:               kubernetes-dashboard
Namespace:          kube-system
Labels:             app=kubernetes-dashboard
Selector:           app=kubernetes-dashboard
Type:               NodePort
IP:                 10.110.207.144
Port:               <unset>	80/TCP
NodePort:           <unset>	32739/TCP
Endpoints:          10.25.178.65:9090
Session Affinity:   None
No events.
admin@kubenode01:~$
```

Now you should be able to resolve the host `kubernetes-dashboard.kube-system.svc.cluster.local`:

```
admin@kubenode01:~$ kubectl exec kube-controller-manager-kubenode01 -it -n kube-system -- ping kubernetes-dashboard.kube-system.svc.cluster.local
PING kubernetes-dashboard.kube-system.svc.cluster.local (10.110.207.144) 56(84) bytes of data.
```

(Note: This host example above has `iputils-ping` installed)

### Kubernetes Node DNS Resolution

For each of the nodes to know exactly how to communicate with Ceph (and thus MariaDB) endpoints, each host much also have an entry for `kube-dns`. Since we are using Ubuntu for our example, place these changes in `/etc/network/interfaces` to ensure they remain after reboot.

Now we are ready to continue with the Openstack-Helm installation.


# Openstack-Helm Preparation

Please ensure that you have verified and completed the steps above to prevent issues with your deployment. Since our goal is to provide a Kubernetes environment with reliable, persistent storage, we will provide some helpful verification steps to ensure you are able to proceed to the next step.

Although Ceph is mentioned throughout this guide, our deployment is flexible to allow you the option of bringing any type of persistent storage. Although most of these verification steps are the same, if not very similar, we will use Ceph as our example throughout this guide.

## Node Labels

First, we must label our nodes according to their role. Although we are labeling `all` nodes, you are free to label only the nodes you wish. You must have at least one, although a minimum of three are recommended. Nodes are labeled according to their Openstack roles:

**Storage Nodes:** `ceph-storage`
**Control Plane:** `openstack-control-plane`
**Compute Nodes:** `openvswitch`, `openstack-compute-node`

```
kubectl label nodes openstack-control-plane=enabled --all
kubectl label nodes ceph-storage=enabled --all
kubectl label nodes openvswitch=enabled --all
kubectl label nodes openstack-compute-node=enabled --all
```

## Obtaining the Project

Download the latest copy of Openstack-Helm:

```
git clone https://github.com/att-comdev/openstack-helm.git
cd openstack-helm
```

## Ceph Preparation and Installation

Ceph must be aware of the OSX cluster and public networks. These CIDR ranges are the exact same ranges you used earlier in your Calico deployment yaml (our example was 10.25.0.0/16 due to our 192.168.0.0/16 overlap). Explore this variable to your deployment environment by issuing the following commands:

```
export osd_cluster_network=10.25.0.0/16
export osd_public_network=10.25.0.0/16
```

## Ceph Storage Volumes

Ceph must also have volumes to mount on each host labeled for `ceph-storage`. On each host that you labeled, create the following directory (can be overriden):

```
mkdir -p /var/lib/openstack-helm/ceph
```

*Repeat this step for each node labeled: `ceph-storage`*

## Ceph Secrets Generation

Although you can bring your own secrets, we have conveniently created a secret generation tool for you (for greenfield deployments). You can create secrets for your project by issuing the following:

```
cd helm-toolkit/utils/secret-generator
./generate_secrets.sh all `./generate_secrets.sh fsid`
cd ../../..
```

## Nova Compute Instance Storage

Nova Compute requires a place to store instances locally.  Each node labeled `openstack-compute-node` needs to have the following directory:

```
mkdir -p /var/lib/nova/instances
```

*Repeat this step for each node labeled: `openstack-compute-node`*

## Helm Preparation

Now we need to install and prepare Helm, the core of our project. Please use the installation guide from the [Kubernetes/Helm](https://github.com/kubernetes/helm/blob/master/docs/install.md#from-the-binary-releases) repository. Please take note of our required versions above.

Once installed, and initiated (`helm init`), you will need your local environment to serve helm charts for use. You can do this by:

```
helm serve &
helm repo add local http://localhost:8879/charts
```

# Openstack-Helm Installation

Now we are ready to deploy, and verify our Openstack-Helm installation. The first required is to build out the deployment secrets, lint and package each of the charts for the project. Do this my running `make` in the `openstack-helm` directory:

```
make
```

**Helpful Note:** If you need to make any changes to the deployment, you may run `make` again, delete your helm-deployed chart, and redeploy the chart (update). If you need to delete a chart for any reason, do the following:

```
helm list

# NAME          	REVISION	UPDATED                 	STATUS  	CHART
# bootstrap     	1       	Fri Dec 23 13:37:35 2016	DEPLOYED	bootstrap-0.2.0
# bootstrap-ceph	1       	Fri Dec 23 14:27:51 2016	DEPLOYED	bootstrap-0.2.0
# ceph          	3       	Fri Dec 23 14:18:49 2016	DEPLOYED	ceph-0.2.0
# keystone      	1       	Fri Dec 23 16:40:56 2016	DEPLOYED	keystone-0.2.0
# mariadb       	1       	Fri Dec 23 16:15:29 2016	DEPLOYED	mariadb-0.2.0
# memcached     	1       	Fri Dec 23 16:39:15 2016	DEPLOYED	memcached-0.2.0
# rabbitmq      	1       	Fri Dec 23 16:40:34 2016	DEPLOYED	rabbitmq-0.2.0

helm delete --purge keystone
```
Please ensure that you use ``--purge`` whenever deleting a project.

## Ceph Installation and Verification
Install the first service, which is Ceph. If all instructions have been followed as mentioned above, this installation should go smoothly. Use the following command to install Ceph:
```
helm install --set network.public=$osd_public_network --name=ceph local/ceph --namespace=ceph
```

## Bootstrap Installation
At this time (and before verification of Ceph) you'll need to install the `bootstrap` chart. The `bootstrap` chart will install secrets for both the `ceph` and `openstack` namespaces for the general StorageClass:
```
helm install --name=bootstrap-ceph local/bootstrap --namespace=ceph
helm install --name=bootstrap-openstack local/bootstrap --namespace=openstack
```

You may want to validate that Ceph is deployed successfully. For more information on this, please see the section entitled [Ceph Troubleshooting](../troubleshooting/ts-persistent-storage.md).


## MariaDB Installation and Verification
We are using Galera to cluster MariaDB and establish a quorum. To install the MariaDB, issue the following command:
```
helm install --name=mariadb local/mariadb --namespace=openstack
```

## Installation of Other Services
Now you can easily install the other services simply by going in order:

**Install Memcached/Etcd/RabbitMQ:**
```
helm install --name=memcached local/memcached --namespace=openstack
helm install --name=etcd-rabbitmq local/etcd --namespace=openstack
helm install --name=rabbitmq local/rabbitmq --namespace=openstack
```

**Install Keystone:**
```
helm install --name=keystone local/keystone --set replicas=2 --namespace=openstack
```

**Install Horizon:**
```
helm install --name=horizon local/horizon --set network.enable_node_port=true --namespace=openstack
```

**Install Glance:**
```
helm install --name=glance local/glance --set replicas.api=2,replicas.registry=2 --namespace=openstack
```

**Install Heat:**
```
helm install --name=heat local/heat --namespace=openstack
```

**Install Neutron:**
```
helm install --name=neutron local/neutron --set replicas.server=2 --namespace=openstack
```

**Install Nova:**
```
helm install --name=nova local/nova --set control_replicas=2 --namespace=openstack
```

**Install Cinder:**
```
helm install --name=cinder local/cinder --set replicas.api=2 --namespace=openstack
```

## Final Checks
Now you can run through your final checks. Wait for all services to come up :
```
watch kubectl get all --namespace=openstack
```

Finally, you should now be able to access horizon at http://<horizon-svc-ip> using admin/password
