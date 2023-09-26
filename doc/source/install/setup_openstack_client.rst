Setup OpenStack client
======================

The OpenStack client software is a crucial tool for interacting
with OpenStack services. In certain OpenStack-Helm deployment
scripts, the OpenStack client software is utilized to conduct
essential checks during deployment. Therefore, installing the
OpenStack client on the developer's machine is a vital step.

The script `setup-client.sh`_ can be used to setup the OpenStack
client.

.. code-block:: bash

    cd ~/osh/openstack-helm
    ./tools/deployment/common/setup-client.sh

At this point you have to keep in mind that the above script configures
OpenStack client so it uses internal Kubernetes FQDNs like
`keystone.openstack.svc.cluster.local`. In order to be able to resolve these
internal names you have to configure the Kubernetes authoritative DNS server
(CoreDNS) to work as a recursive resolver and then add its IP (`10.96.0.10` by default)
to `/etc/resolv.conf`. This is only going to work when you try to access
to OpenStack services from one of Kubernetes nodes because IPs from the
Kubernetes service network are routed only between Kubernetes nodes.

If you wish to access OpenStack services from outside the Kubernetes cluster,
you need to expose the OpenStack Ingress controller using an IP address accessible
from outside the Kubernetes cluster, typically achieved through solutions like
`MetalLB`_ or similar tools. In this scenario, you should also ensure that you
have set up proper FQDN resolution to map to the external IP address and
create the necessary Ingress objects for the associated FQDN.

.. _setup-client.sh: https://opendev.org/openstack/openstack-helm/src/branch/master/tools/deployment/common/setup-client.sh
.. _MetalLB: https://metallb.universe.tf
