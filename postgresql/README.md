# openstack-helm/postgresql

This chart leverages StatefulSets, with persistent storage.

The StatefulSets all leverage PVCs to provide stateful storage to /var/lib/postgresql.

You must ensure that your control nodes that should receive postgresql instances are labeled with openstack-control-plane=enabled, or whatever you have configured in values.yaml for the label configuration:

```
kubectl label nodes openstack-control-plane=enabled --all
```
