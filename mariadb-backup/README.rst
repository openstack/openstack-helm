openstack-helm/mariadb-backup
======================

By default, this chart creates a mariadb-backup cronjob that runs in a schedule
in order to create mysql backups.

This chart depends on mariadb-cluster chart.

The backups are stored in a PVC and also are possible to upload then to a remote
RGW container.

You must ensure that your control nodes that should receive mariadb
instances are labeled with ``openstack-control-plane=enabled``, or
whatever you have configured in values.yaml for the label
configuration:

::

    kubectl label nodes openstack-control-plane=enabled --all
