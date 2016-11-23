# aic-helm/mariadb

By default, this chart creates a 3-member mariadb galera cluster.

PetSets would be ideal to use for this purpose, but as they are going through a transition in 1.5.0-beta.1 and not supported by Helm 2.0.0 under their new name, StatefulSets, we have opted to leverage helms template generation ability to create Values.replicas * POD+PVC+PV resources.  Essentially, we create a mariadb-0, mariadb-1, and mariadb-2 Pod and associated unique PersistentVolumeClaims for each.  This removes the previous daemonset limitations in other mariadb approaches.

You must ensure that your control nodes that should receive mariadb instances are labeled with openstack-control-plane=enabled:

```
kubectl label nodes openstack-control-plane=enabled --all
```

We will continue to refine our labeling so that it is consistent throughout the project.