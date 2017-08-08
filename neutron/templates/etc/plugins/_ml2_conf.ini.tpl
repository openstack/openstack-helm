
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

{{ include "neutron.conf.ml2_conf_values_skeleton" .Values.conf.ml2_conf | trunc 0 }}
{{ include "neutron.conf.ml2_conf" .Values.conf.ml2_conf }}


{{- define "neutron.conf.ml2_conf_values_skeleton" -}}

{{- if not .default -}}{{- set . "default" dict -}}{{- end -}}
{{- if not .default.oslo -}}{{- set .default "oslo" dict -}}{{- end -}}
{{- if not .default.oslo.log -}}{{- set .default.oslo "log" dict -}}{{- end -}}
{{- if not .ml2 -}}{{- set . "ml2" dict -}}{{- end -}}
{{- if not .ml2.neutron -}}{{- set .ml2 "neutron" dict -}}{{- end -}}
{{- if not .ml2.neutron.ml2 -}}{{- set .ml2.neutron "ml2" dict -}}{{- end -}}
{{- if not .ml2_type_flat -}}{{- set . "ml2_type_flat" dict -}}{{- end -}}
{{- if not .ml2_type_flat.neutron -}}{{- set .ml2_type_flat "neutron" dict -}}{{- end -}}
{{- if not .ml2_type_flat.neutron.ml2 -}}{{- set .ml2_type_flat.neutron "ml2" dict -}}{{- end -}}
{{- if not .ml2_type_geneve -}}{{- set . "ml2_type_geneve" dict -}}{{- end -}}
{{- if not .ml2_type_geneve.neutron -}}{{- set .ml2_type_geneve "neutron" dict -}}{{- end -}}
{{- if not .ml2_type_geneve.neutron.ml2 -}}{{- set .ml2_type_geneve.neutron "ml2" dict -}}{{- end -}}
{{- if not .ml2_type_gre -}}{{- set . "ml2_type_gre" dict -}}{{- end -}}
{{- if not .ml2_type_gre.neutron -}}{{- set .ml2_type_gre "neutron" dict -}}{{- end -}}
{{- if not .ml2_type_gre.neutron.ml2 -}}{{- set .ml2_type_gre.neutron "ml2" dict -}}{{- end -}}
{{- if not .ml2_type_vlan -}}{{- set . "ml2_type_vlan" dict -}}{{- end -}}
{{- if not .ml2_type_vlan.neutron -}}{{- set .ml2_type_vlan "neutron" dict -}}{{- end -}}
{{- if not .ml2_type_vlan.neutron.ml2 -}}{{- set .ml2_type_vlan.neutron "ml2" dict -}}{{- end -}}
{{- if not .ml2_type_vxlan -}}{{- set . "ml2_type_vxlan" dict -}}{{- end -}}
{{- if not .ml2_type_vxlan.neutron -}}{{- set .ml2_type_vxlan "neutron" dict -}}{{- end -}}
{{- if not .ml2_type_vxlan.neutron.ml2 -}}{{- set .ml2_type_vxlan.neutron "ml2" dict -}}{{- end -}}
{{- if not .securitygroup -}}{{- set . "securitygroup" dict -}}{{- end -}}
{{- if not .securitygroup.neutron -}}{{- set .securitygroup "neutron" dict -}}{{- end -}}
{{- if not .securitygroup.neutron.ml2 -}}{{- set .securitygroup.neutron "ml2" dict -}}{{- end -}}

{{- end -}}


{{- define "neutron.conf.ml2_conf" -}}

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


[ml2]

#
# From neutron.ml2
#

# List of network type driver entrypoints to be loaded from the
# neutron.ml2.type_drivers namespace. (list value)
# from .ml2.neutron.ml2.type_drivers
{{ if not .ml2.neutron.ml2.type_drivers }}#{{ end }}type_drivers = {{ .ml2.neutron.ml2.type_drivers | default "local,flat,vlan,gre,vxlan,geneve" }}

# Ordered list of network_types to allocate as tenant networks. The default
# value 'local' is useful for single-box testing but provides no connectivity
# between hosts. (list value)
# from .ml2.neutron.ml2.tenant_network_types
{{ if not .ml2.neutron.ml2.tenant_network_types }}#{{ end }}tenant_network_types = {{ .ml2.neutron.ml2.tenant_network_types | default "local" }}

# An ordered list of networking mechanism driver entrypoints to be loaded from
# the neutron.ml2.mechanism_drivers namespace. (list value)
# from .ml2.neutron.ml2.mechanism_drivers
{{ if not .ml2.neutron.ml2.mechanism_drivers }}#{{ end }}mechanism_drivers = {{ .ml2.neutron.ml2.mechanism_drivers | default "" }}

# An ordered list of extension driver entrypoints to be loaded from the
# neutron.ml2.extension_drivers namespace. For example: extension_drivers =
# port_security,qos (list value)
# from .ml2.neutron.ml2.extension_drivers
{{ if not .ml2.neutron.ml2.extension_drivers }}#{{ end }}extension_drivers = {{ .ml2.neutron.ml2.extension_drivers | default "" }}

# Maximum size of an IP packet (MTU) that can traverse the underlying physical
# network infrastructure without fragmentation when using an overlay/tunnel
# protocol. This option allows specifying a physical network MTU value that
# differs from the default global_physnet_mtu value. (integer value)
# from .ml2.neutron.ml2.path_mtu
{{ if not .ml2.neutron.ml2.path_mtu }}#{{ end }}path_mtu = {{ .ml2.neutron.ml2.path_mtu | default "0" }}

# A list of mappings of physical networks to MTU values. The format of the
# mapping is <physnet>:<mtu val>. This mapping allows specifying a physical
# network MTU value that differs from the default global_physnet_mtu value.
# (list value)
# from .ml2.neutron.ml2.physical_network_mtus
{{ if not .ml2.neutron.ml2.physical_network_mtus }}#{{ end }}physical_network_mtus = {{ .ml2.neutron.ml2.physical_network_mtus | default "" }}

# Default network type for external networks when no provider attributes are
# specified. By default it is None, which means that if provider attributes are
# not specified while creating external networks then they will have the same
# type as tenant networks. Allowed values for external_network_type config
# option depend on the network type values configured in type_drivers config
# option. (string value)
# from .ml2.neutron.ml2.external_network_type
{{ if not .ml2.neutron.ml2.external_network_type }}#{{ end }}external_network_type = {{ .ml2.neutron.ml2.external_network_type | default "<None>" }}

# IP version of all overlay (tunnel) network endpoints. Use a value of 4 for
# IPv4 or 6 for IPv6. (integer value)
# from .ml2.neutron.ml2.overlay_ip_version
{{ if not .ml2.neutron.ml2.overlay_ip_version }}#{{ end }}overlay_ip_version = {{ .ml2.neutron.ml2.overlay_ip_version | default "4" }}


[ml2_type_flat]

#
# From neutron.ml2
#

# List of physical_network names with which flat networks can be created. Use
# default '*' to allow flat networks with arbitrary physical_network names. Use
# an empty list to disable flat networks. (list value)
# from .ml2_type_flat.neutron.ml2.flat_networks
{{ if not .ml2_type_flat.neutron.ml2.flat_networks }}#{{ end }}flat_networks = {{ .ml2_type_flat.neutron.ml2.flat_networks | default "*" }}


[ml2_type_geneve]

#
# From neutron.ml2
#

# Comma-separated list of <vni_min>:<vni_max> tuples enumerating ranges of
# Geneve VNI IDs that are available for tenant network allocation (list value)
# from .ml2_type_geneve.neutron.ml2.vni_ranges
{{ if not .ml2_type_geneve.neutron.ml2.vni_ranges }}#{{ end }}vni_ranges = {{ .ml2_type_geneve.neutron.ml2.vni_ranges | default "" }}

# Geneve encapsulation header size is dynamic, this value is used to calculate
# the maximum MTU for the driver. This is the sum of the sizes of the outer ETH
# + IP + UDP + GENEVE header sizes. The default size for this field is 50,
# which is the size of the Geneve header without any additional option headers.
# (integer value)
# from .ml2_type_geneve.neutron.ml2.max_header_size
{{ if not .ml2_type_geneve.neutron.ml2.max_header_size }}#{{ end }}max_header_size = {{ .ml2_type_geneve.neutron.ml2.max_header_size | default "30" }}


[ml2_type_gre]

#
# From neutron.ml2
#

# Comma-separated list of <tun_min>:<tun_max> tuples enumerating ranges of GRE
# tunnel IDs that are available for tenant network allocation (list value)
# from .ml2_type_gre.neutron.ml2.tunnel_id_ranges
{{ if not .ml2_type_gre.neutron.ml2.tunnel_id_ranges }}#{{ end }}tunnel_id_ranges = {{ .ml2_type_gre.neutron.ml2.tunnel_id_ranges | default "" }}


[ml2_type_vlan]

#
# From neutron.ml2
#

# List of <physical_network>:<vlan_min>:<vlan_max> or <physical_network>
# specifying physical_network names usable for VLAN provider and tenant
# networks, as well as ranges of VLAN tags on each available for allocation to
# tenant networks. (list value)
# from .ml2_type_vlan.neutron.ml2.network_vlan_ranges
{{ if not .ml2_type_vlan.neutron.ml2.network_vlan_ranges }}#{{ end }}network_vlan_ranges = {{ .ml2_type_vlan.neutron.ml2.network_vlan_ranges | default "" }}


[ml2_type_vxlan]

#
# From neutron.ml2
#

# Comma-separated list of <vni_min>:<vni_max> tuples enumerating ranges of
# VXLAN VNI IDs that are available for tenant network allocation (list value)
# from .ml2_type_vxlan.neutron.ml2.vni_ranges
{{ if not .ml2_type_vxlan.neutron.ml2.vni_ranges }}#{{ end }}vni_ranges = {{ .ml2_type_vxlan.neutron.ml2.vni_ranges | default "" }}

# Multicast group for VXLAN. When configured, will enable sending all broadcast
# traffic to this multicast group. When left unconfigured, will disable
# multicast VXLAN mode. (string value)
# from .ml2_type_vxlan.neutron.ml2.vxlan_group
{{ if not .ml2_type_vxlan.neutron.ml2.vxlan_group }}#{{ end }}vxlan_group = {{ .ml2_type_vxlan.neutron.ml2.vxlan_group | default "<None>" }}


[securitygroup]

#
# From neutron.ml2
#

# Driver for security groups firewall in the L2 agent (string value)
# from .securitygroup.neutron.ml2.firewall_driver
{{ if not .securitygroup.neutron.ml2.firewall_driver }}#{{ end }}firewall_driver = {{ .securitygroup.neutron.ml2.firewall_driver | default "<None>" }}

# Controls whether the neutron security group API is enabled in the server. It
# should be false when using no security groups or using the nova security
# group API. (boolean value)
# from .securitygroup.neutron.ml2.enable_security_group
{{ if not .securitygroup.neutron.ml2.enable_security_group }}#{{ end }}enable_security_group = {{ .securitygroup.neutron.ml2.enable_security_group | default "true" }}

# Use ipset to speed-up the iptables based security groups. Enabling ipset
# support requires that ipset is installed on L2 agent node. (boolean value)
# from .securitygroup.neutron.ml2.enable_ipset
{{ if not .securitygroup.neutron.ml2.enable_ipset }}#{{ end }}enable_ipset = {{ .securitygroup.neutron.ml2.enable_ipset | default "true" }}

{{- end -}}
