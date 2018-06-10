Fluentd-logging
===============

OpenStack-Helm defines a centralized logging mechanism to provide insight into
the state of the OpenStack services and infrastructure components as
well as underlying kubernetes platform. Among the requirements for a logging
platform, where log data can come from and where log data need to be delivered
are very variable. To support various logging scenarios, OpenStack-Helm should
provide a flexible mechanism to meet with certain operation needs. This chart
proposes fast and lightweight log forwarder and full featured log aggregator
complementing each other providing a flexible and reliable solution. Especially,
Fluent-bit is proposed as a log forwarder and Fluentd is proposed as a main log
aggregator and processor.


Mechanism
---------

Fluent-bit, Fluentd meet OpenStack-Helm's logging requirements for gathering,
aggregating, and delivering of logged events. Flunt-bit runs as a daemonset on
each node and mounts the /var/lib/docker/containers directory. The Docker
container runtime engine directs events posted to stdout and stderr to this
directory on the host. Fluent-bit then forward the contents of that directory to
Fluentd. Fluentd runs as deployment at the designated nodes and expose service
for Fluent-bit to foward logs. Fluentd should then apply the Logstash format to
the logs. Fluentd can also write kubernetes and OpenStack metadata to the logs.
Fluentd will then forward the results to Elasticsearch and to optionally kafka.
Elasticsearch indexes the logs in a logstash-* index by default. kafka stores
the logs in a 'logs' topic by default. Any external tool can then consume the
'logs' topic.
