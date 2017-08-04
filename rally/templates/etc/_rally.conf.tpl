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

{{ include "rally.conf.rally_values_skeleton" .Values.conf.rally | trunc 0 }}
{{ include "rally.conf.rally" .Values.conf.rally }}


{{- define "rally.conf.rally_values_skeleton" -}}

{{- if not .default -}}{{- set . "default" dict -}}{{- end -}}
{{- if not .default.oslo -}}{{- set .default "oslo" dict -}}{{- end -}}
{{- if not .default.oslo.log -}}{{- set .default.oslo "log" dict -}}{{- end -}}
{{- if not .default.rally -}}{{- set .default "rally" dict -}}{{- end -}}
{{- if not .benchmark -}}{{- set . "benchmark" dict -}}{{- end -}}
{{- if not .benchmark.rally -}}{{- set .benchmark "rally" dict -}}{{- end -}}
{{- if not .cleanup -}}{{- set . "cleanup" dict -}}{{- end -}}
{{- if not .cleanup.rally -}}{{- set .cleanup "rally" dict -}}{{- end -}}
{{- if not .database -}}{{- set . "database" dict -}}{{- end -}}
{{- if not .database.oslo -}}{{- set .database "oslo" dict -}}{{- end -}}
{{- if not .database.oslo.db -}}{{- set .database.oslo "db" dict -}}{{- end -}}
{{- if not .roles_context -}}{{- set . "roles_context" dict -}}{{- end -}}
{{- if not .roles_context.rally -}}{{- set .roles_context "rally" dict -}}{{- end -}}
{{- if not .tempest -}}{{- set . "tempest" dict -}}{{- end -}}
{{- if not .tempest.rally -}}{{- set .tempest "rally" dict -}}{{- end -}}
{{- if not .users_context -}}{{- set . "users_context" dict -}}{{- end -}}
{{- if not .users_context.rally -}}{{- set .users_context "rally" dict -}}{{- end -}}

{{- end -}}


{{- define "rally.conf.rally" -}}

[DEFAULT]

#
# From oslo.log
#

# If set to true, the logging level will be set to DEBUG instead of
# the default INFO level. (boolean value)
# Note: This option can be changed without restarting.
# from .default.oslo.log.debug
{{ if not .default.oslo.log.debug }}#{{ end }}debug = {{ .default.oslo.log.debug | default "false" }}

# The name of a logging configuration file. This file is appended to
# any existing logging configuration files. For details about logging
# configuration files, see the Python logging module documentation.
# Note that when logging configuration files are used then all logging
# configuration is set in the configuration file and other logging
# configuration options are ignored (for example,
# logging_context_format_string). (string value)
# Note: This option can be changed without restarting.
# Deprecated group/name - [DEFAULT]/log-config
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

# Enable journald for logging. If running in a systemd environment you
# may wish to enable journal support. Doing so will use the journal
# native protocol which includes structured metadata in addition to
# log messages.This option is ignored if log_config_append is set.
# (boolean value)
# from .default.oslo.log.use_journal
{{ if not .default.oslo.log.use_journal }}#{{ end }}use_journal = {{ .default.oslo.log.use_journal | default "false" }}

# Syslog facility to receive log lines. This option is ignored if
# log_config_append is set. (string value)
# from .default.oslo.log.syslog_log_facility
{{ if not .default.oslo.log.syslog_log_facility }}#{{ end }}syslog_log_facility = {{ .default.oslo.log.syslog_log_facility | default "LOG_USER" }}

# Log output to standard error. This option is ignored if
# log_config_append is set. (boolean value)
# from .default.oslo.log.use_stderr
{{ if not .default.oslo.log.use_stderr }}#{{ end }}use_stderr = {{ .default.oslo.log.use_stderr | default "false" }}

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
{{ if not .default.oslo.log.default_log_levels }}#{{ end }}default_log_levels = {{ .default.oslo.log.default_log_levels | default "amqp=WARN,amqplib=WARN,boto=WARN,qpid=WARN,sqlalchemy=WARN,suds=INFO,oslo.messaging=INFO,oslo_messaging=INFO,iso8601=WARN,requests.packages.urllib3.connectionpool=WARN,urllib3.connectionpool=WARN,websocket=WARN,requests.packages.urllib3.util.retry=WARN,urllib3.util.retry=WARN,keystonemiddleware=WARN,routes.middleware=WARN,stevedore=WARN,taskflow=WARN,keystoneauth=WARN,oslo.cache=INFO,dogpile.core.dogpile=INFO" }}

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

# Interval, number of seconds, of log rate limiting. (integer value)
# from .default.oslo.log.rate_limit_interval
{{ if not .default.oslo.log.rate_limit_interval }}#{{ end }}rate_limit_interval = {{ .default.oslo.log.rate_limit_interval | default "0" }}

# Maximum number of logged messages per rate_limit_interval. (integer
# value)
# from .default.oslo.log.rate_limit_burst
{{ if not .default.oslo.log.rate_limit_burst }}#{{ end }}rate_limit_burst = {{ .default.oslo.log.rate_limit_burst | default "0" }}

# Log level name used by rate limiting: CRITICAL, ERROR, INFO,
# WARNING, DEBUG or empty string. Logs with level greater or equal to
# rate_limit_except_level are not filtered. An empty string means that
# all levels are filtered. (string value)
# from .default.oslo.log.rate_limit_except_level
{{ if not .default.oslo.log.rate_limit_except_level }}#{{ end }}rate_limit_except_level = {{ .default.oslo.log.rate_limit_except_level | default "CRITICAL" }}

# Enables or disables fatal status of deprecations. (boolean value)
# from .default.oslo.log.fatal_deprecations
{{ if not .default.oslo.log.fatal_deprecations }}#{{ end }}fatal_deprecations = {{ .default.oslo.log.fatal_deprecations | default "false" }}

#
# From rally
#

# Print debugging output only for Rally. Off-site components stay
# quiet. (boolean value)
# from .default.rally.rally_debug
{{ if not .default.rally.rally_debug }}#{{ end }}rally_debug = {{ .default.rally.rally_debug | default "false" }}

# HTTP timeout for any of OpenStack service in seconds (floating point
# value)
# from .default.rally.openstack_client_http_timeout
{{ if not .default.rally.openstack_client_http_timeout }}#{{ end }}openstack_client_http_timeout = {{ .default.rally.openstack_client_http_timeout | default "180.0" }}

# Size of raw result chunk in iterations (integer value)
# Minimum value: 1
# from .default.rally.raw_result_chunk_size
{{ if not .default.rally.raw_result_chunk_size }}#{{ end }}raw_result_chunk_size = {{ .default.rally.raw_result_chunk_size | default "1000" }}


[benchmark]

#
# From rally
#

# Time to sleep after creating a resource before polling for it status
# (floating point value)
# from .benchmark.rally.cinder_volume_create_prepoll_delay
{{ if not .benchmark.rally.cinder_volume_create_prepoll_delay }}#{{ end }}cinder_volume_create_prepoll_delay = {{ .benchmark.rally.cinder_volume_create_prepoll_delay | default "2.0" }}

# Time to wait for cinder volume to be created. (floating point value)
# from .benchmark.rally.cinder_volume_create_timeout
{{ if not .benchmark.rally.cinder_volume_create_timeout }}#{{ end }}cinder_volume_create_timeout = {{ .benchmark.rally.cinder_volume_create_timeout | default "600.0" }}

# Interval between checks when waiting for volume creation. (floating
# point value)
# from .benchmark.rally.cinder_volume_create_poll_interval
{{ if not .benchmark.rally.cinder_volume_create_poll_interval }}#{{ end }}cinder_volume_create_poll_interval = {{ .benchmark.rally.cinder_volume_create_poll_interval | default "2.0" }}

# Time to wait for cinder volume to be deleted. (floating point value)
# from .benchmark.rally.cinder_volume_delete_timeout
{{ if not .benchmark.rally.cinder_volume_delete_timeout }}#{{ end }}cinder_volume_delete_timeout = {{ .benchmark.rally.cinder_volume_delete_timeout | default "600.0" }}

# Interval between checks when waiting for volume deletion. (floating
# point value)
# from .benchmark.rally.cinder_volume_delete_poll_interval
{{ if not .benchmark.rally.cinder_volume_delete_poll_interval }}#{{ end }}cinder_volume_delete_poll_interval = {{ .benchmark.rally.cinder_volume_delete_poll_interval | default "2.0" }}

# Time to wait for cinder backup to be restored. (floating point
# value)
# from .benchmark.rally.cinder_backup_restore_timeout
{{ if not .benchmark.rally.cinder_backup_restore_timeout }}#{{ end }}cinder_backup_restore_timeout = {{ .benchmark.rally.cinder_backup_restore_timeout | default "600.0" }}

# Interval between checks when waiting for backup restoring. (floating
# point value)
# from .benchmark.rally.cinder_backup_restore_poll_interval
{{ if not .benchmark.rally.cinder_backup_restore_poll_interval }}#{{ end }}cinder_backup_restore_poll_interval = {{ .benchmark.rally.cinder_backup_restore_poll_interval | default "2.0" }}

# Time to sleep after boot before polling for status (floating point
# value)
# from .benchmark.rally.ec2_server_boot_prepoll_delay
{{ if not .benchmark.rally.ec2_server_boot_prepoll_delay }}#{{ end }}ec2_server_boot_prepoll_delay = {{ .benchmark.rally.ec2_server_boot_prepoll_delay | default "1.0" }}

# Server boot timeout (floating point value)
# from .benchmark.rally.ec2_server_boot_timeout
{{ if not .benchmark.rally.ec2_server_boot_timeout }}#{{ end }}ec2_server_boot_timeout = {{ .benchmark.rally.ec2_server_boot_timeout | default "300.0" }}

# Server boot poll interval (floating point value)
# from .benchmark.rally.ec2_server_boot_poll_interval
{{ if not .benchmark.rally.ec2_server_boot_poll_interval }}#{{ end }}ec2_server_boot_poll_interval = {{ .benchmark.rally.ec2_server_boot_poll_interval | default "1.0" }}

# Time to sleep after creating a resource before polling for it status
# (floating point value)
# from .benchmark.rally.glance_image_create_prepoll_delay
{{ if not .benchmark.rally.glance_image_create_prepoll_delay }}#{{ end }}glance_image_create_prepoll_delay = {{ .benchmark.rally.glance_image_create_prepoll_delay | default "2.0" }}

# Time to wait for glance image to be created. (floating point value)
# from .benchmark.rally.glance_image_create_timeout
{{ if not .benchmark.rally.glance_image_create_timeout }}#{{ end }}glance_image_create_timeout = {{ .benchmark.rally.glance_image_create_timeout | default "120.0" }}

# Interval between checks when waiting for image creation. (floating
# point value)
# from .benchmark.rally.glance_image_create_poll_interval
{{ if not .benchmark.rally.glance_image_create_poll_interval }}#{{ end }}glance_image_create_poll_interval = {{ .benchmark.rally.glance_image_create_poll_interval | default "1.0" }}

# Time(in sec) to sleep after creating a resource before polling for
# it status. (floating point value)
# from .benchmark.rally.heat_stack_create_prepoll_delay
{{ if not .benchmark.rally.heat_stack_create_prepoll_delay }}#{{ end }}heat_stack_create_prepoll_delay = {{ .benchmark.rally.heat_stack_create_prepoll_delay | default "2.0" }}

# Time(in sec) to wait for heat stack to be created. (floating point
# value)
# from .benchmark.rally.heat_stack_create_timeout
{{ if not .benchmark.rally.heat_stack_create_timeout }}#{{ end }}heat_stack_create_timeout = {{ .benchmark.rally.heat_stack_create_timeout | default "3600.0" }}

# Time interval(in sec) between checks when waiting for stack
# creation. (floating point value)
# from .benchmark.rally.heat_stack_create_poll_interval
{{ if not .benchmark.rally.heat_stack_create_poll_interval }}#{{ end }}heat_stack_create_poll_interval = {{ .benchmark.rally.heat_stack_create_poll_interval | default "1.0" }}

# Time(in sec) to wait for heat stack to be deleted. (floating point
# value)
# from .benchmark.rally.heat_stack_delete_timeout
{{ if not .benchmark.rally.heat_stack_delete_timeout }}#{{ end }}heat_stack_delete_timeout = {{ .benchmark.rally.heat_stack_delete_timeout | default "3600.0" }}

# Time interval(in sec) between checks when waiting for stack
# deletion. (floating point value)
# from .benchmark.rally.heat_stack_delete_poll_interval
{{ if not .benchmark.rally.heat_stack_delete_poll_interval }}#{{ end }}heat_stack_delete_poll_interval = {{ .benchmark.rally.heat_stack_delete_poll_interval | default "1.0" }}

# Time(in sec) to wait for stack to be checked. (floating point value)
# from .benchmark.rally.heat_stack_check_timeout
{{ if not .benchmark.rally.heat_stack_check_timeout }}#{{ end }}heat_stack_check_timeout = {{ .benchmark.rally.heat_stack_check_timeout | default "3600.0" }}

# Time interval(in sec) between checks when waiting for stack
# checking. (floating point value)
# from .benchmark.rally.heat_stack_check_poll_interval
{{ if not .benchmark.rally.heat_stack_check_poll_interval }}#{{ end }}heat_stack_check_poll_interval = {{ .benchmark.rally.heat_stack_check_poll_interval | default "1.0" }}

# Time(in sec) to sleep after updating a resource before polling for
# it status. (floating point value)
# from .benchmark.rally.heat_stack_update_prepoll_delay
{{ if not .benchmark.rally.heat_stack_update_prepoll_delay }}#{{ end }}heat_stack_update_prepoll_delay = {{ .benchmark.rally.heat_stack_update_prepoll_delay | default "2.0" }}

# Time(in sec) to wait for stack to be updated. (floating point value)
# from .benchmark.rally.heat_stack_update_timeout
{{ if not .benchmark.rally.heat_stack_update_timeout }}#{{ end }}heat_stack_update_timeout = {{ .benchmark.rally.heat_stack_update_timeout | default "3600.0" }}

# Time interval(in sec) between checks when waiting for stack update.
# (floating point value)
# from .benchmark.rally.heat_stack_update_poll_interval
{{ if not .benchmark.rally.heat_stack_update_poll_interval }}#{{ end }}heat_stack_update_poll_interval = {{ .benchmark.rally.heat_stack_update_poll_interval | default "1.0" }}

# Time(in sec) to wait for stack to be suspended. (floating point
# value)
# from .benchmark.rally.heat_stack_suspend_timeout
{{ if not .benchmark.rally.heat_stack_suspend_timeout }}#{{ end }}heat_stack_suspend_timeout = {{ .benchmark.rally.heat_stack_suspend_timeout | default "3600.0" }}

# Time interval(in sec) between checks when waiting for stack suspend.
# (floating point value)
# from .benchmark.rally.heat_stack_suspend_poll_interval
{{ if not .benchmark.rally.heat_stack_suspend_poll_interval }}#{{ end }}heat_stack_suspend_poll_interval = {{ .benchmark.rally.heat_stack_suspend_poll_interval | default "1.0" }}

# Time(in sec) to wait for stack to be resumed. (floating point value)
# from .benchmark.rally.heat_stack_resume_timeout
{{ if not .benchmark.rally.heat_stack_resume_timeout }}#{{ end }}heat_stack_resume_timeout = {{ .benchmark.rally.heat_stack_resume_timeout | default "3600.0" }}

# Time interval(in sec) between checks when waiting for stack resume.
# (floating point value)
# from .benchmark.rally.heat_stack_resume_poll_interval
{{ if not .benchmark.rally.heat_stack_resume_poll_interval }}#{{ end }}heat_stack_resume_poll_interval = {{ .benchmark.rally.heat_stack_resume_poll_interval | default "1.0" }}

# Time(in sec) to wait for stack snapshot to be created. (floating
# point value)
# from .benchmark.rally.heat_stack_snapshot_timeout
{{ if not .benchmark.rally.heat_stack_snapshot_timeout }}#{{ end }}heat_stack_snapshot_timeout = {{ .benchmark.rally.heat_stack_snapshot_timeout | default "3600.0" }}

# Time interval(in sec) between checks when waiting for stack snapshot
# to be created. (floating point value)
# from .benchmark.rally.heat_stack_snapshot_poll_interval
{{ if not .benchmark.rally.heat_stack_snapshot_poll_interval }}#{{ end }}heat_stack_snapshot_poll_interval = {{ .benchmark.rally.heat_stack_snapshot_poll_interval | default "1.0" }}

# Time(in sec) to wait for stack to be restored from snapshot.
# (floating point value)
# from .benchmark.rally.heat_stack_restore_timeout
{{ if not .benchmark.rally.heat_stack_restore_timeout }}#{{ end }}heat_stack_restore_timeout = {{ .benchmark.rally.heat_stack_restore_timeout | default "3600.0" }}

# Time interval(in sec) between checks when waiting for stack to be
# restored. (floating point value)
# from .benchmark.rally.heat_stack_restore_poll_interval
{{ if not .benchmark.rally.heat_stack_restore_poll_interval }}#{{ end }}heat_stack_restore_poll_interval = {{ .benchmark.rally.heat_stack_restore_poll_interval | default "1.0" }}

# Time (in sec) to wait for stack to scale up or down. (floating point
# value)
# from .benchmark.rally.heat_stack_scale_timeout
{{ if not .benchmark.rally.heat_stack_scale_timeout }}#{{ end }}heat_stack_scale_timeout = {{ .benchmark.rally.heat_stack_scale_timeout | default "3600.0" }}

# Time interval (in sec) between checks when waiting for a stack to
# scale up or down. (floating point value)
# from .benchmark.rally.heat_stack_scale_poll_interval
{{ if not .benchmark.rally.heat_stack_scale_poll_interval }}#{{ end }}heat_stack_scale_poll_interval = {{ .benchmark.rally.heat_stack_scale_poll_interval | default "1.0" }}

# Interval(in sec) between checks when waiting for node creation.
# (floating point value)
# from .benchmark.rally.ironic_node_create_poll_interval
{{ if not .benchmark.rally.ironic_node_create_poll_interval }}#{{ end }}ironic_node_create_poll_interval = {{ .benchmark.rally.ironic_node_create_poll_interval | default "1.0" }}

# Ironic node create timeout (floating point value)
# from .benchmark.rally.ironic_node_create_timeout
{{ if not .benchmark.rally.ironic_node_create_timeout }}#{{ end }}ironic_node_create_timeout = {{ .benchmark.rally.ironic_node_create_timeout | default "300" }}

# Ironic node poll interval (floating point value)
# from .benchmark.rally.ironic_node_poll_interval
{{ if not .benchmark.rally.ironic_node_poll_interval }}#{{ end }}ironic_node_poll_interval = {{ .benchmark.rally.ironic_node_poll_interval | default "1.0" }}

# Ironic node create timeout (floating point value)
# from .benchmark.rally.ironic_node_delete_timeout
{{ if not .benchmark.rally.ironic_node_delete_timeout }}#{{ end }}ironic_node_delete_timeout = {{ .benchmark.rally.ironic_node_delete_timeout | default "300" }}

# Time(in sec) to sleep after creating a resource before polling for
# the status. (floating point value)
# from .benchmark.rally.magnum_cluster_create_prepoll_delay
{{ if not .benchmark.rally.magnum_cluster_create_prepoll_delay }}#{{ end }}magnum_cluster_create_prepoll_delay = {{ .benchmark.rally.magnum_cluster_create_prepoll_delay | default "5.0" }}

# Time(in sec) to wait for magnum cluster to be created. (floating
# point value)
# from .benchmark.rally.magnum_cluster_create_timeout
{{ if not .benchmark.rally.magnum_cluster_create_timeout }}#{{ end }}magnum_cluster_create_timeout = {{ .benchmark.rally.magnum_cluster_create_timeout | default "1200.0" }}

# Time interval(in sec) between checks when waiting for cluster
# creation. (floating point value)
# from .benchmark.rally.magnum_cluster_create_poll_interval
{{ if not .benchmark.rally.magnum_cluster_create_poll_interval }}#{{ end }}magnum_cluster_create_poll_interval = {{ .benchmark.rally.magnum_cluster_create_poll_interval | default "1.0" }}

# Delay between creating Manila share and polling for its status.
# (floating point value)
# from .benchmark.rally.manila_share_create_prepoll_delay
{{ if not .benchmark.rally.manila_share_create_prepoll_delay }}#{{ end }}manila_share_create_prepoll_delay = {{ .benchmark.rally.manila_share_create_prepoll_delay | default "2.0" }}

# Timeout for Manila share creation. (floating point value)
# from .benchmark.rally.manila_share_create_timeout
{{ if not .benchmark.rally.manila_share_create_timeout }}#{{ end }}manila_share_create_timeout = {{ .benchmark.rally.manila_share_create_timeout | default "300.0" }}

# Interval between checks when waiting for Manila share creation.
# (floating point value)
# from .benchmark.rally.manila_share_create_poll_interval
{{ if not .benchmark.rally.manila_share_create_poll_interval }}#{{ end }}manila_share_create_poll_interval = {{ .benchmark.rally.manila_share_create_poll_interval | default "3.0" }}

# Timeout for Manila share deletion. (floating point value)
# from .benchmark.rally.manila_share_delete_timeout
{{ if not .benchmark.rally.manila_share_delete_timeout }}#{{ end }}manila_share_delete_timeout = {{ .benchmark.rally.manila_share_delete_timeout | default "180.0" }}

# Interval between checks when waiting for Manila share deletion.
# (floating point value)
# from .benchmark.rally.manila_share_delete_poll_interval
{{ if not .benchmark.rally.manila_share_delete_poll_interval }}#{{ end }}manila_share_delete_poll_interval = {{ .benchmark.rally.manila_share_delete_poll_interval | default "2.0" }}

# mistral execution timeout (integer value)
# from .benchmark.rally.mistral_execution_timeout
{{ if not .benchmark.rally.mistral_execution_timeout }}#{{ end }}mistral_execution_timeout = {{ .benchmark.rally.mistral_execution_timeout | default "200" }}

# Delay between creating Monasca metrics and polling for its elements.
# (floating point value)
# from .benchmark.rally.monasca_metric_create_prepoll_delay
{{ if not .benchmark.rally.monasca_metric_create_prepoll_delay }}#{{ end }}monasca_metric_create_prepoll_delay = {{ .benchmark.rally.monasca_metric_create_prepoll_delay | default "15.0" }}

# A timeout in seconds for an environment deploy (integer value)
# Deprecated group/name - [benchmark]/deploy_environment_timeout
# from .benchmark.rally.murano_deploy_environment_timeout
{{ if not .benchmark.rally.murano_deploy_environment_timeout }}#{{ end }}murano_deploy_environment_timeout = {{ .benchmark.rally.murano_deploy_environment_timeout | default "1200" }}

# Deploy environment check interval in seconds (integer value)
# Deprecated group/name - [benchmark]/deploy_environment_check_interval
# from .benchmark.rally.murano_deploy_environment_check_interval
{{ if not .benchmark.rally.murano_deploy_environment_check_interval }}#{{ end }}murano_deploy_environment_check_interval = {{ .benchmark.rally.murano_deploy_environment_check_interval | default "5" }}

# Time to sleep after start before polling for status (floating point
# value)
# from .benchmark.rally.nova_server_start_prepoll_delay
{{ if not .benchmark.rally.nova_server_start_prepoll_delay }}#{{ end }}nova_server_start_prepoll_delay = {{ .benchmark.rally.nova_server_start_prepoll_delay | default "0.0" }}

# Server start timeout (floating point value)
# from .benchmark.rally.nova_server_start_timeout
{{ if not .benchmark.rally.nova_server_start_timeout }}#{{ end }}nova_server_start_timeout = {{ .benchmark.rally.nova_server_start_timeout | default "300.0" }}

# Server start poll interval (floating point value)
# from .benchmark.rally.nova_server_start_poll_interval
{{ if not .benchmark.rally.nova_server_start_poll_interval }}#{{ end }}nova_server_start_poll_interval = {{ .benchmark.rally.nova_server_start_poll_interval | default "1.0" }}

# Time to sleep after stop before polling for status (floating point
# value)
# from .benchmark.rally.nova_server_stop_prepoll_delay
{{ if not .benchmark.rally.nova_server_stop_prepoll_delay }}#{{ end }}nova_server_stop_prepoll_delay = {{ .benchmark.rally.nova_server_stop_prepoll_delay | default "0.0" }}

# Server stop timeout (floating point value)
# from .benchmark.rally.nova_server_stop_timeout
{{ if not .benchmark.rally.nova_server_stop_timeout }}#{{ end }}nova_server_stop_timeout = {{ .benchmark.rally.nova_server_stop_timeout | default "300.0" }}

# Server stop poll interval (floating point value)
# from .benchmark.rally.nova_server_stop_poll_interval
{{ if not .benchmark.rally.nova_server_stop_poll_interval }}#{{ end }}nova_server_stop_poll_interval = {{ .benchmark.rally.nova_server_stop_poll_interval | default "2.0" }}

# Time to sleep after boot before polling for status (floating point
# value)
# from .benchmark.rally.nova_server_boot_prepoll_delay
{{ if not .benchmark.rally.nova_server_boot_prepoll_delay }}#{{ end }}nova_server_boot_prepoll_delay = {{ .benchmark.rally.nova_server_boot_prepoll_delay | default "1.0" }}

# Server boot timeout (floating point value)
# from .benchmark.rally.nova_server_boot_timeout
{{ if not .benchmark.rally.nova_server_boot_timeout }}#{{ end }}nova_server_boot_timeout = {{ .benchmark.rally.nova_server_boot_timeout | default "300.0" }}

# Server boot poll interval (floating point value)
# from .benchmark.rally.nova_server_boot_poll_interval
{{ if not .benchmark.rally.nova_server_boot_poll_interval }}#{{ end }}nova_server_boot_poll_interval = {{ .benchmark.rally.nova_server_boot_poll_interval | default "1.0" }}

# Time to sleep after delete before polling for status (floating point
# value)
# from .benchmark.rally.nova_server_delete_prepoll_delay
{{ if not .benchmark.rally.nova_server_delete_prepoll_delay }}#{{ end }}nova_server_delete_prepoll_delay = {{ .benchmark.rally.nova_server_delete_prepoll_delay | default "2.0" }}

# Server delete timeout (floating point value)
# from .benchmark.rally.nova_server_delete_timeout
{{ if not .benchmark.rally.nova_server_delete_timeout }}#{{ end }}nova_server_delete_timeout = {{ .benchmark.rally.nova_server_delete_timeout | default "300.0" }}

# Server delete poll interval (floating point value)
# from .benchmark.rally.nova_server_delete_poll_interval
{{ if not .benchmark.rally.nova_server_delete_poll_interval }}#{{ end }}nova_server_delete_poll_interval = {{ .benchmark.rally.nova_server_delete_poll_interval | default "2.0" }}

# Time to sleep after reboot before polling for status (floating point
# value)
# from .benchmark.rally.nova_server_reboot_prepoll_delay
{{ if not .benchmark.rally.nova_server_reboot_prepoll_delay }}#{{ end }}nova_server_reboot_prepoll_delay = {{ .benchmark.rally.nova_server_reboot_prepoll_delay | default "2.0" }}

# Server reboot timeout (floating point value)
# from .benchmark.rally.nova_server_reboot_timeout
{{ if not .benchmark.rally.nova_server_reboot_timeout }}#{{ end }}nova_server_reboot_timeout = {{ .benchmark.rally.nova_server_reboot_timeout | default "300.0" }}

# Server reboot poll interval (floating point value)
# from .benchmark.rally.nova_server_reboot_poll_interval
{{ if not .benchmark.rally.nova_server_reboot_poll_interval }}#{{ end }}nova_server_reboot_poll_interval = {{ .benchmark.rally.nova_server_reboot_poll_interval | default "2.0" }}

# Time to sleep after rebuild before polling for status (floating
# point value)
# from .benchmark.rally.nova_server_rebuild_prepoll_delay
{{ if not .benchmark.rally.nova_server_rebuild_prepoll_delay }}#{{ end }}nova_server_rebuild_prepoll_delay = {{ .benchmark.rally.nova_server_rebuild_prepoll_delay | default "1.0" }}

# Server rebuild timeout (floating point value)
# from .benchmark.rally.nova_server_rebuild_timeout
{{ if not .benchmark.rally.nova_server_rebuild_timeout }}#{{ end }}nova_server_rebuild_timeout = {{ .benchmark.rally.nova_server_rebuild_timeout | default "300.0" }}

# Server rebuild poll interval (floating point value)
# from .benchmark.rally.nova_server_rebuild_poll_interval
{{ if not .benchmark.rally.nova_server_rebuild_poll_interval }}#{{ end }}nova_server_rebuild_poll_interval = {{ .benchmark.rally.nova_server_rebuild_poll_interval | default "1.0" }}

# Time to sleep after rescue before polling for status (floating point
# value)
# from .benchmark.rally.nova_server_rescue_prepoll_delay
{{ if not .benchmark.rally.nova_server_rescue_prepoll_delay }}#{{ end }}nova_server_rescue_prepoll_delay = {{ .benchmark.rally.nova_server_rescue_prepoll_delay | default "2.0" }}

# Server rescue timeout (floating point value)
# from .benchmark.rally.nova_server_rescue_timeout
{{ if not .benchmark.rally.nova_server_rescue_timeout }}#{{ end }}nova_server_rescue_timeout = {{ .benchmark.rally.nova_server_rescue_timeout | default "300.0" }}

# Server rescue poll interval (floating point value)
# from .benchmark.rally.nova_server_rescue_poll_interval
{{ if not .benchmark.rally.nova_server_rescue_poll_interval }}#{{ end }}nova_server_rescue_poll_interval = {{ .benchmark.rally.nova_server_rescue_poll_interval | default "2.0" }}

# Time to sleep after unrescue before polling for status (floating
# point value)
# from .benchmark.rally.nova_server_unrescue_prepoll_delay
{{ if not .benchmark.rally.nova_server_unrescue_prepoll_delay }}#{{ end }}nova_server_unrescue_prepoll_delay = {{ .benchmark.rally.nova_server_unrescue_prepoll_delay | default "2.0" }}

# Server unrescue timeout (floating point value)
# from .benchmark.rally.nova_server_unrescue_timeout
{{ if not .benchmark.rally.nova_server_unrescue_timeout }}#{{ end }}nova_server_unrescue_timeout = {{ .benchmark.rally.nova_server_unrescue_timeout | default "300.0" }}

# Server unrescue poll interval (floating point value)
# from .benchmark.rally.nova_server_unrescue_poll_interval
{{ if not .benchmark.rally.nova_server_unrescue_poll_interval }}#{{ end }}nova_server_unrescue_poll_interval = {{ .benchmark.rally.nova_server_unrescue_poll_interval | default "2.0" }}

# Time to sleep after suspend before polling for status (floating
# point value)
# from .benchmark.rally.nova_server_suspend_prepoll_delay
{{ if not .benchmark.rally.nova_server_suspend_prepoll_delay }}#{{ end }}nova_server_suspend_prepoll_delay = {{ .benchmark.rally.nova_server_suspend_prepoll_delay | default "2.0" }}

# Server suspend timeout (floating point value)
# from .benchmark.rally.nova_server_suspend_timeout
{{ if not .benchmark.rally.nova_server_suspend_timeout }}#{{ end }}nova_server_suspend_timeout = {{ .benchmark.rally.nova_server_suspend_timeout | default "300.0" }}

# Server suspend poll interval (floating point value)
# from .benchmark.rally.nova_server_suspend_poll_interval
{{ if not .benchmark.rally.nova_server_suspend_poll_interval }}#{{ end }}nova_server_suspend_poll_interval = {{ .benchmark.rally.nova_server_suspend_poll_interval | default "2.0" }}

# Time to sleep after resume before polling for status (floating point
# value)
# from .benchmark.rally.nova_server_resume_prepoll_delay
{{ if not .benchmark.rally.nova_server_resume_prepoll_delay }}#{{ end }}nova_server_resume_prepoll_delay = {{ .benchmark.rally.nova_server_resume_prepoll_delay | default "2.0" }}

# Server resume timeout (floating point value)
# from .benchmark.rally.nova_server_resume_timeout
{{ if not .benchmark.rally.nova_server_resume_timeout }}#{{ end }}nova_server_resume_timeout = {{ .benchmark.rally.nova_server_resume_timeout | default "300.0" }}

# Server resume poll interval (floating point value)
# from .benchmark.rally.nova_server_resume_poll_interval
{{ if not .benchmark.rally.nova_server_resume_poll_interval }}#{{ end }}nova_server_resume_poll_interval = {{ .benchmark.rally.nova_server_resume_poll_interval | default "2.0" }}

# Time to sleep after pause before polling for status (floating point
# value)
# from .benchmark.rally.nova_server_pause_prepoll_delay
{{ if not .benchmark.rally.nova_server_pause_prepoll_delay }}#{{ end }}nova_server_pause_prepoll_delay = {{ .benchmark.rally.nova_server_pause_prepoll_delay | default "2.0" }}

# Server pause timeout (floating point value)
# from .benchmark.rally.nova_server_pause_timeout
{{ if not .benchmark.rally.nova_server_pause_timeout }}#{{ end }}nova_server_pause_timeout = {{ .benchmark.rally.nova_server_pause_timeout | default "300.0" }}

# Server pause poll interval (floating point value)
# from .benchmark.rally.nova_server_pause_poll_interval
{{ if not .benchmark.rally.nova_server_pause_poll_interval }}#{{ end }}nova_server_pause_poll_interval = {{ .benchmark.rally.nova_server_pause_poll_interval | default "2.0" }}

# Time to sleep after unpause before polling for status (floating
# point value)
# from .benchmark.rally.nova_server_unpause_prepoll_delay
{{ if not .benchmark.rally.nova_server_unpause_prepoll_delay }}#{{ end }}nova_server_unpause_prepoll_delay = {{ .benchmark.rally.nova_server_unpause_prepoll_delay | default "2.0" }}

# Server unpause timeout (floating point value)
# from .benchmark.rally.nova_server_unpause_timeout
{{ if not .benchmark.rally.nova_server_unpause_timeout }}#{{ end }}nova_server_unpause_timeout = {{ .benchmark.rally.nova_server_unpause_timeout | default "300.0" }}

# Server unpause poll interval (floating point value)
# from .benchmark.rally.nova_server_unpause_poll_interval
{{ if not .benchmark.rally.nova_server_unpause_poll_interval }}#{{ end }}nova_server_unpause_poll_interval = {{ .benchmark.rally.nova_server_unpause_poll_interval | default "2.0" }}

# Time to sleep after shelve before polling for status (floating point
# value)
# from .benchmark.rally.nova_server_shelve_prepoll_delay
{{ if not .benchmark.rally.nova_server_shelve_prepoll_delay }}#{{ end }}nova_server_shelve_prepoll_delay = {{ .benchmark.rally.nova_server_shelve_prepoll_delay | default "2.0" }}

# Server shelve timeout (floating point value)
# from .benchmark.rally.nova_server_shelve_timeout
{{ if not .benchmark.rally.nova_server_shelve_timeout }}#{{ end }}nova_server_shelve_timeout = {{ .benchmark.rally.nova_server_shelve_timeout | default "300.0" }}

# Server shelve poll interval (floating point value)
# from .benchmark.rally.nova_server_shelve_poll_interval
{{ if not .benchmark.rally.nova_server_shelve_poll_interval }}#{{ end }}nova_server_shelve_poll_interval = {{ .benchmark.rally.nova_server_shelve_poll_interval | default "2.0" }}

# Time to sleep after unshelve before polling for status (floating
# point value)
# from .benchmark.rally.nova_server_unshelve_prepoll_delay
{{ if not .benchmark.rally.nova_server_unshelve_prepoll_delay }}#{{ end }}nova_server_unshelve_prepoll_delay = {{ .benchmark.rally.nova_server_unshelve_prepoll_delay | default "2.0" }}

# Server unshelve timeout (floating point value)
# from .benchmark.rally.nova_server_unshelve_timeout
{{ if not .benchmark.rally.nova_server_unshelve_timeout }}#{{ end }}nova_server_unshelve_timeout = {{ .benchmark.rally.nova_server_unshelve_timeout | default "300.0" }}

# Server unshelve poll interval (floating point value)
# from .benchmark.rally.nova_server_unshelve_poll_interval
{{ if not .benchmark.rally.nova_server_unshelve_poll_interval }}#{{ end }}nova_server_unshelve_poll_interval = {{ .benchmark.rally.nova_server_unshelve_poll_interval | default "2.0" }}

# Time to sleep after image_create before polling for status (floating
# point value)
# from .benchmark.rally.nova_server_image_create_prepoll_delay
{{ if not .benchmark.rally.nova_server_image_create_prepoll_delay }}#{{ end }}nova_server_image_create_prepoll_delay = {{ .benchmark.rally.nova_server_image_create_prepoll_delay | default "0.0" }}

# Server image_create timeout (floating point value)
# from .benchmark.rally.nova_server_image_create_timeout
{{ if not .benchmark.rally.nova_server_image_create_timeout }}#{{ end }}nova_server_image_create_timeout = {{ .benchmark.rally.nova_server_image_create_timeout | default "300.0" }}

# Server image_create poll interval (floating point value)
# from .benchmark.rally.nova_server_image_create_poll_interval
{{ if not .benchmark.rally.nova_server_image_create_poll_interval }}#{{ end }}nova_server_image_create_poll_interval = {{ .benchmark.rally.nova_server_image_create_poll_interval | default "2.0" }}

# Time to sleep after image_delete before polling for status (floating
# point value)
# from .benchmark.rally.nova_server_image_delete_prepoll_delay
{{ if not .benchmark.rally.nova_server_image_delete_prepoll_delay }}#{{ end }}nova_server_image_delete_prepoll_delay = {{ .benchmark.rally.nova_server_image_delete_prepoll_delay | default "0.0" }}

# Server image_delete timeout (floating point value)
# from .benchmark.rally.nova_server_image_delete_timeout
{{ if not .benchmark.rally.nova_server_image_delete_timeout }}#{{ end }}nova_server_image_delete_timeout = {{ .benchmark.rally.nova_server_image_delete_timeout | default "300.0" }}

# Server image_delete poll interval (floating point value)
# from .benchmark.rally.nova_server_image_delete_poll_interval
{{ if not .benchmark.rally.nova_server_image_delete_poll_interval }}#{{ end }}nova_server_image_delete_poll_interval = {{ .benchmark.rally.nova_server_image_delete_poll_interval | default "2.0" }}

# Time to sleep after resize before polling for status (floating point
# value)
# from .benchmark.rally.nova_server_resize_prepoll_delay
{{ if not .benchmark.rally.nova_server_resize_prepoll_delay }}#{{ end }}nova_server_resize_prepoll_delay = {{ .benchmark.rally.nova_server_resize_prepoll_delay | default "2.0" }}

# Server resize timeout (floating point value)
# from .benchmark.rally.nova_server_resize_timeout
{{ if not .benchmark.rally.nova_server_resize_timeout }}#{{ end }}nova_server_resize_timeout = {{ .benchmark.rally.nova_server_resize_timeout | default "400.0" }}

# Server resize poll interval (floating point value)
# from .benchmark.rally.nova_server_resize_poll_interval
{{ if not .benchmark.rally.nova_server_resize_poll_interval }}#{{ end }}nova_server_resize_poll_interval = {{ .benchmark.rally.nova_server_resize_poll_interval | default "5.0" }}

# Time to sleep after resize_confirm before polling for status
# (floating point value)
# from .benchmark.rally.nova_server_resize_confirm_prepoll_delay
{{ if not .benchmark.rally.nova_server_resize_confirm_prepoll_delay }}#{{ end }}nova_server_resize_confirm_prepoll_delay = {{ .benchmark.rally.nova_server_resize_confirm_prepoll_delay | default "0.0" }}

# Server resize_confirm timeout (floating point value)
# from .benchmark.rally.nova_server_resize_confirm_timeout
{{ if not .benchmark.rally.nova_server_resize_confirm_timeout }}#{{ end }}nova_server_resize_confirm_timeout = {{ .benchmark.rally.nova_server_resize_confirm_timeout | default "200.0" }}

# Server resize_confirm poll interval (floating point value)
# from .benchmark.rally.nova_server_resize_confirm_poll_interval
{{ if not .benchmark.rally.nova_server_resize_confirm_poll_interval }}#{{ end }}nova_server_resize_confirm_poll_interval = {{ .benchmark.rally.nova_server_resize_confirm_poll_interval | default "2.0" }}

# Time to sleep after resize_revert before polling for status
# (floating point value)
# from .benchmark.rally.nova_server_resize_revert_prepoll_delay
{{ if not .benchmark.rally.nova_server_resize_revert_prepoll_delay }}#{{ end }}nova_server_resize_revert_prepoll_delay = {{ .benchmark.rally.nova_server_resize_revert_prepoll_delay | default "0.0" }}

# Server resize_revert timeout (floating point value)
# from .benchmark.rally.nova_server_resize_revert_timeout
{{ if not .benchmark.rally.nova_server_resize_revert_timeout }}#{{ end }}nova_server_resize_revert_timeout = {{ .benchmark.rally.nova_server_resize_revert_timeout | default "200.0" }}

# Server resize_revert poll interval (floating point value)
# from .benchmark.rally.nova_server_resize_revert_poll_interval
{{ if not .benchmark.rally.nova_server_resize_revert_poll_interval }}#{{ end }}nova_server_resize_revert_poll_interval = {{ .benchmark.rally.nova_server_resize_revert_poll_interval | default "2.0" }}

# Time to sleep after live_migrate before polling for status (floating
# point value)
# from .benchmark.rally.nova_server_live_migrate_prepoll_delay
{{ if not .benchmark.rally.nova_server_live_migrate_prepoll_delay }}#{{ end }}nova_server_live_migrate_prepoll_delay = {{ .benchmark.rally.nova_server_live_migrate_prepoll_delay | default "1.0" }}

# Server live_migrate timeout (floating point value)
# from .benchmark.rally.nova_server_live_migrate_timeout
{{ if not .benchmark.rally.nova_server_live_migrate_timeout }}#{{ end }}nova_server_live_migrate_timeout = {{ .benchmark.rally.nova_server_live_migrate_timeout | default "400.0" }}

# Server live_migrate poll interval (floating point value)
# from .benchmark.rally.nova_server_live_migrate_poll_interval
{{ if not .benchmark.rally.nova_server_live_migrate_poll_interval }}#{{ end }}nova_server_live_migrate_poll_interval = {{ .benchmark.rally.nova_server_live_migrate_poll_interval | default "2.0" }}

# Time to sleep after migrate before polling for status (floating
# point value)
# from .benchmark.rally.nova_server_migrate_prepoll_delay
{{ if not .benchmark.rally.nova_server_migrate_prepoll_delay }}#{{ end }}nova_server_migrate_prepoll_delay = {{ .benchmark.rally.nova_server_migrate_prepoll_delay | default "1.0" }}

# Server migrate timeout (floating point value)
# from .benchmark.rally.nova_server_migrate_timeout
{{ if not .benchmark.rally.nova_server_migrate_timeout }}#{{ end }}nova_server_migrate_timeout = {{ .benchmark.rally.nova_server_migrate_timeout | default "400.0" }}

# Server migrate poll interval (floating point value)
# from .benchmark.rally.nova_server_migrate_poll_interval
{{ if not .benchmark.rally.nova_server_migrate_poll_interval }}#{{ end }}nova_server_migrate_poll_interval = {{ .benchmark.rally.nova_server_migrate_poll_interval | default "2.0" }}

# Nova volume detach timeout (floating point value)
# from .benchmark.rally.nova_detach_volume_timeout
{{ if not .benchmark.rally.nova_detach_volume_timeout }}#{{ end }}nova_detach_volume_timeout = {{ .benchmark.rally.nova_detach_volume_timeout | default "200.0" }}

# Nova volume detach poll interval (floating point value)
# from .benchmark.rally.nova_detach_volume_poll_interval
{{ if not .benchmark.rally.nova_detach_volume_poll_interval }}#{{ end }}nova_detach_volume_poll_interval = {{ .benchmark.rally.nova_detach_volume_poll_interval | default "2.0" }}

# A timeout in seconds for a cluster create operation (integer value)
# Deprecated group/name - [benchmark]/cluster_create_timeout
# from .benchmark.rally.sahara_cluster_create_timeout
{{ if not .benchmark.rally.sahara_cluster_create_timeout }}#{{ end }}sahara_cluster_create_timeout = {{ .benchmark.rally.sahara_cluster_create_timeout | default "1800" }}

# A timeout in seconds for a cluster delete operation (integer value)
# Deprecated group/name - [benchmark]/cluster_delete_timeout
# from .benchmark.rally.sahara_cluster_delete_timeout
{{ if not .benchmark.rally.sahara_cluster_delete_timeout }}#{{ end }}sahara_cluster_delete_timeout = {{ .benchmark.rally.sahara_cluster_delete_timeout | default "900" }}

# Cluster status polling interval in seconds (integer value)
# Deprecated group/name - [benchmark]/cluster_check_interval
# from .benchmark.rally.sahara_cluster_check_interval
{{ if not .benchmark.rally.sahara_cluster_check_interval }}#{{ end }}sahara_cluster_check_interval = {{ .benchmark.rally.sahara_cluster_check_interval | default "5" }}

# A timeout in seconds for a Job Execution to complete (integer value)
# Deprecated group/name - [benchmark]/job_execution_timeout
# from .benchmark.rally.sahara_job_execution_timeout
{{ if not .benchmark.rally.sahara_job_execution_timeout }}#{{ end }}sahara_job_execution_timeout = {{ .benchmark.rally.sahara_job_execution_timeout | default "600" }}

# Job Execution status polling interval in seconds (integer value)
# Deprecated group/name - [benchmark]/job_check_interval
# from .benchmark.rally.sahara_job_check_interval
{{ if not .benchmark.rally.sahara_job_check_interval }}#{{ end }}sahara_job_check_interval = {{ .benchmark.rally.sahara_job_check_interval | default "5" }}

# Amount of workers one proxy should serve to. (integer value)
# from .benchmark.rally.sahara_workers_per_proxy
{{ if not .benchmark.rally.sahara_workers_per_proxy }}#{{ end }}sahara_workers_per_proxy = {{ .benchmark.rally.sahara_workers_per_proxy | default "20" }}

# Interval between checks when waiting for a VM to become pingable
# (floating point value)
# from .benchmark.rally.vm_ping_poll_interval
{{ if not .benchmark.rally.vm_ping_poll_interval }}#{{ end }}vm_ping_poll_interval = {{ .benchmark.rally.vm_ping_poll_interval | default "1.0" }}

# Time to wait for a VM to become pingable (floating point value)
# from .benchmark.rally.vm_ping_timeout
{{ if not .benchmark.rally.vm_ping_timeout }}#{{ end }}vm_ping_timeout = {{ .benchmark.rally.vm_ping_timeout | default "120.0" }}

# Watcher audit launch interval (floating point value)
# from .benchmark.rally.watcher_audit_launch_poll_interval
{{ if not .benchmark.rally.watcher_audit_launch_poll_interval }}#{{ end }}watcher_audit_launch_poll_interval = {{ .benchmark.rally.watcher_audit_launch_poll_interval | default "2.0" }}

# Watcher audit launch timeout (integer value)
# from .benchmark.rally.watcher_audit_launch_timeout
{{ if not .benchmark.rally.watcher_audit_launch_timeout }}#{{ end }}watcher_audit_launch_timeout = {{ .benchmark.rally.watcher_audit_launch_timeout | default "300" }}


[cleanup]

#
# From rally
#

# A timeout in seconds for deleting resources (integer value)
# from .cleanup.rally.resource_deletion_timeout
{{ if not .cleanup.rally.resource_deletion_timeout }}#{{ end }}resource_deletion_timeout = {{ .cleanup.rally.resource_deletion_timeout | default "600" }}

# Number of cleanup threads to run (integer value)
# from .cleanup.rally.cleanup_threads
{{ if not .cleanup.rally.cleanup_threads }}#{{ end }}cleanup_threads = {{ .cleanup.rally.cleanup_threads | default "20" }}


[database]

#
# From oslo.db
#

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

# If True, transparently enables support for handling MySQL Cluster
# (NDB). (boolean value)
# from .database.oslo.db.mysql_enable_ndb
{{ if not .database.oslo.db.mysql_enable_ndb }}#{{ end }}mysql_enable_ndb = {{ .database.oslo.db.mysql_enable_ndb | default "false" }}

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


[roles_context]

#
# From rally
#

# How many concurrent threads to use for serving roles context
# (integer value)
# from .roles_context.rally.resource_management_workers
{{ if not .roles_context.rally.resource_management_workers }}#{{ end }}resource_management_workers = {{ .roles_context.rally.resource_management_workers | default "30" }}


[tempest]

#
# From rally
#

# image URL (string value)
# from .tempest.rally.img_url
{{ if not .tempest.rally.img_url }}#{{ end }}img_url = {{ .tempest.rally.img_url | default "http://download.cirros-cloud.net/0.3.5/cirros-0.3.5-x86_64-disk.img" }}

# Image disk format to use when creating the image (string value)
# from .tempest.rally.img_disk_format
{{ if not .tempest.rally.img_disk_format }}#{{ end }}img_disk_format = {{ .tempest.rally.img_disk_format | default "qcow2" }}

# Image container format to use when creating the image (string value)
# from .tempest.rally.img_container_format
{{ if not .tempest.rally.img_container_format }}#{{ end }}img_container_format = {{ .tempest.rally.img_container_format | default "bare" }}

# Regular expression for name of a public image to discover it in the
# cloud and use it for the tests. Note that when Rally is searching
# for the image, case insensitive matching is performed. Specify
# nothing ('img_name_regex =') if you want to disable discovering. In
# this case Rally will create needed resources by itself if the values
# for the corresponding config options are not specified in the
# Tempest config file (string value)
# from .tempest.rally.img_name_regex
{{ if not .tempest.rally.img_name_regex }}#{{ end }}img_name_regex = {{ .tempest.rally.img_name_regex | default "^.*(cirros|testvm).*$" }}

# Role required for users to be able to create Swift containers
# (string value)
# from .tempest.rally.swift_operator_role
{{ if not .tempest.rally.swift_operator_role }}#{{ end }}swift_operator_role = {{ .tempest.rally.swift_operator_role | default "Member" }}

# User role that has reseller admin (string value)
# from .tempest.rally.swift_reseller_admin_role
{{ if not .tempest.rally.swift_reseller_admin_role }}#{{ end }}swift_reseller_admin_role = {{ .tempest.rally.swift_reseller_admin_role | default "ResellerAdmin" }}

# Role required for users to be able to manage Heat stacks (string
# value)
# from .tempest.rally.heat_stack_owner_role
{{ if not .tempest.rally.heat_stack_owner_role }}#{{ end }}heat_stack_owner_role = {{ .tempest.rally.heat_stack_owner_role | default "heat_stack_owner" }}

# Role for Heat template-defined users (string value)
# from .tempest.rally.heat_stack_user_role
{{ if not .tempest.rally.heat_stack_user_role }}#{{ end }}heat_stack_user_role = {{ .tempest.rally.heat_stack_user_role | default "heat_stack_user" }}

# Primary flavor RAM size used by most of the test cases (integer
# value)
# from .tempest.rally.flavor_ref_ram
{{ if not .tempest.rally.flavor_ref_ram }}#{{ end }}flavor_ref_ram = {{ .tempest.rally.flavor_ref_ram | default "64" }}

# Alternate reference flavor RAM size used by test thatneed two
# flavors, like those that resize an instance (integer value)
# from .tempest.rally.flavor_ref_alt_ram
{{ if not .tempest.rally.flavor_ref_alt_ram }}#{{ end }}flavor_ref_alt_ram = {{ .tempest.rally.flavor_ref_alt_ram | default "128" }}

# RAM size flavor used for orchestration test cases (integer value)
# from .tempest.rally.heat_instance_type_ram
{{ if not .tempest.rally.heat_instance_type_ram }}#{{ end }}heat_instance_type_ram = {{ .tempest.rally.heat_instance_type_ram | default "64" }}


[users_context]

#
# From rally
#

# The number of concurrent threads to use for serving users context.
# (integer value)
# from .users_context.rally.resource_management_workers
{{ if not .users_context.rally.resource_management_workers }}#{{ end }}resource_management_workers = {{ .users_context.rally.resource_management_workers | default "20" }}

# ID of domain in which projects will be created. (string value)
# from .users_context.rally.project_domain
{{ if not .users_context.rally.project_domain }}#{{ end }}project_domain = {{ .users_context.rally.project_domain | default "default" }}

# ID of domain in which users will be created. (string value)
# from .users_context.rally.user_domain
{{ if not .users_context.rally.user_domain }}#{{ end }}user_domain = {{ .users_context.rally.user_domain | default "default" }}

# The default role name of the keystone to assign to users. (string
# value)
# from .users_context.rally.keystone_default_role
{{ if not .users_context.rally.keystone_default_role }}#{{ end }}keystone_default_role = {{ .users_context.rally.keystone_default_role | default "member" }}

{{- end -}}
