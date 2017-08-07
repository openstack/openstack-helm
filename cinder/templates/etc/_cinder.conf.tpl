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

{{ include "cinder.conf.cinder_values_skeleton" .Values.conf.cinder | trunc 0 }}
{{ include "cinder.conf.cinder" .Values.conf.cinder }}


{{- define "cinder.conf.cinder_values_skeleton" -}}

{{- if not .default -}}{{- set . "default" dict -}}{{- end -}}
{{- if not .default.cinder -}}{{- set .default "cinder" dict -}}{{- end -}}
{{- if not .default.oslo -}}{{- set .default "oslo" dict -}}{{- end -}}
{{- if not .default.oslo.config -}}{{- set .default.oslo "config" dict -}}{{- end -}}
{{- if not .default.oslo.log -}}{{- set .default.oslo "log" dict -}}{{- end -}}
{{- if not .default.oslo.messaging -}}{{- set .default.oslo "messaging" dict -}}{{- end -}}
{{- if not .default.oslo.service -}}{{- set .default.oslo "service" dict -}}{{- end -}}
{{- if not .default.oslo.service.periodic_task -}}{{- set .default.oslo.service "periodic_task" dict -}}{{- end -}}
{{- if not .default.oslo.service.service -}}{{- set .default.oslo.service "service" dict -}}{{- end -}}
{{- if not .default.oslo.service.wsgi -}}{{- set .default.oslo.service "wsgi" dict -}}{{- end -}}
{{- if not .backend -}}{{- set . "backend" dict -}}{{- end -}}
{{- if not .backend.cinder -}}{{- set .backend "cinder" dict -}}{{- end -}}
{{- if not .brcd_fabric_example -}}{{- set . "brcd_fabric_example" dict -}}{{- end -}}
{{- if not .brcd_fabric_example.cinder -}}{{- set .brcd_fabric_example "cinder" dict -}}{{- end -}}
{{- if not .cisco_fabric_example -}}{{- set . "cisco_fabric_example" dict -}}{{- end -}}
{{- if not .cisco_fabric_example.cinder -}}{{- set .cisco_fabric_example "cinder" dict -}}{{- end -}}
{{- if not .coordination -}}{{- set . "coordination" dict -}}{{- end -}}
{{- if not .coordination.cinder -}}{{- set .coordination "cinder" dict -}}{{- end -}}
{{- if not .fc_zone_manager -}}{{- set . "fc_zone_manager" dict -}}{{- end -}}
{{- if not .fc_zone_manager.cinder -}}{{- set .fc_zone_manager "cinder" dict -}}{{- end -}}
{{- if not .key_manager -}}{{- set . "key_manager" dict -}}{{- end -}}
{{- if not .key_manager.cinder -}}{{- set .key_manager "cinder" dict -}}{{- end -}}
{{- if not .barbican -}}{{- set . "barbican" dict -}}{{- end -}}
{{- if not .barbican.castellan -}}{{- set .barbican "castellan" dict -}}{{- end -}}
{{- if not .barbican.castellan.config -}}{{- set .barbican.castellan "config" dict -}}{{- end -}}
{{- if not .cors -}}{{- set . "cors" dict -}}{{- end -}}
{{- if not .cors.oslo -}}{{- set .cors "oslo" dict -}}{{- end -}}
{{- if not .cors.oslo.middleware -}}{{- set .cors.oslo "middleware" dict -}}{{- end -}}
{{- if not .cors.subdomain -}}{{- set .cors "subdomain" dict -}}{{- end -}}
{{- if not .cors.subdomain.oslo -}}{{- set .cors.subdomain "oslo" dict -}}{{- end -}}
{{- if not .cors.subdomain.oslo.middleware -}}{{- set .cors.subdomain.oslo "middleware" dict -}}{{- end -}}
{{- if not .database -}}{{- set . "database" dict -}}{{- end -}}
{{- if not .database.oslo -}}{{- set .database "oslo" dict -}}{{- end -}}
{{- if not .database.oslo.db -}}{{- set .database.oslo "db" dict -}}{{- end -}}
{{- if not .key_manager.castellan -}}{{- set .key_manager "castellan" dict -}}{{- end -}}
{{- if not .key_manager.castellan.config -}}{{- set .key_manager.castellan "config" dict -}}{{- end -}}
{{- if not .keystone_authtoken -}}{{- set . "keystone_authtoken" dict -}}{{- end -}}
{{- if not .keystone_authtoken.keystonemiddleware -}}{{- set .keystone_authtoken "keystonemiddleware" dict -}}{{- end -}}
{{- if not .keystone_authtoken.keystonemiddleware.auth_token -}}{{- set .keystone_authtoken.keystonemiddleware "auth_token" dict -}}{{- end -}}
{{- if not .matchmaker_redis -}}{{- set . "matchmaker_redis" dict -}}{{- end -}}
{{- if not .matchmaker_redis.oslo -}}{{- set .matchmaker_redis "oslo" dict -}}{{- end -}}
{{- if not .matchmaker_redis.oslo.messaging -}}{{- set .matchmaker_redis.oslo "messaging" dict -}}{{- end -}}
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
{{- if not .oslo_policy -}}{{- set . "oslo_policy" dict -}}{{- end -}}
{{- if not .oslo_policy.oslo -}}{{- set .oslo_policy "oslo" dict -}}{{- end -}}
{{- if not .oslo_policy.oslo.policy -}}{{- set .oslo_policy.oslo "policy" dict -}}{{- end -}}
{{- if not .oslo_reports -}}{{- set . "oslo_reports" dict -}}{{- end -}}
{{- if not .oslo_reports.oslo -}}{{- set .oslo_reports "oslo" dict -}}{{- end -}}
{{- if not .oslo_reports.oslo.reports -}}{{- set .oslo_reports.oslo "reports" dict -}}{{- end -}}
{{- if not .oslo_versionedobjects -}}{{- set . "oslo_versionedobjects" dict -}}{{- end -}}
{{- if not .oslo_versionedobjects.oslo -}}{{- set .oslo_versionedobjects "oslo" dict -}}{{- end -}}
{{- if not .oslo_versionedobjects.oslo.versionedobjects -}}{{- set .oslo_versionedobjects.oslo "versionedobjects" dict -}}{{- end -}}
{{- if not .ssl -}}{{- set . "ssl" dict -}}{{- end -}}
{{- if not .ssl.oslo -}}{{- set .ssl "oslo" dict -}}{{- end -}}
{{- if not .ssl.oslo.service -}}{{- set .ssl.oslo "service" dict -}}{{- end -}}
{{- if not .ssl.oslo.service.sslutils -}}{{- set .ssl.oslo.service "sslutils" dict -}}{{- end -}}

{{- end -}}


{{- define "cinder.conf.cinder" -}}

[DEFAULT]

#
# From cinder
#

# Backup metadata version to be used when backing up volume metadata.
# If this number is bumped, make sure the service doing the restore
# supports the new version. (integer value)
# from .default.cinder.backup_metadata_version
{{ if not .default.cinder.backup_metadata_version }}#{{ end }}backup_metadata_version = {{ .default.cinder.backup_metadata_version | default "2" }}

# The number of chunks or objects, for which one Ceilometer
# notification will be sent (integer value)
# from .default.cinder.backup_object_number_per_notification
{{ if not .default.cinder.backup_object_number_per_notification }}#{{ end }}backup_object_number_per_notification = {{ .default.cinder.backup_object_number_per_notification | default "10" }}

# Interval, in seconds, between two progress notifications reporting
# the backup status (integer value)
# from .default.cinder.backup_timer_interval
{{ if not .default.cinder.backup_timer_interval }}#{{ end }}backup_timer_interval = {{ .default.cinder.backup_timer_interval | default "120" }}

# Name of this cluster.  Used to group volume hosts that share the
# same backend configurations to work in HA Active-Active mode.
# Active-Active is not yet supported. (string value)
# from .default.cinder.cluster
{{ if not .default.cinder.cluster }}#{{ end }}cluster = {{ .default.cinder.cluster | default "<None>" }}

# The maximum number of items that a collection resource returns in a
# single response (integer value)
# from .default.cinder.osapi_max_limit
{{ if not .default.cinder.osapi_max_limit }}#{{ end }}osapi_max_limit = {{ .default.cinder.osapi_max_limit | default "1000" }}

# Base URL that will be presented to users in links to the OpenStack
# Volume API (string value)
# Deprecated group/name - [DEFAULT]/osapi_compute_link_prefix
# from .default.cinder.osapi_volume_base_URL
{{ if not .default.cinder.osapi_volume_base_URL }}#{{ end }}osapi_volume_base_URL = {{ .default.cinder.osapi_volume_base_URL | default "<None>" }}

# Volume filter options which non-admin user could use to query
# volumes. Default values are: ['name', 'status', 'metadata',
# 'availability_zone' ,'bootable', 'group_id'] (list value)
# from .default.cinder.query_volume_filters
{{ if not .default.cinder.query_volume_filters }}#{{ end }}query_volume_filters = {{ .default.cinder.query_volume_filters | default "name,status,metadata,availability_zone,bootable,group_id" }}

# Ceph configuration file to use. (string value)
# from .default.cinder.backup_ceph_conf
{{ if not .default.cinder.backup_ceph_conf }}#{{ end }}backup_ceph_conf = {{ .default.cinder.backup_ceph_conf | default "/etc/ceph/ceph.conf" }}

# The Ceph user to connect with. Default here is to use the same user
# as for Cinder volumes. If not using cephx this should be set to
# None. (string value)
# from .default.cinder.backup_ceph_user
{{ if not .default.cinder.backup_ceph_user }}#{{ end }}backup_ceph_user = {{ .default.cinder.backup_ceph_user | default "cinder" }}

# The chunk size, in bytes, that a backup is broken into before
# transfer to the Ceph object store. (integer value)
# from .default.cinder.backup_ceph_chunk_size
{{ if not .default.cinder.backup_ceph_chunk_size }}#{{ end }}backup_ceph_chunk_size = {{ .default.cinder.backup_ceph_chunk_size | default "134217728" }}

# The Ceph pool where volume backups are stored. (string value)
# from .default.cinder.backup_ceph_pool
{{ if not .default.cinder.backup_ceph_pool }}#{{ end }}backup_ceph_pool = {{ .default.cinder.backup_ceph_pool | default "backups" }}

# RBD stripe unit to use when creating a backup image. (integer value)
# from .default.cinder.backup_ceph_stripe_unit
{{ if not .default.cinder.backup_ceph_stripe_unit }}#{{ end }}backup_ceph_stripe_unit = {{ .default.cinder.backup_ceph_stripe_unit | default "0" }}

# RBD stripe count to use when creating a backup image. (integer
# value)
# from .default.cinder.backup_ceph_stripe_count
{{ if not .default.cinder.backup_ceph_stripe_count }}#{{ end }}backup_ceph_stripe_count = {{ .default.cinder.backup_ceph_stripe_count | default "0" }}

# If True, always discard excess bytes when restoring volumes i.e. pad
# with zeroes. (boolean value)
# from .default.cinder.restore_discard_excess_bytes
{{ if not .default.cinder.restore_discard_excess_bytes }}#{{ end }}restore_discard_excess_bytes = {{ .default.cinder.restore_discard_excess_bytes | default "true" }}

# Compression algorithm (None to disable) (string value)
# from .default.cinder.backup_compression_algorithm
{{ if not .default.cinder.backup_compression_algorithm }}#{{ end }}backup_compression_algorithm = {{ .default.cinder.backup_compression_algorithm | default "zlib" }}

# Sets the value of TCP_KEEPALIVE (True/False) for each server socket.
# (boolean value)
# from .default.cinder.tcp_keepalive
{{ if not .default.cinder.tcp_keepalive }}#{{ end }}tcp_keepalive = {{ .default.cinder.tcp_keepalive | default "true" }}

# Sets the value of TCP_KEEPINTVL in seconds for each server socket.
# Not supported on OS X. (integer value)
# from .default.cinder.tcp_keepalive_interval
{{ if not .default.cinder.tcp_keepalive_interval }}#{{ end }}tcp_keepalive_interval = {{ .default.cinder.tcp_keepalive_interval | default "<None>" }}

# Sets the value of TCP_KEEPCNT for each server socket. Not supported
# on OS X. (integer value)
# from .default.cinder.tcp_keepalive_count
{{ if not .default.cinder.tcp_keepalive_count }}#{{ end }}tcp_keepalive_count = {{ .default.cinder.tcp_keepalive_count | default "<None>" }}

# Option to enable strict host key checking.  When set to "True"
# Cinder will only connect to systems with a host key present in the
# configured "ssh_hosts_key_file".  When set to "False" the host key
# will be saved upon first connection and used for subsequent
# connections.  Default=False (boolean value)
# from .default.cinder.strict_ssh_host_key_policy
{{ if not .default.cinder.strict_ssh_host_key_policy }}#{{ end }}strict_ssh_host_key_policy = {{ .default.cinder.strict_ssh_host_key_policy | default "false" }}

# File containing SSH host keys for the systems with which Cinder
# needs to communicate.  OPTIONAL: Default=$state_path/ssh_known_hosts
# (string value)
# from .default.cinder.ssh_hosts_key_file
{{ if not .default.cinder.ssh_hosts_key_file }}#{{ end }}ssh_hosts_key_file = {{ .default.cinder.ssh_hosts_key_file | default "$state_path/ssh_known_hosts" }}

# Base dir containing mount point for gluster share. (string value)
# from .default.cinder.glusterfs_backup_mount_point
{{ if not .default.cinder.glusterfs_backup_mount_point }}#{{ end }}glusterfs_backup_mount_point = {{ .default.cinder.glusterfs_backup_mount_point | default "$state_path/backup_mount" }}

# GlusterFS share in <hostname|ipv4addr|ipv6addr>:<gluster_vol_name>
# format. Eg: 1.2.3.4:backup_vol (string value)
# from .default.cinder.glusterfs_backup_share
{{ if not .default.cinder.glusterfs_backup_share }}#{{ end }}glusterfs_backup_share = {{ .default.cinder.glusterfs_backup_share | default "<None>" }}

# Volume prefix for the backup id when backing up to TSM (string
# value)
# from .default.cinder.backup_tsm_volume_prefix
{{ if not .default.cinder.backup_tsm_volume_prefix }}#{{ end }}backup_tsm_volume_prefix = {{ .default.cinder.backup_tsm_volume_prefix | default "backup" }}

# TSM password for the running username (string value)
# from .default.cinder.backup_tsm_password
{{ if not .default.cinder.backup_tsm_password }}#{{ end }}backup_tsm_password = {{ .default.cinder.backup_tsm_password | default "password" }}

# Enable or Disable compression for backups (boolean value)
# from .default.cinder.backup_tsm_compression
{{ if not .default.cinder.backup_tsm_compression }}#{{ end }}backup_tsm_compression = {{ .default.cinder.backup_tsm_compression | default "true" }}

# Make exception message format errors fatal. (boolean value)
# from .default.cinder.fatal_exception_format_errors
{{ if not .default.cinder.fatal_exception_format_errors }}#{{ end }}fatal_exception_format_errors = {{ .default.cinder.fatal_exception_format_errors | default "false" }}

# Top-level directory for maintaining cinder's state (string value)
# Deprecated group/name - [DEFAULT]/pybasedir
# from .default.cinder.state_path
{{ if not .default.cinder.state_path }}#{{ end }}state_path = {{ .default.cinder.state_path | default "/var/lib/cinder" }}

# IP address of this host (string value)
# from .default.cinder.my_ip
{{ if not .default.cinder.my_ip }}#{{ end }}my_ip = {{ .default.cinder.my_ip | default "10.102.86.147" }}

# A list of the URLs of glance API servers available to cinder
# ([http[s]://][hostname|ip]:port). If protocol is not specified it
# defaults to http. (list value)
# from .default.cinder.glance_api_servers
{{ if not .default.cinder.glance_api_servers }}#{{ end }}glance_api_servers = {{ .default.cinder.glance_api_servers | default "<None>" }}

# Version of the glance API to use (integer value)
# from .default.cinder.glance_api_version
{{ if not .default.cinder.glance_api_version }}#{{ end }}glance_api_version = {{ .default.cinder.glance_api_version | default "1" }}

# Number retries when downloading an image from glance (integer value)
# Minimum value: 0
# from .default.cinder.glance_num_retries
{{ if not .default.cinder.glance_num_retries }}#{{ end }}glance_num_retries = {{ .default.cinder.glance_num_retries | default "0" }}

# Allow to perform insecure SSL (https) requests to glance (https will
# be used but cert validation will not be performed). (boolean value)
# from .default.cinder.glance_api_insecure
{{ if not .default.cinder.glance_api_insecure }}#{{ end }}glance_api_insecure = {{ .default.cinder.glance_api_insecure | default "false" }}

# Enables or disables negotiation of SSL layer compression. In some
# cases disabling compression can improve data throughput, such as
# when high network bandwidth is available and you use compressed
# image formats like qcow2. (boolean value)
# from .default.cinder.glance_api_ssl_compression
{{ if not .default.cinder.glance_api_ssl_compression }}#{{ end }}glance_api_ssl_compression = {{ .default.cinder.glance_api_ssl_compression | default "false" }}

# Location of ca certificates file to use for glance client requests.
# (string value)
# from .default.cinder.glance_ca_certificates_file
{{ if not .default.cinder.glance_ca_certificates_file }}#{{ end }}glance_ca_certificates_file = {{ .default.cinder.glance_ca_certificates_file | default "<None>" }}

# http/https timeout value for glance operations. If no value (None)
# is supplied here, the glanceclient default value is used. (integer
# value)
# from .default.cinder.glance_request_timeout
{{ if not .default.cinder.glance_request_timeout }}#{{ end }}glance_request_timeout = {{ .default.cinder.glance_request_timeout | default "<None>" }}

# DEPRECATED: Deploy v1 of the Cinder API. (boolean value)
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# from .default.cinder.enable_v1_api
{{ if not .default.cinder.enable_v1_api }}#{{ end }}enable_v1_api = {{ .default.cinder.enable_v1_api | default "true" }}

# DEPRECATED: Deploy v2 of the Cinder API. (boolean value)
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# from .default.cinder.enable_v2_api
{{ if not .default.cinder.enable_v2_api }}#{{ end }}enable_v2_api = {{ .default.cinder.enable_v2_api | default "true" }}

# Deploy v3 of the Cinder API. (boolean value)
# from .default.cinder.enable_v3_api
{{ if not .default.cinder.enable_v3_api }}#{{ end }}enable_v3_api = {{ .default.cinder.enable_v3_api | default "true" }}

# Enables or disables rate limit of the API. (boolean value)
# from .default.cinder.api_rate_limit
{{ if not .default.cinder.api_rate_limit }}#{{ end }}api_rate_limit = {{ .default.cinder.api_rate_limit | default "true" }}

# Specify list of extensions to load when using osapi_volume_extension
# option with cinder.api.contrib.select_extensions (list value)
# from .default.cinder.osapi_volume_ext_list
{{ if not .default.cinder.osapi_volume_ext_list }}#{{ end }}osapi_volume_ext_list = {{ .default.cinder.osapi_volume_ext_list | default "" }}

# osapi volume extension to load (multi valued)
# from .default.cinder.osapi_volume_extension (multiopt)
{{ if not .default.cinder.osapi_volume_extension }}#osapi_volume_extension = {{ .default.cinder.osapi_volume_extension | default "cinder.api.contrib.standard_extensions" }}{{ else }}{{ range .default.cinder.osapi_volume_extension }}osapi_volume_extension = {{ . }}
{{ end }}{{ end }}

# Full class name for the Manager for volume (string value)
# from .default.cinder.volume_manager
{{ if not .default.cinder.volume_manager }}#{{ end }}volume_manager = {{ .default.cinder.volume_manager | default "cinder.volume.manager.VolumeManager" }}

# Full class name for the Manager for volume backup (string value)
# from .default.cinder.backup_manager
{{ if not .default.cinder.backup_manager }}#{{ end }}backup_manager = {{ .default.cinder.backup_manager | default "cinder.backup.manager.BackupManager" }}

# Full class name for the Manager for scheduler (string value)
# from .default.cinder.scheduler_manager
{{ if not .default.cinder.scheduler_manager }}#{{ end }}scheduler_manager = {{ .default.cinder.scheduler_manager | default "cinder.scheduler.manager.SchedulerManager" }}

# Name of this node.  This can be an opaque identifier. It is not
# necessarily a host name, FQDN, or IP address. (string value)
# from .default.cinder.host
{{ if not .default.cinder.host }}#{{ end }}host = {{ .default.cinder.host | default "cinder-volume-worker" }}

# Availability zone of this node (string value)
# from .default.cinder.storage_availability_zone
{{ if not .default.cinder.storage_availability_zone }}#{{ end }}storage_availability_zone = {{ .default.cinder.storage_availability_zone | default "nova" }}

# Default availability zone for new volumes. If not set, the
# storage_availability_zone option value is used as the default for
# new volumes. (string value)
# from .default.cinder.default_availability_zone
{{ if not .default.cinder.default_availability_zone }}#{{ end }}default_availability_zone = {{ .default.cinder.default_availability_zone | default "<None>" }}

# If the requested Cinder availability zone is unavailable, fall back
# to the value of default_availability_zone, then
# storage_availability_zone, instead of failing. (boolean value)
# from .default.cinder.allow_availability_zone_fallback
{{ if not .default.cinder.allow_availability_zone_fallback }}#{{ end }}allow_availability_zone_fallback = {{ .default.cinder.allow_availability_zone_fallback | default "false" }}

# Default volume type to use (string value)
# from .default.cinder.default_volume_type
{{ if not .default.cinder.default_volume_type }}#{{ end }}default_volume_type = {{ .default.cinder.default_volume_type | default "<None>" }}

# Default group type to use (string value)
# from .default.cinder.default_group_type
{{ if not .default.cinder.default_group_type }}#{{ end }}default_group_type = {{ .default.cinder.default_group_type | default "<None>" }}

# Time period for which to generate volume usages. The options are
# hour, day, month, or year. (string value)
# from .default.cinder.volume_usage_audit_period
{{ if not .default.cinder.volume_usage_audit_period }}#{{ end }}volume_usage_audit_period = {{ .default.cinder.volume_usage_audit_period | default "month" }}

# Path to the rootwrap configuration file to use for running commands
# as root (string value)
# from .default.cinder.rootwrap_config
{{ if not .default.cinder.rootwrap_config }}#{{ end }}rootwrap_config = {{ .default.cinder.rootwrap_config | default "/etc/cinder/rootwrap.conf" }}

# Enable monkey patching (boolean value)
# from .default.cinder.monkey_patch
{{ if not .default.cinder.monkey_patch }}#{{ end }}monkey_patch = {{ .default.cinder.monkey_patch | default "false" }}

# List of modules/decorators to monkey patch (list value)
# from .default.cinder.monkey_patch_modules
{{ if not .default.cinder.monkey_patch_modules }}#{{ end }}monkey_patch_modules = {{ .default.cinder.monkey_patch_modules | default "" }}

# Maximum time since last check-in for a service to be considered up
# (integer value)
# from .default.cinder.service_down_time
{{ if not .default.cinder.service_down_time }}#{{ end }}service_down_time = {{ .default.cinder.service_down_time | default "60" }}

# The full class name of the volume API class to use (string value)
# from .default.cinder.volume_api_class
{{ if not .default.cinder.volume_api_class }}#{{ end }}volume_api_class = {{ .default.cinder.volume_api_class | default "cinder.volume.api.API" }}

# The full class name of the volume backup API class (string value)
# from .default.cinder.backup_api_class
{{ if not .default.cinder.backup_api_class }}#{{ end }}backup_api_class = {{ .default.cinder.backup_api_class | default "cinder.backup.api.API" }}

# The strategy to use for auth. Supports noauth or keystone. (string
# value)
# Allowed values: noauth, keystone
# from .default.cinder.auth_strategy
{{ if not .default.cinder.auth_strategy }}#{{ end }}auth_strategy = {{ .default.cinder.auth_strategy | default "keystone" }}

# A list of backend names to use. These backend names should be backed
# by a unique [CONFIG] group with its options (list value)
# from .default.cinder.enabled_backends
{{ if not .default.cinder.enabled_backends }}#{{ end }}enabled_backends = {{ .default.cinder.enabled_backends | default "<None>" }}

# Whether snapshots count against gigabyte quota (boolean value)
# from .default.cinder.no_snapshot_gb_quota
{{ if not .default.cinder.no_snapshot_gb_quota }}#{{ end }}no_snapshot_gb_quota = {{ .default.cinder.no_snapshot_gb_quota | default "false" }}

# The full class name of the volume transfer API class (string value)
# from .default.cinder.transfer_api_class
{{ if not .default.cinder.transfer_api_class }}#{{ end }}transfer_api_class = {{ .default.cinder.transfer_api_class | default "cinder.transfer.api.API" }}

# The full class name of the volume replication API class (string
# value)
# from .default.cinder.replication_api_class
{{ if not .default.cinder.replication_api_class }}#{{ end }}replication_api_class = {{ .default.cinder.replication_api_class | default "cinder.replication.api.API" }}

# The full class name of the consistencygroup API class (string value)
# from .default.cinder.consistencygroup_api_class
{{ if not .default.cinder.consistencygroup_api_class }}#{{ end }}consistencygroup_api_class = {{ .default.cinder.consistencygroup_api_class | default "cinder.consistencygroup.api.API" }}

# The full class name of the group API class (string value)
# from .default.cinder.group_api_class
{{ if not .default.cinder.group_api_class }}#{{ end }}group_api_class = {{ .default.cinder.group_api_class | default "cinder.group.api.API" }}

# OpenStack privileged account username. Used for requests to other
# services (such as Nova) that require an account with special rights.
# (string value)
# from .default.cinder.os_privileged_user_name
{{ if not .default.cinder.os_privileged_user_name }}#{{ end }}os_privileged_user_name = {{ .default.cinder.os_privileged_user_name | default "<None>" }}

# Password associated with the OpenStack privileged account. (string
# value)
# from .default.cinder.os_privileged_user_password
{{ if not .default.cinder.os_privileged_user_password }}#{{ end }}os_privileged_user_password = {{ .default.cinder.os_privileged_user_password | default "<None>" }}

# Tenant name associated with the OpenStack privileged account.
# (string value)
# from .default.cinder.os_privileged_user_tenant
{{ if not .default.cinder.os_privileged_user_tenant }}#{{ end }}os_privileged_user_tenant = {{ .default.cinder.os_privileged_user_tenant | default "<None>" }}

# Auth URL associated with the OpenStack privileged account. (string
# value)
# from .default.cinder.os_privileged_user_auth_url
{{ if not .default.cinder.os_privileged_user_auth_url }}#{{ end }}os_privileged_user_auth_url = {{ .default.cinder.os_privileged_user_auth_url | default "<None>" }}

# Multiplier used for weighing free capacity. Negative numbers mean to
# stack vs spread. (floating point value)
# from .default.cinder.capacity_weight_multiplier
{{ if not .default.cinder.capacity_weight_multiplier }}#{{ end }}capacity_weight_multiplier = {{ .default.cinder.capacity_weight_multiplier | default "1.0" }}

# Multiplier used for weighing allocated capacity. Positive numbers
# mean to stack vs spread. (floating point value)
# from .default.cinder.allocated_capacity_weight_multiplier
{{ if not .default.cinder.allocated_capacity_weight_multiplier }}#{{ end }}allocated_capacity_weight_multiplier = {{ .default.cinder.allocated_capacity_weight_multiplier | default "-1.0" }}

# Max size for body of a request (integer value)
# from .default.cinder.osapi_max_request_body_size
{{ if not .default.cinder.osapi_max_request_body_size }}#{{ end }}osapi_max_request_body_size = {{ .default.cinder.osapi_max_request_body_size | default "114688" }}

# The URL of the Swift endpoint (string value)
# from .default.cinder.backup_swift_url
{{ if not .default.cinder.backup_swift_url }}#{{ end }}backup_swift_url = {{ .default.cinder.backup_swift_url | default "<None>" }}

# The URL of the Keystone endpoint (string value)
# from .default.cinder.backup_swift_auth_url
{{ if not .default.cinder.backup_swift_auth_url }}#{{ end }}backup_swift_auth_url = {{ .default.cinder.backup_swift_auth_url | default "<None>" }}

# Info to match when looking for swift in the service catalog. Format
# is: separated values of the form:
# <service_type>:<service_name>:<endpoint_type> - Only used if
# backup_swift_url is unset (string value)
# from .default.cinder.swift_catalog_info
{{ if not .default.cinder.swift_catalog_info }}#{{ end }}swift_catalog_info = {{ .default.cinder.swift_catalog_info | default "object-store:swift:publicURL" }}

# Info to match when looking for keystone in the service catalog.
# Format is: separated values of the form:
# <service_type>:<service_name>:<endpoint_type> - Only used if
# backup_swift_auth_url is unset (string value)
# from .default.cinder.keystone_catalog_info
{{ if not .default.cinder.keystone_catalog_info }}#{{ end }}keystone_catalog_info = {{ .default.cinder.keystone_catalog_info | default "identity:Identity Service:publicURL" }}

# Swift authentication mechanism (string value)
# from .default.cinder.backup_swift_auth
{{ if not .default.cinder.backup_swift_auth }}#{{ end }}backup_swift_auth = {{ .default.cinder.backup_swift_auth | default "per_user" }}

# Swift authentication version. Specify "1" for auth 1.0, or "2" for
# auth 2.0 or "3" for auth 3.0 (string value)
# from .default.cinder.backup_swift_auth_version
{{ if not .default.cinder.backup_swift_auth_version }}#{{ end }}backup_swift_auth_version = {{ .default.cinder.backup_swift_auth_version | default "1" }}

# Swift tenant/account name. Required when connecting to an auth 2.0
# system (string value)
# from .default.cinder.backup_swift_tenant
{{ if not .default.cinder.backup_swift_tenant }}#{{ end }}backup_swift_tenant = {{ .default.cinder.backup_swift_tenant | default "<None>" }}

# Swift user domain name. Required when connecting to an auth 3.0
# system (string value)
# from .default.cinder.backup_swift_user_domain
{{ if not .default.cinder.backup_swift_user_domain }}#{{ end }}backup_swift_user_domain = {{ .default.cinder.backup_swift_user_domain | default "<None>" }}

# Swift project domain name. Required when connecting to an auth 3.0
# system (string value)
# from .default.cinder.backup_swift_project_domain
{{ if not .default.cinder.backup_swift_project_domain }}#{{ end }}backup_swift_project_domain = {{ .default.cinder.backup_swift_project_domain | default "<None>" }}

# Swift project/account name. Required when connecting to an auth 3.0
# system (string value)
# from .default.cinder.backup_swift_project
{{ if not .default.cinder.backup_swift_project }}#{{ end }}backup_swift_project = {{ .default.cinder.backup_swift_project | default "<None>" }}

# Swift user name (string value)
# from .default.cinder.backup_swift_user
{{ if not .default.cinder.backup_swift_user }}#{{ end }}backup_swift_user = {{ .default.cinder.backup_swift_user | default "<None>" }}

# Swift key for authentication (string value)
# from .default.cinder.backup_swift_key
{{ if not .default.cinder.backup_swift_key }}#{{ end }}backup_swift_key = {{ .default.cinder.backup_swift_key | default "<None>" }}

# The default Swift container to use (string value)
# from .default.cinder.backup_swift_container
{{ if not .default.cinder.backup_swift_container }}#{{ end }}backup_swift_container = {{ .default.cinder.backup_swift_container | default "volumebackups" }}

# The size in bytes of Swift backup objects (integer value)
# from .default.cinder.backup_swift_object_size
{{ if not .default.cinder.backup_swift_object_size }}#{{ end }}backup_swift_object_size = {{ .default.cinder.backup_swift_object_size | default "52428800" }}

# The size in bytes that changes are tracked for incremental backups.
# backup_swift_object_size has to be multiple of
# backup_swift_block_size. (integer value)
# from .default.cinder.backup_swift_block_size
{{ if not .default.cinder.backup_swift_block_size }}#{{ end }}backup_swift_block_size = {{ .default.cinder.backup_swift_block_size | default "32768" }}

# The number of retries to make for Swift operations (integer value)
# from .default.cinder.backup_swift_retry_attempts
{{ if not .default.cinder.backup_swift_retry_attempts }}#{{ end }}backup_swift_retry_attempts = {{ .default.cinder.backup_swift_retry_attempts | default "3" }}

# The backoff time in seconds between Swift retries (integer value)
# from .default.cinder.backup_swift_retry_backoff
{{ if not .default.cinder.backup_swift_retry_backoff }}#{{ end }}backup_swift_retry_backoff = {{ .default.cinder.backup_swift_retry_backoff | default "2" }}

# Enable or Disable the timer to send the periodic progress
# notifications to Ceilometer when backing up the volume to the Swift
# backend storage. The default value is True to enable the timer.
# (boolean value)
# from .default.cinder.backup_swift_enable_progress_timer
{{ if not .default.cinder.backup_swift_enable_progress_timer }}#{{ end }}backup_swift_enable_progress_timer = {{ .default.cinder.backup_swift_enable_progress_timer | default "true" }}

# Location of the CA certificate file to use for swift client
# requests. (string value)
# from .default.cinder.backup_swift_ca_cert_file
{{ if not .default.cinder.backup_swift_ca_cert_file }}#{{ end }}backup_swift_ca_cert_file = {{ .default.cinder.backup_swift_ca_cert_file | default "<None>" }}

# Bypass verification of server certificate when making SSL connection
# to Swift. (boolean value)
# from .default.cinder.backup_swift_auth_insecure
{{ if not .default.cinder.backup_swift_auth_insecure }}#{{ end }}backup_swift_auth_insecure = {{ .default.cinder.backup_swift_auth_insecure | default "false" }}

# Interval, in seconds, between nodes reporting state to datastore
# (integer value)
# from .default.cinder.report_interval
{{ if not .default.cinder.report_interval }}#{{ end }}report_interval = {{ .default.cinder.report_interval | default "10" }}

# Interval, in seconds, between running periodic tasks (integer value)
# from .default.cinder.periodic_interval
{{ if not .default.cinder.periodic_interval }}#{{ end }}periodic_interval = {{ .default.cinder.periodic_interval | default "60" }}

# Range, in seconds, to randomly delay when starting the periodic task
# scheduler to reduce stampeding. (Disable by setting to 0) (integer
# value)
# from .default.cinder.periodic_fuzzy_delay
{{ if not .default.cinder.periodic_fuzzy_delay }}#{{ end }}periodic_fuzzy_delay = {{ .default.cinder.periodic_fuzzy_delay | default "60" }}

# IP address on which OpenStack Volume API listens (string value)
# from .default.cinder.osapi_volume_listen
{{ if not .default.cinder.osapi_volume_listen }}#{{ end }}osapi_volume_listen = {{ .default.cinder.osapi_volume_listen | default "0.0.0.0" }}

# Port on which OpenStack Volume API listens (port value)
# Minimum value: 0
# Maximum value: 65535
# from .default.cinder.osapi_volume_listen_port
{{ if not .default.cinder.osapi_volume_listen_port }}#{{ end }}osapi_volume_listen_port = {{ .default.cinder.osapi_volume_listen_port | default "8776" }}

# Number of workers for OpenStack Volume API service. The default is
# equal to the number of CPUs available. (integer value)
# from .default.cinder.osapi_volume_workers
{{ if not .default.cinder.osapi_volume_workers }}#{{ end }}osapi_volume_workers = {{ .default.cinder.osapi_volume_workers | default "<None>" }}

# Wraps the socket in a SSL context if True is set. A certificate file
# and key file must be specified. (boolean value)
# from .default.cinder.osapi_volume_use_ssl
{{ if not .default.cinder.osapi_volume_use_ssl }}#{{ end }}osapi_volume_use_ssl = {{ .default.cinder.osapi_volume_use_ssl | default "false" }}

# The full class name of the compute API class to use (string value)
# from .default.cinder.compute_api_class
{{ if not .default.cinder.compute_api_class }}#{{ end }}compute_api_class = {{ .default.cinder.compute_api_class | default "cinder.compute.nova.API" }}

# ID of the project which will be used as the Cinder internal tenant.
# (string value)
# from .default.cinder.cinder_internal_tenant_project_id
{{ if not .default.cinder.cinder_internal_tenant_project_id }}#{{ end }}cinder_internal_tenant_project_id = {{ .default.cinder.cinder_internal_tenant_project_id | default "<None>" }}

# ID of the user to be used in volume operations as the Cinder
# internal tenant. (string value)
# from .default.cinder.cinder_internal_tenant_user_id
{{ if not .default.cinder.cinder_internal_tenant_user_id }}#{{ end }}cinder_internal_tenant_user_id = {{ .default.cinder.cinder_internal_tenant_user_id | default "<None>" }}

# The scheduler host manager class to use (string value)
# from .default.cinder.scheduler_host_manager
{{ if not .default.cinder.scheduler_host_manager }}#{{ end }}scheduler_host_manager = {{ .default.cinder.scheduler_host_manager | default "cinder.scheduler.host_manager.HostManager" }}

# Maximum number of attempts to schedule a volume (integer value)
# from .default.cinder.scheduler_max_attempts
{{ if not .default.cinder.scheduler_max_attempts }}#{{ end }}scheduler_max_attempts = {{ .default.cinder.scheduler_max_attempts | default "3" }}

# The maximum size in bytes of the files used to hold backups. If the
# volume being backed up exceeds this size, then it will be backed up
# into multiple files.backup_file_size must be a multiple of
# backup_sha_block_size_bytes. (integer value)
# from .default.cinder.backup_file_size
{{ if not .default.cinder.backup_file_size }}#{{ end }}backup_file_size = {{ .default.cinder.backup_file_size | default "1999994880" }}

# The size in bytes that changes are tracked for incremental backups.
# backup_file_size has to be multiple of backup_sha_block_size_bytes.
# (integer value)
# from .default.cinder.backup_sha_block_size_bytes
{{ if not .default.cinder.backup_sha_block_size_bytes }}#{{ end }}backup_sha_block_size_bytes = {{ .default.cinder.backup_sha_block_size_bytes | default "32768" }}

# Enable or Disable the timer to send the periodic progress
# notifications to Ceilometer when backing up the volume to the
# backend storage. The default value is True to enable the timer.
# (boolean value)
# from .default.cinder.backup_enable_progress_timer
{{ if not .default.cinder.backup_enable_progress_timer }}#{{ end }}backup_enable_progress_timer = {{ .default.cinder.backup_enable_progress_timer | default "true" }}

# Path specifying where to store backups. (string value)
# from .default.cinder.backup_posix_path
{{ if not .default.cinder.backup_posix_path }}#{{ end }}backup_posix_path = {{ .default.cinder.backup_posix_path | default "$state_path/backup" }}

# Custom directory to use for backups. (string value)
# from .default.cinder.backup_container
{{ if not .default.cinder.backup_container }}#{{ end }}backup_container = {{ .default.cinder.backup_container | default "<None>" }}

# Driver to use for database access (string value)
# from .default.cinder.db_driver
{{ if not .default.cinder.db_driver }}#{{ end }}db_driver = {{ .default.cinder.db_driver | default "cinder.db" }}

# The number of characters in the salt. (integer value)
# from .default.cinder.volume_transfer_salt_length
{{ if not .default.cinder.volume_transfer_salt_length }}#{{ end }}volume_transfer_salt_length = {{ .default.cinder.volume_transfer_salt_length | default "8" }}

# The number of characters in the autogenerated auth key. (integer
# value)
# from .default.cinder.volume_transfer_key_length
{{ if not .default.cinder.volume_transfer_key_length }}#{{ end }}volume_transfer_key_length = {{ .default.cinder.volume_transfer_key_length | default "16" }}

# Services to be added to the available pool on create (boolean value)
# from .default.cinder.enable_new_services
{{ if not .default.cinder.enable_new_services }}#{{ end }}enable_new_services = {{ .default.cinder.enable_new_services | default "true" }}

# Template string to be used to generate volume names (string value)
# from .default.cinder.volume_name_template
{{ if not .default.cinder.volume_name_template }}#{{ end }}volume_name_template = {{ .default.cinder.volume_name_template | default "volume-%s" }}

# Template string to be used to generate snapshot names (string value)
# from .default.cinder.snapshot_name_template
{{ if not .default.cinder.snapshot_name_template }}#{{ end }}snapshot_name_template = {{ .default.cinder.snapshot_name_template | default "snapshot-%s" }}

# Template string to be used to generate backup names (string value)
# from .default.cinder.backup_name_template
{{ if not .default.cinder.backup_name_template }}#{{ end }}backup_name_template = {{ .default.cinder.backup_name_template | default "backup-%s" }}

# Multiplier used for weighing volume number. Negative numbers mean to
# spread vs stack. (floating point value)
# from .default.cinder.volume_number_multiplier
{{ if not .default.cinder.volume_number_multiplier }}#{{ end }}volume_number_multiplier = {{ .default.cinder.volume_number_multiplier | default "-1.0" }}

# Number of times to attempt to run flakey shell commands (integer
# value)
# from .default.cinder.num_shell_tries
{{ if not .default.cinder.num_shell_tries }}#{{ end }}num_shell_tries = {{ .default.cinder.num_shell_tries | default "3" }}

# The percentage of backend capacity is reserved (integer value)
# Minimum value: 0
# Maximum value: 100
# from .default.cinder.reserved_percentage
{{ if not .default.cinder.reserved_percentage }}#{{ end }}reserved_percentage = {{ .default.cinder.reserved_percentage | default "0" }}

# Prefix for iSCSI volumes (string value)
# from .default.cinder.iscsi_target_prefix
{{ if not .default.cinder.iscsi_target_prefix }}#{{ end }}iscsi_target_prefix = {{ .default.cinder.iscsi_target_prefix | default "iqn.2010-10.org.openstack:" }}

# The IP address that the iSCSI daemon is listening on (string value)
# from .default.cinder.iscsi_ip_address
{{ if not .default.cinder.iscsi_ip_address }}#{{ end }}iscsi_ip_address = {{ .default.cinder.iscsi_ip_address | default "$my_ip" }}

# The list of secondary IP addresses of the iSCSI daemon (list value)
# from .default.cinder.iscsi_secondary_ip_addresses
{{ if not .default.cinder.iscsi_secondary_ip_addresses }}#{{ end }}iscsi_secondary_ip_addresses = {{ .default.cinder.iscsi_secondary_ip_addresses | default "" }}

# The port that the iSCSI daemon is listening on (port value)
# Minimum value: 0
# Maximum value: 65535
# from .default.cinder.iscsi_port
{{ if not .default.cinder.iscsi_port }}#{{ end }}iscsi_port = {{ .default.cinder.iscsi_port | default "3260" }}

# The maximum number of times to rescan targets to find volume
# (integer value)
# from .default.cinder.num_volume_device_scan_tries
{{ if not .default.cinder.num_volume_device_scan_tries }}#{{ end }}num_volume_device_scan_tries = {{ .default.cinder.num_volume_device_scan_tries | default "3" }}

# The backend name for a given driver implementation (string value)
# from .default.cinder.volume_backend_name
{{ if not .default.cinder.volume_backend_name }}#{{ end }}volume_backend_name = {{ .default.cinder.volume_backend_name | default "<None>" }}

# Do we attach/detach volumes in cinder using multipath for volume to
# image and image to volume transfers? (boolean value)
# from .default.cinder.use_multipath_for_image_xfer
{{ if not .default.cinder.use_multipath_for_image_xfer }}#{{ end }}use_multipath_for_image_xfer = {{ .default.cinder.use_multipath_for_image_xfer | default "false" }}

# If this is set to True, attachment of volumes for image transfer
# will be aborted when multipathd is not running. Otherwise, it will
# fallback to single path. (boolean value)
# from .default.cinder.enforce_multipath_for_image_xfer
{{ if not .default.cinder.enforce_multipath_for_image_xfer }}#{{ end }}enforce_multipath_for_image_xfer = {{ .default.cinder.enforce_multipath_for_image_xfer | default "false" }}

# Method used to wipe old volumes (string value)
# Allowed values: none, zero, shred
# from .default.cinder.volume_clear
{{ if not .default.cinder.volume_clear }}#{{ end }}volume_clear = {{ .default.cinder.volume_clear | default "zero" }}

# Size in MiB to wipe at start of old volumes. 1024 MiBat max. 0 =>
# all (integer value)
# Maximum value: 1024
# from .default.cinder.volume_clear_size
{{ if not .default.cinder.volume_clear_size }}#{{ end }}volume_clear_size = {{ .default.cinder.volume_clear_size | default "0" }}

# The flag to pass to ionice to alter the i/o priority of the process
# used to zero a volume after deletion, for example "-c3" for idle
# only priority. (string value)
# from .default.cinder.volume_clear_ionice
{{ if not .default.cinder.volume_clear_ionice }}#{{ end }}volume_clear_ionice = {{ .default.cinder.volume_clear_ionice | default "<None>" }}

# iSCSI target user-land tool to use. tgtadm is default, use lioadm
# for LIO iSCSI support, scstadmin for SCST target support, ietadm for
# iSCSI Enterprise Target, iscsictl for Chelsio iSCSI Target or fake
# for testing. (string value)
# Allowed values: tgtadm, lioadm, scstadmin, iscsictl, ietadm, fake
# from .default.cinder.iscsi_helper
{{ if not .default.cinder.iscsi_helper }}#{{ end }}iscsi_helper = {{ .default.cinder.iscsi_helper | default "tgtadm" }}

# Volume configuration file storage directory (string value)
# from .default.cinder.volumes_dir
{{ if not .default.cinder.volumes_dir }}#{{ end }}volumes_dir = {{ .default.cinder.volumes_dir | default "$state_path/volumes" }}

# IET configuration file (string value)
# from .default.cinder.iet_conf
{{ if not .default.cinder.iet_conf }}#{{ end }}iet_conf = {{ .default.cinder.iet_conf | default "/etc/iet/ietd.conf" }}

# Chiscsi (CXT) global defaults configuration file (string value)
# from .default.cinder.chiscsi_conf
{{ if not .default.cinder.chiscsi_conf }}#{{ end }}chiscsi_conf = {{ .default.cinder.chiscsi_conf | default "/etc/chelsio-iscsi/chiscsi.conf" }}

# Sets the behavior of the iSCSI target to either perform blockio or
# fileio optionally, auto can be set and Cinder will autodetect type
# of backing device (string value)
# Allowed values: blockio, fileio, auto
# from .default.cinder.iscsi_iotype
{{ if not .default.cinder.iscsi_iotype }}#{{ end }}iscsi_iotype = {{ .default.cinder.iscsi_iotype | default "fileio" }}

# The default block size used when copying/clearing volumes (string
# value)
# from .default.cinder.volume_dd_blocksize
{{ if not .default.cinder.volume_dd_blocksize }}#{{ end }}volume_dd_blocksize = {{ .default.cinder.volume_dd_blocksize | default "1M" }}

# The blkio cgroup name to be used to limit bandwidth of volume copy
# (string value)
# from .default.cinder.volume_copy_blkio_cgroup_name
{{ if not .default.cinder.volume_copy_blkio_cgroup_name }}#{{ end }}volume_copy_blkio_cgroup_name = {{ .default.cinder.volume_copy_blkio_cgroup_name | default "cinder-volume-copy" }}

# The upper limit of bandwidth of volume copy. 0 => unlimited (integer
# value)
# from .default.cinder.volume_copy_bps_limit
{{ if not .default.cinder.volume_copy_bps_limit }}#{{ end }}volume_copy_bps_limit = {{ .default.cinder.volume_copy_bps_limit | default "0" }}

# Sets the behavior of the iSCSI target to either perform write-
# back(on) or write-through(off). This parameter is valid if
# iscsi_helper is set to tgtadm. (string value)
# Allowed values: on, off
# from .default.cinder.iscsi_write_cache
{{ if not .default.cinder.iscsi_write_cache }}#{{ end }}iscsi_write_cache = {{ .default.cinder.iscsi_write_cache | default "on" }}

# Sets the target-specific flags for the iSCSI target. Only used for
# tgtadm to specify backing device flags using bsoflags option. The
# specified string is passed as is to the underlying tool. (string
# value)
# from .default.cinder.iscsi_target_flags
{{ if not .default.cinder.iscsi_target_flags }}#{{ end }}iscsi_target_flags = {{ .default.cinder.iscsi_target_flags | default "" }}

# Determines the iSCSI protocol for new iSCSI volumes, created with
# tgtadm or lioadm target helpers. In order to enable RDMA, this
# parameter should be set with the value "iser". The supported iSCSI
# protocol values are "iscsi" and "iser". (string value)
# Allowed values: iscsi, iser
# from .default.cinder.iscsi_protocol
{{ if not .default.cinder.iscsi_protocol }}#{{ end }}iscsi_protocol = {{ .default.cinder.iscsi_protocol | default "iscsi" }}

# The path to the client certificate key for verification, if the
# driver supports it. (string value)
# from .default.cinder.driver_client_cert_key
{{ if not .default.cinder.driver_client_cert_key }}#{{ end }}driver_client_cert_key = {{ .default.cinder.driver_client_cert_key | default "<None>" }}

# The path to the client certificate for verification, if the driver
# supports it. (string value)
# from .default.cinder.driver_client_cert
{{ if not .default.cinder.driver_client_cert }}#{{ end }}driver_client_cert = {{ .default.cinder.driver_client_cert | default "<None>" }}

# Tell driver to use SSL for connection to backend storage if the
# driver supports it. (boolean value)
# from .default.cinder.driver_use_ssl
{{ if not .default.cinder.driver_use_ssl }}#{{ end }}driver_use_ssl = {{ .default.cinder.driver_use_ssl | default "false" }}

# Float representation of the over subscription ratio when thin
# provisioning is involved. Default ratio is 20.0, meaning provisioned
# capacity can be 20 times of the total physical capacity. If the
# ratio is 10.5, it means provisioned capacity can be 10.5 times of
# the total physical capacity. A ratio of 1.0 means provisioned
# capacity cannot exceed the total physical capacity. The ratio has to
# be a minimum of 1.0. (floating point value)
# from .default.cinder.max_over_subscription_ratio
{{ if not .default.cinder.max_over_subscription_ratio }}#{{ end }}max_over_subscription_ratio = {{ .default.cinder.max_over_subscription_ratio | default "20.0" }}

# Certain ISCSI targets have predefined target names, SCST target
# driver uses this name. (string value)
# from .default.cinder.scst_target_iqn_name
{{ if not .default.cinder.scst_target_iqn_name }}#{{ end }}scst_target_iqn_name = {{ .default.cinder.scst_target_iqn_name | default "<None>" }}

# SCST target implementation can choose from multiple SCST target
# drivers. (string value)
# from .default.cinder.scst_target_driver
{{ if not .default.cinder.scst_target_driver }}#{{ end }}scst_target_driver = {{ .default.cinder.scst_target_driver | default "iscsi" }}

# Option to enable/disable CHAP authentication for targets. (boolean
# value)
# Deprecated group/name - [DEFAULT]/eqlx_use_chap
# from .default.cinder.use_chap_auth
{{ if not .default.cinder.use_chap_auth }}#{{ end }}use_chap_auth = {{ .default.cinder.use_chap_auth | default "false" }}

# CHAP user name. (string value)
# Deprecated group/name - [DEFAULT]/eqlx_chap_login
# from .default.cinder.chap_username
{{ if not .default.cinder.chap_username }}#{{ end }}chap_username = {{ .default.cinder.chap_username | default "" }}

# Password for specified CHAP account name. (string value)
# Deprecated group/name - [DEFAULT]/eqlx_chap_password
# from .default.cinder.chap_password
{{ if not .default.cinder.chap_password }}#{{ end }}chap_password = {{ .default.cinder.chap_password | default "" }}

# Namespace for driver private data values to be saved in. (string
# value)
# from .default.cinder.driver_data_namespace
{{ if not .default.cinder.driver_data_namespace }}#{{ end }}driver_data_namespace = {{ .default.cinder.driver_data_namespace | default "<None>" }}

# String representation for an equation that will be used to filter
# hosts. Only used when the driver filter is set to be used by the
# Cinder scheduler. (string value)
# from .default.cinder.filter_function
{{ if not .default.cinder.filter_function }}#{{ end }}filter_function = {{ .default.cinder.filter_function | default "<None>" }}

# String representation for an equation that will be used to determine
# the goodness of a host. Only used when using the goodness weigher is
# set to be used by the Cinder scheduler. (string value)
# from .default.cinder.goodness_function
{{ if not .default.cinder.goodness_function }}#{{ end }}goodness_function = {{ .default.cinder.goodness_function | default "<None>" }}

# If set to True the http client will validate the SSL certificate of
# the backend endpoint. (boolean value)
# from .default.cinder.driver_ssl_cert_verify
{{ if not .default.cinder.driver_ssl_cert_verify }}#{{ end }}driver_ssl_cert_verify = {{ .default.cinder.driver_ssl_cert_verify | default "false" }}

# Can be used to specify a non default path to a CA_BUNDLE file or
# directory with certificates of trusted CAs, which will be used to
# validate the backend (string value)
# from .default.cinder.driver_ssl_cert_path
{{ if not .default.cinder.driver_ssl_cert_path }}#{{ end }}driver_ssl_cert_path = {{ .default.cinder.driver_ssl_cert_path | default "<None>" }}

# List of options that control which trace info is written to the
# DEBUG log level to assist developers. Valid values are method and
# api. (list value)
# from .default.cinder.trace_flags
{{ if not .default.cinder.trace_flags }}#{{ end }}trace_flags = {{ .default.cinder.trace_flags | default "<None>" }}

# Multi opt of dictionaries to represent a replication target device.
# This option may be specified multiple times in a single config
# section to specify multiple replication target devices.  Each entry
# takes the standard dict config form: replication_device =
# target_device_id:<required>,key1:value1,key2:value2... (dict value)
# from .default.cinder.replication_device (multiopt)
{{ if not .default.cinder.replication_device }}#replication_device = {{ .default.cinder.replication_device | default "<None>" }}{{ else }}{{ range .default.cinder.replication_device }}replication_device = {{ . }}
{{ end }}{{ end }}

# If set to True, upload-to-image in raw format will create a cloned
# volume and register its location to the image service, instead of
# uploading the volume content. The cinder backend and locations
# support must be enabled in the image service, and glance_api_version
# must be set to 2. (boolean value)
# from .default.cinder.image_upload_use_cinder_backend
{{ if not .default.cinder.image_upload_use_cinder_backend }}#{{ end }}image_upload_use_cinder_backend = {{ .default.cinder.image_upload_use_cinder_backend | default "false" }}

# If set to True, the image volume created by upload-to-image will be
# placed in the internal tenant. Otherwise, the image volume is
# created in the current context's tenant. (boolean value)
# from .default.cinder.image_upload_use_internal_tenant
{{ if not .default.cinder.image_upload_use_internal_tenant }}#{{ end }}image_upload_use_internal_tenant = {{ .default.cinder.image_upload_use_internal_tenant | default "false" }}

# Enable the image volume cache for this backend. (boolean value)
# from .default.cinder.image_volume_cache_enabled
{{ if not .default.cinder.image_volume_cache_enabled }}#{{ end }}image_volume_cache_enabled = {{ .default.cinder.image_volume_cache_enabled | default "false" }}

# Max size of the image volume cache for this backend in GB. 0 =>
# unlimited. (integer value)
# from .default.cinder.image_volume_cache_max_size_gb
{{ if not .default.cinder.image_volume_cache_max_size_gb }}#{{ end }}image_volume_cache_max_size_gb = {{ .default.cinder.image_volume_cache_max_size_gb | default "0" }}

# Max number of entries allowed in the image volume cache. 0 =>
# unlimited. (integer value)
# from .default.cinder.image_volume_cache_max_count
{{ if not .default.cinder.image_volume_cache_max_count }}#{{ end }}image_volume_cache_max_count = {{ .default.cinder.image_volume_cache_max_count | default "0" }}

# Report to clients of Cinder that the backend supports discard (aka.
# trim/unmap). This will not actually change the behavior of the
# backend or the client directly, it will only notify that it can be
# used. (boolean value)
# from .default.cinder.report_discard_supported
{{ if not .default.cinder.report_discard_supported }}#{{ end }}report_discard_supported = {{ .default.cinder.report_discard_supported | default "false" }}

# Protocol for transferring data between host and storage back-end.
# (string value)
# Allowed values: iscsi, fc
# from .default.cinder.storage_protocol
{{ if not .default.cinder.storage_protocol }}#{{ end }}storage_protocol = {{ .default.cinder.storage_protocol | default "iscsi" }}

# If this is set to True, the backup_use_temp_snapshot path will be
# used during the backup. Otherwise, it will use
# backup_use_temp_volume path. (boolean value)
# from .default.cinder.backup_use_temp_snapshot
{{ if not .default.cinder.backup_use_temp_snapshot }}#{{ end }}backup_use_temp_snapshot = {{ .default.cinder.backup_use_temp_snapshot | default "false" }}

# Set this to True when you want to allow an unsupported driver to
# start.  Drivers that haven't maintained a working CI system and
# testing are marked as unsupported until CI is working again.  This
# also marks a driver as deprecated and may be removed in the next
# release. (boolean value)
# from .default.cinder.enable_unsupported_driver
{{ if not .default.cinder.enable_unsupported_driver }}#{{ end }}enable_unsupported_driver = {{ .default.cinder.enable_unsupported_driver | default "false" }}

# The maximum number of times to rescan iSER targetto find volume
# (integer value)
# from .default.cinder.num_iser_scan_tries
{{ if not .default.cinder.num_iser_scan_tries }}#{{ end }}num_iser_scan_tries = {{ .default.cinder.num_iser_scan_tries | default "3" }}

# Prefix for iSER volumes (string value)
# from .default.cinder.iser_target_prefix
{{ if not .default.cinder.iser_target_prefix }}#{{ end }}iser_target_prefix = {{ .default.cinder.iser_target_prefix | default "iqn.2010-10.org.openstack:" }}

# The IP address that the iSER daemon is listening on (string value)
# from .default.cinder.iser_ip_address
{{ if not .default.cinder.iser_ip_address }}#{{ end }}iser_ip_address = {{ .default.cinder.iser_ip_address | default "$my_ip" }}

# The port that the iSER daemon is listening on (port value)
# Minimum value: 0
# Maximum value: 65535
# from .default.cinder.iser_port
{{ if not .default.cinder.iser_port }}#{{ end }}iser_port = {{ .default.cinder.iser_port | default "3260" }}

# The name of the iSER target user-land tool to use (string value)
# from .default.cinder.iser_helper
{{ if not .default.cinder.iser_helper }}#{{ end }}iser_helper = {{ .default.cinder.iser_helper | default "tgtadm" }}

# Public url to use for versions endpoint. The default is None, which
# will use the request's host_url attribute to populate the URL base.
# If Cinder is operating behind a proxy, you will want to change this
# to represent the proxy's URL. (string value)
# from .default.cinder.public_endpoint
{{ if not .default.cinder.public_endpoint }}#{{ end }}public_endpoint = {{ .default.cinder.public_endpoint | default "<None>" }}

# A list of url schemes that can be downloaded directly via the
# direct_url.  Currently supported schemes: [file]. (list value)
# from .default.cinder.allowed_direct_url_schemes
{{ if not .default.cinder.allowed_direct_url_schemes }}#{{ end }}allowed_direct_url_schemes = {{ .default.cinder.allowed_direct_url_schemes | default "" }}

# Info to match when looking for glance in the service catalog. Format
# is: separated values of the form:
# <service_type>:<service_name>:<endpoint_type> - Only used if
# glance_api_servers are not provided. (string value)
# from .default.cinder.glance_catalog_info
{{ if not .default.cinder.glance_catalog_info }}#{{ end }}glance_catalog_info = {{ .default.cinder.glance_catalog_info | default "image:glance:publicURL" }}

# Default core properties of image (list value)
# from .default.cinder.glance_core_properties
{{ if not .default.cinder.glance_core_properties }}#{{ end }}glance_core_properties = {{ .default.cinder.glance_core_properties | default "checksum,container_format,disk_format,image_name,image_id,min_disk,min_ram,name,size" }}

# The GCS bucket to use. (string value)
# from .default.cinder.backup_gcs_bucket
{{ if not .default.cinder.backup_gcs_bucket }}#{{ end }}backup_gcs_bucket = {{ .default.cinder.backup_gcs_bucket | default "<None>" }}

# The size in bytes of GCS backup objects. (integer value)
# from .default.cinder.backup_gcs_object_size
{{ if not .default.cinder.backup_gcs_object_size }}#{{ end }}backup_gcs_object_size = {{ .default.cinder.backup_gcs_object_size | default "52428800" }}

# The size in bytes that changes are tracked for incremental backups.
# backup_gcs_object_size has to be multiple of backup_gcs_block_size.
# (integer value)
# from .default.cinder.backup_gcs_block_size
{{ if not .default.cinder.backup_gcs_block_size }}#{{ end }}backup_gcs_block_size = {{ .default.cinder.backup_gcs_block_size | default "32768" }}

# GCS object will be downloaded in chunks of bytes. (integer value)
# from .default.cinder.backup_gcs_reader_chunk_size
{{ if not .default.cinder.backup_gcs_reader_chunk_size }}#{{ end }}backup_gcs_reader_chunk_size = {{ .default.cinder.backup_gcs_reader_chunk_size | default "2097152" }}

# GCS object will be uploaded in chunks of bytes. Pass in a value of
# -1 if the file is to be uploaded as a single chunk. (integer value)
# from .default.cinder.backup_gcs_writer_chunk_size
{{ if not .default.cinder.backup_gcs_writer_chunk_size }}#{{ end }}backup_gcs_writer_chunk_size = {{ .default.cinder.backup_gcs_writer_chunk_size | default "2097152" }}

# Number of times to retry. (integer value)
# from .default.cinder.backup_gcs_num_retries
{{ if not .default.cinder.backup_gcs_num_retries }}#{{ end }}backup_gcs_num_retries = {{ .default.cinder.backup_gcs_num_retries | default "3" }}

# List of GCS error codes. (list value)
# from .default.cinder.backup_gcs_retry_error_codes
{{ if not .default.cinder.backup_gcs_retry_error_codes }}#{{ end }}backup_gcs_retry_error_codes = {{ .default.cinder.backup_gcs_retry_error_codes | default "429" }}

# Location of GCS bucket. (string value)
# from .default.cinder.backup_gcs_bucket_location
{{ if not .default.cinder.backup_gcs_bucket_location }}#{{ end }}backup_gcs_bucket_location = {{ .default.cinder.backup_gcs_bucket_location | default "US" }}

# Storage class of GCS bucket. (string value)
# from .default.cinder.backup_gcs_storage_class
{{ if not .default.cinder.backup_gcs_storage_class }}#{{ end }}backup_gcs_storage_class = {{ .default.cinder.backup_gcs_storage_class | default "NEARLINE" }}

# Absolute path of GCS service account credential file. (string value)
# from .default.cinder.backup_gcs_credential_file
{{ if not .default.cinder.backup_gcs_credential_file }}#{{ end }}backup_gcs_credential_file = {{ .default.cinder.backup_gcs_credential_file | default "<None>" }}

# Owner project id for GCS bucket. (string value)
# from .default.cinder.backup_gcs_project_id
{{ if not .default.cinder.backup_gcs_project_id }}#{{ end }}backup_gcs_project_id = {{ .default.cinder.backup_gcs_project_id | default "<None>" }}

# Http user-agent string for gcs api. (string value)
# from .default.cinder.backup_gcs_user_agent
{{ if not .default.cinder.backup_gcs_user_agent }}#{{ end }}backup_gcs_user_agent = {{ .default.cinder.backup_gcs_user_agent | default "gcscinder" }}

# Enable or Disable the timer to send the periodic progress
# notifications to Ceilometer when backing up the volume to the GCS
# backend storage. The default value is True to enable the timer.
# (boolean value)
# from .default.cinder.backup_gcs_enable_progress_timer
{{ if not .default.cinder.backup_gcs_enable_progress_timer }}#{{ end }}backup_gcs_enable_progress_timer = {{ .default.cinder.backup_gcs_enable_progress_timer | default "true" }}

# URL for http proxy access. (uri value)
# from .default.cinder.backup_gcs_proxy_url
{{ if not .default.cinder.backup_gcs_proxy_url }}#{{ end }}backup_gcs_proxy_url = {{ .default.cinder.backup_gcs_proxy_url | default "<None>" }}

# Treat X-Forwarded-For as the canonical remote address. Only enable
# this if you have a sanitizing proxy. (boolean value)
# from .default.cinder.use_forwarded_for
{{ if not .default.cinder.use_forwarded_for }}#{{ end }}use_forwarded_for = {{ .default.cinder.use_forwarded_for | default "false" }}

# Backup services use same backend. (boolean value)
# from .default.cinder.backup_use_same_host
{{ if not .default.cinder.backup_use_same_host }}#{{ end }}backup_use_same_host = {{ .default.cinder.backup_use_same_host | default "false" }}

# Driver to use for backups. (string value)
# from .default.cinder.backup_driver
{{ if not .default.cinder.backup_driver }}#{{ end }}backup_driver = {{ .default.cinder.backup_driver | default "cinder.backup.drivers.swift" }}

# Offload pending backup delete during backup service startup. If
# false, the backup service will remain down until all pending backups
# are deleted. (boolean value)
# from .default.cinder.backup_service_inithost_offload
{{ if not .default.cinder.backup_service_inithost_offload }}#{{ end }}backup_service_inithost_offload = {{ .default.cinder.backup_service_inithost_offload | default "true" }}

# Number of volumes allowed per project (integer value)
# from .default.cinder.quota_volumes
{{ if not .default.cinder.quota_volumes }}#{{ end }}quota_volumes = {{ .default.cinder.quota_volumes | default "10" }}

# Number of volume snapshots allowed per project (integer value)
# from .default.cinder.quota_snapshots
{{ if not .default.cinder.quota_snapshots }}#{{ end }}quota_snapshots = {{ .default.cinder.quota_snapshots | default "10" }}

# Number of consistencygroups allowed per project (integer value)
# from .default.cinder.quota_consistencygroups
{{ if not .default.cinder.quota_consistencygroups }}#{{ end }}quota_consistencygroups = {{ .default.cinder.quota_consistencygroups | default "10" }}

# Number of groups allowed per project (integer value)
# from .default.cinder.quota_groups
{{ if not .default.cinder.quota_groups }}#{{ end }}quota_groups = {{ .default.cinder.quota_groups | default "10" }}

# Total amount of storage, in gigabytes, allowed for volumes and
# snapshots per project (integer value)
# from .default.cinder.quota_gigabytes
{{ if not .default.cinder.quota_gigabytes }}#{{ end }}quota_gigabytes = {{ .default.cinder.quota_gigabytes | default "1000" }}

# Number of volume backups allowed per project (integer value)
# from .default.cinder.quota_backups
{{ if not .default.cinder.quota_backups }}#{{ end }}quota_backups = {{ .default.cinder.quota_backups | default "10" }}

# Total amount of storage, in gigabytes, allowed for backups per
# project (integer value)
# from .default.cinder.quota_backup_gigabytes
{{ if not .default.cinder.quota_backup_gigabytes }}#{{ end }}quota_backup_gigabytes = {{ .default.cinder.quota_backup_gigabytes | default "1000" }}

# Number of seconds until a reservation expires (integer value)
# from .default.cinder.reservation_expire
{{ if not .default.cinder.reservation_expire }}#{{ end }}reservation_expire = {{ .default.cinder.reservation_expire | default "86400" }}

# Count of reservations until usage is refreshed (integer value)
# from .default.cinder.until_refresh
{{ if not .default.cinder.until_refresh }}#{{ end }}until_refresh = {{ .default.cinder.until_refresh | default "0" }}

# Number of seconds between subsequent usage refreshes (integer value)
# from .default.cinder.max_age
{{ if not .default.cinder.max_age }}#{{ end }}max_age = {{ .default.cinder.max_age | default "0" }}

# Default driver to use for quota checks (string value)
# from .default.cinder.quota_driver
{{ if not .default.cinder.quota_driver }}#{{ end }}quota_driver = {{ .default.cinder.quota_driver | default "cinder.quota.DbQuotaDriver" }}

# Enables or disables use of default quota class with default quota.
# (boolean value)
# from .default.cinder.use_default_quota_class
{{ if not .default.cinder.use_default_quota_class }}#{{ end }}use_default_quota_class = {{ .default.cinder.use_default_quota_class | default "true" }}

# Max size allowed per volume, in gigabytes (integer value)
# from .default.cinder.per_volume_size_limit
{{ if not .default.cinder.per_volume_size_limit }}#{{ end }}per_volume_size_limit = {{ .default.cinder.per_volume_size_limit | default "-1" }}

# Which filter class names to use for filtering hosts when not
# specified in the request. (list value)
# from .default.cinder.scheduler_default_filters
{{ if not .default.cinder.scheduler_default_filters }}#{{ end }}scheduler_default_filters = {{ .default.cinder.scheduler_default_filters | default "AvailabilityZoneFilter,CapacityFilter,CapabilitiesFilter" }}

# Which weigher class names to use for weighing hosts. (list value)
# from .default.cinder.scheduler_default_weighers
{{ if not .default.cinder.scheduler_default_weighers }}#{{ end }}scheduler_default_weighers = {{ .default.cinder.scheduler_default_weighers | default "CapacityWeigher" }}

# Which handler to use for selecting the host/pool after weighing
# (string value)
# from .default.cinder.scheduler_weight_handler
{{ if not .default.cinder.scheduler_weight_handler }}#{{ end }}scheduler_weight_handler = {{ .default.cinder.scheduler_weight_handler | default "cinder.scheduler.weights.OrderedHostWeightHandler" }}

# Default scheduler driver to use (string value)
# from .default.cinder.scheduler_driver
{{ if not .default.cinder.scheduler_driver }}#{{ end }}scheduler_driver = {{ .default.cinder.scheduler_driver | default "cinder.scheduler.filter_scheduler.FilterScheduler" }}

# Base dir containing mount point for NFS share. (string value)
# from .default.cinder.backup_mount_point_base
{{ if not .default.cinder.backup_mount_point_base }}#{{ end }}backup_mount_point_base = {{ .default.cinder.backup_mount_point_base | default "$state_path/backup_mount" }}

# NFS share in hostname:path, ipv4addr:path, or "[ipv6addr]:path"
# format. (string value)
# from .default.cinder.backup_share
{{ if not .default.cinder.backup_share }}#{{ end }}backup_share = {{ .default.cinder.backup_share | default "<None>" }}

# Mount options passed to the NFS client. See NFS man page for
# details. (string value)
# from .default.cinder.backup_mount_options
{{ if not .default.cinder.backup_mount_options }}#{{ end }}backup_mount_options = {{ .default.cinder.backup_mount_options | default "<None>" }}

# Absolute path to scheduler configuration JSON file. (string value)
# from .default.cinder.scheduler_json_config_location
{{ if not .default.cinder.scheduler_json_config_location }}#{{ end }}scheduler_json_config_location = {{ .default.cinder.scheduler_json_config_location | default "" }}

# message minimum life in seconds. (integer value)
# from .default.cinder.message_ttl
{{ if not .default.cinder.message_ttl }}#{{ end }}message_ttl = {{ .default.cinder.message_ttl | default "2592000" }}

# Directory used for temporary storage during image conversion (string
# value)
# from .default.cinder.image_conversion_dir
{{ if not .default.cinder.image_conversion_dir }}#{{ end }}image_conversion_dir = {{ .default.cinder.image_conversion_dir | default "$state_path/conversion" }}

# Match this value when searching for nova in the service catalog.
# Format is: separated values of the form:
# <service_type>:<service_name>:<endpoint_type> (string value)
# from .default.cinder.nova_catalog_info
{{ if not .default.cinder.nova_catalog_info }}#{{ end }}nova_catalog_info = {{ .default.cinder.nova_catalog_info | default "compute:Compute Service:publicURL" }}

# Same as nova_catalog_info, but for admin endpoint. (string value)
# from .default.cinder.nova_catalog_admin_info
{{ if not .default.cinder.nova_catalog_admin_info }}#{{ end }}nova_catalog_admin_info = {{ .default.cinder.nova_catalog_admin_info | default "compute:Compute Service:adminURL" }}

# Override service catalog lookup with template for nova endpoint e.g.
# http://localhost:8774/v2/%(project_id)s (string value)
# from .default.cinder.nova_endpoint_template
{{ if not .default.cinder.nova_endpoint_template }}#{{ end }}nova_endpoint_template = {{ .default.cinder.nova_endpoint_template | default "<None>" }}

# Same as nova_endpoint_template, but for admin endpoint. (string
# value)
# from .default.cinder.nova_endpoint_admin_template
{{ if not .default.cinder.nova_endpoint_admin_template }}#{{ end }}nova_endpoint_admin_template = {{ .default.cinder.nova_endpoint_admin_template | default "<None>" }}

# Region name of this node (string value)
# from .default.cinder.os_region_name
{{ if not .default.cinder.os_region_name }}#{{ end }}os_region_name = {{ .default.cinder.os_region_name | default "<None>" }}

# Location of ca certificates file to use for nova client requests.
# (string value)
# from .default.cinder.nova_ca_certificates_file
{{ if not .default.cinder.nova_ca_certificates_file }}#{{ end }}nova_ca_certificates_file = {{ .default.cinder.nova_ca_certificates_file | default "<None>" }}

# Allow to perform insecure SSL requests to nova (boolean value)
# from .default.cinder.nova_api_insecure
{{ if not .default.cinder.nova_api_insecure }}#{{ end }}nova_api_insecure = {{ .default.cinder.nova_api_insecure | default "false" }}

# Driver to use for volume creation (string value)
# from .default.cinder.volume_driver
{{ if not .default.cinder.volume_driver }}#{{ end }}volume_driver = {{ .default.cinder.volume_driver | default "cinder.volume.drivers.lvm.LVMVolumeDriver" }}

# Timeout for creating the volume to migrate to when performing volume
# migration (seconds) (integer value)
# from .default.cinder.migration_create_volume_timeout_secs
{{ if not .default.cinder.migration_create_volume_timeout_secs }}#{{ end }}migration_create_volume_timeout_secs = {{ .default.cinder.migration_create_volume_timeout_secs | default "300" }}

# Offload pending volume delete during volume service startup (boolean
# value)
# from .default.cinder.volume_service_inithost_offload
{{ if not .default.cinder.volume_service_inithost_offload }}#{{ end }}volume_service_inithost_offload = {{ .default.cinder.volume_service_inithost_offload | default "false" }}

# FC Zoning mode configured (string value)
# from .default.cinder.zoning_mode
{{ if not .default.cinder.zoning_mode }}#{{ end }}zoning_mode = {{ .default.cinder.zoning_mode | default "<None>" }}

# User defined capabilities, a JSON formatted string specifying
# key/value pairs. The key/value pairs can be used by the
# CapabilitiesFilter to select between backends when requests specify
# volume types. For example, specifying a service level or the
# geographical location of a backend, then creating a volume type to
# allow the user to select by these different properties. (string
# value)
# from .default.cinder.extra_capabilities
{{ if not .default.cinder.extra_capabilities }}#{{ end }}extra_capabilities = {{ .default.cinder.extra_capabilities | default "{}" }}

# Suppress requests library SSL certificate warnings. (boolean value)
# from .default.cinder.suppress_requests_ssl_warnings
{{ if not .default.cinder.suppress_requests_ssl_warnings }}#{{ end }}suppress_requests_ssl_warnings = {{ .default.cinder.suppress_requests_ssl_warnings | default "false" }}

# Enables the Force option on upload_to_image. This enables running
# upload_volume on in-use volumes for backends that support it.
# (boolean value)
# from .default.cinder.enable_force_upload
{{ if not .default.cinder.enable_force_upload }}#{{ end }}enable_force_upload = {{ .default.cinder.enable_force_upload | default "false" }}

# Create volume from snapshot at the host where snapshot resides
# (boolean value)
# from .default.cinder.snapshot_same_host
{{ if not .default.cinder.snapshot_same_host }}#{{ end }}snapshot_same_host = {{ .default.cinder.snapshot_same_host | default "true" }}

# Ensure that the new volumes are the same AZ as snapshot or source
# volume (boolean value)
# from .default.cinder.cloned_volume_same_az
{{ if not .default.cinder.cloned_volume_same_az }}#{{ end }}cloned_volume_same_az = {{ .default.cinder.cloned_volume_same_az | default "true" }}

# Cache volume availability zones in memory for the provided duration
# in seconds (integer value)
# from .default.cinder.az_cache_duration
{{ if not .default.cinder.az_cache_duration }}#{{ end }}az_cache_duration = {{ .default.cinder.az_cache_duration | default "3600" }}

#
# From oslo.config
#

# Path to a config file to use. Multiple config files can be
# specified, with values in later files taking precedence. Defaults to
# %(default)s. (unknown value)
# from .default.oslo.config.config_file
{{ if not .default.oslo.config.config_file }}#{{ end }}config_file = {{ .default.oslo.config.config_file | default "~/.project/project.conf,~/project.conf,/etc/project/project.conf,/etc/project.conf" }}

# Path to a config directory to pull *.conf files from. This file set
# is sorted, so as to provide a predictable parse order if individual
# options are over-ridden. The set is parsed after the file(s)
# specified via previous --config-file, arguments hence over-ridden
# options in the directory take precedence. (list value)
# from .default.oslo.config.config_dir
{{ if not .default.oslo.config.config_dir }}#{{ end }}config_dir = {{ .default.oslo.config.config_dir | default "<None>" }}

#
# From oslo.log
#

# If set to true, the logging level will be set to DEBUG instead of
# the default INFO level. (boolean value)
# Note: This option can be changed without restarting.
# from .default.oslo.log.debug
{{ if not .default.oslo.log.debug }}#{{ end }}debug = {{ .default.oslo.log.debug | default "false" }}

# DEPRECATED: If set to false, the logging level will be set to
# WARNING instead of the default INFO level. (boolean value)
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# from .default.oslo.log.verbose
{{ if not .default.oslo.log.verbose }}#{{ end }}verbose = {{ .default.oslo.log.verbose | default "true" }}

# The name of a logging configuration file. This file is appended to
# any existing logging configuration files. For details about logging
# configuration files, see the Python logging module documentation.
# Note that when logging configuration files are used then all logging
# configuration is set in the configuration file and other logging
# configuration options are ignored (for example,
# logging_context_format_string). (string value)
# Note: This option can be changed without restarting.
# Deprecated group/name - [DEFAULT]/log_config
# from .default.oslo.log.log_config_append
{{ if not .default.oslo.log.log_config_append }}#{{ end }}log_config_append = {{ .default.oslo.log.log_config_append | default "<None>" }}

# Defines the format string for %%(asctime)s in log records. Default:
# %(default)s . This option is ignored if log_config_append is set.
# (string value)
# from .default.oslo.log.log_date_format
{{ if not .default.oslo.log.log_date_format }}#{{ end }}log_date_format = {{ .default.oslo.log.log_date_format | default "%Y-%m-%d %H:%M:%S" }}

# (Optional) Name of log file to send logging output to. If no default
# is set, logging will go to stderr as defined by use_stderr. This
# option is ignored if log_config_append is set. (string value)
# Deprecated group/name - [DEFAULT]/logfile
# from .default.oslo.log.log_file
{{ if not .default.oslo.log.log_file }}#{{ end }}log_file = {{ .default.oslo.log.log_file | default "<None>" }}

# (Optional) The base directory used for relative log_file  paths.
# This option is ignored if log_config_append is set. (string value)
# Deprecated group/name - [DEFAULT]/logdir
# from .default.oslo.log.log_dir
{{ if not .default.oslo.log.log_dir }}#{{ end }}log_dir = {{ .default.oslo.log.log_dir | default "<None>" }}

# Uses logging handler designed to watch file system. When log file is
# moved or removed this handler will open a new log file with
# specified path instantaneously. It makes sense only if log_file
# option is specified and Linux platform is used. This option is
# ignored if log_config_append is set. (boolean value)
# from .default.oslo.log.watch_log_file
{{ if not .default.oslo.log.watch_log_file }}#{{ end }}watch_log_file = {{ .default.oslo.log.watch_log_file | default "false" }}

# Use syslog for logging. Existing syslog format is DEPRECATED and
# will be changed later to honor RFC5424. This option is ignored if
# log_config_append is set. (boolean value)
# from .default.oslo.log.use_syslog
{{ if not .default.oslo.log.use_syslog }}#{{ end }}use_syslog = {{ .default.oslo.log.use_syslog | default "false" }}

# Syslog facility to receive log lines. This option is ignored if
# log_config_append is set. (string value)
# from .default.oslo.log.syslog_log_facility
{{ if not .default.oslo.log.syslog_log_facility }}#{{ end }}syslog_log_facility = {{ .default.oslo.log.syslog_log_facility | default "LOG_USER" }}

# Log output to standard error. This option is ignored if
# log_config_append is set. (boolean value)
# from .default.oslo.log.use_stderr
{{ if not .default.oslo.log.use_stderr }}#{{ end }}use_stderr = {{ .default.oslo.log.use_stderr | default "true" }}

# Format string to use for log messages with context. (string value)
# from .default.oslo.log.logging_context_format_string
{{ if not .default.oslo.log.logging_context_format_string }}#{{ end }}logging_context_format_string = {{ .default.oslo.log.logging_context_format_string | default "%(asctime)s.%(msecs)03d %(process)d %(levelname)s %(name)s [%(request_id)s %(user_identity)s] %(instance)s%(message)s" }}

# Format string to use for log messages when context is undefined.
# (string value)
# from .default.oslo.log.logging_default_format_string
{{ if not .default.oslo.log.logging_default_format_string }}#{{ end }}logging_default_format_string = {{ .default.oslo.log.logging_default_format_string | default "%(asctime)s.%(msecs)03d %(process)d %(levelname)s %(name)s [-] %(instance)s%(message)s" }}

# Additional data to append to log message when logging level for the
# message is DEBUG. (string value)
# from .default.oslo.log.logging_debug_format_suffix
{{ if not .default.oslo.log.logging_debug_format_suffix }}#{{ end }}logging_debug_format_suffix = {{ .default.oslo.log.logging_debug_format_suffix | default "%(funcName)s %(pathname)s:%(lineno)d" }}

# Prefix each line of exception output with this format. (string
# value)
# from .default.oslo.log.logging_exception_prefix
{{ if not .default.oslo.log.logging_exception_prefix }}#{{ end }}logging_exception_prefix = {{ .default.oslo.log.logging_exception_prefix | default "%(asctime)s.%(msecs)03d %(process)d ERROR %(name)s %(instance)s" }}

# Defines the format string for %(user_identity)s that is used in
# logging_context_format_string. (string value)
# from .default.oslo.log.logging_user_identity_format
{{ if not .default.oslo.log.logging_user_identity_format }}#{{ end }}logging_user_identity_format = {{ .default.oslo.log.logging_user_identity_format | default "%(user)s %(tenant)s %(domain)s %(user_domain)s %(project_domain)s" }}

# List of package logging levels in logger=LEVEL pairs. This option is
# ignored if log_config_append is set. (list value)
# from .default.oslo.log.default_log_levels
{{ if not .default.oslo.log.default_log_levels }}#{{ end }}default_log_levels = {{ .default.oslo.log.default_log_levels | default "amqp=WARN,amqplib=WARN,boto=WARN,qpid=WARN,sqlalchemy=WARN,suds=INFO,oslo.messaging=INFO,iso8601=WARN,requests.packages.urllib3.connectionpool=WARN,urllib3.connectionpool=WARN,websocket=WARN,requests.packages.urllib3.util.retry=WARN,urllib3.util.retry=WARN,keystonemiddleware=WARN,routes.middleware=WARN,stevedore=WARN,taskflow=WARN,keystoneauth=WARN,oslo.cache=INFO,dogpile.core.dogpile=INFO" }}

# Enables or disables publication of error events. (boolean value)
# from .default.oslo.log.publish_errors
{{ if not .default.oslo.log.publish_errors }}#{{ end }}publish_errors = {{ .default.oslo.log.publish_errors | default "false" }}

# The format for an instance that is passed with the log message.
# (string value)
# from .default.oslo.log.instance_format
{{ if not .default.oslo.log.instance_format }}#{{ end }}instance_format = {{ .default.oslo.log.instance_format | default "\"[instance: %(uuid)s] \"" }}

# The format for an instance UUID that is passed with the log message.
# (string value)
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

# The pool size limit for connections expiration policy (integer
# value)
# from .default.oslo.messaging.conn_pool_min_size
{{ if not .default.oslo.messaging.conn_pool_min_size }}#{{ end }}conn_pool_min_size = {{ .default.oslo.messaging.conn_pool_min_size | default "2" }}

# The time-to-live in sec of idle connections in the pool (integer
# value)
# from .default.oslo.messaging.conn_pool_ttl
{{ if not .default.oslo.messaging.conn_pool_ttl }}#{{ end }}conn_pool_ttl = {{ .default.oslo.messaging.conn_pool_ttl | default "1200" }}

# ZeroMQ bind address. Should be a wildcard (*), an ethernet
# interface, or IP. The "host" option should point or resolve to this
# address. (string value)
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

# Maximum number of ingress messages to locally buffer per topic.
# Default is unlimited. (integer value)
# Deprecated group/name - [DEFAULT]/rpc_zmq_topic_backlog
# from .default.oslo.messaging.rpc_zmq_topic_backlog
{{ if not .default.oslo.messaging.rpc_zmq_topic_backlog }}#{{ end }}rpc_zmq_topic_backlog = {{ .default.oslo.messaging.rpc_zmq_topic_backlog | default "<None>" }}

# Directory for holding IPC sockets. (string value)
# Deprecated group/name - [DEFAULT]/rpc_zmq_ipc_dir
# from .default.oslo.messaging.rpc_zmq_ipc_dir
{{ if not .default.oslo.messaging.rpc_zmq_ipc_dir }}#{{ end }}rpc_zmq_ipc_dir = {{ .default.oslo.messaging.rpc_zmq_ipc_dir | default "/var/run/openstack" }}

# Name of this node. Must be a valid hostname, FQDN, or IP address.
# Must match "host" option, if running Nova. (string value)
# Deprecated group/name - [DEFAULT]/rpc_zmq_host
# from .default.oslo.messaging.rpc_zmq_host
{{ if not .default.oslo.messaging.rpc_zmq_host }}#{{ end }}rpc_zmq_host = {{ .default.oslo.messaging.rpc_zmq_host | default "localhost" }}

# Seconds to wait before a cast expires (TTL). The default value of -1
# specifies an infinite linger period. The value of 0 specifies no
# linger period. Pending messages shall be discarded immediately when
# the socket is closed. Only supported by impl_zmq. (integer value)
# Deprecated group/name - [DEFAULT]/rpc_cast_timeout
# from .default.oslo.messaging.rpc_cast_timeout
{{ if not .default.oslo.messaging.rpc_cast_timeout }}#{{ end }}rpc_cast_timeout = {{ .default.oslo.messaging.rpc_cast_timeout | default "-1" }}

# The default number of seconds that poll should wait. Poll raises
# timeout exception when timeout expired. (integer value)
# Deprecated group/name - [DEFAULT]/rpc_poll_timeout
# from .default.oslo.messaging.rpc_poll_timeout
{{ if not .default.oslo.messaging.rpc_poll_timeout }}#{{ end }}rpc_poll_timeout = {{ .default.oslo.messaging.rpc_poll_timeout | default "1" }}

# Expiration timeout in seconds of a name service record about
# existing target ( < 0 means no timeout). (integer value)
# Deprecated group/name - [DEFAULT]/zmq_target_expire
# from .default.oslo.messaging.zmq_target_expire
{{ if not .default.oslo.messaging.zmq_target_expire }}#{{ end }}zmq_target_expire = {{ .default.oslo.messaging.zmq_target_expire | default "300" }}

# Update period in seconds of a name service record about existing
# target. (integer value)
# Deprecated group/name - [DEFAULT]/zmq_target_update
# from .default.oslo.messaging.zmq_target_update
{{ if not .default.oslo.messaging.zmq_target_update }}#{{ end }}zmq_target_update = {{ .default.oslo.messaging.zmq_target_update | default "180" }}

# Use PUB/SUB pattern for fanout methods. PUB/SUB always uses proxy.
# (boolean value)
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

# Number of retries to find free port number before fail with
# ZMQBindError. (integer value)
# Deprecated group/name - [DEFAULT]/rpc_zmq_bind_port_retries
# from .default.oslo.messaging.rpc_zmq_bind_port_retries
{{ if not .default.oslo.messaging.rpc_zmq_bind_port_retries }}#{{ end }}rpc_zmq_bind_port_retries = {{ .default.oslo.messaging.rpc_zmq_bind_port_retries | default "100" }}

# Default serialization mechanism for serializing/deserializing
# outgoing/incoming messages (string value)
# Allowed values: json, msgpack
# Deprecated group/name - [DEFAULT]/rpc_zmq_serialization
# from .default.oslo.messaging.rpc_zmq_serialization
{{ if not .default.oslo.messaging.rpc_zmq_serialization }}#{{ end }}rpc_zmq_serialization = {{ .default.oslo.messaging.rpc_zmq_serialization | default "json" }}

# This option configures round-robin mode in zmq socket. True means
# not keeping a queue when server side disconnects. False means to
# keep queue and messages even if server is disconnected, when the
# server appears we send all accumulated messages to it. (boolean
# value)
# from .default.oslo.messaging.zmq_immediate
{{ if not .default.oslo.messaging.zmq_immediate }}#{{ end }}zmq_immediate = {{ .default.oslo.messaging.zmq_immediate | default "false" }}

# Size of executor thread pool. (integer value)
# Deprecated group/name - [DEFAULT]/rpc_thread_pool_size
# from .default.oslo.messaging.executor_thread_pool_size
{{ if not .default.oslo.messaging.executor_thread_pool_size }}#{{ end }}executor_thread_pool_size = {{ .default.oslo.messaging.executor_thread_pool_size | default "64" }}

# Seconds to wait for a response from a call. (integer value)
# from .default.oslo.messaging.rpc_response_timeout
{{ if not .default.oslo.messaging.rpc_response_timeout }}#{{ end }}rpc_response_timeout = {{ .default.oslo.messaging.rpc_response_timeout | default "60" }}

# A URL representing the messaging driver to use and its full
# configuration. (string value)
# from .default.oslo.messaging.transport_url
{{ if not .default.oslo.messaging.transport_url }}#{{ end }}transport_url = {{ .default.oslo.messaging.transport_url | default "<None>" }}

# DEPRECATED: The messaging driver to use, defaults to rabbit. Other
# drivers include amqp and zmq. (string value)
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# Reason: Replaced by [DEFAULT]/transport_url
# from .default.oslo.messaging.rpc_backend
{{ if not .default.oslo.messaging.rpc_backend }}#{{ end }}rpc_backend = {{ .default.oslo.messaging.rpc_backend | default "rabbit" }}

# The default exchange under which topics are scoped. May be
# overridden by an exchange name specified in the transport_url
# option. (string value)
# from .default.oslo.messaging.control_exchange
{{ if not .default.oslo.messaging.control_exchange }}#{{ end }}control_exchange = {{ .default.oslo.messaging.control_exchange | default "openstack" }}

#
# From oslo.service.periodic_task
#

# Some periodic tasks can be run in a separate process. Should we run
# them here? (boolean value)
# from .default.oslo.service.periodic_task.run_external_periodic_tasks
{{ if not .default.oslo.service.periodic_task.run_external_periodic_tasks }}#{{ end }}run_external_periodic_tasks = {{ .default.oslo.service.periodic_task.run_external_periodic_tasks | default "true" }}

#
# From oslo.service.service
#

# Enable eventlet backdoor.  Acceptable values are 0, <port>, and
# <start>:<end>, where 0 results in listening on a random tcp port
# number; <port> results in listening on the specified port number
# (and not enabling backdoor if that port is in use); and
# <start>:<end> results in listening on the smallest unused port
# number within the specified range of port numbers.  The chosen port
# is displayed in the service's log file. (string value)
# from .default.oslo.service.service.backdoor_port
{{ if not .default.oslo.service.service.backdoor_port }}#{{ end }}backdoor_port = {{ .default.oslo.service.service.backdoor_port | default "<None>" }}

# Enable eventlet backdoor, using the provided path as a unix socket
# that can receive connections. This option is mutually exclusive with
# 'backdoor_port' in that only one should be provided. If both are
# provided then the existence of this option overrides the usage of
# that option. (string value)
# from .default.oslo.service.service.backdoor_socket
{{ if not .default.oslo.service.service.backdoor_socket }}#{{ end }}backdoor_socket = {{ .default.oslo.service.service.backdoor_socket | default "<None>" }}

# Enables or disables logging values of all registered options when
# starting a service (at DEBUG level). (boolean value)
# from .default.oslo.service.service.log_options
{{ if not .default.oslo.service.service.log_options }}#{{ end }}log_options = {{ .default.oslo.service.service.log_options | default "true" }}

# Specify a timeout after which a gracefully shutdown server will
# exit. Zero value means endless wait. (integer value)
# from .default.oslo.service.service.graceful_shutdown_timeout
{{ if not .default.oslo.service.service.graceful_shutdown_timeout }}#{{ end }}graceful_shutdown_timeout = {{ .default.oslo.service.service.graceful_shutdown_timeout | default "60" }}

#
# From oslo.service.wsgi
#

# File name for the paste.deploy config for api service (string value)
# from .default.oslo.service.wsgi.api_paste_config
{{ if not .default.oslo.service.wsgi.api_paste_config }}#{{ end }}api_paste_config = {{ .default.oslo.service.wsgi.api_paste_config | default "api-paste.ini" }}

# A python format string that is used as the template to generate log
# lines. The following values can beformatted into it: client_ip,
# date_time, request_line, status_code, body_length, wall_seconds.
# (string value)
# from .default.oslo.service.wsgi.wsgi_log_format
{{ if not .default.oslo.service.wsgi.wsgi_log_format }}#{{ end }}wsgi_log_format = {{ .default.oslo.service.wsgi.wsgi_log_format | default "%(client_ip)s \"%(request_line)s\" status: %(status_code)s  len: %(body_length)s time: %(wall_seconds).7f" }}

# Sets the value of TCP_KEEPIDLE in seconds for each server socket.
# Not supported on OS X. (integer value)
# from .default.oslo.service.wsgi.tcp_keepidle
{{ if not .default.oslo.service.wsgi.tcp_keepidle }}#{{ end }}tcp_keepidle = {{ .default.oslo.service.wsgi.tcp_keepidle | default "600" }}

# Size of the pool of greenthreads used by wsgi (integer value)
# from .default.oslo.service.wsgi.wsgi_default_pool_size
{{ if not .default.oslo.service.wsgi.wsgi_default_pool_size }}#{{ end }}wsgi_default_pool_size = {{ .default.oslo.service.wsgi.wsgi_default_pool_size | default "100" }}

# Maximum line size of message headers to be accepted. max_header_line
# may need to be increased when using large tokens (typically those
# generated when keystone is configured to use PKI tokens with big
# service catalogs). (integer value)
# from .default.oslo.service.wsgi.max_header_line
{{ if not .default.oslo.service.wsgi.max_header_line }}#{{ end }}max_header_line = {{ .default.oslo.service.wsgi.max_header_line | default "16384" }}

# If False, closes the client socket connection explicitly. (boolean
# value)
# from .default.oslo.service.wsgi.wsgi_keep_alive
{{ if not .default.oslo.service.wsgi.wsgi_keep_alive }}#{{ end }}wsgi_keep_alive = {{ .default.oslo.service.wsgi.wsgi_keep_alive | default "true" }}

# Timeout for client connections' socket operations. If an incoming
# connection is idle for this number of seconds it will be closed. A
# value of '0' means wait forever. (integer value)
# from .default.oslo.service.wsgi.client_socket_timeout
{{ if not .default.oslo.service.wsgi.client_socket_timeout }}#{{ end }}client_socket_timeout = {{ .default.oslo.service.wsgi.client_socket_timeout | default "900" }}


[BRCD_FABRIC_EXAMPLE]

#
# From cinder
#

# South bound connector for the fabric. (string value)
# Allowed values: SSH, HTTP, HTTPS
# from .brcd_fabric_example.cinder.fc_southbound_protocol
{{ if not .brcd_fabric_example.cinder.fc_southbound_protocol }}#{{ end }}fc_southbound_protocol = {{ .brcd_fabric_example.cinder.fc_southbound_protocol | default "HTTP" }}

# Management IP of fabric. (string value)
# from .brcd_fabric_example.cinder.fc_fabric_address
{{ if not .brcd_fabric_example.cinder.fc_fabric_address }}#{{ end }}fc_fabric_address = {{ .brcd_fabric_example.cinder.fc_fabric_address | default "" }}

# Fabric user ID. (string value)
# from .brcd_fabric_example.cinder.fc_fabric_user
{{ if not .brcd_fabric_example.cinder.fc_fabric_user }}#{{ end }}fc_fabric_user = {{ .brcd_fabric_example.cinder.fc_fabric_user | default "" }}

# Password for user. (string value)
# from .brcd_fabric_example.cinder.fc_fabric_password
{{ if not .brcd_fabric_example.cinder.fc_fabric_password }}#{{ end }}fc_fabric_password = {{ .brcd_fabric_example.cinder.fc_fabric_password | default "" }}

# Connecting port (port value)
# Minimum value: 0
# Maximum value: 65535
# from .brcd_fabric_example.cinder.fc_fabric_port
{{ if not .brcd_fabric_example.cinder.fc_fabric_port }}#{{ end }}fc_fabric_port = {{ .brcd_fabric_example.cinder.fc_fabric_port | default "22" }}

# Local SSH certificate Path. (string value)
# from .brcd_fabric_example.cinder.fc_fabric_ssh_cert_path
{{ if not .brcd_fabric_example.cinder.fc_fabric_ssh_cert_path }}#{{ end }}fc_fabric_ssh_cert_path = {{ .brcd_fabric_example.cinder.fc_fabric_ssh_cert_path | default "" }}

# Overridden zoning policy. (string value)
# from .brcd_fabric_example.cinder.zoning_policy
{{ if not .brcd_fabric_example.cinder.zoning_policy }}#{{ end }}zoning_policy = {{ .brcd_fabric_example.cinder.zoning_policy | default "initiator-target" }}

# Overridden zoning activation state. (boolean value)
# from .brcd_fabric_example.cinder.zone_activate
{{ if not .brcd_fabric_example.cinder.zone_activate }}#{{ end }}zone_activate = {{ .brcd_fabric_example.cinder.zone_activate | default "true" }}

# Overridden zone name prefix. (string value)
# from .brcd_fabric_example.cinder.zone_name_prefix
{{ if not .brcd_fabric_example.cinder.zone_name_prefix }}#{{ end }}zone_name_prefix = {{ .brcd_fabric_example.cinder.zone_name_prefix | default "openstack" }}

# Virtual Fabric ID. (string value)
# from .brcd_fabric_example.cinder.fc_virtual_fabric_id
{{ if not .brcd_fabric_example.cinder.fc_virtual_fabric_id }}#{{ end }}fc_virtual_fabric_id = {{ .brcd_fabric_example.cinder.fc_virtual_fabric_id | default "<None>" }}

# DEPRECATED: Principal switch WWN of the fabric. This option is not
# used anymore. (string value)
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# from .brcd_fabric_example.cinder.principal_switch_wwn
{{ if not .brcd_fabric_example.cinder.principal_switch_wwn }}#{{ end }}principal_switch_wwn = {{ .brcd_fabric_example.cinder.principal_switch_wwn | default "<None>" }}


[CISCO_FABRIC_EXAMPLE]

#
# From cinder
#

# Management IP of fabric (string value)
# from .cisco_fabric_example.cinder.cisco_fc_fabric_address
{{ if not .cisco_fabric_example.cinder.cisco_fc_fabric_address }}#{{ end }}cisco_fc_fabric_address = {{ .cisco_fabric_example.cinder.cisco_fc_fabric_address | default "" }}

# Fabric user ID (string value)
# from .cisco_fabric_example.cinder.cisco_fc_fabric_user
{{ if not .cisco_fabric_example.cinder.cisco_fc_fabric_user }}#{{ end }}cisco_fc_fabric_user = {{ .cisco_fabric_example.cinder.cisco_fc_fabric_user | default "" }}

# Password for user (string value)
# from .cisco_fabric_example.cinder.cisco_fc_fabric_password
{{ if not .cisco_fabric_example.cinder.cisco_fc_fabric_password }}#{{ end }}cisco_fc_fabric_password = {{ .cisco_fabric_example.cinder.cisco_fc_fabric_password | default "" }}

# Connecting port (port value)
# Minimum value: 0
# Maximum value: 65535
# from .cisco_fabric_example.cinder.cisco_fc_fabric_port
{{ if not .cisco_fabric_example.cinder.cisco_fc_fabric_port }}#{{ end }}cisco_fc_fabric_port = {{ .cisco_fabric_example.cinder.cisco_fc_fabric_port | default "22" }}

# overridden zoning policy (string value)
# from .cisco_fabric_example.cinder.cisco_zoning_policy
{{ if not .cisco_fabric_example.cinder.cisco_zoning_policy }}#{{ end }}cisco_zoning_policy = {{ .cisco_fabric_example.cinder.cisco_zoning_policy | default "initiator-target" }}

# overridden zoning activation state (boolean value)
# from .cisco_fabric_example.cinder.cisco_zone_activate
{{ if not .cisco_fabric_example.cinder.cisco_zone_activate }}#{{ end }}cisco_zone_activate = {{ .cisco_fabric_example.cinder.cisco_zone_activate | default "true" }}

# overridden zone name prefix (string value)
# from .cisco_fabric_example.cinder.cisco_zone_name_prefix
{{ if not .cisco_fabric_example.cinder.cisco_zone_name_prefix }}#{{ end }}cisco_zone_name_prefix = {{ .cisco_fabric_example.cinder.cisco_zone_name_prefix | default "<None>" }}

# VSAN of the Fabric (string value)
# from .cisco_fabric_example.cinder.cisco_zoning_vsan
{{ if not .cisco_fabric_example.cinder.cisco_zoning_vsan }}#{{ end }}cisco_zoning_vsan = {{ .cisco_fabric_example.cinder.cisco_zoning_vsan | default "<None>" }}


[COORDINATION]

#
# From cinder
#

# The backend URL to use for distributed coordination. (string value)
# from .coordination.cinder.backend_url
{{ if not .coordination.cinder.backend_url }}#{{ end }}backend_url = {{ .coordination.cinder.backend_url | default "file://$state_path" }}

# Number of seconds between heartbeats for distributed coordination.
# (floating point value)
# from .coordination.cinder.heartbeat
{{ if not .coordination.cinder.heartbeat }}#{{ end }}heartbeat = {{ .coordination.cinder.heartbeat | default "1.0" }}

# Initial number of seconds to wait after failed reconnection.
# (floating point value)
# from .coordination.cinder.initial_reconnect_backoff
{{ if not .coordination.cinder.initial_reconnect_backoff }}#{{ end }}initial_reconnect_backoff = {{ .coordination.cinder.initial_reconnect_backoff | default "0.1" }}

# Maximum number of seconds between sequential reconnection retries.
# (floating point value)
# from .coordination.cinder.max_reconnect_backoff
{{ if not .coordination.cinder.max_reconnect_backoff }}#{{ end }}max_reconnect_backoff = {{ .coordination.cinder.max_reconnect_backoff | default "60.0" }}


[FC-ZONE-MANAGER]

#
# From cinder
#

# South bound connector for zoning operation (string value)
# from .fc_zone_manager.cinder.brcd_sb_connector
{{ if not .fc_zone_manager.cinder.brcd_sb_connector }}#{{ end }}brcd_sb_connector = {{ .fc_zone_manager.cinder.brcd_sb_connector | default "HTTP" }}

# FC Zone Driver responsible for zone management (string value)
# from .fc_zone_manager.cinder.zone_driver
{{ if not .fc_zone_manager.cinder.zone_driver }}#{{ end }}zone_driver = {{ .fc_zone_manager.cinder.zone_driver | default "cinder.zonemanager.drivers.brocade.brcd_fc_zone_driver.BrcdFCZoneDriver" }}

# Zoning policy configured by user; valid values include "initiator-
# target" or "initiator" (string value)
# from .fc_zone_manager.cinder.zoning_policy
{{ if not .fc_zone_manager.cinder.zoning_policy }}#{{ end }}zoning_policy = {{ .fc_zone_manager.cinder.zoning_policy | default "initiator-target" }}

# Comma separated list of Fibre Channel fabric names. This list of
# names is used to retrieve other SAN credentials for connecting to
# each SAN fabric (string value)
# from .fc_zone_manager.cinder.fc_fabric_names
{{ if not .fc_zone_manager.cinder.fc_fabric_names }}#{{ end }}fc_fabric_names = {{ .fc_zone_manager.cinder.fc_fabric_names | default "<None>" }}

# FC SAN Lookup Service (string value)
# from .fc_zone_manager.cinder.fc_san_lookup_service
{{ if not .fc_zone_manager.cinder.fc_san_lookup_service }}#{{ end }}fc_san_lookup_service = {{ .fc_zone_manager.cinder.fc_san_lookup_service | default "cinder.zonemanager.drivers.brocade.brcd_fc_san_lookup_service.BrcdFCSanLookupService" }}

# Set this to True when you want to allow an unsupported zone manager
# driver to start.  Drivers that haven't maintained a working CI
# system and testing are marked as unsupported until CI is working
# again.  This also marks a driver as deprecated and may be removed in
# the next release. (boolean value)
# from .fc_zone_manager.cinder.enable_unsupported_driver
{{ if not .fc_zone_manager.cinder.enable_unsupported_driver }}#{{ end }}enable_unsupported_driver = {{ .fc_zone_manager.cinder.enable_unsupported_driver | default "false" }}

# Southbound connector for zoning operation (string value)
# from .fc_zone_manager.cinder.cisco_sb_connector
{{ if not .fc_zone_manager.cinder.cisco_sb_connector }}#{{ end }}cisco_sb_connector = {{ .fc_zone_manager.cinder.cisco_sb_connector | default "cinder.zonemanager.drivers.cisco.cisco_fc_zone_client_cli.CiscoFCZoneClientCLI" }}


[KEY_MANAGER]

#
# From cinder
#

# Fixed key returned by key manager, specified in hex (string value)
# Deprecated group/name - [keymgr]/fixed_key
# from .key_manager.cinder.fixed_key
{{ if not .key_manager.cinder.fixed_key }}#{{ end }}fixed_key = {{ .key_manager.cinder.fixed_key | default "<None>" }}


[barbican]

#
# From castellan.config
#

# Use this endpoint to connect to Barbican, for example:
# "http://localhost:9311/" (string value)
# from .barbican.castellan.config.barbican_endpoint
{{ if not .barbican.castellan.config.barbican_endpoint }}#{{ end }}barbican_endpoint = {{ .barbican.castellan.config.barbican_endpoint | default "<None>" }}

# Version of the Barbican API, for example: "v1" (string value)
# from .barbican.castellan.config.barbican_api_version
{{ if not .barbican.castellan.config.barbican_api_version }}#{{ end }}barbican_api_version = {{ .barbican.castellan.config.barbican_api_version | default "<None>" }}

# Use this endpoint to connect to Keystone (string value)
# from .barbican.castellan.config.auth_endpoint
{{ if not .barbican.castellan.config.auth_endpoint }}#{{ end }}auth_endpoint = {{ .barbican.castellan.config.auth_endpoint | default "http://localhost:5000/v3" }}

# Number of seconds to wait before retrying poll for key creation
# completion (integer value)
# from .barbican.castellan.config.retry_delay
{{ if not .barbican.castellan.config.retry_delay }}#{{ end }}retry_delay = {{ .barbican.castellan.config.retry_delay | default "1" }}

# Number of times to retry poll for key creation completion (integer
# value)
# from .barbican.castellan.config.number_of_retries
{{ if not .barbican.castellan.config.number_of_retries }}#{{ end }}number_of_retries = {{ .barbican.castellan.config.number_of_retries | default "60" }}


[cors]

#
# From oslo.middleware
#

# Indicate whether this resource may be shared with the domain
# received in the requests "origin" header. Format:
# "<protocol>://<host>[:<port>]", no trailing slash. Example:
# https://horizon.example.com (list value)
# from .cors.oslo.middleware.allowed_origin
{{ if not .cors.oslo.middleware.allowed_origin }}#{{ end }}allowed_origin = {{ .cors.oslo.middleware.allowed_origin | default "<None>" }}

# Indicate that the actual request can include user credentials
# (boolean value)
# from .cors.oslo.middleware.allow_credentials
{{ if not .cors.oslo.middleware.allow_credentials }}#{{ end }}allow_credentials = {{ .cors.oslo.middleware.allow_credentials | default "true" }}

# Indicate which headers are safe to expose to the API. Defaults to
# HTTP Simple Headers. (list value)
# from .cors.oslo.middleware.expose_headers
{{ if not .cors.oslo.middleware.expose_headers }}#{{ end }}expose_headers = {{ .cors.oslo.middleware.expose_headers | default "X-Auth-Token,X-Subject-Token,X-Service-Token,X-OpenStack-Request-ID,OpenStack-API-Version" }}

# Maximum cache age of CORS preflight requests. (integer value)
# from .cors.oslo.middleware.max_age
{{ if not .cors.oslo.middleware.max_age }}#{{ end }}max_age = {{ .cors.oslo.middleware.max_age | default "3600" }}

# Indicate which methods can be used during the actual request. (list
# value)
# from .cors.oslo.middleware.allow_methods
{{ if not .cors.oslo.middleware.allow_methods }}#{{ end }}allow_methods = {{ .cors.oslo.middleware.allow_methods | default "GET,PUT,POST,DELETE,PATCH,HEAD" }}

# Indicate which header field names may be used during the actual
# request. (list value)
# from .cors.oslo.middleware.allow_headers
{{ if not .cors.oslo.middleware.allow_headers }}#{{ end }}allow_headers = {{ .cors.oslo.middleware.allow_headers | default "X-Auth-Token,X-Identity-Status,X-Roles,X-Service-Catalog,X-User-Id,X-Tenant-Id,X-OpenStack-Request-ID,X-Trace-Info,X-Trace-HMAC,OpenStack-API-Version" }}


[cors.subdomain]

#
# From oslo.middleware
#

# Indicate whether this resource may be shared with the domain
# received in the requests "origin" header. Format:
# "<protocol>://<host>[:<port>]", no trailing slash. Example:
# https://horizon.example.com (list value)
# from .cors.subdomain.oslo.middleware.allowed_origin
{{ if not .cors.subdomain.oslo.middleware.allowed_origin }}#{{ end }}allowed_origin = {{ .cors.subdomain.oslo.middleware.allowed_origin | default "<None>" }}

# Indicate that the actual request can include user credentials
# (boolean value)
# from .cors.subdomain.oslo.middleware.allow_credentials
{{ if not .cors.subdomain.oslo.middleware.allow_credentials }}#{{ end }}allow_credentials = {{ .cors.subdomain.oslo.middleware.allow_credentials | default "true" }}

# Indicate which headers are safe to expose to the API. Defaults to
# HTTP Simple Headers. (list value)
# from .cors.subdomain.oslo.middleware.expose_headers
{{ if not .cors.subdomain.oslo.middleware.expose_headers }}#{{ end }}expose_headers = {{ .cors.subdomain.oslo.middleware.expose_headers | default "X-Auth-Token,X-Subject-Token,X-Service-Token,X-OpenStack-Request-ID,OpenStack-API-Version" }}

# Maximum cache age of CORS preflight requests. (integer value)
# from .cors.subdomain.oslo.middleware.max_age
{{ if not .cors.subdomain.oslo.middleware.max_age }}#{{ end }}max_age = {{ .cors.subdomain.oslo.middleware.max_age | default "3600" }}

# Indicate which methods can be used during the actual request. (list
# value)
# from .cors.subdomain.oslo.middleware.allow_methods
{{ if not .cors.subdomain.oslo.middleware.allow_methods }}#{{ end }}allow_methods = {{ .cors.subdomain.oslo.middleware.allow_methods | default "GET,PUT,POST,DELETE,PATCH,HEAD" }}

# Indicate which header field names may be used during the actual
# request. (list value)
# from .cors.subdomain.oslo.middleware.allow_headers
{{ if not .cors.subdomain.oslo.middleware.allow_headers }}#{{ end }}allow_headers = {{ .cors.subdomain.oslo.middleware.allow_headers | default "X-Auth-Token,X-Identity-Status,X-Roles,X-Service-Catalog,X-User-Id,X-Tenant-Id,X-OpenStack-Request-ID,X-Trace-Info,X-Trace-HMAC,OpenStack-API-Version" }}


[database]

#
# From oslo.db
#

# DEPRECATED: The file name to use with SQLite. (string value)
# Deprecated group/name - [DEFAULT]/sqlite_db
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# Reason: Should use config option connection or slave_connection to
# connect the database.
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

# The SQLAlchemy connection string to use to connect to the database.
# (string value)
# Deprecated group/name - [DEFAULT]/sql_connection
# Deprecated group/name - [DATABASE]/sql_connection
# Deprecated group/name - [sql]/connection
# from .database.oslo.db.connection
{{ if not .database.oslo.db.connection }}#{{ end }}connection = {{ .database.oslo.db.connection | default "<None>" }}

# The SQLAlchemy connection string to use to connect to the slave
# database. (string value)
# from .database.oslo.db.slave_connection
{{ if not .database.oslo.db.slave_connection }}#{{ end }}slave_connection = {{ .database.oslo.db.slave_connection | default "<None>" }}

# The SQL mode to be used for MySQL sessions. This option, including
# the default, overrides any server-set SQL mode. To use whatever SQL
# mode is set by the server configuration, set this to no value.
# Example: mysql_sql_mode= (string value)
# from .database.oslo.db.mysql_sql_mode
{{ if not .database.oslo.db.mysql_sql_mode }}#{{ end }}mysql_sql_mode = {{ .database.oslo.db.mysql_sql_mode | default "TRADITIONAL" }}

# Timeout before idle SQL connections are reaped. (integer value)
# Deprecated group/name - [DEFAULT]/sql_idle_timeout
# Deprecated group/name - [DATABASE]/sql_idle_timeout
# Deprecated group/name - [sql]/idle_timeout
# from .database.oslo.db.idle_timeout
{{ if not .database.oslo.db.idle_timeout }}#{{ end }}idle_timeout = {{ .database.oslo.db.idle_timeout | default "3600" }}

# Minimum number of SQL connections to keep open in a pool. (integer
# value)
# Deprecated group/name - [DEFAULT]/sql_min_pool_size
# Deprecated group/name - [DATABASE]/sql_min_pool_size
# from .database.oslo.db.min_pool_size
{{ if not .database.oslo.db.min_pool_size }}#{{ end }}min_pool_size = {{ .database.oslo.db.min_pool_size | default "1" }}

# Maximum number of SQL connections to keep open in a pool. Setting a
# value of 0 indicates no limit. (integer value)
# Deprecated group/name - [DEFAULT]/sql_max_pool_size
# Deprecated group/name - [DATABASE]/sql_max_pool_size
# from .database.oslo.db.max_pool_size
{{ if not .database.oslo.db.max_pool_size }}#{{ end }}max_pool_size = {{ .database.oslo.db.max_pool_size | default "5" }}

# Maximum number of database connection retries during startup. Set to
# -1 to specify an infinite retry count. (integer value)
# Deprecated group/name - [DEFAULT]/sql_max_retries
# Deprecated group/name - [DATABASE]/sql_max_retries
# from .database.oslo.db.max_retries
{{ if not .database.oslo.db.max_retries }}#{{ end }}max_retries = {{ .database.oslo.db.max_retries | default "10" }}

# Interval between retries of opening a SQL connection. (integer
# value)
# Deprecated group/name - [DEFAULT]/sql_retry_interval
# Deprecated group/name - [DATABASE]/reconnect_interval
# from .database.oslo.db.retry_interval
{{ if not .database.oslo.db.retry_interval }}#{{ end }}retry_interval = {{ .database.oslo.db.retry_interval | default "10" }}

# If set, use this value for max_overflow with SQLAlchemy. (integer
# value)
# Deprecated group/name - [DEFAULT]/sql_max_overflow
# Deprecated group/name - [DATABASE]/sqlalchemy_max_overflow
# from .database.oslo.db.max_overflow
{{ if not .database.oslo.db.max_overflow }}#{{ end }}max_overflow = {{ .database.oslo.db.max_overflow | default "50" }}

# Verbosity of SQL debugging information: 0=None, 100=Everything.
# (integer value)
# Minimum value: 0
# Maximum value: 100
# Deprecated group/name - [DEFAULT]/sql_connection_debug
# from .database.oslo.db.connection_debug
{{ if not .database.oslo.db.connection_debug }}#{{ end }}connection_debug = {{ .database.oslo.db.connection_debug | default "0" }}

# Add Python stack traces to SQL as comment strings. (boolean value)
# Deprecated group/name - [DEFAULT]/sql_connection_trace
# from .database.oslo.db.connection_trace
{{ if not .database.oslo.db.connection_trace }}#{{ end }}connection_trace = {{ .database.oslo.db.connection_trace | default "false" }}

# If set, use this value for pool_timeout with SQLAlchemy. (integer
# value)
# Deprecated group/name - [DATABASE]/sqlalchemy_pool_timeout
# from .database.oslo.db.pool_timeout
{{ if not .database.oslo.db.pool_timeout }}#{{ end }}pool_timeout = {{ .database.oslo.db.pool_timeout | default "<None>" }}

# Enable the experimental use of database reconnect on connection
# lost. (boolean value)
# from .database.oslo.db.use_db_reconnect
{{ if not .database.oslo.db.use_db_reconnect }}#{{ end }}use_db_reconnect = {{ .database.oslo.db.use_db_reconnect | default "false" }}

# Seconds between retries of a database transaction. (integer value)
# from .database.oslo.db.db_retry_interval
{{ if not .database.oslo.db.db_retry_interval }}#{{ end }}db_retry_interval = {{ .database.oslo.db.db_retry_interval | default "1" }}

# If True, increases the interval between retries of a database
# operation up to db_max_retry_interval. (boolean value)
# from .database.oslo.db.db_inc_retry_interval
{{ if not .database.oslo.db.db_inc_retry_interval }}#{{ end }}db_inc_retry_interval = {{ .database.oslo.db.db_inc_retry_interval | default "true" }}

# If db_inc_retry_interval is set, the maximum seconds between retries
# of a database operation. (integer value)
# from .database.oslo.db.db_max_retry_interval
{{ if not .database.oslo.db.db_max_retry_interval }}#{{ end }}db_max_retry_interval = {{ .database.oslo.db.db_max_retry_interval | default "10" }}

# Maximum retries in case of connection error or deadlock error before
# error is raised. Set to -1 to specify an infinite retry count.
# (integer value)
# from .database.oslo.db.db_max_retries
{{ if not .database.oslo.db.db_max_retries }}#{{ end }}db_max_retries = {{ .database.oslo.db.db_max_retries | default "20" }}


[key_manager]

#
# From castellan.config
#

# The full class name of the key manager API class (string value)
# from .key_manager.castellan.config.api_class
{{ if not .key_manager.castellan.config.api_class }}#{{ end }}api_class = {{ .key_manager.castellan.config.api_class | default "castellan.key_manager.barbican_key_manager.BarbicanKeyManager" }}

# The type of authentication credential to create. Possible values are
# 'token', 'password', 'keystone_token', and 'keystone_password'.
# Required if no context is passed to the credential factory. (string
# value)
# from .key_manager.castellan.config.auth_type
{{ if not .key_manager.castellan.config.auth_type }}#{{ end }}auth_type = {{ .key_manager.castellan.config.auth_type | default "<None>" }}

# Token for authentication. Required for 'token' and 'keystone_token'
# auth_type if no context is passed to the credential factory. (string
# value)
# from .key_manager.castellan.config.token
{{ if not .key_manager.castellan.config.token }}#{{ end }}token = {{ .key_manager.castellan.config.token | default "<None>" }}

# Username for authentication. Required for 'password' auth_type.
# Optional for the 'keystone_password' auth_type. (string value)
# from .key_manager.castellan.config.username
{{ if not .key_manager.castellan.config.username }}#{{ end }}username = {{ .key_manager.castellan.config.username | default "<None>" }}

# Password for authentication. Required for 'password' and
# 'keystone_password' auth_type. (string value)
# from .key_manager.castellan.config.password
{{ if not .key_manager.castellan.config.password }}#{{ end }}password = {{ .key_manager.castellan.config.password | default "<None>" }}

# User ID for authentication. Optional for 'keystone_token' and
# 'keystone_password' auth_type. (string value)
# from .key_manager.castellan.config.user_id
{{ if not .key_manager.castellan.config.user_id }}#{{ end }}user_id = {{ .key_manager.castellan.config.user_id | default "<None>" }}

# User's domain ID for authentication. Optional for 'keystone_token'
# and 'keystone_password' auth_type. (string value)
# from .key_manager.castellan.config.user_domain_id
{{ if not .key_manager.castellan.config.user_domain_id }}#{{ end }}user_domain_id = {{ .key_manager.castellan.config.user_domain_id | default "<None>" }}

# User's domain name for authentication. Optional for 'keystone_token'
# and 'keystone_password' auth_type. (string value)
# from .key_manager.castellan.config.user_domain_name
{{ if not .key_manager.castellan.config.user_domain_name }}#{{ end }}user_domain_name = {{ .key_manager.castellan.config.user_domain_name | default "<None>" }}

# Trust ID for trust scoping. Optional for 'keystone_token' and
# 'keystone_password' auth_type. (string value)
# from .key_manager.castellan.config.trust_id
{{ if not .key_manager.castellan.config.trust_id }}#{{ end }}trust_id = {{ .key_manager.castellan.config.trust_id | default "<None>" }}

# Domain ID for domain scoping. Optional for 'keystone_token' and
# 'keystone_password' auth_type. (string value)
# from .key_manager.castellan.config.domain_id
{{ if not .key_manager.castellan.config.domain_id }}#{{ end }}domain_id = {{ .key_manager.castellan.config.domain_id | default "<None>" }}

# Domain name for domain scoping. Optional for 'keystone_token' and
# 'keystone_password' auth_type. (string value)
# from .key_manager.castellan.config.domain_name
{{ if not .key_manager.castellan.config.domain_name }}#{{ end }}domain_name = {{ .key_manager.castellan.config.domain_name | default "<None>" }}

# Project ID for project scoping. Optional for 'keystone_token' and
# 'keystone_password' auth_type. (string value)
# from .key_manager.castellan.config.project_id
{{ if not .key_manager.castellan.config.project_id }}#{{ end }}project_id = {{ .key_manager.castellan.config.project_id | default "<None>" }}

# Project name for project scoping. Optional for 'keystone_token' and
# 'keystone_password' auth_type. (string value)
# from .key_manager.castellan.config.project_name
{{ if not .key_manager.castellan.config.project_name }}#{{ end }}project_name = {{ .key_manager.castellan.config.project_name | default "<None>" }}

# Project's domain ID for project. Optional for 'keystone_token' and
# 'keystone_password' auth_type. (string value)
# from .key_manager.castellan.config.project_domain_id
{{ if not .key_manager.castellan.config.project_domain_id }}#{{ end }}project_domain_id = {{ .key_manager.castellan.config.project_domain_id | default "<None>" }}

# Project's domain name for project. Optional for 'keystone_token' and
# 'keystone_password' auth_type. (string value)
# from .key_manager.castellan.config.project_domain_name
{{ if not .key_manager.castellan.config.project_domain_name }}#{{ end }}project_domain_name = {{ .key_manager.castellan.config.project_domain_name | default "<None>" }}

# Allow fetching a new token if the current one is going to expire.
# Optional for 'keystone_token' and 'keystone_password' auth_type.
# (boolean value)
# from .key_manager.castellan.config.reauthenticate
{{ if not .key_manager.castellan.config.reauthenticate }}#{{ end }}reauthenticate = {{ .key_manager.castellan.config.reauthenticate | default "true" }}


[keystone_authtoken]

#
# From keystonemiddleware.auth_token
#

# FIXME(dulek) - added the next several lines because oslo gen config refuses to generate the line items required in keystonemiddleware
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

# Complete "public" Identity API endpoint. This endpoint should not be
# an "admin" endpoint, as it should be accessible by all end users.
# Unauthenticated clients are redirected to this endpoint to
# authenticate. Although this endpoint should  ideally be unversioned,
# client support in the wild varies.  If you're using a versioned v2
# endpoint here, then this  should *not* be the same endpoint the
# service user utilizes  for validating tokens, because normal end
# users may not be  able to reach that endpoint. (string value)
# from .keystone_authtoken.keystonemiddleware.auth_token.auth_uri
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.auth_uri }}#{{ end }}auth_uri = {{ .keystone_authtoken.keystonemiddleware.auth_token.auth_uri | default "<None>" }}

# API version of the admin Identity API endpoint. (string value)
# from .keystone_authtoken.keystonemiddleware.auth_token.auth_version
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.auth_version }}#{{ end }}auth_version = {{ .keystone_authtoken.keystonemiddleware.auth_token.auth_version | default "<None>" }}

# Do not handle authorization requests within the middleware, but
# delegate the authorization decision to downstream WSGI components.
# (boolean value)
# from .keystone_authtoken.keystonemiddleware.auth_token.delay_auth_decision
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.delay_auth_decision }}#{{ end }}delay_auth_decision = {{ .keystone_authtoken.keystonemiddleware.auth_token.delay_auth_decision | default "false" }}

# Request timeout value for communicating with Identity API server.
# (integer value)
# from .keystone_authtoken.keystonemiddleware.auth_token.http_connect_timeout
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.http_connect_timeout }}#{{ end }}http_connect_timeout = {{ .keystone_authtoken.keystonemiddleware.auth_token.http_connect_timeout | default "<None>" }}

# How many times are we trying to reconnect when communicating with
# Identity API Server. (integer value)
# from .keystone_authtoken.keystonemiddleware.auth_token.http_request_max_retries
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.http_request_max_retries }}#{{ end }}http_request_max_retries = {{ .keystone_authtoken.keystonemiddleware.auth_token.http_request_max_retries | default "3" }}

# Request environment key where the Swift cache object is stored. When
# auth_token middleware is deployed with a Swift cache, use this
# option to have the middleware share a caching backend with swift.
# Otherwise, use the ``memcached_servers`` option instead. (string
# value)
# from .keystone_authtoken.keystonemiddleware.auth_token.cache
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.cache }}#{{ end }}cache = {{ .keystone_authtoken.keystonemiddleware.auth_token.cache | default "<None>" }}

# Required if identity server requires client certificate (string
# value)
# from .keystone_authtoken.keystonemiddleware.auth_token.certfile
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.certfile }}#{{ end }}certfile = {{ .keystone_authtoken.keystonemiddleware.auth_token.certfile | default "<None>" }}

# Required if identity server requires client certificate (string
# value)
# from .keystone_authtoken.keystonemiddleware.auth_token.keyfile
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.keyfile }}#{{ end }}keyfile = {{ .keystone_authtoken.keystonemiddleware.auth_token.keyfile | default "<None>" }}

# A PEM encoded Certificate Authority to use when verifying HTTPs
# connections. Defaults to system CAs. (string value)
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

# Optionally specify a list of memcached server(s) to use for caching.
# If left undefined, tokens will instead be cached in-process. (list
# value)
# Deprecated group/name - [keystone_authtoken]/memcache_servers
# from .keystone_authtoken.keystonemiddleware.auth_token.memcached_servers
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.memcached_servers }}#{{ end }}memcached_servers = {{ .keystone_authtoken.keystonemiddleware.auth_token.memcached_servers | default "<None>" }}

# In order to prevent excessive effort spent validating tokens, the
# middleware caches previously-seen tokens for a configurable duration
# (in seconds). Set to -1 to disable caching completely. (integer
# value)
# from .keystone_authtoken.keystonemiddleware.auth_token.token_cache_time
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.token_cache_time }}#{{ end }}token_cache_time = {{ .keystone_authtoken.keystonemiddleware.auth_token.token_cache_time | default "300" }}

# Determines the frequency at which the list of revoked tokens is
# retrieved from the Identity service (in seconds). A high number of
# revocation events combined with a low cache duration may
# significantly reduce performance. Only valid for PKI tokens.
# (integer value)
# from .keystone_authtoken.keystonemiddleware.auth_token.revocation_cache_time
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.revocation_cache_time }}#{{ end }}revocation_cache_time = {{ .keystone_authtoken.keystonemiddleware.auth_token.revocation_cache_time | default "10" }}

# (Optional) If defined, indicate whether token data should be
# authenticated or authenticated and encrypted. If MAC, token data is
# authenticated (with HMAC) in the cache. If ENCRYPT, token data is
# encrypted and authenticated in the cache. If the value is not one of
# these options or empty, auth_token will raise an exception on
# initialization. (string value)
# Allowed values: None, MAC, ENCRYPT
# from .keystone_authtoken.keystonemiddleware.auth_token.memcache_security_strategy
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.memcache_security_strategy }}#{{ end }}memcache_security_strategy = {{ .keystone_authtoken.keystonemiddleware.auth_token.memcache_security_strategy | default "None" }}

# (Optional, mandatory if memcache_security_strategy is defined) This
# string is used for key derivation. (string value)
# from .keystone_authtoken.keystonemiddleware.auth_token.memcache_secret_key
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.memcache_secret_key }}#{{ end }}memcache_secret_key = {{ .keystone_authtoken.keystonemiddleware.auth_token.memcache_secret_key | default "<None>" }}

# (Optional) Number of seconds memcached server is considered dead
# before it is tried again. (integer value)
# from .keystone_authtoken.keystonemiddleware.auth_token.memcache_pool_dead_retry
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.memcache_pool_dead_retry }}#{{ end }}memcache_pool_dead_retry = {{ .keystone_authtoken.keystonemiddleware.auth_token.memcache_pool_dead_retry | default "300" }}

# (Optional) Maximum total number of open connections to every
# memcached server. (integer value)
# from .keystone_authtoken.keystonemiddleware.auth_token.memcache_pool_maxsize
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.memcache_pool_maxsize }}#{{ end }}memcache_pool_maxsize = {{ .keystone_authtoken.keystonemiddleware.auth_token.memcache_pool_maxsize | default "10" }}

# (Optional) Socket timeout in seconds for communicating with a
# memcached server. (integer value)
# from .keystone_authtoken.keystonemiddleware.auth_token.memcache_pool_socket_timeout
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.memcache_pool_socket_timeout }}#{{ end }}memcache_pool_socket_timeout = {{ .keystone_authtoken.keystonemiddleware.auth_token.memcache_pool_socket_timeout | default "3" }}

# (Optional) Number of seconds a connection to memcached is held
# unused in the pool before it is closed. (integer value)
# from .keystone_authtoken.keystonemiddleware.auth_token.memcache_pool_unused_timeout
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.memcache_pool_unused_timeout }}#{{ end }}memcache_pool_unused_timeout = {{ .keystone_authtoken.keystonemiddleware.auth_token.memcache_pool_unused_timeout | default "60" }}

# (Optional) Number of seconds that an operation will wait to get a
# memcached client connection from the pool. (integer value)
# from .keystone_authtoken.keystonemiddleware.auth_token.memcache_pool_conn_get_timeout
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.memcache_pool_conn_get_timeout }}#{{ end }}memcache_pool_conn_get_timeout = {{ .keystone_authtoken.keystonemiddleware.auth_token.memcache_pool_conn_get_timeout | default "10" }}

# (Optional) Use the advanced (eventlet safe) memcached client pool.
# The advanced pool will only work under python 2.x. (boolean value)
# from .keystone_authtoken.keystonemiddleware.auth_token.memcache_use_advanced_pool
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.memcache_use_advanced_pool }}#{{ end }}memcache_use_advanced_pool = {{ .keystone_authtoken.keystonemiddleware.auth_token.memcache_use_advanced_pool | default "false" }}

# (Optional) Indicate whether to set the X-Service-Catalog header. If
# False, middleware will not ask for service catalog on token
# validation and will not set the X-Service-Catalog header. (boolean
# value)
# from .keystone_authtoken.keystonemiddleware.auth_token.include_service_catalog
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.include_service_catalog }}#{{ end }}include_service_catalog = {{ .keystone_authtoken.keystonemiddleware.auth_token.include_service_catalog | default "true" }}

# Used to control the use and type of token binding. Can be set to:
# "disabled" to not check token binding. "permissive" (default) to
# validate binding information if the bind type is of a form known to
# the server and ignore it if not. "strict" like "permissive" but if
# the bind type is unknown the token will be rejected. "required" any
# form of token binding is needed to be allowed. Finally the name of a
# binding method that must be present in tokens. (string value)
# from .keystone_authtoken.keystonemiddleware.auth_token.enforce_token_bind
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.enforce_token_bind }}#{{ end }}enforce_token_bind = {{ .keystone_authtoken.keystonemiddleware.auth_token.enforce_token_bind | default "permissive" }}

# If true, the revocation list will be checked for cached tokens. This
# requires that PKI tokens are configured on the identity server.
# (boolean value)
# from .keystone_authtoken.keystonemiddleware.auth_token.check_revocations_for_cached
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.check_revocations_for_cached }}#{{ end }}check_revocations_for_cached = {{ .keystone_authtoken.keystonemiddleware.auth_token.check_revocations_for_cached | default "false" }}

# Hash algorithms to use for hashing PKI tokens. This may be a single
# algorithm or multiple. The algorithms are those supported by Python
# standard hashlib.new(). The hashes will be tried in the order given,
# so put the preferred one first for performance. The result of the
# first hash will be stored in the cache. This will typically be set
# to multiple values only while migrating from a less secure algorithm
# to a more secure one. Once all the old tokens are expired this
# option should be set to a single value for better performance. (list
# value)
# from .keystone_authtoken.keystonemiddleware.auth_token.hash_algorithms
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.hash_algorithms }}#{{ end }}hash_algorithms = {{ .keystone_authtoken.keystonemiddleware.auth_token.hash_algorithms | default "md5" }}

# Authentication type to load (string value)
# Deprecated group/name - [keystone_authtoken]/auth_plugin
# from .keystone_authtoken.keystonemiddleware.auth_token.auth_type
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.auth_type }}#{{ end }}auth_type = {{ .keystone_authtoken.keystonemiddleware.auth_token.auth_type | default "<None>" }}

# Config Section from which to load plugin specific options (string
# value)
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


[oslo_concurrency]

#
# From oslo.concurrency
#

# Enables or disables inter-process locks. (boolean value)
# Deprecated group/name - [DEFAULT]/disable_process_locking
# from .oslo_concurrency.oslo.concurrency.disable_process_locking
{{ if not .oslo_concurrency.oslo.concurrency.disable_process_locking }}#{{ end }}disable_process_locking = {{ .oslo_concurrency.oslo.concurrency.disable_process_locking | default "false" }}

# Directory to use for lock files.  For security, the specified
# directory should only be writable by the user running the processes
# that need locking. Defaults to environment variable OSLO_LOCK_PATH.
# If external locks are used, a lock path must be set. (string value)
# Deprecated group/name - [DEFAULT]/lock_path
# from .oslo_concurrency.oslo.concurrency.lock_path
{{ if not .oslo_concurrency.oslo.concurrency.lock_path }}#{{ end }}lock_path = {{ .oslo_concurrency.oslo.concurrency.lock_path | default "<None>" }}


[oslo_messaging_amqp]

#
# From oslo.messaging
#

# Name for the AMQP container. must be globally unique. Defaults to a
# generated UUID (string value)
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

# Identifying certificate PEM file to present to clients (string
# value)
# Deprecated group/name - [amqp1]/ssl_cert_file
# from .oslo_messaging_amqp.oslo.messaging.ssl_cert_file
{{ if not .oslo_messaging_amqp.oslo.messaging.ssl_cert_file }}#{{ end }}ssl_cert_file = {{ .oslo_messaging_amqp.oslo.messaging.ssl_cert_file | default "" }}

# Private key PEM file used to sign cert_file certificate (string
# value)
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

# Path to directory that contains the SASL configuration (string
# value)
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

# Increase the connection_retry_interval by this many seconds after
# each unsuccessful failover attempt. (integer value)
# Minimum value: 0
# from .oslo_messaging_amqp.oslo.messaging.connection_retry_backoff
{{ if not .oslo_messaging_amqp.oslo.messaging.connection_retry_backoff }}#{{ end }}connection_retry_backoff = {{ .oslo_messaging_amqp.oslo.messaging.connection_retry_backoff | default "2" }}

# Maximum limit for connection_retry_interval +
# connection_retry_backoff (integer value)
# Minimum value: 1
# from .oslo_messaging_amqp.oslo.messaging.connection_retry_interval_max
{{ if not .oslo_messaging_amqp.oslo.messaging.connection_retry_interval_max }}#{{ end }}connection_retry_interval_max = {{ .oslo_messaging_amqp.oslo.messaging.connection_retry_interval_max | default "30" }}

# Time to pause between re-connecting an AMQP 1.0 link that failed due
# to a recoverable error. (integer value)
# Minimum value: 1
# from .oslo_messaging_amqp.oslo.messaging.link_retry_delay
{{ if not .oslo_messaging_amqp.oslo.messaging.link_retry_delay }}#{{ end }}link_retry_delay = {{ .oslo_messaging_amqp.oslo.messaging.link_retry_delay | default "10" }}

# The deadline for an rpc reply message delivery. Only used when
# caller does not provide a timeout expiry. (integer value)
# Minimum value: 5
# from .oslo_messaging_amqp.oslo.messaging.default_reply_timeout
{{ if not .oslo_messaging_amqp.oslo.messaging.default_reply_timeout }}#{{ end }}default_reply_timeout = {{ .oslo_messaging_amqp.oslo.messaging.default_reply_timeout | default "30" }}

# The deadline for an rpc cast or call message delivery. Only used
# when caller does not provide a timeout expiry. (integer value)
# Minimum value: 5
# from .oslo_messaging_amqp.oslo.messaging.default_send_timeout
{{ if not .oslo_messaging_amqp.oslo.messaging.default_send_timeout }}#{{ end }}default_send_timeout = {{ .oslo_messaging_amqp.oslo.messaging.default_send_timeout | default "30" }}

# The deadline for a sent notification message delivery. Only used
# when caller does not provide a timeout expiry. (integer value)
# Minimum value: 5
# from .oslo_messaging_amqp.oslo.messaging.default_notify_timeout
{{ if not .oslo_messaging_amqp.oslo.messaging.default_notify_timeout }}#{{ end }}default_notify_timeout = {{ .oslo_messaging_amqp.oslo.messaging.default_notify_timeout | default "30" }}

# Indicates the addressing mode used by the driver.
# Permitted values:
# 'legacy'   - use legacy non-routable addressing
# 'routable' - use routable addresses
# 'dynamic'  - use legacy addresses if the message bus does not
# support routing otherwise use routable addressing (string value)
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

# Address prefix for all generated Notification addresses (string
# value)
# from .oslo_messaging_amqp.oslo.messaging.notify_address_prefix
{{ if not .oslo_messaging_amqp.oslo.messaging.notify_address_prefix }}#{{ end }}notify_address_prefix = {{ .oslo_messaging_amqp.oslo.messaging.notify_address_prefix | default "openstack.org/om/notify" }}

# Appended to the address prefix when sending a fanout message. Used
# by the message bus to identify fanout messages. (string value)
# from .oslo_messaging_amqp.oslo.messaging.multicast_address
{{ if not .oslo_messaging_amqp.oslo.messaging.multicast_address }}#{{ end }}multicast_address = {{ .oslo_messaging_amqp.oslo.messaging.multicast_address | default "multicast" }}

# Appended to the address prefix when sending to a particular
# RPC/Notification server. Used by the message bus to identify
# messages sent to a single destination. (string value)
# from .oslo_messaging_amqp.oslo.messaging.unicast_address
{{ if not .oslo_messaging_amqp.oslo.messaging.unicast_address }}#{{ end }}unicast_address = {{ .oslo_messaging_amqp.oslo.messaging.unicast_address | default "unicast" }}

# Appended to the address prefix when sending to a group of consumers.
# Used by the message bus to identify messages that should be
# delivered in a round-robin fashion across consumers. (string value)
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

# A URL representing the messaging driver to use for notifications. If
# not set, we fall back to the same configuration used for RPC.
# (string value)
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

# SSL version to use (valid only if SSL enabled). Valid values are
# TLSv1 and SSLv23. SSLv2, SSLv3, TLSv1_1, and TLSv1_2 may be
# available on some distributions. (string value)
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

# SSL certification authority file (valid only if SSL enabled).
# (string value)
# Deprecated group/name - [DEFAULT]/kombu_ssl_ca_certs
# from .oslo_messaging_rabbit.oslo.messaging.kombu_ssl_ca_certs
{{ if not .oslo_messaging_rabbit.oslo.messaging.kombu_ssl_ca_certs }}#{{ end }}kombu_ssl_ca_certs = {{ .oslo_messaging_rabbit.oslo.messaging.kombu_ssl_ca_certs | default "" }}

# How long to wait before reconnecting in response to an AMQP consumer
# cancel notification. (floating point value)
# Deprecated group/name - [DEFAULT]/kombu_reconnect_delay
# from .oslo_messaging_rabbit.oslo.messaging.kombu_reconnect_delay
{{ if not .oslo_messaging_rabbit.oslo.messaging.kombu_reconnect_delay }}#{{ end }}kombu_reconnect_delay = {{ .oslo_messaging_rabbit.oslo.messaging.kombu_reconnect_delay | default "1.0" }}

# EXPERIMENTAL: Possible values are: gzip, bz2. If not set compression
# will not be used. This option may not be available in future
# versions. (string value)
# from .oslo_messaging_rabbit.oslo.messaging.kombu_compression
{{ if not .oslo_messaging_rabbit.oslo.messaging.kombu_compression }}#{{ end }}kombu_compression = {{ .oslo_messaging_rabbit.oslo.messaging.kombu_compression | default "<None>" }}

# How long to wait a missing client before abandoning to send it its
# replies. This value should not be longer than rpc_response_timeout.
# (integer value)
# Deprecated group/name - [oslo_messaging_rabbit]/kombu_reconnect_timeout
# from .oslo_messaging_rabbit.oslo.messaging.kombu_missing_consumer_retry_timeout
{{ if not .oslo_messaging_rabbit.oslo.messaging.kombu_missing_consumer_retry_timeout }}#{{ end }}kombu_missing_consumer_retry_timeout = {{ .oslo_messaging_rabbit.oslo.messaging.kombu_missing_consumer_retry_timeout | default "60" }}

# Determines how the next RabbitMQ node is chosen in case the one we
# are currently connected to becomes unavailable. Takes effect only if
# more than one RabbitMQ node is provided in config. (string value)
# Allowed values: round-robin, shuffle
# from .oslo_messaging_rabbit.oslo.messaging.kombu_failover_strategy
{{ if not .oslo_messaging_rabbit.oslo.messaging.kombu_failover_strategy }}#{{ end }}kombu_failover_strategy = {{ .oslo_messaging_rabbit.oslo.messaging.kombu_failover_strategy | default "round-robin" }}

# DEPRECATED: The RabbitMQ broker address where a single node is used.
# (string value)
# Deprecated group/name - [DEFAULT]/rabbit_host
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# Reason: Replaced by [DEFAULT]/transport_url
# from .oslo_messaging_rabbit.oslo.messaging.rabbit_host
{{ if not .oslo_messaging_rabbit.oslo.messaging.rabbit_host }}#{{ end }}rabbit_host = {{ .oslo_messaging_rabbit.oslo.messaging.rabbit_host | default "localhost" }}

# DEPRECATED: The RabbitMQ broker port where a single node is used.
# (port value)
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

# How long to backoff for between retries when connecting to RabbitMQ.
# (integer value)
# Deprecated group/name - [DEFAULT]/rabbit_retry_backoff
# from .oslo_messaging_rabbit.oslo.messaging.rabbit_retry_backoff
{{ if not .oslo_messaging_rabbit.oslo.messaging.rabbit_retry_backoff }}#{{ end }}rabbit_retry_backoff = {{ .oslo_messaging_rabbit.oslo.messaging.rabbit_retry_backoff | default "2" }}

# Maximum interval of RabbitMQ connection retries. Default is 30
# seconds. (integer value)
# from .oslo_messaging_rabbit.oslo.messaging.rabbit_interval_max
{{ if not .oslo_messaging_rabbit.oslo.messaging.rabbit_interval_max }}#{{ end }}rabbit_interval_max = {{ .oslo_messaging_rabbit.oslo.messaging.rabbit_interval_max | default "30" }}

# DEPRECATED: Maximum number of RabbitMQ connection retries. Default
# is 0 (infinite retry count). (integer value)
# Deprecated group/name - [DEFAULT]/rabbit_max_retries
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# from .oslo_messaging_rabbit.oslo.messaging.rabbit_max_retries
{{ if not .oslo_messaging_rabbit.oslo.messaging.rabbit_max_retries }}#{{ end }}rabbit_max_retries = {{ .oslo_messaging_rabbit.oslo.messaging.rabbit_max_retries | default "0" }}

# Try to use HA queues in RabbitMQ (x-ha-policy: all). If you change
# this option, you must wipe the RabbitMQ database. In RabbitMQ 3.0,
# queue mirroring is no longer controlled by the x-ha-policy argument
# when declaring a queue. If you just want to make sure that all
# queues (except  those with auto-generated names) are mirrored across
# all nodes, run: "rabbitmqctl set_policy HA '^(?!amq\.).*' '{"ha-
# mode": "all"}' " (boolean value)
# Deprecated group/name - [DEFAULT]/rabbit_ha_queues
# from .oslo_messaging_rabbit.oslo.messaging.rabbit_ha_queues
{{ if not .oslo_messaging_rabbit.oslo.messaging.rabbit_ha_queues }}#{{ end }}rabbit_ha_queues = {{ .oslo_messaging_rabbit.oslo.messaging.rabbit_ha_queues | default "false" }}

# Positive integer representing duration in seconds for queue TTL
# (x-expires). Queues which are unused for the duration of the TTL are
# automatically deleted. The parameter affects only reply and fanout
# queues. (integer value)
# Minimum value: 1
# from .oslo_messaging_rabbit.oslo.messaging.rabbit_transient_queues_ttl
{{ if not .oslo_messaging_rabbit.oslo.messaging.rabbit_transient_queues_ttl }}#{{ end }}rabbit_transient_queues_ttl = {{ .oslo_messaging_rabbit.oslo.messaging.rabbit_transient_queues_ttl | default "1800" }}

# Specifies the number of messages to prefetch. Setting to zero allows
# unlimited messages. (integer value)
# from .oslo_messaging_rabbit.oslo.messaging.rabbit_qos_prefetch_count
{{ if not .oslo_messaging_rabbit.oslo.messaging.rabbit_qos_prefetch_count }}#{{ end }}rabbit_qos_prefetch_count = {{ .oslo_messaging_rabbit.oslo.messaging.rabbit_qos_prefetch_count | default "0" }}

# Number of seconds after which the Rabbit broker is considered down
# if heartbeat's keep-alive fails (0 disable the heartbeat).
# EXPERIMENTAL (integer value)
# from .oslo_messaging_rabbit.oslo.messaging.heartbeat_timeout_threshold
{{ if not .oslo_messaging_rabbit.oslo.messaging.heartbeat_timeout_threshold }}#{{ end }}heartbeat_timeout_threshold = {{ .oslo_messaging_rabbit.oslo.messaging.heartbeat_timeout_threshold | default "60" }}

# How often times during the heartbeat_timeout_threshold we check the
# heartbeat. (integer value)
# from .oslo_messaging_rabbit.oslo.messaging.heartbeat_rate
{{ if not .oslo_messaging_rabbit.oslo.messaging.heartbeat_rate }}#{{ end }}heartbeat_rate = {{ .oslo_messaging_rabbit.oslo.messaging.heartbeat_rate | default "2" }}

# Deprecated, use rpc_backend=kombu+memory or rpc_backend=fake
# (boolean value)
# Deprecated group/name - [DEFAULT]/fake_rabbit
# from .oslo_messaging_rabbit.oslo.messaging.fake_rabbit
{{ if not .oslo_messaging_rabbit.oslo.messaging.fake_rabbit }}#{{ end }}fake_rabbit = {{ .oslo_messaging_rabbit.oslo.messaging.fake_rabbit | default "false" }}

# Maximum number of channels to allow (integer value)
# from .oslo_messaging_rabbit.oslo.messaging.channel_max
{{ if not .oslo_messaging_rabbit.oslo.messaging.channel_max }}#{{ end }}channel_max = {{ .oslo_messaging_rabbit.oslo.messaging.channel_max | default "<None>" }}

# The maximum byte size for an AMQP frame (integer value)
# from .oslo_messaging_rabbit.oslo.messaging.frame_max
{{ if not .oslo_messaging_rabbit.oslo.messaging.frame_max }}#{{ end }}frame_max = {{ .oslo_messaging_rabbit.oslo.messaging.frame_max | default "<None>" }}

# How often to send heartbeats for consumer's connections (integer
# value)
# from .oslo_messaging_rabbit.oslo.messaging.heartbeat_interval
{{ if not .oslo_messaging_rabbit.oslo.messaging.heartbeat_interval }}#{{ end }}heartbeat_interval = {{ .oslo_messaging_rabbit.oslo.messaging.heartbeat_interval | default "3" }}

# Enable SSL (boolean value)
# from .oslo_messaging_rabbit.oslo.messaging.ssl
{{ if not .oslo_messaging_rabbit.oslo.messaging.ssl }}#{{ end }}ssl = {{ .oslo_messaging_rabbit.oslo.messaging.ssl | default "<None>" }}

# Arguments passed to ssl.wrap_socket (dict value)
# from .oslo_messaging_rabbit.oslo.messaging.ssl_options
{{ if not .oslo_messaging_rabbit.oslo.messaging.ssl_options }}#{{ end }}ssl_options = {{ .oslo_messaging_rabbit.oslo.messaging.ssl_options | default "<None>" }}

# Set socket timeout in seconds for connection's socket (floating
# point value)
# from .oslo_messaging_rabbit.oslo.messaging.socket_timeout
{{ if not .oslo_messaging_rabbit.oslo.messaging.socket_timeout }}#{{ end }}socket_timeout = {{ .oslo_messaging_rabbit.oslo.messaging.socket_timeout | default "0.25" }}

# Set TCP_USER_TIMEOUT in seconds for connection's socket (floating
# point value)
# from .oslo_messaging_rabbit.oslo.messaging.tcp_user_timeout
{{ if not .oslo_messaging_rabbit.oslo.messaging.tcp_user_timeout }}#{{ end }}tcp_user_timeout = {{ .oslo_messaging_rabbit.oslo.messaging.tcp_user_timeout | default "0.25" }}

# Set delay for reconnection to some host which has connection error
# (floating point value)
# from .oslo_messaging_rabbit.oslo.messaging.host_connection_reconnect_delay
{{ if not .oslo_messaging_rabbit.oslo.messaging.host_connection_reconnect_delay }}#{{ end }}host_connection_reconnect_delay = {{ .oslo_messaging_rabbit.oslo.messaging.host_connection_reconnect_delay | default "0.25" }}

# Connection factory implementation (string value)
# Allowed values: new, single, read_write
# from .oslo_messaging_rabbit.oslo.messaging.connection_factory
{{ if not .oslo_messaging_rabbit.oslo.messaging.connection_factory }}#{{ end }}connection_factory = {{ .oslo_messaging_rabbit.oslo.messaging.connection_factory | default "single" }}

# Maximum number of connections to keep queued. (integer value)
# from .oslo_messaging_rabbit.oslo.messaging.pool_max_size
{{ if not .oslo_messaging_rabbit.oslo.messaging.pool_max_size }}#{{ end }}pool_max_size = {{ .oslo_messaging_rabbit.oslo.messaging.pool_max_size | default "30" }}

# Maximum number of connections to create above `pool_max_size`.
# (integer value)
# from .oslo_messaging_rabbit.oslo.messaging.pool_max_overflow
{{ if not .oslo_messaging_rabbit.oslo.messaging.pool_max_overflow }}#{{ end }}pool_max_overflow = {{ .oslo_messaging_rabbit.oslo.messaging.pool_max_overflow | default "0" }}

# Default number of seconds to wait for a connections to available
# (integer value)
# from .oslo_messaging_rabbit.oslo.messaging.pool_timeout
{{ if not .oslo_messaging_rabbit.oslo.messaging.pool_timeout }}#{{ end }}pool_timeout = {{ .oslo_messaging_rabbit.oslo.messaging.pool_timeout | default "30" }}

# Lifetime of a connection (since creation) in seconds or None for no
# recycling. Expired connections are closed on acquire. (integer
# value)
# from .oslo_messaging_rabbit.oslo.messaging.pool_recycle
{{ if not .oslo_messaging_rabbit.oslo.messaging.pool_recycle }}#{{ end }}pool_recycle = {{ .oslo_messaging_rabbit.oslo.messaging.pool_recycle | default "600" }}

# Threshold at which inactive (since release) connections are
# considered stale in seconds or None for no staleness. Stale
# connections are closed on acquire. (integer value)
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

# Reconnecting retry count in case of connectivity problem during
# sending notification, -1 means infinite retry. (integer value)
# from .oslo_messaging_rabbit.oslo.messaging.default_notification_retry_attempts
{{ if not .oslo_messaging_rabbit.oslo.messaging.default_notification_retry_attempts }}#{{ end }}default_notification_retry_attempts = {{ .oslo_messaging_rabbit.oslo.messaging.default_notification_retry_attempts | default "-1" }}

# Reconnecting retry delay in case of connectivity problem during
# sending notification message (floating point value)
# from .oslo_messaging_rabbit.oslo.messaging.notification_retry_delay
{{ if not .oslo_messaging_rabbit.oslo.messaging.notification_retry_delay }}#{{ end }}notification_retry_delay = {{ .oslo_messaging_rabbit.oslo.messaging.notification_retry_delay | default "0.25" }}

# Time to live for rpc queues without consumers in seconds. (integer
# value)
# from .oslo_messaging_rabbit.oslo.messaging.rpc_queue_expiration
{{ if not .oslo_messaging_rabbit.oslo.messaging.rpc_queue_expiration }}#{{ end }}rpc_queue_expiration = {{ .oslo_messaging_rabbit.oslo.messaging.rpc_queue_expiration | default "60" }}

# Exchange name for sending RPC messages (string value)
# from .oslo_messaging_rabbit.oslo.messaging.default_rpc_exchange
{{ if not .oslo_messaging_rabbit.oslo.messaging.default_rpc_exchange }}#{{ end }}default_rpc_exchange = {{ .oslo_messaging_rabbit.oslo.messaging.default_rpc_exchange | default "${control_exchange}_rpc" }}

# Exchange name for receiving RPC replies (string value)
# from .oslo_messaging_rabbit.oslo.messaging.rpc_reply_exchange
{{ if not .oslo_messaging_rabbit.oslo.messaging.rpc_reply_exchange }}#{{ end }}rpc_reply_exchange = {{ .oslo_messaging_rabbit.oslo.messaging.rpc_reply_exchange | default "${control_exchange}_rpc_reply" }}

# Max number of not acknowledged message which RabbitMQ can send to
# rpc listener. (integer value)
# from .oslo_messaging_rabbit.oslo.messaging.rpc_listener_prefetch_count
{{ if not .oslo_messaging_rabbit.oslo.messaging.rpc_listener_prefetch_count }}#{{ end }}rpc_listener_prefetch_count = {{ .oslo_messaging_rabbit.oslo.messaging.rpc_listener_prefetch_count | default "100" }}

# Max number of not acknowledged message which RabbitMQ can send to
# rpc reply listener. (integer value)
# from .oslo_messaging_rabbit.oslo.messaging.rpc_reply_listener_prefetch_count
{{ if not .oslo_messaging_rabbit.oslo.messaging.rpc_reply_listener_prefetch_count }}#{{ end }}rpc_reply_listener_prefetch_count = {{ .oslo_messaging_rabbit.oslo.messaging.rpc_reply_listener_prefetch_count | default "100" }}

# Reconnecting retry count in case of connectivity problem during
# sending reply. -1 means infinite retry during rpc_timeout (integer
# value)
# from .oslo_messaging_rabbit.oslo.messaging.rpc_reply_retry_attempts
{{ if not .oslo_messaging_rabbit.oslo.messaging.rpc_reply_retry_attempts }}#{{ end }}rpc_reply_retry_attempts = {{ .oslo_messaging_rabbit.oslo.messaging.rpc_reply_retry_attempts | default "-1" }}

# Reconnecting retry delay in case of connectivity problem during
# sending reply. (floating point value)
# from .oslo_messaging_rabbit.oslo.messaging.rpc_reply_retry_delay
{{ if not .oslo_messaging_rabbit.oslo.messaging.rpc_reply_retry_delay }}#{{ end }}rpc_reply_retry_delay = {{ .oslo_messaging_rabbit.oslo.messaging.rpc_reply_retry_delay | default "0.25" }}

# Reconnecting retry count in case of connectivity problem during
# sending RPC message, -1 means infinite retry. If actual retry
# attempts in not 0 the rpc request could be processed more then one
# time (integer value)
# from .oslo_messaging_rabbit.oslo.messaging.default_rpc_retry_attempts
{{ if not .oslo_messaging_rabbit.oslo.messaging.default_rpc_retry_attempts }}#{{ end }}default_rpc_retry_attempts = {{ .oslo_messaging_rabbit.oslo.messaging.default_rpc_retry_attempts | default "-1" }}

# Reconnecting retry delay in case of connectivity problem during
# sending RPC message (floating point value)
# from .oslo_messaging_rabbit.oslo.messaging.rpc_retry_delay
{{ if not .oslo_messaging_rabbit.oslo.messaging.rpc_retry_delay }}#{{ end }}rpc_retry_delay = {{ .oslo_messaging_rabbit.oslo.messaging.rpc_retry_delay | default "0.25" }}


[oslo_messaging_zmq]

#
# From oslo.messaging
#

# ZeroMQ bind address. Should be a wildcard (*), an ethernet
# interface, or IP. The "host" option should point or resolve to this
# address. (string value)
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

# Maximum number of ingress messages to locally buffer per topic.
# Default is unlimited. (integer value)
# Deprecated group/name - [DEFAULT]/rpc_zmq_topic_backlog
# from .oslo_messaging_zmq.oslo.messaging.rpc_zmq_topic_backlog
{{ if not .oslo_messaging_zmq.oslo.messaging.rpc_zmq_topic_backlog }}#{{ end }}rpc_zmq_topic_backlog = {{ .oslo_messaging_zmq.oslo.messaging.rpc_zmq_topic_backlog | default "<None>" }}

# Directory for holding IPC sockets. (string value)
# Deprecated group/name - [DEFAULT]/rpc_zmq_ipc_dir
# from .oslo_messaging_zmq.oslo.messaging.rpc_zmq_ipc_dir
{{ if not .oslo_messaging_zmq.oslo.messaging.rpc_zmq_ipc_dir }}#{{ end }}rpc_zmq_ipc_dir = {{ .oslo_messaging_zmq.oslo.messaging.rpc_zmq_ipc_dir | default "/var/run/openstack" }}

# Name of this node. Must be a valid hostname, FQDN, or IP address.
# Must match "host" option, if running Nova. (string value)
# Deprecated group/name - [DEFAULT]/rpc_zmq_host
# from .oslo_messaging_zmq.oslo.messaging.rpc_zmq_host
{{ if not .oslo_messaging_zmq.oslo.messaging.rpc_zmq_host }}#{{ end }}rpc_zmq_host = {{ .oslo_messaging_zmq.oslo.messaging.rpc_zmq_host | default "localhost" }}

# Seconds to wait before a cast expires (TTL). The default value of -1
# specifies an infinite linger period. The value of 0 specifies no
# linger period. Pending messages shall be discarded immediately when
# the socket is closed. Only supported by impl_zmq. (integer value)
# Deprecated group/name - [DEFAULT]/rpc_cast_timeout
# from .oslo_messaging_zmq.oslo.messaging.rpc_cast_timeout
{{ if not .oslo_messaging_zmq.oslo.messaging.rpc_cast_timeout }}#{{ end }}rpc_cast_timeout = {{ .oslo_messaging_zmq.oslo.messaging.rpc_cast_timeout | default "-1" }}

# The default number of seconds that poll should wait. Poll raises
# timeout exception when timeout expired. (integer value)
# Deprecated group/name - [DEFAULT]/rpc_poll_timeout
# from .oslo_messaging_zmq.oslo.messaging.rpc_poll_timeout
{{ if not .oslo_messaging_zmq.oslo.messaging.rpc_poll_timeout }}#{{ end }}rpc_poll_timeout = {{ .oslo_messaging_zmq.oslo.messaging.rpc_poll_timeout | default "1" }}

# Expiration timeout in seconds of a name service record about
# existing target ( < 0 means no timeout). (integer value)
# Deprecated group/name - [DEFAULT]/zmq_target_expire
# from .oslo_messaging_zmq.oslo.messaging.zmq_target_expire
{{ if not .oslo_messaging_zmq.oslo.messaging.zmq_target_expire }}#{{ end }}zmq_target_expire = {{ .oslo_messaging_zmq.oslo.messaging.zmq_target_expire | default "300" }}

# Update period in seconds of a name service record about existing
# target. (integer value)
# Deprecated group/name - [DEFAULT]/zmq_target_update
# from .oslo_messaging_zmq.oslo.messaging.zmq_target_update
{{ if not .oslo_messaging_zmq.oslo.messaging.zmq_target_update }}#{{ end }}zmq_target_update = {{ .oslo_messaging_zmq.oslo.messaging.zmq_target_update | default "180" }}

# Use PUB/SUB pattern for fanout methods. PUB/SUB always uses proxy.
# (boolean value)
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

# Number of retries to find free port number before fail with
# ZMQBindError. (integer value)
# Deprecated group/name - [DEFAULT]/rpc_zmq_bind_port_retries
# from .oslo_messaging_zmq.oslo.messaging.rpc_zmq_bind_port_retries
{{ if not .oslo_messaging_zmq.oslo.messaging.rpc_zmq_bind_port_retries }}#{{ end }}rpc_zmq_bind_port_retries = {{ .oslo_messaging_zmq.oslo.messaging.rpc_zmq_bind_port_retries | default "100" }}

# Default serialization mechanism for serializing/deserializing
# outgoing/incoming messages (string value)
# Allowed values: json, msgpack
# Deprecated group/name - [DEFAULT]/rpc_zmq_serialization
# from .oslo_messaging_zmq.oslo.messaging.rpc_zmq_serialization
{{ if not .oslo_messaging_zmq.oslo.messaging.rpc_zmq_serialization }}#{{ end }}rpc_zmq_serialization = {{ .oslo_messaging_zmq.oslo.messaging.rpc_zmq_serialization | default "json" }}

# This option configures round-robin mode in zmq socket. True means
# not keeping a queue when server side disconnects. False means to
# keep queue and messages even if server is disconnected, when the
# server appears we send all accumulated messages to it. (boolean
# value)
# from .oslo_messaging_zmq.oslo.messaging.zmq_immediate
{{ if not .oslo_messaging_zmq.oslo.messaging.zmq_immediate }}#{{ end }}zmq_immediate = {{ .oslo_messaging_zmq.oslo.messaging.zmq_immediate | default "false" }}


[oslo_middleware]

#
# From oslo.middleware
#

# The maximum body size for each  request, in bytes. (integer value)
# Deprecated group/name - [DEFAULT]/osapi_max_request_body_size
# Deprecated group/name - [DEFAULT]/max_request_body_size
# from .oslo_middleware.oslo.middleware.max_request_body_size
{{ if not .oslo_middleware.oslo.middleware.max_request_body_size }}#{{ end }}max_request_body_size = {{ .oslo_middleware.oslo.middleware.max_request_body_size | default "114688" }}

# DEPRECATED: The HTTP Header that will be used to determine what the
# original request protocol scheme was, even if it was hidden by a SSL
# termination proxy. (string value)
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# from .oslo_middleware.oslo.middleware.secure_proxy_ssl_header
{{ if not .oslo_middleware.oslo.middleware.secure_proxy_ssl_header }}#{{ end }}secure_proxy_ssl_header = {{ .oslo_middleware.oslo.middleware.secure_proxy_ssl_header | default "X-Forwarded-Proto" }}

# Whether the application is behind a proxy or not. This determines if
# the middleware should parse the headers or not. (boolean value)
# from .oslo_middleware.oslo.middleware.enable_proxy_headers_parsing
{{ if not .oslo_middleware.oslo.middleware.enable_proxy_headers_parsing }}#{{ end }}enable_proxy_headers_parsing = {{ .oslo_middleware.oslo.middleware.enable_proxy_headers_parsing | default "false" }}


[oslo_policy]

#
# From oslo.policy
#

# The JSON file that defines policies. (string value)
# Deprecated group/name - [DEFAULT]/policy_file
# from .oslo_policy.oslo.policy.policy_file
{{ if not .oslo_policy.oslo.policy.policy_file }}#{{ end }}policy_file = {{ .oslo_policy.oslo.policy.policy_file | default "policy.json" }}

# Default rule. Enforced when a requested rule is not found. (string
# value)
# Deprecated group/name - [DEFAULT]/policy_default_rule
# from .oslo_policy.oslo.policy.policy_default_rule
{{ if not .oslo_policy.oslo.policy.policy_default_rule }}#{{ end }}policy_default_rule = {{ .oslo_policy.oslo.policy.policy_default_rule | default "default" }}

# Directories where policy configuration files are stored. They can be
# relative to any directory in the search path defined by the
# config_dir option, or absolute paths. The file defined by
# policy_file must exist for these directories to be searched.
# Missing or empty directories are ignored. (multi valued)
# Deprecated group/name - [DEFAULT]/policy_dirs
# from .oslo_policy.oslo.policy.policy_dirs (multiopt)
{{ if not .oslo_policy.oslo.policy.policy_dirs }}#policy_dirs = {{ .oslo_policy.oslo.policy.policy_dirs | default "policy.d" }}{{ else }}{{ range .oslo_policy.oslo.policy.policy_dirs }}policy_dirs = {{ . }}
{{ end }}{{ end }}


[oslo_reports]

#
# From oslo.reports
#

# Path to a log directory where to create a file (string value)
# from .oslo_reports.oslo.reports.log_dir
{{ if not .oslo_reports.oslo.reports.log_dir }}#{{ end }}log_dir = {{ .oslo_reports.oslo.reports.log_dir | default "<None>" }}

# The path to a file to watch for changes to trigger the reports,
# instead of signals. Setting this option disables the signal trigger
# for the reports. If application is running as a WSGI application it
# is recommended to use this instead of signals. (string value)
# from .oslo_reports.oslo.reports.file_event_handler
{{ if not .oslo_reports.oslo.reports.file_event_handler }}#{{ end }}file_event_handler = {{ .oslo_reports.oslo.reports.file_event_handler | default "<None>" }}

# How many seconds to wait between polls when file_event_handler is
# set (integer value)
# from .oslo_reports.oslo.reports.file_event_handler_interval
{{ if not .oslo_reports.oslo.reports.file_event_handler_interval }}#{{ end }}file_event_handler_interval = {{ .oslo_reports.oslo.reports.file_event_handler_interval | default "1" }}


[oslo_versionedobjects]

#
# From oslo.versionedobjects
#

# Make exception message format errors fatal (boolean value)
# from .oslo_versionedobjects.oslo.versionedobjects.fatal_exception_format_errors
{{ if not .oslo_versionedobjects.oslo.versionedobjects.fatal_exception_format_errors }}#{{ end }}fatal_exception_format_errors = {{ .oslo_versionedobjects.oslo.versionedobjects.fatal_exception_format_errors | default "false" }}


[ssl]

#
# From oslo.service.sslutils
#

# CA certificate file to use to verify connecting clients. (string
# value)
# Deprecated group/name - [DEFAULT]/ssl_ca_file
# from .ssl.oslo.service.sslutils.ca_file
{{ if not .ssl.oslo.service.sslutils.ca_file }}#{{ end }}ca_file = {{ .ssl.oslo.service.sslutils.ca_file | default "<None>" }}

# Certificate file to use when starting the server securely. (string
# value)
# Deprecated group/name - [DEFAULT]/ssl_cert_file
# from .ssl.oslo.service.sslutils.cert_file
{{ if not .ssl.oslo.service.sslutils.cert_file }}#{{ end }}cert_file = {{ .ssl.oslo.service.sslutils.cert_file | default "<None>" }}

# Private key file to use when starting the server securely. (string
# value)
# Deprecated group/name - [DEFAULT]/ssl_key_file
# from .ssl.oslo.service.sslutils.key_file
{{ if not .ssl.oslo.service.sslutils.key_file }}#{{ end }}key_file = {{ .ssl.oslo.service.sslutils.key_file | default "<None>" }}

# SSL version to use (valid only if SSL enabled). Valid values are
# TLSv1 and SSLv23. SSLv2, SSLv3, TLSv1_1, and TLSv1_2 may be
# available on some distributions. (string value)
# from .ssl.oslo.service.sslutils.version
{{ if not .ssl.oslo.service.sslutils.version }}#{{ end }}version = {{ .ssl.oslo.service.sslutils.version | default "<None>" }}

# Sets the list of available ciphers. value should be a string in the
# OpenSSL cipher list format. (string value)
# from .ssl.oslo.service.sslutils.ciphers
{{ if not .ssl.oslo.service.sslutils.ciphers }}#{{ end }}ciphers = {{ .ssl.oslo.service.sslutils.ciphers | default "<None>" }}

{{- end -}}

