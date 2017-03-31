# Development Environment Setup

## Requirements

  * Hardware
    * 16GB RAM
    * 32GB HDD Space
  * Software
    * Vagrant >= 1.8.0
    * VirtualBox >= 5.1.0
    * Kubectl
    * Helm
    * Git

## Deploy

  * Make sure you are in the directory containing the Vagrantfile before running the following commands.

### Create VM

``` bash
vagrant up --provider virtualbox
```

### Deploy NFS Provisioner for development PVCs

``` bash
vagrant ssh --command "sudo docker exec kubeadm-aio kubectl create -R -f /opt/nfs-provisioner/"
```

### Setup Clients and deploy Helm's tiller

``` bash
./setup-dev-host.sh
```

### Label VM node(s) for OpenStack-Helm Deployment

``` bash
kubectl label nodes openstack-control-plane=enabled --all --namespace=openstack
kubectl label nodes openvswitch=enabled --all --namespace=openstack
kubectl label nodes openstack-compute-node=enabled --all --namespace=openstack
```
