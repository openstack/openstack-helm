# Development of Openstack-Helm

Community Development is extremely important to us. As developers, we want development of Openstack-Helm to be an easy, painless experience. Please evaluate, make recommendations, and feel welcome to contribute to this project! Below, are some instructions and suggestions to help you get started.

# Requirements
There's really only a few prerequisites in order to get started. The first is getting a recent version of Helm.

**Kubernetes Minikube:**
Ensure that you have installed a recent version of [Kubernetes/Minikube](http://kubernetes.io/docs/getting-started-guides/minikube/).

**Kubernetes Helm:**
Install a recent version of [Kubernetes/Helm](https://github.com/kubernetes/helm):

Helm Installation Quickstart:

```
$ curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get > get_helm.sh
$ chmod 700 get_helm.sh
$ ./get_helm.sh
```


# Getting Started

After installing Minikube, start it with the flags listed below. Ensure that you have supplied enough disk, memory, and the current version of Kubernetes during `minikube start`. More information can be found [HERE](https://github.com/kubernetes/minikube/blob/master/docs/minikube_start.md).

```
$ minikube start \
    --network-plugin=cni \
    --kubernetes-version v1.5.1 \
    --disk-size 40g
```

Next deploy the [Calico](http://docs.projectcalico.org/master/getting-started/kubernetes/installation/hosted/hosted) manifest. This is not a requirement in cases where you want to use your own SDN, however you are doing so at your own experience. Note, which versions of Calico are recommended in our [Installation Guide](https://github.com/att-comdev/openstack-helm/blob/master/docs/installation/getting-started.md#overview).

```
$ kubectl create -f http://docs.projectcalico.org/v2.0/getting-started/kubernetes/installation/hosted/calico.yaml
```

Wait for the environment to come up without error (like shown below).

```
$ kubectl get pods -o wide --all-namespaces -w
NAMESPACE     NAME                                        READY     STATUS      RESTARTS   AGE       IP               NODE
kube-system   calico-node-r9b9s                           2/2       Running     0          3m        192.168.99.100   minikube
kube-system   calico-policy-controller-2974666449-hm0zr   1/1       Running     0          3m        192.168.99.100   minikube
kube-system   configure-calico-r6lnw                      0/1       Completed   0          3m        192.168.99.100   minikube
kube-system   kube-addon-manager-minikube                 1/1       Running     0          7m        192.168.99.100   minikube
kube-system   kube-dns-v20-sh5gp                          3/3       Running     0          7m        192.168.120.64   minikube
kube-system   kubernetes-dashboard-m24s8                  1/1       Running     0          7m        192.168.120.65   minikube
```

Next, initialize [Helm](https://github.com/kubernetes/helm/blob/master/docs/install.md#easy-in-cluster-installation) (which includes deploying tiller).

```
$ helm init
Creating /Users/admin/.helm
Creating /Users/admin/.helm/repository
Creating /Users/admin/.helm/repository/cache
Creating /Users/admin/.helm/repository/local
Creating /Users/admin/.helm/plugins
Creating /Users/admin/.helm/starters
Creating /Users/admin/.helm/repository/repositories.yaml
Creating /Users/admin/.helm/repository/local/index.yaml
$HELM_HOME has been configured at $HOME/.helm.

Tiller (the helm server side component) has been installed into your Kubernetes Cluster.
Happy Helming!

$ kubectl get pods -o wide --all-namespaces | grep tiller
kube-system   tiller-deploy-3299276078-n98ct              1/1       Running   0          39s       192.168.120.66   minikube
```

With Helm now installed, you will need to start a local [Helm server](https://github.com/kubernetes/helm/blob/7a15ad381eae794a36494084972e350306e498fd/docs/helm/helm_serve.md#helm-serve) (in the background), and point to a locally provided Helm [repository](https://github.com/kubernetes/helm/blob/7a15ad381eae794a36494084972e350306e498fd/docs/helm/helm_repo_index.md#helm-repo-index):

```
$ helm serve . &
$ helm repo add local http://localhost:8879/charts
"local" has been added to your repositories
```

Verify that the local repository is working correctly:

```
$ helm repo list
NAME  	URL
stable	https://kubernetes-charts.storage.googleapis.com/
local 	http://localhost:8879/charts
```

Now you will want to download the latest release of the project, preferably from `master` since you are following the "developer" instructions.

```
$ git clone https://github.com/att-comdev/openstack-helm.git
```

Next, build in the git repo you have just cloned, and push the charts to your new local repository:

```
$ cd openstack-helm
$ make
```

Perfect! You’re ready to install, deploy, develop, destroy, repeat!


# Installation and Testing

After following the instructions above, you are in a state where you can develop for the project. If you need to make any changes to a chart, all you need to do is run `make` again. The charts will be updated in your local repository.


To deploy the Charts, you will want to make some important considerations:
* Persistent Storage for "Development" Mode is `hostPath`.
* Make sure to note `values.yaml` for the MariaDB chart. You will will want to have the `hostPath` directory created prior to deploying MariaDB.
* Do *not* install the `common` `ceph` or `bootstrap` charts. These charts are required for deploying Ceph PVC's.
* If Ceph development is required, you will need to follow the quickstart guide rather than this Development mode documentation.

To deploy Openstack-Helm in "development” mode, first ensure that you have created a minikube-approved hostPath volume. Minikube is very specific about what is expected for hostPath volumes. The following volumes are acceptable for minikube deployments:

```
/data
/var/lib/localkube
/var/lib/docker
```

So we recommend creating one for MariaDB like shown below.

```
$ sudo mkdir -p /data/openstack-helm/mariadb
```

### Label Minikube Node
Next, label your minikube node according to the documentation in our installation guide (this remains exactly the same).

```
$ kubectl label nodes openstack-control-plane=enabled --all --namespace=openstack

```
***NOTE:*** *You do not need to label your minikube cluster for `ceph-storage`, since development mode uses hostPath.*


### Deploy MariaDB
Now you can deploy the first recommended chart (required by all other child charts), MariaDB.

```
$ helm install --name mariadb --set development.enabled=true local/mariadb --namespace=openstack
```
***IMPORTANT:*** *MariaDB seeding tasks run for quite a while. This is expected behavior. Please wait for a few minutes for these jobs to complete.*


### Deploy Remaining Charts
Once MariaDB is deployed fulfilled, you can deploy other charts as needed.

```
$ helm install --name=memcached local/memcached --namespace=openstack
$ helm install --name=rabbitmq local/rabbitmq --namespace=openstack
$ helm install --name=keystone local/keystone --namespace=openstack
$ helm install --name=horizon local/horizon --namespace=openstack
$ helm install --name=glance local/glance --namespace=openstack
$ helm install --name=glance local/nova --namespace=openstack
$ helm install --name=glance local/neutron --namespace=openstack
```

# Horizon Management
Now that each Chart has been deployed, the last thing required (in the case of Minikube development) is to change our typical service for Horizon to a `nodePort` endpoint. You can use the `kubectl` command to edit this service manually.

```
$ kubectl edit svc horizon -n openstack
```

Once you have the live manifest in edit mode, you can enable `nodePort` by replicating some of the fields below (specifically, the `nodePort` lines). 

```
apiVersion: v1
kind: Service
metadata:
  creationTimestamp: 2016-12-30T03:05:55Z
  name: horizon
  namespace: openstack
  resourceVersion: "2458"
  selfLink: /api/v1/namespaces/openstack/services/horizon
  uid: e18011bb-ce3c-11e6-8cd6-6249d6214f72
spec:
  clusterIP: 10.0.0.80
  ports:
  - nodePort: 31537
    port: 80
    protocol: TCP
    targetPort: 80
  selector:
    app: horizon
  sessionAffinity: None
  type: NodePort
status:
  loadBalancer: {}
```

Now you're ready to manage Openstack!

If you have any questions, comments, or find any bugs, please submit an issue so we can quickly address it.

# Troubleshooting
In order to protect your general sanity, we've included a currated list of verification and troubleshooting steps that may help you avoid some potential issues while developing Openstack-Helm.

**MariaDB**
To verify the state of MariaDB, use the following command:

```
$ kubectl exec mariadb-0 -it -n openstack -- mysql -uroot -ppassword -e 'show databases;'
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
+--------------------+
$ 
```

**Helm Server/Repository**
Sometimes you will run into Helm server or repository issues. For our purposes, it's mostly safe to whack these. If you are developing charts for other projects, use at your own risk (you most likely know how to resolve these issues already).

To check for a running instance of Helm Server:

```
$ ps -a | grep "helm serve"
29452 ttys004    0:00.23 helm serve .
35721 ttys004    0:00.00 grep --color=auto helm serve
```

Kill the "helm serve" running process:

```
$ kill 29452
```

To clear out previous Helm repositories, and reinstall a local repository:

```
$ helm repo list
NAME  	URL
stable	https://kubernetes-charts.storage.googleapis.com/
local 	http://localhost:8879/charts
$ 
$ helm repo remove local
```

This allows you to readd your local repository, if you ever need to do these steps:

```
$ helm repo add local http://localhost:8879/charts
```
