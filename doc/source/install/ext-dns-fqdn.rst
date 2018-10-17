============================
External DNS to FQDN/Ingress
============================

Overview
========

In order to access your OpenStack deployment on Kubernetes we can use the Ingress Controller
or NodePorts to provide a pathway in. A background on Ingress, OpenStack-Helm fully qualified
domain name (FQDN) overrides, installation, examples, and troubleshooting will be discussed here.


Ingress
=======

OpenStack-Helm utilizes the `Kubernetes Ingress Controller
<https://kubernetes.io/docs/concepts/services-networking/ingress/>`__

An Ingress is a collection of rules that allow inbound connections to reach the cluster services.

::

    internet
        |
   [ Ingress ]
   --|-----|--
   [ Services ]


It can be configured to give services externally-reachable URLs, load balance traffic,
terminate SSL, offer name based virtual hosting, and more.

Essentially the use of Ingress for OpenStack-Helm is an Nginx proxy service. Ingress (Nginx) is
accessible by your cluster public IP - e.g. the IP associated with
``kubectl get pods -o wide --all-namespaces | grep ingress-api``
Ingress/Nginx will be listening for server name requests of "keystone" or "keystone.openstack"
and will route those requests to the proper internal K8s Services.
These public listeners in Ingress must match the external DNS that you will set up to access
your OpenStack deployment. Note each rule also has a Service that directs Ingress Controllers
allow access to the endpoints from within the cluster.


External DNS and FQDN
=====================

Prepare ahead of time your FQDN and DNS layouts. There are a handful of OpenStack endpoints
you will want to expose for API and Dashboard access.

Update your lab/environment DNS server with your appropriate host values creating A Records
for the edge node IP's and various FQDN's. Alternatively you can test these settings locally by
editing your ``/etc/hosts``. Below is an example with a dummy domain ``os.foo.org`` and
dummy Ingress IP ``1.2.3.4``.

::

    A Records

    1.2.3.4     horizon.os.foo.org
    1.2.3.4     neutron.os.foo.org
    1.2.3.4     keystone.os.foo.org
    1.2.3.4     nova.os.foo.org
    1.2.3.4     metadata.os.foo.org
    1.2.3.4     glance.os.foo.org


The default FQDN's for OpenStack-Helm are

::

    horizon.openstack.svc.cluster.local
    neutron.openstack.svc.cluster.local
    keystone.openstack.svc.cluster.local
    nova.openstack.svc.cluster.local
    metadata.openstack.svc.cluster.local
    glance.openstack.svc.cluster.local

We want to change the **public** configurations to match our DNS layouts above. In each Chart
``values.yaml`` is a ``endpoints`` configuration that has ``host_fqdn_override``'s for each API
that the Chart either produces or is dependent on. `Read more about how Endpoints are developed
<https://docs.openstack.org/openstack-helm/latest/devref/endpoints.html>`__.
Note while Glance Registry is listening on a Ingress http endpoint, you will not need to expose
the registry for external services.


Installation
============

Implementing the FQDN overrides **must** be done at install time. If you run these as helm upgrades,
Ingress will notice the updates though none of the endpoint build-out jobs will run again,
unless they are cleaned up manually or using a tool like Armada.

Two similar options exist to set the FQDN overrides for External DNS mapping.

**First**, edit the ``values.yaml`` for Neutron, Glance, Horizon, Keystone, and Nova.

Using Horizon as an example, find the ``endpoints`` config.

For ``identity`` and ``dashboard`` at ``host_fdqn_override.public`` replace ``null`` with the
value as ``keystone.os.foo.org`` and ``horizon.os.foo.org``

.. code:: bash

    endpoints:
      cluster_domain_suffix: cluster.local
      identity:
        name: keystone
        hosts:
          default: keystone-api
          public: keystone
        host_fqdn_override:
          default: null
          public: keystone.os.foo.org
        .
        .
      dashboard:
        name: horizon
        hosts:
          default: horizon-int
          public: horizon
        host_fqdn_override:
          default: null
          public: horizon.os.foo.org


After making the configuration changes, run a ``make`` and then install as you would from
AIO or MultiNode instructions.

**Second** option would be as ``--set`` flags when calling ``helm install``

Add to the Install steps these flags - also adding a shell environment variable to save on
repeat code.

.. code-block:: shell

  export FQDN=os.foo.org

  helm install --name=horizon ./horizon --namespace=openstack \
    --set network.node_port.enabled=true \
    --set endpoints.dashboard.host_fqdn_override.public=horizon.$FQDN \
    --set endpoints.identity.host_fqdn_override.public=keystone.$FQDN



Note if you need to make a DNS change, you will have to do uninstall (``helm delete <chart>``)
and install again.

Once installed, access the API's or Dashboard at `http://horizon.os.foo.org`


Examples
========

Code examples below.

If doing an `AIO install
<https://docs.openstack.org/openstack-helm/latest/install/developer/index.html>`__,
all the ``--set`` flags

.. code-block:: shell

  export FQDN=os.foo.org

  helm install --name=keystone local/keystone --namespace=openstack \
    --set endpoints.identity.host_fqdn_override.public=keystone.$FQDN

  helm install --name=glance local/glance --namespace=openstack \
    --set storage=pvc \
    --set endpoints.image.host_fqdn_override.public=glance.$FQDN \
    --set endpoints.identity.host_fqdn_override.public=keystone.$FQDN

  helm install --name=nova local/nova --namespace=openstack \
    --values=./tools/overrides/mvp/nova.yaml \
    --set conf.nova.libvirt.virt_type=qemu \
    --set conf.nova.libvirt.cpu_mode=none \
    --set endpoints.compute.host_fqdn_override.public=nova.$FQDN \
    --set endpoints.compute_metadata.host_fqdn_override.public=metadata.$FQDN \
    --set endpoints.image.host_fqdn_override.public=glance.$FQDN \
    --set endpoints.network.host_fqdn_override.public=neutron.$FQDN \
    --set endpoints.identity.host_fqdn_override.public=keystone.$FQDN

  helm install --name=neutron local/neutron \
    --namespace=openstack --values=./tools/overrides/mvp/neutron-ovs.yaml \
    --set endpoints.network.host_fqdn_override.public=neutron.$FQDN \
    --set endpoints.compute.host_fqdn_override.public=nova.$FQDN \
    --set endpoints.identity.host_fqdn_override.public=keystone.$FQDN

  helm install --name=horizon local/horizon --namespace=openstack \
    --set=network.node_port.enabled=true \
    --set endpoints.dashboard.host_fqdn_override.public=horizon.$FQDN \
    --set endpoints.identity.host_fqdn_override.public=keystone.$FQDN



Troubleshooting
===============

**Review the Ingress configuration.**

Get the Nginx configuration from the Ingress Pod:

.. code-block:: shell

    kubectl exec -it ingress-api-2210976527-92cq0 -n openstack -- cat /etc/nginx/nginx.conf


Look for *server* configuration with a *server_name* matching your desired FQDN

::

    server {
        server_name nova.os.foo.org;
        listen [::]:80;
        set $proxy_upstream_name "-";
        location / {
            set $proxy_upstream_name "openstack-nova-api-n-api";
            .
            .
        }



**Check Chart Status**

Get the ``helm status`` of your chart.

.. code-block:: shell

    helm status keystone


Verify the *v1beta1/Ingress* resource has a Host with your FQDN value

::

    LAST DEPLOYED: Thu Sep 28 20:00:49 2017
    NAMESPACE: openstack
    STATUS: DEPLOYED

    RESOURCES:
    ==> v1beta1/Ingress
    NAME      HOSTS                            ADDRESS      PORTS  AGE
    keystone  keystone,keystone.os.foo.org     1.2.3.4      80     35m


