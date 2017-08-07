
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

{{ include "neutron.conf.neutron_values_skeleton" .Values.conf.neutron | trunc 0 }}
{{ include "neutron.conf.neutron" .Values.conf.neutron }}


{{- define "neutron.conf.neutron_values_skeleton" -}}

{{- if not .default -}}{{- set . "default" dict -}}{{- end -}}
{{- if not .default.neutron -}}{{- set .default "neutron" dict -}}{{- end -}}
{{- if not .default.neutron.agent -}}{{- set .default.neutron "agent" dict -}}{{- end -}}
{{- if not .default.neutron.db -}}{{- set .default.neutron "db" dict -}}{{- end -}}
{{- if not .default.neutron.extensions -}}{{- set .default.neutron "extensions" dict -}}{{- end -}}
{{- if not .default.oslo -}}{{- set .default "oslo" dict -}}{{- end -}}
{{- if not .default.oslo.log -}}{{- set .default.oslo "log" dict -}}{{- end -}}
{{- if not .default.oslo.messaging -}}{{- set .default.oslo "messaging" dict -}}{{- end -}}
{{- if not .default.oslo.service -}}{{- set .default.oslo "service" dict -}}{{- end -}}
{{- if not .default.oslo.service.wsgi -}}{{- set .default.oslo.service "wsgi" dict -}}{{- end -}}
{{- if not .agent -}}{{- set . "agent" dict -}}{{- end -}}
{{- if not .agent.neutron -}}{{- set .agent "neutron" dict -}}{{- end -}}
{{- if not .agent.neutron.agent -}}{{- set .agent.neutron "agent" dict -}}{{- end -}}
{{- if not .cors -}}{{- set . "cors" dict -}}{{- end -}}
{{- if not .cors.oslo -}}{{- set .cors "oslo" dict -}}{{- end -}}
{{- if not .cors.oslo.middleware -}}{{- set .cors.oslo "middleware" dict -}}{{- end -}}
{{- if not .cors.oslo.middleware.cors -}}{{- set .cors.oslo.middleware "cors" dict -}}{{- end -}}
{{- if not .cors.subdomain -}}{{- set .cors "subdomain" dict -}}{{- end -}}
{{- if not .cors.subdomain.oslo -}}{{- set .cors.subdomain "oslo" dict -}}{{- end -}}
{{- if not .cors.subdomain.oslo.middleware -}}{{- set .cors.subdomain.oslo "middleware" dict -}}{{- end -}}
{{- if not .cors.subdomain.oslo.middleware.cors -}}{{- set .cors.subdomain.oslo.middleware "cors" dict -}}{{- end -}}
{{- if not .database -}}{{- set . "database" dict -}}{{- end -}}
{{- if not .database.neutron -}}{{- set .database "neutron" dict -}}{{- end -}}
{{- if not .database.neutron.db -}}{{- set .database.neutron "db" dict -}}{{- end -}}
{{- if not .database.oslo -}}{{- set .database "oslo" dict -}}{{- end -}}
{{- if not .database.oslo.db -}}{{- set .database.oslo "db" dict -}}{{- end -}}
{{- if not .keystone_authtoken -}}{{- set . "keystone_authtoken" dict -}}{{- end -}}
{{- if not .keystone_authtoken.keystonemiddleware -}}{{- set .keystone_authtoken "keystonemiddleware" dict -}}{{- end -}}
{{- if not .keystone_authtoken.keystonemiddleware.auth_token -}}{{- set .keystone_authtoken.keystonemiddleware "auth_token" dict -}}{{- end -}}
{{- if not .matchmaker_redis -}}{{- set . "matchmaker_redis" dict -}}{{- end -}}
{{- if not .matchmaker_redis.oslo -}}{{- set .matchmaker_redis "oslo" dict -}}{{- end -}}
{{- if not .matchmaker_redis.oslo.messaging -}}{{- set .matchmaker_redis.oslo "messaging" dict -}}{{- end -}}
{{- if not .nova -}}{{- set . "nova" dict -}}{{- end -}}
{{- if not .nova.neutron -}}{{- set .nova "neutron" dict -}}{{- end -}}
{{- if not .nova.nova -}}{{- set .nova "nova" dict -}}{{- end -}}
{{- if not .nova.nova.auth -}}{{- set .nova.nova "auth" dict -}}{{- end -}}
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
{{- if not .oslo_middleware -}}{{- set . "oslo_middleware" dict -}}{{- end -}}
{{- if not .oslo_middleware.oslo -}}{{- set .oslo_middleware "oslo" dict -}}{{- end -}}
{{- if not .oslo_middleware.oslo.middleware -}}{{- set .oslo_middleware.oslo "middleware" dict -}}{{- end -}}
{{- if not .oslo_middleware.oslo.middleware.http_proxy_to_wsgi -}}{{- set .oslo_middleware.oslo.middleware "http_proxy_to_wsgi" dict -}}{{- end -}}
{{- if not .oslo_policy -}}{{- set . "oslo_policy" dict -}}{{- end -}}
{{- if not .oslo_policy.oslo -}}{{- set .oslo_policy "oslo" dict -}}{{- end -}}
{{- if not .oslo_policy.oslo.policy -}}{{- set .oslo_policy.oslo "policy" dict -}}{{- end -}}
{{- if not .qos -}}{{- set . "qos" dict -}}{{- end -}}
{{- if not .qos.neutron -}}{{- set .qos "neutron" dict -}}{{- end -}}
{{- if not .qos.neutron.qos -}}{{- set .qos.neutron "qos" dict -}}{{- end -}}
{{- if not .quotas -}}{{- set . "quotas" dict -}}{{- end -}}
{{- if not .quotas.neutron -}}{{- set .quotas "neutron" dict -}}{{- end -}}
{{- if not .quotas.neutron.extensions -}}{{- set .quotas.neutron "extensions" dict -}}{{- end -}}
{{- if not .ssl -}}{{- set . "ssl" dict -}}{{- end -}}
{{- if not .ssl.oslo -}}{{- set .ssl "oslo" dict -}}{{- end -}}
{{- if not .ssl.oslo.service -}}{{- set .ssl.oslo "service" dict -}}{{- end -}}
{{- if not .ssl.oslo.service.sslutils -}}{{- set .ssl.oslo.service "sslutils" dict -}}{{- end -}}

{{- end -}}


{{- define "neutron.conf.neutron" -}}

[DEFAULT]

# Where to store Neutron state files. This directory must be writable by the
# agent. (string value)
# from .default.neutron.state_path
{{ if not .default.neutron.state_path }}#{{ end }}state_path = {{ .default.neutron.state_path | default "/var/lib/neutron" }}

# The host IP to bind to (string value)
# from .default.neutron.bind_host
{{ if not .default.neutron.bind_host }}#{{ end }}bind_host = {{ .default.neutron.bind_host | default "0.0.0.0" }}

# The port to bind to (port value)
# Minimum value: 0
# Maximum value: 65535
# from .default.neutron.bind_port
{{ if not .default.neutron.bind_port }}#{{ end }}bind_port = {{ .default.neutron.bind_port | default "9696" }}

# The path for API extensions. Note that this can be a colon-separated list of
# paths. For example: api_extensions_path =
# extensions:/path/to/more/exts:/even/more/exts. The __path__ of
# neutron.extensions is appended to this, so if your extensions are in there
# you don't need to specify them here. (string value)
# from .default.neutron.api_extensions_path
{{ if not .default.neutron.api_extensions_path }}#{{ end }}api_extensions_path = {{ .default.neutron.api_extensions_path | default "" }}

# The type of authentication to use (string value)
# from .default.neutron.auth_strategy
{{ if not .default.neutron.auth_strategy }}#{{ end }}auth_strategy = {{ .default.neutron.auth_strategy | default "keystone" }}

# The core plugin Neutron will use (string value)
# from .default.neutron.core_plugin
{{ if not .default.neutron.core_plugin }}#{{ end }}core_plugin = {{ .default.neutron.core_plugin | default "<None>" }}

# The service plugins Neutron will use (list value)
# from .default.neutron.service_plugins
{{ if not .default.neutron.service_plugins }}#{{ end }}service_plugins = {{ .default.neutron.service_plugins | default "" }}

# The base MAC address Neutron will use for VIFs. The first 3 octets will
# remain unchanged. If the 4th octet is not 00, it will also be used. The
# others will be randomly generated. (string value)
# from .default.neutron.base_mac
{{ if not .default.neutron.base_mac }}#{{ end }}base_mac = {{ .default.neutron.base_mac | default "fa:16:3e:00:00:00" }}

# DEPRECATED: How many times Neutron will retry MAC generation. This option is
# now obsolete and so is deprecated to be removed in the Ocata release.
# (integer value)
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# from .default.neutron.mac_generation_retries
{{ if not .default.neutron.mac_generation_retries }}#{{ end }}mac_generation_retries = {{ .default.neutron.mac_generation_retries | default "16" }}

# Allow the usage of the bulk API (boolean value)
# from .default.neutron.allow_bulk
{{ if not .default.neutron.allow_bulk }}#{{ end }}allow_bulk = {{ .default.neutron.allow_bulk | default "true" }}

# DEPRECATED: Allow the usage of the pagination. This option has been
# deprecated and will now be enabled unconditionally. (boolean value)
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# from .default.neutron.allow_pagination
{{ if not .default.neutron.allow_pagination }}#{{ end }}allow_pagination = {{ .default.neutron.allow_pagination | default "true" }}

# DEPRECATED: Allow the usage of the sorting. This option has been deprecated
# and will now be enabled unconditionally. (boolean value)
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# from .default.neutron.allow_sorting
{{ if not .default.neutron.allow_sorting }}#{{ end }}allow_sorting = {{ .default.neutron.allow_sorting | default "true" }}

# The maximum number of items returned in a single response, value was
# 'infinite' or negative integer means no limit (string value)
# from .default.neutron.pagination_max_limit
{{ if not .default.neutron.pagination_max_limit }}#{{ end }}pagination_max_limit = {{ .default.neutron.pagination_max_limit | default "-1" }}

# Default value of availability zone hints. The availability zone aware
# schedulers use this when the resources availability_zone_hints is empty.
# Multiple availability zones can be specified by a comma separated string.
# This value can be empty. In this case, even if availability_zone_hints for a
# resource is empty, availability zone is considered for high availability
# while scheduling the resource. (list value)
# from .default.neutron.default_availability_zones
{{ if not .default.neutron.default_availability_zones }}#{{ end }}default_availability_zones = {{ .default.neutron.default_availability_zones | default "" }}

# Maximum number of DNS nameservers per subnet (integer value)
# from .default.neutron.max_dns_nameservers
{{ if not .default.neutron.max_dns_nameservers }}#{{ end }}max_dns_nameservers = {{ .default.neutron.max_dns_nameservers | default "5" }}

# Maximum number of host routes per subnet (integer value)
# from .default.neutron.max_subnet_host_routes
{{ if not .default.neutron.max_subnet_host_routes }}#{{ end }}max_subnet_host_routes = {{ .default.neutron.max_subnet_host_routes | default "20" }}

# DEPRECATED: Maximum number of fixed ips per port. This option is deprecated
# and will be removed in the Ocata release. (integer value)
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# from .default.neutron.max_fixed_ips_per_port
{{ if not .default.neutron.max_fixed_ips_per_port }}#{{ end }}max_fixed_ips_per_port = {{ .default.neutron.max_fixed_ips_per_port | default "5" }}

# Enables IPv6 Prefix Delegation for automatic subnet CIDR allocation. Set to
# True to enable IPv6 Prefix Delegation for subnet allocation in a PD-capable
# environment. Users making subnet creation requests for IPv6 subnets without
# providing a CIDR or subnetpool ID will be given a CIDR via the Prefix
# Delegation mechanism. Note that enabling PD will override the behavior of the
# default IPv6 subnetpool. (boolean value)
# from .default.neutron.ipv6_pd_enabled
{{ if not .default.neutron.ipv6_pd_enabled }}#{{ end }}ipv6_pd_enabled = {{ .default.neutron.ipv6_pd_enabled | default "false" }}

# DHCP lease duration (in seconds). Use -1 to tell dnsmasq to use infinite
# lease times. (integer value)
# from .default.neutron.dhcp_lease_duration
{{ if not .default.neutron.dhcp_lease_duration }}#{{ end }}dhcp_lease_duration = {{ .default.neutron.dhcp_lease_duration | default "86400" }}

# Domain to use for building the hostnames (string value)
# from .default.neutron.dns_domain
{{ if not .default.neutron.dns_domain }}#{{ end }}dns_domain = {{ .default.neutron.dns_domain | default "openstacklocal" }}

# Driver for external DNS integration. (string value)
# from .default.neutron.external_dns_driver
{{ if not .default.neutron.external_dns_driver }}#{{ end }}external_dns_driver = {{ .default.neutron.external_dns_driver | default "<None>" }}

# Allow sending resource operation notification to DHCP agent (boolean value)
# from .default.neutron.dhcp_agent_notification
{{ if not .default.neutron.dhcp_agent_notification }}#{{ end }}dhcp_agent_notification = {{ .default.neutron.dhcp_agent_notification | default "true" }}

# Allow overlapping IP support in Neutron. Attention: the following parameter
# MUST be set to False if Neutron is being used in conjunction with Nova
# security groups. (boolean value)
# from .default.neutron.allow_overlapping_ips
{{ if not .default.neutron.allow_overlapping_ips }}#{{ end }}allow_overlapping_ips = {{ .default.neutron.allow_overlapping_ips | default "false" }}

# Hostname to be used by the Neutron server, agents and services running on
# this machine. All the agents and services running on this machine must use
# the same host value. (string value)
# from .default.neutron.host
{{ if not .default.neutron.host }}#{{ end }}host = {{ .default.neutron.host | default "example.domain" }}

# Send notification to nova when port status changes (boolean value)
# from .default.neutron.notify_nova_on_port_status_changes
{{ if not .default.neutron.notify_nova_on_port_status_changes }}#{{ end }}notify_nova_on_port_status_changes = {{ .default.neutron.notify_nova_on_port_status_changes | default "true" }}

# Send notification to nova when port data (fixed_ips/floatingip) changes so
# nova can update its cache. (boolean value)
# from .default.neutron.notify_nova_on_port_data_changes
{{ if not .default.neutron.notify_nova_on_port_data_changes }}#{{ end }}notify_nova_on_port_data_changes = {{ .default.neutron.notify_nova_on_port_data_changes | default "true" }}

# Number of seconds between sending events to nova if there are any events to
# send. (integer value)
# from .default.neutron.send_events_interval
{{ if not .default.neutron.send_events_interval }}#{{ end }}send_events_interval = {{ .default.neutron.send_events_interval | default "2" }}

# DEPRECATED: If True, advertise network MTU values if core plugin calculates
# them. MTU is advertised to running instances via DHCP and RA MTU options.
# (boolean value)
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# from .default.neutron.advertise_mtu
{{ if not .default.neutron.advertise_mtu }}#{{ end }}advertise_mtu = {{ .default.neutron.advertise_mtu | default "true" }}

# Neutron IPAM (IP address management) driver to use. By default, the reference
# implementation of the Neutron IPAM driver is used. (string value)
# from .default.neutron.ipam_driver
{{ if not .default.neutron.ipam_driver }}#{{ end }}ipam_driver = {{ .default.neutron.ipam_driver | default "internal" }}

# If True, then allow plugins that support it to create VLAN transparent
# networks. (boolean value)
# from .default.neutron.vlan_transparent
{{ if not .default.neutron.vlan_transparent }}#{{ end }}vlan_transparent = {{ .default.neutron.vlan_transparent | default "false" }}

# This will choose the web framework in which to run the Neutron API server.
# 'pecan' is a new experimental rewrite of the API server. (string value)
# Allowed values: legacy, pecan
# from .default.neutron.web_framework
{{ if not .default.neutron.web_framework }}#{{ end }}web_framework = {{ .default.neutron.web_framework | default "legacy" }}

# MTU of the underlying physical network. Neutron uses this value to calculate
# MTU for all virtual network components. For flat and VLAN networks, neutron
# uses this value without modification. For overlay networks such as VXLAN,
# neutron automatically subtracts the overlay protocol overhead from this
# value. Defaults to 1500, the standard value for Ethernet. (integer value)
# Deprecated group/name - [ml2]/segment_mtu
# from .default.neutron.global_physnet_mtu
{{ if not .default.neutron.global_physnet_mtu }}#{{ end }}global_physnet_mtu = {{ .default.neutron.global_physnet_mtu | default "1500" }}

# Number of backlog requests to configure the socket with (integer value)
# from .default.neutron.backlog
{{ if not .default.neutron.backlog }}#{{ end }}backlog = {{ .default.neutron.backlog | default "4096" }}

# Number of seconds to keep retrying to listen (integer value)
# from .default.neutron.retry_until_window
{{ if not .default.neutron.retry_until_window }}#{{ end }}retry_until_window = {{ .default.neutron.retry_until_window | default "30" }}

# Enable SSL on the API server (boolean value)
# from .default.neutron.use_ssl
{{ if not .default.neutron.use_ssl }}#{{ end }}use_ssl = {{ .default.neutron.use_ssl | default "false" }}

# Seconds between running periodic tasks. (integer value)
# from .default.neutron.periodic_interval
{{ if not .default.neutron.periodic_interval }}#{{ end }}periodic_interval = {{ .default.neutron.periodic_interval | default "40" }}

# Number of separate API worker processes for service. If not specified, the
# default is equal to the number of CPUs available for best performance.
# (integer value)
# from .default.neutron.api_workers
{{ if not .default.neutron.api_workers }}#{{ end }}api_workers = {{ .default.neutron.api_workers | default "<None>" }}

# Number of RPC worker processes for service. (integer value)
# from .default.neutron.rpc_workers
{{ if not .default.neutron.rpc_workers }}#{{ end }}rpc_workers = {{ .default.neutron.rpc_workers | default "1" }}

# Number of RPC worker processes dedicated to state reports queue. (integer
# value)
# from .default.neutron.rpc_state_report_workers
{{ if not .default.neutron.rpc_state_report_workers }}#{{ end }}rpc_state_report_workers = {{ .default.neutron.rpc_state_report_workers | default "1" }}

# Range of seconds to randomly delay when starting the periodic task scheduler
# to reduce stampeding. (Disable by setting to 0) (integer value)
# from .default.neutron.periodic_fuzzy_delay
{{ if not .default.neutron.periodic_fuzzy_delay }}#{{ end }}periodic_fuzzy_delay = {{ .default.neutron.periodic_fuzzy_delay | default "5" }}

#
# From neutron.agent
#

# The driver used to manage the virtual interface. (string value)
# from .default.neutron.agent.interface_driver
{{ if not .default.neutron.agent.interface_driver }}#{{ end }}interface_driver = {{ .default.neutron.agent.interface_driver | default "<None>" }}

# Location for Metadata Proxy UNIX domain socket. (string value)
# from .default.neutron.agent.metadata_proxy_socket
{{ if not .default.neutron.agent.metadata_proxy_socket }}#{{ end }}metadata_proxy_socket = {{ .default.neutron.agent.metadata_proxy_socket | default "$state_path/metadata_proxy" }}

# User (uid or name) running metadata proxy after its initialization (if empty:
# agent effective user). (string value)
# from .default.neutron.agent.metadata_proxy_user
{{ if not .default.neutron.agent.metadata_proxy_user }}#{{ end }}metadata_proxy_user = {{ .default.neutron.agent.metadata_proxy_user | default "" }}

# Group (gid or name) running metadata proxy after its initialization (if
# empty: agent effective group). (string value)
# from .default.neutron.agent.metadata_proxy_group
{{ if not .default.neutron.agent.metadata_proxy_group }}#{{ end }}metadata_proxy_group = {{ .default.neutron.agent.metadata_proxy_group | default "" }}

# Enable/Disable log watch by metadata proxy. It should be disabled when
# metadata_proxy_user/group is not allowed to read/write its log file and
# copytruncate logrotate option must be used if logrotate is enabled on
# metadata proxy log files. Option default value is deduced from
# metadata_proxy_user: watch log is enabled if metadata_proxy_user is agent
# effective user id/name. (boolean value)
# from .default.neutron.agent.metadata_proxy_watch_log
{{ if not .default.neutron.agent.metadata_proxy_watch_log }}#{{ end }}metadata_proxy_watch_log = {{ .default.neutron.agent.metadata_proxy_watch_log | default "<None>" }}

#
# From neutron.db
#

# Seconds to regard the agent is down; should be at least twice
# report_interval, to be sure the agent is down for good. (integer value)
# from .default.neutron.db.agent_down_time
{{ if not .default.neutron.db.agent_down_time }}#{{ end }}agent_down_time = {{ .default.neutron.db.agent_down_time | default "75" }}

# Representing the resource type whose load is being reported by the agent.
# This can be "networks", "subnets" or "ports". When specified (Default is
# networks), the server will extract particular load sent as part of its agent
# configuration object from the agent report state, which is the number of
# resources being consumed, at every report_interval.dhcp_load_type can be used
# in combination with network_scheduler_driver =
# neutron.scheduler.dhcp_agent_scheduler.WeightScheduler When the
# network_scheduler_driver is WeightScheduler, dhcp_load_type can be configured
# to represent the choice for the resource being balanced. Example:
# dhcp_load_type=networks (string value)
# Allowed values: networks, subnets, ports
# from .default.neutron.db.dhcp_load_type
{{ if not .default.neutron.db.dhcp_load_type }}#{{ end }}dhcp_load_type = {{ .default.neutron.db.dhcp_load_type | default "networks" }}

# Agent starts with admin_state_up=False when enable_new_agents=False. In the
# case, user's resources will not be scheduled automatically to the agent until
# admin changes admin_state_up to True. (boolean value)
# from .default.neutron.db.enable_new_agents
{{ if not .default.neutron.db.enable_new_agents }}#{{ end }}enable_new_agents = {{ .default.neutron.db.enable_new_agents | default "true" }}

# Maximum number of routes per router (integer value)
# from .default.neutron.db.max_routes
{{ if not .default.neutron.db.max_routes }}#{{ end }}max_routes = {{ .default.neutron.db.max_routes | default "30" }}

# Define the default value of enable_snat if not provided in
# external_gateway_info. (boolean value)
# from .default.neutron.db.enable_snat_by_default
{{ if not .default.neutron.db.enable_snat_by_default }}#{{ end }}enable_snat_by_default = {{ .default.neutron.db.enable_snat_by_default | default "true" }}

# Driver to use for scheduling network to DHCP agent (string value)
# from .default.neutron.db.network_scheduler_driver
{{ if not .default.neutron.db.network_scheduler_driver }}#{{ end }}network_scheduler_driver = {{ .default.neutron.db.network_scheduler_driver | default "neutron.scheduler.dhcp_agent_scheduler.WeightScheduler" }}

# Allow auto scheduling networks to DHCP agent. (boolean value)
# from .default.neutron.db.network_auto_schedule
{{ if not .default.neutron.db.network_auto_schedule }}#{{ end }}network_auto_schedule = {{ .default.neutron.db.network_auto_schedule | default "true" }}

# Automatically remove networks from offline DHCP agents. (boolean value)
# from .default.neutron.db.allow_automatic_dhcp_failover
{{ if not .default.neutron.db.allow_automatic_dhcp_failover }}#{{ end }}allow_automatic_dhcp_failover = {{ .default.neutron.db.allow_automatic_dhcp_failover | default "true" }}

# Number of DHCP agents scheduled to host a tenant network. If this number is
# greater than 1, the scheduler automatically assigns multiple DHCP agents for
# a given tenant network, providing high availability for DHCP service.
# (integer value)
# from .default.neutron.db.dhcp_agents_per_network
{{ if not .default.neutron.db.dhcp_agents_per_network }}#{{ end }}dhcp_agents_per_network = {{ .default.neutron.db.dhcp_agents_per_network | default "1" }}

# Enable services on an agent with admin_state_up False. If this option is
# False, when admin_state_up of an agent is turned False, services on it will
# be disabled. Agents with admin_state_up False are not selected for automatic
# scheduling regardless of this option. But manual scheduling to such agents is
# available if this option is True. (boolean value)
# from .default.neutron.db.enable_services_on_agents_with_admin_state_down
{{ if not .default.neutron.db.enable_services_on_agents_with_admin_state_down }}#{{ end }}enable_services_on_agents_with_admin_state_down = {{ .default.neutron.db.enable_services_on_agents_with_admin_state_down | default "false" }}

# The base mac address used for unique DVR instances by Neutron. The first 3
# octets will remain unchanged. If the 4th octet is not 00, it will also be
# used. The others will be randomly generated. The 'dvr_base_mac' *must* be
# different from 'base_mac' to avoid mixing them up with MAC's allocated for
# tenant ports. A 4 octet example would be dvr_base_mac = fa:16:3f:4f:00:00.
# The default is 3 octet (string value)
# from .default.neutron.db.dvr_base_mac
{{ if not .default.neutron.db.dvr_base_mac }}#{{ end }}dvr_base_mac = {{ .default.neutron.db.dvr_base_mac | default "fa:16:3f:00:00:00" }}

# System-wide flag to determine the type of router that tenants can create.
# Only admin can override. (boolean value)
# from .default.neutron.db.router_distributed
{{ if not .default.neutron.db.router_distributed }}#{{ end }}router_distributed = {{ .default.neutron.db.router_distributed | default "false" }}

# Driver to use for scheduling router to a default L3 agent (string value)
# from .default.neutron.db.router_scheduler_driver
{{ if not .default.neutron.db.router_scheduler_driver }}#{{ end }}router_scheduler_driver = {{ .default.neutron.db.router_scheduler_driver | default "neutron.scheduler.l3_agent_scheduler.LeastRoutersScheduler" }}

# Allow auto scheduling of routers to L3 agent. (boolean value)
# from .default.neutron.db.router_auto_schedule
{{ if not .default.neutron.db.router_auto_schedule }}#{{ end }}router_auto_schedule = {{ .default.neutron.db.router_auto_schedule | default "true" }}

# Automatically reschedule routers from offline L3 agents to online L3 agents.
# (boolean value)
# from .default.neutron.db.allow_automatic_l3agent_failover
{{ if not .default.neutron.db.allow_automatic_l3agent_failover }}#{{ end }}allow_automatic_l3agent_failover = {{ .default.neutron.db.allow_automatic_l3agent_failover | default "false" }}

# Enable HA mode for virtual routers. (boolean value)
# from .default.neutron.db.l3_ha
{{ if not .default.neutron.db.l3_ha }}#{{ end }}l3_ha = {{ .default.neutron.db.l3_ha | default "false" }}

# Maximum number of L3 agents which a HA router will be scheduled on. If it is
# set to 0 then the router will be scheduled on every agent. (integer value)
# from .default.neutron.db.max_l3_agents_per_router
{{ if not .default.neutron.db.max_l3_agents_per_router }}#{{ end }}max_l3_agents_per_router = {{ .default.neutron.db.max_l3_agents_per_router | default "3" }}

# DEPRECATED: Minimum number of L3 agents that have to be available in order to
# allow a new HA router to be scheduled. This option is deprecated in the
# Newton release and will be removed for the Ocata release where the scheduling
# of new HA routers will always be allowed. (integer value)
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# from .default.neutron.db.min_l3_agents_per_router
{{ if not .default.neutron.db.min_l3_agents_per_router }}#{{ end }}min_l3_agents_per_router = {{ .default.neutron.db.min_l3_agents_per_router | default "2" }}

# Subnet used for the l3 HA admin network. (string value)
# from .default.neutron.db.l3_ha_net_cidr
{{ if not .default.neutron.db.l3_ha_net_cidr }}#{{ end }}l3_ha_net_cidr = {{ .default.neutron.db.l3_ha_net_cidr | default "169.254.192.0/18" }}

# The network type to use when creating the HA network for an HA router. By
# default or if empty, the first 'tenant_network_types' is used. This is
# helpful when the VRRP traffic should use a specific network which is not the
# default one. (string value)
# from .default.neutron.db.l3_ha_network_type
{{ if not .default.neutron.db.l3_ha_network_type }}#{{ end }}l3_ha_network_type = {{ .default.neutron.db.l3_ha_network_type | default "" }}

# The physical network name with which the HA network can be created. (string
# value)
# from .default.neutron.db.l3_ha_network_physical_name
{{ if not .default.neutron.db.l3_ha_network_physical_name }}#{{ end }}l3_ha_network_physical_name = {{ .default.neutron.db.l3_ha_network_physical_name | default "" }}

#
# From neutron.extensions
#

# Maximum number of allowed address pairs (integer value)
# from .default.neutron.extensions.max_allowed_address_pair
{{ if not .default.neutron.extensions.max_allowed_address_pair }}#{{ end }}max_allowed_address_pair = {{ .default.neutron.extensions.max_allowed_address_pair | default "10" }}

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
{{ if not .default.oslo.messaging.control_exchange }}#{{ end }}control_exchange = {{ .default.oslo.messaging.control_exchange | default "neutron" }}

#
# From oslo.service.wsgi
#

# File name for the paste.deploy config for api service (string value)
# from .default.oslo.service.wsgi.api_paste_config
{{ if not .default.oslo.service.wsgi.api_paste_config }}#{{ end }}api_paste_config = {{ .default.oslo.service.wsgi.api_paste_config | default "api-paste.ini" }}

# A python format string that is used as the template to generate log lines.
# The following values can beformatted into it: client_ip, date_time,
# request_line, status_code, body_length, wall_seconds. (string value)
# from .default.oslo.service.wsgi.wsgi_log_format
{{ if not .default.oslo.service.wsgi.wsgi_log_format }}#{{ end }}wsgi_log_format = {{ .default.oslo.service.wsgi.wsgi_log_format | default "%(client_ip)s \"%(request_line)s\" status: %(status_code)s  len: %(body_length)s time: %(wall_seconds).7f" }}

# Sets the value of TCP_KEEPIDLE in seconds for each server socket. Not
# supported on OS X. (integer value)
# from .default.oslo.service.wsgi.tcp_keepidle
{{ if not .default.oslo.service.wsgi.tcp_keepidle }}#{{ end }}tcp_keepidle = {{ .default.oslo.service.wsgi.tcp_keepidle | default "600" }}

# Size of the pool of greenthreads used by wsgi (integer value)
# from .default.oslo.service.wsgi.wsgi_default_pool_size
{{ if not .default.oslo.service.wsgi.wsgi_default_pool_size }}#{{ end }}wsgi_default_pool_size = {{ .default.oslo.service.wsgi.wsgi_default_pool_size | default "100" }}

# Maximum line size of message headers to be accepted. max_header_line may need
# to be increased when using large tokens (typically those generated when
# keystone is configured to use PKI tokens with big service catalogs). (integer
# value)
# from .default.oslo.service.wsgi.max_header_line
{{ if not .default.oslo.service.wsgi.max_header_line }}#{{ end }}max_header_line = {{ .default.oslo.service.wsgi.max_header_line | default "16384" }}

# If False, closes the client socket connection explicitly. (boolean value)
# from .default.oslo.service.wsgi.wsgi_keep_alive
{{ if not .default.oslo.service.wsgi.wsgi_keep_alive }}#{{ end }}wsgi_keep_alive = {{ .default.oslo.service.wsgi.wsgi_keep_alive | default "true" }}

# Timeout for client connections' socket operations. If an incoming connection
# is idle for this number of seconds it will be closed. A value of '0' means
# wait forever. (integer value)
# from .default.oslo.service.wsgi.client_socket_timeout
{{ if not .default.oslo.service.wsgi.client_socket_timeout }}#{{ end }}client_socket_timeout = {{ .default.oslo.service.wsgi.client_socket_timeout | default "900" }}


[agent]

#
# From neutron.agent
#

# Root helper application. Use 'sudo neutron-rootwrap
# /etc/neutron/rootwrap.conf' to use the real root filter facility. Change to
# 'sudo' to skip the filtering and just run the command directly. (string
# value)
# from .agent.neutron.agent.root_helper
{{ if not .agent.neutron.agent.root_helper }}#{{ end }}root_helper = {{ .agent.neutron.agent.root_helper | default "sudo" }}

# Use the root helper when listing the namespaces on a system. This may not be
# required depending on the security configuration. If the root helper is not
# required, set this to False for a performance improvement. (boolean value)
# from .agent.neutron.agent.use_helper_for_ns_read
{{ if not .agent.neutron.agent.use_helper_for_ns_read }}#{{ end }}use_helper_for_ns_read = {{ .agent.neutron.agent.use_helper_for_ns_read | default "true" }}

# Root helper daemon application to use when possible. (string value)
# from .agent.neutron.agent.root_helper_daemon
{{ if not .agent.neutron.agent.root_helper_daemon }}#{{ end }}root_helper_daemon = {{ .agent.neutron.agent.root_helper_daemon | default "<None>" }}

# Seconds between nodes reporting state to server; should be less than
# agent_down_time, best if it is half or less than agent_down_time. (floating
# point value)
# from .agent.neutron.agent.report_interval
{{ if not .agent.neutron.agent.report_interval }}#{{ end }}report_interval = {{ .agent.neutron.agent.report_interval | default "30" }}

# Log agent heartbeats (boolean value)
# from .agent.neutron.agent.log_agent_heartbeats
{{ if not .agent.neutron.agent.log_agent_heartbeats }}#{{ end }}log_agent_heartbeats = {{ .agent.neutron.agent.log_agent_heartbeats | default "false" }}

# Add comments to iptables rules. Set to false to disallow the addition of
# comments to generated iptables rules that describe each rule's purpose.
# System must support the iptables comments module for addition of comments.
# (boolean value)
# from .agent.neutron.agent.comment_iptables_rules
{{ if not .agent.neutron.agent.comment_iptables_rules }}#{{ end }}comment_iptables_rules = {{ .agent.neutron.agent.comment_iptables_rules | default "true" }}

# Duplicate every iptables difference calculation to ensure the format being
# generated matches the format of iptables-save. This option should not be
# turned on for production systems because it imposes a performance penalty.
# (boolean value)
# from .agent.neutron.agent.debug_iptables_rules
{{ if not .agent.neutron.agent.debug_iptables_rules }}#{{ end }}debug_iptables_rules = {{ .agent.neutron.agent.debug_iptables_rules | default "false" }}

# Action to be executed when a child process dies (string value)
# Allowed values: respawn, exit
# from .agent.neutron.agent.check_child_processes_action
{{ if not .agent.neutron.agent.check_child_processes_action }}#{{ end }}check_child_processes_action = {{ .agent.neutron.agent.check_child_processes_action | default "respawn" }}

# Interval between checks of child process liveness (seconds), use 0 to disable
# (integer value)
# from .agent.neutron.agent.check_child_processes_interval
{{ if not .agent.neutron.agent.check_child_processes_interval }}#{{ end }}check_child_processes_interval = {{ .agent.neutron.agent.check_child_processes_interval | default "60" }}

# Availability zone of this node (string value)
# from .agent.neutron.agent.availability_zone
{{ if not .agent.neutron.agent.availability_zone }}#{{ end }}availability_zone = {{ .agent.neutron.agent.availability_zone | default "nova" }}


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
{{ if not .cors.oslo.middleware.cors.expose_headers }}#{{ end }}expose_headers = {{ .cors.oslo.middleware.cors.expose_headers | default "X-Auth-Token,X-Subject-Token,X-Service-Token,X-OpenStack-Request-ID,OpenStack-Volume-microversion" }}

# Maximum cache age of CORS preflight requests. (integer value)
# from .cors.oslo.middleware.cors.max_age
{{ if not .cors.oslo.middleware.cors.max_age }}#{{ end }}max_age = {{ .cors.oslo.middleware.cors.max_age | default "3600" }}

# Indicate which methods can be used during the actual request. (list value)
# from .cors.oslo.middleware.cors.allow_methods
{{ if not .cors.oslo.middleware.cors.allow_methods }}#{{ end }}allow_methods = {{ .cors.oslo.middleware.cors.allow_methods | default "GET,PUT,POST,DELETE,PATCH" }}

# Indicate which header field names may be used during the actual request.
# (list value)
# from .cors.oslo.middleware.cors.allow_headers
{{ if not .cors.oslo.middleware.cors.allow_headers }}#{{ end }}allow_headers = {{ .cors.oslo.middleware.cors.allow_headers | default "X-Auth-Token,X-Identity-Status,X-Roles,X-Service-Catalog,X-User-Id,X-Tenant-Id,X-OpenStack-Request-ID" }}


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
{{ if not .cors.subdomain.oslo.middleware.cors.expose_headers }}#{{ end }}expose_headers = {{ .cors.subdomain.oslo.middleware.cors.expose_headers | default "X-Auth-Token,X-Subject-Token,X-Service-Token,X-OpenStack-Request-ID,OpenStack-Volume-microversion" }}

# Maximum cache age of CORS preflight requests. (integer value)
# from .cors.subdomain.oslo.middleware.cors.max_age
{{ if not .cors.subdomain.oslo.middleware.cors.max_age }}#{{ end }}max_age = {{ .cors.subdomain.oslo.middleware.cors.max_age | default "3600" }}

# Indicate which methods can be used during the actual request. (list value)
# from .cors.subdomain.oslo.middleware.cors.allow_methods
{{ if not .cors.subdomain.oslo.middleware.cors.allow_methods }}#{{ end }}allow_methods = {{ .cors.subdomain.oslo.middleware.cors.allow_methods | default "GET,PUT,POST,DELETE,PATCH" }}

# Indicate which header field names may be used during the actual request.
# (list value)
# from .cors.subdomain.oslo.middleware.cors.allow_headers
{{ if not .cors.subdomain.oslo.middleware.cors.allow_headers }}#{{ end }}allow_headers = {{ .cors.subdomain.oslo.middleware.cors.allow_headers | default "X-Auth-Token,X-Identity-Status,X-Roles,X-Service-Catalog,X-User-Id,X-Tenant-Id,X-OpenStack-Request-ID" }}


[database]

#
# From neutron.db
#

# Database engine for which script will be generated when using offline
# migration. (string value)
# from .database.neutron.db.engine
{{ if not .database.neutron.db.engine }}#{{ end }}engine = {{ .database.neutron.db.engine | default "" }}

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

[keystone_authtoken]

#
# From keystonemiddleware.auth_token
#

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


[nova]

#
# From neutron
#

# Name of nova region to use. Useful if keystone manages more than one region.
# (string value)
# from .nova.neutron.region_name
{{ if not .nova.neutron.region_name }}#{{ end }}region_name = {{ .nova.neutron.region_name | default "<None>" }}

# Type of the nova endpoint to use.  This endpoint will be looked up in the
# keystone catalog and should be one of public, internal or admin. (string
# value)
# Allowed values: public, admin, internal
# from .nova.neutron.endpoint_type
{{ if not .nova.neutron.endpoint_type }}#{{ end }}endpoint_type = {{ .nova.neutron.endpoint_type | default "public" }}

#
# From nova.auth
#

# Authentication URL (string value)
# from .nova.nova.auth.auth_url
{{ if not .nova.nova.auth.auth_url }}#{{ end }}auth_url = {{ .nova.nova.auth.auth_url | default "<None>" }}

# Authentication type to load (string value)
# Deprecated group/name - [nova]/auth_plugin
# from .nova.nova.auth.auth_type
{{ if not .nova.nova.auth.auth_type }}#{{ end }}auth_type = {{ .nova.nova.auth.auth_type | default "<None>" }}

# PEM encoded Certificate Authority to use when verifying HTTPs connections.
# (string value)
# from .nova.nova.auth.cafile
{{ if not .nova.nova.auth.cafile }}#{{ end }}cafile = {{ .nova.nova.auth.cafile | default "<None>" }}

# PEM encoded client certificate cert file (string value)
# from .nova.nova.auth.certfile
{{ if not .nova.nova.auth.certfile }}#{{ end }}certfile = {{ .nova.nova.auth.certfile | default "<None>" }}

# Optional domain ID to use with v3 and v2 parameters. It will be used for both
# the user and project domain in v3 and ignored in v2 authentication. (string
# value)
# from .nova.nova.auth.default_domain_id
{{ if not .nova.nova.auth.default_domain_id }}#{{ end }}default_domain_id = {{ .nova.nova.auth.default_domain_id | default "<None>" }}

# Optional domain name to use with v3 API and v2 parameters. It will be used
# for both the user and project domain in v3 and ignored in v2 authentication.
# (string value)
# from .nova.nova.auth.default_domain_name
{{ if not .nova.nova.auth.default_domain_name }}#{{ end }}default_domain_name = {{ .nova.nova.auth.default_domain_name | default "<None>" }}

# Domain ID to scope to (string value)
# from .nova.nova.auth.domain_id
{{ if not .nova.nova.auth.domain_id }}#{{ end }}domain_id = {{ .nova.nova.auth.domain_id | default "<None>" }}

# Domain name to scope to (string value)
# from .nova.nova.auth.domain_name
{{ if not .nova.nova.auth.domain_name }}#{{ end }}domain_name = {{ .nova.nova.auth.domain_name | default "<None>" }}

# Verify HTTPS connections. (boolean value)
# from .nova.nova.auth.insecure
{{ if not .nova.nova.auth.insecure }}#{{ end }}insecure = {{ .nova.nova.auth.insecure | default "false" }}

# PEM encoded client certificate key file (string value)
# from .nova.nova.auth.keyfile
{{ if not .nova.nova.auth.keyfile }}#{{ end }}keyfile = {{ .nova.nova.auth.keyfile | default "<None>" }}

# User's password (string value)
# from .nova.nova.auth.password
{{ if not .nova.nova.auth.password }}#{{ end }}password = {{ .nova.nova.auth.password | default "<None>" }}

# Domain ID containing project (string value)
# from .nova.nova.auth.project_domain_id
{{ if not .nova.nova.auth.project_domain_id }}#{{ end }}project_domain_id = {{ .nova.nova.auth.project_domain_id | default "<None>" }}

# Domain name containing project (string value)
# from .nova.nova.auth.project_domain_name
{{ if not .nova.nova.auth.project_domain_name }}#{{ end }}project_domain_name = {{ .nova.nova.auth.project_domain_name | default "<None>" }}

# Project ID to scope to (string value)
# Deprecated group/name - [nova]/tenant-id
# from .nova.nova.auth.project_id
{{ if not .nova.nova.auth.project_id }}#{{ end }}project_id = {{ .nova.nova.auth.project_id | default "<None>" }}

# Project name to scope to (string value)
# Deprecated group/name - [nova]/tenant-name
# from .nova.nova.auth.project_name
{{ if not .nova.nova.auth.project_name }}#{{ end }}project_name = {{ .nova.nova.auth.project_name | default "<None>" }}

# Tenant ID (string value)
# from .nova.nova.auth.tenant_id
{{ if not .nova.nova.auth.tenant_id }}#{{ end }}tenant_id = {{ .nova.nova.auth.tenant_id | default "<None>" }}

# Tenant Name (string value)
# from .nova.nova.auth.tenant_name
{{ if not .nova.nova.auth.tenant_name }}#{{ end }}tenant_name = {{ .nova.nova.auth.tenant_name | default "<None>" }}

# Timeout value for http requests (integer value)
# from .nova.nova.auth.timeout
{{ if not .nova.nova.auth.timeout }}#{{ end }}timeout = {{ .nova.nova.auth.timeout | default "<None>" }}

# Trust ID (string value)
# from .nova.nova.auth.trust_id
{{ if not .nova.nova.auth.trust_id }}#{{ end }}trust_id = {{ .nova.nova.auth.trust_id | default "<None>" }}

# User's domain id (string value)
# from .nova.nova.auth.user_domain_id
{{ if not .nova.nova.auth.user_domain_id }}#{{ end }}user_domain_id = {{ .nova.nova.auth.user_domain_id | default "<None>" }}

# User's domain name (string value)
# from .nova.nova.auth.user_domain_name
{{ if not .nova.nova.auth.user_domain_name }}#{{ end }}user_domain_name = {{ .nova.nova.auth.user_domain_name | default "<None>" }}

# User id (string value)
# from .nova.nova.auth.user_id
{{ if not .nova.nova.auth.user_id }}#{{ end }}user_id = {{ .nova.nova.auth.user_id | default "<None>" }}

# Username (string value)
# Deprecated group/name - [nova]/user-name
# from .nova.nova.auth.username
{{ if not .nova.nova.auth.username }}#{{ end }}username = {{ .nova.nova.auth.username | default "<None>" }}


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


[oslo_middleware]

#
# From oslo.middleware.http_proxy_to_wsgi
#

# Whether the application is behind a proxy or not. This determines if the
# middleware should parse the headers or not. (boolean value)
# from .oslo_middleware.oslo.middleware.http_proxy_to_wsgi.enable_proxy_headers_parsing
{{ if not .oslo_middleware.oslo.middleware.http_proxy_to_wsgi.enable_proxy_headers_parsing }}#{{ end }}enable_proxy_headers_parsing = {{ .oslo_middleware.oslo.middleware.http_proxy_to_wsgi.enable_proxy_headers_parsing | default "false" }}


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


[qos]

#
# From neutron.qos
#

# Drivers list to use to send the update notification (list value)
# from .qos.neutron.qos.notification_drivers
{{ if not .qos.neutron.qos.notification_drivers }}#{{ end }}notification_drivers = {{ .qos.neutron.qos.notification_drivers | default "message_queue" }}


[quotas]

#
# From neutron
#

# Default number of resource allowed per tenant. A negative value means
# unlimited. (integer value)
# from .quotas.neutron.default_quota
{{ if not .quotas.neutron.default_quota }}#{{ end }}default_quota = {{ .quotas.neutron.default_quota | default "-1" }}

# Number of networks allowed per tenant. A negative value means unlimited.
# (integer value)
# from .quotas.neutron.quota_network
{{ if not .quotas.neutron.quota_network }}#{{ end }}quota_network = {{ .quotas.neutron.quota_network | default "10" }}

# Number of subnets allowed per tenant, A negative value means unlimited.
# (integer value)
# from .quotas.neutron.quota_subnet
{{ if not .quotas.neutron.quota_subnet }}#{{ end }}quota_subnet = {{ .quotas.neutron.quota_subnet | default "10" }}

# Number of ports allowed per tenant. A negative value means unlimited.
# (integer value)
# from .quotas.neutron.quota_port
{{ if not .quotas.neutron.quota_port }}#{{ end }}quota_port = {{ .quotas.neutron.quota_port | default "50" }}

# Default driver to use for quota checks. (string value)
# from .quotas.neutron.quota_driver
{{ if not .quotas.neutron.quota_driver }}#{{ end }}quota_driver = {{ .quotas.neutron.quota_driver | default "neutron.db.quota.driver.DbQuotaDriver" }}

# Keep in track in the database of current resource quota usage. Plugins which
# do not leverage the neutron database should set this flag to False. (boolean
# value)
# from .quotas.neutron.track_quota_usage
{{ if not .quotas.neutron.track_quota_usage }}#{{ end }}track_quota_usage = {{ .quotas.neutron.track_quota_usage | default "true" }}

#
# From neutron.extensions
#

# Number of routers allowed per tenant. A negative value means unlimited.
# (integer value)
# from .quotas.neutron.extensions.quota_router
{{ if not .quotas.neutron.extensions.quota_router }}#{{ end }}quota_router = {{ .quotas.neutron.extensions.quota_router | default "10" }}

# Number of floating IPs allowed per tenant. A negative value means unlimited.
# (integer value)
# from .quotas.neutron.extensions.quota_floatingip
{{ if not .quotas.neutron.extensions.quota_floatingip }}#{{ end }}quota_floatingip = {{ .quotas.neutron.extensions.quota_floatingip | default "50" }}

# Number of security groups allowed per tenant. A negative value means
# unlimited. (integer value)
# from .quotas.neutron.extensions.quota_security_group
{{ if not .quotas.neutron.extensions.quota_security_group }}#{{ end }}quota_security_group = {{ .quotas.neutron.extensions.quota_security_group | default "10" }}

# Number of security rules allowed per tenant. A negative value means
# unlimited. (integer value)
# from .quotas.neutron.extensions.quota_security_group_rule
{{ if not .quotas.neutron.extensions.quota_security_group_rule }}#{{ end }}quota_security_group_rule = {{ .quotas.neutron.extensions.quota_security_group_rule | default "100" }}


[ssl]

#
# From oslo.service.sslutils
#

# CA certificate file to use to verify connecting clients. (string value)
# Deprecated group/name - [DEFAULT]/ssl_ca_file
# from .ssl.oslo.service.sslutils.ca_file
{{ if not .ssl.oslo.service.sslutils.ca_file }}#{{ end }}ca_file = {{ .ssl.oslo.service.sslutils.ca_file | default "<None>" }}

# Certificate file to use when starting the server securely. (string value)
# Deprecated group/name - [DEFAULT]/ssl_cert_file
# from .ssl.oslo.service.sslutils.cert_file
{{ if not .ssl.oslo.service.sslutils.cert_file }}#{{ end }}cert_file = {{ .ssl.oslo.service.sslutils.cert_file | default "<None>" }}

# Private key file to use when starting the server securely. (string value)
# Deprecated group/name - [DEFAULT]/ssl_key_file
# from .ssl.oslo.service.sslutils.key_file
{{ if not .ssl.oslo.service.sslutils.key_file }}#{{ end }}key_file = {{ .ssl.oslo.service.sslutils.key_file | default "<None>" }}

# SSL version to use (valid only if SSL enabled). Valid values are TLSv1 and
# SSLv23. SSLv2, SSLv3, TLSv1_1, and TLSv1_2 may be available on some
# distributions. (string value)
# from .ssl.oslo.service.sslutils.version
{{ if not .ssl.oslo.service.sslutils.version }}#{{ end }}version = {{ .ssl.oslo.service.sslutils.version | default "<None>" }}

# Sets the list of available ciphers. value should be a string in the OpenSSL
# cipher list format. (string value)
# from .ssl.oslo.service.sslutils.ciphers
{{ if not .ssl.oslo.service.sslutils.ciphers }}#{{ end }}ciphers = {{ .ssl.oslo.service.sslutils.ciphers | default "<None>" }}

{{- end -}}
