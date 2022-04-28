===============
Deploy OVS-DPDK
===============

Requirements
============

A correct DPDK configuration depends heavily on the specific hardware resources
and its configuration. Before deploying Openvswitch with DPDK, check the amount
and type of available hugepages on the host OS.

.. code-block:: shell

  cat /proc/meminfo | grep Huge
  AnonHugePages:         0 kB
  ShmemHugePages:        0 kB
  HugePages_Total:       8
  HugePages_Free:        6
  HugePages_Rsvd:        0
  HugePages_Surp:        0
  Hugepagesize:    1048576 kB

In this example, 8 hugepages of 1G size have been allocated. 2 of those are
being used and 6 are still available.

More information on how to allocate and configure hugepages on the host OS can
be found in the `Openvswitch documentation
<http://docs.openvswitch.org/en/latest/intro/install/dpdk/>`_.

In order to allow OVS inside a pod to make use of hugepages, the corresponding
type and amount of hugepages must be specified in the resource section of the
OVS chart's values.yaml:

.. code-block:: yaml

  resources:
    enabled: true
    ovs:
      db:
        requests:
          memory: "128Mi"
          cpu: "100m"
        limits:
          memory: "1024Mi"
          cpu: "2000m"
      vswitchd:
        requests:
          memory: "128Mi"
          cpu: "100m"
        limits:
          memory: "1024Mi"
          cpu: "2000m"
          # set resources to enabled and specify one of the following when using dpdk
          hugepages-1Gi: "1Gi"
          # hugepages-2Mi: "512Mi"

Additionally, the default configuration of the neutron chart must be adapted according
to the underlying hardware. The corresponding configuration parameter is labeled with
"CHANGE-ME" in the script "values_overrides/dpdk.yaml". Specifically, the "ovs_dpdk"
configuration section should list all NICs which should be bound to DPDK with
their corresponding PCI-IDs. Moreover, the name of each NIC needs to be unique,
e.g., dpdk0, dpdk1, etc.

.. code-block:: yaml

  network:
    interface:
      tunnel: br-phy
  conf:
    ovs_dpdk:
      enabled: true
      driver: uio_pci_generic
      nics:
        - name: dpdk0
          # CHANGE-ME: modify pci_id according to hardware
          pci_id: '0000:05:00.0'
          bridge: br-phy
          migrate_ip: true
      bridges:
        - name: br-phy
      bonds: []

In the example above, bonding isn't used and hence an empty list is passed in the "bonds"
section.

Deployment
==========

Once the above requirements are met, start deploying Openstack Helm using the deployment
scripts under the dpdk directory in an increasing order

.. code-block:: shell

  ./tools/deployment/developer/dpdk/<script-name>

One can also specify the name of Openstack release and container OS distribution as
overrides before running the deployment scripts, for instance,

.. code-block:: shell

  export OPENSTACK_RELEASE=wallaby
  export CONTAINER_DISTRO_NAME=ubuntu
  export CONTAINER_DISTRO_VERSION=focal

Troubleshooting
===============

OVS startup failure
-------------------

If OVS fails to start up because of no hugepages are available, check the
configuration of the OVS daemonset. Older versions of helm-toolkit were not
able to render hugepage configuration into the Kubernetes manifest and just
removed the hugepage attributes. If no hugepage configuration is defined for
the OVS daemonset, consider using a newer version of helm-toolkit.

.. code-block:: shell

  kubectl get daemonset openvswitch-vswitchd -n openstack -o yaml
  [...]
  resources:
    limits:
      cpu: "2"
      hugepages-1Gi: 1Gi
      memory: 1Gi
    requests:
      cpu: 100m
      memory: 128Mi
  [...]

Adding a DPDK port to Openvswitch fails
---------------------------------------

When adding a DPDK port (a NIC bound to DPDK) to OVS fails, one source of error
is related to an incorrect configuration with regards to the NUMA topology of
the underlying hardware. Every NIC is connected to one specific NUMA socket. In
order to use a NIC as DPDK port in OVS, the OVS configurations regarding
hugepage(s) and PMD thread(s) need to match the NUMA topology.

The NUMA socket a given NIC is connected to can be found in the ovs-vswitchd log:

.. code-block::

  kubectl logs -n openstack openvswitch-vswitchd-6h928
  [...]
  2019-07-02T13:42:06Z|00016|dpdk|INFO|EAL: PCI device 0000:00:04.0 on NUMA socket 1
  2019-07-02T13:42:06Z|00018|dpdk|INFO|EAL:   probe driver: 1af4:1000 net_virtio
  [...]

In this example, the NIC with PCI-ID 0000:00:04.0 is connected to NUMA socket
1. As a result, this NIC can only be used by OVS if

1. hugepages have been allocated on NUMA socket 1 by OVS, and
2. PMD threads have been assigned to NUMA socket 1.

To allocate hugepages to NUMA sockets in OVS, ensure that the
``socket_memory`` attribute in values.yaml specifies a value for the
corresponding NUMA socket. In the following example, OVS will use one 1G
hugepage for NUMA socket 0 and socket 1.

.. code-block::

  socket_memory: 1024,1024


To allocate PMD threads to NUMA sockets in OVS, ensure that the ``pmd_cpu_mask``
attribute in values.yaml includes CPU sockets on the corresponding NUMA socket.
In the example below, the mask of 0xf covers the first 4 CPU cores which are
distributed across NUMA sockets 0 and 1.

.. code-block::

  pmd_cpu_mask: 0xf

The mapping of CPU cores to NUMA sockets can be determined by means of ``lspci``, for instance:

.. code-block:: shell

  lspci | grep NUMA
  NUMA node(s):          2
  NUMA node0 CPU(s):     0,2,4,6,8,10,12,14
  NUMA node1 CPU(s):     1,3,5,7,9,11,13,15

More information can be found in the `Openvswitch documentation
<http://docs.openvswitch.org/en/latest/intro/install/dpdk/>`_.
