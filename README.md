# aic-helm

This is a fully self-contained OpenStack deployment on Kubernetes.  This collection is a work in progress so components will continue to be added over time.

## Requirements

The aic-helm project is fairly opinionated.  We will work to generalize the configuration but since we are targeting a fully functional proof of concept end-to-end, we will have to limit the plugin like functionality within this project.

### helm

The entire aic-helm project is obviously helm driven.  All components should work with 2.0.0-rc2 or later.

### baremetal provisioning

The aic-helm project assumes Canonical's MaaS as the foundational bootstrap provider.  We create the MaaS service inside Kubernetes for ease of deployment and upgrades.  This has a few requirements for external network connectivity to provide bootstrapping noted in the maas chart README.

### dynamic volume provisioning

At the moment, this is not optional.  We will strive to make a non-1.5.0 requirement path in all charts using an alternative persistent storage approach but that currently, all charts make the assumption that dynamic volume provisioning is supported.

To support dynamic volume provisioning, the aic-helm project requires Kubernetes 1.5.0-beta1 in order to obtain rbd dynamic volume support.  Although rbd volumes are supported in the stable v1.4 version, dynamic rbd volumes allowing PVCs are only supported in 1.5.0-beta.1 and beyond.  Note that you can still use helm-2.0.0 with 1.5.0-beta.1, but you will not be able to use PetSets until the following helm [issue](https://github.com/kubernetes/helm/issues/1581) is resolved. 

This can be accomplished with a [kubeadm](http://kubernetes.io/docs/getting-started-guides/kubeadm/) based cluster install:

```
kubeadm init --use-kubernetes-version v1.5.0-beta.1
```

Note that in addition to Kubernetes 1.5.0-beta.1, you will need to replace the kube-controller-manager container with one that supports the rbd utilities.  We have made a convenient container that you can drop in as a replacement.  It is an ubuntu based container with the ceph tools and the kube-controller-manager binary from the 1.5.0-beta.1 release available as a [Dockerfile](https://github.com/att-comdev/dockerfiles/tree/master/kube-controller-manager) or a quay.io image you can update in your kubeadm manifest ```/etc/kubernetes/manifests/kube-controller-manager.json``` directly with ```image: quay.io/attcomdev/kube-controller-manager```

The kubelet should pick up the change and restart the container.

For the kube-controller-manager to be able to talk to the ceph-mon instances, ensure it can resolve ceph-mon.ceph (assuming you install the ceph chart into the ceph namespace).  This is done by ensuring that both the baremetal host running the kubelet process and the kube-controller-manager container have the SkyDNS address and the appropriate search string in /etc/resolv.conf.  This is covered in more detail in the [ceph](ceph/README.md) but a typical resolv.conf would look like this:

```
nameserver 10.32.0.2 ### skydns instance ip
nameserver 8.8.8.8
nameserver 8.8.4.4
search svc.cluster.local
```

Finally, you need to install Sigil to help in the generation of Ceph Secrets. You can do this by running the following command as root:

```
curl -L https://github.com/gliderlabs/sigil/releases/download/v0.4.0/sigil_0.4.0_Linux_x86_64.tgz | tar -zxC /usr/local/bin
```

## QuickStart

You can start aic-helm fairly quickly.  Assuming the above requirements are met, you can install the charts in a layered approach.  Today, the openstack chart is only tied to the mariadb sub-chart.  We will continue to add other OpenStack components into the openstack parent chart as they are validated.

Note that the openstack parent chart should always be used as it does some prepatory work for the openstack namespace for subcharts, such as ensuring ceph secrets are available to all subcharts.

```
# label all known nodes as candidates for pods
kubectl label nodes node-type=storage --all
kubectl label nodes openstack-control-plane=enabled --all

# move into the aic-helm directory
cd aic-helm

# generate secrets (ceph, etc.)
export osd_cluster_network=10.32.0.0/12
export osd_public_network=10.32.0.0/12
cd common/utils/secret-generator
./generate_secrets.sh all `./generate_secrets.sh fsid`
cd ../../..

# now you are ready to build aic-helm
helm serve . &
make

# install
helm install local/chef --namespace=ceph
helm install local/openstack --namespace=openstack
```

## Control Plane Charts

The following charts form the foundation to help establish an OpenStack control plane, including shared storage and bare metal provisioning:

- [ceph](ceph/README.md)
- maas (in progress)
- aic-kube (in progress)

These charts, unlike the OpenStack charts below, are designed to run directly.  They form the foundational layers necessary to bootstrap an environment in may run in separate namespaces.  The intention is to layer them. Please see the direct links above as they become available for README instructions crafted for each chart.  Please walk through each of these as some of them require build steps that should be done before running make.

## Infrastructure Charts

- [mariadb](mariadb/README.md)
- rabbitmq (in progress)
- memcached (in progress)

## OpenStack Charts

- keystone (in progress)

The OpenStack charts under development will focus on container images leveraging the entrypoint model.  This differs somewhat from the existing [openstack-helm](https://github.com/sapcc/openstack-helm) repository maintained by SAP right now although we have shamelessly "borrowed" many oncepts from them.  For these charts, we will be following the same region approach as openstack-helm, namely that these charts will not install and run directly. They are included in the "openstack" chart as requirements, the openstack chart is effectively an abstract region and is intended to be required by a concrete region chart.  We will provide an example region chart as well as sample region specific settings and certificate generation instructions.


Similar to openstack-helm, much of the 'make' complexity in this repository surrounds the fact that helm does not support directory based config maps or secrets.  This will continue to be the case until (https://github.com/kubernetes/helm/issues/950) receives more attention.
