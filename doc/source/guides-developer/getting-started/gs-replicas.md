## Replicas

All charts must provide replica definitions and leverage those in the Kubernetes manifests.  This allows site operators to tune the replica counts at install or when upgrading.  Each chart should deploy with multiple replicas by default to ensure that production deployments are treated as first class citizens, and that services are tested with multiple replicas more frequently during development and testing.  Developers wishing to deploy minimal environments can enable the `development` mode override, which should enforce only one replica per component.

The convention today in OpenStack-Helm is to define a `replicas:` section for the chart, where each component being deployed has its own tunable value.

For example, the `glance` chart provides the following replicas in `values.yaml`

```
replicas:
  api: 2
  registry: 2
```

An operator can override these on `install` or `upgrade`:

```
$ helm install local/glance --set replicas.api=3,replicas.registry=3
```
