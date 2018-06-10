..
 This work is licensed under a Creative Commons Attribution 3.0 Unported
 License.

 http://creativecommons.org/licenses/by/3.0/legalcode
..

======================================
fluentbit-fluentd logging architecture
======================================

Blueprints:
1. osh-logging-framework_

.. _osh-logging-framework: https://blueprints.launchpad.net/openstack-helm/+spec/osh-logging-framework

Releated Specs:
1. OSH logging monitoring and alerting: https://review.openstack.org/#/c/482687/


Problem Description
===================

OpenStack-Helm defines a centralized logging mechanism to provide insight into
the state of the OpenStack services and infrastructure components as
well as underlying Kubernetes platform. Among the requirements for a logging
platform, where log data can come from and where log data need to be delivered
are very variable. To support various logging scenarios, OpenStack-Helm should
provide a flexible mechanism to meet with certain operation needs. This spec
proposes fast and lightweight log forwarder and full featured log aggregator
complementing each other providing a flexible and reliable solution. Especially,
Fluentbit is proposed as a log forwarder and Fluentd is proposed as a main log
aggregator and processor.

Platform Requirements
=====================

Logging Requirements
--------------------

The requirements for a logging collector/aggregator include:

1. Log collection daemon runs on each node to forward logs to aggregator
2. Log collection daemon should have a minimal server footprint
3. Log aggregator deployment runs on a selected node as deployment
4. Ability to apply custom metadata and uniform format to logs
5. Log aggregator should have HA capability
6. Log aggregator should have a flexible output capability to choose from
7. Log aggregator is able to send data to Elasticsearch and Kafka
8. Log aggregator should be scalable

Logical Diagram
---------------

1. diagram link: https://github.com/sktelecom-oslab/docs/blob/master/images/fluentbit-fluentd-diagram.png

Use Cases
=========

Logging Use Cases
-----------------

Example uses for centralized logging with Fluentbit and Fluentd include:

1. Cover the following logging use cases https://review.openstack.org/#/c/482687/
2. Collect logs from the node by Fluentbit
3. Every Fluentbit send logs to Fluentd with Kubernetes metadata attached
4. Fluentd then attaches Kubernetes and/or OpenStack metadata
5. Fluentd properly filters and categorizes logs
6. Fluentd send aggregated logs to Elasticsearch for the internal use cases
7. Aggregator also send aggregated logs to Kafka for external tools to consume


Proposed Change
===============

Logging
-------

Fluentbit, Fluentd meet OpenStack-Helm's logging requirements for gathering,
aggregating, and delivering of logged events. Fluntbit runs as a daemonset on
each node and mounts the /var/lib/docker/containers directory. The Docker
container runtime engine directs events posted to stdout and stderr to this
directory on the host. Fluentbit then forward the contents of that directory to
Fluentd. Fluentd runs as deployment at the designated nodes and expose service
for Fluentbit to forward logs. Fluentd should then apply the Logstash format to
the logs. Fluentd can also write Kubernetes and OpenStack metadata to the logs.
Fluentd will then forward the results to Elasticsearch and to optionally Kafka.
Elasticsearch indexes the logs in a logstash-* index by default. Kafka stores
the logs in a 'logs' topic by default. Any external tool can then consume the
'logs' topic.

The proposal includes the following:

1. Helm chart for Fluentbit-Fluentd Combination

The above chart must include sensible configuration values to make the logging
platform usable by default. These include: proper input configurations for both
Fluentbit and Fluentd, proper output configurations for both Fluentbit and
Fluentd, proper metadata and formats applied to the logs via Fluentd.


Security Impact
---------------

All services running within the platform should be subject to the
security practices applied to the other OpenStack-Helm charts.

Performance Impact
------------------

To minimize the performance impacts, the following should be considered:

1. Sane defaults for log retention and rotation policies

Implementation
==============

Assignee(s)
-----------

Primary assignees:
  sungil (Sungil Im)
  jayahn (Jaesuk Ahn)

Work Items
----------

1. Fluentbit-Fluentd logging chart

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
