# Openstack-Helm: Minikube Deployment

Community development is extremely important to us. As an open source development team, we want the development of Openstack-Helm to be an easy experience. Please evaluate, and make recommendations. We want developers to feel welcome to contribute to this project. Below are some instructions and suggestions to help you get started.

# Requirements
We've tried to minimize the number of prerequisites required in order to get started. For most users, the main prerequisites are to install the most recent versions of Minikube and Helm. For fresh installations, you may also need to install a Hypervisor that works for your system (that is supported by [Minikube](https://kubernetes.io/docs/getting-started-guides/minikube/#requirements)).

**Kubectl:** Download and install the version of [`kubectl`](https://kubernetes.io/docs/getting-started-guides/kubectl/) that matches your Kubernetes deployment.

**Kubernetes Minikube:**
Ensure that you have installed a recent version of [Kubernetes/Minikube](http://kubernetes.io/docs/getting-started-guides/minikube/).

**Kubernetes Helm:**
Install a recent version of [Kubernetes/Helm](https://github.com/kubernetes/helm):

Helm Installation Quickstart:

```
curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get > get_helm.sh
chmod 700 get_helm.sh
./get_helm.sh
```

# TLDR;

If your environment meets all of the prerequisites above, you can simply use the following commands:

```
# Clone the project:
git clone https://github.com/att-comdev/openstack-helm.git && cd openstack-helm

# Get a list of the current tags:
git tag -l

# Checkout the tag you want to work with (use master for development):
# For stability and testing, checkout the latest stable branch.
git checkout 0.2.0

# Start a local Helm Server:
helm serve &
helm repo add local http://localhost:8879/charts

# You may need to change these params for your environment. Look up use of --iso-url if needed:
minikube start \
        --network-plugin=cni \
        --kubernetes-version v1.5.1 \
        --disk-size 40g \
        --memory 16384 \
        --cpus 4 \
        --vm-driver kvm \
        --iso-url=https://storage.googleapis.com/minikube/iso/minikube-v1.0.4.iso

# Deploy a CNI/SDN:
kubectl create -f http://docs.projectcalico.org/v2.0/getting-started/kubernetes/installation/hosted/calico.yaml

# Initialize Helm/Deploy Tiller:
helm init

# Package the Openstack-Helm Charts, and push them to your local Helm repository:
make

# Label the Minikube as an Openstack Control Plane node:
kubectl label nodes openstack-control-plane=enabled --all --namespace=openstack

# Deploy each chart:
helm install --name mariadb --set development.enabled=true local/mariadb --namespace=openstack
helm install --name=memcached local/memcached --namespace=openstack
helm install --name=etcd-rabbitmq local/etcd --namespace=openstack
helm install --name=rabbitmq local/rabbitmq --namespace=openstack
helm install --name=keystone local/keystone --namespace=openstack
helm install --name=cinder local/cinder --namespace=openstack
helm install --name=glance local/glance --namespace=openstack
helm install --name=heat local/heat --namespace=openstack
helm install --name=nova local/nova --namespace=openstack
helm install --name=neutron local/neutron --namespace=openstack
helm install --name=horizon local/horizon --namespace=openstack
```

# Getting Started

After installation, start Minikube with the flags listed below. Ensure that you have supplied enough disk, memory, and the current version flag for Kubernetes during `minikube start`. More information can be found [HERE](https://github.com/kubernetes/minikube/blob/master/docs/minikube_start.md).

```
minikube start \
    --network-plugin=cni \
    --kubernetes-version v1.5.1 \
    --disk-size 40g \
    --memory 4048
```

Next, deploy the [Calico](http://docs.projectcalico.org/master/getting-started/kubernetes/installation/hosted/hosted) manifest. This is not a requirement in cases where you want to use your own CNI-enabled SDN, however you are doing so at your own experience. Note which versions of Calico are recommended for the project in our [Installation Guide](https://github.com/att-comdev/openstack-helm/blob/master/docs/installation/getting-started.md#overview).

```
kubectl create -f http://docs.projectcalico.org/v2.0/getting-started/kubernetes/installation/hosted/calico.yaml
```

Wait for the environment to come up without error (like shown below).

```
kubectl get pods -o wide --all-namespaces -w

# NAMESPACE     NAME                                        READY     STATUS      RESTARTS   AGE       IP               NODE
# kube-system   calico-node-r9b9s                           2/2       Running     0          3m        192.168.99.100   minikube
# kube-system   calico-policy-controller-2974666449-hm0zr   1/1       Running     0          3m        192.168.99.100   minikube
# kube-system   configure-calico-r6lnw                      0/1       Completed   0          3m        192.168.99.100   minikube
# kube-system   kube-addon-manager-minikube                 1/1       Running     0          7m        192.168.99.100   minikube
# kube-system   kube-dns-v20-sh5gp                          3/3       Running     0          7m        192.168.120.64   minikube
# kube-system   kubernetes-dashboard-m24s8                  1/1       Running     0          7m        192.168.120.65   minikube
```

Next, initialize [Helm](https://github.com/kubernetes/helm/blob/master/docs/install.md#easy-in-cluster-installation) (which includes deploying tiller).

```
helm init

# Creating /Users/admin/.helm
# Creating /Users/admin/.helm/repository
# Creating /Users/admin/.helm/repository/cache
# Creating /Users/admin/.helm/repository/local
# Creating /Users/admin/.helm/plugins
# Creating /Users/admin/.helm/starters
# Creating /Users/admin/.helm/repository/repositories.yaml
# Creating /Users/admin/.helm/repository/local/index.yaml
# $HELM_HOME has been configured at $HOME/.helm.

# Tiller (the helm server side component) has been installed into your Kubernetes Cluster.
# Happy Helming!
```

Ensure that Tiller is deployed successfully:

```
kubectl get pods -o wide --all-namespaces | grep tiller

# kube-system   tiller-deploy-3299276078-n98ct              1/1       Running   0          39s       192.168.120.66   minikube
```

With Helm installed, you will need to start a local [Helm server](https://github.com/kubernetes/helm/blob/7a15ad381eae794a36494084972e350306e498fd/docs/helm/helm_serve.md#helm-serve) (in the background), and point to a locally configured Helm [repository](https://github.com/kubernetes/helm/blob/7a15ad381eae794a36494084972e350306e498fd/docs/helm/helm_repo_index.md#helm-repo-index):

```
helm serve &
helm repo add local http://localhost:8879/charts

# "local" has been added to your repositories
```

Verify that the local repository is configured correctly:

```
helm repo list

# NAME  	URL
# stable	https://kubernetes-charts.storage.googleapis.com/
# local 	http://localhost:8879/charts
```

Download the latest release of the project, preferably from `master` since you are following the "developer" instructions.

```
git clone https://github.com/att-comdev/openstack-helm.git
```

Run `make` against the newly cloned project, which will automatically build secrets for the deployment and push the charts to your new local Helm repository:

```
cd openstack-helm
make
```

Perfect! You’re ready to install, develop, deploy, destroy, and repeat (when necessary)!


# Installation and Testing

After following the instructions above your environment is in a state where you can enhance the current charts, or develop new charts for the project. If you need to make changes to a chart, simply re-run `make` against the project in the top-tier directory. The charts will be updated and automatically re-pushed to your local repository.


Consider the following when using Minikube and development mode:
* Persistent Storage used for Minikube development mode is `hostPath`. The Ceph PVC's included with this project are not intended to work with Minikube.
* There is *no need* to install the `helm-toolkit` `ceph` or `bootstrap` charts. These charts are required for deploying Ceph PVC's.
* Familiarize yourself with `values.yaml` included with the MariaDB chart. You will want to have the `storage_path` directory created prior to deploying MariaDB. This value will be used as the deployment's `hostPath`.
* If Ceph development is required, you will need to follow the [getting started guide](https://github.com/att-comdev/openstack-helm/blob/master/docs/installation/getting-started.md) rather than this development mode documentation.

To deploy Openstack-Helm in development mode, ensure you've created a minikube-approved `hostPath` volume. Minikube is very specific about what is expected for `hostPath` volumes. The following volumes are acceptable for minikube deployments:

```
/data
/var/lib/localkube
/var/lib/docker
/tmp/hostpath_pv
/tmp/hostpath-provisioner
```

### Label Minikube Node

Be sure to label your minikube node according to the documentation in our installation guide (this remains exactly the same).

```
kubectl label nodes openstack-control-plane=enabled --all --namespace=openstack

```
***NOTE:*** *You do not need to label your minikube cluster for `ceph-storage`, since development mode uses hostPath.*


### Deploy MariaDB

Now you can deploy the MariaDB chart, which is required by all other child charts.

```
helm install --name mariadb --set development.enabled=true local/mariadb --namespace=openstack
```
***IMPORTANT:*** *MariaDB seeding tasks run for quite a while. This is expected behavior, as several checks are completed prior to completion. Please wait for a few minutes for these jobs to finish.*


### Deploy Remaining Charts

Once MariaDB is deployed complete, deploy the other charts as needed.

```
helm install --name=memcached local/memcached --namespace=openstack
helm install --name=etcd-rabbitmq local/etcd --namespace=openstack
helm install --name=rabbitmq local/rabbitmq --namespace=openstack
helm install --name=keystone local/keystone --namespace=openstack
helm install --name=horizon local/horizon --namespace=openstack
helm install --name=cinder local/cinder --namespace=openstack
helm install --name=glance local/glance --namespace=openstack
helm install --name=nova local/nova --namespace=openstack
helm install --name=neutron local/neutron --namespace=openstack
helm install --name=heat local/heat --namespace=openstack
```

# Horizon Management

After each chart is deployed, you may wish to change the typical service endpoint for Horizon to a `nodePort` service endpoint (this is unique to Minikube deployments). Use the `kubectl edit` command to edit this service manually.

```
sudo kubectl edit svc horizon -n openstack
```

With the deployed manifest in edit mode, you can enable `nodePort` by replicating some of the fields below (specifically, the `nodePort` lines).

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

**Accessing Horizon:**<br>
*Now you're ready to manage OpenStack! Point your browser to the following:*<br>
***URL:*** *http://192.168.99.100:31537/* <br>
***User:*** *admin* <br>
***Pass:*** *password* <br>

If you have any questions, comments, or find any bugs, please submit an issue so we can quickly address them.

# Troubleshooting

* [Openstack-Helm Minikube Troubleshooting](../troubleshooting/ts-minikube.md)
