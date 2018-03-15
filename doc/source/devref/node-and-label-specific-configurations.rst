Node and label specific configurations
--------------------------------------

There are situations where we need to define configuration differently for
different nodes in the environment. For example, we may require that some nodes
have a different vcpu_pin_set or other hardware specific deltas in nova.conf.

To do this, we can specify overrides in the values fed to the chart. Ex:

.. code-block:: yaml

    conf:
      nova:
        DEFAULT:
          vcpu_pin_set: "0-31"
          cpu_allocation_ratio: 3.0
      overrides:
        nova_compute:
          labels:
          - label:
              key: compute-type
              values:
              - "dpdk"
              - "sriov"
            conf:
              nova:
                DEFAULT:
                  vcpu_pin_set: "0-15"
          - label:
              key: another-label
              values:
              - "another-value"
            conf:
              nova:
                DEFAULT:
                  vcpu_pin_set: "16-31"
          hosts:
          - name: host1.fqdn
            conf:
              nova:
                DEFAULT:
                  vcpu_pin_set: "8-15"
          - name: host2.fqdn
            conf:
              nova:
                DEFAULT:
                  vcpu_pin_set: "16-23"

Note that only one set of overrides is applied per node, such that:

1. Host overrides supercede label overrides
2. The farther down the list the label appears, the greater precedence it has.
   e.g., "another-label" overrides will apply to a node containing both labels.

Also note that other non-overridden values are inherited by hosts and labels with overrides.
The following shows a set of example hosts and the values fed into the configmap for each:

1. ``host1.fqdn`` with labels ``compute-type: dpdk, sriov`` and ``another-label: another-value``:

   .. code-block:: yaml

    conf:
      nova:
        DEFAULT:
          vcpu_pin_set: "8-15"
          cpu_allocation_ratio: 3.0

2. ``host2.fqdn`` with labels ``compute-type: dpdk, sriov`` and ``another-label: another-value``:

   .. code-block:: yaml

    conf:
      nova:
        DEFAULT:
          vcpu_pin_set: "16-23"
          cpu_allocation_ratio: 3.0

3. ``host3.fqdn`` with labels ``compute-type: dpdk, sriov`` and ``another-label: another-value``:

   .. code-block:: yaml

    conf:
      nova:
        DEFAULT:
          vcpu_pin_set: "16-31"
          cpu_allocation_ratio: 3.0

4. ``host4.fqdn`` with labels ``compute-type: dpdk, sriov``:

   .. code-block:: yaml

    conf:
      nova:
        DEFAULT:
          vcpu_pin_set: "0-15"
          cpu_allocation_ratio: 3.0

5. ``host5.fqdn`` with no labels:

   .. code-block:: yaml

    conf:
      nova:
        DEFAULT:
          vcpu_pin_set: "0-31"
          cpu_allocation_ratio: 3.0
