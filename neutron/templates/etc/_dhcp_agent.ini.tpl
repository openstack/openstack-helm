
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

{{ include "neutron.conf.dhcp_agent_values_skeleton" .Values.conf.dhcp_agent | trunc 0 }}
{{ include "neutron.conf.dhcp_agent" .Values.conf.dhcp_agent }}


{{- define "neutron.conf.dhcp_agent_values_skeleton" -}}

{{- if not .default -}}{{- set . "default" dict -}}{{- end -}}
{{- if not .default.neutron -}}{{- set .default "neutron" dict -}}{{- end -}}
{{- if not .default.neutron.base -}}{{- set .default.neutron "base" dict -}}{{- end -}}
{{- if not .default.neutron.base.agent -}}{{- set .default.neutron.base "agent" dict -}}{{- end -}}
{{- if not .default.neutron.dhcp -}}{{- set .default.neutron "dhcp" dict -}}{{- end -}}
{{- if not .default.neutron.dhcp.agent -}}{{- set .default.neutron.dhcp "agent" dict -}}{{- end -}}
{{- if not .default.oslo -}}{{- set .default "oslo" dict -}}{{- end -}}
{{- if not .default.oslo.log -}}{{- set .default.oslo "log" dict -}}{{- end -}}
{{- if not .agent -}}{{- set . "agent" dict -}}{{- end -}}
{{- if not .agent.neutron -}}{{- set .agent "neutron" dict -}}{{- end -}}
{{- if not .agent.neutron.base -}}{{- set .agent.neutron "base" dict -}}{{- end -}}
{{- if not .agent.neutron.base.agent -}}{{- set .agent.neutron.base "agent" dict -}}{{- end -}}

{{- end -}}


{{- define "neutron.conf.dhcp_agent" -}}

[DEFAULT]

#
# From neutron.base.agent
#

# Name of Open vSwitch bridge to use (string value)
# from .default.neutron.base.agent.ovs_integration_bridge
{{ if not .default.neutron.base.agent.ovs_integration_bridge }}#{{ end }}ovs_integration_bridge = {{ .default.neutron.base.agent.ovs_integration_bridge | default "br-int" }}

# Uses veth for an OVS interface or not. Support kernels with limited namespace
# support (e.g. RHEL 6.5) so long as ovs_use_veth is set to True. (boolean
# value)
# from .default.neutron.base.agent.ovs_use_veth
{{ if not .default.neutron.base.agent.ovs_use_veth }}#{{ end }}ovs_use_veth = {{ .default.neutron.base.agent.ovs_use_veth | default "false" }}

# The driver used to manage the virtual interface. (string value)
# from .default.neutron.base.agent.interface_driver
{{ if not .default.neutron.base.agent.interface_driver }}#{{ end }}interface_driver = {{ .default.neutron.base.agent.interface_driver | default "<None>" }}

# Timeout in seconds for ovs-vsctl commands. If the timeout expires, ovs
# commands will fail with ALARMCLOCK error. (integer value)
# from .default.neutron.base.agent.ovs_vsctl_timeout
{{ if not .default.neutron.base.agent.ovs_vsctl_timeout }}#{{ end }}ovs_vsctl_timeout = {{ .default.neutron.base.agent.ovs_vsctl_timeout | default "10" }}

#
# From neutron.dhcp.agent
#

# The DHCP agent will resync its state with Neutron to recover from any
# transient notification or RPC errors. The interval is number of seconds
# between attempts. (integer value)
# from .default.neutron.dhcp.agent.resync_interval
{{ if not .default.neutron.dhcp.agent.resync_interval }}#{{ end }}resync_interval = {{ .default.neutron.dhcp.agent.resync_interval | default "5" }}

# The driver used to manage the DHCP server. (string value)
# from .default.neutron.dhcp.agent.dhcp_driver
{{ if not .default.neutron.dhcp.agent.dhcp_driver }}#{{ end }}dhcp_driver = {{ .default.neutron.dhcp.agent.dhcp_driver | default "neutron.agent.linux.dhcp.Dnsmasq" }}

# The DHCP server can assist with providing metadata support on isolated
# networks. Setting this value to True will cause the DHCP server to append
# specific host routes to the DHCP request. The metadata service will only be
# activated when the subnet does not contain any router port. The guest
# instance must be configured to request host routes via DHCP (Option 121).
# This option doesn't have any effect when force_metadata is set to True.
# (boolean value)
# from .default.neutron.dhcp.agent.enable_isolated_metadata
{{ if not .default.neutron.dhcp.agent.enable_isolated_metadata }}#{{ end }}enable_isolated_metadata = {{ .default.neutron.dhcp.agent.enable_isolated_metadata | default "false" }}

# In some cases the Neutron router is not present to provide the metadata IP
# but the DHCP server can be used to provide this info. Setting this value will
# force the DHCP server to append specific host routes to the DHCP request. If
# this option is set, then the metadata service will be activated for all the
# networks. (boolean value)
# from .default.neutron.dhcp.agent.force_metadata
{{ if not .default.neutron.dhcp.agent.force_metadata }}#{{ end }}force_metadata = {{ .default.neutron.dhcp.agent.force_metadata | default "false" }}

# Allows for serving metadata requests coming from a dedicated metadata access
# network whose CIDR is 169.254.169.254/16 (or larger prefix), and is connected
# to a Neutron router from which the VMs send metadata:1 request. In this case
# DHCP Option 121 will not be injected in VMs, as they will be able to reach
# 169.254.169.254 through a router. This option requires
# enable_isolated_metadata = True. (boolean value)
# from .default.neutron.dhcp.agent.enable_metadata_network
{{ if not .default.neutron.dhcp.agent.enable_metadata_network }}#{{ end }}enable_metadata_network = {{ .default.neutron.dhcp.agent.enable_metadata_network | default "false" }}

# Number of threads to use during sync process. Should not exceed connection
# pool size configured on server. (integer value)
# from .default.neutron.dhcp.agent.num_sync_threads
{{ if not .default.neutron.dhcp.agent.num_sync_threads }}#{{ end }}num_sync_threads = {{ .default.neutron.dhcp.agent.num_sync_threads | default "4" }}

# Location to store DHCP server config files. (string value)
# from .default.neutron.dhcp.agent.dhcp_confs
{{ if not .default.neutron.dhcp.agent.dhcp_confs }}#{{ end }}dhcp_confs = {{ .default.neutron.dhcp.agent.dhcp_confs | default "$state_path/dhcp" }}

# DEPRECATED: Domain to use for building the hostnames. This option is
# deprecated. It has been moved to neutron.conf as dns_domain. It will be
# removed in a future release. (string value)
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# from .default.neutron.dhcp.agent.dhcp_domain
{{ if not .default.neutron.dhcp.agent.dhcp_domain }}#{{ end }}dhcp_domain = {{ .default.neutron.dhcp.agent.dhcp_domain | default "openstacklocal" }}

# Override the default dnsmasq settings with this file. (string value)
# from .default.neutron.dhcp.agent.dnsmasq_config_file
{{ if not .default.neutron.dhcp.agent.dnsmasq_config_file }}#{{ end }}dnsmasq_config_file = {{ .default.neutron.dhcp.agent.dnsmasq_config_file | default "" }}

# Comma-separated list of the DNS servers which will be used as forwarders.
# (list value)
# from .default.neutron.dhcp.agent.dnsmasq_dns_servers
{{ if not .default.neutron.dhcp.agent.dnsmasq_dns_servers }}#{{ end }}dnsmasq_dns_servers = {{ .default.neutron.dhcp.agent.dnsmasq_dns_servers | default "" }}

# Base log dir for dnsmasq logging. The log contains DHCP and DNS log
# information and is useful for debugging issues with either DHCP or DNS. If
# this section is null, disable dnsmasq log. (string value)
# from .default.neutron.dhcp.agent.dnsmasq_base_log_dir
{{ if not .default.neutron.dhcp.agent.dnsmasq_base_log_dir }}#{{ end }}dnsmasq_base_log_dir = {{ .default.neutron.dhcp.agent.dnsmasq_base_log_dir | default "<None>" }}

# Enables the dnsmasq service to provide name resolution for instances via DNS
# resolvers on the host running the DHCP agent. Effectively removes the '--no-
# resolv' option from the dnsmasq process arguments. Adding custom DNS
# resolvers to the 'dnsmasq_dns_servers' option disables this feature. (boolean
# value)
# from .default.neutron.dhcp.agent.dnsmasq_local_resolv
{{ if not .default.neutron.dhcp.agent.dnsmasq_local_resolv }}#{{ end }}dnsmasq_local_resolv = {{ .default.neutron.dhcp.agent.dnsmasq_local_resolv | default "false" }}

# Limit number of leases to prevent a denial-of-service. (integer value)
# from .default.neutron.dhcp.agent.dnsmasq_lease_max
{{ if not .default.neutron.dhcp.agent.dnsmasq_lease_max }}#{{ end }}dnsmasq_lease_max = {{ .default.neutron.dhcp.agent.dnsmasq_lease_max | default "16777216" }}

# Use broadcast in DHCP replies. (boolean value)
# from .default.neutron.dhcp.agent.dhcp_broadcast_reply
{{ if not .default.neutron.dhcp.agent.dhcp_broadcast_reply }}#{{ end }}dhcp_broadcast_reply = {{ .default.neutron.dhcp.agent.dhcp_broadcast_reply | default "false" }}

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
# From neutron.base.agent
#

# Seconds between nodes reporting state to server; should be less than
# agent_down_time, best if it is half or less than agent_down_time. (floating
# point value)
# from .agent.neutron.base.agent.report_interval
{{ if not .agent.neutron.base.agent.report_interval }}#{{ end }}report_interval = {{ .agent.neutron.base.agent.report_interval | default "30" }}

# Log agent heartbeats (boolean value)
# from .agent.neutron.base.agent.log_agent_heartbeats
{{ if not .agent.neutron.base.agent.log_agent_heartbeats }}#{{ end }}log_agent_heartbeats = {{ .agent.neutron.base.agent.log_agent_heartbeats | default "false" }}

# Availability zone of this node (string value)
# from .agent.neutron.base.agent.availability_zone
{{ if not .agent.neutron.base.agent.availability_zone }}#{{ end }}availability_zone = {{ .agent.neutron.base.agent.availability_zone | default "nova" }}

{{- end -}}
