# Helm Overrides

This document covers helm overrides and the openstack-helm approach.  For more information on helm overrides in general see the Helm [Values Documentation](https://github.com/kubernetes/helm/blob/master/docs/charts.md#values-files)

## Values Philosophy

There are two major The openstack-helm values philosophies that guide how values are formed.  It is important that new chart developers understand the values.yaml approach openstack-helm has to ensure our charts are both consistent and remain a joy to work with.

The first is that all charts should be independently installable and do not require a parent chart. This means that the values file in each chart should be self-contained.  We will avoid the use of helm globals and the concept of a parent chart as a requirement to capture and feed environment specific overrides into subcharts.  An example of a single site definition YAML that can be source controlled and used as `--values` input to all openstack-helm charts to maintain overrides in one testable place is forthcoming.  Currently helm does not support as `--values=environment.yaml` chunking up a larger override files YAML namespace.  Ideally, we are seeking native helm support for `helm install local/keystone --values=environment.yaml:keystone` where `environment.yaml` is the operators chart-wide environment defition and `keystone` is the section in environment.yaml that will be fed to the keystone chart during install as overrides.  Standard YAML anchors can be used to duplicate common elements like the `endpoints` sections.  As of this document, operators can use a temporary approach like [values.py](https://github.com/att-comdev/openstack-helm/blob/master/common/utils/values/values.py) to chunk up a single override YAML file as input to various individual charts.  It is our belief that overrides, just like the templates themselves, should be source controlled and tested especially for operators operating charts at scale.  We will continue to examine efforts such as [helm-value-store](https://github.com/skuid/helm-value-store) and solutions in the vein of [helmfile](https://github.com/roboll/helmfile).  A project that seems quite compelling to address the needs of orchestrating multiple charts and managing site specific overrides is [Landscape](https://github.com/Eneco/landscaper)

The second is that the values files should be consistent across all charts, including charts in core, infra, and addons.  This provides a consistent way for operators to override settings such as enabling developer mode, defining resource limitations, and customizing the actual OpenStack configuration within chart templates without having to guess how a particular chart developer has layed out their values.yaml. There are also various macros in the `common` chart that will depend on the values.yaml within all charts being structured a certain way.

Finally, where charts reference connectivity information for other services sane defaults should be provided.  In the case where these services are provided by openstack-helm itself, the defaults should assume the user will use the openstack-helm charts for those services but ensure that they can be overriden if the operator has them externally deployed.

## Replicas

All charts must provide replicas definitions and leverage those in the kubernetes manifests.  This allows site operators to tune the replica counts at install or upgrade time.  We suggest all charts deploy by default with more then one replica to ensure that openstack-helm being used in production environments is treated as a first class citizen and that more then one replica of every service is frequently tested.  Developers wishing to deploy minimal environments can enable the `development` mode override which should enforce only one replica of each component.

The convention today in openstack-helm is to define a `replicas:` section for the chart, with each component being deployed having its own tunable value.

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

We use nodeSelectors as well as podAntiAffinity rules to ensure resources land in the proper place within Kubernetes.  Today, openstack-helm employs four labels:

- ceph-storage: enabled
- openstack-control-plane: enabled
- openstack-compute-node: enabled
- openvswitch: enabled

Ideally, we would eliminate the openvswitch label as this is really an OR of (`openstack-control-plane` and `openstack-compute-node`) however the fundamental way in which Kubernetes nodeSelectors prohibits this specific logic so we require a third label that spans all hosts, `openvswitch` as this is an element that is applicable to both `openstack-control-plane` as well as `openstack-compute-node` hosts.  The openvswitch service must run on both types of hosts to provide openvswitch connectivity for DHCP, L3, Metadata services which run in the control plane as well as tenant connectivity which runs on the compute node infrastructure.

Labels are of course definable and overridable by the chart operators. Labels are defined in charts with a common convention, using a `labels:` section which defines both a selector, and a value:

```
labels:
  node_selector_key: openstack-control-plane
  node_selector_value: enabled
```

In some cases, a chart may need to define more then one label, such as the neutron chart in which case each element should be articulated under the `labels:` section, nesting where appropriate.

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

In some cases, especially with infrastructure components, it becomes necessary for the chart developer to provide some scheduling instruction to Kubernetes to help ensure proper resiliency.  The most common example employed today are podAntiAffinity rules, such as those used in the `mariadb` chart.  We encurage these to be placed on all foundational elements so that Kubernetes will disperse resources for resiliency, but also allow multi-replica installations to deploy successfully into a single host environment:

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

Our core philosophy regarding images is that the toolsets required to enable the OpenStack services should be applied by Kubernetes itself.  This requires the openstack-helm to develop common and simple scripts with minimal dependencies that can be overlayed on any image meeting the OpenStack core library requirements.  The advantage of this however is that we can be image agnostic, allowing operators to use Stackanetes, Kolla, Yaodu, or any image flavor they choose and they will all function the same.

To that end, all charts provide an `images:` section that allows operators to override images.  It is also our assertion that all default image references should be fully spelled out, even those hosted by docker, and no default image reference should use `:latest` but be pinned to a specific version to ensure a consistent behavior for deployments over time.

Today, the `images:` section has several common conventions.  Most openstack services require a database initialization function, a database synchronization function, and finally a series of steps for Keystone registration and integration. There may also be specific images for each component that composes that OpenStack services and these may or may not differ but should all be defined in `images`.

The following standards are in use today, in addition to any components defined by the service itself.

- dep_check: The image that will perform dependency checking in an init-container.
- db_init: The image that will perform database creation operations for the OpenStack service.
- db_sync: The image that will perform database sync (schema insertion) for the OpenStack service.
- ks_user: The image that will perform keystone user creation for the service.
- ks_service: The image that will perform keystone service registration for the service.
- ks_endpoints: The image that will perform keystone endpoint registration for the service.
- pull_policy: The image pull policy, one of "Always", "IfNotPresent", and "Never" which will be used by all containers in the chart.

An illustrative example of a images: section taken from the heat chart:

```
images:
  dep_check: quay.io/stackanetes/kubernetes-entrypoint:v0.1.0
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

The openstack-helm project today uses a mix of docker images from Stackanetes, Kolla, but going forward we will likely first standardize on Kolla images across all charts but without any reliance on Kolla image utilities, followed by support for alternative images with substantially smaller footprints such as [Yaodu](https://github.com/yaodu)

## Upgrades

The openstack-helm project assumes all upgrades will be done through helm.  This includes both template changes, including resources layered on top of the image such as configuration files as well as the Kubernetes resources themselves in addition to the more common practice of updating images.

Today, several issues exist within helm when updating images within charts that may be used by jobs that have already run to completion or are still in flight.  We will seek to address these within the helm community or within the charts themselves by support helm hooks to allow jobs to be deleted during an upgrade so that they can be recreated with an updated image.  An example of where this behavior would be desirable would be an updated db_sync image which has updated to point from a Mitaka image to a Newton image.  In this case, the operator will likely want a db_sync job which was already run and completed during site installation to run again with the updated image to bring the schema inline with the Newton release.

The openstack-helm project also implements annotations across all chart configmaps so that changing resources inside containers such as configuration files, triggers a Kubernetes rolling update so that those resources can be updated without deleting and redeploying the service and treated like any other upgrade such as a container image change.

This is accomplished with the following annotation:

```
      ...
      annotations:
        configmap-bin-hash: {{ tuple "configmap-bin.yaml" . | include "hash" }}
        configmap-etc-hash: {{ tuple "configmap-etc.yaml" . | include "hash" }}
```

The `hash` function defined in the `common` chart ensures that any change to any file referenced by configmap-bin.yaml or configmap-etc.yaml results in a new hash, which will trigger a rolling update.

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

In values.yaml in each chart, the same defaults are supplied in every chart, allowing the operator to override at upgrade or deployment time.

```
upgrades:
  revision_history: 3
  pod_replacement_strategy: RollingUpdate
  rolling_update:
    max_unavailable: 1
    max_surge: 3
```

## Resource Limits

Resource limits should be defined for all charts within openstack-helm.

The convention is to leverage a `resources:` section within values.yaml with an `enabled` setting that defaults to `false` but can be turned on by the operator at install or upgrade time.

The resources specify the requests (memory and cpu) and limits (memory and cpu) for each deployed resource.  For example, from the nova chart `values.yaml`:

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

These resources definitions are then applied to the appropriate component, when the `enabled` flag is set.  For instance, below, the nova_compute daemonset has the requests and limits values applied from `.Values.resources.nova_compute`:

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

When a chart developer doesn't know what resource limits or requests to apply to a new component, they can deploy them locally and examine utilization using tools like WeaveScope.  The resource limits may not be perfect on initial submission but over time with community contributions they will be refined to reflect reality.

## Endpoints

NOTE: This feature is under active development.  There may be dragons here.

Endpoints are a large part of what openstack-helm seeks to provide mechanisms around.  OpenStack is a highly interconnected application, with various components requiring connectivity details to numerous services, including other OpenStack components, infrastructure elements such as databases, queues, and memcache infrastructure.  We want to ensure we provide a consistent mechanism for defining these "endpoints" across all charts and the macros necessary to convert those definitions into usable endpoints.  The charts should consistently default to building endpoints that assume the operator is leveraging all of our charts to build their OpenStack stack.  However, we want to ensure that if operators want to run some of our charts and have those plug into their existing infrastructure, or run elements in different namespaces, for example, these endpoints should be overridable.


For instance, in the neutron chart `values.yaml` the following endpoints are defined:

```
# typically overriden by environmental
# values, but should include all endpoints
# required by this chart
endpoints:
  glance:
    hosts:
      default: glance-api
    type: image
    path: null
    scheme: 'http'
    port:
      api: 9292
      registry: 9191
  nova:
    hosts:
      default: nova-api
    path: "/v2/%(tenant_id)s"
    type: compute
    scheme: 'http'
    port:
      api: 8774
      metadata: 8775
      novncproxy: 6080
  keystone:
    hosts:
      default: keystone-api
    path: /v3
    type: identity
    scheme: 'http'
    port:
        admin: 35357
        public: 5000
  neutron:
    hosts:
      default: neutron-server
    path: null
    type: network
    scheme: 'http'
    port:
      api: 9696
```

These values define all the endpoints that the neutron chart may need in order to build full URL compatible endpoints to various services.  Long-term these will also include database, memcache, and rabbitmq elements in one place--essentially all external connectivity needs defined centrally.

The macros that help translate these into the actual URLs necessary are defined in the `common` chart.  For instance, the cinder chart defines a `glance_api_servers` definition in the `cinder.conf` template:

```
+glance_api_servers = {{ tuple "image" "internal" "api" . | include "endpoint_type_lookup_addr" }}
```

This line of magic uses the `endpoint_type_lookup_addr` macro in the common chart (since it is used by all charts), and passes it three parameters:

- image: This the OpenStack service we are building an endpoint for.  This will be mapped to `glance` which is the image service for OpenStack.
- internal: This is the OpenStack endpoint type we are looking for - valid values would be `internal`, `admin`, and `public`
- api: This is the port to map to for the service.  Some components such as glance provide an `api` port and a `registry` port, for example.

Charts should avoid at all costs hard coding values such as ``http://keystone-api:5000` as these are not compatible with operator overrides or supporting spreading components out over various namespaces.

## Common Conditionals

The openstack-helm charts make the following conditions available across all charts which can be set at install or upgrade time with helm:

### Developer Mode 

```
helm install local/chart --set development.enabled=true
```

The development mode flag should be available on all charts.  Enabling this reduces dependencies that chart may have on persistent volume claims (which are difficult to support in a laptop minikube environment) as well as reducing replica counts or resiliency features to support a minimal environment.

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
