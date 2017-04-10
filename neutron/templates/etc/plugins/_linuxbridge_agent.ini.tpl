[DEFAULT]

#
# From oslo.log
#

# If set to true, the logging level will be set to DEBUG instead of the default
# INFO level. (boolean value)
# Note: This option can be changed without restarting.
#debug = false

# DEPRECATED: If set to false, the logging level will be set to WARNING instead
# of the default INFO level. (boolean value)
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
#verbose = true

# The name of a logging configuration file. This file is appended to any
# existing logging configuration files. For details about logging configuration
# files, see the Python logging module documentation. Note that when logging
# configuration files are used then all logging configuration is set in the
# configuration file and other logging configuration options are ignored (for
# example, logging_context_format_string). (string value)
# Note: This option can be changed without restarting.
# Deprecated group/name - [DEFAULT]/log_config
#log_config_append = <None>

# Defines the format string for %%(asctime)s in log records. Default:
# %(default)s . This option is ignored if log_config_append is set. (string
# value)
#log_date_format = %Y-%m-%d %H:%M:%S

# (Optional) Name of log file to send logging output to. If no default is set,
# logging will go to stderr as defined by use_stderr. This option is ignored if
# log_config_append is set. (string value)
# Deprecated group/name - [DEFAULT]/logfile
#log_file = <None>

# (Optional) The base directory used for relative log_file  paths. This option
# is ignored if log_config_append is set. (string value)
# Deprecated group/name - [DEFAULT]/logdir
#log_dir = <None>

# Uses logging handler designed to watch file system. When log file is moved or
# removed this handler will open a new log file with specified path
# instantaneously. It makes sense only if log_file option is specified and
# Linux platform is used. This option is ignored if log_config_append is set.
# (boolean value)
#watch_log_file = false

# Use syslog for logging. Existing syslog format is DEPRECATED and will be
# changed later to honor RFC5424. This option is ignored if log_config_append
# is set. (boolean value)
#use_syslog = false

# Syslog facility to receive log lines. This option is ignored if
# log_config_append is set. (string value)
#syslog_log_facility = LOG_USER

# Log output to standard error. This option is ignored if log_config_append is
# set. (boolean value)
#use_stderr = true

# Format string to use for log messages with context. (string value)
#logging_context_format_string = %(asctime)s.%(msecs)03d %(process)d %(levelname)s %(name)s [%(request_id)s %(user_identity)s] %(instance)s%(message)s

# Format string to use for log messages when context is undefined. (string
# value)
#logging_default_format_string = %(asctime)s.%(msecs)03d %(process)d %(levelname)s %(name)s [-] %(instance)s%(message)s

# Additional data to append to log message when logging level for the message
# is DEBUG. (string value)
#logging_debug_format_suffix = %(funcName)s %(pathname)s:%(lineno)d

# Prefix each line of exception output with this format. (string value)
#logging_exception_prefix = %(asctime)s.%(msecs)03d %(process)d ERROR %(name)s %(instance)s

# Defines the format string for %(user_identity)s that is used in
# logging_context_format_string. (string value)
#logging_user_identity_format = %(user)s %(tenant)s %(domain)s %(user_domain)s %(project_domain)s

# List of package logging levels in logger=LEVEL pairs. This option is ignored
# if log_config_append is set. (list value)
#default_log_levels = amqp=WARN,amqplib=WARN,boto=WARN,qpid=WARN,sqlalchemy=WARN,suds=INFO,oslo.messaging=INFO,iso8601=WARN,requests.packages.urllib3.connectionpool=WARN,urllib3.connectionpool=WARN,websocket=WARN,requests.packages.urllib3.util.retry=WARN,urllib3.util.retry=WARN,keystonemiddleware=WARN,routes.middleware=WARN,stevedore=WARN,taskflow=WARN,keystoneauth=WARN,oslo.cache=INFO,dogpile.core.dogpile=INFO

# Enables or disables publication of error events. (boolean value)
#publish_errors = false

# The format for an instance that is passed with the log message. (string
# value)
#instance_format = "[instance: %(uuid)s] "

# The format for an instance UUID that is passed with the log message. (string
# value)
#instance_uuid_format = "[instance: %(uuid)s] "

# Enables or disables fatal status of deprecations. (boolean value)
#fatal_deprecations = false


[agent]

#
# From neutron.ml2.linuxbridge.agent
#

# The number of seconds the agent will wait between polling for local device
# changes. (integer value)
#polling_interval = 2

# Set new timeout in seconds for new rpc calls after agent receives SIGTERM. If
# value is set to 0, rpc timeout won't be changed (integer value)
#quitting_rpc_timeout = 10

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
#prevent_arp_spoofing = true

# Extensions list to use (list value)
#extensions =


[linux_bridge]

#
# From neutron.ml2.linuxbridge.agent
#

# Comma-separated list of <physical_network>:<physical_interface> tuples
# mapping physical network names to the agent's node-specific physical network
# interfaces to be used for flat and VLAN networks. All physical networks
# listed in network_vlan_ranges on the server should have mappings to
# appropriate interfaces on each agent. (list value)
#physical_interface_mappings =

# List of <physical_network>:<physical_bridge> (list value)
#bridge_mappings =


[securitygroup]

#
# From neutron.ml2.linuxbridge.agent
#

# Driver for security groups firewall in the L2 agent (string value)
#firewall_driver = <None>

# Controls whether the neutron security group API is enabled in the server. It
# should be false when using no security groups or using the nova security
# group API. (boolean value)
#enable_security_group = true

# Use ipset to speed-up the iptables based security groups. Enabling ipset
# support requires that ipset is installed on L2 agent node. (boolean value)
#enable_ipset = true


[vxlan]

#
# From neutron.ml2.linuxbridge.agent
#

# Enable VXLAN on the agent. Can be enabled when agent is managed by ml2 plugin
# using linuxbridge mechanism driver (boolean value)
#enable_vxlan = true

# TTL for vxlan interface protocol packets. (integer value)
#ttl = <None>

# TOS for vxlan interface protocol packets. (integer value)
#tos = <None>

# Multicast group(s) for vxlan interface. A range of group addresses may be
# specified by using CIDR notation. Specifying a range allows different VNIs to
# use different group addresses, reducing or eliminating spurious broadcast
# traffic to the tunnel endpoints. To reserve a unique group for each possible
# (24-bit) VNI, use a /8 such as 239.0.0.0/8. This setting must be the same on
# all the agents. (string value)
#vxlan_group = 224.0.0.1

# IP address of local overlay (tunnel) network endpoint. Use either an IPv4 or
# IPv6 address that resides on one of the host network interfaces. The IP
# version of this value must match the value of the 'overlay_ip_version' option
# in the ML2 plug-in configuration file on the neutron server node(s). (IP
# address value)
#local_ip = <None>

# Extension to use alongside ml2 plugin's l2population mechanism driver. It
# enables the plugin to populate VXLAN forwarding table. (boolean value)
#l2_population = false

# Enable local ARP responder which provides local responses instead of
# performing ARP broadcast into the overlay. Enabling local ARP responder is
# not fully compatible with the allowed-address-pairs extension. (boolean
# value)
#arp_responder = false
