
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

{{ include "neutron.conf.linuxbridge_agent_values_skeleton" .Values.conf.linuxbridge_agent | trunc 0 }}
{{ include "neutron.conf.linuxbridge_agent" .Values.conf.linuxbridge_agent }}


{{- define "neutron.conf.linuxbridge_agent_values_skeleton" -}}

{{- if not .default -}}{{- set . "default" dict -}}{{- end -}}
{{- if not .default.oslo -}}{{- set .default "oslo" dict -}}{{- end -}}
{{- if not .default.oslo.log -}}{{- set .default.oslo "log" dict -}}{{- end -}}
{{- if not .agent -}}{{- set . "agent" dict -}}{{- end -}}
{{- if not .agent.neutron -}}{{- set .agent "neutron" dict -}}{{- end -}}
{{- if not .agent.neutron.ml2 -}}{{- set .agent.neutron "ml2" dict -}}{{- end -}}
{{- if not .agent.neutron.ml2.linuxbridge -}}{{- set .agent.neutron.ml2 "linuxbridge" dict -}}{{- end -}}
{{- if not .agent.neutron.ml2.linuxbridge.agent -}}{{- set .agent.neutron.ml2.linuxbridge "agent" dict -}}{{- end -}}
{{- if not .linux_bridge -}}{{- set . "linux_bridge" dict -}}{{- end -}}
{{- if not .linux_bridge.neutron -}}{{- set .linux_bridge "neutron" dict -}}{{- end -}}
{{- if not .linux_bridge.neutron.ml2 -}}{{- set .linux_bridge.neutron "ml2" dict -}}{{- end -}}
{{- if not .linux_bridge.neutron.ml2.linuxbridge -}}{{- set .linux_bridge.neutron.ml2 "linuxbridge" dict -}}{{- end -}}
{{- if not .linux_bridge.neutron.ml2.linuxbridge.agent -}}{{- set .linux_bridge.neutron.ml2.linuxbridge "agent" dict -}}{{- end -}}
{{- if not .securitygroup -}}{{- set . "securitygroup" dict -}}{{- end -}}
{{- if not .securitygroup.neutron -}}{{- set .securitygroup "neutron" dict -}}{{- end -}}
{{- if not .securitygroup.neutron.ml2 -}}{{- set .securitygroup.neutron "ml2" dict -}}{{- end -}}
{{- if not .securitygroup.neutron.ml2.linuxbridge -}}{{- set .securitygroup.neutron.ml2 "linuxbridge" dict -}}{{- end -}}
{{- if not .securitygroup.neutron.ml2.linuxbridge.agent -}}{{- set .securitygroup.neutron.ml2.linuxbridge "agent" dict -}}{{- end -}}
{{- if not .vxlan -}}{{- set . "vxlan" dict -}}{{- end -}}
{{- if not .vxlan.neutron -}}{{- set .vxlan "neutron" dict -}}{{- end -}}
{{- if not .vxlan.neutron.ml2 -}}{{- set .vxlan.neutron "ml2" dict -}}{{- end -}}
{{- if not .vxlan.neutron.ml2.linuxbridge -}}{{- set .vxlan.neutron.ml2 "linuxbridge" dict -}}{{- end -}}
{{- if not .vxlan.neutron.ml2.linuxbridge.agent -}}{{- set .vxlan.neutron.ml2.linuxbridge "agent" dict -}}{{- end -}}

{{- end -}}


{{- define "neutron.conf.linuxbridge_agent" -}}

[DEFAULT]

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


[agent]

#
# From neutron.ml2.linuxbridge.agent
#

# The number of seconds the agent will wait between polling for local device
# changes. (integer value)
# from .agent.neutron.ml2.linuxbridge.agent.polling_interval
{{ if not .agent.neutron.ml2.linuxbridge.agent.polling_interval }}#{{ end }}polling_interval = {{ .agent.neutron.ml2.linuxbridge.agent.polling_interval | default "2" }}

# Set new timeout in seconds for new rpc calls after agent receives SIGTERM. If
# value is set to 0, rpc timeout won't be changed (integer value)
# from .agent.neutron.ml2.linuxbridge.agent.quitting_rpc_timeout
{{ if not .agent.neutron.ml2.linuxbridge.agent.quitting_rpc_timeout }}#{{ end }}quitting_rpc_timeout = {{ .agent.neutron.ml2.linuxbridge.agent.quitting_rpc_timeout | default "10" }}

# DEPRECATED: Enable suppression of ARP responses that don't match an IP
# address that belongs to the port from which they originate. Note: This
# prevents the VMs attached to this agent from spoofing, it doesn't protect
# them from other devices which have the capability to spoof (e.g. bare metal
# or VMs attached to agents without this flag set to True). Spoofing rules will
# not be added to any ports that have port security disabled. For LinuxBridge,
# this requires ebtables. For OVS, it requires a version that supports matching
# ARP headers. This option will be removed in Ocata so the only way to disable
# protection will be via the port security extension. (boolean value)
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# from .agent.neutron.ml2.linuxbridge.agent.prevent_arp_spoofing
{{ if not .agent.neutron.ml2.linuxbridge.agent.prevent_arp_spoofing }}#{{ end }}prevent_arp_spoofing = {{ .agent.neutron.ml2.linuxbridge.agent.prevent_arp_spoofing | default "true" }}

# Extensions list to use (list value)
# from .agent.neutron.ml2.linuxbridge.agent.extensions
{{ if not .agent.neutron.ml2.linuxbridge.agent.extensions }}#{{ end }}extensions = {{ .agent.neutron.ml2.linuxbridge.agent.extensions | default "" }}


[linux_bridge]

#
# From neutron.ml2.linuxbridge.agent
#

# Comma-separated list of <physical_network>:<physical_interface> tuples
# mapping physical network names to the agent's node-specific physical network
# interfaces to be used for flat and VLAN networks. All physical networks
# listed in network_vlan_ranges on the server should have mappings to
# appropriate interfaces on each agent. (list value)
# from .linux_bridge.neutron.ml2.linuxbridge.agent.physical_interface_mappings
{{ if not .linux_bridge.neutron.ml2.linuxbridge.agent.physical_interface_mappings }}#{{ end }}physical_interface_mappings = {{ .linux_bridge.neutron.ml2.linuxbridge.agent.physical_interface_mappings | default "" }}

# List of <physical_network>:<physical_bridge> (list value)
# from .linux_bridge.neutron.ml2.linuxbridge.agent.bridge_mappings
{{ if not .linux_bridge.neutron.ml2.linuxbridge.agent.bridge_mappings }}#{{ end }}bridge_mappings = {{ .linux_bridge.neutron.ml2.linuxbridge.agent.bridge_mappings | default "" }}


[securitygroup]

#
# From neutron.ml2.linuxbridge.agent
#

# Driver for security groups firewall in the L2 agent (string value)
# from .securitygroup.neutron.ml2.linuxbridge.agent.firewall_driver
{{ if not .securitygroup.neutron.ml2.linuxbridge.agent.firewall_driver }}#{{ end }}firewall_driver = {{ .securitygroup.neutron.ml2.linuxbridge.agent.firewall_driver | default "<None>" }}

# Controls whether the neutron security group API is enabled in the server. It
# should be false when using no security groups or using the nova security
# group API. (boolean value)
# from .securitygroup.neutron.ml2.linuxbridge.agent.enable_security_group
{{ if not .securitygroup.neutron.ml2.linuxbridge.agent.enable_security_group }}#{{ end }}enable_security_group = {{ .securitygroup.neutron.ml2.linuxbridge.agent.enable_security_group | default "true" }}

# Use ipset to speed-up the iptables based security groups. Enabling ipset
# support requires that ipset is installed on L2 agent node. (boolean value)
# from .securitygroup.neutron.ml2.linuxbridge.agent.enable_ipset
{{ if not .securitygroup.neutron.ml2.linuxbridge.agent.enable_ipset }}#{{ end }}enable_ipset = {{ .securitygroup.neutron.ml2.linuxbridge.agent.enable_ipset | default "true" }}


[vxlan]

#
# From neutron.ml2.linuxbridge.agent
#

# Enable VXLAN on the agent. Can be enabled when agent is managed by ml2 plugin
# using linuxbridge mechanism driver (boolean value)
# from .vxlan.neutron.ml2.linuxbridge.agent.enable_vxlan
{{ if not .vxlan.neutron.ml2.linuxbridge.agent.enable_vxlan }}#{{ end }}enable_vxlan = {{ .vxlan.neutron.ml2.linuxbridge.agent.enable_vxlan | default "true" }}

# TTL for vxlan interface protocol packets. (integer value)
# from .vxlan.neutron.ml2.linuxbridge.agent.ttl
{{ if not .vxlan.neutron.ml2.linuxbridge.agent.ttl }}#{{ end }}ttl = {{ .vxlan.neutron.ml2.linuxbridge.agent.ttl | default "<None>" }}

# TOS for vxlan interface protocol packets. (integer value)
# from .vxlan.neutron.ml2.linuxbridge.agent.tos
{{ if not .vxlan.neutron.ml2.linuxbridge.agent.tos }}#{{ end }}tos = {{ .vxlan.neutron.ml2.linuxbridge.agent.tos | default "<None>" }}

# Multicast group(s) for vxlan interface. A range of group addresses may be
# specified by using CIDR notation. Specifying a range allows different VNIs to
# use different group addresses, reducing or eliminating spurious broadcast
# traffic to the tunnel endpoints. To reserve a unique group for each possible
# (24-bit) VNI, use a /8 such as 239.0.0.0/8. This setting must be the same on
# all the agents. (string value)
# from .vxlan.neutron.ml2.linuxbridge.agent.vxlan_group
{{ if not .vxlan.neutron.ml2.linuxbridge.agent.vxlan_group }}#{{ end }}vxlan_group = {{ .vxlan.neutron.ml2.linuxbridge.agent.vxlan_group | default "224.0.0.1" }}

# IP address of local overlay (tunnel) network endpoint. Use either an IPv4 or
# IPv6 address that resides on one of the host network interfaces. The IP
# version of this value must match the value of the 'overlay_ip_version' option
# in the ML2 plug-in configuration file on the neutron server node(s). (IP
# address value)
# from .vxlan.neutron.ml2.linuxbridge.agent.local_ip
{{ if not .vxlan.neutron.ml2.linuxbridge.agent.local_ip }}#{{ end }}local_ip = {{ .vxlan.neutron.ml2.linuxbridge.agent.local_ip | default "<None>" }}

# Extension to use alongside ml2 plugin's l2population mechanism driver. It
# enables the plugin to populate VXLAN forwarding table. (boolean value)
# from .vxlan.neutron.ml2.linuxbridge.agent.l2_population
{{ if not .vxlan.neutron.ml2.linuxbridge.agent.l2_population }}#{{ end }}l2_population = {{ .vxlan.neutron.ml2.linuxbridge.agent.l2_population | default "false" }}

# Enable local ARP responder which provides local responses instead of
# performing ARP broadcast into the overlay. Enabling local ARP responder is
# not fully compatible with the allowed-address-pairs extension. (boolean
# value)
# from .vxlan.neutron.ml2.linuxbridge.agent.arp_responder
{{ if not .vxlan.neutron.ml2.linuxbridge.agent.arp_responder }}#{{ end }}arp_responder = {{ .vxlan.neutron.ml2.linuxbridge.agent.arp_responder | default "false" }}

{{- end -}}
