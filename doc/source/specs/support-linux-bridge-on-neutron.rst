..
 This work is licensed under a Creative Commons Attribution 3.0 Unported
 License.

 http://creativecommons.org/licenses/by/3.0/legalcode

..

==========================================
Support linux bridge on neutron helm chart
==========================================

Blueprint:
support-linux-bridge-on-neutron_

.. _support-linux-bridge-on-neutron: https://blueprints.launchpad.net/openstack-helm/+spec/support-linux-bridge-on-neutron

Problem Description
===================

This specification will address enablement of LinuxBridge network virtualization
for OpenStack Helm (OSH). LinuxBridge is second available networking technology
in Neutron's reference architecture. The first one is OVS, that is already
implemented in OSH.

The LinuxBridge (LB) is Neutron's L2 agent, using linux kernel bridges as network
configuration for VMs. Both OVS and LB are part of Neutron's Modular Layer 2 (ML2)
framework, allowing to simultaneously utilize the variety of layer 2 networking
technologies.

Other services inside Neutron reference stack (L3/DHCP/metadata agents) are
dependent on L2 connectivity agent. Thus, replacing OVS with LB would cause
changes in mentioned services configuration.

Proposed Change
===============

LinuxBridge installation with neutron chart takes advantaged of decomposable
neutron chart in OSH. LinuxBridge agent will be added as daemonset, similarly
how OVS is implemented. New value :code:`daemonset_lb_agent` should be added in
:code:`neutron/values.yaml` in :code:`manifests` section:

.. code-block:: yaml

    manifests:
      (...)
      daemonset_dhcp_agent: true
      daemonset_l3_agent: true
      daemonset_lb_agent: false
      daemonset_metadata_agent: true
      daemonset_ovs_agent: true
      daemonset_ovs_db: true
      daemonset_ovs_vswitchd: true
      (...)

By default, :code:`daemonset_lb_agent` will be set to false to remain default
behaviour of installing OVS as networking agent.

Installing OVS requires Kubernetes worker node labeling with tag
:code:`openvswitch=enabled`. To mark nodes where LB should be used, new tag
will be introduced: :code:`linuxbridge=enabled`.

LinuxBridge should support external bridge configuration, as well as auto
bridge add mechanism implemented for OVS.

As mentioned before, configuration of L3/DHCP/metadata agent should be adjusted
to use LinuxBridge, sample configuration override:

.. code-block:: yaml

    conf:
      neutron:
        default:
          agent:
            interface_driver: linuxbridge
      ml2_conf:
        ml2_type_flat:
          neutron:
            ml2:
              mechanism_drivers: linuxbridge, l2population
      dhcp_agent:
        default:
          neutron:
            base:
              agent:
                interface_driver: linuxbridge
      l3_agent:
        default:
          neutron:
            base:
              agent:
                interface_driver: linuxbridge

Having services configured, also the services pod dependencies should be
updated to reflect the new kind on L2 agent:

.. code-block:: yaml

    dependencies:
      dhcp:
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
      l3:
        pod:
          - requireSameNode: true
            labels:
              application: neutron
              component: neutron-lb-agent

LinuxBridge should be also enabled in :code:`manifests` section:

.. code-block:: yaml

    manifests:
      daemonset_lb_agent: true
      daemonset_ovs_agent: false
      daemonset_ovs_db: false
      daemonset_ovs_vswitchd: false

In above example OVS and Neutron OVS agent are disabled.

Another place where Neutron L2 agent should be pointed is dependencies list
in other OpenStack projects. Currently, :code:`nova-compute` has dependency for
:code:`ovs-agent` in :code:`nova/values.yaml`, it should be changed to:

.. code-block:: yaml

    dependencies:
      compute:
        daemonset:
        - lb-agent

Security Impact
---------------
No security impact.

Performance Impact
------------------
VM networking performance would be dependent on linux bridge implementation.

Alternatives
------------
OVS is an alternative in Neutron reference architecture. It is already in tree.

Implementation
==============

Assignee(s)
-----------

Primary assignees:

* korzen (Artur Korzeniewski)


Work Items
----------

#. Add LinuxBridge daemonset
#. Add gate job testing VM network connectivity
#. Add documentation on how to use LinuxBridge

Testing
=======
Gate job testing VM network connectivity.

Documentation Impact
====================
Documentation on how to use LinuxBridge with Neutron chart.

References
==========
