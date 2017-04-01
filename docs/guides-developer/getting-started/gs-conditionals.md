## Common Conditionals

The OpenStack-Helm charts make the following conditions available across all charts, which can be set at install or upgrade time with Helm below.

### Developer Mode

```
helm install local/chart --set development.enabled=true
```

The development mode flag should be available on all charts.  Enabling this reduces dependencies that the chart may have on persistent volume claims (which are difficult to support in a laptop minikube environment) as well as reducing replica counts or resiliency features to support a minimal environment.

The glance chart for instance defines the following `development:` overrides:

```
development:
  enabled: false
  storage_path: /var/lib/localkube/openstack-helm/glance/images
```

The `enabled` flag allows the developer to enable development mode.  The storage path allows the operator to store glance images in a hostPath instead of leveraging a ceph backend, which again, is difficult to spin up in a small laptop minikube environment.  The host path can be overriden by the operator if desired.

### Resources

```
helm install local/chart --set resources.enabled=true
```

Resource limits/requirements can be turned on and off.  By default, they are off.  Setting this enabled to `true` will deploy Kubernetes resources with resource requirements and limits.
