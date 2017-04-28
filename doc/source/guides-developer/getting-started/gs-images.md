## Images

The project's core philosophy regarding images is that the toolsets required to enable the OpenStack services should be applied by Kubernetes itself.  This requires OpenStack-Helm to develop common and simple scripts with minimal dependencies that can be overlaid on any image that meets the OpenStack core library requirements.  The advantage of this is that the project can be image agnostic, allowing operators to use Stackanetes, Kolla, Yaodu, or any image flavor and format they choose and they will all function the same.

A long-term goal, besides being image agnostic, is to also be able to support any of the container runtimes that Kubernetes supports, even those that might not use Docker's own packaging format.  This will allow the project to continue to offer maximum flexibility with regard to operator choice.

To that end, all charts provide an `images:` section that allows operators to override images.  Also, all default image references should be fully spelled out, even those hosted by Docker or Quay. Further, no default image reference should use `:latest` but rather should be pinned to a specific version to ensure consistent behavior for deployments over time.

Today, the `images:` section has several common conventions.  Most OpenStack services require a database initialization function, a database synchronization function, and a series of steps for Keystone registration and integration. Each component may also have a specific image that composes an OpenStack service. The images may or may not differ, but regardless, should all be defined in `images`.

The following standards are in use today, in addition to any components defined by the service itself:

- dep_check: The image that will perform dependency checking in an init-container.
- db_init: The image that will perform database creation operations for the OpenStack service.
- db_sync: The image that will perform database sync (schema initialization and migration) for the OpenStack service.
- ks_user: The image that will perform keystone user creation for the service.
- ks_service: The image that will perform keystone service registration for the service.
- ks_endpoints: The image that will perform keystone endpoint registration for the service.
- pull_policy: The image pull policy, one of "Always", "IfNotPresent", and "Never" which will be used by all containers in the chart.

An illustrative example of an `images:` section taken from the heat chart:

```
images:
  dep_check: quay.io/stackanetes/kubernetes-entrypoint:v0.1.1
  db_init: quay.io/stackanetes/stackanetes-kolla-toolbox:newton
  db_sync: docker.io/kolla/ubuntu-source-heat-api:3.0.1
  ks_user: quay.io/stackanetes/stackanetes-kolla-toolbox:newton
  ks_service: quay.io/stackanetes/stackanetes-kolla-toolbox:newton
  ks_endpoints: quay.io/stackanetes/stackanetes-kolla-toolbox:newton
  api: docker.io/kolla/ubuntu-source-heat-api:3.0.1
  cfn: docker.io/kolla/ubuntu-source-heat-api:3.0.1
  cloudwatch: docker.io/kolla/ubuntu-source-heat-api:3.0.1
  engine: docker.io/kolla/ubuntu-source-heat-engine:3.0.1
  pull_policy: "IfNotPresent"
```

The OpenStack-Helm project today uses a mix of Docker images from Stackanetes and Kolla, but will likely standardize on a default set of images for all charts without any reliance on image-specific utilities.
