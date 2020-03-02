..
 This work is licensed under a Creative Commons Attribution 3.0 Unported
 License.

 http://creativecommons.org/licenses/by/3.0/legalcode

..

=====================
Neutron multiple SDNs
=====================

Blueprint:
neutron-multiple-sdns_

.. _neutron-multiple-sdns: https://blueprints.launchpad.net/openstack-helm/+spec/neutron-multiple-sdns

Problem Description
===================

Currently OpenStack-Helm supports OpenVSwitch as a network virtualization engine.
In order to support many possible backends (SDNs), changes are required in
neutron chart and in deployment techniques. OpenStack-Helm can support every SDN
solution that has Neutron plugin, either core_plugin or mechanism_driver.

The Neutron reference architecture provides mechanism_drivers OpenVSwitch (OVS)
and linuxbridge (LB) with ML2 core_plugin framework.

Other networking services provided by Neutron are:

#. L3 routing - creation of routers
#. DHCP - auto-assign IP address and DNS info
#. Metadata- Provide proxy for Nova metadata service

Introducing a new SDN solution should consider how the above services are
provided. It may be required to disable the built-in Neutron functionality.

Proposed Change
===============

To be able to install Neutron with multiple possible SDNs as networking plugin,
Neutron chart should be modified to enable installation of base services
with decomposable approach. This means that operator can define which components
from base Neutron chart should be installed, and which should not. This plus
proper configuration of Neutron chart would enable operator to flexibly provision
OpenStack with chosen SDN.

Every Kubernetes manifest inside Neutron chart can be enabled or disabled.
That would provide flexibility to the operator, to choose which Neutron
components are reusable with different type of SDNs. For example, neutron-server
which is serving the API and configuring the database can be used with different
types of SDN plugin, and provider of that SDN chart would not need to copy
all logic from Neutron base chart to manage the API and database.

The proposes change would be to add in :code:`neutron/values.yaml` new section
with boolean values describing which Neutron's Kubernetes resources should be
enabled:

.. code-block:: yaml

    manifests:
      configmap_bin: true
      configmap_etc: true
      daemonset_dhcp_agent: true
      daemonset_l3_agent: true
      daemonset_metadata_agent: true
      daemonset_ovs_agent: true
      daemonset_ovs_db: true
      daemonset_ovs_vswitchd: true
      deployment_server: true
      ingress_server: true
      job_db_init: true
      job_db_sync: true
      job_ks_endpoints: true
      job_ks_service: true
      job_ks_user: true
      pdb_server: true
      secret_db: true
      secret_keystone: true
      service_ingress_server: true
      service_server: true

Then, inside Kubernetes manifests, add global if statement, deciding if given
manifest should be declared on Kubernetes API, for example
:code:`neutron/templates/daemonset-ovs-agent.yaml`:

.. code-block:: yaml

    {{- if .Values.manifests.daemonset_ovs_agent }}
    # Licensed under the Apache License, Version 2.0 (the "License");

    ...

            - name: libmodules
          hostPath:
            path: /lib/modules
        - name: run
          hostPath:
            path: /run
    {{- end }}

If :code:`.Values.manifests.daemonset_ovs_agent` will be set to false, neutron
ovs agent would not be launched. In that matter, other type of L2 or L3 agent
on compute node can be run.

To enable new SDN solution, there should be separate chart created, which would
handle the deployment of service, setting up the database and any related
networking functionality that SDN is providing.

Use case
--------

Let's consider how new SDN can take advantage of disaggregated Neutron services
architecture. First assumption is that neutron-server functionality would be
common for all SDNs, as it provides networking API, database management and
Keystone interaction. Required modifications are:

#. Configuration in :code:`neutron.conf` and :code:`ml2_conf.ini`
#. Providing the neutron plugin code.

The code can be supplied as modified neutron server image, or plugin can be
mounted to original image. The :code:`manifests` section in :code:`neutron/values.yaml`
should be enabled for below components:

.. code-block:: yaml

    manifests:
      # neutron-server components:
      configmap_bin: true
      configmap_etc: true
      deployment_server: true
      ingress_server: true
      job_db_init: true
      job_db_sync: true
      job_ks_endpoints: true
      job_ks_service: true
      job_ks_user: true
      pdb_server: true
      secret_db: true
      secret_keystone: true
      service_ingress_server: true
      service_server: true

Next, Neutron services like L3 routing, DHCP and metadata serving should be
considered. If SDN provides its own implementation, the Neutron's default one
should be disabled:

.. code-block:: yaml

    manifests:
      daemonset_dhcp_agent: false
      daemonset_l3_agent: false
      daemonset_metadata_agent: false

Provision of those services should be included inside SDN chart.

The last thing to be considered is VM network virtualization. What engine does
SDN use? It is OpenVSwitch, Linux Bridges or l3 routing (no l2 connectivity).
If SDN is using the OpenVSwitch, it can take advantage of existing OVS
daemonsets. Any modification that would be required to OVS manifests can be
included in base Neutron chart as a configurable option. In that way, the features
of OVS can be shared between different SDNs. When using the OVS, default Neutron
L2 agent should be disabled, but OVS-DB and OVS-vswitchd can be left enabled.

.. code-block:: yaml

    manifests:
      # Neutron L2 agent:
      daemonset_ovs_agent: false
      # OVS tool:
      daemonset_ovs_db: true
      daemonset_ovs_vswitchd: true

Security Impact
---------------
No security impact.

Performance Impact
------------------
VM networking performance would be dependent of SDN used.


Alternatives
------------
Alternatives to decomposable Neutron chart would be to copy whole Neutron chart
and create spin-offs with new SDN enabled. This approach has drawbacks of
maintaining the whole neutron chart in many places, and copies of standard
services may be out of sync with OSH improvements. This implies constant
maintenance effort to up to date.

Implementation
==============

Assignee(s)
-----------

Primary assignees:

* korzen (Artur Korzeniewski)
* portdirect (Pete Birley)


Work Items
----------

#. Implement decomposable Neutron chart
#. Add Linux Bridge as first alternative for OVS - separate spec needed.
#. Add one SDN to see if proposed change is working OK - separate spec needed.


Testing
=======
First reasonable testing in gates would be to setup Linux Bridge and check
if VM network connectivity is working.

Documentation Impact
====================
Documentation of how new SDN can be enabled, how Neutron should be configured.
Also, for each new SDN that would be incorporated, the architecture overview
should be provided.

References
==========
