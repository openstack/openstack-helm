openstack-helm/mariadb
======================

By default, this chart creates a 3-member mariadb galera cluster.

This chart leverages StatefulSets, with persistent storage.

It creates a job that acts as a temporary standalone galera cluster.
This host is bootstrapped with authentication and then the WSREP
bindings are exposed publicly. The cluster members being StatefulSets
are provisioned one at a time. The first host must be marked as
``Ready`` before the next host will be provisioned. This is determined
by the readinessProbes which actually validate that MySQL is up and
responsive.

The configuration leverages xtrabackup-v2 for synchronization. This may
later be augmented to leverage rsync which has some benefits.

Once the seed job completes, which completes only when galera reports
that it is Synced and all cluster members are reporting in thus matching
the cluster count according to the job to the replica count in the helm
values configuration, the job is terminated. When the job is no longer
active, future StatefulSets provisioned will leverage the existing
cluster members as gcomm endpoints. It is only when the job is running
that the cluster members leverage the seed job as their gcomm endpoint.
This ensures you can restart members and scale the cluster.

The StatefulSets all leverage PVCs to provide stateful storage to
``/var/lib/mysql``.

You must ensure that your control nodes that should receive mariadb
instances are labeled with ``openstack-control-plane=enabled``, or
whatever you have configured in values.yaml for the label
configuration:

::

    kubectl label nodes openstack-control-plane=enabled --all
