Prometheus
==========

The Prometheus chart in openstack-helm-infra provides a time series database and
a strong querying language for monitoring various components of OpenStack-Helm.
Prometheus gathers metrics by scraping defined service endpoints or pods at
specified intervals and indexing them in the underlying time series database.

Authentication
--------------

The Prometheus deployment includes a sidecar container that runs an Apache
reverse proxy to add authentication capabilities for Prometheus.  The
username and password are configured under the monitoring entry in the endpoints
section of the chart's values.yaml.

The configuration for Apache can be found under the conf.httpd key, and uses a
helm-toolkit function that allows for including gotpl entries in the template
directly.  This allows the use of other templates, like the endpoint lookup
function templates, directly in the configuration for Apache.

Prometheus Service configuration
--------------------------------

The Prometheus service is configured via command line flags set during runtime.
These flags include: setting the configuration file, setting log levels, setting
characteristics of the time series database, and enabling the web admin API for
snapshot support.  These settings can be configured via the values tree at:

::

    conf:
      prometheus:
        command_line_flags:
          log.level: info
          query.max_concurrency: 20
          query.timeout: 2m
          storage.tsdb.path: /var/lib/prometheus/data
          storage.tsdb.retention: 7d
          web.enable_admin_api: false
          web.enable_lifecycle: false

The Prometheus configuration file contains the definitions for scrape targets
and the location of the rules files for triggering alerts on scraped metrics.
The configuration file is defined in the values file, and can be found at:

::

    conf:
      prometheus:
        scrape_configs: |

By defining the configuration via the values file, an operator can override all
configuration components of the Prometheus deployment at runtime.

Kubernetes Endpoint Configuration
---------------------------------

The Prometheus chart in openstack-helm-infra uses the built-in service discovery
mechanisms for Kubernetes endpoints and pods to automatically configure scrape
targets.  Functions added to helm-toolkit allows configuration of these targets
via annotations that can be applied to any service or pod that exposes metrics
for Prometheus, whether a service for an application-specific exporter or an
application that provides a metrics endpoint via its service. The values in
these functions correspond to entries in the monitoring tree under the
prometheus key in a chart's values.yaml file.


The functions definitions are below:

::

    {{- define "helm-toolkit.snippets.prometheus_service_annotations" -}}
    {{- $config := index . 0 -}}
    {{- if $config.scrape }}
    prometheus.io/scrape: {{ $config.scrape | quote }}
    {{- end }}
    {{- if $config.scheme }}
    prometheus.io/scheme: {{ $config.scheme | quote }}
    {{- end }}
    {{- if $config.path }}
    prometheus.io/path: {{ $config.path | quote }}
    {{- end }}
    {{- if $config.port }}
    prometheus.io/port: {{ $config.port | quote }}
    {{- end }}
    {{- end -}}

::

    {{- define "helm-toolkit.snippets.prometheus_pod_annotations" -}}
    {{- $config := index . 0 -}}
    {{- if $config.scrape }}
    prometheus.io/scrape: {{ $config.scrape | quote }}
    {{- end }}
    {{- if $config.path }}
    prometheus.io/path: {{ $config.path | quote }}
    {{- end }}
    {{- if $config.port }}
    prometheus.io/port: {{ $config.port | quote }}
    {{- end }}
    {{- end -}}

These functions render the following annotations:

- prometheus.io/scrape:  Must be set to true for Prometheus to scrape target
- prometheus.io/scheme:  Overrides scheme used to scrape target if not http
- prometheus.io/path:    Overrides path used to scrape target metrics if not /metrics
- prometheus.io/port:    Overrides port to scrape metrics on if not service's default port

Each chart that can be targeted for monitoring by Prometheus has a prometheus
section under a monitoring tree in the chart's values.yaml, and Prometheus
monitoring is disabled by default for those services.  Example values for the
required entries can be found in the following monitoring configuration for the
prometheus-node-exporter chart:

::

    monitoring:
      prometheus:
        enabled: false
        node_exporter:
          scrape: true

If the prometheus.enabled key is set to true, the annotations are set on the
targeted service or pod as the condition for applying the annotations evaluates
to true.  For example:

::

    {{- $prometheus_annotations := $envAll.Values.monitoring.prometheus.node_exporter }}
    ---
    apiVersion: v1
    kind: Service
    metadata:
    name: {{ tuple "node_metrics" "internal" . | include "helm-toolkit.endpoints.hostname_short_endpoint_lookup" }}
    labels:
    {{ tuple $envAll "node_exporter" "metrics" | include "helm-toolkit.snippets.kubernetes_metadata_labels" | indent 4 }}
    annotations:
    {{- if .Values.monitoring.prometheus.enabled }}
    {{ tuple $prometheus_annotations | include "helm-toolkit.snippets.prometheus_service_annotations" | indent 4 }}
    {{- end }}

Kubelet, API Server, and cAdvisor
---------------------------------

The Prometheus chart includes scrape target configurations for the kubelet, the
Kubernetes API servers, and cAdvisor.  These targets are configured based on
a kubeadm deployed Kubernetes cluster, as OpenStack-Helm uses kubeadm to deploy
Kubernetes in the gates.  These configurations may need to change based on your
chosen method of deployment.  Please note the cAdvisor metrics will not be
captured if the kubelet was started with the following flag:

::

    --cadvisor-port=0

To enable the gathering of the kubelet's custom metrics, the following flag must
be set:

::

    --enable-custom-metrics

Installation
------------

The Prometheus chart can be installed with the following command:

.. code-block:: bash

    helm install --namespace=openstack local/prometheus --name=prometheus

The above command results in a Prometheus deployment configured to automatically
discover services with the necessary annotations for scraping, configured to
gather metrics on the kubelet, the Kubernetes API servers, and cAdvisor.

Extending Prometheus
--------------------

Prometheus can target various exporters to gather metrics related to specific
applications to extend visibility into an OpenStack-Helm deployment.  Currently,
openstack-helm-infra contains charts for:

- prometheus-kube-state-metrics: Provides additional Kubernetes metrics
- prometheus-node-exporter: Provides metrics for nodes and linux kernels
- prometheus-openstack-metrics-exporter: Provides metrics for OpenStack services

Kube-State-Metrics
~~~~~~~~~~~~~~~~~~

The prometheus-kube-state-metrics chart provides metrics for Kubernetes objects
as well as metrics for kube-scheduler and kube-controller-manager.  Information
on the specific metrics available via the kube-state-metrics service can be
found in the kube-state-metrics_ documentation.

The prometheus-kube-state-metrics chart can be installed with the following:

.. code-block:: bash

    helm install --namespace=kube-system local/prometheus-kube-state-metrics --name=prometheus-kube-state-metrics

.. _kube-state-metrics: https://github.com/kubernetes/kube-state-metrics/tree/master/Documentation

Node Exporter
~~~~~~~~~~~~~

The prometheus-node-exporter chart provides hardware and operating system metrics
exposed via Linux kernels.  Information on the specific metrics available via
the Node exporter can be found on the Node_exporter_ GitHub page.

The prometheus-node-exporter chart can be installed with the following:

.. code-block:: bash

    helm install --namespace=kube-system local/prometheus-node-exporter --name=prometheus-node-exporter

.. _Node_exporter: https://github.com/prometheus/node_exporter

OpenStack Exporter
~~~~~~~~~~~~~~~~~~

The prometheus-openstack-exporter chart provides metrics specific to the
OpenStack services.  The exporter's source code can be found here_. While the
metrics provided are by no means comprehensive, they will be expanded upon.

Please note the OpenStack exporter requires the creation of a Keystone user to
successfully gather metrics.  To create the required user, the chart uses the
same keystone user management job the OpenStack service charts use.

The prometheus-openstack-exporter chart can be installed with the following:

.. code-block:: bash

    helm install --namespace=openstack local/prometheus-openstack-exporter --name=prometheus-openstack-exporter

.. _here: https://github.com/att-comdev/openstack-metrics-collector

Other exporters
~~~~~~~~~~~~~~~

Certain charts in OpenStack-Helm include templates for application-specific
Prometheus exporters, which keeps the monitoring of those services tightly coupled
to the chart.  The templates for these exporters can be found in the monitoring
subdirectory in the chart.  These exporters are disabled by default, and can be
enabled by setting the appropriate flag in the monitoring.prometheus key of the
chart's values.yaml file.  The charts containing exporters include:

- Elasticsearch_
- RabbitMQ_
- MariaDB_
- Memcached_
- Fluentd_
- Postgres_

.. _Elasticsearch: https://github.com/prometheus-community/elasticsearch_exporter
.. _RabbitMQ: https://github.com/kbudde/rabbitmq_exporter
.. _MariaDB: https://github.com/prometheus/mysqld_exporter
.. _Memcached: https://github.com/prometheus/memcached_exporter
.. _Fluentd: https://github.com/V3ckt0r/fluentd_exporter
.. _Postgres: https://github.com/wrouesnel/postgres_exporter

Ceph
~~~~

Starting with Luminous, Ceph can export metrics with ceph-mgr prometheus module.
This module can be enabled in Ceph's values.yaml under the ceph_mgr_enabled_plugins
key by appending prometheus to the list of enabled modules.  After enabling the
prometheus module, metrics can be scraped on the ceph-mgr service endpoint.  This
relies on the Prometheus annotations attached to the ceph-mgr service template, and
these annotations can be modified in the endpoints section of Ceph's values.yaml
file.  Information on the specific metrics available via the prometheus module
can be found in the Ceph prometheus_ module documentation.

.. _prometheus: http://docs.ceph.com/docs/master/mgr/prometheus/


Prometheus Dashboard
--------------------

Prometheus includes a dashboard that can be accessed via the accessible
Prometheus endpoint (NodePort or otherwise).  This dashboard will give you a
view of your scrape targets' state, the configuration values for Prometheus's
scrape jobs and command line flags, a view of any alerts triggered based on the
defined rules, and a means for using PromQL to query scraped metrics.  The
Prometheus dashboard is a useful tool for verifying Prometheus is configured
appropriately and to verify the status of any services targeted for scraping via
the Prometheus service discovery annotations.

Rules Configuration
-------------------

Prometheus provides a querying language that can operate on defined rules which
allow for the generation of alerts on specific metrics.  The Prometheus chart in
openstack-helm-infra defines these rules via the values.yaml file.  By defining
these in the values file, it allows operators flexibility to provide specific
rules via overrides at installation.  The following rules keys are provided:

::

    values:
      conf:
        rules:
          alertmanager:
          etcd3:
          kube_apiserver:
          kube_controller_manager:
          kubelet:
          kubernetes:
          rabbitmq:
          mysql:
          ceph:
          openstack:
          custom:

These provided keys provide recording and alert rules for all infrastructure
components of an OpenStack-Helm deployment.  If you wish to exclude rules for a
component, leave the tree empty in an overrides file.  To read more
about Prometheus recording and alert rules definitions, please see the official
Prometheus recording_ and alert_ rules documentation.

.. _recording: https://prometheus.io/docs/prometheus/latest/configuration/recording_rules/
.. _alert: https://prometheus.io/docs/prometheus/latest/configuration/alerting_rules/

Note: Prometheus releases prior to 2.0 used gotpl to define rules.  Prometheus
2.0 changed the rules format to YAML, making them much easier to read.  The
Prometheus chart in openstack-helm-infra uses Prometheus 2.0 by default to take
advantage of changes to the underlying storage layer and the handling of stale
data.  The chart will not support overrides for Prometheus versions below 2.0,
as the command line flags for the service changed between versions.

The wide range of exporters included in OpenStack-Helm coupled with the ability
to define rules with configuration overrides allows for the addition of custom
alerting and recording rules to fit an operator's monitoring needs.  Adding new
rules or modifying existing rules require overrides for either an existing key
under conf.rules or the addition of a new key under conf.rules.  The addition
of custom rules can be used to define complex checks that can be extended for
determining the liveliness or health of infrastructure components.
