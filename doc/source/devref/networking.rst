==========
Networking
==========
Currently OpenStack-Helm supports OpenVSwitch and LinuxBridge as a network
virtualization engines. In order to support many possible backends (SDNs),
modular architecture of Neutron chart was developed. OpenStack-Helm can support
every SDN solution that has Neutron plugin, either core_plugin or mechanism_driver.

The Neutron reference architecture provides mechanism_drivers :code:`OpenVSwitch`
(OVS) and :code:`linuxbridge` (LB) with ML2 :code:`core_plugin` framework.

Other networking services provided by Neutron are:

#. L3 routing - creation of routers
#. DHCP - auto-assign IP address and DNS info
#. Metadata - Provide proxy for Nova metadata service

Introducing a new SDN solution should consider how the above services are
provided. It maybe required to disable built-in Neutron functionality.

Neutron architecture
--------------------

Neutron chart includes the following services:

neutron-server
~~~~~~~~~~~~~~
neutron-server is serving the networking REST API for operator and other
OpenStack services usage. The internals of Neutron are highly flexible,
providing plugin mechanisms for all networking services exposed. The
consistent API is exposed to the user, but the internal implementation
is up to the chosen SDN.

Typical networking API request is an operation of create/update/delete:
 * network
 * subnet
 * port

To use other Neutron reference architecture types of SDN, these options
should be configured in :code:`neutron.conf`:

.. code-block:: ini

    [DEFAULT]
    ...
    # core_plugin - plugin responsible for L2 connectivity and IP address
    #               assignments.
    # ML2 (Modular Layer 2) is the core plugin provided by Neutron ref arch
    # If other SDN implements its own logic for L2, it should replace the
    # ml2 here
    core_plugin = ml2

    # service_plugins - a list of extra services exposed by Neutron API.
    # Example: router, qos, trunk, metering.
    # If other SDN implement L3 or other services, it should be configured
    # here
    service_plugins = router

All of the above configs are endpoints or path to the specific class
implementing the interface. You can see the endpoints to class mapping in
`setup.cfg <https://github.com/openstack/neutron/blob/412c49b3930ce8aecb0a07aec50a9607058e5bc7/setup.cfg#L69>`_.

If the SDN of your choice is using the ML2 core plugin, then the extra
options in `neutron/ml2/plugins/ml2_conf.ini` should be configured:

.. code-block:: ini

    [ml2]
    # type_drivers - layer 2 technologies that ML2 plugin supports.
    # Those are local,flat,vlan,gre,vxlan,geneve
    type_drivers = flat,vlan,vxlan

    # mech_drivers - implementation of above L2 technologies. This option is
    # pointing to the engines like linux bridge or OpenVSwitch in ref arch.
    # This is the place where SDN implementing ML2 driver should be configured
    mech_drivers = openvswitch, l2population

SDNs implementing ML2 driver can add extra/plugin-specific configuration
options in `neutron/ml2/plugins/ml2_conf.ini`. Or define its own `ml2_conf_<name>.ini`
file where configs specific to the SDN would be placed.

The above configuration options are handled by `neutron/values.yaml`:

.. code-block:: yaml

    conf:
      neutron:
        DEFAULT:
            ...
          # core_plugin can be: ml2, calico
          core_plugin: ml2
          # service_plugin can be: router, odl-router, empty for calico,
          # networking_ovn.l3.l3_ovn.OVNL3RouterPlugin for OVN
          service_plugins: router

      plugins:
        ml2_conf:
          ml2:
            # mechnism_drivers can be: openvswitch, linuxbridge,
            # opendaylight, ovn
            mechanism_drivers: openvswitch,l2population
            type_drivers: flat,vlan,vxlan


Neutron-server service is scheduled on nodes with
`openstack-control-plane=enabled` label.

neutron-dhcp-agent
~~~~~~~~~~~~~~~~~~
DHCP agent is running dnsmasq process which is serving the IP assignment and
DNS info. DHCP agent is dependent on the L2 agent wiring the interface.
So one should be aware that when changing the L2 agent, it also needs to be
changed in the DHCP agent. The configuration of the DHCP agent includes
option `interface_driver`, which will instruct how the tap interface created
for serving the request should be wired.

.. code-block:: yaml

    conf:
      dhcp_agent:
        DEFAULT:
          # we can define here, which driver we are using:
          # openvswitch or linuxbridge
          interface_driver: openvswitch

Another place where the DHCP agent is dependent on L2 agent is the dependency
for the L2 agent daemonset:

.. code-block:: yaml

    dependencies:
      dynamic:
        targeted:
          openvswitch:
            dhcp:
              pod:
                # this should be set to corresponding neutron L2 agent
                - requireSameNode: true
                  labels:
                    application: neutron
                    component: neutron-ovs-agent

There is also a need for DHCP agent to pass ovs agent config file
(in :code:`neutron/templates/bin/_neutron-dhcp-agent.sh.tpl`):

.. code-block:: bash

    exec neutron-dhcp-agent \
          --config-file /etc/neutron/neutron.conf \
          --config-file /etc/neutron/dhcp_agent.ini \
          --config-file /etc/neutron/metadata_agent.ini \
          --config-file /etc/neutron/plugins/ml2/ml2_conf.ini
    {{- if ( has "openvswitch" .Values.network.backend ) }} \
          --config-file /etc/neutron/plugins/ml2/openvswitch_agent.ini
    {{- end }}

This requirement is OVS specific, the `ovsdb_connection` string is defined
in `openvswitch_agent.ini` file, specifying how DHCP agent can connect to ovs.
When using other SDNs, running the DHCP agent may not be required. When the
SDN solution is addressing the IP assignments in another way, neutron's
DHCP agent should be disabled.

neutron-dhcp-agent service is scheduled to run on nodes with the label
`openstack-control-plane=enabled`.

neutron-l3-agent
~~~~~~~~~~~~~~~~
L3 agent is serving the routing capabilities for Neutron networks. It is also
dependent on the L2 agent wiring the tap interface for the routers.

All dependencies described in neutron-dhcp-agent are valid here.

If the SDN implements its own version of L3 networking, neutron-l3-agent
should not be started.

neutron-l3-agent service is scheduled to run on nodes with the label
`openstack-control-plane=enabled`.

neutron-metadata-agent
~~~~~~~~~~~~~~~~~~~~~~
Metadata-agent is a proxy to nova-metadata service. This one provides
information about public IP, hostname, ssh keys, and any tenant specific
information. The same dependencies apply for metadata as it is for DHCP
and L3 agents. Other SDNs may require to force the config driver in nova,
since the metadata service is not exposed by it.

neutron-metadata-agent service is scheduled to run on nodes with the label
`openstack-control-plane=enabled`.


Configuring network plugin
--------------------------
To be able to configure multiple networking plugins inside of OpenStack-Helm,
a new configuration option is added:

.. code-block:: yaml

    network:
      # provide what type of network wiring will be used
      # possible options: openvswitch, linuxbridge, sriov
      backend:
        - openvswitch

This option will allow to configure the Neutron services in proper way, by
checking what is the actual backed set in :code:`neutron/values.yaml`.

In order to meet modularity criteria of Neutron chart, section `manifests` in
:code:`neutron/values.yaml` contains boolean values describing which Neutron's
Kubernetes resources should be deployed:

.. code-block:: yaml

    manifests:
      configmap_bin: true
      configmap_etc: true
      daemonset_dhcp_agent: true
      daemonset_l3_agent: true
      daemonset_lb_agent: false
      daemonset_metadata_agent: true
      daemonset_ovs_agent: true
      daemonset_sriov_agent: true
      deployment_server: true
      ingress_server: true
      job_bootstrap: true
      job_db_init: true
      job_db_sync: true
      job_db_drop: false
      job_image_repo_sync: true
      job_ks_endpoints: true
      job_ks_service: true
      job_ks_user: true
      job_rabbit_init: true
      pdb_server: true
      pod_rally_test: true
      secret_db: true
      secret_keystone: true
      secret_rabbitmq: true
      service_ingress_server: true
      service_server: true

If :code:`.Values.manifests.daemonset_ovs_agent` will be set to false, neutron
ovs agent would not be launched. In that matter, other type of L2 or L3 agent
on compute node can be run.

To enable new SDN solution, there should be separate chart created, which would
handle the deployment of service, setting up the database and any related
networking functionality that SDN is providing.

OpenVSwitch
~~~~~~~~~~~
The ovs set of daemonsets are running on the node labeled
`openvswitch=enabled`. This includes the compute and controller/network nodes.
For more flexibility, OpenVSwitch as a tool was split out of Neutron chart, and
put in separate chart dedicated OpenVSwitch. Neutron OVS agent remains in
Neutron chart. Splitting out the OpenVSwitch creates possibilities to use it
with different SDNs, adjusting the configuration accordingly.

neutron-ovs-agent
+++++++++++++++++
As part of Neutron chart, this daemonset is running Neutron OVS agent.
It is dependent on having :code:`openvswitch-db` and :code:`openvswitch-vswitchd`
deployed and ready. Since its the default choice of the networking backend,
all configuration is in place in `neutron/values.yaml`. :code:`neutron-ovs-agent`
should not be deployed when another SDN is used in `network.backend`.

Script in :code:`neutron/templates/bin/_neutron-openvswitch-agent-init.sh.tpl`
is responsible for determining the tunnel interface and its IP for later usage
by :code:`neutron-ovs-agent`. The IP is set in init container and shared between
init container and main container with :code:`neutron-ovs-agent` via file
:code:`/tmp/pod-shared/ml2-local-ip.ini`.

Configuration of OVS bridges can be done via
`neutron/templates/bin/_neutron-openvswitch-agent-init.sh.tpl`. The
script is configuring the external network bridge and sets up any
bridge mappings defined in :code:`conf.auto_bridge_add`.  These
values should align with
:code:`conf.plugins.openvswitch_agent.ovs.bridge_mappings`.

openvswitch-db and openvswitch-vswitchd
+++++++++++++++++++++++++++++++++++++++
This runs the OVS tool and database. OpenVSwitch chart is not Neutron specific,
it may be used with other technologies that are leveraging the OVS technology,
such as OVN or ODL.

A detail worth mentioning is that ovs is configured to use sockets, rather
than the default loopback mechanism.

.. code-block:: bash

    exec /usr/sbin/ovs-vswitchd unix:${OVS_SOCKET} \
            -vconsole:emer \
            -vconsole:err \
            -vconsole:info \
            --pidfile=${OVS_PID} \
            --mlockall

Linuxbridge
~~~~~~~~~~~
Linuxbridge is the second type of Neutron reference architecture L2 agent.
It is running on nodes labeled `linuxbridge=enabled`. As mentioned before,
all nodes that are requiring the L2 services need to be labeled with linuxbridge.
This includes both the compute and controller/network nodes. It is not possible
to label the same node with both openvswitch and linuxbridge (or any other
network virtualization technology) at the same time.

neutron-lb-agent
++++++++++++++++
This daemonset includes the linuxbridge Neutron agent with bridge-utils and
ebtables utilities installed. This is all that is needed, since linuxbridge
uses native kernel libraries.

:code:`neutron/templates/bin/_neutron-linuxbridge-agent-init.sh.tpl` is
configuring the tunnel IP, external bridge and all bridge mappings defined
in config. It is done in init container, and the IP for tunneling is shared
using file :code:`/tmp/pod-shared/ml2-local-ip.ini` with main linuxbridge
container.

In order to use linuxbridge in your OpenStack-Helm deployment, you need to
label the compute and controller/network nodes with `linuxbridge=enabled`
and use this `neutron/values.yaml` override:

.. code-block:: yaml

    network:
      backend: linuxbridge
    dependencies:
      dynamic:
        targeted:
          linuxbridge:
            dhcp:
              pod:
                - requireSameNode: true
                  labels:
                    application: neutron
                    component: neutron-lb-agent
            l3:
              pod:
                - requireSameNode: true
                  labels:
                    application: neutron
                    component: neutron-lb-agent
            metadata:
              pod:
                - requireSameNode: true
                  labels:
                    application: neutron
                    component: neutron-lb-agent
            lb_agent:
              pod: null
    conf:
      neutron:
        DEFAULT
          interface_driver: linuxbridge
      dhcp_agent:
        DEFAULT:
          interface_driver: linuxbridge
      l3_agent:
        DEFAULT:
          interface_driver: linuxbridge


Other SDNs
~~~~~~~~~~
In order to add support for more SDNs, these steps need to be performed:

#. Configure neutron-server with SDN specific core_plugin/mechanism_drivers.
#. If required, add new networking agent label type.
#. Specify if new SDN would like to use existing services from Neutron:
   L3, DHCP, metadata.
#. Create separate chart with new SDN deployment method.


Nova config dependency
~~~~~~~~~~~~~~~~~~~~~~
Whenever we change the L2 agent, it should be reflected in ``nova/values.yaml``
in dependency resolution for nova-compute.
