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

Please keep in mind that the above script configures
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

It is also important to note that the above script does not actually installs
the Openstack client package on the host but instead it creates a bash
script `/usr/local/bin/openstack` that runs the Openstack client in a
Docker container. If you need to pass extra command line parameters to the
`docker run` command use the environment variable
`OPENSTACK_CLIENT_CONTAINER_EXTRA_ARGS`. For example if you need to mount a
directory from the host file system, you can do the following

.. code-block:: bash

    export OPENSTACK_CLIENT_CONTAINER_EXTRA_ARGS="-v /data:/data"
    /usr/local/bin/openstack <subcommand> <options>

Remember that the container file system is ephemeral and is destroyed
when you stop the container. So if you would like to use the
Openstack client capabilities interfacing with the file system then you have to mount
a directory from the host file system where you will read/write necessary files.
For example, this is useful when you create a key pair and save the private key in a file
which is then used for ssh access to VMs. Or it could be Heat recipes
which you prepare in advance and then use with Openstack client.

.. _setup-client.sh: https://opendev.org/openstack/openstack-helm/src/branch/master/tools/deployment/common/setup-client.sh
.. _MetalLB: https://metallb.universe.tf
