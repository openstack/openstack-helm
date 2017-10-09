..
 This work is licensed under a Creative Commons Attribution 3.0 Unported
 License.

 http://creativecommons.org/licenses/by/3.0/legalcode

..

=====================================
OSH Logging, Monitoring, and Alerting
=====================================

Blueprints:
1. osh-monitoring_
2. osh-logging-framework_

.. _osh-monitoring: https://blueprints.launchpad.net/openstack-helm/+spec/osh-monitoring
.. _osh-logging-framework: https://blueprints.launchpad.net/openstack-helm/+spec/osh-logging-framework


Problem Description
===================

OpenStack-Helm currently lacks a centralized mechanism for providing insight
into the performance of the OpenStack services and infrastructure components.
The log formats of the different components in OpenStack-Helm vary, which makes
identifying causes for issues difficult across services.  To support operational
readiness by default, OpenStack-Helm should include components for logging
events in a common format, monitoring metrics at all levels, alerting and alarms
for those metrics, and visualization tools for querying the logs and metrics in
a single pane view.


Platform Requirements
=====================

Logging Requirements
--------------------

The requirements for a logging platform include:

1. All services in OpenStack-Helm log to stdout and stderr by default
2. Log collection daemon runs on each node to forward logs to storage
3. Proper directories mounted to retrieve logs from the node
4. Ability to apply custom metadata and uniform format to logs
5. Time-series database for logs collected
6. Backed by highly available storage
7. Configurable log rotation mechanism
8. Ability to perform custom queries against stored logs
9. Single pane visualization capabilities

Monitoring Requirements
-----------------------

The requirements for a monitoring platform include:

1. Time-series database for collected metrics
2. Backed by highly available storage
3. Common method to configure all monitoring targets
4. Single pane visualization capabilities
5. Ability to perform custom queries against metrics collected
6. Alerting capabilities to notify operators when thresholds exceeded


Use Cases
=========

Logging Use Cases
-----------------

Example uses for centralized logging include:

1. Record compute instance behavior across nodes and services
2. Record OpenStack service behavior and status
3. Find all backtraces for a tenant id's uuid
4. Identify issues with infrastructure components, such as RabbitMQ, mariadb, etc
5. Identify issues with Kubernetes components, such as: etcd, CNI, scheduler, etc
6. Organizational auditing needs
7. Visualize logged events to determine if an event is recurring or an outlier
8. Find all logged events that match a pattern (service, pod, behavior, etc)

Monitoring Use Cases
--------------------

Example OpenStack-Helm metrics requiring monitoring include:

1. Host utilization: memory usage, CPU usage, disk I/O, network I/O, etc
2. Kubernetes metrics: pod status, replica availability, job status, etc
3. Ceph metrics: total pool usage, latency, health, etc
4. OpenStack metrics: tenants, networks, flavors, floating IPs, quotas, etc
5. Proactive monitoring of stack traces across all deployed infrastructure

Examples of how these metrics can be used include:

1. Add or remove nodes depending on utilization
2. Trigger alerts when desired replicas fall below required number
3. Trigger alerts when services become unavailable or unresponsive
4. Identify etcd performance that could lead to cluster instability
5. Visualize performance to identify trends in traffic or utilization over time

Proposed Change
===============

Logging
-------

Fluentd, Elasticsearch, and Kibana meet OpenStack-Helm's logging requirements
for capture, storage and visualization of logged events.  Fluentd runs as a
daemonset on each node and mounts the /var/lib/docker/containers directory.
The Docker container runtime engine directs events posted to stdout and stderr
to this directory on the host.  Fluentd should then declare the contents of
that directory as an input stream, and use the fluent-plugin-elasticsearch
plugin to apply the Logstash format to the logs.  Fluentd will also use the
fluentd-plugin-kubernetes-metadata plugin to write Kubernetes metadata to the
log record.  Fluentd will then forward the results to Elasticsearch, which
indexes the logs in a logstash-* index by default.  The resulting logs can then
be queried directly through Elasticsearch, or they can be viewed via Kibana.
Kibana offers a dashboard that can create custom views on logged events, and
Kibana integrates well with Elasticsearch by default.

The proposal includes the following:

1. Helm chart for Fluentd
2. Helm chart for Elasticsearch
3. Helm chart for Kibana

All three charts must include sensible configuration values to make the
logging platform usable by default.  These include: proper input configurations
for Fluentd, proper metadata and formats applied to the logs via Fluentd,
sensible indexes created for Elasticsearch, and proper configuration values for
Kibana to query the Elasticsearch indexes previously created.

Monitoring
----------

Prometheus and Grafana meet OpenStack-Helm's monitoring requirements.  The
Prometheus monitoring tool provides the ability to scrape targets for metrics
over HTTP, and it stores these metrics in Prometheus's time-series database.
The monitoring targets can be discovered via static configuration in Prometheus
or through service discovery.  Prometheus includes a querying language that
provides meaningful queries against the metrics gathered and supports the
creation of rules to measure these metrics against for alerting purposes.  It
also supports a wide range of Prometheus exporters for existing services,
including Ceph and OpenStack.  Grafana supports Prometheus as a data source, and
provides the ability to view the metrics gathered by Prometheus in a single pane
dashboard.  Grafana can be bootstrapped with dashboards for each target scraped,
or the dashboards can be added via Grafana's web interface directly.  To meet
OpenStack-Helm's alerting needs, Alertmanager can be used to interface with
Prometheus and send alerts based on Prometheus rule evaluations.

The proposal includes the following:

1. Helm chart for Prometheus
2. Helm chart for Alertmanager
3. Helm chart for Grafana
4. Helm charts for any appropriate Prometheus exporters

All charts must include sensible configuration values to make the monitoring
platform usable by default.  These include:  static Prometheus configurations
for the included exporters, static dashboards for Grafana mounted via configMaps
and configurations for Alertmanager out of the box.

Security Impact
---------------

All services running within the platform should be subject to the
security practices applied to the other OpenStack-Helm charts.

Performance Impact
------------------

To minimize the performance impacts, the following should be considered:

1. Sane defaults for log retention and rotation policies
2. Identify opportunities for improving Prometheus's operation over time
3. Elasticsearch configured to prevent memory swapping to disk
4. Elasticsearch configured in a highly available manner with sane defaults


Implementation
==============

Assignee(s)
-----------

Primary assignees:
  srwilker (Steve Wilkerson)
  portdirect (Pete Birley)
  lr699s (Larry Rensing)


Work Items
----------

1. Fluentd chart
2. Elasticsearch chart
3. Kibana chart
4. Prometheus chart
5. Alertmanager chart
6. Grafana chart
7. Charts for exporters: kube-state-metrics, ceph-exporter, openstack-exporter?

All charts should follow design approaches applied to all other OpenStack-Helm
charts, including the use of helm-toolkit.

All charts require valid and sensible default values to provide operational
value out of the box.

Testing
=======
Testing should include Helm tests for each of the included charts as well as an
integration test in the gate.


Documentation Impact
====================
Documentation should be included for each of the included charts as well as
documentation detailing the requirements for a usable monitoring platform,
preferably with sane default values out of the box.
