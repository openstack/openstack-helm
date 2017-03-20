# Helm Overrides

This document covers Helm overrides and the OpenStack-Helm approach.  For more information on Helm overrides in general see the Helm [Values Documentation](https://github.com/kubernetes/helm/blob/master/docs/charts.md#values-files)

## Values Philosophy

Two major philosophies guide the OpenStack-Helm values approach.  It is important that new chart developers understand the `values.yaml` approach OpenStack-Helm has within each of its charts to ensure that all charts are both consistent and remain a joy to work with.

The first philosophy to understand is that all charts should be independently installable and should not require a parent chart. This means that the values file in each chart should be self-contained.  The project avoids using Helm globals and parent charts as requirements for capturing and feeding environment specific overrides into subcharts.  An example of a single site definition YAML that can be source controlled and used as `--values` input to all OpenStack-Helm charts to maintain overrides in one testable place is forthcoming.  Currently Helm does not support a `--values=environment.yaml` chunking up a larger override file's YAML namespace.  Ideally, the project seeks native Helm support for `helm install local/keystone --values=environment.yaml:keystone` where `environment.yaml` is the operator's chart-wide environment definition and `keystone` is the section in environment.yaml that will be fed to the keystone chart during install as overrides.  Standard YAML anchors can be used to duplicate common elements like the `endpoints` sections.  At the time of writing, operators can use a temporary approach like [values.py](https://github.com/att-comdev/openstack-helm/blob/master/helm-toolkit/utils/values/values.py) to chunk up a single override YAML file as input to various individual charts.  Overrides, just like the templates themselves, should be source controlled and tested, especially for operators operating charts at scale.  This project will continue to examine efforts such as [helm-value-store](https://github.com/skuid/helm-value-store) and solutions in the vein of [helmfile](https://github.com/roboll/helmfile).  Another compelling project that seems to address the needs of orchestrating multiple charts and managing site specific overrides is [Landscape](https://github.com/Eneco/landscaper)

The second philosophy is that the values files should be consistent across all charts, including charts in core, infra, and add-ons.  This provides a consistent way for operators to override settings, such as enabling developer mode, defining resource limitations, and customizing the actual OpenStack configuration within chart templates without having to guess how a particular chart developer has laid out their values.yaml. There are also various macros in the `helm-toolkit` chart that will depend on the `values.yaml` within all charts being structured a certain way.

Finally, where charts reference connectivity information for other services sane defaults should be provided.  In cases where these services are provided by OpenStack-Helm itself, the defaults should assume that the user will use the OpenStack-Helm charts for those services, but should also allow those charts to be overridden if the operator has them externally deployed.

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

## Images

The project's core philosophy regarding images is that the toolsets required to enable the OpenStack services should be applied by Kubernetes itself.  This requires OpenStack-Helm to develop common and simple scripts with minimal dependencies that can be overlaid on any image that meets the OpenStack core library requirements.  The advantage of this is that the project can be image agnostic, allowing operators to use Stackanetes, Kolla, Yaodu, or any image flavor and format they choose and they will all function the same.

A long-term goal, besides being image agnostic, is to also be able to support any of the container runtimes that Kubernetes supports, even those that might not use Docker's own packaging format.  This will allow the project to continue to offer maximum flexibility with regard to operator choice.

To that end, all charts provide an `images:` section that allows operators to override images.  Also, all default image references should be fully spelled out, even those hosted by Docker or Quay. Further, no default image reference should use `:latest` but rather should be pinned to a specific version to ensure consistent behavior for deployments over time.

Today, the `images:` section has several common conventions.  Most OpenStack services require a database initialization function, a database synchronization function, and a series of steps for Keystone registration and integration. Each component may also have a specific image that composes an OpenStack service. The images may or may not differ, but regardless, should all be defined in `images`.

The following standards are in use today, in addition to any components defined by the service itself:

- dep_check: The image that will perform dependency checking in an init-container.
- db_init: The image that will perform database creation operations for the OpenStack service.
- db_sync: The image that will perform database sync (schema insertion) for the OpenStack service.
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

The OpenStack-Helm project today uses a mix of Docker images from Stackanetes and Kolla, but will likely standardize on Kolla images for all charts without any reliance on Kolla image utilities. Soon, the project will support alternative images with substantially smaller footprints, such as [Yaodu](https://github.com/yaodu).

## Upgrades

The OpenStack-Helm project assumes all upgrades will be done through Helm. This includes handling several different resource types. First, changes to the Helm chart templates themselves are handled. Second, all of the resources layered on top of the container image, such as `ConfigMaps` which includes both scripts and configuration files, are updated during an upgrade. Finally, any image references will result in rolling updates of containers, replacing them with the updating image.

As Helm stands today, several issues exist when you update images within charts that might have been used by jobs that already ran to completion or are still in flight.  OpenStack-Helm developers will continue to work with the Helm community or develop charts that will support job removal prior to an upgrade, which will recreate services with updated images.  An example of where this behavior would be desirable is when an updated db_sync image has updated to point from a Mitaka image to a Newton image.  In this case, the operator will likely want a db_sync job, which was already run and completed during site installation, to run again with the updated image to bring the schema inline with the Newton release.

The OpenStack-Helm project also implements annotations across all chart configmaps so that changing resources inside containers, such as configuration files, triggers a Kubernetes rolling update. This means that those resources can be updated without deleting and redeploying the service and can be treated like any other upgrade, such as a container image change.

This is accomplished with the following annotation:

```
      ...
      annotations:
        configmap-bin-hash: {{ tuple "configmap-bin.yaml" . | include "hash" }}
        configmap-etc-hash: {{ tuple "configmap-etc.yaml" . | include "hash" }}
```

The `hash` function defined in the `helm-toolkit` chart ensures that any change to any file referenced by configmap-bin.yaml or configmap-etc.yaml results in a new hash, which will then trigger a rolling update.

All chart components (except `DaemonSets`) are outfitted by default with rolling update strategies:

```
spec:
  replicas: {{ .Values.replicas }}
  revisionHistoryLimit: {{ .Values.upgrades.revision_history }}
  strategy:
    type: {{ .Values.upgrades.pod_replacement_strategy }}
    {{ if eq .Values.upgrades.pod_replacement_strategy "RollingUpdate" }}
    rollingUpdate:
      maxUnavailable: {{ .Values.upgrades.rolling_update.max_unavailable }}
      maxSurge: {{ .Values.upgrades.rolling_update.max_surge }}
    {{ end }}
```

In values.yaml in each chart, the same defaults are supplied in every chart, which allows the operator to override at upgrade or deployment time.

```
upgrades:
  revision_history: 3
  pod_replacement_strategy: RollingUpdate
  rolling_update:
    max_unavailable: 1
    max_surge: 3
```

## Resource Limits

Resource limits should be defined for all charts within OpenStack-Helm.

The convention is to leverage a `resources:` section within values.yaml by using an `enabled` setting that defaults to `false` but can be turned on by the operator at install or upgrade time.

The resources specify the requests (memory and cpu) and limits (memory and cpu) for each deployed resource.  For example, from the Nova chart `values.yaml`:

```
resources:
  enabled: false
  nova_compute:
    requests:
      memory: "124Mi"
      cpu: "100m"
    limits:
      memory: "1024Mi"
      cpu: "2000m"
  nova_libvirt:
    requests:
      memory: "124Mi"
      cpu: "100m"
    limits:
      memory: "1024Mi"
      cpu: "2000m"
  nova_api_metadata:
    requests:
      memory: "124Mi"
      cpu: "100m"
    limits:
      memory: "1024Mi"
      cpu: "2000m"
...
```

These resources definitions are then applied to the appropriate component when the `enabled` flag is set.  For instance, the following nova_compute daemonset has the requests and limits values applied from `.Values.resources.nova_compute`:

```
          {{- if .Values.resources.enabled }}
          resources:
            requests:
              memory: {{ .Values.resources.nova_compute.requests.memory | quote }}
              cpu: {{ .Values.resources.nova_compute.requests.cpu | quote }}
            limits:
              memory: {{ .Values.resources.nova_compute.limits.memory | quote }}
              cpu: {{ .Values.resources.nova_compute.limits.cpu | quote }}
          {{- end }}
```

When a chart developer doesn't know what resource limits or requests to apply to a new component, they can deploy the component locally and examine resource utilization using tools like WeaveScope.  The resource limits may not be perfect on initial submission, but over time and with community contributions, they can be refined to reflect reality.

## Endpoints

NOTE: This feature is under active development.  There may be dragons here.

As a large part of the project's purpose, OpenStack-Helm seeks to provide mechanisms around endpoints.  OpenStack is a highly interconnected application, with various components requiring connectivity details to numerous services, including other OpenStack components and infrastructure elements such as databases, queues, and memcached infrastructure.  The project's goal is to ensure that it can provide a consistent mechanism for defining these "endpoints" across all charts and provide the macros necessary to convert those definitions into usable endpoints.  The charts should consistently default to building endpoints that assume the operator is leveraging all charts to build their OpenStack cloud.  Endpoints should be configurable if an operator would like a chart to work with their existing infrastructure or run elements in different namespaces.


For instance, in the Neutron chart `values.yaml` the following endpoints are defined:

```
# typically overridden by environmental
# values, but should include all endpoints
# required by this chart
endpoints:
  image:
    hosts:
      default: glance-api
    type: image
    path: null
    scheme: 'http'
    port:
      api: 9292
      registry: 9191
  compute:
    hosts:
      default: nova-api
    path: "/v2/%(tenant_id)s"
    type: compute
    scheme: 'http'
    port:
      api: 8774
      metadata: 8775
      novncproxy: 6080
  identity:
    hosts:
      default: keystone-api
    path: /v3
    type: identity
    scheme: 'http'
    port:
        admin: 35357
        public: 5000
  network:
    hosts:
      default: neutron-server
    path: null
    type: network
    scheme: 'http'
    port:
      api: 9696
```

These values define all the endpoints that the Neutron chart may need in order to build full URL compatible endpoints to various services.  Long-term, these will also include database, memcached, and rabbitmq elements in one place. Essentially, all external connectivity needs to be defined centrally.

The macros that help translate these into the actual URLs necessary are defined in the `helm-toolkit` chart.  For instance, the cinder chart defines a `glance_api_servers` definition in the `cinder.conf` template:

```
+glance_api_servers = {{ tuple "image" "internal" "api" . | include "helm-toolkit.endpoint_type_lookup_addr" }}
```

This line of magic uses the `endpoint_type_lookup_addr` macro in the `helm-toolkit` chart (since it is used by all charts).  Note that there is a second convention here. All `{{ define }}` macros in charts should be pre-fixed with the chart that is defining them.  This allows developers to easily identify the source of a Helm macro and also avoid namespace collisions.  In the example above, the macro `endpoint_type_look_addr` is defined in the `helm-toolkit` chart.  This macro is passing three parameters (aided by the `tuple` method built into the go/sprig templating library used by Helm):

- image: This is the OpenStack service that the endpoint is being built for.  This will be mapped to `glance` which is the image service for OpenStack.
- internal: This is the OpenStack endpoint type we are looking for - valid values would be `internal`, `admin`, and `public`
- api: This is the port to map to for the service.  Some components, such as glance, provide an `api` port and a `registry` port, for example.

At all costs, charts should avoid hard coding values such as `http://keystone-api:5000` because these are not compatible with operator overrides and do not support spreading components out over various namespaces.

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
  storage_path: /data/openstack-helm/glance/images
```

The `enabled` flag allows the developer to enable development mode.  The storage path allows the operator to store glance images in a hostPath instead of leveraging a ceph backend, which again, is difficult to spin up in a small laptop minikube environment.  The host path can be overriden by the operator if desired.

### Resources

```
helm install local/chart --set resources.enabled=true
```

Resource limits/requirements can be turned on and off.  By default, they are off.  Setting this enabled to `true` will deploy Kubernetes resources with resource requirements and limits.
