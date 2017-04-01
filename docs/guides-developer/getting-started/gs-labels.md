## Labels

This project uses `nodeSelectors` as well as `podAntiAffinity` rules to ensure resources land in the proper place within Kubernetes.  Today, OpenStack-Helm employs four labels:

- ceph-storage: enabled
- openstack-control-plane: enabled
- openstack-compute-node: enabled
- openvswitch: enabled

NOTE: The `openvswitch` label is an element that is applicable to both `openstack-control-plane` as well as `openstack-compute-node` nodes. Ideally, you would eliminate the `openvswitch` label if you could simply do an OR of (`openstack-control-plane` and `openstack-compute-node`).  However, Kubernetes `nodeSelectors` prohibits this specific logic. As a result of this, a third label that spans all hosts is required, which in this case is `openvswitch`.  The Open vSwitch service must run on both control plane and tenant nodes with both labels to provide connectivity for DHCP, L3, and Metadata services. These Open vSwitch services run as part of the control plane as well as tenant connectivity, which runs as part of the compute node infrastructure.


Labels are of course definable and overridable by the chart operators. Labels are defined in charts by using a `labels:` section, which is a common convention that defines both a selector and a value:

```
labels:
  node_selector_key: openstack-control-plane
  node_selector_value: enabled
```

In some cases, such as with the Neutron chart, a chart may need to define more then one label. In cases such as this, each element should be articulated under the `labels:` section, nesting where appropriate:

```
labels:
  # ovs is a special case, requiring a special
  # label that can apply to both control hosts
  # and compute hosts, until we get more sophisticated
  # with our daemonset scheduling
  ovs:
      node_selector_key: openvswitch
      node_selector_value: enabled
  agent:
    dhcp:
      node_selector_key: openstack-control-plane
      node_selector_value: enabled
    l3:
      node_selector_key: openstack-control-plane
      node_selector_value: enabled
    metadata:
      node_selector_key: openstack-control-plane
      node_selector_value: enabled
  server:
    node_selector_key: openstack-control-plane
    node_selector_value: enabled
```

These labels should be leveraged by `nodeSelector` definitions in charts for all resources, including jobs:

```
    ...
    spec:
      nodeSelector:
        {{ .Values.labels.node_selector_key }}: {{ .Values.labels.node_selector_value }}
    containers:
    ...
```

In some cases, especially with infrastructure components, it is necessary for the chart developer to provide scheduling instruction to Kubernetes to help ensure proper resiliency.  The most common examples employed today are podAntiAffinity rules, such as those used in the `mariadb` chart.  These should be placed on all foundational elements so that Kubernetes will not only disperse resources for resiliency, but also allow multi-replica installations to deploy successfully into a single host environment:

```
      annotations:
        # this soft requirement allows single
        # host deployments to spawn several mariadb containers
        # but in a larger environment, would attempt to spread
        # them out
        scheduler.alpha.kubernetes.io/affinity: >
          {
            "podAntiAffinity": {
              "preferredDuringSchedulingIgnoredDuringExecution": [{
                "labelSelector": {
                  "matchExpressions": [{
                    "key": "app",
                    "operator": "In",
                    "values":["mariadb"]
                  }]
                },
              "topologyKey": "kubernetes.io/hostname",
              "weight": 10
              }]
            }
          }
```
