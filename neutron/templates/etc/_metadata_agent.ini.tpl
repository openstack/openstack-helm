
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

{{ include "neutron.conf.metadata_agent_values_skeleton" .Values.conf.metadata_agent | trunc 0 }}
{{ include "neutron.conf.metadata_agent" .Values.conf.metadata_agent }}


{{- define "neutron.conf.metadata_agent_values_skeleton" -}}

{{- if not .default -}}{{- set . "default" dict -}}{{- end -}}
{{- if not .default.neutron -}}{{- set .default "neutron" dict -}}{{- end -}}
{{- if not .default.neutron.metadata -}}{{- set .default.neutron "metadata" dict -}}{{- end -}}
{{- if not .default.neutron.metadata.agent -}}{{- set .default.neutron.metadata "agent" dict -}}{{- end -}}
{{- if not .default.oslo -}}{{- set .default "oslo" dict -}}{{- end -}}
{{- if not .default.oslo.log -}}{{- set .default.oslo "log" dict -}}{{- end -}}
{{- if not .agent -}}{{- set . "agent" dict -}}{{- end -}}
{{- if not .agent.neutron -}}{{- set .agent "neutron" dict -}}{{- end -}}
{{- if not .agent.neutron.metadata -}}{{- set .agent.neutron "metadata" dict -}}{{- end -}}
{{- if not .agent.neutron.metadata.agent -}}{{- set .agent.neutron.metadata "agent" dict -}}{{- end -}}
{{- if not .cache -}}{{- set . "cache" dict -}}{{- end -}}
{{- if not .cache.oslo -}}{{- set .cache "oslo" dict -}}{{- end -}}
{{- if not .cache.oslo.cache -}}{{- set .cache.oslo "cache" dict -}}{{- end -}}

{{- end -}}


{{- define "neutron.conf.metadata_agent" -}}

[DEFAULT]

#
# From neutron.metadata.agent
#

# Location for Metadata Proxy UNIX domain socket. (string value)
# from .default.neutron.metadata.agent.metadata_proxy_socket
{{ if not .default.neutron.metadata.agent.metadata_proxy_socket }}#{{ end }}metadata_proxy_socket = {{ .default.neutron.metadata.agent.metadata_proxy_socket | default "$state_path/metadata_proxy" }}

# User (uid or name) running metadata proxy after its initialization (if empty:
# agent effective user). (string value)
# from .default.neutron.metadata.agent.metadata_proxy_user
{{ if not .default.neutron.metadata.agent.metadata_proxy_user }}#{{ end }}metadata_proxy_user = {{ .default.neutron.metadata.agent.metadata_proxy_user | default "" }}

# Group (gid or name) running metadata proxy after its initialization (if
# empty: agent effective group). (string value)
# from .default.neutron.metadata.agent.metadata_proxy_group
{{ if not .default.neutron.metadata.agent.metadata_proxy_group }}#{{ end }}metadata_proxy_group = {{ .default.neutron.metadata.agent.metadata_proxy_group | default "" }}

# Certificate Authority public key (CA cert) file for ssl (string value)
# from .default.neutron.metadata.agent.auth_ca_cert
{{ if not .default.neutron.metadata.agent.auth_ca_cert }}#{{ end }}auth_ca_cert = {{ .default.neutron.metadata.agent.auth_ca_cert | default "<None>" }}

# IP address used by Nova metadata server. (string value)
# from .default.neutron.metadata.agent.nova_metadata_ip
{{ if not .default.neutron.metadata.agent.nova_metadata_ip }}#{{ end }}nova_metadata_ip = {{ .default.neutron.metadata.agent.nova_metadata_ip | default "127.0.0.1" }}

# TCP Port used by Nova metadata server. (port value)
# Minimum value: 0
# Maximum value: 65535
# from .default.neutron.metadata.agent.nova_metadata_port
{{ if not .default.neutron.metadata.agent.nova_metadata_port }}#{{ end }}nova_metadata_port = {{ .default.neutron.metadata.agent.nova_metadata_port | default "8775" }}

# When proxying metadata requests, Neutron signs the Instance-ID header with a
# shared secret to prevent spoofing. You may select any string for a secret,
# but it must match here and in the configuration used by the Nova Metadata
# Server. NOTE: Nova uses the same config key, but in [neutron] section.
# (string value)
# from .default.neutron.metadata.agent.metadata_proxy_shared_secret
{{ if not .default.neutron.metadata.agent.metadata_proxy_shared_secret }}#{{ end }}metadata_proxy_shared_secret = {{ .default.neutron.metadata.agent.metadata_proxy_shared_secret | default "" }}

# Protocol to access nova metadata, http or https (string value)
# Allowed values: http, https
# from .default.neutron.metadata.agent.nova_metadata_protocol
{{ if not .default.neutron.metadata.agent.nova_metadata_protocol }}#{{ end }}nova_metadata_protocol = {{ .default.neutron.metadata.agent.nova_metadata_protocol | default "http" }}

# Allow to perform insecure SSL (https) requests to nova metadata (boolean
# value)
# from .default.neutron.metadata.agent.nova_metadata_insecure
{{ if not .default.neutron.metadata.agent.nova_metadata_insecure }}#{{ end }}nova_metadata_insecure = {{ .default.neutron.metadata.agent.nova_metadata_insecure | default "false" }}

# Client certificate for nova metadata api server. (string value)
# from .default.neutron.metadata.agent.nova_client_cert
{{ if not .default.neutron.metadata.agent.nova_client_cert }}#{{ end }}nova_client_cert = {{ .default.neutron.metadata.agent.nova_client_cert | default "" }}

# Private key of client certificate. (string value)
# from .default.neutron.metadata.agent.nova_client_priv_key
{{ if not .default.neutron.metadata.agent.nova_client_priv_key }}#{{ end }}nova_client_priv_key = {{ .default.neutron.metadata.agent.nova_client_priv_key | default "" }}

# Metadata Proxy UNIX domain socket mode, 4 values allowed: 'deduce': deduce
# mode from metadata_proxy_user/group values, 'user': set metadata proxy socket
# mode to 0o644, to use when metadata_proxy_user is agent effective user or
# root, 'group': set metadata proxy socket mode to 0o664, to use when
# metadata_proxy_group is agent effective group or root, 'all': set metadata
# proxy socket mode to 0o666, to use otherwise. (string value)
# Allowed values: deduce, user, group, all
# from .default.neutron.metadata.agent.metadata_proxy_socket_mode
{{ if not .default.neutron.metadata.agent.metadata_proxy_socket_mode }}#{{ end }}metadata_proxy_socket_mode = {{ .default.neutron.metadata.agent.metadata_proxy_socket_mode | default "deduce" }}

# Number of separate worker processes for metadata server (defaults to half of
# the number of CPUs) (integer value)
# from .default.neutron.metadata.agent.metadata_workers
{{ if not .default.neutron.metadata.agent.metadata_workers }}#{{ end }}metadata_workers = {{ .default.neutron.metadata.agent.metadata_workers | default "4" }}

# Number of backlog requests to configure the metadata server socket with
# (integer value)
# from .default.neutron.metadata.agent.metadata_backlog
{{ if not .default.neutron.metadata.agent.metadata_backlog }}#{{ end }}metadata_backlog = {{ .default.neutron.metadata.agent.metadata_backlog | default "4096" }}

# DEPRECATED: URL to connect to the cache back end. This option is deprecated
# in the Newton release and will be removed. Please add a [cache] group for
# oslo.cache in your neutron.conf and add "enable" and "backend" options in
# this section. (string value)
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# from .default.neutron.metadata.agent.cache_url
{{ if not .default.neutron.metadata.agent.cache_url }}#{{ end }}cache_url = {{ .default.neutron.metadata.agent.cache_url | default "" }}

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


[AGENT]

#
# From neutron.metadata.agent
#

# Seconds between nodes reporting state to server; should be less than
# agent_down_time, best if it is half or less than agent_down_time. (floating
# point value)
# from .agent.neutron.metadata.agent.report_interval
{{ if not .agent.neutron.metadata.agent.report_interval }}#{{ end }}report_interval = {{ .agent.neutron.metadata.agent.report_interval | default "30" }}

# Log agent heartbeats (boolean value)
# from .agent.neutron.metadata.agent.log_agent_heartbeats
{{ if not .agent.neutron.metadata.agent.log_agent_heartbeats }}#{{ end }}log_agent_heartbeats = {{ .agent.neutron.metadata.agent.log_agent_heartbeats | default "false" }}


[cache]

#
# From oslo.cache
#

# Prefix for building the configuration dictionary for the cache region. This
# should not need to be changed unless there is another dogpile.cache region
# with the same configuration name. (string value)
# from .cache.oslo.cache.config_prefix
{{ if not .cache.oslo.cache.config_prefix }}#{{ end }}config_prefix = {{ .cache.oslo.cache.config_prefix | default "cache.oslo" }}

# Default TTL, in seconds, for any cached item in the dogpile.cache region.
# This applies to any cached method that doesn't have an explicit cache
# expiration time defined for it. (integer value)
# from .cache.oslo.cache.expiration_time
{{ if not .cache.oslo.cache.expiration_time }}#{{ end }}expiration_time = {{ .cache.oslo.cache.expiration_time | default "600" }}

# Dogpile.cache backend module. It is recommended that Memcache or Redis
# (dogpile.cache.redis) be used in production deployments. For eventlet-based
# or highly threaded servers, Memcache with pooling (oslo_cache.memcache_pool)
# is recommended. For low thread servers, dogpile.cache.memcached is
# recommended. Test environments with a single instance of the server can use
# the dogpile.cache.memory backend. (string value)
# from .cache.oslo.cache.backend
{{ if not .cache.oslo.cache.backend }}#{{ end }}backend = {{ .cache.oslo.cache.backend | default "dogpile.cache.null" }}

# Arguments supplied to the backend module. Specify this option once per
# argument to be passed to the dogpile.cache backend. Example format:
# "<argname>:<value>". (multi valued)
# from .cache.oslo.cache.backend_argument (multiopt)
{{ if not .cache.oslo.cache.backend_argument }}#backend_argument = {{ .cache.oslo.cache.backend_argument | default "" }}{{ else }}{{ range .cache.oslo.cache.backend_argument }}backend_argument = {{ . }}
{{ end }}{{ end }}

# Proxy classes to import that will affect the way the dogpile.cache backend
# functions. See the dogpile.cache documentation on changing-backend-behavior.
# (list value)
# from .cache.oslo.cache.proxies
{{ if not .cache.oslo.cache.proxies }}#{{ end }}proxies = {{ .cache.oslo.cache.proxies | default "" }}

# Global toggle for caching. (boolean value)
# from .cache.oslo.cache.enabled
{{ if not .cache.oslo.cache.enabled }}#{{ end }}enabled = {{ .cache.oslo.cache.enabled | default "false" }}

# Extra debugging from the cache backend (cache keys, get/set/delete/etc
# calls). This is only really useful if you need to see the specific cache-
# backend get/set/delete calls with the keys/values.  Typically this should be
# left set to false. (boolean value)
# from .cache.oslo.cache.debug_cache_backend
{{ if not .cache.oslo.cache.debug_cache_backend }}#{{ end }}debug_cache_backend = {{ .cache.oslo.cache.debug_cache_backend | default "false" }}

# Memcache servers in the format of "host:port". (dogpile.cache.memcache and
# oslo_cache.memcache_pool backends only). (list value)
# from .cache.oslo.cache.memcache_servers
{{ if not .cache.oslo.cache.memcache_servers }}#{{ end }}memcache_servers = {{ .cache.oslo.cache.memcache_servers | default "localhost:11211" }}

# Number of seconds memcached server is considered dead before it is tried
# again. (dogpile.cache.memcache and oslo_cache.memcache_pool backends only).
# (integer value)
# from .cache.oslo.cache.memcache_dead_retry
{{ if not .cache.oslo.cache.memcache_dead_retry }}#{{ end }}memcache_dead_retry = {{ .cache.oslo.cache.memcache_dead_retry | default "300" }}

# Timeout in seconds for every call to a server. (dogpile.cache.memcache and
# oslo_cache.memcache_pool backends only). (integer value)
# from .cache.oslo.cache.memcache_socket_timeout
{{ if not .cache.oslo.cache.memcache_socket_timeout }}#{{ end }}memcache_socket_timeout = {{ .cache.oslo.cache.memcache_socket_timeout | default "3" }}

# Max total number of open connections to every memcached server.
# (oslo_cache.memcache_pool backend only). (integer value)
# from .cache.oslo.cache.memcache_pool_maxsize
{{ if not .cache.oslo.cache.memcache_pool_maxsize }}#{{ end }}memcache_pool_maxsize = {{ .cache.oslo.cache.memcache_pool_maxsize | default "10" }}

# Number of seconds a connection to memcached is held unused in the pool before
# it is closed. (oslo_cache.memcache_pool backend only). (integer value)
# from .cache.oslo.cache.memcache_pool_unused_timeout
{{ if not .cache.oslo.cache.memcache_pool_unused_timeout }}#{{ end }}memcache_pool_unused_timeout = {{ .cache.oslo.cache.memcache_pool_unused_timeout | default "60" }}

# Number of seconds that an operation will wait to get a memcache client
# connection. (integer value)
# from .cache.oslo.cache.memcache_pool_connection_get_timeout
{{ if not .cache.oslo.cache.memcache_pool_connection_get_timeout }}#{{ end }}memcache_pool_connection_get_timeout = {{ .cache.oslo.cache.memcache_pool_connection_get_timeout | default "10" }}

{{- end -}}
