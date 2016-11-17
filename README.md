# aic-helm

This is a fully self-contained OpenStack deployment on Kubernetes.  This collection is a work in progress so components will continue to be added over time.

The following charts form the foundation to help establish an OpenStack control plane, including shared storage and bare metal provisioning:

- [ceph](ceph/README.md)
- maas (in progress)
- aic-kube (in progress)

These charts, unlike the OpenStack charts below, are designed to run directly.  They form the foundational layers necessary to bootstrap an environment in may run in separate namespaces.  The intention is to layer them. Please see the direct links above as they become available for README instructions crafted for each chart.  Please walk through each of these as some of them require build steps that should be done before running make.

The OpenStack charts under development will focus on container images leveraging the entrypoint model.  This differs somewhat from the existing [openstack-helm](https://github.com/sapcc/openstack-helm) repository maintained by SAP right now although we have shamelessly "borrowed" many concepts from them.  For these charts, we will be following the same region approach as openstack-helm, namely that these charts will not install and run directly. They are included in the "openstack" chart as requirements, the openstack chart is effectively an abstract region and is intended to be required by a concrete region chart.  We will provide an example region chart as well as sample region specific settings and certificate generation instructions.

Similar to openstack-helm, much of the 'make' complexity in this repository surrounds the fact that helm does not support directory based config maps or secrets.  This will continue to be the case until (https://github.com/kubernetes/helm/issues/950) receives more attention.
