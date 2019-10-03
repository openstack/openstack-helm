Node and node label specific daemonset configurations
=====================================================

A typical Helm daemonset may leverage a secret to store configuration data.
However, there are cases where the same secret document can't be used for
the entire daemonset, because there are node-specific differences.

To address this use-case, the ``helm-toolkit.utils.daemonset_overrides``
template was added in helm-toolkit. This was created with the intention that it
should be straightforward to convert (wrap) a pre-existing daemonset with the
functionality to override secret parameters on a per-node or per-nodelabel
basis.

Adapting your daemonset to support node/nodelabel overrides
-----------------------------------------------------------

Consider the following (simplified) secret and daemonset pairing example:

.. code-block:: yaml

    # Simplified secret definition
    # ===============================
    ---
    apiVersion: v1
    kind: Secret
    # Note ref to $secretName for dynamically generated secrets
    metadata:
      name: mychart-etc
    data:
      myConf: {{ include "helm-toolkit.utils.template" | b64enc }}

    # Simplified daemonset definition
    # ===============================
    ---
    apiVersion: apps/v1
    kind: DaemonSet
    metadata:
      name: mychart-name
    spec:
      template:
        spec:
          containers:
          - name: my-container
          volumes:
          - name: mychart-etc
            secret:
              name: mychart-etc
              defaultMode: 0444

Assume the chart name is ``mychart``.

Now we can wrap the existing YAML to make it support node and nodelabel
overrides, with minimal changes to the existing YAML (note where $secretName
has been substituted):

.. code-block:: yaml

    # Simplified secret definition needed for node/nodelabel overrides
    # -------------------------------------------------------------------
    # Wrap secret definition
    {{- define "mychart.secret.etc" }}
    {{- $secretName := index . 0 }}
    {{- $envAll := index . 1 }}
    # Set to the same env context as was available to the caller, so we can
    # access any env data needed to build the template (e.g., envAll.Values...)
    {{- with $envAll }}
    ---
    apiVersion: v1
    kind: Secret
    # Note ref to $secretName for dynamically generated secrets
    metadata:
      name: {{ $secretName }}
    data:
      myConf: {{ include "helm-toolkit.utils.template" | b64enc }}
    {{- end }}
    {{- end }}

    # Simplified daemonset definition needed for node/nodelabel overrides
    # -------------------------------------------------------------------
    # Wrap daemonset definition
    {{- define "mychart.daemonset" }}
    {{- $daemonset := index . 0 }}
    {{- $secretName := index . 1 }}
    {{- $envAll := index . 2 }}
    # Set to the same env context as was available to the caller, so we can
    # access any env data needed to build the template (e.g., envAll.Values...)
    {{- with $envAll }}
    ---
    apiVersion: apps/v1
    kind: DaemonSet
    metadata:
      name: {{ $daemonset }}
    spec:
      template:
        spec:
          containers:
          - name: {{ $daemonset }}
          volumes:
            # Note refs to $secretName for dynamically generated secrets
          - name: {{ $secretName }}
            secret:
              name: {{ $secretName }}
              defaultMode: 0444
    {{- end }}
    {{- end }}
    # Desired daemonset name/prefix that helm will register with kubernetes
    # Note that this needs to be a valid dns-1123 name for a k8s resource
    {{- $daemonset := "mydaemonset" }}
    # Desired secret name/prefix that helm will register with kubernetes
    # Note that this needs to be a valid dns-1123 name for a k8s resource
    {{- $secretName := "mychart-etc" }}
    # Generate the daemonset YAML with a matching/consistent secretName (so
    # daemonset_overrides knows which volumes to dynamically substitute with the
    # auto-generated secrets). You may include in this list any other vars
    # which you need to reference or substitute into the daemonset YAML above.
    {{- $daemonset_yaml := list $secretName . | include "mychart.daemonset" | toString | fromYaml }}
    # Namespace to the secret definition which will be used/manipulated
    {{- $secret_include := "mychart.secret.etc" }}
    # Pass all these elements to daemonset_overrides to generate secret/daemonset
    # pairings for each set of overrides (plus one with no overrides)
    {{- list $daemonset $daemonset_yaml $secret_include $secretName . | include "helm-toolkit.utils.daemonset_overrides" }}

Your daemonset should now support node and nodelabl level overrides. (Note that
you will also need your chart to have helm-toolkit listed as a dependency.)

Implementation details of node/nodelabel overrides
--------------------------------------------------

Instead of having one daemonset with one monolithic secret, this helm-toolkit
feature permits a common daemonset and secret template, from which daemonset
and secret pairings are auto-generated. It supports establishing value
overrides for nodes with specific label value pairs and for targeting nodes with
specific hostnames and hostlabels. The overridden configuration is merged with
the normal config data, with the override data taking precedence.

The chart will then generate one daemonset for each host and label override, in
addition to a default daemonset for which no overrides are applied. Each
daemonset generated will also exclude from its scheduling criteria all other
hosts and labels defined in other overrides for the same daemonset, to ensure
that there is no overlap of daemonsets (i.e., one and only one daemonset of a
given type for each node).

For example, if you have some special conf setting that should be applied
to ``host1.fqdn``, and another special conf setting that should be applied
to nodes labeled with ``someNodeLabel``, then three secret/daemonset pairs
will be generated and registered with kubernetes: one for ``host1.fqdn``, one
for ``someNodeLabel``, and one for ``default``.

The order of precedence for matches is FQDN, node label, and then default. If a
node matches both a FQDN and a nodelabel, then only the FQDN override is applied.
Pay special attention to adding FQDN overrides for nodes that match a nodelabel
override, as you would need to duplicate the nodelabel overrides for that node
in the FQDN overrides for them to still apply.

If there is no matching FQDN and no matching nodelabel, then the default
daemonset/secret (with no overrides applied) is used.

If a node matches more than one nodelabel, only the last matching nodelabel will
apply (last in terms of the order the overrides are defined in the YAML).

Exercising node/nodelabel overrides
-----------------------------------

The following example demonstrates how to exercise the node/nodelabel overrides:

.. code-block:: yaml

    data:
      values:
        conf:
          mychart:
            foo: 1
          # "overrides" keyword to invoke override behavior
          overrides:
            # To match these overrides to the right daemonset, the following key
            # needs to follow the pattern:
            # Chart.Name + '_' + $daemonset
            # where $daemonset is the value set for $daemonset in the daemonset
            # config above.
            mychart_mydaemonset:
              # labels dict contains a list of labels which overrides apply to. Dict may be excluded
              # if there are no labels to override.
              # Note - if a host satisfies more than one label in this list, then whichever matching
              # label is furtherest down on the list will be the one applied to the node. E.g., if
              # a host matched both label criteria below, then the overrides for "another_label"
              # would be applied.
              labels:
                # node label key and values to match against to apply these config overrides.
                # The values are ORed, so the daemonset will spawn to all nodes to node_type
                # set to "foo" and to all nodes with node_type set to "bar".
              - label:
                  key: node_type
                  values:
                  - "foo"
                  - "bar"
                # The setting overrides that will be applied for hosts with this host label
                conf:
                  mychart:
                    foo: 2
                # another label/key to match against to apply different overrides
              - label:
                  key: another_label
                  values:
                  - "another_value"
                # The setting overrides that will be applied for hosts with this host label
                conf:
                  mychart:
                    foo: 3
              # hosts dict contains a list of hosts which overrides apply to. Dict may be excluded
              # if there are no hosts to override.
              hosts:
                # FQDN of the host to override settings on
              - name: superhost
                # The setting overrides that will be applied for this host
                conf:
                  mychart:
                    foo: 4
                # FQDN of another host to override settings on
              - name: superhost2
                # The setting overrides that will be applied for this host
                conf:
                  mychart:
                    foo: 5

Nova vcpu example
------------------

Some nodes may have a different vcpu_pin_set in nova.conf due to differences
in CPU hardware.

To address this, we can specify overrides in the values fed to the chart. Ex:

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
The following shows a set of example hosts and the values fed into each:

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
