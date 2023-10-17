openstack-helm/mariadb
======================

By default, this chart creates a 3-member mariadb galera cluster.

This chart depends on mariadb-operator chart.

The StatefulSets all leverage PVCs to provide stateful storage to
``/var/lib/mysql``.

You must ensure that your control nodes that should receive mariadb
instances are labeled with ``openstack-control-plane=enabled``, or
whatever you have configured in values.yaml for the label
configuration:

::

    kubectl label nodes openstack-control-plane=enabled --all
