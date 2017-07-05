# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

{{ include "barbican.conf.barbican_values_skeleton" .Values.conf.barbican | trunc 0 }}
{{ include "barbican.conf.barbican" .Values.conf.barbican }}


{{- define "barbican.conf.barbican_values_skeleton" -}}

{{- if not .default -}}{{- set . "default" dict -}}{{- end -}}
{{- if not .default.barbican -}}{{- set .default "barbican" dict -}}{{- end -}}
{{- if not .default.barbican.common -}}{{- set .default.barbican "common" dict -}}{{- end -}}
{{- if not .default.barbican.common.config -}}{{- set .default.barbican.common "config" dict -}}{{- end -}}
{{- if not .default.oslo -}}{{- set .default "oslo" dict -}}{{- end -}}
{{- if not .default.oslo.log -}}{{- set .default.oslo "log" dict -}}{{- end -}}
{{- if not .default.oslo.messaging -}}{{- set .default.oslo "messaging" dict -}}{{- end -}}
{{- if not .default.oslo.service -}}{{- set .default.oslo "service" dict -}}{{- end -}}
{{- if not .default.oslo.service.periodic_task -}}{{- set .default.oslo.service "periodic_task" dict -}}{{- end -}}
{{- if not .default.oslo.service.wsgi -}}{{- set .default.oslo.service "wsgi" dict -}}{{- end -}}
{{- if not .certificate -}}{{- set . "certificate" dict -}}{{- end -}}
{{- if not .certificate.barbican -}}{{- set .certificate "barbican" dict -}}{{- end -}}
{{- if not .certificate.barbican.certificate -}}{{- set .certificate.barbican "certificate" dict -}}{{- end -}}
{{- if not .certificate.barbican.certificate.plugin -}}{{- set .certificate.barbican.certificate "plugin" dict -}}{{- end -}}
{{- if not .certificate_event -}}{{- set . "certificate_event" dict -}}{{- end -}}
{{- if not .certificate_event.barbican -}}{{- set .certificate_event "barbican" dict -}}{{- end -}}
{{- if not .certificate_event.barbican.certificate -}}{{- set .certificate_event.barbican "certificate" dict -}}{{- end -}}
{{- if not .certificate_event.barbican.certificate.plugin -}}{{- set .certificate_event.barbican.certificate "plugin" dict -}}{{- end -}}
{{- if not .cors -}}{{- set . "cors" dict -}}{{- end -}}
{{- if not .cors.oslo -}}{{- set .cors "oslo" dict -}}{{- end -}}
{{- if not .cors.oslo.middleware -}}{{- set .cors.oslo "middleware" dict -}}{{- end -}}
{{- if not .cors.oslo.middleware.cors -}}{{- set .cors.oslo.middleware "cors" dict -}}{{- end -}}
{{- if not .cors.subdomain -}}{{- set .cors "subdomain" dict -}}{{- end -}}
{{- if not .cors.subdomain.oslo -}}{{- set .cors.subdomain "oslo" dict -}}{{- end -}}
{{- if not .cors.subdomain.oslo.middleware -}}{{- set .cors.subdomain.oslo "middleware" dict -}}{{- end -}}
{{- if not .cors.subdomain.oslo.middleware.cors -}}{{- set .cors.subdomain.oslo.middleware "cors" dict -}}{{- end -}}
{{- if not .crypto -}}{{- set . "crypto" dict -}}{{- end -}}
{{- if not .crypto.barbican -}}{{- set .crypto "barbican" dict -}}{{- end -}}
{{- if not .crypto.barbican.plugin -}}{{- set .crypto.barbican "plugin" dict -}}{{- end -}}
{{- if not .crypto.barbican.plugin.crypto -}}{{- set .crypto.barbican.plugin "crypto" dict -}}{{- end -}}
{{- if not .keystone_authtoken -}}{{- set . "keystone_authtoken" dict -}}{{- end -}}
{{- if not .keystone_authtoken.keystonemiddleware -}}{{- set .keystone_authtoken "keystonemiddleware" dict -}}{{- end -}}
{{- if not .keystone_authtoken.keystonemiddleware.auth_token -}}{{- set .keystone_authtoken.keystonemiddleware "auth_token" dict -}}{{- end -}}
{{- if not .keystone_notifications -}}{{- set . "keystone_notifications" dict -}}{{- end -}}
{{- if not .keystone_notifications.barbican -}}{{- set .keystone_notifications "barbican" dict -}}{{- end -}}
{{- if not .keystone_notifications.barbican.common -}}{{- set .keystone_notifications.barbican "common" dict -}}{{- end -}}
{{- if not .keystone_notifications.barbican.common.config -}}{{- set .keystone_notifications.barbican.common "config" dict -}}{{- end -}}
{{- if not .kmip_plugin -}}{{- set . "kmip_plugin" dict -}}{{- end -}}
{{- if not .kmip_plugin.barbican -}}{{- set .kmip_plugin "barbican" dict -}}{{- end -}}
{{- if not .kmip_plugin.barbican.plugin -}}{{- set .kmip_plugin.barbican "plugin" dict -}}{{- end -}}
{{- if not .kmip_plugin.barbican.plugin.secret_store -}}{{- set .kmip_plugin.barbican.plugin "secret_store" dict -}}{{- end -}}
{{- if not .kmip_plugin.barbican.plugin.secret_store.kmip -}}{{- set .kmip_plugin.barbican.plugin.secret_store "kmip" dict -}}{{- end -}}
{{- if not .matchmaker_redis -}}{{- set . "matchmaker_redis" dict -}}{{- end -}}
{{- if not .matchmaker_redis.oslo -}}{{- set .matchmaker_redis "oslo" dict -}}{{- end -}}
{{- if not .matchmaker_redis.oslo.messaging -}}{{- set .matchmaker_redis.oslo "messaging" dict -}}{{- end -}}
{{- if not .oslo_messaging_amqp -}}{{- set . "oslo_messaging_amqp" dict -}}{{- end -}}
{{- if not .oslo_messaging_amqp.oslo -}}{{- set .oslo_messaging_amqp "oslo" dict -}}{{- end -}}
{{- if not .oslo_messaging_amqp.oslo.messaging -}}{{- set .oslo_messaging_amqp.oslo "messaging" dict -}}{{- end -}}
{{- if not .oslo_messaging_kafka -}}{{- set . "oslo_messaging_kafka" dict -}}{{- end -}}
{{- if not .oslo_messaging_kafka.oslo -}}{{- set .oslo_messaging_kafka "oslo" dict -}}{{- end -}}
{{- if not .oslo_messaging_kafka.oslo.messaging -}}{{- set .oslo_messaging_kafka.oslo "messaging" dict -}}{{- end -}}
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
{{- if not .p11_crypto_plugin -}}{{- set . "p11_crypto_plugin" dict -}}{{- end -}}
{{- if not .p11_crypto_plugin.barbican -}}{{- set .p11_crypto_plugin "barbican" dict -}}{{- end -}}
{{- if not .p11_crypto_plugin.barbican.plugin -}}{{- set .p11_crypto_plugin.barbican "plugin" dict -}}{{- end -}}
{{- if not .p11_crypto_plugin.barbican.plugin.crypto -}}{{- set .p11_crypto_plugin.barbican.plugin "crypto" dict -}}{{- end -}}
{{- if not .p11_crypto_plugin.barbican.plugin.crypto.p11 -}}{{- set .p11_crypto_plugin.barbican.plugin.crypto "p11" dict -}}{{- end -}}
{{- if not .queue -}}{{- set . "queue" dict -}}{{- end -}}
{{- if not .queue.barbican -}}{{- set .queue "barbican" dict -}}{{- end -}}
{{- if not .queue.barbican.common -}}{{- set .queue.barbican "common" dict -}}{{- end -}}
{{- if not .queue.barbican.common.config -}}{{- set .queue.barbican.common "config" dict -}}{{- end -}}
{{- if not .quotas -}}{{- set . "quotas" dict -}}{{- end -}}
{{- if not .quotas.barbican -}}{{- set .quotas "barbican" dict -}}{{- end -}}
{{- if not .quotas.barbican.common -}}{{- set .quotas.barbican "common" dict -}}{{- end -}}
{{- if not .quotas.barbican.common.config -}}{{- set .quotas.barbican.common "config" dict -}}{{- end -}}
{{- if not .retry_scheduler -}}{{- set . "retry_scheduler" dict -}}{{- end -}}
{{- if not .retry_scheduler.barbican -}}{{- set .retry_scheduler "barbican" dict -}}{{- end -}}
{{- if not .retry_scheduler.barbican.common -}}{{- set .retry_scheduler.barbican "common" dict -}}{{- end -}}
{{- if not .retry_scheduler.barbican.common.config -}}{{- set .retry_scheduler.barbican.common "config" dict -}}{{- end -}}
{{- if not .secretstore -}}{{- set . "secretstore" dict -}}{{- end -}}
{{- if not .secretstore.barbican -}}{{- set .secretstore "barbican" dict -}}{{- end -}}
{{- if not .secretstore.barbican.plugin -}}{{- set .secretstore.barbican "plugin" dict -}}{{- end -}}
{{- if not .secretstore.barbican.plugin.secret_store -}}{{- set .secretstore.barbican.plugin "secret_store" dict -}}{{- end -}}
{{- if not .simple_crypto_plugin -}}{{- set . "simple_crypto_plugin" dict -}}{{- end -}}
{{- if not .simple_crypto_plugin.barbican -}}{{- set .simple_crypto_plugin "barbican" dict -}}{{- end -}}
{{- if not .simple_crypto_plugin.barbican.plugin -}}{{- set .simple_crypto_plugin.barbican "plugin" dict -}}{{- end -}}
{{- if not .simple_crypto_plugin.barbican.plugin.crypto -}}{{- set .simple_crypto_plugin.barbican.plugin "crypto" dict -}}{{- end -}}
{{- if not .simple_crypto_plugin.barbican.plugin.crypto.simple -}}{{- set .simple_crypto_plugin.barbican.plugin.crypto "simple" dict -}}{{- end -}}
{{- if not .snakeoil_ca_plugin -}}{{- set . "snakeoil_ca_plugin" dict -}}{{- end -}}
{{- if not .snakeoil_ca_plugin.barbican -}}{{- set .snakeoil_ca_plugin "barbican" dict -}}{{- end -}}
{{- if not .snakeoil_ca_plugin.barbican.certificate -}}{{- set .snakeoil_ca_plugin.barbican "certificate" dict -}}{{- end -}}
{{- if not .snakeoil_ca_plugin.barbican.certificate.plugin -}}{{- set .snakeoil_ca_plugin.barbican.certificate "plugin" dict -}}{{- end -}}
{{- if not .snakeoil_ca_plugin.barbican.certificate.plugin.snakeoil -}}{{- set .snakeoil_ca_plugin.barbican.certificate.plugin "snakeoil" dict -}}{{- end -}}
{{- if not .ssl -}}{{- set . "ssl" dict -}}{{- end -}}
{{- if not .ssl.oslo -}}{{- set .ssl "oslo" dict -}}{{- end -}}
{{- if not .ssl.oslo.service -}}{{- set .ssl.oslo "service" dict -}}{{- end -}}
{{- if not .ssl.oslo.service.sslutils -}}{{- set .ssl.oslo.service "sslutils" dict -}}{{- end -}}

{{- end -}}


{{- define "barbican.conf.barbican" -}}

[DEFAULT]

#
# From barbican.common.config
#

# Role used to identify an authenticated user as administrator.
# (string value)
# from .default.barbican.common.config.admin_role
{{ if not .default.barbican.common.config.admin_role }}#{{ end }}admin_role = {{ .default.barbican.common.config.admin_role | default "admin" }}

# Allow unauthenticated users to access the API with read-only
# privileges. This only applies when using ContextMiddleware. (boolean
# value)
# from .default.barbican.common.config.allow_anonymous_access
{{ if not .default.barbican.common.config.allow_anonymous_access }}#{{ end }}allow_anonymous_access = {{ .default.barbican.common.config.allow_anonymous_access | default "false" }}

# Maximum allowed http request size against the barbican-api. (integer
# value)
# from .default.barbican.common.config.max_allowed_request_size_in_bytes
{{ if not .default.barbican.common.config.max_allowed_request_size_in_bytes }}#{{ end }}max_allowed_request_size_in_bytes = {{ .default.barbican.common.config.max_allowed_request_size_in_bytes | default "15000" }}

# Maximum allowed secret size in bytes. (integer value)
# from .default.barbican.common.config.max_allowed_secret_in_bytes
{{ if not .default.barbican.common.config.max_allowed_secret_in_bytes }}#{{ end }}max_allowed_secret_in_bytes = {{ .default.barbican.common.config.max_allowed_secret_in_bytes | default "10000" }}

# Host name, for use in HATEOAS-style references Note: Typically this
# would be the load balanced endpoint that clients would use to
# communicate back with this service. If a deployment wants to derive
# host from wsgi request instead then make this blank. Blank is needed
# to override default config value which is 'http://localhost:9311'
# (string value)
# from .default.barbican.common.config.host_href
{{ if not .default.barbican.common.config.host_href }}#{{ end }}host_href = {{ .default.barbican.common.config.host_href | default "http://localhost:9311" }}

# SQLAlchemy connection string for the reference implementation
# registry server. Any valid SQLAlchemy connection string is fine.
# See:
# http://www.sqlalchemy.org/docs/05/reference/sqlalchemy/connections.html#sqlalchemy.create_engine.
# Note: For absolute addresses, use '////' slashes after 'sqlite:'.
# (string value)
# from .default.barbican.common.config.sql_connection
{{ if not .default.barbican.common.config.sql_connection }}#{{ end }}sql_connection = {{ .default.barbican.common.config.sql_connection | default "sqlite:///barbican.sqlite" }}

# Period in seconds after which SQLAlchemy should reestablish its
# connection to the database. MySQL uses a default `wait_timeout` of 8
# hours, after which it will drop idle connections. This can result in
# 'MySQL Gone Away' exceptions. If you notice this, you can lower this
# value to ensure that SQLAlchemy reconnects before MySQL can drop the
# connection. (integer value)
# from .default.barbican.common.config.sql_idle_timeout
{{ if not .default.barbican.common.config.sql_idle_timeout }}#{{ end }}sql_idle_timeout = {{ .default.barbican.common.config.sql_idle_timeout | default "3600" }}

# Maximum number of database connection retries during startup. Set to
# -1 to specify an infinite retry count. (integer value)
# from .default.barbican.common.config.sql_max_retries
{{ if not .default.barbican.common.config.sql_max_retries }}#{{ end }}sql_max_retries = {{ .default.barbican.common.config.sql_max_retries | default "60" }}

# Interval between retries of opening a SQL connection. (integer
# value)
# from .default.barbican.common.config.sql_retry_interval
{{ if not .default.barbican.common.config.sql_retry_interval }}#{{ end }}sql_retry_interval = {{ .default.barbican.common.config.sql_retry_interval | default "1" }}

# Create the Barbican database on service startup. (boolean value)
# from .default.barbican.common.config.db_auto_create
{{ if not .default.barbican.common.config.db_auto_create }}#{{ end }}db_auto_create = {{ .default.barbican.common.config.db_auto_create | default "true" }}

# Maximum page size for the 'limit' paging URL parameter. (integer
# value)
# from .default.barbican.common.config.max_limit_paging
{{ if not .default.barbican.common.config.max_limit_paging }}#{{ end }}max_limit_paging = {{ .default.barbican.common.config.max_limit_paging | default "100" }}

# Default page size for the 'limit' paging URL parameter. (integer
# value)
# from .default.barbican.common.config.default_limit_paging
{{ if not .default.barbican.common.config.default_limit_paging }}#{{ end }}default_limit_paging = {{ .default.barbican.common.config.default_limit_paging | default "10" }}

# Accepts a class imported from the sqlalchemy.pool module, and
# handles the details of building the pool for you. If commented out,
# SQLAlchemy will select based on the database dialect. Other options
# are QueuePool (for SQLAlchemy-managed connections) and NullPool (to
# disabled SQLAlchemy management of connections). See
# http://docs.sqlalchemy.org/en/latest/core/pooling.html for more
# details (string value)
# from .default.barbican.common.config.sql_pool_class
{{ if not .default.barbican.common.config.sql_pool_class }}#{{ end }}sql_pool_class = {{ .default.barbican.common.config.sql_pool_class | default "QueuePool" }}

# Show SQLAlchemy pool-related debugging output in logs (sets DEBUG
# log level output) if specified. (boolean value)
# from .default.barbican.common.config.sql_pool_logging
{{ if not .default.barbican.common.config.sql_pool_logging }}#{{ end }}sql_pool_logging = {{ .default.barbican.common.config.sql_pool_logging | default "false" }}

# Size of pool used by SQLAlchemy. This is the largest number of
# connections that will be kept persistently in the pool. Can be set
# to 0 to indicate no size limit. To disable pooling, use a NullPool
# with sql_pool_class instead. Comment out to allow SQLAlchemy to
# select the default. (integer value)
# from .default.barbican.common.config.sql_pool_size
{{ if not .default.barbican.common.config.sql_pool_size }}#{{ end }}sql_pool_size = {{ .default.barbican.common.config.sql_pool_size | default "5" }}

# # The maximum overflow size of the pool used by SQLAlchemy. When the
# number of checked-out connections reaches the size set in
# sql_pool_size, additional connections will be returned up to this
# limit. It follows then that the total number of simultaneous
# connections the pool will allow is sql_pool_size +
# sql_pool_max_overflow. Can be set to -1 to indicate no overflow
# limit, so no limit will be placed on the total number of concurrent
# connections. Comment out to allow SQLAlchemy to select the default.
# (integer value)
# from .default.barbican.common.config.sql_pool_max_overflow
{{ if not .default.barbican.common.config.sql_pool_max_overflow }}#{{ end }}sql_pool_max_overflow = {{ .default.barbican.common.config.sql_pool_max_overflow | default "10" }}

# Enable eventlet backdoor.  Acceptable values are 0, <port>, and
# <start>:<end>, where 0 results in listening on a random tcp port
# number; <port> results in listening on the specified port number
# (and not enabling backdoor if that port is in use); and
# <start>:<end> results in listening on the smallest unused port
# number within the specified range of port numbers.  The chosen port
# is displayed in the service's log file. (string value)
# from .default.barbican.common.config.backdoor_port
{{ if not .default.barbican.common.config.backdoor_port }}#{{ end }}backdoor_port = {{ .default.barbican.common.config.backdoor_port | default "<None>" }}

# Enable eventlet backdoor, using the provided path as a unix socket
# that can receive connections. This option is mutually exclusive with
# 'backdoor_port' in that only one should be provided. If both are
# provided then the existence of this option overrides the usage of
# that option. (string value)
# from .default.barbican.common.config.backdoor_socket
{{ if not .default.barbican.common.config.backdoor_socket }}#{{ end }}backdoor_socket = {{ .default.barbican.common.config.backdoor_socket | default "<None>" }}

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
# Allowed values: redis, sentinel, dummy
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

# Number of seconds to wait before all pending messages will be sent
# after closing a socket. The default value of -1 specifies an
# infinite linger period. The value of 0 specifies no linger period.
# Pending messages shall be discarded immediately when the socket is
# closed. Positive values specify an upper bound for the linger
# period. (integer value)
# Deprecated group/name - [DEFAULT]/rpc_cast_timeout
# from .default.oslo.messaging.zmq_linger
{{ if not .default.oslo.messaging.zmq_linger }}#{{ end }}zmq_linger = {{ .default.oslo.messaging.zmq_linger | default "-1" }}

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
{{ if not .default.oslo.messaging.use_pub_sub }}#{{ end }}use_pub_sub = {{ .default.oslo.messaging.use_pub_sub | default "false" }}

# Use ROUTER remote proxy. (boolean value)
# Deprecated group/name - [DEFAULT]/use_router_proxy
# from .default.oslo.messaging.use_router_proxy
{{ if not .default.oslo.messaging.use_router_proxy }}#{{ end }}use_router_proxy = {{ .default.oslo.messaging.use_router_proxy | default "false" }}

# This option makes direct connections dynamic or static. It makes
# sense only with use_router_proxy=False which means to use direct
# connections for direct message types (ignored otherwise). (boolean
# value)
# from .default.oslo.messaging.use_dynamic_connections
{{ if not .default.oslo.messaging.use_dynamic_connections }}#{{ end }}use_dynamic_connections = {{ .default.oslo.messaging.use_dynamic_connections | default "false" }}

# How many additional connections to a host will be made for failover
# reasons. This option is actual only in dynamic connections mode.
# (integer value)
# from .default.oslo.messaging.zmq_failover_connections
{{ if not .default.oslo.messaging.zmq_failover_connections }}#{{ end }}zmq_failover_connections = {{ .default.oslo.messaging.zmq_failover_connections | default "2" }}

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
{{ if not .default.oslo.messaging.zmq_immediate }}#{{ end }}zmq_immediate = {{ .default.oslo.messaging.zmq_immediate | default "true" }}

# Enable/disable TCP keepalive (KA) mechanism. The default value of -1
# (or any other negative value) means to skip any overrides and leave
# it to OS default; 0 and 1 (or any other positive value) mean to
# disable and enable the option respectively. (integer value)
# from .default.oslo.messaging.zmq_tcp_keepalive
{{ if not .default.oslo.messaging.zmq_tcp_keepalive }}#{{ end }}zmq_tcp_keepalive = {{ .default.oslo.messaging.zmq_tcp_keepalive | default "-1" }}

# The duration between two keepalive transmissions in idle condition.
# The unit is platform dependent, for example, seconds in Linux,
# milliseconds in Windows etc. The default value of -1 (or any other
# negative value and 0) means to skip any overrides and leave it to OS
# default. (integer value)
# from .default.oslo.messaging.zmq_tcp_keepalive_idle
{{ if not .default.oslo.messaging.zmq_tcp_keepalive_idle }}#{{ end }}zmq_tcp_keepalive_idle = {{ .default.oslo.messaging.zmq_tcp_keepalive_idle | default "-1" }}

# The number of retransmissions to be carried out before declaring
# that remote end is not available. The default value of -1 (or any
# other negative value and 0) means to skip any overrides and leave it
# to OS default. (integer value)
# from .default.oslo.messaging.zmq_tcp_keepalive_cnt
{{ if not .default.oslo.messaging.zmq_tcp_keepalive_cnt }}#{{ end }}zmq_tcp_keepalive_cnt = {{ .default.oslo.messaging.zmq_tcp_keepalive_cnt | default "-1" }}

# The duration between two successive keepalive retransmissions, if
# acknowledgement to the previous keepalive transmission is not
# received. The unit is platform dependent, for example, seconds in
# Linux, milliseconds in Windows etc. The default value of -1 (or any
# other negative value and 0) means to skip any overrides and leave it
# to OS default. (integer value)
# from .default.oslo.messaging.zmq_tcp_keepalive_intvl
{{ if not .default.oslo.messaging.zmq_tcp_keepalive_intvl }}#{{ end }}zmq_tcp_keepalive_intvl = {{ .default.oslo.messaging.zmq_tcp_keepalive_intvl | default "-1" }}

# Maximum number of (green) threads to work concurrently. (integer
# value)
# from .default.oslo.messaging.rpc_thread_pool_size
{{ if not .default.oslo.messaging.rpc_thread_pool_size }}#{{ end }}rpc_thread_pool_size = {{ .default.oslo.messaging.rpc_thread_pool_size | default "100" }}

# Expiration timeout in seconds of a sent/received message after which
# it is not tracked anymore by a client/server. (integer value)
# from .default.oslo.messaging.rpc_message_ttl
{{ if not .default.oslo.messaging.rpc_message_ttl }}#{{ end }}rpc_message_ttl = {{ .default.oslo.messaging.rpc_message_ttl | default "300" }}

# Wait for message acknowledgements from receivers. This mechanism
# works only via proxy without PUB/SUB. (boolean value)
# from .default.oslo.messaging.rpc_use_acks
{{ if not .default.oslo.messaging.rpc_use_acks }}#{{ end }}rpc_use_acks = {{ .default.oslo.messaging.rpc_use_acks | default "false" }}

# Number of seconds to wait for an ack from a cast/call. After each
# retry attempt this timeout is multiplied by some specified
# multiplier. (integer value)
# from .default.oslo.messaging.rpc_ack_timeout_base
{{ if not .default.oslo.messaging.rpc_ack_timeout_base }}#{{ end }}rpc_ack_timeout_base = {{ .default.oslo.messaging.rpc_ack_timeout_base | default "15" }}

# Number to multiply base ack timeout by after each retry attempt.
# (integer value)
# from .default.oslo.messaging.rpc_ack_timeout_multiplier
{{ if not .default.oslo.messaging.rpc_ack_timeout_multiplier }}#{{ end }}rpc_ack_timeout_multiplier = {{ .default.oslo.messaging.rpc_ack_timeout_multiplier | default "2" }}

# Default number of message sending attempts in case of any problems
# occurred: positive value N means at most N retries, 0 means no
# retries, None or -1 (or any other negative values) mean to retry
# forever. This option is used only if acknowledgments are enabled.
# (integer value)
# from .default.oslo.messaging.rpc_retry_attempts
{{ if not .default.oslo.messaging.rpc_retry_attempts }}#{{ end }}rpc_retry_attempts = {{ .default.oslo.messaging.rpc_retry_attempts | default "3" }}

# List of publisher hosts SubConsumer can subscribe on. This option
# has higher priority then the default publishers list taken from the
# matchmaker. (list value)
# from .default.oslo.messaging.subscribe_on
{{ if not .default.oslo.messaging.subscribe_on }}#{{ end }}subscribe_on = {{ .default.oslo.messaging.subscribe_on | default "" }}

# Size of executor thread pool when executor is threading or eventlet.
# (integer value)
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


[certificate]

#
# From barbican.certificate.plugin
#

# Extension namespace to search for plugins. (string value)
# from .certificate.barbican.certificate.plugin.namespace
{{ if not .certificate.barbican.certificate.plugin.namespace }}#{{ end }}namespace = {{ .certificate.barbican.certificate.plugin.namespace | default "barbican.certificate.plugin" }}

# List of certificate plugins to load. (multi valued)
# from .certificate.barbican.certificate.plugin.enabled_certificate_plugins (multiopt)
{{ if not .certificate.barbican.certificate.plugin.enabled_certificate_plugins }}#enabled_certificate_plugins = {{ .certificate.barbican.certificate.plugin.enabled_certificate_plugins | default "simple_certificate" }}{{ else }}{{ range .certificate.barbican.certificate.plugin.enabled_certificate_plugins }}enabled_certificate_plugins = {{ . }}
{{ end }}{{ end }}


[certificate_event]

#
# From barbican.certificate.plugin
#

# Extension namespace to search for eventing plugins. (string value)
# from .certificate_event.barbican.certificate.plugin.namespace
{{ if not .certificate_event.barbican.certificate.plugin.namespace }}#{{ end }}namespace = {{ .certificate_event.barbican.certificate.plugin.namespace | default "barbican.certificate.event.plugin" }}

# List of certificate plugins to load. (multi valued)
# from .certificate_event.barbican.certificate.plugin.enabled_certificate_event_plugins (multiopt)
{{ if not .certificate_event.barbican.certificate.plugin.enabled_certificate_event_plugins }}#enabled_certificate_event_plugins = {{ .certificate_event.barbican.certificate.plugin.enabled_certificate_event_plugins | default "simple_certificate_event" }}{{ else }}{{ range .certificate_event.barbican.certificate.plugin.enabled_certificate_event_plugins }}enabled_certificate_event_plugins = {{ . }}
{{ end }}{{ end }}


[cors]

#
# From oslo.middleware.cors
#

# Indicate whether this resource may be shared with the domain
# received in the requests "origin" header. Format:
# "<protocol>://<host>[:<port>]", no trailing slash. Example:
# https://horizon.example.com (list value)
# from .cors.oslo.middleware.cors.allowed_origin
{{ if not .cors.oslo.middleware.cors.allowed_origin }}#{{ end }}allowed_origin = {{ .cors.oslo.middleware.cors.allowed_origin | default "<None>" }}

# Indicate that the actual request can include user credentials
# (boolean value)
# from .cors.oslo.middleware.cors.allow_credentials
{{ if not .cors.oslo.middleware.cors.allow_credentials }}#{{ end }}allow_credentials = {{ .cors.oslo.middleware.cors.allow_credentials | default "true" }}

# Indicate which headers are safe to expose to the API. Defaults to
# HTTP Simple Headers. (list value)
# from .cors.oslo.middleware.cors.expose_headers
{{ if not .cors.oslo.middleware.cors.expose_headers }}#{{ end }}expose_headers = {{ .cors.oslo.middleware.cors.expose_headers | default "X-Auth-Token,X-Openstack-Request-Id,X-Project-Id,X-Identity-Status,X-User-Id,X-Storage-Token,X-Domain-Id,X-User-Domain-Id,X-Project-Domain-Id,X-Roles" }}

# Maximum cache age of CORS preflight requests. (integer value)
# from .cors.oslo.middleware.cors.max_age
{{ if not .cors.oslo.middleware.cors.max_age }}#{{ end }}max_age = {{ .cors.oslo.middleware.cors.max_age | default "3600" }}

# Indicate which methods can be used during the actual request. (list
# value)
# from .cors.oslo.middleware.cors.allow_methods
{{ if not .cors.oslo.middleware.cors.allow_methods }}#{{ end }}allow_methods = {{ .cors.oslo.middleware.cors.allow_methods | default "GET,PUT,POST,DELETE,PATCH" }}

# Indicate which header field names may be used during the actual
# request. (list value)
# from .cors.oslo.middleware.cors.allow_headers
{{ if not .cors.oslo.middleware.cors.allow_headers }}#{{ end }}allow_headers = {{ .cors.oslo.middleware.cors.allow_headers | default "X-Auth-Token,X-Openstack-Request-Id,X-Project-Id,X-Identity-Status,X-User-Id,X-Storage-Token,X-Domain-Id,X-User-Domain-Id,X-Project-Domain-Id,X-Roles" }}


[cors.subdomain]

#
# From oslo.middleware.cors
#

# Indicate whether this resource may be shared with the domain
# received in the requests "origin" header. Format:
# "<protocol>://<host>[:<port>]", no trailing slash. Example:
# https://horizon.example.com (list value)
# from .cors.subdomain.oslo.middleware.cors.allowed_origin
{{ if not .cors.subdomain.oslo.middleware.cors.allowed_origin }}#{{ end }}allowed_origin = {{ .cors.subdomain.oslo.middleware.cors.allowed_origin | default "<None>" }}

# Indicate that the actual request can include user credentials
# (boolean value)
# from .cors.subdomain.oslo.middleware.cors.allow_credentials
{{ if not .cors.subdomain.oslo.middleware.cors.allow_credentials }}#{{ end }}allow_credentials = {{ .cors.subdomain.oslo.middleware.cors.allow_credentials | default "true" }}

# Indicate which headers are safe to expose to the API. Defaults to
# HTTP Simple Headers. (list value)
# from .cors.subdomain.oslo.middleware.cors.expose_headers
{{ if not .cors.subdomain.oslo.middleware.cors.expose_headers }}#{{ end }}expose_headers = {{ .cors.subdomain.oslo.middleware.cors.expose_headers | default "X-Auth-Token,X-Openstack-Request-Id,X-Project-Id,X-Identity-Status,X-User-Id,X-Storage-Token,X-Domain-Id,X-User-Domain-Id,X-Project-Domain-Id,X-Roles" }}

# Maximum cache age of CORS preflight requests. (integer value)
# from .cors.subdomain.oslo.middleware.cors.max_age
{{ if not .cors.subdomain.oslo.middleware.cors.max_age }}#{{ end }}max_age = {{ .cors.subdomain.oslo.middleware.cors.max_age | default "3600" }}

# Indicate which methods can be used during the actual request. (list
# value)
# from .cors.subdomain.oslo.middleware.cors.allow_methods
{{ if not .cors.subdomain.oslo.middleware.cors.allow_methods }}#{{ end }}allow_methods = {{ .cors.subdomain.oslo.middleware.cors.allow_methods | default "GET,PUT,POST,DELETE,PATCH" }}

# Indicate which header field names may be used during the actual
# request. (list value)
# from .cors.subdomain.oslo.middleware.cors.allow_headers
{{ if not .cors.subdomain.oslo.middleware.cors.allow_headers }}#{{ end }}allow_headers = {{ .cors.subdomain.oslo.middleware.cors.allow_headers | default "X-Auth-Token,X-Openstack-Request-Id,X-Project-Id,X-Identity-Status,X-User-Id,X-Storage-Token,X-Domain-Id,X-User-Domain-Id,X-Project-Domain-Id,X-Roles" }}


[crypto]

#
# From barbican.plugin.crypto
#

# Extension namespace to search for plugins. (string value)
# from .crypto.barbican.plugin.crypto.namespace
{{ if not .crypto.barbican.plugin.crypto.namespace }}#{{ end }}namespace = {{ .crypto.barbican.plugin.crypto.namespace | default "barbican.crypto.plugin" }}

# List of crypto plugins to load. (multi valued)
# from .crypto.barbican.plugin.crypto.enabled_crypto_plugins (multiopt)
{{ if not .crypto.barbican.plugin.crypto.enabled_crypto_plugins }}#enabled_crypto_plugins = {{ .crypto.barbican.plugin.crypto.enabled_crypto_plugins | default "simple_crypto" }}{{ else }}{{ range .crypto.barbican.plugin.crypto.enabled_crypto_plugins }}enabled_crypto_plugins = {{ . }}
{{ end }}{{ end }}


[keystone_authtoken]

#
# From keystonemiddleware.auth_token
#

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
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.auth_uri }}#{{ end }}auth_url = {{ .keystone_authtoken.keystonemiddleware.auth_token.auth_uri | default "<None>" }}

{{ if not .keystone_authtoken.keystonemiddleware.auth_token.project_name }}#{{ end }}project_name = {{ .keystone_authtoken.keystonemiddleware.auth_token.project_name | default "<None>" }}
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.project_domain_name }}#{{ end }}project_domain_name = {{ .keystone_authtoken.keystonemiddleware.auth_token.project_domain_name | default "<None>" }}
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.user_domain_name }}#{{ end }}user_domain_name = {{ .keystone_authtoken.keystonemiddleware.auth_token.user_domain_name | default "<None>" }}
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.username }}#{{ end }}username = {{ .keystone_authtoken.keystonemiddleware.auth_token.username | default "<None>" }}
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.password }}#{{ end }}password = {{ .keystone_authtoken.keystonemiddleware.auth_token.password | default "<None>" }}

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

# DEPRECATED: Directory used to cache files related to PKI tokens.
# This option has been deprecated in the Ocata release and will be
# removed in the P release. (string value)
# This option is deprecated for removal since Ocata.
# Its value may be silently ignored in the future.
# Reason: PKI token format is no longer supported.
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

# DEPRECATED: Determines the frequency at which the list of revoked
# tokens is retrieved from the Identity service (in seconds). A high
# number of revocation events combined with a low cache duration may
# significantly reduce performance. Only valid for PKI tokens. This
# option has been deprecated in the Ocata release and will be removed
# in the P release. (integer value)
# This option is deprecated for removal since Ocata.
# Its value may be silently ignored in the future.
# Reason: PKI token format is no longer supported.
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

# DEPRECATED: If true, the revocation list will be checked for cached
# tokens. This requires that PKI tokens are configured on the identity
# server. (boolean value)
# This option is deprecated for removal since Ocata.
# Its value may be silently ignored in the future.
# Reason: PKI token format is no longer supported.
# from .keystone_authtoken.keystonemiddleware.auth_token.check_revocations_for_cached
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.check_revocations_for_cached }}#{{ end }}check_revocations_for_cached = {{ .keystone_authtoken.keystonemiddleware.auth_token.check_revocations_for_cached | default "false" }}

# DEPRECATED: Hash algorithms to use for hashing PKI tokens. This may
# be a single algorithm or multiple. The algorithms are those
# supported by Python standard hashlib.new(). The hashes will be tried
# in the order given, so put the preferred one first for performance.
# The result of the first hash will be stored in the cache. This will
# typically be set to multiple values only while migrating from a less
# secure algorithm to a more secure one. Once all the old tokens are
# expired this option should be set to a single value for better
# performance. (list value)
# This option is deprecated for removal since Ocata.
# Its value may be silently ignored in the future.
# Reason: PKI token format is no longer supported.
# from .keystone_authtoken.keystonemiddleware.auth_token.hash_algorithms
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.hash_algorithms }}#{{ end }}hash_algorithms = {{ .keystone_authtoken.keystonemiddleware.auth_token.hash_algorithms | default "md5" }}

# A choice of roles that must be present in a service token. Service
# tokens are allowed to request that an expired token can be used and
# so this check should tightly control that only actual services
# should be sending this token. Roles here are applied as an ANY check
# so any role in this list must be present. For backwards
# compatibility reasons this currently only affects the allow_expired
# check. (list value)
# from .keystone_authtoken.keystonemiddleware.auth_token.service_token_roles
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.service_token_roles }}#{{ end }}service_token_roles = {{ .keystone_authtoken.keystonemiddleware.auth_token.service_token_roles | default "service" }}

# For backwards compatibility reasons we must let valid service tokens
# pass that don't pass the service_token_roles check as valid. Setting
# this true will become the default in a future release and should be
# enabled if possible. (boolean value)
# from .keystone_authtoken.keystonemiddleware.auth_token.service_token_roles_required
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.service_token_roles_required }}#{{ end }}service_token_roles_required = {{ .keystone_authtoken.keystonemiddleware.auth_token.service_token_roles_required | default "false" }}

# Authentication type to load (string value)
# Deprecated group/name - [keystone_authtoken]/auth_plugin
# from .keystone_authtoken.keystonemiddleware.auth_token.auth_type
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.auth_type }}#{{ end }}auth_type = {{ .keystone_authtoken.keystonemiddleware.auth_token.auth_type | default "<None>" }}

# Config Section from which to load plugin specific options (string
# value)
# from .keystone_authtoken.keystonemiddleware.auth_token.auth_section
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.auth_section }}#{{ end }}auth_section = {{ .keystone_authtoken.keystonemiddleware.auth_token.auth_section | default "<None>" }}


[keystone_notifications]

#
# From barbican.common.config
#

# True enables keystone notification listener  functionality. (boolean
# value)
# from .keystone_notifications.barbican.common.config.enable
{{ if not .keystone_notifications.barbican.common.config.enable }}#{{ end }}enable = {{ .keystone_notifications.barbican.common.config.enable | default "false" }}

# The default exchange under which topics are scoped. May be
# overridden by an exchange name specified in the transport_url
# option. (string value)
# from .keystone_notifications.barbican.common.config.control_exchange
{{ if not .keystone_notifications.barbican.common.config.control_exchange }}#{{ end }}control_exchange = {{ .keystone_notifications.barbican.common.config.control_exchange | default "openstack" }}

# Keystone notification queue topic name. This name needs to match one
# of values mentioned in Keystone deployment's 'notification_topics'
# configuration e.g.    notification_topics=notifications,
# barbican_notificationsMultiple servers may listen on a topic and
# messages will be dispatched to one of the servers in a round-robin
# fashion. That's why Barbican service should have its own dedicated
# notification queue so that it receives all of Keystone
# notifications. (string value)
# from .keystone_notifications.barbican.common.config.topic
{{ if not .keystone_notifications.barbican.common.config.topic }}#{{ end }}topic = {{ .keystone_notifications.barbican.common.config.topic | default "notifications" }}

# True enables requeue feature in case of notification processing
# error. Enable this only when underlying transport supports this
# feature. (boolean value)
# from .keystone_notifications.barbican.common.config.allow_requeue
{{ if not .keystone_notifications.barbican.common.config.allow_requeue }}#{{ end }}allow_requeue = {{ .keystone_notifications.barbican.common.config.allow_requeue | default "false" }}

# Version of tasks invoked via notifications (string value)
# from .keystone_notifications.barbican.common.config.version
{{ if not .keystone_notifications.barbican.common.config.version }}#{{ end }}version = {{ .keystone_notifications.barbican.common.config.version | default "1.0" }}

# Define the number of max threads to be used for notification server
# processing functionality. (integer value)
# from .keystone_notifications.barbican.common.config.thread_pool_size
{{ if not .keystone_notifications.barbican.common.config.thread_pool_size }}#{{ end }}thread_pool_size = {{ .keystone_notifications.barbican.common.config.thread_pool_size | default "10" }}


[kmip_plugin]

#
# From barbican.plugin.secret_store.kmip
#

# Username for authenticating with KMIP server (string value)
# from .kmip_plugin.barbican.plugin.secret_store.kmip.username
{{ if not .kmip_plugin.barbican.plugin.secret_store.kmip.username }}#{{ end }}username = {{ .kmip_plugin.barbican.plugin.secret_store.kmip.username | default "<None>" }}

# Password for authenticating with KMIP server (string value)
# from .kmip_plugin.barbican.plugin.secret_store.kmip.password
{{ if not .kmip_plugin.barbican.plugin.secret_store.kmip.password }}#{{ end }}password = {{ .kmip_plugin.barbican.plugin.secret_store.kmip.password | default "<None>" }}

# Address of the KMIP server (string value)
# from .kmip_plugin.barbican.plugin.secret_store.kmip.host
{{ if not .kmip_plugin.barbican.plugin.secret_store.kmip.host }}#{{ end }}host = {{ .kmip_plugin.barbican.plugin.secret_store.kmip.host | default "localhost" }}

# Port for the KMIP server (integer value)
# from .kmip_plugin.barbican.plugin.secret_store.kmip.port
{{ if not .kmip_plugin.barbican.plugin.secret_store.kmip.port }}#{{ end }}port = {{ .kmip_plugin.barbican.plugin.secret_store.kmip.port | default "5696" }}

# SSL version, maps to the module ssl's constants (string value)
# from .kmip_plugin.barbican.plugin.secret_store.kmip.ssl_version
{{ if not .kmip_plugin.barbican.plugin.secret_store.kmip.ssl_version }}#{{ end }}ssl_version = {{ .kmip_plugin.barbican.plugin.secret_store.kmip.ssl_version | default "PROTOCOL_TLSv1_2" }}

# File path to concatenated "certification authority" certificates
# (string value)
# from .kmip_plugin.barbican.plugin.secret_store.kmip.ca_certs
{{ if not .kmip_plugin.barbican.plugin.secret_store.kmip.ca_certs }}#{{ end }}ca_certs = {{ .kmip_plugin.barbican.plugin.secret_store.kmip.ca_certs | default "<None>" }}

# File path to local client certificate (string value)
# from .kmip_plugin.barbican.plugin.secret_store.kmip.certfile
{{ if not .kmip_plugin.barbican.plugin.secret_store.kmip.certfile }}#{{ end }}certfile = {{ .kmip_plugin.barbican.plugin.secret_store.kmip.certfile | default "<None>" }}

# File path to local client certificate keyfile (string value)
# from .kmip_plugin.barbican.plugin.secret_store.kmip.keyfile
{{ if not .kmip_plugin.barbican.plugin.secret_store.kmip.keyfile }}#{{ end }}keyfile = {{ .kmip_plugin.barbican.plugin.secret_store.kmip.keyfile | default "<None>" }}

# Only support PKCS#1 encoding of asymmetric keys (boolean value)
# from .kmip_plugin.barbican.plugin.secret_store.kmip.pkcs1_only
{{ if not .kmip_plugin.barbican.plugin.secret_store.kmip.pkcs1_only }}#{{ end }}pkcs1_only = {{ .kmip_plugin.barbican.plugin.secret_store.kmip.pkcs1_only | default "false" }}

# User friendly plugin name (string value)
# from .kmip_plugin.barbican.plugin.secret_store.kmip.plugin_name
{{ if not .kmip_plugin.barbican.plugin.secret_store.kmip.plugin_name }}#{{ end }}plugin_name = {{ .kmip_plugin.barbican.plugin.secret_store.kmip.plugin_name | default "KMIP HSM" }}


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

# DEPRECATED: List of Redis Sentinel hosts (fault tolerance mode),
# e.g., [host:port, host1:port ... ] (list value)
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

# Timeout in ms on blocking socket operations. (integer value)
# from .matchmaker_redis.oslo.messaging.socket_timeout
{{ if not .matchmaker_redis.oslo.messaging.socket_timeout }}#{{ end }}socket_timeout = {{ .matchmaker_redis.oslo.messaging.socket_timeout | default "10000" }}


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

# Attempt to connect via SSL. If no other ssl-related parameters are
# given, it will use the system's CA-bundle to verify the server's
# certificate. (boolean value)
# from .oslo_messaging_amqp.oslo.messaging.ssl
{{ if not .oslo_messaging_amqp.oslo.messaging.ssl }}#{{ end }}ssl = {{ .oslo_messaging_amqp.oslo.messaging.ssl | default "false" }}

# CA certificate PEM file used to verify the server's certificate
# (string value)
# Deprecated group/name - [amqp1]/ssl_ca_file
# from .oslo_messaging_amqp.oslo.messaging.ssl_ca_file
{{ if not .oslo_messaging_amqp.oslo.messaging.ssl_ca_file }}#{{ end }}ssl_ca_file = {{ .oslo_messaging_amqp.oslo.messaging.ssl_ca_file | default "" }}

# Self-identifying certificate PEM file for client authentication
# (string value)
# Deprecated group/name - [amqp1]/ssl_cert_file
# from .oslo_messaging_amqp.oslo.messaging.ssl_cert_file
{{ if not .oslo_messaging_amqp.oslo.messaging.ssl_cert_file }}#{{ end }}ssl_cert_file = {{ .oslo_messaging_amqp.oslo.messaging.ssl_cert_file | default "" }}

# Private key PEM file used to sign ssl_cert_file certificate
# (optional) (string value)
# Deprecated group/name - [amqp1]/ssl_key_file
# from .oslo_messaging_amqp.oslo.messaging.ssl_key_file
{{ if not .oslo_messaging_amqp.oslo.messaging.ssl_key_file }}#{{ end }}ssl_key_file = {{ .oslo_messaging_amqp.oslo.messaging.ssl_key_file | default "" }}

# Password for decrypting ssl_key_file (if encrypted) (string value)
# Deprecated group/name - [amqp1]/ssl_key_password
# from .oslo_messaging_amqp.oslo.messaging.ssl_key_password
{{ if not .oslo_messaging_amqp.oslo.messaging.ssl_key_password }}#{{ end }}ssl_key_password = {{ .oslo_messaging_amqp.oslo.messaging.ssl_key_password | default "<None>" }}

# DEPRECATED: Accept clients using either SSL or plain TCP (boolean
# value)
# Deprecated group/name - [amqp1]/allow_insecure_clients
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# Reason: Not applicable - not a SSL server
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

# DEPRECATED: User name for message broker authentication (string
# value)
# Deprecated group/name - [amqp1]/username
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# Reason: Should use configuration option transport_url to provide the
# username.
# from .oslo_messaging_amqp.oslo.messaging.username
{{ if not .oslo_messaging_amqp.oslo.messaging.username }}#{{ end }}username = {{ .oslo_messaging_amqp.oslo.messaging.username | default "" }}

# DEPRECATED: Password for message broker authentication (string
# value)
# Deprecated group/name - [amqp1]/password
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# Reason: Should use configuration option transport_url to provide the
# password.
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

# The maximum number of attempts to re-send a reply message which
# failed due to a recoverable error. (integer value)
# Minimum value: -1
# from .oslo_messaging_amqp.oslo.messaging.default_reply_retry
{{ if not .oslo_messaging_amqp.oslo.messaging.default_reply_retry }}#{{ end }}default_reply_retry = {{ .oslo_messaging_amqp.oslo.messaging.default_reply_retry | default "0" }}

# The deadline for an rpc reply message delivery. (integer value)
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

# The duration to schedule a purge of idle sender links. Detach link
# after expiry. (integer value)
# Minimum value: 1
# from .oslo_messaging_amqp.oslo.messaging.default_sender_link_timeout
{{ if not .oslo_messaging_amqp.oslo.messaging.default_sender_link_timeout }}#{{ end }}default_sender_link_timeout = {{ .oslo_messaging_amqp.oslo.messaging.default_sender_link_timeout | default "600" }}

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

# Send messages of this type pre-settled.
# Pre-settled messages will not receive acknowledgement
# from the peer. Note well: pre-settled messages may be
# silently discarded if the delivery fails.
# Permitted values:
# 'rpc-call' - send RPC Calls pre-settled
# 'rpc-reply'- send RPC Replies pre-settled
# 'rpc-cast' - Send RPC Casts pre-settled
# 'notify'   - Send Notifications pre-settled
#  (multi valued)
# from .oslo_messaging_amqp.oslo.messaging.pre_settled (multiopt)
{{ if not .oslo_messaging_amqp.oslo.messaging.pre_settled }}#pre_settled = {{ .oslo_messaging_amqp.oslo.messaging.pre_settled | default "rpc-cast" }}{{ else }}{{ range .oslo_messaging_amqp.oslo.messaging.pre_settled }}pre_settled = {{ . }}
{{ end }}{{ end }}
# from .oslo_messaging_amqp.oslo.messaging.pre_settled (multiopt)
{{ if not .oslo_messaging_amqp.oslo.messaging.pre_settled }}#pre_settled = {{ .oslo_messaging_amqp.oslo.messaging.pre_settled | default "rpc-reply" }}{{ else }}{{ range .oslo_messaging_amqp.oslo.messaging.pre_settled }}pre_settled = {{ . }}
{{ end }}{{ end }}


[oslo_messaging_kafka]

#
# From oslo.messaging
#

# DEPRECATED: Default Kafka broker Host (string value)
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# Reason: Replaced by [DEFAULT]/transport_url
# from .oslo_messaging_kafka.oslo.messaging.kafka_default_host
{{ if not .oslo_messaging_kafka.oslo.messaging.kafka_default_host }}#{{ end }}kafka_default_host = {{ .oslo_messaging_kafka.oslo.messaging.kafka_default_host | default "localhost" }}

# DEPRECATED: Default Kafka broker Port (port value)
# Minimum value: 0
# Maximum value: 65535
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# Reason: Replaced by [DEFAULT]/transport_url
# from .oslo_messaging_kafka.oslo.messaging.kafka_default_port
{{ if not .oslo_messaging_kafka.oslo.messaging.kafka_default_port }}#{{ end }}kafka_default_port = {{ .oslo_messaging_kafka.oslo.messaging.kafka_default_port | default "9092" }}

# Max fetch bytes of Kafka consumer (integer value)
# from .oslo_messaging_kafka.oslo.messaging.kafka_max_fetch_bytes
{{ if not .oslo_messaging_kafka.oslo.messaging.kafka_max_fetch_bytes }}#{{ end }}kafka_max_fetch_bytes = {{ .oslo_messaging_kafka.oslo.messaging.kafka_max_fetch_bytes | default "1048576" }}

# Default timeout(s) for Kafka consumers (floating point value)
# from .oslo_messaging_kafka.oslo.messaging.kafka_consumer_timeout
{{ if not .oslo_messaging_kafka.oslo.messaging.kafka_consumer_timeout }}#{{ end }}kafka_consumer_timeout = {{ .oslo_messaging_kafka.oslo.messaging.kafka_consumer_timeout | default "1.0" }}

# Pool Size for Kafka Consumers (integer value)
# from .oslo_messaging_kafka.oslo.messaging.pool_size
{{ if not .oslo_messaging_kafka.oslo.messaging.pool_size }}#{{ end }}pool_size = {{ .oslo_messaging_kafka.oslo.messaging.pool_size | default "10" }}

# The pool size limit for connections expiration policy (integer
# value)
# from .oslo_messaging_kafka.oslo.messaging.conn_pool_min_size
{{ if not .oslo_messaging_kafka.oslo.messaging.conn_pool_min_size }}#{{ end }}conn_pool_min_size = {{ .oslo_messaging_kafka.oslo.messaging.conn_pool_min_size | default "2" }}

# The time-to-live in sec of idle connections in the pool (integer
# value)
# from .oslo_messaging_kafka.oslo.messaging.conn_pool_ttl
{{ if not .oslo_messaging_kafka.oslo.messaging.conn_pool_ttl }}#{{ end }}conn_pool_ttl = {{ .oslo_messaging_kafka.oslo.messaging.conn_pool_ttl | default "1200" }}

# Group id for Kafka consumer. Consumers in one group will coordinate
# message consumption (string value)
# from .oslo_messaging_kafka.oslo.messaging.consumer_group
{{ if not .oslo_messaging_kafka.oslo.messaging.consumer_group }}#{{ end }}consumer_group = {{ .oslo_messaging_kafka.oslo.messaging.consumer_group | default "oslo_messaging_consumer" }}

# Upper bound on the delay for KafkaProducer batching in seconds
# (floating point value)
# from .oslo_messaging_kafka.oslo.messaging.producer_batch_timeout
{{ if not .oslo_messaging_kafka.oslo.messaging.producer_batch_timeout }}#{{ end }}producer_batch_timeout = {{ .oslo_messaging_kafka.oslo.messaging.producer_batch_timeout | default "0.0" }}

# Size of batch for the producer async send (integer value)
# from .oslo_messaging_kafka.oslo.messaging.producer_batch_size
{{ if not .oslo_messaging_kafka.oslo.messaging.producer_batch_size }}#{{ end }}producer_batch_size = {{ .oslo_messaging_kafka.oslo.messaging.producer_batch_size | default "16384" }}


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

# Enable SSL (boolean value)
# from .oslo_messaging_rabbit.oslo.messaging.ssl
{{ if not .oslo_messaging_rabbit.oslo.messaging.ssl }}#{{ end }}ssl = {{ .oslo_messaging_rabbit.oslo.messaging.ssl | default "<None>" }}

# SSL version to use (valid only if SSL enabled). Valid values are
# TLSv1 and SSLv23. SSLv2, SSLv3, TLSv1_1, and TLSv1_2 may be
# available on some distributions. (string value)
# Deprecated group/name - [oslo_messaging_rabbit]/kombu_ssl_version
# from .oslo_messaging_rabbit.oslo.messaging.ssl_version
{{ if not .oslo_messaging_rabbit.oslo.messaging.ssl_version }}#{{ end }}ssl_version = {{ .oslo_messaging_rabbit.oslo.messaging.ssl_version | default "" }}

# SSL key file (valid only if SSL enabled). (string value)
# Deprecated group/name - [oslo_messaging_rabbit]/kombu_ssl_keyfile
# from .oslo_messaging_rabbit.oslo.messaging.ssl_key_file
{{ if not .oslo_messaging_rabbit.oslo.messaging.ssl_key_file }}#{{ end }}ssl_key_file = {{ .oslo_messaging_rabbit.oslo.messaging.ssl_key_file | default "" }}

# SSL cert file (valid only if SSL enabled). (string value)
# Deprecated group/name - [oslo_messaging_rabbit]/kombu_ssl_certfile
# from .oslo_messaging_rabbit.oslo.messaging.ssl_cert_file
{{ if not .oslo_messaging_rabbit.oslo.messaging.ssl_cert_file }}#{{ end }}ssl_cert_file = {{ .oslo_messaging_rabbit.oslo.messaging.ssl_cert_file | default "" }}

# SSL certification authority file (valid only if SSL enabled).
# (string value)
# Deprecated group/name - [oslo_messaging_rabbit]/kombu_ssl_ca_certs
# from .oslo_messaging_rabbit.oslo.messaging.ssl_ca_file
{{ if not .oslo_messaging_rabbit.oslo.messaging.ssl_ca_file }}#{{ end }}ssl_ca_file = {{ .oslo_messaging_rabbit.oslo.messaging.ssl_ca_file | default "" }}

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
# Allowed values: PLAIN, AMQPLAIN, RABBIT-CR-DEMO
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
# queues (except those with auto-generated names) are mirrored across
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

# Default serialization mechanism for serializing/deserializing
# outgoing/incoming messages (string value)
# Allowed values: json, msgpack
# from .oslo_messaging_rabbit.oslo.messaging.default_serializer_type
{{ if not .oslo_messaging_rabbit.oslo.messaging.default_serializer_type }}#{{ end }}default_serializer_type = {{ .oslo_messaging_rabbit.oslo.messaging.default_serializer_type | default "json" }}

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
# attempts in not 0 the rpc request could be processed more than one
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
# Allowed values: redis, sentinel, dummy
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

# Number of seconds to wait before all pending messages will be sent
# after closing a socket. The default value of -1 specifies an
# infinite linger period. The value of 0 specifies no linger period.
# Pending messages shall be discarded immediately when the socket is
# closed. Positive values specify an upper bound for the linger
# period. (integer value)
# Deprecated group/name - [DEFAULT]/rpc_cast_timeout
# from .oslo_messaging_zmq.oslo.messaging.zmq_linger
{{ if not .oslo_messaging_zmq.oslo.messaging.zmq_linger }}#{{ end }}zmq_linger = {{ .oslo_messaging_zmq.oslo.messaging.zmq_linger | default "-1" }}

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
{{ if not .oslo_messaging_zmq.oslo.messaging.use_pub_sub }}#{{ end }}use_pub_sub = {{ .oslo_messaging_zmq.oslo.messaging.use_pub_sub | default "false" }}

# Use ROUTER remote proxy. (boolean value)
# Deprecated group/name - [DEFAULT]/use_router_proxy
# from .oslo_messaging_zmq.oslo.messaging.use_router_proxy
{{ if not .oslo_messaging_zmq.oslo.messaging.use_router_proxy }}#{{ end }}use_router_proxy = {{ .oslo_messaging_zmq.oslo.messaging.use_router_proxy | default "false" }}

# This option makes direct connections dynamic or static. It makes
# sense only with use_router_proxy=False which means to use direct
# connections for direct message types (ignored otherwise). (boolean
# value)
# from .oslo_messaging_zmq.oslo.messaging.use_dynamic_connections
{{ if not .oslo_messaging_zmq.oslo.messaging.use_dynamic_connections }}#{{ end }}use_dynamic_connections = {{ .oslo_messaging_zmq.oslo.messaging.use_dynamic_connections | default "false" }}

# How many additional connections to a host will be made for failover
# reasons. This option is actual only in dynamic connections mode.
# (integer value)
# from .oslo_messaging_zmq.oslo.messaging.zmq_failover_connections
{{ if not .oslo_messaging_zmq.oslo.messaging.zmq_failover_connections }}#{{ end }}zmq_failover_connections = {{ .oslo_messaging_zmq.oslo.messaging.zmq_failover_connections | default "2" }}

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
{{ if not .oslo_messaging_zmq.oslo.messaging.zmq_immediate }}#{{ end }}zmq_immediate = {{ .oslo_messaging_zmq.oslo.messaging.zmq_immediate | default "true" }}

# Enable/disable TCP keepalive (KA) mechanism. The default value of -1
# (or any other negative value) means to skip any overrides and leave
# it to OS default; 0 and 1 (or any other positive value) mean to
# disable and enable the option respectively. (integer value)
# from .oslo_messaging_zmq.oslo.messaging.zmq_tcp_keepalive
{{ if not .oslo_messaging_zmq.oslo.messaging.zmq_tcp_keepalive }}#{{ end }}zmq_tcp_keepalive = {{ .oslo_messaging_zmq.oslo.messaging.zmq_tcp_keepalive | default "-1" }}

# The duration between two keepalive transmissions in idle condition.
# The unit is platform dependent, for example, seconds in Linux,
# milliseconds in Windows etc. The default value of -1 (or any other
# negative value and 0) means to skip any overrides and leave it to OS
# default. (integer value)
# from .oslo_messaging_zmq.oslo.messaging.zmq_tcp_keepalive_idle
{{ if not .oslo_messaging_zmq.oslo.messaging.zmq_tcp_keepalive_idle }}#{{ end }}zmq_tcp_keepalive_idle = {{ .oslo_messaging_zmq.oslo.messaging.zmq_tcp_keepalive_idle | default "-1" }}

# The number of retransmissions to be carried out before declaring
# that remote end is not available. The default value of -1 (or any
# other negative value and 0) means to skip any overrides and leave it
# to OS default. (integer value)
# from .oslo_messaging_zmq.oslo.messaging.zmq_tcp_keepalive_cnt
{{ if not .oslo_messaging_zmq.oslo.messaging.zmq_tcp_keepalive_cnt }}#{{ end }}zmq_tcp_keepalive_cnt = {{ .oslo_messaging_zmq.oslo.messaging.zmq_tcp_keepalive_cnt | default "-1" }}

# The duration between two successive keepalive retransmissions, if
# acknowledgement to the previous keepalive transmission is not
# received. The unit is platform dependent, for example, seconds in
# Linux, milliseconds in Windows etc. The default value of -1 (or any
# other negative value and 0) means to skip any overrides and leave it
# to OS default. (integer value)
# from .oslo_messaging_zmq.oslo.messaging.zmq_tcp_keepalive_intvl
{{ if not .oslo_messaging_zmq.oslo.messaging.zmq_tcp_keepalive_intvl }}#{{ end }}zmq_tcp_keepalive_intvl = {{ .oslo_messaging_zmq.oslo.messaging.zmq_tcp_keepalive_intvl | default "-1" }}

# Maximum number of (green) threads to work concurrently. (integer
# value)
# from .oslo_messaging_zmq.oslo.messaging.rpc_thread_pool_size
{{ if not .oslo_messaging_zmq.oslo.messaging.rpc_thread_pool_size }}#{{ end }}rpc_thread_pool_size = {{ .oslo_messaging_zmq.oslo.messaging.rpc_thread_pool_size | default "100" }}

# Expiration timeout in seconds of a sent/received message after which
# it is not tracked anymore by a client/server. (integer value)
# from .oslo_messaging_zmq.oslo.messaging.rpc_message_ttl
{{ if not .oslo_messaging_zmq.oslo.messaging.rpc_message_ttl }}#{{ end }}rpc_message_ttl = {{ .oslo_messaging_zmq.oslo.messaging.rpc_message_ttl | default "300" }}

# Wait for message acknowledgements from receivers. This mechanism
# works only via proxy without PUB/SUB. (boolean value)
# from .oslo_messaging_zmq.oslo.messaging.rpc_use_acks
{{ if not .oslo_messaging_zmq.oslo.messaging.rpc_use_acks }}#{{ end }}rpc_use_acks = {{ .oslo_messaging_zmq.oslo.messaging.rpc_use_acks | default "false" }}

# Number of seconds to wait for an ack from a cast/call. After each
# retry attempt this timeout is multiplied by some specified
# multiplier. (integer value)
# from .oslo_messaging_zmq.oslo.messaging.rpc_ack_timeout_base
{{ if not .oslo_messaging_zmq.oslo.messaging.rpc_ack_timeout_base }}#{{ end }}rpc_ack_timeout_base = {{ .oslo_messaging_zmq.oslo.messaging.rpc_ack_timeout_base | default "15" }}

# Number to multiply base ack timeout by after each retry attempt.
# (integer value)
# from .oslo_messaging_zmq.oslo.messaging.rpc_ack_timeout_multiplier
{{ if not .oslo_messaging_zmq.oslo.messaging.rpc_ack_timeout_multiplier }}#{{ end }}rpc_ack_timeout_multiplier = {{ .oslo_messaging_zmq.oslo.messaging.rpc_ack_timeout_multiplier | default "2" }}

# Default number of message sending attempts in case of any problems
# occurred: positive value N means at most N retries, 0 means no
# retries, None or -1 (or any other negative values) mean to retry
# forever. This option is used only if acknowledgments are enabled.
# (integer value)
# from .oslo_messaging_zmq.oslo.messaging.rpc_retry_attempts
{{ if not .oslo_messaging_zmq.oslo.messaging.rpc_retry_attempts }}#{{ end }}rpc_retry_attempts = {{ .oslo_messaging_zmq.oslo.messaging.rpc_retry_attempts | default "3" }}

# List of publisher hosts SubConsumer can subscribe on. This option
# has higher priority then the default publishers list taken from the
# matchmaker. (list value)
# from .oslo_messaging_zmq.oslo.messaging.subscribe_on
{{ if not .oslo_messaging_zmq.oslo.messaging.subscribe_on }}#{{ end }}subscribe_on = {{ .oslo_messaging_zmq.oslo.messaging.subscribe_on | default "" }}


[oslo_middleware]

#
# From oslo.middleware.http_proxy_to_wsgi
#

# Whether the application is behind a proxy or not. This determines if
# the middleware should parse the headers or not. (boolean value)
# from .oslo_middleware.oslo.middleware.http_proxy_to_wsgi.enable_proxy_headers_parsing
{{ if not .oslo_middleware.oslo.middleware.http_proxy_to_wsgi.enable_proxy_headers_parsing }}#{{ end }}enable_proxy_headers_parsing = {{ .oslo_middleware.oslo.middleware.http_proxy_to_wsgi.enable_proxy_headers_parsing | default "false" }}


[oslo_policy]

#
# From oslo.policy
#

# The file that defines policies. (string value)
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


[p11_crypto_plugin]

#
# From barbican.plugin.crypto.p11
#

# Path to vendor PKCS11 library (string value)
# from .p11_crypto_plugin.barbican.plugin.crypto.p11.library_path
{{ if not .p11_crypto_plugin.barbican.plugin.crypto.p11.library_path }}#{{ end }}library_path = {{ .p11_crypto_plugin.barbican.plugin.crypto.p11.library_path | default "<None>" }}

# Password to login to PKCS11 session (string value)
# from .p11_crypto_plugin.barbican.plugin.crypto.p11.login
{{ if not .p11_crypto_plugin.barbican.plugin.crypto.p11.login }}#{{ end }}login = {{ .p11_crypto_plugin.barbican.plugin.crypto.p11.login | default "<None>" }}

# Master KEK label (used in the HSM) (string value)
# from .p11_crypto_plugin.barbican.plugin.crypto.p11.mkek_label
{{ if not .p11_crypto_plugin.barbican.plugin.crypto.p11.mkek_label }}#{{ end }}mkek_label = {{ .p11_crypto_plugin.barbican.plugin.crypto.p11.mkek_label | default "<None>" }}

# Master KEK length in bytes. (integer value)
# from .p11_crypto_plugin.barbican.plugin.crypto.p11.mkek_length
{{ if not .p11_crypto_plugin.barbican.plugin.crypto.p11.mkek_length }}#{{ end }}mkek_length = {{ .p11_crypto_plugin.barbican.plugin.crypto.p11.mkek_length | default "<None>" }}

# HMAC label (used in the HSM) (string value)
# from .p11_crypto_plugin.barbican.plugin.crypto.p11.hmac_label
{{ if not .p11_crypto_plugin.barbican.plugin.crypto.p11.hmac_label }}#{{ end }}hmac_label = {{ .p11_crypto_plugin.barbican.plugin.crypto.p11.hmac_label | default "<None>" }}

# HSM Slot ID (integer value)
# from .p11_crypto_plugin.barbican.plugin.crypto.p11.slot_id
{{ if not .p11_crypto_plugin.barbican.plugin.crypto.p11.slot_id }}#{{ end }}slot_id = {{ .p11_crypto_plugin.barbican.plugin.crypto.p11.slot_id | default "1" }}

# Flag for Read/Write Sessions (boolean value)
# from .p11_crypto_plugin.barbican.plugin.crypto.p11.rw_session
{{ if not .p11_crypto_plugin.barbican.plugin.crypto.p11.rw_session }}#{{ end }}rw_session = {{ .p11_crypto_plugin.barbican.plugin.crypto.p11.rw_session | default "true" }}

# Project KEK length in bytes. (integer value)
# from .p11_crypto_plugin.barbican.plugin.crypto.p11.pkek_length
{{ if not .p11_crypto_plugin.barbican.plugin.crypto.p11.pkek_length }}#{{ end }}pkek_length = {{ .p11_crypto_plugin.barbican.plugin.crypto.p11.pkek_length | default "32" }}

# Project KEK Cache Time To Live, in seconds (integer value)
# from .p11_crypto_plugin.barbican.plugin.crypto.p11.pkek_cache_ttl
{{ if not .p11_crypto_plugin.barbican.plugin.crypto.p11.pkek_cache_ttl }}#{{ end }}pkek_cache_ttl = {{ .p11_crypto_plugin.barbican.plugin.crypto.p11.pkek_cache_ttl | default "900" }}

# Project KEK Cache Item Limit (integer value)
# from .p11_crypto_plugin.barbican.plugin.crypto.p11.pkek_cache_limit
{{ if not .p11_crypto_plugin.barbican.plugin.crypto.p11.pkek_cache_limit }}#{{ end }}pkek_cache_limit = {{ .p11_crypto_plugin.barbican.plugin.crypto.p11.pkek_cache_limit | default "100" }}

# Secret encryption algorithm (string value)
# from .p11_crypto_plugin.barbican.plugin.crypto.p11.algorithm
{{ if not .p11_crypto_plugin.barbican.plugin.crypto.p11.algorithm }}#{{ end }}algorithm = {{ .p11_crypto_plugin.barbican.plugin.crypto.p11.algorithm | default "VENDOR_SAFENET_CKM_AES_GCM" }}

# File to pull entropy for seeding RNG (string value)
# from .p11_crypto_plugin.barbican.plugin.crypto.p11.seed_file
{{ if not .p11_crypto_plugin.barbican.plugin.crypto.p11.seed_file }}#{{ end }}seed_file = {{ .p11_crypto_plugin.barbican.plugin.crypto.p11.seed_file | default "" }}

# Amount of data to read from file for seed (integer value)
# from .p11_crypto_plugin.barbican.plugin.crypto.p11.seed_length
{{ if not .p11_crypto_plugin.barbican.plugin.crypto.p11.seed_length }}#{{ end }}seed_length = {{ .p11_crypto_plugin.barbican.plugin.crypto.p11.seed_length | default "32" }}

# User friendly plugin name (string value)
# from .p11_crypto_plugin.barbican.plugin.crypto.p11.plugin_name
{{ if not .p11_crypto_plugin.barbican.plugin.crypto.p11.plugin_name }}#{{ end }}plugin_name = {{ .p11_crypto_plugin.barbican.plugin.crypto.p11.plugin_name | default "PKCS11 HSM" }}


[queue]

#
# From barbican.common.config
#

# True enables queuing, False invokes workers synchronously (boolean
# value)
# from .queue.barbican.common.config.enable
{{ if not .queue.barbican.common.config.enable }}#{{ end }}enable = {{ .queue.barbican.common.config.enable | default "false" }}

# Queue namespace (string value)
# from .queue.barbican.common.config.namespace
{{ if not .queue.barbican.common.config.namespace }}#{{ end }}namespace = {{ .queue.barbican.common.config.namespace | default "barbican" }}

# Queue topic name (string value)
# from .queue.barbican.common.config.topic
{{ if not .queue.barbican.common.config.topic }}#{{ end }}topic = {{ .queue.barbican.common.config.topic | default "barbican.workers" }}

# Version of tasks invoked via queue (string value)
# from .queue.barbican.common.config.version
{{ if not .queue.barbican.common.config.version }}#{{ end }}version = {{ .queue.barbican.common.config.version | default "1.1" }}

# Server name for RPC task processing server (string value)
# from .queue.barbican.common.config.server_name
{{ if not .queue.barbican.common.config.server_name }}#{{ end }}server_name = {{ .queue.barbican.common.config.server_name | default "barbican.queue" }}

# Number of asynchronous worker processes (integer value)
# from .queue.barbican.common.config.asynchronous_workers
{{ if not .queue.barbican.common.config.asynchronous_workers }}#{{ end }}asynchronous_workers = {{ .queue.barbican.common.config.asynchronous_workers | default "1" }}


[quotas]

#
# From barbican.common.config
#

# Number of secrets allowed per project (integer value)
# from .quotas.barbican.common.config.quota_secrets
{{ if not .quotas.barbican.common.config.quota_secrets }}#{{ end }}quota_secrets = {{ .quotas.barbican.common.config.quota_secrets | default "-1" }}

# Number of orders allowed per project (integer value)
# from .quotas.barbican.common.config.quota_orders
{{ if not .quotas.barbican.common.config.quota_orders }}#{{ end }}quota_orders = {{ .quotas.barbican.common.config.quota_orders | default "-1" }}

# Number of containers allowed per project (integer value)
# from .quotas.barbican.common.config.quota_containers
{{ if not .quotas.barbican.common.config.quota_containers }}#{{ end }}quota_containers = {{ .quotas.barbican.common.config.quota_containers | default "-1" }}

# Number of consumers allowed per project (integer value)
# from .quotas.barbican.common.config.quota_consumers
{{ if not .quotas.barbican.common.config.quota_consumers }}#{{ end }}quota_consumers = {{ .quotas.barbican.common.config.quota_consumers | default "-1" }}

# Number of CAs allowed per project (integer value)
# from .quotas.barbican.common.config.quota_cas
{{ if not .quotas.barbican.common.config.quota_cas }}#{{ end }}quota_cas = {{ .quotas.barbican.common.config.quota_cas | default "-1" }}


[retry_scheduler]

#
# From barbican.common.config
#

# Seconds (float) to wait before starting retry scheduler (floating
# point value)
# from .retry_scheduler.barbican.common.config.initial_delay_seconds
{{ if not .retry_scheduler.barbican.common.config.initial_delay_seconds }}#{{ end }}initial_delay_seconds = {{ .retry_scheduler.barbican.common.config.initial_delay_seconds | default "10.0" }}

# Seconds (float) to wait between periodic schedule events (floating
# point value)
# from .retry_scheduler.barbican.common.config.periodic_interval_max_seconds
{{ if not .retry_scheduler.barbican.common.config.periodic_interval_max_seconds }}#{{ end }}periodic_interval_max_seconds = {{ .retry_scheduler.barbican.common.config.periodic_interval_max_seconds | default "10.0" }}


[secretstore]

#
# From barbican.plugin.secret_store
#

# Extension namespace to search for plugins. (string value)
# from .secretstore.barbican.plugin.secret_store.namespace
{{ if not .secretstore.barbican.plugin.secret_store.namespace }}#{{ end }}namespace = {{ .secretstore.barbican.plugin.secret_store.namespace | default "barbican.secretstore.plugin" }}

# List of secret store plugins to load. (multi valued)
# from .secretstore.barbican.plugin.secret_store.enabled_secretstore_plugins (multiopt)
{{ if not .secretstore.barbican.plugin.secret_store.enabled_secretstore_plugins }}#enabled_secretstore_plugins = {{ .secretstore.barbican.plugin.secret_store.enabled_secretstore_plugins | default "store_crypto" }}{{ else }}{{ range .secretstore.barbican.plugin.secret_store.enabled_secretstore_plugins }}enabled_secretstore_plugins = {{ . }}
{{ end }}{{ end }}

# Flag to enable multiple secret store plugin backend support. Default
# is False (boolean value)
# from .secretstore.barbican.plugin.secret_store.enable_multiple_secret_stores
{{ if not .secretstore.barbican.plugin.secret_store.enable_multiple_secret_stores }}#{{ end }}enable_multiple_secret_stores = {{ .secretstore.barbican.plugin.secret_store.enable_multiple_secret_stores | default "false" }}

# List of suffix to use for looking up plugins which are supported
# with multiple backend support. (list value)
# from .secretstore.barbican.plugin.secret_store.stores_lookup_suffix
{{ if not .secretstore.barbican.plugin.secret_store.stores_lookup_suffix }}#{{ end }}stores_lookup_suffix = {{ .secretstore.barbican.plugin.secret_store.stores_lookup_suffix | default "<None>" }}


[simple_crypto_plugin]

#
# From barbican.plugin.crypto.simple
#

# Key encryption key to be used by Simple Crypto Plugin (string value)
# from .simple_crypto_plugin.barbican.plugin.crypto.simple.kek
{{ if not .simple_crypto_plugin.barbican.plugin.crypto.simple.kek }}#{{ end }}kek = {{ .simple_crypto_plugin.barbican.plugin.crypto.simple.kek | default "dGhpcnR5X3R3b19ieXRlX2tleWJsYWhibGFoYmxhaGg=" }}

# User friendly plugin name (string value)
# from .simple_crypto_plugin.barbican.plugin.crypto.simple.plugin_name
{{ if not .simple_crypto_plugin.barbican.plugin.crypto.simple.plugin_name }}#{{ end }}plugin_name = {{ .simple_crypto_plugin.barbican.plugin.crypto.simple.plugin_name | default "Software Only Crypto" }}


[snakeoil_ca_plugin]

#
# From barbican.certificate.plugin.snakeoil
#

# Path to CA certificate file (string value)
# from .snakeoil_ca_plugin.barbican.certificate.plugin.snakeoil.ca_cert_path
{{ if not .snakeoil_ca_plugin.barbican.certificate.plugin.snakeoil.ca_cert_path }}#{{ end }}ca_cert_path = {{ .snakeoil_ca_plugin.barbican.certificate.plugin.snakeoil.ca_cert_path | default "<None>" }}

# Path to CA certificate key file (string value)
# from .snakeoil_ca_plugin.barbican.certificate.plugin.snakeoil.ca_cert_key_path
{{ if not .snakeoil_ca_plugin.barbican.certificate.plugin.snakeoil.ca_cert_key_path }}#{{ end }}ca_cert_key_path = {{ .snakeoil_ca_plugin.barbican.certificate.plugin.snakeoil.ca_cert_key_path | default "<None>" }}

# Path to CA certificate chain file (string value)
# from .snakeoil_ca_plugin.barbican.certificate.plugin.snakeoil.ca_cert_chain_path
{{ if not .snakeoil_ca_plugin.barbican.certificate.plugin.snakeoil.ca_cert_chain_path }}#{{ end }}ca_cert_chain_path = {{ .snakeoil_ca_plugin.barbican.certificate.plugin.snakeoil.ca_cert_chain_path | default "<None>" }}

# Path to CA chain pkcs7 file (string value)
# from .snakeoil_ca_plugin.barbican.certificate.plugin.snakeoil.ca_cert_pkcs7_path
{{ if not .snakeoil_ca_plugin.barbican.certificate.plugin.snakeoil.ca_cert_pkcs7_path }}#{{ end }}ca_cert_pkcs7_path = {{ .snakeoil_ca_plugin.barbican.certificate.plugin.snakeoil.ca_cert_pkcs7_path | default "<None>" }}

# Directory in which to store certs/keys for subcas (string value)
# from .snakeoil_ca_plugin.barbican.certificate.plugin.snakeoil.subca_cert_key_directory
{{ if not .snakeoil_ca_plugin.barbican.certificate.plugin.snakeoil.subca_cert_key_directory }}#{{ end }}subca_cert_key_directory = {{ .snakeoil_ca_plugin.barbican.certificate.plugin.snakeoil.subca_cert_key_directory | default "/etc/barbican/snakeoil-cas" }}


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
