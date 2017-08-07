
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

{{ include "neutron.conf.l3_agent_values_skeleton" .Values.conf.l3_agent | trunc 0 }}
{{ include "neutron.conf.l3_agent" .Values.conf.l3_agent }}


{{- define "neutron.conf.l3_agent_values_skeleton" -}}

{{- if not .default -}}{{- set . "default" dict -}}{{- end -}}
{{- if not .default.neutron -}}{{- set .default "neutron" dict -}}{{- end -}}
{{- if not .default.neutron.base -}}{{- set .default.neutron "base" dict -}}{{- end -}}
{{- if not .default.neutron.base.agent -}}{{- set .default.neutron.base "agent" dict -}}{{- end -}}
{{- if not .default.neutron.l3 -}}{{- set .default.neutron "l3" dict -}}{{- end -}}
{{- if not .default.neutron.l3.agent -}}{{- set .default.neutron.l3 "agent" dict -}}{{- end -}}
{{- if not .default.oslo -}}{{- set .default "oslo" dict -}}{{- end -}}
{{- if not .default.oslo.log -}}{{- set .default.oslo "log" dict -}}{{- end -}}
{{- if not .agent -}}{{- set . "agent" dict -}}{{- end -}}
{{- if not .agent.neutron -}}{{- set .agent "neutron" dict -}}{{- end -}}
{{- if not .agent.neutron.base -}}{{- set .agent.neutron "base" dict -}}{{- end -}}
{{- if not .agent.neutron.base.agent -}}{{- set .agent.neutron.base "agent" dict -}}{{- end -}}

{{- end -}}


{{- define "neutron.conf.l3_agent" -}}

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
# From neutron.l3.agent
#

# The working mode for the agent. Allowed modes are: 'legacy' - this preserves
# the existing behavior where the L3 agent is deployed on a centralized
# networking node to provide L3 services like DNAT, and SNAT. Use this mode if
# you do not want to adopt DVR. 'dvr' - this mode enables DVR functionality and
# must be used for an L3 agent that runs on a compute host. 'dvr_snat' - this
# enables centralized SNAT support in conjunction with DVR.  This mode must be
# used for an L3 agent running on a centralized node (or in single-host
# deployments, e.g. devstack) (string value)
# Allowed values: dvr, dvr_snat, legacy
# from .default.neutron.l3.agent.agent_mode
{{ if not .default.neutron.l3.agent.agent_mode }}#{{ end }}agent_mode = {{ .default.neutron.l3.agent.agent_mode | default "legacy" }}

# TCP Port used by Neutron metadata namespace proxy. (port value)
# Minimum value: 0
# Maximum value: 65535
# from .default.neutron.l3.agent.metadata_port
{{ if not .default.neutron.l3.agent.metadata_port }}#{{ end }}metadata_port = {{ .default.neutron.l3.agent.metadata_port | default "9697" }}

# Send this many gratuitous ARPs for HA setup, if less than or equal to 0, the
# feature is disabled (integer value)
# from .default.neutron.l3.agent.send_arp_for_ha
{{ if not .default.neutron.l3.agent.send_arp_for_ha }}#{{ end }}send_arp_for_ha = {{ .default.neutron.l3.agent.send_arp_for_ha | default "3" }}

# Indicates that this L3 agent should also handle routers that do not have an
# external network gateway configured. This option should be True only for a
# single agent in a Neutron deployment, and may be False for all agents if all
# routers must have an external network gateway. (boolean value)
# from .default.neutron.l3.agent.handle_internal_only_routers
{{ if not .default.neutron.l3.agent.handle_internal_only_routers }}#{{ end }}handle_internal_only_routers = {{ .default.neutron.l3.agent.handle_internal_only_routers | default "true" }}

# When external_network_bridge is set, each L3 agent can be associated with no
# more than one external network. This value should be set to the UUID of that
# external network. To allow L3 agent support multiple external networks, both
# the external_network_bridge and gateway_external_network_id must be left
# empty. (string value)
# from .default.neutron.l3.agent.gateway_external_network_id
{{ if not .default.neutron.l3.agent.gateway_external_network_id }}#{{ end }}gateway_external_network_id = {{ .default.neutron.l3.agent.gateway_external_network_id | default "" }}

# With IPv6, the network used for the external gateway does not need to have an
# associated subnet, since the automatically assigned link-local address (LLA)
# can be used. However, an IPv6 gateway address is needed for use as the next-
# hop for the default route. If no IPv6 gateway address is configured here,
# (and only then) the neutron router will be configured to get its default
# route from router advertisements (RAs) from the upstream router; in which
# case the upstream router must also be configured to send these RAs. The
# ipv6_gateway, when configured, should be the LLA of the interface on the
# upstream router. If a next-hop using a global unique address (GUA) is
# desired, it needs to be done via a subnet allocated to the network and not
# through this parameter.  (string value)
# from .default.neutron.l3.agent.ipv6_gateway
{{ if not .default.neutron.l3.agent.ipv6_gateway }}#{{ end }}ipv6_gateway = {{ .default.neutron.l3.agent.ipv6_gateway | default "" }}

# Driver used for ipv6 prefix delegation. This needs to be an entry point
# defined in the neutron.agent.linux.pd_drivers namespace. See setup.cfg for
# entry points included with the neutron source. (string value)
# from .default.neutron.l3.agent.prefix_delegation_driver
{{ if not .default.neutron.l3.agent.prefix_delegation_driver }}#{{ end }}prefix_delegation_driver = {{ .default.neutron.l3.agent.prefix_delegation_driver | default "dibbler" }}

# Allow running metadata proxy. (boolean value)
# from .default.neutron.l3.agent.enable_metadata_proxy
{{ if not .default.neutron.l3.agent.enable_metadata_proxy }}#{{ end }}enable_metadata_proxy = {{ .default.neutron.l3.agent.enable_metadata_proxy | default "true" }}

# Iptables mangle mark used to mark metadata valid requests. This mark will be
# masked with 0xffff so that only the lower 16 bits will be used. (string
# value)
# from .default.neutron.l3.agent.metadata_access_mark
{{ if not .default.neutron.l3.agent.metadata_access_mark }}#{{ end }}metadata_access_mark = {{ .default.neutron.l3.agent.metadata_access_mark | default "0x1" }}

# Iptables mangle mark used to mark ingress from external network. This mark
# will be masked with 0xffff so that only the lower 16 bits will be used.
# (string value)
# from .default.neutron.l3.agent.external_ingress_mark
{{ if not .default.neutron.l3.agent.external_ingress_mark }}#{{ end }}external_ingress_mark = {{ .default.neutron.l3.agent.external_ingress_mark | default "0x2" }}

# DEPRECATED: Name of bridge used for external network traffic. When this
# parameter is set, the L3 agent will plug an interface directly into an
# external bridge which will not allow any wiring by the L2 agent. Using this
# will result in incorrect port statuses. This option is deprecated and will be
# removed in Ocata. (string value)
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# from .default.neutron.l3.agent.external_network_bridge
{{ if not .default.neutron.l3.agent.external_network_bridge }}#{{ end }}external_network_bridge = {{ .default.neutron.l3.agent.external_network_bridge | default "" }}

# Seconds between running periodic tasks. (integer value)
# from .default.neutron.l3.agent.periodic_interval
{{ if not .default.neutron.l3.agent.periodic_interval }}#{{ end }}periodic_interval = {{ .default.neutron.l3.agent.periodic_interval | default "40" }}

# Number of separate API worker processes for service. If not specified, the
# default is equal to the number of CPUs available for best performance.
# (integer value)
# from .default.neutron.l3.agent.api_workers
{{ if not .default.neutron.l3.agent.api_workers }}#{{ end }}api_workers = {{ .default.neutron.l3.agent.api_workers | default "<None>" }}

# Number of RPC worker processes for service. (integer value)
# from .default.neutron.l3.agent.rpc_workers
{{ if not .default.neutron.l3.agent.rpc_workers }}#{{ end }}rpc_workers = {{ .default.neutron.l3.agent.rpc_workers | default "1" }}

# Number of RPC worker processes dedicated to state reports queue. (integer
# value)
# from .default.neutron.l3.agent.rpc_state_report_workers
{{ if not .default.neutron.l3.agent.rpc_state_report_workers }}#{{ end }}rpc_state_report_workers = {{ .default.neutron.l3.agent.rpc_state_report_workers | default "1" }}

# Range of seconds to randomly delay when starting the periodic task scheduler
# to reduce stampeding. (Disable by setting to 0) (integer value)
# from .default.neutron.l3.agent.periodic_fuzzy_delay
{{ if not .default.neutron.l3.agent.periodic_fuzzy_delay }}#{{ end }}periodic_fuzzy_delay = {{ .default.neutron.l3.agent.periodic_fuzzy_delay | default "5" }}

# Location to store keepalived/conntrackd config files (string value)
# from .default.neutron.l3.agent.ha_confs_path
{{ if not .default.neutron.l3.agent.ha_confs_path }}#{{ end }}ha_confs_path = {{ .default.neutron.l3.agent.ha_confs_path | default "$state_path/ha_confs" }}

# VRRP authentication type (string value)
# Allowed values: AH, PASS
# from .default.neutron.l3.agent.ha_vrrp_auth_type
{{ if not .default.neutron.l3.agent.ha_vrrp_auth_type }}#{{ end }}ha_vrrp_auth_type = {{ .default.neutron.l3.agent.ha_vrrp_auth_type | default "PASS" }}

# VRRP authentication password (string value)
# from .default.neutron.l3.agent.ha_vrrp_auth_password
{{ if not .default.neutron.l3.agent.ha_vrrp_auth_password }}#{{ end }}ha_vrrp_auth_password = {{ .default.neutron.l3.agent.ha_vrrp_auth_password | default "<None>" }}

# The advertisement interval in seconds (integer value)
# from .default.neutron.l3.agent.ha_vrrp_advert_int
{{ if not .default.neutron.l3.agent.ha_vrrp_advert_int }}#{{ end }}ha_vrrp_advert_int = {{ .default.neutron.l3.agent.ha_vrrp_advert_int | default "2" }}

# Number of concurrent threads for keepalived server connection requests.More
# threads create a higher CPU load on the agent node. (integer value)
# Minimum value: 1
# from .default.neutron.l3.agent.ha_keepalived_state_change_server_threads
{{ if not .default.neutron.l3.agent.ha_keepalived_state_change_server_threads }}#{{ end }}ha_keepalived_state_change_server_threads = {{ .default.neutron.l3.agent.ha_keepalived_state_change_server_threads | default "4" }}

# Service to handle DHCPv6 Prefix delegation. (string value)
# from .default.neutron.l3.agent.pd_dhcp_driver
{{ if not .default.neutron.l3.agent.pd_dhcp_driver }}#{{ end }}pd_dhcp_driver = {{ .default.neutron.l3.agent.pd_dhcp_driver | default "dibbler" }}

# Location to store IPv6 RA config files (string value)
# from .default.neutron.l3.agent.ra_confs
{{ if not .default.neutron.l3.agent.ra_confs }}#{{ end }}ra_confs = {{ .default.neutron.l3.agent.ra_confs | default "$state_path/ra" }}

# MinRtrAdvInterval setting for radvd.conf (integer value)
# from .default.neutron.l3.agent.min_rtr_adv_interval
{{ if not .default.neutron.l3.agent.min_rtr_adv_interval }}#{{ end }}min_rtr_adv_interval = {{ .default.neutron.l3.agent.min_rtr_adv_interval | default "30" }}

# MaxRtrAdvInterval setting for radvd.conf (integer value)
# from .default.neutron.l3.agent.max_rtr_adv_interval
{{ if not .default.neutron.l3.agent.max_rtr_adv_interval }}#{{ end }}max_rtr_adv_interval = {{ .default.neutron.l3.agent.max_rtr_adv_interval | default "100" }}

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
