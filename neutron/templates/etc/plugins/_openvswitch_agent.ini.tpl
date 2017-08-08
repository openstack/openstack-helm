
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

{{ include "neutron.conf.openvswitch_agent_values_skeleton" .Values.conf.openvswitch_agent | trunc 0 }}
{{ include "neutron.conf.openvswitch_agent" .Values.conf.openvswitch_agent }}


{{- define "neutron.conf.openvswitch_agent_values_skeleton" -}}

{{- if not .default -}}{{- set . "default" dict -}}{{- end -}}
{{- if not .default.oslo -}}{{- set .default "oslo" dict -}}{{- end -}}
{{- if not .default.oslo.log -}}{{- set .default.oslo "log" dict -}}{{- end -}}
{{- if not .agent -}}{{- set . "agent" dict -}}{{- end -}}
{{- if not .agent.neutron -}}{{- set .agent "neutron" dict -}}{{- end -}}
{{- if not .agent.neutron.ml2 -}}{{- set .agent.neutron "ml2" dict -}}{{- end -}}
{{- if not .agent.neutron.ml2.ovs -}}{{- set .agent.neutron.ml2 "ovs" dict -}}{{- end -}}
{{- if not .agent.neutron.ml2.ovs.agent -}}{{- set .agent.neutron.ml2.ovs "agent" dict -}}{{- end -}}
{{- if not .ovs -}}{{- set . "ovs" dict -}}{{- end -}}
{{- if not .ovs.neutron -}}{{- set .ovs "neutron" dict -}}{{- end -}}
{{- if not .ovs.neutron.ml2 -}}{{- set .ovs.neutron "ml2" dict -}}{{- end -}}
{{- if not .ovs.neutron.ml2.ovs -}}{{- set .ovs.neutron.ml2 "ovs" dict -}}{{- end -}}
{{- if not .ovs.neutron.ml2.ovs.agent -}}{{- set .ovs.neutron.ml2.ovs "agent" dict -}}{{- end -}}
{{- if not .securitygroup -}}{{- set . "securitygroup" dict -}}{{- end -}}
{{- if not .securitygroup.neutron -}}{{- set .securitygroup "neutron" dict -}}{{- end -}}
{{- if not .securitygroup.neutron.ml2 -}}{{- set .securitygroup.neutron "ml2" dict -}}{{- end -}}
{{- if not .securitygroup.neutron.ml2.ovs -}}{{- set .securitygroup.neutron.ml2 "ovs" dict -}}{{- end -}}
{{- if not .securitygroup.neutron.ml2.ovs.agent -}}{{- set .securitygroup.neutron.ml2.ovs "agent" dict -}}{{- end -}}

{{- end -}}


{{- define "neutron.conf.openvswitch_agent" -}}

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
# From neutron.ml2.ovs.agent
#

# The number of seconds the agent will wait between polling for local device
# changes. (integer value)
# from .agent.neutron.ml2.ovs.agent.polling_interval
{{ if not .agent.neutron.ml2.ovs.agent.polling_interval }}#{{ end }}polling_interval = {{ .agent.neutron.ml2.ovs.agent.polling_interval | default "2" }}

# Minimize polling by monitoring ovsdb for interface changes. (boolean value)
# from .agent.neutron.ml2.ovs.agent.minimize_polling
{{ if not .agent.neutron.ml2.ovs.agent.minimize_polling }}#{{ end }}minimize_polling = {{ .agent.neutron.ml2.ovs.agent.minimize_polling | default "true" }}

# The number of seconds to wait before respawning the ovsdb monitor after
# losing communication with it. (integer value)
# from .agent.neutron.ml2.ovs.agent.ovsdb_monitor_respawn_interval
{{ if not .agent.neutron.ml2.ovs.agent.ovsdb_monitor_respawn_interval }}#{{ end }}ovsdb_monitor_respawn_interval = {{ .agent.neutron.ml2.ovs.agent.ovsdb_monitor_respawn_interval | default "30" }}

# Network types supported by the agent (gre and/or vxlan). (list value)
# from .agent.neutron.ml2.ovs.agent.tunnel_types
{{ if not .agent.neutron.ml2.ovs.agent.tunnel_types }}#{{ end }}tunnel_types = {{ .agent.neutron.ml2.ovs.agent.tunnel_types | default "" }}

# The UDP port to use for VXLAN tunnels. (port value)
# Minimum value: 0
# Maximum value: 65535
# from .agent.neutron.ml2.ovs.agent.vxlan_udp_port
{{ if not .agent.neutron.ml2.ovs.agent.vxlan_udp_port }}#{{ end }}vxlan_udp_port = {{ .agent.neutron.ml2.ovs.agent.vxlan_udp_port | default "4789" }}

# MTU size of veth interfaces (integer value)
# from .agent.neutron.ml2.ovs.agent.veth_mtu
{{ if not .agent.neutron.ml2.ovs.agent.veth_mtu }}#{{ end }}veth_mtu = {{ .agent.neutron.ml2.ovs.agent.veth_mtu | default "9000" }}

# Use ML2 l2population mechanism driver to learn remote MAC and IPs and improve
# tunnel scalability. (boolean value)
# from .agent.neutron.ml2.ovs.agent.l2_population
{{ if not .agent.neutron.ml2.ovs.agent.l2_population }}#{{ end }}l2_population = {{ .agent.neutron.ml2.ovs.agent.l2_population | default "false" }}

# Enable local ARP responder if it is supported. Requires OVS 2.1 and ML2
# l2population driver. Allows the switch (when supporting an overlay) to
# respond to an ARP request locally without performing a costly ARP broadcast
# into the overlay. (boolean value)
# from .agent.neutron.ml2.ovs.agent.arp_responder
{{ if not .agent.neutron.ml2.ovs.agent.arp_responder }}#{{ end }}arp_responder = {{ .agent.neutron.ml2.ovs.agent.arp_responder | default "false" }}

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
# from .agent.neutron.ml2.ovs.agent.prevent_arp_spoofing
{{ if not .agent.neutron.ml2.ovs.agent.prevent_arp_spoofing }}#{{ end }}prevent_arp_spoofing = {{ .agent.neutron.ml2.ovs.agent.prevent_arp_spoofing | default "true" }}

# Set or un-set the don't fragment (DF) bit on outgoing IP packet carrying
# GRE/VXLAN tunnel. (boolean value)
# from .agent.neutron.ml2.ovs.agent.dont_fragment
{{ if not .agent.neutron.ml2.ovs.agent.dont_fragment }}#{{ end }}dont_fragment = {{ .agent.neutron.ml2.ovs.agent.dont_fragment | default "true" }}

# Make the l2 agent run in DVR mode. (boolean value)
# from .agent.neutron.ml2.ovs.agent.enable_distributed_routing
{{ if not .agent.neutron.ml2.ovs.agent.enable_distributed_routing }}#{{ end }}enable_distributed_routing = {{ .agent.neutron.ml2.ovs.agent.enable_distributed_routing | default "false" }}

# Set new timeout in seconds for new rpc calls after agent receives SIGTERM. If
# value is set to 0, rpc timeout won't be changed (integer value)
# from .agent.neutron.ml2.ovs.agent.quitting_rpc_timeout
{{ if not .agent.neutron.ml2.ovs.agent.quitting_rpc_timeout }}#{{ end }}quitting_rpc_timeout = {{ .agent.neutron.ml2.ovs.agent.quitting_rpc_timeout | default "10" }}

# Reset flow table on start. Setting this to True will cause brief traffic
# interruption. (boolean value)
# from .agent.neutron.ml2.ovs.agent.drop_flows_on_start
{{ if not .agent.neutron.ml2.ovs.agent.drop_flows_on_start }}#{{ end }}drop_flows_on_start = {{ .agent.neutron.ml2.ovs.agent.drop_flows_on_start | default "false" }}

# Set or un-set the tunnel header checksum  on outgoing IP packet carrying
# GRE/VXLAN tunnel. (boolean value)
# from .agent.neutron.ml2.ovs.agent.tunnel_csum
{{ if not .agent.neutron.ml2.ovs.agent.tunnel_csum }}#{{ end }}tunnel_csum = {{ .agent.neutron.ml2.ovs.agent.tunnel_csum | default "false" }}

# DEPRECATED: Selects the Agent Type reported (string value)
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# from .agent.neutron.ml2.ovs.agent.agent_type
{{ if not .agent.neutron.ml2.ovs.agent.agent_type }}#{{ end }}agent_type = {{ .agent.neutron.ml2.ovs.agent.agent_type | default "Open vSwitch agent" }}

# Extensions list to use (list value)
# from .agent.neutron.ml2.ovs.agent.extensions
{{ if not .agent.neutron.ml2.ovs.agent.extensions }}#{{ end }}extensions = {{ .agent.neutron.ml2.ovs.agent.extensions | default "" }}


[ovs]

#
# From neutron.ml2.ovs.agent
#

# Integration bridge to use. Do not change this parameter unless you have a
# good reason to. This is the name of the OVS integration bridge. There is one
# per hypervisor. The integration bridge acts as a virtual 'patch bay'. All VM
# VIFs are attached to this bridge and then 'patched' according to their
# network connectivity. (string value)
# from .ovs.neutron.ml2.ovs.agent.integration_bridge
{{ if not .ovs.neutron.ml2.ovs.agent.integration_bridge }}#{{ end }}integration_bridge = {{ .ovs.neutron.ml2.ovs.agent.integration_bridge | default "br-int" }}

# Tunnel bridge to use. (string value)
# from .ovs.neutron.ml2.ovs.agent.tunnel_bridge
{{ if not .ovs.neutron.ml2.ovs.agent.tunnel_bridge }}#{{ end }}tunnel_bridge = {{ .ovs.neutron.ml2.ovs.agent.tunnel_bridge | default "br-tun" }}

# Peer patch port in integration bridge for tunnel bridge. (string value)
# from .ovs.neutron.ml2.ovs.agent.int_peer_patch_port
{{ if not .ovs.neutron.ml2.ovs.agent.int_peer_patch_port }}#{{ end }}int_peer_patch_port = {{ .ovs.neutron.ml2.ovs.agent.int_peer_patch_port | default "patch-tun" }}

# Peer patch port in tunnel bridge for integration bridge. (string value)
# from .ovs.neutron.ml2.ovs.agent.tun_peer_patch_port
{{ if not .ovs.neutron.ml2.ovs.agent.tun_peer_patch_port }}#{{ end }}tun_peer_patch_port = {{ .ovs.neutron.ml2.ovs.agent.tun_peer_patch_port | default "patch-int" }}

# IP address of local overlay (tunnel) network endpoint. Use either an IPv4 or
# IPv6 address that resides on one of the host network interfaces. The IP
# version of this value must match the value of the 'overlay_ip_version' option
# in the ML2 plug-in configuration file on the neutron server node(s). (IP
# address value)
# from .ovs.neutron.ml2.ovs.agent.local_ip
{{ if not .ovs.neutron.ml2.ovs.agent.local_ip }}#{{ end }}local_ip = {{ .ovs.neutron.ml2.ovs.agent.local_ip | default "<None>" }}

# Comma-separated list of <physical_network>:<bridge> tuples mapping physical
# network names to the agent's node-specific Open vSwitch bridge names to be
# used for flat and VLAN networks. The length of bridge names should be no more
# than 11. Each bridge must exist, and should have a physical network interface
# configured as a port. All physical networks configured on the server should
# have mappings to appropriate bridges on each agent. Note: If you remove a
# bridge from this mapping, make sure to disconnect it from the integration
# bridge as it won't be managed by the agent anymore. (list value)
# from .ovs.neutron.ml2.ovs.agent.bridge_mappings
{{ if not .ovs.neutron.ml2.ovs.agent.bridge_mappings }}#{{ end }}bridge_mappings = {{ .ovs.neutron.ml2.ovs.agent.bridge_mappings | default "" }}

# Use veths instead of patch ports to interconnect the integration bridge to
# physical networks. Support kernel without Open vSwitch patch port support so
# long as it is set to True. (boolean value)
# from .ovs.neutron.ml2.ovs.agent.use_veth_interconnection
{{ if not .ovs.neutron.ml2.ovs.agent.use_veth_interconnection }}#{{ end }}use_veth_interconnection = {{ .ovs.neutron.ml2.ovs.agent.use_veth_interconnection | default "false" }}

# OpenFlow interface to use. (string value)
# Allowed values: ovs-ofctl, native
# from .ovs.neutron.ml2.ovs.agent.of_interface
{{ if not .ovs.neutron.ml2.ovs.agent.of_interface }}#{{ end }}of_interface = {{ .ovs.neutron.ml2.ovs.agent.of_interface | default "native" }}

# OVS datapath to use. 'system' is the default value and corresponds to the
# kernel datapath. To enable the userspace datapath set this value to 'netdev'.
# (string value)
# Allowed values: system, netdev
# from .ovs.neutron.ml2.ovs.agent.datapath_type
{{ if not .ovs.neutron.ml2.ovs.agent.datapath_type }}#{{ end }}datapath_type = {{ .ovs.neutron.ml2.ovs.agent.datapath_type | default "system" }}

# OVS vhost-user socket directory. (string value)
# from .ovs.neutron.ml2.ovs.agent.vhostuser_socket_dir
{{ if not .ovs.neutron.ml2.ovs.agent.vhostuser_socket_dir }}#{{ end }}vhostuser_socket_dir = {{ .ovs.neutron.ml2.ovs.agent.vhostuser_socket_dir | default "/var/run/openvswitch" }}

# Address to listen on for OpenFlow connections. Used only for 'native' driver.
# (IP address value)
# from .ovs.neutron.ml2.ovs.agent.of_listen_address
{{ if not .ovs.neutron.ml2.ovs.agent.of_listen_address }}#{{ end }}of_listen_address = {{ .ovs.neutron.ml2.ovs.agent.of_listen_address | default "127.0.0.1" }}

# Port to listen on for OpenFlow connections. Used only for 'native' driver.
# (port value)
# Minimum value: 0
# Maximum value: 65535
# from .ovs.neutron.ml2.ovs.agent.of_listen_port
{{ if not .ovs.neutron.ml2.ovs.agent.of_listen_port }}#{{ end }}of_listen_port = {{ .ovs.neutron.ml2.ovs.agent.of_listen_port | default "6633" }}

# Timeout in seconds to wait for the local switch connecting the controller.
# Used only for 'native' driver. (integer value)
# from .ovs.neutron.ml2.ovs.agent.of_connect_timeout
{{ if not .ovs.neutron.ml2.ovs.agent.of_connect_timeout }}#{{ end }}of_connect_timeout = {{ .ovs.neutron.ml2.ovs.agent.of_connect_timeout | default "30" }}

# Timeout in seconds to wait for a single OpenFlow request. Used only for
# 'native' driver. (integer value)
# from .ovs.neutron.ml2.ovs.agent.of_request_timeout
{{ if not .ovs.neutron.ml2.ovs.agent.of_request_timeout }}#{{ end }}of_request_timeout = {{ .ovs.neutron.ml2.ovs.agent.of_request_timeout | default "10" }}

# The interface for interacting with the OVSDB (string value)
# Allowed values: native, vsctl
# from .ovs.neutron.ml2.ovs.agent.ovsdb_interface
{{ if not .ovs.neutron.ml2.ovs.agent.ovsdb_interface }}#{{ end }}ovsdb_interface = {{ .ovs.neutron.ml2.ovs.agent.ovsdb_interface | default "native" }}

# The connection string for the native OVSDB backend. Requires the native
# ovsdb_interface to be enabled. (string value)
# from .ovs.neutron.ml2.ovs.agent.ovsdb_connection
{{ if not .ovs.neutron.ml2.ovs.agent.ovsdb_connection }}#{{ end }}ovsdb_connection = {{ .ovs.neutron.ml2.ovs.agent.ovsdb_connection | default "tcp:127.0.0.1:6640" }}


[securitygroup]

#
# From neutron.ml2.ovs.agent
#

# Driver for security groups firewall in the L2 agent (string value)
# from .securitygroup.neutron.ml2.ovs.agent.firewall_driver
{{ if not .securitygroup.neutron.ml2.ovs.agent.firewall_driver }}#{{ end }}firewall_driver = {{ .securitygroup.neutron.ml2.ovs.agent.firewall_driver | default "<None>" }}

# Controls whether the neutron security group API is enabled in the server. It
# should be false when using no security groups or using the nova security
# group API. (boolean value)
# from .securitygroup.neutron.ml2.ovs.agent.enable_security_group
{{ if not .securitygroup.neutron.ml2.ovs.agent.enable_security_group }}#{{ end }}enable_security_group = {{ .securitygroup.neutron.ml2.ovs.agent.enable_security_group | default "true" }}

# Use ipset to speed-up the iptables based security groups. Enabling ipset
# support requires that ipset is installed on L2 agent node. (boolean value)
# from .securitygroup.neutron.ml2.ovs.agent.enable_ipset
{{ if not .securitygroup.neutron.ml2.ovs.agent.enable_ipset }}#{{ end }}enable_ipset = {{ .securitygroup.neutron.ml2.ovs.agent.enable_ipset | default "true" }}

{{- end -}}
