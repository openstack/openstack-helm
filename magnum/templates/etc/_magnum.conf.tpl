{{/*
Copyright 2017 The Openstack-Helm Authors.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/}}

{{ include "magnum.conf.magnum_values_skeleton" .Values.conf.magnum | trunc 0 }}
{{ include "magnum.conf.magnum" .Values.conf.magnum }}


{{- define "magnum.conf.magnum_values_skeleton" -}}

{{- if not .default -}}{{- set . "default" dict -}}{{- end -}}
{{- if not .default.magnum -}}{{- set .default "magnum" dict -}}{{- end -}}
{{- if not .default.oslo -}}{{- set .default "oslo" dict -}}{{- end -}}
{{- if not .default.oslo.log -}}{{- set .default.oslo "log" dict -}}{{- end -}}
{{- if not .default.oslo.messaging -}}{{- set .default.oslo "messaging" dict -}}{{- end -}}
{{- if not .default.oslo.service -}}{{- set .default.oslo "service" dict -}}{{- end -}}
{{- if not .default.oslo.service.periodic_task -}}{{- set .default.oslo.service "periodic_task" dict -}}{{- end -}}
{{- if not .default.oslo.service.service -}}{{- set .default.oslo.service "service" dict -}}{{- end -}}
{{- if not .api -}}{{- set . "api" dict -}}{{- end -}}
{{- if not .api.magnum -}}{{- set .api "magnum" dict -}}{{- end -}}
{{- if not .barbican_client -}}{{- set . "barbican_client" dict -}}{{- end -}}
{{- if not .barbican_client.magnum -}}{{- set .barbican_client "magnum" dict -}}{{- end -}}
{{- if not .certificates -}}{{- set . "certificates" dict -}}{{- end -}}
{{- if not .certificates.magnum -}}{{- set .certificates "magnum" dict -}}{{- end -}}
{{- if not .cinder_client -}}{{- set . "cinder_client" dict -}}{{- end -}}
{{- if not .cinder_client.magnum -}}{{- set .cinder_client "magnum" dict -}}{{- end -}}
{{- if not .cluster -}}{{- set . "cluster" dict -}}{{- end -}}
{{- if not .cluster.magnum -}}{{- set .cluster "magnum" dict -}}{{- end -}}
{{- if not .cluster_heat -}}{{- set . "cluster_heat" dict -}}{{- end -}}
{{- if not .cluster_heat.magnum -}}{{- set .cluster_heat "magnum" dict -}}{{- end -}}
{{- if not .cluster_template -}}{{- set . "cluster_template" dict -}}{{- end -}}
{{- if not .cluster_template.magnum -}}{{- set .cluster_template "magnum" dict -}}{{- end -}}
{{- if not .conductor -}}{{- set . "conductor" dict -}}{{- end -}}
{{- if not .conductor.magnum -}}{{- set .conductor "magnum" dict -}}{{- end -}}
{{- if not .cors -}}{{- set . "cors" dict -}}{{- end -}}
{{- if not .cors.oslo -}}{{- set .cors "oslo" dict -}}{{- end -}}
{{- if not .cors.oslo.middleware -}}{{- set .cors.oslo "middleware" dict -}}{{- end -}}
{{- if not .cors.oslo.middleware.cors -}}{{- set .cors.oslo.middleware "cors" dict -}}{{- end -}}
{{- if not .cors.subdomain -}}{{- set .cors "subdomain" dict -}}{{- end -}}
{{- if not .cors.subdomain.oslo -}}{{- set .cors.subdomain "oslo" dict -}}{{- end -}}
{{- if not .cors.subdomain.oslo.middleware -}}{{- set .cors.subdomain.oslo "middleware" dict -}}{{- end -}}
{{- if not .cors.subdomain.oslo.middleware.cors -}}{{- set .cors.subdomain.oslo.middleware "cors" dict -}}{{- end -}}
{{- if not .database -}}{{- set . "database" dict -}}{{- end -}}
{{- if not .database.magnum -}}{{- set .database "magnum" dict -}}{{- end -}}
{{- if not .database.oslo -}}{{- set .database "oslo" dict -}}{{- end -}}
{{- if not .database.oslo.db -}}{{- set .database.oslo "db" dict -}}{{- end -}}
{{- if not .docker -}}{{- set . "docker" dict -}}{{- end -}}
{{- if not .docker.magnum -}}{{- set .docker "magnum" dict -}}{{- end -}}
{{- if not .docker_registry -}}{{- set . "docker_registry" dict -}}{{- end -}}
{{- if not .docker_registry.magnum -}}{{- set .docker_registry "magnum" dict -}}{{- end -}}
{{- if not .glance_client -}}{{- set . "glance_client" dict -}}{{- end -}}
{{- if not .glance_client.magnum -}}{{- set .glance_client "magnum" dict -}}{{- end -}}
{{- if not .heat_client -}}{{- set . "heat_client" dict -}}{{- end -}}
{{- if not .heat_client.magnum -}}{{- set .heat_client "magnum" dict -}}{{- end -}}
{{- if not .keystone_auth -}}{{- set . "keystone_auth" dict -}}{{- end -}}
{{- if not .keystone_auth.magnum -}}{{- set .keystone_auth "magnum" dict -}}{{- end -}}
{{- if not .keystone_authtoken -}}{{- set . "keystone_authtoken" dict -}}{{- end -}}
{{- if not .keystone_authtoken.keystonemiddleware -}}{{- set .keystone_authtoken "keystonemiddleware" dict -}}{{- end -}}
{{- if not .keystone_authtoken.keystonemiddleware.auth_token -}}{{- set .keystone_authtoken.keystonemiddleware "auth_token" dict -}}{{- end -}}
{{- if not .magnum_client -}}{{- set . "magnum_client" dict -}}{{- end -}}
{{- if not .magnum_client.magnum -}}{{- set .magnum_client "magnum" dict -}}{{- end -}}
{{- if not .matchmaker_redis -}}{{- set . "matchmaker_redis" dict -}}{{- end -}}
{{- if not .matchmaker_redis.oslo -}}{{- set .matchmaker_redis "oslo" dict -}}{{- end -}}
{{- if not .matchmaker_redis.oslo.messaging -}}{{- set .matchmaker_redis.oslo "messaging" dict -}}{{- end -}}
{{- if not .neutron_client -}}{{- set . "neutron_client" dict -}}{{- end -}}
{{- if not .neutron_client.magnum -}}{{- set .neutron_client "magnum" dict -}}{{- end -}}
{{- if not .nova_client -}}{{- set . "nova_client" dict -}}{{- end -}}
{{- if not .nova_client.magnum -}}{{- set .nova_client "magnum" dict -}}{{- end -}}
{{- if not .oslo_concurrency -}}{{- set . "oslo_concurrency" dict -}}{{- end -}}
{{- if not .oslo_concurrency.oslo -}}{{- set .oslo_concurrency "oslo" dict -}}{{- end -}}
{{- if not .oslo_concurrency.oslo.concurrency -}}{{- set .oslo_concurrency.oslo "concurrency" dict -}}{{- end -}}
{{- if not .oslo_messaging_amqp -}}{{- set . "oslo_messaging_amqp" dict -}}{{- end -}}
{{- if not .oslo_messaging_amqp.oslo -}}{{- set .oslo_messaging_amqp "oslo" dict -}}{{- end -}}
{{- if not .oslo_messaging_amqp.oslo.messaging -}}{{- set .oslo_messaging_amqp.oslo "messaging" dict -}}{{- end -}}
{{- if not .oslo_messaging_notifications -}}{{- set . "oslo_messaging_notifications" dict -}}{{- end -}}
{{- if not .oslo_messaging_notifications.oslo -}}{{- set .oslo_messaging_notifications "oslo" dict -}}{{- end -}}
{{- if not .oslo_messaging_notifications.oslo.messaging -}}{{- set .oslo_messaging_notifications.oslo "messaging" dict -}}{{- end -}}
{{- if not .oslo_messaging_rabbit -}}{{- set . "oslo_messaging_rabbit" dict -}}{{- end -}}
{{- if not .oslo_messaging_rabbit.oslo -}}{{- set .oslo_messaging_rabbit "oslo" dict -}}{{- end -}}
{{- if not .oslo_messaging_rabbit.oslo.messaging -}}{{- set .oslo_messaging_rabbit.oslo "messaging" dict -}}{{- end -}}
{{- if not .oslo_messaging_zmq -}}{{- set . "oslo_messaging_zmq" dict -}}{{- end -}}
{{- if not .oslo_messaging_zmq.oslo -}}{{- set .oslo_messaging_zmq "oslo" dict -}}{{- end -}}
{{- if not .oslo_messaging_zmq.oslo.messaging -}}{{- set .oslo_messaging_zmq.oslo "messaging" dict -}}{{- end -}}
{{- if not .oslo_policy -}}{{- set . "oslo_policy" dict -}}{{- end -}}
{{- if not .oslo_policy.oslo -}}{{- set .oslo_policy "oslo" dict -}}{{- end -}}
{{- if not .oslo_policy.oslo.policy -}}{{- set .oslo_policy.oslo "policy" dict -}}{{- end -}}
{{- if not .trust -}}{{- set . "trust" dict -}}{{- end -}}
{{- if not .trust.magnum -}}{{- set .trust "magnum" dict -}}{{- end -}}
{{- if not .x509 -}}{{- set . "x509" dict -}}{{- end -}}
{{- if not .x509.magnum -}}{{- set .x509 "magnum" dict -}}{{- end -}}

{{- end -}}


{{- define "magnum.conf.magnum" -}}

[DEFAULT]

#
# From magnum
#

# Directory where the magnum python module is installed. (string value)
# from .default.magnum.pybasedir
{{ if not .default.magnum.pybasedir }}#{{ end }}pybasedir = {{ .default.magnum.pybasedir | default "/tmp/magnum/magnum" }}

# Directory where magnum binaries are installed. (string value)
# from .default.magnum.bindir
{{ if not .default.magnum.bindir }}#{{ end }}bindir = {{ .default.magnum.bindir | default "$pybasedir/bin" }}

# Top-level directory for maintaining magnum's state. (string value)
# from .default.magnum.state_path
{{ if not .default.magnum.state_path }}#{{ end }}state_path = {{ .default.magnum.state_path | default "$pybasedir" }}

# Path to the rootwrap configuration file to use for running commands as root.
# (string value)
# from .default.magnum.rootwrap_config
{{ if not .default.magnum.rootwrap_config }}#{{ end }}rootwrap_config = {{ .default.magnum.rootwrap_config | default "/etc/magnum/rootwrap.conf" }}

# Explicitly specify the temporary working directory. (string value)
# from .default.magnum.tempdir
{{ if not .default.magnum.tempdir }}#{{ end }}tempdir = {{ .default.magnum.tempdir | default "<None>" }}

# Symbols to use for passwords (list value)
# from .default.magnum.password_symbols
{{ if not .default.magnum.password_symbols }}#{{ end }}password_symbols = {{ .default.magnum.password_symbols | default "23456789,ABCDEFGHJKLMNPQRSTUVWXYZ,abcdefghijkmnopqrstuvwxyz" }}

# List Heat stacks globally when syncing clusters. Default is to do retrieve
# each cluster's stack  individually. Reduces number of requests against Heat
# API if enabled but requires changes to Heat's policy.json. (boolean value)
# from .default.magnum.periodic_global_stack_list
{{ if not .default.magnum.periodic_global_stack_list }}#{{ end }}periodic_global_stack_list = {{ .default.magnum.periodic_global_stack_list | default "false" }}

# Enable periodic tasks. (boolean value)
# from .default.magnum.periodic_enable
{{ if not .default.magnum.periodic_enable }}#{{ end }}periodic_enable = {{ .default.magnum.periodic_enable | default "true" }}

# Max interval size between periodic tasks execution in seconds. (integer
# value)
# from .default.magnum.periodic_interval_max
{{ if not .default.magnum.periodic_interval_max }}#{{ end }}periodic_interval_max = {{ .default.magnum.periodic_interval_max | default "60" }}

# Name of this node. This can be an opaque identifier. It is not necessarily a
# hostname, FQDN, or IP address. However, the node name must be valid within an
# AMQP key, and if using ZeroMQ, a valid hostname, FQDN, or IP address. (string
# value)
# from .default.magnum.host
{{ if not .default.magnum.host }}#{{ end }}host = {{ .default.magnum.host | default "<None>" }}

#
# From oslo.log
#

# If set to true, the logging level will be set to DEBUG instead of the default
# INFO level. (boolean value)
# Note: This option can be changed without restarting.
# from .default.oslo.log.debug
{{ if not .default.oslo.log.debug }}#{{ end }}debug = {{ .default.oslo.log.debug | default "false" }}

# DEPRECATED: If set to false, the logging level will be set to WARNING instead
# of the default INFO level. (boolean value)
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# from .default.oslo.log.verbose
{{ if not .default.oslo.log.verbose }}#{{ end }}verbose = {{ .default.oslo.log.verbose | default "true" }}

# The name of a logging configuration file. This file is appended to any
# existing logging configuration files. For details about logging configuration
# files, see the Python logging module documentation. Note that when logging
# configuration files are used then all logging configuration is set in the
# configuration file and other logging configuration options are ignored (for
# example, logging_context_format_string). (string value)
# Note: This option can be changed without restarting.
# Deprecated group/name - [DEFAULT]/log_config
# from .default.oslo.log.log_config_append
{{ if not .default.oslo.log.log_config_append }}#{{ end }}log_config_append = {{ .default.oslo.log.log_config_append | default "<None>" }}

# Defines the format string for %%(asctime)s in log records. Default:
# %(default)s . This option is ignored if log_config_append is set. (string
# value)
# from .default.oslo.log.log_date_format
{{ if not .default.oslo.log.log_date_format }}#{{ end }}log_date_format = {{ .default.oslo.log.log_date_format | default "%Y-%m-%d %H:%M:%S" }}

# (Optional) Name of log file to send logging output to. If no default is set,
# logging will go to stderr as defined by use_stderr. This option is ignored if
# log_config_append is set. (string value)
# Deprecated group/name - [DEFAULT]/logfile
# from .default.oslo.log.log_file
{{ if not .default.oslo.log.log_file }}#{{ end }}log_file = {{ .default.oslo.log.log_file | default "<None>" }}

# (Optional) The base directory used for relative log_file  paths. This option
# is ignored if log_config_append is set. (string value)
# Deprecated group/name - [DEFAULT]/logdir
# from .default.oslo.log.log_dir
{{ if not .default.oslo.log.log_dir }}#{{ end }}log_dir = {{ .default.oslo.log.log_dir | default "<None>" }}

# Uses logging handler designed to watch file system. When log file is moved or
# removed this handler will open a new log file with specified path
# instantaneously. It makes sense only if log_file option is specified and
# Linux platform is used. This option is ignored if log_config_append is set.
# (boolean value)
# from .default.oslo.log.watch_log_file
{{ if not .default.oslo.log.watch_log_file }}#{{ end }}watch_log_file = {{ .default.oslo.log.watch_log_file | default "false" }}

# Use syslog for logging. Existing syslog format is DEPRECATED and will be
# changed later to honor RFC5424. This option is ignored if log_config_append
# is set. (boolean value)
# from .default.oslo.log.use_syslog
{{ if not .default.oslo.log.use_syslog }}#{{ end }}use_syslog = {{ .default.oslo.log.use_syslog | default "false" }}

# Syslog facility to receive log lines. This option is ignored if
# log_config_append is set. (string value)
# from .default.oslo.log.syslog_log_facility
{{ if not .default.oslo.log.syslog_log_facility }}#{{ end }}syslog_log_facility = {{ .default.oslo.log.syslog_log_facility | default "LOG_USER" }}

# Log output to standard error. This option is ignored if log_config_append is
# set. (boolean value)
# from .default.oslo.log.use_stderr
{{ if not .default.oslo.log.use_stderr }}#{{ end }}use_stderr = {{ .default.oslo.log.use_stderr | default "true" }}

# Format string to use for log messages with context. (string value)
# from .default.oslo.log.logging_context_format_string
{{ if not .default.oslo.log.logging_context_format_string }}#{{ end }}logging_context_format_string = {{ .default.oslo.log.logging_context_format_string | default "%(asctime)s.%(msecs)03d %(process)d %(levelname)s %(name)s [%(request_id)s %(user_identity)s] %(instance)s%(message)s" }}

# Format string to use for log messages when context is undefined. (string
# value)
# from .default.oslo.log.logging_default_format_string
{{ if not .default.oslo.log.logging_default_format_string }}#{{ end }}logging_default_format_string = {{ .default.oslo.log.logging_default_format_string | default "%(asctime)s.%(msecs)03d %(process)d %(levelname)s %(name)s [-] %(instance)s%(message)s" }}

# Additional data to append to log message when logging level for the message
# is DEBUG. (string value)
# from .default.oslo.log.logging_debug_format_suffix
{{ if not .default.oslo.log.logging_debug_format_suffix }}#{{ end }}logging_debug_format_suffix = {{ .default.oslo.log.logging_debug_format_suffix | default "%(funcName)s %(pathname)s:%(lineno)d" }}

# Prefix each line of exception output with this format. (string value)
# from .default.oslo.log.logging_exception_prefix
{{ if not .default.oslo.log.logging_exception_prefix }}#{{ end }}logging_exception_prefix = {{ .default.oslo.log.logging_exception_prefix | default "%(asctime)s.%(msecs)03d %(process)d ERROR %(name)s %(instance)s" }}

# Defines the format string for %(user_identity)s that is used in
# logging_context_format_string. (string value)
# from .default.oslo.log.logging_user_identity_format
{{ if not .default.oslo.log.logging_user_identity_format }}#{{ end }}logging_user_identity_format = {{ .default.oslo.log.logging_user_identity_format | default "%(user)s %(tenant)s %(domain)s %(user_domain)s %(project_domain)s" }}

# List of package logging levels in logger=LEVEL pairs. This option is ignored
# if log_config_append is set. (list value)
# from .default.oslo.log.default_log_levels
{{ if not .default.oslo.log.default_log_levels }}#{{ end }}default_log_levels = {{ .default.oslo.log.default_log_levels | default "amqp=WARN,amqplib=WARN,boto=WARN,qpid=WARN,sqlalchemy=WARN,suds=INFO,oslo.messaging=INFO,iso8601=WARN,requests.packages.urllib3.connectionpool=WARN,urllib3.connectionpool=WARN,websocket=WARN,requests.packages.urllib3.util.retry=WARN,urllib3.util.retry=WARN,keystonemiddleware=WARN,routes.middleware=WARN,stevedore=WARN,taskflow=WARN,keystoneauth=WARN,oslo.cache=INFO,dogpile.core.dogpile=INFO" }}

# Enables or disables publication of error events. (boolean value)
# from .default.oslo.log.publish_errors
{{ if not .default.oslo.log.publish_errors }}#{{ end }}publish_errors = {{ .default.oslo.log.publish_errors | default "false" }}

# The format for an instance that is passed with the log message. (string
# value)
# from .default.oslo.log.instance_format
{{ if not .default.oslo.log.instance_format }}#{{ end }}instance_format = {{ .default.oslo.log.instance_format | default "\"[instance: %(uuid)s] \"" }}

# The format for an instance UUID that is passed with the log message. (string
# value)
# from .default.oslo.log.instance_uuid_format
{{ if not .default.oslo.log.instance_uuid_format }}#{{ end }}instance_uuid_format = {{ .default.oslo.log.instance_uuid_format | default "\"[instance: %(uuid)s] \"" }}

# Enables or disables fatal status of deprecations. (boolean value)
# from .default.oslo.log.fatal_deprecations
{{ if not .default.oslo.log.fatal_deprecations }}#{{ end }}fatal_deprecations = {{ .default.oslo.log.fatal_deprecations | default "false" }}

#
# From oslo.messaging
#

# Size of RPC connection pool. (integer value)
# Deprecated group/name - [DEFAULT]/rpc_conn_pool_size
# from .default.oslo.messaging.rpc_conn_pool_size
{{ if not .default.oslo.messaging.rpc_conn_pool_size }}#{{ end }}rpc_conn_pool_size = {{ .default.oslo.messaging.rpc_conn_pool_size | default "30" }}

# The pool size limit for connections expiration policy (integer value)
# from .default.oslo.messaging.conn_pool_min_size
{{ if not .default.oslo.messaging.conn_pool_min_size }}#{{ end }}conn_pool_min_size = {{ .default.oslo.messaging.conn_pool_min_size | default "2" }}

# The time-to-live in sec of idle connections in the pool (integer value)
# from .default.oslo.messaging.conn_pool_ttl
{{ if not .default.oslo.messaging.conn_pool_ttl }}#{{ end }}conn_pool_ttl = {{ .default.oslo.messaging.conn_pool_ttl | default "1200" }}

# ZeroMQ bind address. Should be a wildcard (*), an ethernet interface, or IP.
# The "host" option should point or resolve to this address. (string value)
# Deprecated group/name - [DEFAULT]/rpc_zmq_bind_address
# from .default.oslo.messaging.rpc_zmq_bind_address
{{ if not .default.oslo.messaging.rpc_zmq_bind_address }}#{{ end }}rpc_zmq_bind_address = {{ .default.oslo.messaging.rpc_zmq_bind_address | default "*" }}

# MatchMaker driver. (string value)
# Allowed values: redis, dummy
# Deprecated group/name - [DEFAULT]/rpc_zmq_matchmaker
# from .default.oslo.messaging.rpc_zmq_matchmaker
{{ if not .default.oslo.messaging.rpc_zmq_matchmaker }}#{{ end }}rpc_zmq_matchmaker = {{ .default.oslo.messaging.rpc_zmq_matchmaker | default "redis" }}

# Number of ZeroMQ contexts, defaults to 1. (integer value)
# Deprecated group/name - [DEFAULT]/rpc_zmq_contexts
# from .default.oslo.messaging.rpc_zmq_contexts
{{ if not .default.oslo.messaging.rpc_zmq_contexts }}#{{ end }}rpc_zmq_contexts = {{ .default.oslo.messaging.rpc_zmq_contexts | default "1" }}

# Maximum number of ingress messages to locally buffer per topic. Default is
# unlimited. (integer value)
# Deprecated group/name - [DEFAULT]/rpc_zmq_topic_backlog
# from .default.oslo.messaging.rpc_zmq_topic_backlog
{{ if not .default.oslo.messaging.rpc_zmq_topic_backlog }}#{{ end }}rpc_zmq_topic_backlog = {{ .default.oslo.messaging.rpc_zmq_topic_backlog | default "<None>" }}

# Directory for holding IPC sockets. (string value)
# Deprecated group/name - [DEFAULT]/rpc_zmq_ipc_dir
# from .default.oslo.messaging.rpc_zmq_ipc_dir
{{ if not .default.oslo.messaging.rpc_zmq_ipc_dir }}#{{ end }}rpc_zmq_ipc_dir = {{ .default.oslo.messaging.rpc_zmq_ipc_dir | default "/var/run/openstack" }}

# Name of this node. Must be a valid hostname, FQDN, or IP address. Must match
# "host" option, if running Nova. (string value)
# Deprecated group/name - [DEFAULT]/rpc_zmq_host
# from .default.oslo.messaging.rpc_zmq_host
{{ if not .default.oslo.messaging.rpc_zmq_host }}#{{ end }}rpc_zmq_host = {{ .default.oslo.messaging.rpc_zmq_host | default "localhost" }}

# Seconds to wait before a cast expires (TTL). The default value of -1
# specifies an infinite linger period. The value of 0 specifies no linger
# period. Pending messages shall be discarded immediately when the socket is
# closed. Only supported by impl_zmq. (integer value)
# Deprecated group/name - [DEFAULT]/rpc_cast_timeout
# from .default.oslo.messaging.rpc_cast_timeout
{{ if not .default.oslo.messaging.rpc_cast_timeout }}#{{ end }}rpc_cast_timeout = {{ .default.oslo.messaging.rpc_cast_timeout | default "-1" }}

# The default number of seconds that poll should wait. Poll raises timeout
# exception when timeout expired. (integer value)
# Deprecated group/name - [DEFAULT]/rpc_poll_timeout
# from .default.oslo.messaging.rpc_poll_timeout
{{ if not .default.oslo.messaging.rpc_poll_timeout }}#{{ end }}rpc_poll_timeout = {{ .default.oslo.messaging.rpc_poll_timeout | default "1" }}

# Expiration timeout in seconds of a name service record about existing target
# ( < 0 means no timeout). (integer value)
# Deprecated group/name - [DEFAULT]/zmq_target_expire
# from .default.oslo.messaging.zmq_target_expire
{{ if not .default.oslo.messaging.zmq_target_expire }}#{{ end }}zmq_target_expire = {{ .default.oslo.messaging.zmq_target_expire | default "300" }}

# Update period in seconds of a name service record about existing target.
# (integer value)
# Deprecated group/name - [DEFAULT]/zmq_target_update
# from .default.oslo.messaging.zmq_target_update
{{ if not .default.oslo.messaging.zmq_target_update }}#{{ end }}zmq_target_update = {{ .default.oslo.messaging.zmq_target_update | default "180" }}

# Use PUB/SUB pattern for fanout methods. PUB/SUB always uses proxy. (boolean
# value)
# Deprecated group/name - [DEFAULT]/use_pub_sub
# from .default.oslo.messaging.use_pub_sub
{{ if not .default.oslo.messaging.use_pub_sub }}#{{ end }}use_pub_sub = {{ .default.oslo.messaging.use_pub_sub | default "true" }}

# Use ROUTER remote proxy. (boolean value)
# Deprecated group/name - [DEFAULT]/use_router_proxy
# from .default.oslo.messaging.use_router_proxy
{{ if not .default.oslo.messaging.use_router_proxy }}#{{ end }}use_router_proxy = {{ .default.oslo.messaging.use_router_proxy | default "true" }}

# Minimal port number for random ports range. (port value)
# Minimum value: 0
# Maximum value: 65535
# Deprecated group/name - [DEFAULT]/rpc_zmq_min_port
# from .default.oslo.messaging.rpc_zmq_min_port
{{ if not .default.oslo.messaging.rpc_zmq_min_port }}#{{ end }}rpc_zmq_min_port = {{ .default.oslo.messaging.rpc_zmq_min_port | default "49153" }}

# Maximal port number for random ports range. (integer value)
# Minimum value: 1
# Maximum value: 65536
# Deprecated group/name - [DEFAULT]/rpc_zmq_max_port
# from .default.oslo.messaging.rpc_zmq_max_port
{{ if not .default.oslo.messaging.rpc_zmq_max_port }}#{{ end }}rpc_zmq_max_port = {{ .default.oslo.messaging.rpc_zmq_max_port | default "65536" }}

# Number of retries to find free port number before fail with ZMQBindError.
# (integer value)
# Deprecated group/name - [DEFAULT]/rpc_zmq_bind_port_retries
# from .default.oslo.messaging.rpc_zmq_bind_port_retries
{{ if not .default.oslo.messaging.rpc_zmq_bind_port_retries }}#{{ end }}rpc_zmq_bind_port_retries = {{ .default.oslo.messaging.rpc_zmq_bind_port_retries | default "100" }}

# Default serialization mechanism for serializing/deserializing
# outgoing/incoming messages (string value)
# Allowed values: json, msgpack
# Deprecated group/name - [DEFAULT]/rpc_zmq_serialization
# from .default.oslo.messaging.rpc_zmq_serialization
{{ if not .default.oslo.messaging.rpc_zmq_serialization }}#{{ end }}rpc_zmq_serialization = {{ .default.oslo.messaging.rpc_zmq_serialization | default "json" }}

# This option configures round-robin mode in zmq socket. True means not keeping
# a queue when server side disconnects. False means to keep queue and messages
# even if server is disconnected, when the server appears we send all
# accumulated messages to it. (boolean value)
# from .default.oslo.messaging.zmq_immediate
{{ if not .default.oslo.messaging.zmq_immediate }}#{{ end }}zmq_immediate = {{ .default.oslo.messaging.zmq_immediate | default "false" }}

# Size of executor thread pool. (integer value)
# Deprecated group/name - [DEFAULT]/rpc_thread_pool_size
# from .default.oslo.messaging.executor_thread_pool_size
{{ if not .default.oslo.messaging.executor_thread_pool_size }}#{{ end }}executor_thread_pool_size = {{ .default.oslo.messaging.executor_thread_pool_size | default "64" }}

# Seconds to wait for a response from a call. (integer value)
# from .default.oslo.messaging.rpc_response_timeout
{{ if not .default.oslo.messaging.rpc_response_timeout }}#{{ end }}rpc_response_timeout = {{ .default.oslo.messaging.rpc_response_timeout | default "60" }}

# A URL representing the messaging driver to use and its full configuration.
# (string value)
# from .default.oslo.messaging.transport_url
{{ if not .default.oslo.messaging.transport_url }}#{{ end }}transport_url = {{ .default.oslo.messaging.transport_url | default "<None>" }}

# DEPRECATED: The messaging driver to use, defaults to rabbit. Other drivers
# include amqp and zmq. (string value)
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# Reason: Replaced by [DEFAULT]/transport_url
# from .default.oslo.messaging.rpc_backend
{{ if not .default.oslo.messaging.rpc_backend }}#{{ end }}rpc_backend = {{ .default.oslo.messaging.rpc_backend | default "rabbit" }}

# The default exchange under which topics are scoped. May be overridden by an
# exchange name specified in the transport_url option. (string value)
# from .default.oslo.messaging.control_exchange
{{ if not .default.oslo.messaging.control_exchange }}#{{ end }}control_exchange = {{ .default.oslo.messaging.control_exchange | default "openstack" }}

#
# From oslo.service.periodic_task
#

# Some periodic tasks can be run in a separate process. Should we run them
# here? (boolean value)
# from .default.oslo.service.periodic_task.run_external_periodic_tasks
{{ if not .default.oslo.service.periodic_task.run_external_periodic_tasks }}#{{ end }}run_external_periodic_tasks = {{ .default.oslo.service.periodic_task.run_external_periodic_tasks | default "true" }}

#
# From oslo.service.service
#

# Enable eventlet backdoor.  Acceptable values are 0, <port>, and
# <start>:<end>, where 0 results in listening on a random tcp port number;
# <port> results in listening on the specified port number (and not enabling
# backdoor if that port is in use); and <start>:<end> results in listening on
# the smallest unused port number within the specified range of port numbers.
# The chosen port is displayed in the service's log file. (string value)
# from .default.oslo.service.service.backdoor_port
{{ if not .default.oslo.service.service.backdoor_port }}#{{ end }}backdoor_port = {{ .default.oslo.service.service.backdoor_port | default "<None>" }}

# Enable eventlet backdoor, using the provided path as a unix socket that can
# receive connections. This option is mutually exclusive with 'backdoor_port'
# in that only one should be provided. If both are provided then the existence
# of this option overrides the usage of that option. (string value)
# from .default.oslo.service.service.backdoor_socket
{{ if not .default.oslo.service.service.backdoor_socket }}#{{ end }}backdoor_socket = {{ .default.oslo.service.service.backdoor_socket | default "<None>" }}

# Enables or disables logging values of all registered options when starting a
# service (at DEBUG level). (boolean value)
# from .default.oslo.service.service.log_options
{{ if not .default.oslo.service.service.log_options }}#{{ end }}log_options = {{ .default.oslo.service.service.log_options | default "true" }}

# Specify a timeout after which a gracefully shutdown server will exit. Zero
# value means endless wait. (integer value)
# from .default.oslo.service.service.graceful_shutdown_timeout
{{ if not .default.oslo.service.service.graceful_shutdown_timeout }}#{{ end }}graceful_shutdown_timeout = {{ .default.oslo.service.service.graceful_shutdown_timeout | default "60" }}


[api]

#
# From magnum
#

# The port for the Magnum API server. (port value)
# Minimum value: 0
# Maximum value: 65535
# from .api.magnum.port
{{ if not .api.magnum.port }}#{{ end }}port = {{ .api.magnum.port | default "9511" }}

# The listen IP for the Magnum API server. (IP address value)
# from .api.magnum.host
{{ if not .api.magnum.host }}#{{ end }}host = {{ .api.magnum.host | default "127.0.0.1" }}

# The maximum number of items returned in a single response from a collection
# resource. (integer value)
# from .api.magnum.max_limit
{{ if not .api.magnum.max_limit }}#{{ end }}max_limit = {{ .api.magnum.max_limit | default "1000" }}

# Configuration file for WSGI definition of API. (string value)
# from .api.magnum.api_paste_config
{{ if not .api.magnum.api_paste_config }}#{{ end }}api_paste_config = {{ .api.magnum.api_paste_config | default "api-paste.ini" }}

# This option allows setting path to the SSL certificate of API server.
# (string value)
# from .api.magnum.ssl_cert_file
{{ if not .api.magnum.ssl_cert_file }}#{{ end }}ssl_cert_file = {{ .api.magnum.ssl_cert_file | default "<None>" }}

# This option specifies the path to the file where SSL private key of API
# server is stored when SSL is in effect.  (string value)
# from .api.magnum.ssl_key_file
{{ if not .api.magnum.ssl_key_file }}#{{ end }}ssl_key_file = {{ .api.magnum.ssl_key_file | default "<None>" }}

# Enable SSL Magnum API service (boolean value)
# from .api.magnum.enabled_ssl
{{ if not .api.magnum.enabled_ssl }}#{{ end }}enabled_ssl = {{ .api.magnum.enabled_ssl | default "false" }}


[barbican_client]

#
# From magnum
#

# Region in Identity service catalog to use for communication with the
# OpenStack service. (string value)
# from .barbican_client.magnum.region_name
{{ if not .barbican_client.magnum.region_name }}#{{ end }}region_name = {{ .barbican_client.magnum.region_name | default "<None>" }}

# Type of endpoint in Identity service catalog to use for communication with
# the OpenStack service. (string value)
# from .barbican_client.magnum.endpoint_type
{{ if not .barbican_client.magnum.endpoint_type }}#{{ end }}endpoint_type = {{ .barbican_client.magnum.endpoint_type | default "publicURL" }}


[certificates]

#
# From magnum
#

# Certificate Manager plugin. Defaults to barbican. (string value)
# from .certificates.magnum.cert_manager_type
{{ if not .certificates.magnum.cert_manager_type }}#{{ end }}cert_manager_type = {{ .certificates.magnum.cert_manager_type | default "barbican" }}

# Absolute path of the certificate storage directory. Defaults to
# /var/lib/magnum/certificates/. (string value)
# from .certificates.magnum.storage_path
{{ if not .certificates.magnum.storage_path }}#{{ end }}storage_path = {{ .certificates.magnum.storage_path | default "/var/lib/magnum/certificates/" }}


[cinder_client]

#
# From magnum
#

# Region in Identity service catalog to use for communication with the
# OpenStack service. (string value)
# from .cinder_client.magnum.region_name
{{ if not .cinder_client.magnum.region_name }}#{{ end }}region_name = {{ .cinder_client.magnum.region_name | default "<None>" }}


[cluster]

#
# From magnum
#

# Url for etcd public discovery endpoint. (string value)
# Deprecated group/name - [bay]/etcd_discovery_service_endpoint_format
# from .cluster.magnum.etcd_discovery_service_endpoint_format
{{ if not .cluster.magnum.etcd_discovery_service_endpoint_format }}#{{ end }}etcd_discovery_service_endpoint_format = {{ .cluster.magnum.etcd_discovery_service_endpoint_format | default "https://discovery.etcd.io/new?size=%(size)d" }}

# Enabled cluster definition entry points. (list value)
# Deprecated group/name - [bay]/enabled_definitions
# from .cluster.magnum.enabled_definitions
{{ if not .cluster.magnum.enabled_definitions }}#{{ end }}enabled_definitions = {{ .cluster.magnum.enabled_definitions | default "magnum_vm_atomic_k8s,magnum_bm_fedora_k8s,magnum_vm_coreos_k8s,magnum_vm_atomic_swarm,magnum_vm_ubuntu_mesos" }}


[cluster_heat]

#
# From magnum
#

# Number of attempts to query the Heat stack for finding out the status of the
# created stack and getting template outputs.  This value is ignored during
# cluster creation if timeout is set as the poll will continue until cluster
# creation either ends or times out. (integer value)
# Deprecated group/name - [bay_heat]/max_attempts
# from .cluster_heat.magnum.max_attempts
{{ if not .cluster_heat.magnum.max_attempts }}#{{ end }}max_attempts = {{ .cluster_heat.magnum.max_attempts | default "2000" }}

# Sleep time interval between two attempts of querying the Heat stack.  This
# interval is in seconds. (integer value)
# Deprecated group/name - [bay_heat]/wait_interval
# from .cluster_heat.magnum.wait_interval
{{ if not .cluster_heat.magnum.wait_interval }}#{{ end }}wait_interval = {{ .cluster_heat.magnum.wait_interval | default "1" }}

# The length of time to let cluster creation continue. This interval is in
# minutes. The default is 60 minutes. (integer value)
# Deprecated group/name - [bay_heat]/bay_create_timeout
# from .cluster_heat.magnum.create_timeout
{{ if not .cluster_heat.magnum.create_timeout }}#{{ end }}create_timeout = {{ .cluster_heat.magnum.create_timeout | default "60" }}


[cluster_template]

#
# From magnum
#

# Allowed network drivers for kubernetes cluster-templates. Use 'all' keyword
# to allow all drivers supported for kubernetes cluster-templates. Supported
# network drivers include flannel. (list value)
# Deprecated group/name - [baymodel]/kubernetes_allowed_network_drivers
# from .cluster_template.magnum.kubernetes_allowed_network_drivers
{{ if not .cluster_template.magnum.kubernetes_allowed_network_drivers }}#{{ end }}kubernetes_allowed_network_drivers = {{ .cluster_template.magnum.kubernetes_allowed_network_drivers | default "all" }}

# Default network driver for kubernetes cluster-templates. (string value)
# Deprecated group/name - [baymodel]/kubernetes_default_network_driver
# from .cluster_template.magnum.kubernetes_default_network_driver
{{ if not .cluster_template.magnum.kubernetes_default_network_driver }}#{{ end }}kubernetes_default_network_driver = {{ .cluster_template.magnum.kubernetes_default_network_driver | default "flannel" }}

# Allowed network drivers for docker swarm cluster-templates. Use 'all' keyword
# to allow all drivers supported for swarm cluster-templates. Supported network
# drivers include docker and flannel. (list value)
# Deprecated group/name - [baymodel]/swarm_allowed_network_drivers
# from .cluster_template.magnum.swarm_allowed_network_drivers
{{ if not .cluster_template.magnum.swarm_allowed_network_drivers }}#{{ end }}swarm_allowed_network_drivers = {{ .cluster_template.magnum.swarm_allowed_network_drivers | default "all" }}

# Default network driver for docker swarm cluster-templates. (string value)
# Deprecated group/name - [baymodel]/swarm_default_network_driver
# from .cluster_template.magnum.swarm_default_network_driver
{{ if not .cluster_template.magnum.swarm_default_network_driver }}#{{ end }}swarm_default_network_driver = {{ .cluster_template.magnum.swarm_default_network_driver | default "docker" }}

# Allowed network drivers for mesos cluster-templates. Use 'all' keyword to
# allow all drivers supported for mesos cluster-templates. Supported network
# drivers include docker. (list value)
# Deprecated group/name - [baymodel]/mesos_allowed_network_drivers
# from .cluster_template.magnum.mesos_allowed_network_drivers
{{ if not .cluster_template.magnum.mesos_allowed_network_drivers }}#{{ end }}mesos_allowed_network_drivers = {{ .cluster_template.magnum.mesos_allowed_network_drivers | default "all" }}

# Default network driver for mesos cluster-templates. (string value)
# Deprecated group/name - [baymodel]/mesos_default_network_driver
# from .cluster_template.magnum.mesos_default_network_driver
{{ if not .cluster_template.magnum.mesos_default_network_driver }}#{{ end }}mesos_default_network_driver = {{ .cluster_template.magnum.mesos_default_network_driver | default "docker" }}


[conductor]

#
# From magnum
#

# The queue to add conductor tasks to. (string value)
# from .conductor.magnum.topic
{{ if not .conductor.magnum.topic }}#{{ end }}topic = {{ .conductor.magnum.topic | default "magnum-conductor" }}

# RPC timeout for the conductor liveness check that is used for bay locking.
# (integer value)
# from .conductor.magnum.conductor_life_check_timeout
{{ if not .conductor.magnum.conductor_life_check_timeout }}#{{ end }}conductor_life_check_timeout = {{ .conductor.magnum.conductor_life_check_timeout | default "4" }}


[cors]

#
# From oslo.middleware.cors
#

# Indicate whether this resource may be shared with the domain received in the
# requests "origin" header. Format: "<protocol>://<host>[:<port>]", no trailing
# slash. Example: https://horizon.example.com (list value)
# from .cors.oslo.middleware.cors.allowed_origin
{{ if not .cors.oslo.middleware.cors.allowed_origin }}#{{ end }}allowed_origin = {{ .cors.oslo.middleware.cors.allowed_origin | default "<None>" }}

# Indicate that the actual request can include user credentials (boolean value)
# from .cors.oslo.middleware.cors.allow_credentials
{{ if not .cors.oslo.middleware.cors.allow_credentials }}#{{ end }}allow_credentials = {{ .cors.oslo.middleware.cors.allow_credentials | default "true" }}

# Indicate which headers are safe to expose to the API. Defaults to HTTP Simple
# Headers. (list value)
# from .cors.oslo.middleware.cors.expose_headers
{{ if not .cors.oslo.middleware.cors.expose_headers }}#{{ end }}expose_headers = {{ .cors.oslo.middleware.cors.expose_headers | default "X-Auth-Token,X-Subject-Token,X-Service-Token,X-OpenStack-Request-ID,X-Server-Management-Url" }}

# Maximum cache age of CORS preflight requests. (integer value)
# from .cors.oslo.middleware.cors.max_age
{{ if not .cors.oslo.middleware.cors.max_age }}#{{ end }}max_age = {{ .cors.oslo.middleware.cors.max_age | default "3600" }}

# Indicate which methods can be used during the actual request. (list value)
# from .cors.oslo.middleware.cors.allow_methods
{{ if not .cors.oslo.middleware.cors.allow_methods }}#{{ end }}allow_methods = {{ .cors.oslo.middleware.cors.allow_methods | default "GET,PUT,POST,DELETE,PATCH" }}

# Indicate which header field names may be used during the actual request.
# (list value)
# from .cors.oslo.middleware.cors.allow_headers
{{ if not .cors.oslo.middleware.cors.allow_headers }}#{{ end }}allow_headers = {{ .cors.oslo.middleware.cors.allow_headers | default "X-Auth-Token,X-Identity-Status,X-Roles,X-Service-Catalog,X-User-Id,X-Tenant-Id,X-OpenStack-Request-ID,X-Server-Management-Url" }}


[cors.subdomain]

#
# From oslo.middleware.cors
#

# Indicate whether this resource may be shared with the domain received in the
# requests "origin" header. Format: "<protocol>://<host>[:<port>]", no trailing
# slash. Example: https://horizon.example.com (list value)
# from .cors.subdomain.oslo.middleware.cors.allowed_origin
{{ if not .cors.subdomain.oslo.middleware.cors.allowed_origin }}#{{ end }}allowed_origin = {{ .cors.subdomain.oslo.middleware.cors.allowed_origin | default "<None>" }}

# Indicate that the actual request can include user credentials (boolean value)
# from .cors.subdomain.oslo.middleware.cors.allow_credentials
{{ if not .cors.subdomain.oslo.middleware.cors.allow_credentials }}#{{ end }}allow_credentials = {{ .cors.subdomain.oslo.middleware.cors.allow_credentials | default "true" }}

# Indicate which headers are safe to expose to the API. Defaults to HTTP Simple
# Headers. (list value)
# from .cors.subdomain.oslo.middleware.cors.expose_headers
{{ if not .cors.subdomain.oslo.middleware.cors.expose_headers }}#{{ end }}expose_headers = {{ .cors.subdomain.oslo.middleware.cors.expose_headers | default "X-Auth-Token,X-Subject-Token,X-Service-Token,X-OpenStack-Request-ID,X-Server-Management-Url" }}

# Maximum cache age of CORS preflight requests. (integer value)
# from .cors.subdomain.oslo.middleware.cors.max_age
{{ if not .cors.subdomain.oslo.middleware.cors.max_age }}#{{ end }}max_age = {{ .cors.subdomain.oslo.middleware.cors.max_age | default "3600" }}

# Indicate which methods can be used during the actual request. (list value)
# from .cors.subdomain.oslo.middleware.cors.allow_methods
{{ if not .cors.subdomain.oslo.middleware.cors.allow_methods }}#{{ end }}allow_methods = {{ .cors.subdomain.oslo.middleware.cors.allow_methods | default "GET,PUT,POST,DELETE,PATCH" }}

# Indicate which header field names may be used during the actual request.
# (list value)
# from .cors.subdomain.oslo.middleware.cors.allow_headers
{{ if not .cors.subdomain.oslo.middleware.cors.allow_headers }}#{{ end }}allow_headers = {{ .cors.subdomain.oslo.middleware.cors.allow_headers | default "X-Auth-Token,X-Identity-Status,X-Roles,X-Service-Catalog,X-User-Id,X-Tenant-Id,X-OpenStack-Request-ID,X-Server-Management-Url" }}


[database]

#
# From magnum
#

# MySQL engine to use. (string value)
# from .database.magnum.mysql_engine
{{ if not .database.magnum.mysql_engine }}#{{ end }}mysql_engine = {{ .database.magnum.mysql_engine | default "InnoDB" }}

#
# From oslo.db
#

# DEPRECATED: The file name to use with SQLite. (string value)
# Deprecated group/name - [DEFAULT]/sqlite_db
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# Reason: Should use config option connection or slave_connection to connect
# the database.
# from .database.oslo.db.sqlite_db
{{ if not .database.oslo.db.sqlite_db }}#{{ end }}sqlite_db = {{ .database.oslo.db.sqlite_db | default "oslo.sqlite" }}

# If True, SQLite uses synchronous mode. (boolean value)
# Deprecated group/name - [DEFAULT]/sqlite_synchronous
# from .database.oslo.db.sqlite_synchronous
{{ if not .database.oslo.db.sqlite_synchronous }}#{{ end }}sqlite_synchronous = {{ .database.oslo.db.sqlite_synchronous | default "true" }}

# The back end to use for the database. (string value)
# Deprecated group/name - [DEFAULT]/db_backend
# from .database.oslo.db.backend
{{ if not .database.oslo.db.backend }}#{{ end }}backend = {{ .database.oslo.db.backend | default "sqlalchemy" }}

# The SQLAlchemy connection string to use to connect to the database. (string
# value)
# Deprecated group/name - [DEFAULT]/sql_connection
# Deprecated group/name - [DATABASE]/sql_connection
# Deprecated group/name - [sql]/connection
# from .database.oslo.db.connection
{{ if not .database.oslo.db.connection }}#{{ end }}connection = {{ .database.oslo.db.connection | default "<None>" }}

# The SQLAlchemy connection string to use to connect to the slave database.
# (string value)
# from .database.oslo.db.slave_connection
{{ if not .database.oslo.db.slave_connection }}#{{ end }}slave_connection = {{ .database.oslo.db.slave_connection | default "<None>" }}

# The SQL mode to be used for MySQL sessions. This option, including the
# default, overrides any server-set SQL mode. To use whatever SQL mode is set
# by the server configuration, set this to no value. Example: mysql_sql_mode=
# (string value)
# from .database.oslo.db.mysql_sql_mode
{{ if not .database.oslo.db.mysql_sql_mode }}#{{ end }}mysql_sql_mode = {{ .database.oslo.db.mysql_sql_mode | default "TRADITIONAL" }}

# Timeout before idle SQL connections are reaped. (integer value)
# Deprecated group/name - [DEFAULT]/sql_idle_timeout
# Deprecated group/name - [DATABASE]/sql_idle_timeout
# Deprecated group/name - [sql]/idle_timeout
# from .database.oslo.db.idle_timeout
{{ if not .database.oslo.db.idle_timeout }}#{{ end }}idle_timeout = {{ .database.oslo.db.idle_timeout | default "3600" }}

# Minimum number of SQL connections to keep open in a pool. (integer value)
# Deprecated group/name - [DEFAULT]/sql_min_pool_size
# Deprecated group/name - [DATABASE]/sql_min_pool_size
# from .database.oslo.db.min_pool_size
{{ if not .database.oslo.db.min_pool_size }}#{{ end }}min_pool_size = {{ .database.oslo.db.min_pool_size | default "1" }}

# Maximum number of SQL connections to keep open in a pool. Setting a value of
# 0 indicates no limit. (integer value)
# Deprecated group/name - [DEFAULT]/sql_max_pool_size
# Deprecated group/name - [DATABASE]/sql_max_pool_size
# from .database.oslo.db.max_pool_size
{{ if not .database.oslo.db.max_pool_size }}#{{ end }}max_pool_size = {{ .database.oslo.db.max_pool_size | default "5" }}

# Maximum number of database connection retries during startup. Set to -1 to
# specify an infinite retry count. (integer value)
# Deprecated group/name - [DEFAULT]/sql_max_retries
# Deprecated group/name - [DATABASE]/sql_max_retries
# from .database.oslo.db.max_retries
{{ if not .database.oslo.db.max_retries }}#{{ end }}max_retries = {{ .database.oslo.db.max_retries | default "10" }}

# Interval between retries of opening a SQL connection. (integer value)
# Deprecated group/name - [DEFAULT]/sql_retry_interval
# Deprecated group/name - [DATABASE]/reconnect_interval
# from .database.oslo.db.retry_interval
{{ if not .database.oslo.db.retry_interval }}#{{ end }}retry_interval = {{ .database.oslo.db.retry_interval | default "10" }}

# If set, use this value for max_overflow with SQLAlchemy. (integer value)
# Deprecated group/name - [DEFAULT]/sql_max_overflow
# Deprecated group/name - [DATABASE]/sqlalchemy_max_overflow
# from .database.oslo.db.max_overflow
{{ if not .database.oslo.db.max_overflow }}#{{ end }}max_overflow = {{ .database.oslo.db.max_overflow | default "50" }}

# Verbosity of SQL debugging information: 0=None, 100=Everything. (integer
# value)
# Minimum value: 0
# Maximum value: 100
# Deprecated group/name - [DEFAULT]/sql_connection_debug
# from .database.oslo.db.connection_debug
{{ if not .database.oslo.db.connection_debug }}#{{ end }}connection_debug = {{ .database.oslo.db.connection_debug | default "0" }}

# Add Python stack traces to SQL as comment strings. (boolean value)
# Deprecated group/name - [DEFAULT]/sql_connection_trace
# from .database.oslo.db.connection_trace
{{ if not .database.oslo.db.connection_trace }}#{{ end }}connection_trace = {{ .database.oslo.db.connection_trace | default "false" }}

# If set, use this value for pool_timeout with SQLAlchemy. (integer value)
# Deprecated group/name - [DATABASE]/sqlalchemy_pool_timeout
# from .database.oslo.db.pool_timeout
{{ if not .database.oslo.db.pool_timeout }}#{{ end }}pool_timeout = {{ .database.oslo.db.pool_timeout | default "<None>" }}

# Enable the experimental use of database reconnect on connection lost.
# (boolean value)
# from .database.oslo.db.use_db_reconnect
{{ if not .database.oslo.db.use_db_reconnect }}#{{ end }}use_db_reconnect = {{ .database.oslo.db.use_db_reconnect | default "false" }}

# Seconds between retries of a database transaction. (integer value)
# from .database.oslo.db.db_retry_interval
{{ if not .database.oslo.db.db_retry_interval }}#{{ end }}db_retry_interval = {{ .database.oslo.db.db_retry_interval | default "1" }}

# If True, increases the interval between retries of a database operation up to
# db_max_retry_interval. (boolean value)
# from .database.oslo.db.db_inc_retry_interval
{{ if not .database.oslo.db.db_inc_retry_interval }}#{{ end }}db_inc_retry_interval = {{ .database.oslo.db.db_inc_retry_interval | default "true" }}

# If db_inc_retry_interval is set, the maximum seconds between retries of a
# database operation. (integer value)
# from .database.oslo.db.db_max_retry_interval
{{ if not .database.oslo.db.db_max_retry_interval }}#{{ end }}db_max_retry_interval = {{ .database.oslo.db.db_max_retry_interval | default "10" }}

# Maximum retries in case of connection error or deadlock error before error is
# raised. Set to -1 to specify an infinite retry count. (integer value)
# from .database.oslo.db.db_max_retries
{{ if not .database.oslo.db.db_max_retries }}#{{ end }}db_max_retries = {{ .database.oslo.db.db_max_retries | default "20" }}


[docker]

#
# From magnum
#

# Docker remote api version. Override it according to specific docker api
# version in your environment. (string value)
# from .docker.magnum.docker_remote_api_version
{{ if not .docker.magnum.docker_remote_api_version }}#{{ end }}docker_remote_api_version = {{ .docker.magnum.docker_remote_api_version | default "1.20" }}

# Default timeout in seconds for docker client operations. (integer value)
# from .docker.magnum.default_timeout
{{ if not .docker.magnum.default_timeout }}#{{ end }}default_timeout = {{ .docker.magnum.default_timeout | default "60" }}

# If set, ignore any SSL validation issues (boolean value)
# from .docker.magnum.api_insecure
{{ if not .docker.magnum.api_insecure }}#{{ end }}api_insecure = {{ .docker.magnum.api_insecure | default "false" }}

# Location of CA certificates file for securing docker api requests
# (tlscacert). (string value)
# from .docker.magnum.ca_file
{{ if not .docker.magnum.ca_file }}#{{ end }}ca_file = {{ .docker.magnum.ca_file | default "<None>" }}

# Location of TLS certificate file for securing docker api requests (tlscert).
# (string value)
# from .docker.magnum.cert_file
{{ if not .docker.magnum.cert_file }}#{{ end }}cert_file = {{ .docker.magnum.cert_file | default "<None>" }}

# Location of TLS private key file for securing docker api requests (tlskey).
# (string value)
# from .docker.magnum.key_file
{{ if not .docker.magnum.key_file }}#{{ end }}key_file = {{ .docker.magnum.key_file | default "<None>" }}


[docker_registry]

#
# From magnum
#

# Region name of Swift (string value)
# from .docker_registry.magnum.swift_region
{{ if not .docker_registry.magnum.swift_region }}#{{ end }}swift_region = {{ .docker_registry.magnum.swift_region | default "<None>" }}

# Name of the container in Swift which docker registry stores images in (string
# value)
# from .docker_registry.magnum.swift_registry_container
{{ if not .docker_registry.magnum.swift_registry_container }}#{{ end }}swift_registry_container = {{ .docker_registry.magnum.swift_registry_container | default "docker_registry" }}


[glance_client]

#
# From magnum
#

# Region in Identity service catalog to use for communication with the
# OpenStack service. (string value)
# from .glance_client.magnum.region_name
{{ if not .glance_client.magnum.region_name }}#{{ end }}region_name = {{ .glance_client.magnum.region_name | default "<None>" }}

# Type of endpoint in Identity service catalog to use for communication with
# the OpenStack service. (string value)
# from .glance_client.magnum.endpoint_type
{{ if not .glance_client.magnum.endpoint_type }}#{{ end }}endpoint_type = {{ .glance_client.magnum.endpoint_type | default "publicURL" }}

# Version of Glance API to use in glanceclient. (string value)
# from .glance_client.magnum.api_version
{{ if not .glance_client.magnum.api_version }}#{{ end }}api_version = {{ .glance_client.magnum.api_version | default "2" }}


[heat_client]

#
# From magnum
#

# Region in Identity service catalog to use for communication with the
# OpenStack service. (string value)
# from .heat_client.magnum.region_name
{{ if not .heat_client.magnum.region_name }}#{{ end }}region_name = {{ .heat_client.magnum.region_name | default "<None>" }}

# Type of endpoint in Identity service catalog to use for communication with
# the OpenStack service. (string value)
# from .heat_client.magnum.endpoint_type
{{ if not .heat_client.magnum.endpoint_type }}#{{ end }}endpoint_type = {{ .heat_client.magnum.endpoint_type | default "publicURL" }}

# Version of Heat API to use in heatclient. (string value)
# from .heat_client.magnum.api_version
{{ if not .heat_client.magnum.api_version }}#{{ end }}api_version = {{ .heat_client.magnum.api_version | default "1" }}


[keystone_auth]

#
# From magnum
#

# Authentication type to load (string value)
# Deprecated group/name - [keystone_auth]/auth_plugin
# from .keystone_auth.magnum.auth_type
{{ if not .keystone_auth.magnum.auth_type }}#{{ end }}auth_type = {{ .keystone_auth.magnum.auth_type | default "<None>" }}

# Config Section from which to load plugin specific options (string value)
# from .keystone_auth.magnum.auth_section
{{ if not .keystone_auth.magnum.auth_section }}#{{ end }}auth_section = {{ .keystone_auth.magnum.auth_section | default "<None>" }}

# Authentication URL (string value)
# from .keystone_auth.magnum.auth_url
{{ if not .keystone_auth.magnum.auth_url }}#{{ end }}auth_url = {{ .keystone_auth.magnum.auth_url | default "<None>" }}

# Domain ID to scope to (string value)
# from .keystone_auth.magnum.domain_id
{{ if not .keystone_auth.magnum.domain_id }}#{{ end }}domain_id = {{ .keystone_auth.magnum.domain_id | default "<None>" }}

# Domain name to scope to (string value)
# from .keystone_auth.magnum.domain_name
{{ if not .keystone_auth.magnum.domain_name }}#{{ end }}domain_name = {{ .keystone_auth.magnum.domain_name | default "<None>" }}

# Project ID to scope to (string value)
# Deprecated group/name - [keystone_auth]/tenant-id
# from .keystone_auth.magnum.project_id
{{ if not .keystone_auth.magnum.project_id }}#{{ end }}project_id = {{ .keystone_auth.magnum.project_id | default "<None>" }}

# Project name to scope to (string value)
# Deprecated group/name - [keystone_auth]/tenant-name
# from .keystone_auth.magnum.project_name
{{ if not .keystone_auth.magnum.project_name }}#{{ end }}project_name = {{ .keystone_auth.magnum.project_name | default "<None>" }}

# Domain ID containing project (string value)
# from .keystone_auth.magnum.project_domain_id
{{ if not .keystone_auth.magnum.project_domain_id }}#{{ end }}project_domain_id = {{ .keystone_auth.magnum.project_domain_id | default "<None>" }}

# Domain name containing project (string value)
# from .keystone_auth.magnum.project_domain_name
{{ if not .keystone_auth.magnum.project_domain_name }}#{{ end }}project_domain_name = {{ .keystone_auth.magnum.project_domain_name | default "<None>" }}

# Trust ID (string value)
# from .keystone_auth.magnum.trust_id
{{ if not .keystone_auth.magnum.trust_id }}#{{ end }}trust_id = {{ .keystone_auth.magnum.trust_id | default "<None>" }}

# Optional domain ID to use with v3 and v2 parameters. It will be used for both
# the user and project domain in v3 and ignored in v2 authentication. (string
# value)
# from .keystone_auth.magnum.default_domain_id
{{ if not .keystone_auth.magnum.default_domain_id }}#{{ end }}default_domain_id = {{ .keystone_auth.magnum.default_domain_id | default "<None>" }}

# Optional domain name to use with v3 API and v2 parameters. It will be used
# for both the user and project domain in v3 and ignored in v2 authentication.
# (string value)
# from .keystone_auth.magnum.default_domain_name
{{ if not .keystone_auth.magnum.default_domain_name }}#{{ end }}default_domain_name = {{ .keystone_auth.magnum.default_domain_name | default "<None>" }}

# User id (string value)
# from .keystone_auth.magnum.user_id
{{ if not .keystone_auth.magnum.user_id }}#{{ end }}user_id = {{ .keystone_auth.magnum.user_id | default "<None>" }}

# Username (string value)
# Deprecated group/name - [keystone_auth]/user-name
# from .keystone_auth.magnum.username
{{ if not .keystone_auth.magnum.username }}#{{ end }}username = {{ .keystone_auth.magnum.username | default "<None>" }}

# User's domain id (string value)
# from .keystone_auth.magnum.user_domain_id
{{ if not .keystone_auth.magnum.user_domain_id }}#{{ end }}user_domain_id = {{ .keystone_auth.magnum.user_domain_id | default "<None>" }}

# User's domain name (string value)
# from .keystone_auth.magnum.user_domain_name
{{ if not .keystone_auth.magnum.user_domain_name }}#{{ end }}user_domain_name = {{ .keystone_auth.magnum.user_domain_name | default "<None>" }}

# User's password (string value)
# from .keystone_auth.magnum.password
{{ if not .keystone_auth.magnum.password }}#{{ end }}password = {{ .keystone_auth.magnum.password | default "<None>" }}


[keystone_authtoken]

# FIXME(alanmeadows) - added the next several lines because oslo gen config refuses to generate the line items required in keystonemiddleware
# for authentication - while it does support an "auth_section" parameter to locate these elsewhere, it would be a strange divergence
# from how neutron keystone authentication is stored today - ocata and later appear to use a "service" user section which can house these details
# and does successfully generate beyond newton, so likely this whole section will be removed the next time we generate this file

{{ if not .keystone_authtoken.keystonemiddleware.auth_token.auth_url }}#{{ end }}auth_url = {{ .keystone_authtoken.keystonemiddleware.auth_token.auth_url | default "<None>" }}
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.region_name }}#{{ end }}region_name = {{ .keystone_authtoken.keystonemiddleware.auth_token.region_name | default "<None>" }}
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.project_name }}#{{ end }}project_name = {{ .keystone_authtoken.keystonemiddleware.auth_token.project_name | default "<None>" }}
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.project_domain_name }}#{{ end }}project_domain_name = {{ .keystone_authtoken.keystonemiddleware.auth_token.project_domain_name | default "<None>" }}
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.user_domain_name }}#{{ end }}user_domain_name = {{ .keystone_authtoken.keystonemiddleware.auth_token.user_domain_name | default "<None>" }}
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.username }}#{{ end }}username = {{ .keystone_authtoken.keystonemiddleware.auth_token.username | default "<None>" }}
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.password }}#{{ end }}password = {{ .keystone_authtoken.keystonemiddleware.auth_token.password | default "<None>" }}

# FIXME(alanmeadows) - added for some newton images using older keystoneauth1 libs but are still "newton"
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.auth_url }}#{{ end }}auth_url = {{ .keystone_authtoken.keystonemiddleware.auth_token.auth_url | default "<None>" }}

#
# From keystonemiddleware.auth_token
#

# Complete "public" Identity API endpoint. This endpoint should not be an
# "admin" endpoint, as it should be accessible by all end users.
# Unauthenticated clients are redirected to this endpoint to authenticate.
# Although this endpoint should  ideally be unversioned, client support in the
# wild varies.  If you're using a versioned v2 endpoint here, then this  should
# *not* be the same endpoint the service user utilizes  for validating tokens,
# because normal end users may not be  able to reach that endpoint. (string
# value)
# from .keystone_authtoken.keystonemiddleware.auth_token.auth_uri
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.auth_uri }}#{{ end }}auth_uri = {{ .keystone_authtoken.keystonemiddleware.auth_token.auth_uri | default "<None>" }}

# API version of the admin Identity API endpoint. (string value)
# from .keystone_authtoken.keystonemiddleware.auth_token.auth_version
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.auth_version }}#{{ end }}auth_version = {{ .keystone_authtoken.keystonemiddleware.auth_token.auth_version | default "<None>" }}

# Do not handle authorization requests within the middleware, but delegate the
# authorization decision to downstream WSGI components. (boolean value)
# from .keystone_authtoken.keystonemiddleware.auth_token.delay_auth_decision
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.delay_auth_decision }}#{{ end }}delay_auth_decision = {{ .keystone_authtoken.keystonemiddleware.auth_token.delay_auth_decision | default "false" }}

# Request timeout value for communicating with Identity API server. (integer
# value)
# from .keystone_authtoken.keystonemiddleware.auth_token.http_connect_timeout
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.http_connect_timeout }}#{{ end }}http_connect_timeout = {{ .keystone_authtoken.keystonemiddleware.auth_token.http_connect_timeout | default "<None>" }}

# How many times are we trying to reconnect when communicating with Identity
# API Server. (integer value)
# from .keystone_authtoken.keystonemiddleware.auth_token.http_request_max_retries
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.http_request_max_retries }}#{{ end }}http_request_max_retries = {{ .keystone_authtoken.keystonemiddleware.auth_token.http_request_max_retries | default "3" }}

# Request environment key where the Swift cache object is stored. When
# auth_token middleware is deployed with a Swift cache, use this option to have
# the middleware share a caching backend with swift. Otherwise, use the
# ``memcached_servers`` option instead. (string value)
# from .keystone_authtoken.keystonemiddleware.auth_token.cache
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.cache }}#{{ end }}cache = {{ .keystone_authtoken.keystonemiddleware.auth_token.cache | default "<None>" }}

# Required if identity server requires client certificate (string value)
# from .keystone_authtoken.keystonemiddleware.auth_token.certfile
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.certfile }}#{{ end }}certfile = {{ .keystone_authtoken.keystonemiddleware.auth_token.certfile | default "<None>" }}

# Required if identity server requires client certificate (string value)
# from .keystone_authtoken.keystonemiddleware.auth_token.keyfile
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.keyfile }}#{{ end }}keyfile = {{ .keystone_authtoken.keystonemiddleware.auth_token.keyfile | default "<None>" }}

# A PEM encoded Certificate Authority to use when verifying HTTPs connections.
# Defaults to system CAs. (string value)
# from .keystone_authtoken.keystonemiddleware.auth_token.cafile
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.cafile }}#{{ end }}cafile = {{ .keystone_authtoken.keystonemiddleware.auth_token.cafile | default "<None>" }}

# Verify HTTPS connections. (boolean value)
# from .keystone_authtoken.keystonemiddleware.auth_token.insecure
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.insecure }}#{{ end }}insecure = {{ .keystone_authtoken.keystonemiddleware.auth_token.insecure | default "false" }}

# The region in which the identity server can be found. (string value)
# from .keystone_authtoken.keystonemiddleware.auth_token.region_name
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.region_name }}#{{ end }}region_name = {{ .keystone_authtoken.keystonemiddleware.auth_token.region_name | default "<None>" }}

# Directory used to cache files related to PKI tokens. (string value)
# from .keystone_authtoken.keystonemiddleware.auth_token.signing_dir
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.signing_dir }}#{{ end }}signing_dir = {{ .keystone_authtoken.keystonemiddleware.auth_token.signing_dir | default "<None>" }}

# Optionally specify a list of memcached server(s) to use for caching. If left
# undefined, tokens will instead be cached in-process. (list value)
# Deprecated group/name - [keystone_authtoken]/memcache_servers
# from .keystone_authtoken.keystonemiddleware.auth_token.memcached_servers
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.memcached_servers }}#{{ end }}memcached_servers = {{ .keystone_authtoken.keystonemiddleware.auth_token.memcached_servers | default "<None>" }}

# In order to prevent excessive effort spent validating tokens, the middleware
# caches previously-seen tokens for a configurable duration (in seconds). Set
# to -1 to disable caching completely. (integer value)
# from .keystone_authtoken.keystonemiddleware.auth_token.token_cache_time
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.token_cache_time }}#{{ end }}token_cache_time = {{ .keystone_authtoken.keystonemiddleware.auth_token.token_cache_time | default "300" }}

# Determines the frequency at which the list of revoked tokens is retrieved
# from the Identity service (in seconds). A high number of revocation events
# combined with a low cache duration may significantly reduce performance. Only
# valid for PKI tokens. (integer value)
# from .keystone_authtoken.keystonemiddleware.auth_token.revocation_cache_time
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.revocation_cache_time }}#{{ end }}revocation_cache_time = {{ .keystone_authtoken.keystonemiddleware.auth_token.revocation_cache_time | default "10" }}

# (Optional) If defined, indicate whether token data should be authenticated or
# authenticated and encrypted. If MAC, token data is authenticated (with HMAC)
# in the cache. If ENCRYPT, token data is encrypted and authenticated in the
# cache. If the value is not one of these options or empty, auth_token will
# raise an exception on initialization. (string value)
# Allowed values: None, MAC, ENCRYPT
# from .keystone_authtoken.keystonemiddleware.auth_token.memcache_security_strategy
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.memcache_security_strategy }}#{{ end }}memcache_security_strategy = {{ .keystone_authtoken.keystonemiddleware.auth_token.memcache_security_strategy | default "None" }}

# (Optional, mandatory if memcache_security_strategy is defined) This string is
# used for key derivation. (string value)
# from .keystone_authtoken.keystonemiddleware.auth_token.memcache_secret_key
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.memcache_secret_key }}#{{ end }}memcache_secret_key = {{ .keystone_authtoken.keystonemiddleware.auth_token.memcache_secret_key | default "<None>" }}

# (Optional) Number of seconds memcached server is considered dead before it is
# tried again. (integer value)
# from .keystone_authtoken.keystonemiddleware.auth_token.memcache_pool_dead_retry
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.memcache_pool_dead_retry }}#{{ end }}memcache_pool_dead_retry = {{ .keystone_authtoken.keystonemiddleware.auth_token.memcache_pool_dead_retry | default "300" }}

# (Optional) Maximum total number of open connections to every memcached
# server. (integer value)
# from .keystone_authtoken.keystonemiddleware.auth_token.memcache_pool_maxsize
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.memcache_pool_maxsize }}#{{ end }}memcache_pool_maxsize = {{ .keystone_authtoken.keystonemiddleware.auth_token.memcache_pool_maxsize | default "10" }}

# (Optional) Socket timeout in seconds for communicating with a memcached
# server. (integer value)
# from .keystone_authtoken.keystonemiddleware.auth_token.memcache_pool_socket_timeout
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.memcache_pool_socket_timeout }}#{{ end }}memcache_pool_socket_timeout = {{ .keystone_authtoken.keystonemiddleware.auth_token.memcache_pool_socket_timeout | default "3" }}

# (Optional) Number of seconds a connection to memcached is held unused in the
# pool before it is closed. (integer value)
# from .keystone_authtoken.keystonemiddleware.auth_token.memcache_pool_unused_timeout
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.memcache_pool_unused_timeout }}#{{ end }}memcache_pool_unused_timeout = {{ .keystone_authtoken.keystonemiddleware.auth_token.memcache_pool_unused_timeout | default "60" }}

# (Optional) Number of seconds that an operation will wait to get a memcached
# client connection from the pool. (integer value)
# from .keystone_authtoken.keystonemiddleware.auth_token.memcache_pool_conn_get_timeout
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.memcache_pool_conn_get_timeout }}#{{ end }}memcache_pool_conn_get_timeout = {{ .keystone_authtoken.keystonemiddleware.auth_token.memcache_pool_conn_get_timeout | default "10" }}

# (Optional) Use the advanced (eventlet safe) memcached client pool. The
# advanced pool will only work under python 2.x. (boolean value)
# from .keystone_authtoken.keystonemiddleware.auth_token.memcache_use_advanced_pool
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.memcache_use_advanced_pool }}#{{ end }}memcache_use_advanced_pool = {{ .keystone_authtoken.keystonemiddleware.auth_token.memcache_use_advanced_pool | default "false" }}

# (Optional) Indicate whether to set the X-Service-Catalog header. If False,
# middleware will not ask for service catalog on token validation and will not
# set the X-Service-Catalog header. (boolean value)
# from .keystone_authtoken.keystonemiddleware.auth_token.include_service_catalog
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.include_service_catalog }}#{{ end }}include_service_catalog = {{ .keystone_authtoken.keystonemiddleware.auth_token.include_service_catalog | default "true" }}

# Used to control the use and type of token binding. Can be set to: "disabled"
# to not check token binding. "permissive" (default) to validate binding
# information if the bind type is of a form known to the server and ignore it
# if not. "strict" like "permissive" but if the bind type is unknown the token
# will be rejected. "required" any form of token binding is needed to be
# allowed. Finally the name of a binding method that must be present in tokens.
# (string value)
# from .keystone_authtoken.keystonemiddleware.auth_token.enforce_token_bind
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.enforce_token_bind }}#{{ end }}enforce_token_bind = {{ .keystone_authtoken.keystonemiddleware.auth_token.enforce_token_bind | default "permissive" }}

# If true, the revocation list will be checked for cached tokens. This requires
# that PKI tokens are configured on the identity server. (boolean value)
# from .keystone_authtoken.keystonemiddleware.auth_token.check_revocations_for_cached
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.check_revocations_for_cached }}#{{ end }}check_revocations_for_cached = {{ .keystone_authtoken.keystonemiddleware.auth_token.check_revocations_for_cached | default "false" }}

# Hash algorithms to use for hashing PKI tokens. This may be a single algorithm
# or multiple. The algorithms are those supported by Python standard
# hashlib.new(). The hashes will be tried in the order given, so put the
# preferred one first for performance. The result of the first hash will be
# stored in the cache. This will typically be set to multiple values only while
# migrating from a less secure algorithm to a more secure one. Once all the old
# tokens are expired this option should be set to a single value for better
# performance. (list value)
# from .keystone_authtoken.keystonemiddleware.auth_token.hash_algorithms
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.hash_algorithms }}#{{ end }}hash_algorithms = {{ .keystone_authtoken.keystonemiddleware.auth_token.hash_algorithms | default "md5" }}

# Authentication type to load (string value)
# Deprecated group/name - [keystone_authtoken]/auth_plugin
# from .keystone_authtoken.keystonemiddleware.auth_token.auth_type
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.auth_type }}#{{ end }}auth_type = {{ .keystone_authtoken.keystonemiddleware.auth_token.auth_type | default "<None>" }}

# Config Section from which to load plugin specific options (string value)
# from .keystone_authtoken.keystonemiddleware.auth_token.auth_section
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.auth_section }}#{{ end }}auth_section = {{ .keystone_authtoken.keystonemiddleware.auth_token.auth_section | default "<None>" }}


[magnum_client]

#
# From magnum
#

# Region in Identity service catalog to use for communication with the
# OpenStack service. (string value)
# from .magnum_client.magnum.region_name
{{ if not .magnum_client.magnum.region_name }}#{{ end }}region_name = {{ .magnum_client.magnum.region_name | default "<None>" }}

# Type of endpoint in Identity service catalog to use for communication with
# the OpenStack service. (string value)
# from .magnum_client.magnum.endpoint_type
{{ if not .magnum_client.magnum.endpoint_type }}#{{ end }}endpoint_type = {{ .magnum_client.magnum.endpoint_type | default "publicURL" }}


[matchmaker_redis]

#
# From oslo.messaging
#

# DEPRECATED: Host to locate redis. (string value)
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# Reason: Replaced by [DEFAULT]/transport_url
# from .matchmaker_redis.oslo.messaging.host
{{ if not .matchmaker_redis.oslo.messaging.host }}#{{ end }}host = {{ .matchmaker_redis.oslo.messaging.host | default "127.0.0.1" }}

# DEPRECATED: Use this port to connect to redis host. (port value)
# Minimum value: 0
# Maximum value: 65535
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# Reason: Replaced by [DEFAULT]/transport_url
# from .matchmaker_redis.oslo.messaging.port
{{ if not .matchmaker_redis.oslo.messaging.port }}#{{ end }}port = {{ .matchmaker_redis.oslo.messaging.port | default "6379" }}

# DEPRECATED: Password for Redis server (optional). (string value)
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# Reason: Replaced by [DEFAULT]/transport_url
# from .matchmaker_redis.oslo.messaging.password
{{ if not .matchmaker_redis.oslo.messaging.password }}#{{ end }}password = {{ .matchmaker_redis.oslo.messaging.password | default "" }}

# DEPRECATED: List of Redis Sentinel hosts (fault tolerance mode) e.g.
# [host:port, host1:port ... ] (list value)
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# Reason: Replaced by [DEFAULT]/transport_url
# from .matchmaker_redis.oslo.messaging.sentinel_hosts
{{ if not .matchmaker_redis.oslo.messaging.sentinel_hosts }}#{{ end }}sentinel_hosts = {{ .matchmaker_redis.oslo.messaging.sentinel_hosts | default "" }}

# Redis replica set name. (string value)
# from .matchmaker_redis.oslo.messaging.sentinel_group_name
{{ if not .matchmaker_redis.oslo.messaging.sentinel_group_name }}#{{ end }}sentinel_group_name = {{ .matchmaker_redis.oslo.messaging.sentinel_group_name | default "oslo-messaging-zeromq" }}

# Time in ms to wait between connection attempts. (integer value)
# from .matchmaker_redis.oslo.messaging.wait_timeout
{{ if not .matchmaker_redis.oslo.messaging.wait_timeout }}#{{ end }}wait_timeout = {{ .matchmaker_redis.oslo.messaging.wait_timeout | default "2000" }}

# Time in ms to wait before the transaction is killed. (integer value)
# from .matchmaker_redis.oslo.messaging.check_timeout
{{ if not .matchmaker_redis.oslo.messaging.check_timeout }}#{{ end }}check_timeout = {{ .matchmaker_redis.oslo.messaging.check_timeout | default "20000" }}

# Timeout in ms on blocking socket operations (integer value)
# from .matchmaker_redis.oslo.messaging.socket_timeout
{{ if not .matchmaker_redis.oslo.messaging.socket_timeout }}#{{ end }}socket_timeout = {{ .matchmaker_redis.oslo.messaging.socket_timeout | default "10000" }}


[neutron_client]

#
# From magnum
#

# Region in Identity service catalog to use for communication with the
# OpenStack service. (string value)
# from .neutron_client.magnum.region_name
{{ if not .neutron_client.magnum.region_name }}#{{ end }}region_name = {{ .neutron_client.magnum.region_name | default "<None>" }}

# Type of endpoint in Identity service catalog to use for communication with
# the OpenStack service. (string value)
# from .neutron_client.magnum.endpoint_type
{{ if not .neutron_client.magnum.endpoint_type }}#{{ end }}endpoint_type = {{ .neutron_client.magnum.endpoint_type | default "publicURL" }}


[nova_client]

#
# From magnum
#

# Region in Identity service catalog to use for communication with the
# OpenStack service. (string value)
# from .nova_client.magnum.region_name
{{ if not .nova_client.magnum.region_name }}#{{ end }}region_name = {{ .nova_client.magnum.region_name | default "<None>" }}

# Type of endpoint in Identity service catalog to use for communication with
# the OpenStack service. (string value)
# from .nova_client.magnum.endpoint_type
{{ if not .nova_client.magnum.endpoint_type }}#{{ end }}endpoint_type = {{ .nova_client.magnum.endpoint_type | default "publicURL" }}

# Version of Nova API to use in novaclient. (string value)
# from .nova_client.magnum.api_version
{{ if not .nova_client.magnum.api_version }}#{{ end }}api_version = {{ .nova_client.magnum.api_version | default "2" }}


[oslo_concurrency]

#
# From oslo.concurrency
#

# Enables or disables inter-process locks. (boolean value)
# Deprecated group/name - [DEFAULT]/disable_process_locking
# from .oslo_concurrency.oslo.concurrency.disable_process_locking
{{ if not .oslo_concurrency.oslo.concurrency.disable_process_locking }}#{{ end }}disable_process_locking = {{ .oslo_concurrency.oslo.concurrency.disable_process_locking | default "false" }}

# Directory to use for lock files.  For security, the specified directory
# should only be writable by the user running the processes that need locking.
# Defaults to environment variable OSLO_LOCK_PATH. If external locks are used,
# a lock path must be set. (string value)
# Deprecated group/name - [DEFAULT]/lock_path
# from .oslo_concurrency.oslo.concurrency.lock_path
{{ if not .oslo_concurrency.oslo.concurrency.lock_path }}#{{ end }}lock_path = {{ .oslo_concurrency.oslo.concurrency.lock_path | default "<None>" }}


[oslo_messaging_amqp]

#
# From oslo.messaging
#

# Name for the AMQP container. must be globally unique. Defaults to a generated
# UUID (string value)
# Deprecated group/name - [amqp1]/container_name
# from .oslo_messaging_amqp.oslo.messaging.container_name
{{ if not .oslo_messaging_amqp.oslo.messaging.container_name }}#{{ end }}container_name = {{ .oslo_messaging_amqp.oslo.messaging.container_name | default "<None>" }}

# Timeout for inactive connections (in seconds) (integer value)
# Deprecated group/name - [amqp1]/idle_timeout
# from .oslo_messaging_amqp.oslo.messaging.idle_timeout
{{ if not .oslo_messaging_amqp.oslo.messaging.idle_timeout }}#{{ end }}idle_timeout = {{ .oslo_messaging_amqp.oslo.messaging.idle_timeout | default "0" }}

# Debug: dump AMQP frames to stdout (boolean value)
# Deprecated group/name - [amqp1]/trace
# from .oslo_messaging_amqp.oslo.messaging.trace
{{ if not .oslo_messaging_amqp.oslo.messaging.trace }}#{{ end }}trace = {{ .oslo_messaging_amqp.oslo.messaging.trace | default "false" }}

# CA certificate PEM file to verify server certificate (string value)
# Deprecated group/name - [amqp1]/ssl_ca_file
# from .oslo_messaging_amqp.oslo.messaging.ssl_ca_file
{{ if not .oslo_messaging_amqp.oslo.messaging.ssl_ca_file }}#{{ end }}ssl_ca_file = {{ .oslo_messaging_amqp.oslo.messaging.ssl_ca_file | default "" }}

# Identifying certificate PEM file to present to clients (string value)
# Deprecated group/name - [amqp1]/ssl_cert_file
# from .oslo_messaging_amqp.oslo.messaging.ssl_cert_file
{{ if not .oslo_messaging_amqp.oslo.messaging.ssl_cert_file }}#{{ end }}ssl_cert_file = {{ .oslo_messaging_amqp.oslo.messaging.ssl_cert_file | default "" }}

# Private key PEM file used to sign cert_file certificate (string value)
# Deprecated group/name - [amqp1]/ssl_key_file
# from .oslo_messaging_amqp.oslo.messaging.ssl_key_file
{{ if not .oslo_messaging_amqp.oslo.messaging.ssl_key_file }}#{{ end }}ssl_key_file = {{ .oslo_messaging_amqp.oslo.messaging.ssl_key_file | default "" }}

# Password for decrypting ssl_key_file (if encrypted) (string value)
# Deprecated group/name - [amqp1]/ssl_key_password
# from .oslo_messaging_amqp.oslo.messaging.ssl_key_password
{{ if not .oslo_messaging_amqp.oslo.messaging.ssl_key_password }}#{{ end }}ssl_key_password = {{ .oslo_messaging_amqp.oslo.messaging.ssl_key_password | default "<None>" }}

# Accept clients using either SSL or plain TCP (boolean value)
# Deprecated group/name - [amqp1]/allow_insecure_clients
# from .oslo_messaging_amqp.oslo.messaging.allow_insecure_clients
{{ if not .oslo_messaging_amqp.oslo.messaging.allow_insecure_clients }}#{{ end }}allow_insecure_clients = {{ .oslo_messaging_amqp.oslo.messaging.allow_insecure_clients | default "false" }}

# Space separated list of acceptable SASL mechanisms (string value)
# Deprecated group/name - [amqp1]/sasl_mechanisms
# from .oslo_messaging_amqp.oslo.messaging.sasl_mechanisms
{{ if not .oslo_messaging_amqp.oslo.messaging.sasl_mechanisms }}#{{ end }}sasl_mechanisms = {{ .oslo_messaging_amqp.oslo.messaging.sasl_mechanisms | default "" }}

# Path to directory that contains the SASL configuration (string value)
# Deprecated group/name - [amqp1]/sasl_config_dir
# from .oslo_messaging_amqp.oslo.messaging.sasl_config_dir
{{ if not .oslo_messaging_amqp.oslo.messaging.sasl_config_dir }}#{{ end }}sasl_config_dir = {{ .oslo_messaging_amqp.oslo.messaging.sasl_config_dir | default "" }}

# Name of configuration file (without .conf suffix) (string value)
# Deprecated group/name - [amqp1]/sasl_config_name
# from .oslo_messaging_amqp.oslo.messaging.sasl_config_name
{{ if not .oslo_messaging_amqp.oslo.messaging.sasl_config_name }}#{{ end }}sasl_config_name = {{ .oslo_messaging_amqp.oslo.messaging.sasl_config_name | default "" }}

# User name for message broker authentication (string value)
# Deprecated group/name - [amqp1]/username
# from .oslo_messaging_amqp.oslo.messaging.username
{{ if not .oslo_messaging_amqp.oslo.messaging.username }}#{{ end }}username = {{ .oslo_messaging_amqp.oslo.messaging.username | default "" }}

# Password for message broker authentication (string value)
# Deprecated group/name - [amqp1]/password
# from .oslo_messaging_amqp.oslo.messaging.password
{{ if not .oslo_messaging_amqp.oslo.messaging.password }}#{{ end }}password = {{ .oslo_messaging_amqp.oslo.messaging.password | default "" }}

# Seconds to pause before attempting to re-connect. (integer value)
# Minimum value: 1
# from .oslo_messaging_amqp.oslo.messaging.connection_retry_interval
{{ if not .oslo_messaging_amqp.oslo.messaging.connection_retry_interval }}#{{ end }}connection_retry_interval = {{ .oslo_messaging_amqp.oslo.messaging.connection_retry_interval | default "1" }}

# Increase the connection_retry_interval by this many seconds after each
# unsuccessful failover attempt. (integer value)
# Minimum value: 0
# from .oslo_messaging_amqp.oslo.messaging.connection_retry_backoff
{{ if not .oslo_messaging_amqp.oslo.messaging.connection_retry_backoff }}#{{ end }}connection_retry_backoff = {{ .oslo_messaging_amqp.oslo.messaging.connection_retry_backoff | default "2" }}

# Maximum limit for connection_retry_interval + connection_retry_backoff
# (integer value)
# Minimum value: 1
# from .oslo_messaging_amqp.oslo.messaging.connection_retry_interval_max
{{ if not .oslo_messaging_amqp.oslo.messaging.connection_retry_interval_max }}#{{ end }}connection_retry_interval_max = {{ .oslo_messaging_amqp.oslo.messaging.connection_retry_interval_max | default "30" }}

# Time to pause between re-connecting an AMQP 1.0 link that failed due to a
# recoverable error. (integer value)
# Minimum value: 1
# from .oslo_messaging_amqp.oslo.messaging.link_retry_delay
{{ if not .oslo_messaging_amqp.oslo.messaging.link_retry_delay }}#{{ end }}link_retry_delay = {{ .oslo_messaging_amqp.oslo.messaging.link_retry_delay | default "10" }}

# The deadline for an rpc reply message delivery. Only used when caller does
# not provide a timeout expiry. (integer value)
# Minimum value: 5
# from .oslo_messaging_amqp.oslo.messaging.default_reply_timeout
{{ if not .oslo_messaging_amqp.oslo.messaging.default_reply_timeout }}#{{ end }}default_reply_timeout = {{ .oslo_messaging_amqp.oslo.messaging.default_reply_timeout | default "30" }}

# The deadline for an rpc cast or call message delivery. Only used when caller
# does not provide a timeout expiry. (integer value)
# Minimum value: 5
# from .oslo_messaging_amqp.oslo.messaging.default_send_timeout
{{ if not .oslo_messaging_amqp.oslo.messaging.default_send_timeout }}#{{ end }}default_send_timeout = {{ .oslo_messaging_amqp.oslo.messaging.default_send_timeout | default "30" }}

# The deadline for a sent notification message delivery. Only used when caller
# does not provide a timeout expiry. (integer value)
# Minimum value: 5
# from .oslo_messaging_amqp.oslo.messaging.default_notify_timeout
{{ if not .oslo_messaging_amqp.oslo.messaging.default_notify_timeout }}#{{ end }}default_notify_timeout = {{ .oslo_messaging_amqp.oslo.messaging.default_notify_timeout | default "30" }}

# Indicates the addressing mode used by the driver.
# Permitted values:
# 'legacy'   - use legacy non-routable addressing
# 'routable' - use routable addresses
# 'dynamic'  - use legacy addresses if the message bus does not support routing
# otherwise use routable addressing (string value)
# from .oslo_messaging_amqp.oslo.messaging.addressing_mode
{{ if not .oslo_messaging_amqp.oslo.messaging.addressing_mode }}#{{ end }}addressing_mode = {{ .oslo_messaging_amqp.oslo.messaging.addressing_mode | default "dynamic" }}

# address prefix used when sending to a specific server (string value)
# Deprecated group/name - [amqp1]/server_request_prefix
# from .oslo_messaging_amqp.oslo.messaging.server_request_prefix
{{ if not .oslo_messaging_amqp.oslo.messaging.server_request_prefix }}#{{ end }}server_request_prefix = {{ .oslo_messaging_amqp.oslo.messaging.server_request_prefix | default "exclusive" }}

# address prefix used when broadcasting to all servers (string value)
# Deprecated group/name - [amqp1]/broadcast_prefix
# from .oslo_messaging_amqp.oslo.messaging.broadcast_prefix
{{ if not .oslo_messaging_amqp.oslo.messaging.broadcast_prefix }}#{{ end }}broadcast_prefix = {{ .oslo_messaging_amqp.oslo.messaging.broadcast_prefix | default "broadcast" }}

# address prefix when sending to any server in group (string value)
# Deprecated group/name - [amqp1]/group_request_prefix
# from .oslo_messaging_amqp.oslo.messaging.group_request_prefix
{{ if not .oslo_messaging_amqp.oslo.messaging.group_request_prefix }}#{{ end }}group_request_prefix = {{ .oslo_messaging_amqp.oslo.messaging.group_request_prefix | default "unicast" }}

# Address prefix for all generated RPC addresses (string value)
# from .oslo_messaging_amqp.oslo.messaging.rpc_address_prefix
{{ if not .oslo_messaging_amqp.oslo.messaging.rpc_address_prefix }}#{{ end }}rpc_address_prefix = {{ .oslo_messaging_amqp.oslo.messaging.rpc_address_prefix | default "openstack.org/om/rpc" }}

# Address prefix for all generated Notification addresses (string value)
# from .oslo_messaging_amqp.oslo.messaging.notify_address_prefix
{{ if not .oslo_messaging_amqp.oslo.messaging.notify_address_prefix }}#{{ end }}notify_address_prefix = {{ .oslo_messaging_amqp.oslo.messaging.notify_address_prefix | default "openstack.org/om/notify" }}

# Appended to the address prefix when sending a fanout message. Used by the
# message bus to identify fanout messages. (string value)
# from .oslo_messaging_amqp.oslo.messaging.multicast_address
{{ if not .oslo_messaging_amqp.oslo.messaging.multicast_address }}#{{ end }}multicast_address = {{ .oslo_messaging_amqp.oslo.messaging.multicast_address | default "multicast" }}

# Appended to the address prefix when sending to a particular RPC/Notification
# server. Used by the message bus to identify messages sent to a single
# destination. (string value)
# from .oslo_messaging_amqp.oslo.messaging.unicast_address
{{ if not .oslo_messaging_amqp.oslo.messaging.unicast_address }}#{{ end }}unicast_address = {{ .oslo_messaging_amqp.oslo.messaging.unicast_address | default "unicast" }}

# Appended to the address prefix when sending to a group of consumers. Used by
# the message bus to identify messages that should be delivered in a round-
# robin fashion across consumers. (string value)
# from .oslo_messaging_amqp.oslo.messaging.anycast_address
{{ if not .oslo_messaging_amqp.oslo.messaging.anycast_address }}#{{ end }}anycast_address = {{ .oslo_messaging_amqp.oslo.messaging.anycast_address | default "anycast" }}

# Exchange name used in notification addresses.
# Exchange name resolution precedence:
# Target.exchange if set
# else default_notification_exchange if set
# else control_exchange if set
# else 'notify' (string value)
# from .oslo_messaging_amqp.oslo.messaging.default_notification_exchange
{{ if not .oslo_messaging_amqp.oslo.messaging.default_notification_exchange }}#{{ end }}default_notification_exchange = {{ .oslo_messaging_amqp.oslo.messaging.default_notification_exchange | default "<None>" }}

# Exchange name used in RPC addresses.
# Exchange name resolution precedence:
# Target.exchange if set
# else default_rpc_exchange if set
# else control_exchange if set
# else 'rpc' (string value)
# from .oslo_messaging_amqp.oslo.messaging.default_rpc_exchange
{{ if not .oslo_messaging_amqp.oslo.messaging.default_rpc_exchange }}#{{ end }}default_rpc_exchange = {{ .oslo_messaging_amqp.oslo.messaging.default_rpc_exchange | default "<None>" }}

# Window size for incoming RPC Reply messages. (integer value)
# Minimum value: 1
# from .oslo_messaging_amqp.oslo.messaging.reply_link_credit
{{ if not .oslo_messaging_amqp.oslo.messaging.reply_link_credit }}#{{ end }}reply_link_credit = {{ .oslo_messaging_amqp.oslo.messaging.reply_link_credit | default "200" }}

# Window size for incoming RPC Request messages (integer value)
# Minimum value: 1
# from .oslo_messaging_amqp.oslo.messaging.rpc_server_credit
{{ if not .oslo_messaging_amqp.oslo.messaging.rpc_server_credit }}#{{ end }}rpc_server_credit = {{ .oslo_messaging_amqp.oslo.messaging.rpc_server_credit | default "100" }}

# Window size for incoming Notification messages (integer value)
# Minimum value: 1
# from .oslo_messaging_amqp.oslo.messaging.notify_server_credit
{{ if not .oslo_messaging_amqp.oslo.messaging.notify_server_credit }}#{{ end }}notify_server_credit = {{ .oslo_messaging_amqp.oslo.messaging.notify_server_credit | default "100" }}


[oslo_messaging_notifications]

#
# From oslo.messaging
#

# The Drivers(s) to handle sending notifications. Possible values are
# messaging, messagingv2, routing, log, test, noop (multi valued)
# Deprecated group/name - [DEFAULT]/notification_driver
# from .oslo_messaging_notifications.oslo.messaging.driver (multiopt)
{{ if not .oslo_messaging_notifications.oslo.messaging.driver }}#driver = {{ .oslo_messaging_notifications.oslo.messaging.driver | default "" }}{{ else }}{{ range .oslo_messaging_notifications.oslo.messaging.driver }}driver = {{ . }}
{{ end }}{{ end }}

# A URL representing the messaging driver to use for notifications. If not set,
# we fall back to the same configuration used for RPC. (string value)
# Deprecated group/name - [DEFAULT]/notification_transport_url
# from .oslo_messaging_notifications.oslo.messaging.transport_url
{{ if not .oslo_messaging_notifications.oslo.messaging.transport_url }}#{{ end }}transport_url = {{ .oslo_messaging_notifications.oslo.messaging.transport_url | default "<None>" }}

# AMQP topic used for OpenStack notifications. (list value)
# Deprecated group/name - [rpc_notifier2]/topics
# Deprecated group/name - [DEFAULT]/notification_topics
# from .oslo_messaging_notifications.oslo.messaging.topics
{{ if not .oslo_messaging_notifications.oslo.messaging.topics }}#{{ end }}topics = {{ .oslo_messaging_notifications.oslo.messaging.topics | default "notifications" }}


[oslo_messaging_rabbit]

#
# From oslo.messaging
#

# Use durable queues in AMQP. (boolean value)
# Deprecated group/name - [DEFAULT]/amqp_durable_queues
# Deprecated group/name - [DEFAULT]/rabbit_durable_queues
# from .oslo_messaging_rabbit.oslo.messaging.amqp_durable_queues
{{ if not .oslo_messaging_rabbit.oslo.messaging.amqp_durable_queues }}#{{ end }}amqp_durable_queues = {{ .oslo_messaging_rabbit.oslo.messaging.amqp_durable_queues | default "false" }}

# Auto-delete queues in AMQP. (boolean value)
# Deprecated group/name - [DEFAULT]/amqp_auto_delete
# from .oslo_messaging_rabbit.oslo.messaging.amqp_auto_delete
{{ if not .oslo_messaging_rabbit.oslo.messaging.amqp_auto_delete }}#{{ end }}amqp_auto_delete = {{ .oslo_messaging_rabbit.oslo.messaging.amqp_auto_delete | default "false" }}

# SSL version to use (valid only if SSL enabled). Valid values are TLSv1 and
# SSLv23. SSLv2, SSLv3, TLSv1_1, and TLSv1_2 may be available on some
# distributions. (string value)
# Deprecated group/name - [DEFAULT]/kombu_ssl_version
# from .oslo_messaging_rabbit.oslo.messaging.kombu_ssl_version
{{ if not .oslo_messaging_rabbit.oslo.messaging.kombu_ssl_version }}#{{ end }}kombu_ssl_version = {{ .oslo_messaging_rabbit.oslo.messaging.kombu_ssl_version | default "" }}

# SSL key file (valid only if SSL enabled). (string value)
# Deprecated group/name - [DEFAULT]/kombu_ssl_keyfile
# from .oslo_messaging_rabbit.oslo.messaging.kombu_ssl_keyfile
{{ if not .oslo_messaging_rabbit.oslo.messaging.kombu_ssl_keyfile }}#{{ end }}kombu_ssl_keyfile = {{ .oslo_messaging_rabbit.oslo.messaging.kombu_ssl_keyfile | default "" }}

# SSL cert file (valid only if SSL enabled). (string value)
# Deprecated group/name - [DEFAULT]/kombu_ssl_certfile
# from .oslo_messaging_rabbit.oslo.messaging.kombu_ssl_certfile
{{ if not .oslo_messaging_rabbit.oslo.messaging.kombu_ssl_certfile }}#{{ end }}kombu_ssl_certfile = {{ .oslo_messaging_rabbit.oslo.messaging.kombu_ssl_certfile | default "" }}

# SSL certification authority file (valid only if SSL enabled). (string value)
# Deprecated group/name - [DEFAULT]/kombu_ssl_ca_certs
# from .oslo_messaging_rabbit.oslo.messaging.kombu_ssl_ca_certs
{{ if not .oslo_messaging_rabbit.oslo.messaging.kombu_ssl_ca_certs }}#{{ end }}kombu_ssl_ca_certs = {{ .oslo_messaging_rabbit.oslo.messaging.kombu_ssl_ca_certs | default "" }}

# How long to wait before reconnecting in response to an AMQP consumer cancel
# notification. (floating point value)
# Deprecated group/name - [DEFAULT]/kombu_reconnect_delay
# from .oslo_messaging_rabbit.oslo.messaging.kombu_reconnect_delay
{{ if not .oslo_messaging_rabbit.oslo.messaging.kombu_reconnect_delay }}#{{ end }}kombu_reconnect_delay = {{ .oslo_messaging_rabbit.oslo.messaging.kombu_reconnect_delay | default "1.0" }}

# EXPERIMENTAL: Possible values are: gzip, bz2. If not set compression will not
# be used. This option may not be available in future versions. (string value)
# from .oslo_messaging_rabbit.oslo.messaging.kombu_compression
{{ if not .oslo_messaging_rabbit.oslo.messaging.kombu_compression }}#{{ end }}kombu_compression = {{ .oslo_messaging_rabbit.oslo.messaging.kombu_compression | default "<None>" }}

# How long to wait a missing client before abandoning to send it its replies.
# This value should not be longer than rpc_response_timeout. (integer value)
# Deprecated group/name - [oslo_messaging_rabbit]/kombu_reconnect_timeout
# from .oslo_messaging_rabbit.oslo.messaging.kombu_missing_consumer_retry_timeout
{{ if not .oslo_messaging_rabbit.oslo.messaging.kombu_missing_consumer_retry_timeout }}#{{ end }}kombu_missing_consumer_retry_timeout = {{ .oslo_messaging_rabbit.oslo.messaging.kombu_missing_consumer_retry_timeout | default "60" }}

# Determines how the next RabbitMQ node is chosen in case the one we are
# currently connected to becomes unavailable. Takes effect only if more than
# one RabbitMQ node is provided in config. (string value)
# Allowed values: round-robin, shuffle
# from .oslo_messaging_rabbit.oslo.messaging.kombu_failover_strategy
{{ if not .oslo_messaging_rabbit.oslo.messaging.kombu_failover_strategy }}#{{ end }}kombu_failover_strategy = {{ .oslo_messaging_rabbit.oslo.messaging.kombu_failover_strategy | default "round-robin" }}

# DEPRECATED: The RabbitMQ broker address where a single node is used. (string
# value)
# Deprecated group/name - [DEFAULT]/rabbit_host
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# Reason: Replaced by [DEFAULT]/transport_url
# from .oslo_messaging_rabbit.oslo.messaging.rabbit_host
{{ if not .oslo_messaging_rabbit.oslo.messaging.rabbit_host }}#{{ end }}rabbit_host = {{ .oslo_messaging_rabbit.oslo.messaging.rabbit_host | default "localhost" }}

# DEPRECATED: The RabbitMQ broker port where a single node is used. (port
# value)
# Minimum value: 0
# Maximum value: 65535
# Deprecated group/name - [DEFAULT]/rabbit_port
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# Reason: Replaced by [DEFAULT]/transport_url
# from .oslo_messaging_rabbit.oslo.messaging.rabbit_port
{{ if not .oslo_messaging_rabbit.oslo.messaging.rabbit_port }}#{{ end }}rabbit_port = {{ .oslo_messaging_rabbit.oslo.messaging.rabbit_port | default "5672" }}

# DEPRECATED: RabbitMQ HA cluster host:port pairs. (list value)
# Deprecated group/name - [DEFAULT]/rabbit_hosts
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# Reason: Replaced by [DEFAULT]/transport_url
# from .oslo_messaging_rabbit.oslo.messaging.rabbit_hosts
{{ if not .oslo_messaging_rabbit.oslo.messaging.rabbit_hosts }}#{{ end }}rabbit_hosts = {{ .oslo_messaging_rabbit.oslo.messaging.rabbit_hosts | default "$rabbit_host:$rabbit_port" }}

# Connect over SSL for RabbitMQ. (boolean value)
# Deprecated group/name - [DEFAULT]/rabbit_use_ssl
# from .oslo_messaging_rabbit.oslo.messaging.rabbit_use_ssl
{{ if not .oslo_messaging_rabbit.oslo.messaging.rabbit_use_ssl }}#{{ end }}rabbit_use_ssl = {{ .oslo_messaging_rabbit.oslo.messaging.rabbit_use_ssl | default "false" }}

# DEPRECATED: The RabbitMQ userid. (string value)
# Deprecated group/name - [DEFAULT]/rabbit_userid
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# Reason: Replaced by [DEFAULT]/transport_url
# from .oslo_messaging_rabbit.oslo.messaging.rabbit_userid
{{ if not .oslo_messaging_rabbit.oslo.messaging.rabbit_userid }}#{{ end }}rabbit_userid = {{ .oslo_messaging_rabbit.oslo.messaging.rabbit_userid | default "guest" }}

# DEPRECATED: The RabbitMQ password. (string value)
# Deprecated group/name - [DEFAULT]/rabbit_password
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# Reason: Replaced by [DEFAULT]/transport_url
# from .oslo_messaging_rabbit.oslo.messaging.rabbit_password
{{ if not .oslo_messaging_rabbit.oslo.messaging.rabbit_password }}#{{ end }}rabbit_password = {{ .oslo_messaging_rabbit.oslo.messaging.rabbit_password | default "guest" }}

# The RabbitMQ login method. (string value)
# Deprecated group/name - [DEFAULT]/rabbit_login_method
# from .oslo_messaging_rabbit.oslo.messaging.rabbit_login_method
{{ if not .oslo_messaging_rabbit.oslo.messaging.rabbit_login_method }}#{{ end }}rabbit_login_method = {{ .oslo_messaging_rabbit.oslo.messaging.rabbit_login_method | default "AMQPLAIN" }}

# DEPRECATED: The RabbitMQ virtual host. (string value)
# Deprecated group/name - [DEFAULT]/rabbit_virtual_host
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# Reason: Replaced by [DEFAULT]/transport_url
# from .oslo_messaging_rabbit.oslo.messaging.rabbit_virtual_host
{{ if not .oslo_messaging_rabbit.oslo.messaging.rabbit_virtual_host }}#{{ end }}rabbit_virtual_host = {{ .oslo_messaging_rabbit.oslo.messaging.rabbit_virtual_host | default "/" }}

# How frequently to retry connecting with RabbitMQ. (integer value)
# from .oslo_messaging_rabbit.oslo.messaging.rabbit_retry_interval
{{ if not .oslo_messaging_rabbit.oslo.messaging.rabbit_retry_interval }}#{{ end }}rabbit_retry_interval = {{ .oslo_messaging_rabbit.oslo.messaging.rabbit_retry_interval | default "1" }}

# How long to backoff for between retries when connecting to RabbitMQ. (integer
# value)
# Deprecated group/name - [DEFAULT]/rabbit_retry_backoff
# from .oslo_messaging_rabbit.oslo.messaging.rabbit_retry_backoff
{{ if not .oslo_messaging_rabbit.oslo.messaging.rabbit_retry_backoff }}#{{ end }}rabbit_retry_backoff = {{ .oslo_messaging_rabbit.oslo.messaging.rabbit_retry_backoff | default "2" }}

# Maximum interval of RabbitMQ connection retries. Default is 30 seconds.
# (integer value)
# from .oslo_messaging_rabbit.oslo.messaging.rabbit_interval_max
{{ if not .oslo_messaging_rabbit.oslo.messaging.rabbit_interval_max }}#{{ end }}rabbit_interval_max = {{ .oslo_messaging_rabbit.oslo.messaging.rabbit_interval_max | default "30" }}

# DEPRECATED: Maximum number of RabbitMQ connection retries. Default is 0
# (infinite retry count). (integer value)
# Deprecated group/name - [DEFAULT]/rabbit_max_retries
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# from .oslo_messaging_rabbit.oslo.messaging.rabbit_max_retries
{{ if not .oslo_messaging_rabbit.oslo.messaging.rabbit_max_retries }}#{{ end }}rabbit_max_retries = {{ .oslo_messaging_rabbit.oslo.messaging.rabbit_max_retries | default "0" }}

# Try to use HA queues in RabbitMQ (x-ha-policy: all). If you change this
# option, you must wipe the RabbitMQ database. In RabbitMQ 3.0, queue mirroring
# is no longer controlled by the x-ha-policy argument when declaring a queue.
# If you just want to make sure that all queues (except  those with auto-
# generated names) are mirrored across all nodes, run: "rabbitmqctl set_policy
# HA '^(?!amq\.).*' '{"ha-mode": "all"}' " (boolean value)
# Deprecated group/name - [DEFAULT]/rabbit_ha_queues
# from .oslo_messaging_rabbit.oslo.messaging.rabbit_ha_queues
{{ if not .oslo_messaging_rabbit.oslo.messaging.rabbit_ha_queues }}#{{ end }}rabbit_ha_queues = {{ .oslo_messaging_rabbit.oslo.messaging.rabbit_ha_queues | default "false" }}

# Positive integer representing duration in seconds for queue TTL (x-expires).
# Queues which are unused for the duration of the TTL are automatically
# deleted. The parameter affects only reply and fanout queues. (integer value)
# Minimum value: 1
# from .oslo_messaging_rabbit.oslo.messaging.rabbit_transient_queues_ttl
{{ if not .oslo_messaging_rabbit.oslo.messaging.rabbit_transient_queues_ttl }}#{{ end }}rabbit_transient_queues_ttl = {{ .oslo_messaging_rabbit.oslo.messaging.rabbit_transient_queues_ttl | default "1800" }}

# Specifies the number of messages to prefetch. Setting to zero allows
# unlimited messages. (integer value)
# from .oslo_messaging_rabbit.oslo.messaging.rabbit_qos_prefetch_count
{{ if not .oslo_messaging_rabbit.oslo.messaging.rabbit_qos_prefetch_count }}#{{ end }}rabbit_qos_prefetch_count = {{ .oslo_messaging_rabbit.oslo.messaging.rabbit_qos_prefetch_count | default "0" }}

# Number of seconds after which the Rabbit broker is considered down if
# heartbeat's keep-alive fails (0 disable the heartbeat). EXPERIMENTAL (integer
# value)
# from .oslo_messaging_rabbit.oslo.messaging.heartbeat_timeout_threshold
{{ if not .oslo_messaging_rabbit.oslo.messaging.heartbeat_timeout_threshold }}#{{ end }}heartbeat_timeout_threshold = {{ .oslo_messaging_rabbit.oslo.messaging.heartbeat_timeout_threshold | default "60" }}

# How often times during the heartbeat_timeout_threshold we check the
# heartbeat. (integer value)
# from .oslo_messaging_rabbit.oslo.messaging.heartbeat_rate
{{ if not .oslo_messaging_rabbit.oslo.messaging.heartbeat_rate }}#{{ end }}heartbeat_rate = {{ .oslo_messaging_rabbit.oslo.messaging.heartbeat_rate | default "2" }}

# Deprecated, use rpc_backend=kombu+memory or rpc_backend=fake (boolean value)
# Deprecated group/name - [DEFAULT]/fake_rabbit
# from .oslo_messaging_rabbit.oslo.messaging.fake_rabbit
{{ if not .oslo_messaging_rabbit.oslo.messaging.fake_rabbit }}#{{ end }}fake_rabbit = {{ .oslo_messaging_rabbit.oslo.messaging.fake_rabbit | default "false" }}

# Maximum number of channels to allow (integer value)
# from .oslo_messaging_rabbit.oslo.messaging.channel_max
{{ if not .oslo_messaging_rabbit.oslo.messaging.channel_max }}#{{ end }}channel_max = {{ .oslo_messaging_rabbit.oslo.messaging.channel_max | default "<None>" }}

# The maximum byte size for an AMQP frame (integer value)
# from .oslo_messaging_rabbit.oslo.messaging.frame_max
{{ if not .oslo_messaging_rabbit.oslo.messaging.frame_max }}#{{ end }}frame_max = {{ .oslo_messaging_rabbit.oslo.messaging.frame_max | default "<None>" }}

# How often to send heartbeats for consumer's connections (integer value)
# from .oslo_messaging_rabbit.oslo.messaging.heartbeat_interval
{{ if not .oslo_messaging_rabbit.oslo.messaging.heartbeat_interval }}#{{ end }}heartbeat_interval = {{ .oslo_messaging_rabbit.oslo.messaging.heartbeat_interval | default "3" }}

# Enable SSL (boolean value)
# from .oslo_messaging_rabbit.oslo.messaging.ssl
{{ if not .oslo_messaging_rabbit.oslo.messaging.ssl }}#{{ end }}ssl = {{ .oslo_messaging_rabbit.oslo.messaging.ssl | default "<None>" }}

# Arguments passed to ssl.wrap_socket (dict value)
# from .oslo_messaging_rabbit.oslo.messaging.ssl_options
{{ if not .oslo_messaging_rabbit.oslo.messaging.ssl_options }}#{{ end }}ssl_options = {{ .oslo_messaging_rabbit.oslo.messaging.ssl_options | default "<None>" }}

# Set socket timeout in seconds for connection's socket (floating point value)
# from .oslo_messaging_rabbit.oslo.messaging.socket_timeout
{{ if not .oslo_messaging_rabbit.oslo.messaging.socket_timeout }}#{{ end }}socket_timeout = {{ .oslo_messaging_rabbit.oslo.messaging.socket_timeout | default "0.25" }}

# Set TCP_USER_TIMEOUT in seconds for connection's socket (floating point
# value)
# from .oslo_messaging_rabbit.oslo.messaging.tcp_user_timeout
{{ if not .oslo_messaging_rabbit.oslo.messaging.tcp_user_timeout }}#{{ end }}tcp_user_timeout = {{ .oslo_messaging_rabbit.oslo.messaging.tcp_user_timeout | default "0.25" }}

# Set delay for reconnection to some host which has connection error (floating
# point value)
# from .oslo_messaging_rabbit.oslo.messaging.host_connection_reconnect_delay
{{ if not .oslo_messaging_rabbit.oslo.messaging.host_connection_reconnect_delay }}#{{ end }}host_connection_reconnect_delay = {{ .oslo_messaging_rabbit.oslo.messaging.host_connection_reconnect_delay | default "0.25" }}

# Connection factory implementation (string value)
# Allowed values: new, single, read_write
# from .oslo_messaging_rabbit.oslo.messaging.connection_factory
{{ if not .oslo_messaging_rabbit.oslo.messaging.connection_factory }}#{{ end }}connection_factory = {{ .oslo_messaging_rabbit.oslo.messaging.connection_factory | default "single" }}

# Maximum number of connections to keep queued. (integer value)
# from .oslo_messaging_rabbit.oslo.messaging.pool_max_size
{{ if not .oslo_messaging_rabbit.oslo.messaging.pool_max_size }}#{{ end }}pool_max_size = {{ .oslo_messaging_rabbit.oslo.messaging.pool_max_size | default "30" }}

# Maximum number of connections to create above `pool_max_size`. (integer
# value)
# from .oslo_messaging_rabbit.oslo.messaging.pool_max_overflow
{{ if not .oslo_messaging_rabbit.oslo.messaging.pool_max_overflow }}#{{ end }}pool_max_overflow = {{ .oslo_messaging_rabbit.oslo.messaging.pool_max_overflow | default "0" }}

# Default number of seconds to wait for a connections to available (integer
# value)
# from .oslo_messaging_rabbit.oslo.messaging.pool_timeout
{{ if not .oslo_messaging_rabbit.oslo.messaging.pool_timeout }}#{{ end }}pool_timeout = {{ .oslo_messaging_rabbit.oslo.messaging.pool_timeout | default "30" }}

# Lifetime of a connection (since creation) in seconds or None for no
# recycling. Expired connections are closed on acquire. (integer value)
# from .oslo_messaging_rabbit.oslo.messaging.pool_recycle
{{ if not .oslo_messaging_rabbit.oslo.messaging.pool_recycle }}#{{ end }}pool_recycle = {{ .oslo_messaging_rabbit.oslo.messaging.pool_recycle | default "600" }}

# Threshold at which inactive (since release) connections are considered stale
# in seconds or None for no staleness. Stale connections are closed on acquire.
# (integer value)
# from .oslo_messaging_rabbit.oslo.messaging.pool_stale
{{ if not .oslo_messaging_rabbit.oslo.messaging.pool_stale }}#{{ end }}pool_stale = {{ .oslo_messaging_rabbit.oslo.messaging.pool_stale | default "60" }}

# Persist notification messages. (boolean value)
# from .oslo_messaging_rabbit.oslo.messaging.notification_persistence
{{ if not .oslo_messaging_rabbit.oslo.messaging.notification_persistence }}#{{ end }}notification_persistence = {{ .oslo_messaging_rabbit.oslo.messaging.notification_persistence | default "false" }}

# Exchange name for sending notifications (string value)
# from .oslo_messaging_rabbit.oslo.messaging.default_notification_exchange
{{ if not .oslo_messaging_rabbit.oslo.messaging.default_notification_exchange }}#{{ end }}default_notification_exchange = {{ .oslo_messaging_rabbit.oslo.messaging.default_notification_exchange | default "${control_exchange}_notification" }}

# Max number of not acknowledged message which RabbitMQ can send to
# notification listener. (integer value)
# from .oslo_messaging_rabbit.oslo.messaging.notification_listener_prefetch_count
{{ if not .oslo_messaging_rabbit.oslo.messaging.notification_listener_prefetch_count }}#{{ end }}notification_listener_prefetch_count = {{ .oslo_messaging_rabbit.oslo.messaging.notification_listener_prefetch_count | default "100" }}

# Reconnecting retry count in case of connectivity problem during sending
# notification, -1 means infinite retry. (integer value)
# from .oslo_messaging_rabbit.oslo.messaging.default_notification_retry_attempts
{{ if not .oslo_messaging_rabbit.oslo.messaging.default_notification_retry_attempts }}#{{ end }}default_notification_retry_attempts = {{ .oslo_messaging_rabbit.oslo.messaging.default_notification_retry_attempts | default "-1" }}

# Reconnecting retry delay in case of connectivity problem during sending
# notification message (floating point value)
# from .oslo_messaging_rabbit.oslo.messaging.notification_retry_delay
{{ if not .oslo_messaging_rabbit.oslo.messaging.notification_retry_delay }}#{{ end }}notification_retry_delay = {{ .oslo_messaging_rabbit.oslo.messaging.notification_retry_delay | default "0.25" }}

# Time to live for rpc queues without consumers in seconds. (integer value)
# from .oslo_messaging_rabbit.oslo.messaging.rpc_queue_expiration
{{ if not .oslo_messaging_rabbit.oslo.messaging.rpc_queue_expiration }}#{{ end }}rpc_queue_expiration = {{ .oslo_messaging_rabbit.oslo.messaging.rpc_queue_expiration | default "60" }}

# Exchange name for sending RPC messages (string value)
# from .oslo_messaging_rabbit.oslo.messaging.default_rpc_exchange
{{ if not .oslo_messaging_rabbit.oslo.messaging.default_rpc_exchange }}#{{ end }}default_rpc_exchange = {{ .oslo_messaging_rabbit.oslo.messaging.default_rpc_exchange | default "${control_exchange}_rpc" }}

# Exchange name for receiving RPC replies (string value)
# from .oslo_messaging_rabbit.oslo.messaging.rpc_reply_exchange
{{ if not .oslo_messaging_rabbit.oslo.messaging.rpc_reply_exchange }}#{{ end }}rpc_reply_exchange = {{ .oslo_messaging_rabbit.oslo.messaging.rpc_reply_exchange | default "${control_exchange}_rpc_reply" }}

# Max number of not acknowledged message which RabbitMQ can send to rpc
# listener. (integer value)
# from .oslo_messaging_rabbit.oslo.messaging.rpc_listener_prefetch_count
{{ if not .oslo_messaging_rabbit.oslo.messaging.rpc_listener_prefetch_count }}#{{ end }}rpc_listener_prefetch_count = {{ .oslo_messaging_rabbit.oslo.messaging.rpc_listener_prefetch_count | default "100" }}

# Max number of not acknowledged message which RabbitMQ can send to rpc reply
# listener. (integer value)
# from .oslo_messaging_rabbit.oslo.messaging.rpc_reply_listener_prefetch_count
{{ if not .oslo_messaging_rabbit.oslo.messaging.rpc_reply_listener_prefetch_count }}#{{ end }}rpc_reply_listener_prefetch_count = {{ .oslo_messaging_rabbit.oslo.messaging.rpc_reply_listener_prefetch_count | default "100" }}

# Reconnecting retry count in case of connectivity problem during sending
# reply. -1 means infinite retry during rpc_timeout (integer value)
# from .oslo_messaging_rabbit.oslo.messaging.rpc_reply_retry_attempts
{{ if not .oslo_messaging_rabbit.oslo.messaging.rpc_reply_retry_attempts }}#{{ end }}rpc_reply_retry_attempts = {{ .oslo_messaging_rabbit.oslo.messaging.rpc_reply_retry_attempts | default "-1" }}

# Reconnecting retry delay in case of connectivity problem during sending
# reply. (floating point value)
# from .oslo_messaging_rabbit.oslo.messaging.rpc_reply_retry_delay
{{ if not .oslo_messaging_rabbit.oslo.messaging.rpc_reply_retry_delay }}#{{ end }}rpc_reply_retry_delay = {{ .oslo_messaging_rabbit.oslo.messaging.rpc_reply_retry_delay | default "0.25" }}

# Reconnecting retry count in case of connectivity problem during sending RPC
# message, -1 means infinite retry. If actual retry attempts in not 0 the rpc
# request could be processed more then one time (integer value)
# from .oslo_messaging_rabbit.oslo.messaging.default_rpc_retry_attempts
{{ if not .oslo_messaging_rabbit.oslo.messaging.default_rpc_retry_attempts }}#{{ end }}default_rpc_retry_attempts = {{ .oslo_messaging_rabbit.oslo.messaging.default_rpc_retry_attempts | default "-1" }}

# Reconnecting retry delay in case of connectivity problem during sending RPC
# message (floating point value)
# from .oslo_messaging_rabbit.oslo.messaging.rpc_retry_delay
{{ if not .oslo_messaging_rabbit.oslo.messaging.rpc_retry_delay }}#{{ end }}rpc_retry_delay = {{ .oslo_messaging_rabbit.oslo.messaging.rpc_retry_delay | default "0.25" }}


[oslo_messaging_zmq]

#
# From oslo.messaging
#

# ZeroMQ bind address. Should be a wildcard (*), an ethernet interface, or IP.
# The "host" option should point or resolve to this address. (string value)
# Deprecated group/name - [DEFAULT]/rpc_zmq_bind_address
# from .oslo_messaging_zmq.oslo.messaging.rpc_zmq_bind_address
{{ if not .oslo_messaging_zmq.oslo.messaging.rpc_zmq_bind_address }}#{{ end }}rpc_zmq_bind_address = {{ .oslo_messaging_zmq.oslo.messaging.rpc_zmq_bind_address | default "*" }}

# MatchMaker driver. (string value)
# Allowed values: redis, dummy
# Deprecated group/name - [DEFAULT]/rpc_zmq_matchmaker
# from .oslo_messaging_zmq.oslo.messaging.rpc_zmq_matchmaker
{{ if not .oslo_messaging_zmq.oslo.messaging.rpc_zmq_matchmaker }}#{{ end }}rpc_zmq_matchmaker = {{ .oslo_messaging_zmq.oslo.messaging.rpc_zmq_matchmaker | default "redis" }}

# Number of ZeroMQ contexts, defaults to 1. (integer value)
# Deprecated group/name - [DEFAULT]/rpc_zmq_contexts
# from .oslo_messaging_zmq.oslo.messaging.rpc_zmq_contexts
{{ if not .oslo_messaging_zmq.oslo.messaging.rpc_zmq_contexts }}#{{ end }}rpc_zmq_contexts = {{ .oslo_messaging_zmq.oslo.messaging.rpc_zmq_contexts | default "1" }}

# Maximum number of ingress messages to locally buffer per topic. Default is
# unlimited. (integer value)
# Deprecated group/name - [DEFAULT]/rpc_zmq_topic_backlog
# from .oslo_messaging_zmq.oslo.messaging.rpc_zmq_topic_backlog
{{ if not .oslo_messaging_zmq.oslo.messaging.rpc_zmq_topic_backlog }}#{{ end }}rpc_zmq_topic_backlog = {{ .oslo_messaging_zmq.oslo.messaging.rpc_zmq_topic_backlog | default "<None>" }}

# Directory for holding IPC sockets. (string value)
# Deprecated group/name - [DEFAULT]/rpc_zmq_ipc_dir
# from .oslo_messaging_zmq.oslo.messaging.rpc_zmq_ipc_dir
{{ if not .oslo_messaging_zmq.oslo.messaging.rpc_zmq_ipc_dir }}#{{ end }}rpc_zmq_ipc_dir = {{ .oslo_messaging_zmq.oslo.messaging.rpc_zmq_ipc_dir | default "/var/run/openstack" }}

# Name of this node. Must be a valid hostname, FQDN, or IP address. Must match
# "host" option, if running Nova. (string value)
# Deprecated group/name - [DEFAULT]/rpc_zmq_host
# from .oslo_messaging_zmq.oslo.messaging.rpc_zmq_host
{{ if not .oslo_messaging_zmq.oslo.messaging.rpc_zmq_host }}#{{ end }}rpc_zmq_host = {{ .oslo_messaging_zmq.oslo.messaging.rpc_zmq_host | default "localhost" }}

# Seconds to wait before a cast expires (TTL). The default value of -1
# specifies an infinite linger period. The value of 0 specifies no linger
# period. Pending messages shall be discarded immediately when the socket is
# closed. Only supported by impl_zmq. (integer value)
# Deprecated group/name - [DEFAULT]/rpc_cast_timeout
# from .oslo_messaging_zmq.oslo.messaging.rpc_cast_timeout
{{ if not .oslo_messaging_zmq.oslo.messaging.rpc_cast_timeout }}#{{ end }}rpc_cast_timeout = {{ .oslo_messaging_zmq.oslo.messaging.rpc_cast_timeout | default "-1" }}

# The default number of seconds that poll should wait. Poll raises timeout
# exception when timeout expired. (integer value)
# Deprecated group/name - [DEFAULT]/rpc_poll_timeout
# from .oslo_messaging_zmq.oslo.messaging.rpc_poll_timeout
{{ if not .oslo_messaging_zmq.oslo.messaging.rpc_poll_timeout }}#{{ end }}rpc_poll_timeout = {{ .oslo_messaging_zmq.oslo.messaging.rpc_poll_timeout | default "1" }}

# Expiration timeout in seconds of a name service record about existing target
# ( < 0 means no timeout). (integer value)
# Deprecated group/name - [DEFAULT]/zmq_target_expire
# from .oslo_messaging_zmq.oslo.messaging.zmq_target_expire
{{ if not .oslo_messaging_zmq.oslo.messaging.zmq_target_expire }}#{{ end }}zmq_target_expire = {{ .oslo_messaging_zmq.oslo.messaging.zmq_target_expire | default "300" }}

# Update period in seconds of a name service record about existing target.
# (integer value)
# Deprecated group/name - [DEFAULT]/zmq_target_update
# from .oslo_messaging_zmq.oslo.messaging.zmq_target_update
{{ if not .oslo_messaging_zmq.oslo.messaging.zmq_target_update }}#{{ end }}zmq_target_update = {{ .oslo_messaging_zmq.oslo.messaging.zmq_target_update | default "180" }}

# Use PUB/SUB pattern for fanout methods. PUB/SUB always uses proxy. (boolean
# value)
# Deprecated group/name - [DEFAULT]/use_pub_sub
# from .oslo_messaging_zmq.oslo.messaging.use_pub_sub
{{ if not .oslo_messaging_zmq.oslo.messaging.use_pub_sub }}#{{ end }}use_pub_sub = {{ .oslo_messaging_zmq.oslo.messaging.use_pub_sub | default "true" }}

# Use ROUTER remote proxy. (boolean value)
# Deprecated group/name - [DEFAULT]/use_router_proxy
# from .oslo_messaging_zmq.oslo.messaging.use_router_proxy
{{ if not .oslo_messaging_zmq.oslo.messaging.use_router_proxy }}#{{ end }}use_router_proxy = {{ .oslo_messaging_zmq.oslo.messaging.use_router_proxy | default "true" }}

# Minimal port number for random ports range. (port value)
# Minimum value: 0
# Maximum value: 65535
# Deprecated group/name - [DEFAULT]/rpc_zmq_min_port
# from .oslo_messaging_zmq.oslo.messaging.rpc_zmq_min_port
{{ if not .oslo_messaging_zmq.oslo.messaging.rpc_zmq_min_port }}#{{ end }}rpc_zmq_min_port = {{ .oslo_messaging_zmq.oslo.messaging.rpc_zmq_min_port | default "49153" }}

# Maximal port number for random ports range. (integer value)
# Minimum value: 1
# Maximum value: 65536
# Deprecated group/name - [DEFAULT]/rpc_zmq_max_port
# from .oslo_messaging_zmq.oslo.messaging.rpc_zmq_max_port
{{ if not .oslo_messaging_zmq.oslo.messaging.rpc_zmq_max_port }}#{{ end }}rpc_zmq_max_port = {{ .oslo_messaging_zmq.oslo.messaging.rpc_zmq_max_port | default "65536" }}

# Number of retries to find free port number before fail with ZMQBindError.
# (integer value)
# Deprecated group/name - [DEFAULT]/rpc_zmq_bind_port_retries
# from .oslo_messaging_zmq.oslo.messaging.rpc_zmq_bind_port_retries
{{ if not .oslo_messaging_zmq.oslo.messaging.rpc_zmq_bind_port_retries }}#{{ end }}rpc_zmq_bind_port_retries = {{ .oslo_messaging_zmq.oslo.messaging.rpc_zmq_bind_port_retries | default "100" }}

# Default serialization mechanism for serializing/deserializing
# outgoing/incoming messages (string value)
# Allowed values: json, msgpack
# Deprecated group/name - [DEFAULT]/rpc_zmq_serialization
# from .oslo_messaging_zmq.oslo.messaging.rpc_zmq_serialization
{{ if not .oslo_messaging_zmq.oslo.messaging.rpc_zmq_serialization }}#{{ end }}rpc_zmq_serialization = {{ .oslo_messaging_zmq.oslo.messaging.rpc_zmq_serialization | default "json" }}

# This option configures round-robin mode in zmq socket. True means not keeping
# a queue when server side disconnects. False means to keep queue and messages
# even if server is disconnected, when the server appears we send all
# accumulated messages to it. (boolean value)
# from .oslo_messaging_zmq.oslo.messaging.zmq_immediate
{{ if not .oslo_messaging_zmq.oslo.messaging.zmq_immediate }}#{{ end }}zmq_immediate = {{ .oslo_messaging_zmq.oslo.messaging.zmq_immediate | default "false" }}


[oslo_policy]

#
# From oslo.policy
#

# The JSON file that defines policies. (string value)
# Deprecated group/name - [DEFAULT]/policy_file
# from .oslo_policy.oslo.policy.policy_file
{{ if not .oslo_policy.oslo.policy.policy_file }}#{{ end }}policy_file = {{ .oslo_policy.oslo.policy.policy_file | default "policy.json" }}

# Default rule. Enforced when a requested rule is not found. (string value)
# Deprecated group/name - [DEFAULT]/policy_default_rule
# from .oslo_policy.oslo.policy.policy_default_rule
{{ if not .oslo_policy.oslo.policy.policy_default_rule }}#{{ end }}policy_default_rule = {{ .oslo_policy.oslo.policy.policy_default_rule | default "default" }}

# Directories where policy configuration files are stored. They can be relative
# to any directory in the search path defined by the config_dir option, or
# absolute paths. The file defined by policy_file must exist for these
# directories to be searched.  Missing or empty directories are ignored. (multi
# valued)
# Deprecated group/name - [DEFAULT]/policy_dirs
# from .oslo_policy.oslo.policy.policy_dirs (multiopt)
{{ if not .oslo_policy.oslo.policy.policy_dirs }}#policy_dirs = {{ .oslo_policy.oslo.policy.policy_dirs | default "policy.d" }}{{ else }}{{ range .oslo_policy.oslo.policy.policy_dirs }}policy_dirs = {{ . }}
{{ end }}{{ end }}


[trust]

#
# From magnum
#

# This setting controls whether to assign a trust to the cluster user or not.
# You will need to set it to True for clusters with volume_driver=cinder or
# registry_enabled=true in the underlying cluster template to work. This is a
# potential security risk since the trust gives instances OpenStack API access
# to the cluster's project. Note that this setting does not affect per-cluster
# trusts assigned to theMagnum service user. (boolean value)
# from .trust.magnum.cluster_user_trust
{{ if not .trust.magnum.cluster_user_trust }}#{{ end }}cluster_user_trust = {{ .trust.magnum.cluster_user_trust | default "false" }}

# Id of the domain to create trustee for clusters (string value)
# from .trust.magnum.trustee_domain_id
{{ if not .trust.magnum.trustee_domain_id }}#{{ end }}trustee_domain_id = {{ .trust.magnum.trustee_domain_id | default "<None>" }}

# Name of the domain to create trustee for s (string value)
# from .trust.magnum.trustee_domain_name
{{ if not .trust.magnum.trustee_domain_name }}#{{ end }}trustee_domain_name = {{ .trust.magnum.trustee_domain_name | default "<None>" }}

# Id of the admin with roles sufficient to manage users in the trustee_domain
# (string value)
# from .trust.magnum.trustee_domain_admin_id
{{ if not .trust.magnum.trustee_domain_admin_id }}#{{ end }}trustee_domain_admin_id = {{ .trust.magnum.trustee_domain_admin_id | default "<None>" }}

# Name of the admin with roles sufficient to manage users in the trustee_domain
# (string value)
# from .trust.magnum.trustee_domain_admin_name
{{ if not .trust.magnum.trustee_domain_admin_name }}#{{ end }}trustee_domain_admin_name = {{ .trust.magnum.trustee_domain_admin_name | default "<None>" }}

# Id of the domain admin user's domain. trustee_domain_id is used by default
# (string value)
# from .trust.magnum.trustee_domain_admin_domain_id
{{ if not .trust.magnum.trustee_domain_admin_domain_id }}#{{ end }}trustee_domain_admin_domain_id = {{ .trust.magnum.trustee_domain_admin_domain_id | default "<None>" }}

# Name of the domain admin user's domain. trustee_domain_name is used by
# default (string value)
# from .trust.magnum.trustee_domain_admin_domain_name
{{ if not .trust.magnum.trustee_domain_admin_domain_name }}#{{ end }}trustee_domain_admin_domain_name = {{ .trust.magnum.trustee_domain_admin_domain_name | default "<None>" }}

# Password of trustee_domain_admin (string value)
# from .trust.magnum.trustee_domain_admin_password
{{ if not .trust.magnum.trustee_domain_admin_password }}#{{ end }}trustee_domain_admin_password = {{ .trust.magnum.trustee_domain_admin_password | default "<None>" }}

# The roles which are delegated to the trustee by the trustor (list value)
# from .trust.magnum.roles
{{ if not .trust.magnum.roles }}#{{ end }}roles = {{ .trust.magnum.roles | default "" }}


[x509]

#
# From magnum
#

# Certificate can get the CA flag in x509 extensions. (boolean value)
# from .x509.magnum.allow_ca
{{ if not .x509.magnum.allow_ca }}#{{ end }}allow_ca = {{ .x509.magnum.allow_ca | default "false" }}

# List of allowed x509 extensions. Available values: "authorityKeyIdentifier",
# "subjectKeyIdentifier", "authorityInfoAccess", "basicConstraints",
# "cRLDistributionPoints", "certificatePolicies", "extendedKeyUsage",
# "OCSPNoCheck", "inhibitAnyPolicy", "keyUsage", "nameConstraints",
# "subjectAltName", "issuerAltName" (list value)
# from .x509.magnum.allowed_extensions
{{ if not .x509.magnum.allowed_extensions }}#{{ end }}allowed_extensions = {{ .x509.magnum.allowed_extensions | default "keyUsage,extendedKeyUsage,subjectAltName,basicConstraints,subjectKeyIdentifier" }}

# List of allowed x509 key usage. Available values: "Digital Signature", "Non
# Repudiation", "Key Encipherment", "Data Encipherment", "Key Agreement",
# "Certificate Sign", "CRL Sign", "Encipher Only", "Decipher Only" (list value)
# from .x509.magnum.allowed_key_usage
{{ if not .x509.magnum.allowed_key_usage }}#{{ end }}allowed_key_usage = {{ .x509.magnum.allowed_key_usage | default "Digital Signature,Key Encipherment,Non Repudiation" }}

# Number of days for which a certificate is valid. (integer value)
# from .x509.magnum.term_of_validity
{{ if not .x509.magnum.term_of_validity }}#{{ end }}term_of_validity = {{ .x509.magnum.term_of_validity | default "1825" }}

# Size of generated private key.  (integer value)
# from .x509.magnum.rsa_key_size
{{ if not .x509.magnum.rsa_key_size }}#{{ end }}rsa_key_size = {{ .x509.magnum.rsa_key_size | default "2048" }}

{{- end -}}
