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

{{ include "keystone.conf.keystone_values_skeleton" .Values.conf.keystone | trunc 0 }}
{{ include "keystone.conf.keystone" .Values.conf.keystone }}


{{- define "keystone.conf.keystone_values_skeleton" -}}

{{- if not .default -}}{{- set . "default" dict -}}{{- end -}}
{{- if not .default.keystone -}}{{- set .default "keystone" dict -}}{{- end -}}
{{- if not .default.oslo -}}{{- set .default "oslo" dict -}}{{- end -}}
{{- if not .default.oslo.log -}}{{- set .default.oslo "log" dict -}}{{- end -}}
{{- if not .default.oslo.messaging -}}{{- set .default.oslo "messaging" dict -}}{{- end -}}
{{- if not .assignment -}}{{- set . "assignment" dict -}}{{- end -}}
{{- if not .assignment.keystone -}}{{- set .assignment "keystone" dict -}}{{- end -}}
{{- if not .auth -}}{{- set . "auth" dict -}}{{- end -}}
{{- if not .auth.keystone -}}{{- set .auth "keystone" dict -}}{{- end -}}
{{- if not .cache -}}{{- set . "cache" dict -}}{{- end -}}
{{- if not .cache.oslo -}}{{- set .cache "oslo" dict -}}{{- end -}}
{{- if not .cache.oslo.cache -}}{{- set .cache.oslo "cache" dict -}}{{- end -}}
{{- if not .catalog -}}{{- set . "catalog" dict -}}{{- end -}}
{{- if not .catalog.keystone -}}{{- set .catalog "keystone" dict -}}{{- end -}}
{{- if not .cors -}}{{- set . "cors" dict -}}{{- end -}}
{{- if not .cors.oslo -}}{{- set .cors "oslo" dict -}}{{- end -}}
{{- if not .cors.oslo.middleware -}}{{- set .cors.oslo "middleware" dict -}}{{- end -}}
{{- if not .cors.subdomain -}}{{- set .cors "subdomain" dict -}}{{- end -}}
{{- if not .cors.subdomain.oslo -}}{{- set .cors.subdomain "oslo" dict -}}{{- end -}}
{{- if not .cors.subdomain.oslo.middleware -}}{{- set .cors.subdomain.oslo "middleware" dict -}}{{- end -}}
{{- if not .credential -}}{{- set . "credential" dict -}}{{- end -}}
{{- if not .credential.keystone -}}{{- set .credential "keystone" dict -}}{{- end -}}
{{- if not .database -}}{{- set . "database" dict -}}{{- end -}}
{{- if not .database.oslo -}}{{- set .database "oslo" dict -}}{{- end -}}
{{- if not .database.oslo.db -}}{{- set .database.oslo "db" dict -}}{{- end -}}
{{- if not .domain_config -}}{{- set . "domain_config" dict -}}{{- end -}}
{{- if not .domain_config.keystone -}}{{- set .domain_config "keystone" dict -}}{{- end -}}
{{- if not .endpoint_filter -}}{{- set . "endpoint_filter" dict -}}{{- end -}}
{{- if not .endpoint_filter.keystone -}}{{- set .endpoint_filter "keystone" dict -}}{{- end -}}
{{- if not .endpoint_policy -}}{{- set . "endpoint_policy" dict -}}{{- end -}}
{{- if not .endpoint_policy.keystone -}}{{- set .endpoint_policy "keystone" dict -}}{{- end -}}
{{- if not .eventlet_server -}}{{- set . "eventlet_server" dict -}}{{- end -}}
{{- if not .eventlet_server.keystone -}}{{- set .eventlet_server "keystone" dict -}}{{- end -}}
{{- if not .federation -}}{{- set . "federation" dict -}}{{- end -}}
{{- if not .federation.keystone -}}{{- set .federation "keystone" dict -}}{{- end -}}
{{- if not .fernet_tokens -}}{{- set . "fernet_tokens" dict -}}{{- end -}}
{{- if not .fernet_tokens.keystone -}}{{- set .fernet_tokens "keystone" dict -}}{{- end -}}
{{- if not .identity -}}{{- set . "identity" dict -}}{{- end -}}
{{- if not .identity.keystone -}}{{- set .identity "keystone" dict -}}{{- end -}}
{{- if not .identity_mapping -}}{{- set . "identity_mapping" dict -}}{{- end -}}
{{- if not .identity_mapping.keystone -}}{{- set .identity_mapping "keystone" dict -}}{{- end -}}
{{- if not .kvs -}}{{- set . "kvs" dict -}}{{- end -}}
{{- if not .kvs.keystone -}}{{- set .kvs "keystone" dict -}}{{- end -}}
{{- if not .ldap -}}{{- set . "ldap" dict -}}{{- end -}}
{{- if not .ldap.keystone -}}{{- set .ldap "keystone" dict -}}{{- end -}}
{{- if not .matchmaker_redis -}}{{- set . "matchmaker_redis" dict -}}{{- end -}}
{{- if not .matchmaker_redis.oslo -}}{{- set .matchmaker_redis "oslo" dict -}}{{- end -}}
{{- if not .matchmaker_redis.oslo.messaging -}}{{- set .matchmaker_redis.oslo "messaging" dict -}}{{- end -}}
{{- if not .memcache -}}{{- set . "memcache" dict -}}{{- end -}}
{{- if not .memcache.keystone -}}{{- set .memcache "keystone" dict -}}{{- end -}}
{{- if not .oauth1 -}}{{- set . "oauth1" dict -}}{{- end -}}
{{- if not .oauth1.keystone -}}{{- set .oauth1 "keystone" dict -}}{{- end -}}
{{- if not .os_inherit -}}{{- set . "os_inherit" dict -}}{{- end -}}
{{- if not .os_inherit.keystone -}}{{- set .os_inherit "keystone" dict -}}{{- end -}}
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
{{- if not .paste_deploy -}}{{- set . "paste_deploy" dict -}}{{- end -}}
{{- if not .paste_deploy.keystone -}}{{- set .paste_deploy "keystone" dict -}}{{- end -}}
{{- if not .policy -}}{{- set . "policy" dict -}}{{- end -}}
{{- if not .policy.keystone -}}{{- set .policy "keystone" dict -}}{{- end -}}
{{- if not .profiler -}}{{- set . "profiler" dict -}}{{- end -}}
{{- if not .profiler.osprofiler -}}{{- set .profiler "osprofiler" dict -}}{{- end -}}
{{- if not .resource -}}{{- set . "resource" dict -}}{{- end -}}
{{- if not .resource.keystone -}}{{- set .resource "keystone" dict -}}{{- end -}}
{{- if not .revoke -}}{{- set . "revoke" dict -}}{{- end -}}
{{- if not .revoke.keystone -}}{{- set .revoke "keystone" dict -}}{{- end -}}
{{- if not .role -}}{{- set . "role" dict -}}{{- end -}}
{{- if not .role.keystone -}}{{- set .role "keystone" dict -}}{{- end -}}
{{- if not .saml -}}{{- set . "saml" dict -}}{{- end -}}
{{- if not .saml.keystone -}}{{- set .saml "keystone" dict -}}{{- end -}}
{{- if not .security_compliance -}}{{- set . "security_compliance" dict -}}{{- end -}}
{{- if not .security_compliance.keystone -}}{{- set .security_compliance "keystone" dict -}}{{- end -}}
{{- if not .shadow_users -}}{{- set . "shadow_users" dict -}}{{- end -}}
{{- if not .shadow_users.keystone -}}{{- set .shadow_users "keystone" dict -}}{{- end -}}
{{- if not .signing -}}{{- set . "signing" dict -}}{{- end -}}
{{- if not .signing.keystone -}}{{- set .signing "keystone" dict -}}{{- end -}}
{{- if not .token -}}{{- set . "token" dict -}}{{- end -}}
{{- if not .token.keystone -}}{{- set .token "keystone" dict -}}{{- end -}}
{{- if not .tokenless_auth -}}{{- set . "tokenless_auth" dict -}}{{- end -}}
{{- if not .tokenless_auth.keystone -}}{{- set .tokenless_auth "keystone" dict -}}{{- end -}}
{{- if not .trust -}}{{- set . "trust" dict -}}{{- end -}}
{{- if not .trust.keystone -}}{{- set .trust "keystone" dict -}}{{- end -}}

{{- end -}}


{{- define "keystone.conf.keystone" -}}

[DEFAULT]

#
# From keystone
#

# Using this feature is *NOT* recommended. Instead, use the `keystone-manage
# bootstrap` command. The value of this option is treated as a "shared secret"
# that can be used to bootstrap Keystone through the API. This "token" does not
# represent a user (it has no identity), and carries no explicit authorization
# (it effectively bypasses most authorization checks). If set to `None`, the
# value is ignored and the `admin_token` middleware is effectively disabled.
# However, to completely disable `admin_token` in production (highly
# recommended, as it presents a security risk), remove
# `AdminTokenAuthMiddleware` (the `admin_token_auth` filter) from your paste
# application pipelines (for example, in `keystone-paste.ini`). (string value)
# from .default.keystone.admin_token
{{ if not .default.keystone.admin_token }}#{{ end }}admin_token = {{ .default.keystone.admin_token | default "<None>" }}

# The base public endpoint URL for Keystone that is advertised to clients
# (NOTE: this does NOT affect how Keystone listens for connections). Defaults
# to the base host URL of the request. For example, if keystone receives a
# request to `http://server:5000/v3/users`, then this will option will be
# automatically treated as `http://server:5000`. You should only need to set
# option if either the value of the base URL contains a path that keystone does
# not automatically infer (`/prefix/v3`), or if the endpoint should be found on
# a different host. (string value)
# from .default.keystone.public_endpoint
{{ if not .default.keystone.public_endpoint }}#{{ end }}public_endpoint = {{ .default.keystone.public_endpoint | default "<None>" }}

# The base admin endpoint URL for Keystone that is advertised to clients (NOTE:
# this does NOT affect how Keystone listens for connections). Defaults to the
# base host URL of the request. For example, if keystone receives a request to
# `http://server:35357/v3/users`, then this will option will be automatically
# treated as `http://server:35357`. You should only need to set option if
# either the value of the base URL contains a path that keystone does not
# automatically infer (`/prefix/v3`), or if the endpoint should be found on a
# different host. (string value)
# from .default.keystone.admin_endpoint
{{ if not .default.keystone.admin_endpoint }}#{{ end }}admin_endpoint = {{ .default.keystone.admin_endpoint | default "<None>" }}

# Maximum depth of the project hierarchy, excluding the project acting as a
# domain at the top of the hierarchy. WARNING: Setting it to a large value may
# adversely impact performance. (integer value)
# from .default.keystone.max_project_tree_depth
{{ if not .default.keystone.max_project_tree_depth }}#{{ end }}max_project_tree_depth = {{ .default.keystone.max_project_tree_depth | default "5" }}

# Limit the sizes of user & project ID/names. (integer value)
# from .default.keystone.max_param_size
{{ if not .default.keystone.max_param_size }}#{{ end }}max_param_size = {{ .default.keystone.max_param_size | default "64" }}

# Similar to `[DEFAULT] max_param_size`, but provides an exception for token
# values. With PKI / PKIZ tokens, this needs to be set close to 8192 (any
# higher, and other HTTP implementations may break), depending on the size of
# your service catalog and other factors. With Fernet tokens, this can be set
# as low as 255. With UUID tokens, this should be set to 32). (integer value)
# from .default.keystone.max_token_size
{{ if not .default.keystone.max_token_size }}#{{ end }}max_token_size = {{ .default.keystone.max_token_size | default "8192" }}

# Similar to the `[DEFAULT] member_role_name` option, this represents the
# default role ID used to associate users with their default projects in the v2
# API. This will be used as the explicit role where one is not specified by the
# v2 API. You do not need to set this value unless you want keystone to use an
# existing role with a different ID, other than the arbitrarily defined
# `_member_` role (in which case, you should set `[DEFAULT] member_role_name`
# as well). (string value)
# from .default.keystone.member_role_id
{{ if not .default.keystone.member_role_id }}#{{ end }}member_role_id = {{ .default.keystone.member_role_id | default "9fe2ff9ee4384b1894a90878d3e92bab" }}

# This is the role name used in combination with the `[DEFAULT] member_role_id`
# option; see that option for more detail. You do not need to set this option
# unless you want keystone to use an existing role (in which case, you should
# set `[DEFAULT] member_role_id` as well). (string value)
# from .default.keystone.member_role_name
{{ if not .default.keystone.member_role_name }}#{{ end }}member_role_name = {{ .default.keystone.member_role_name | default "_member_" }}

# The value passed as the keyword "rounds" to passlib's encrypt method. This
# option represents a trade off between security and performance. Higher values
# lead to slower performance, but higher security. Changing this option will
# only affect newly created passwords as existing password hashes already have
# a fixed number of rounds applied, so it is safe to tune this option in a
# running cluster. For more information, see
# https://pythonhosted.org/passlib/password_hash_api.html#choosing-the-right-
# rounds-value (integer value)
# Minimum value: 1000
# Maximum value: 100000
# from .default.keystone.crypt_strength
{{ if not .default.keystone.crypt_strength }}#{{ end }}crypt_strength = {{ .default.keystone.crypt_strength | default "10000" }}

# The maximum number of entities that will be returned in a collection. This
# global limit may be then overridden for a specific driver, by specifying a
# list_limit in the appropriate section (for example, `[assignment]`). No limit
# is set by default. In larger deployments, it is recommended that you set this
# to a reasonable number to prevent operations like listing all users and
# projects from placing an unnecessary load on the system. (integer value)
# from .default.keystone.list_limit
{{ if not .default.keystone.list_limit }}#{{ end }}list_limit = {{ .default.keystone.list_limit | default "<None>" }}

# DEPRECATED: Set this to false if you want to enable the ability for user,
# group and project entities to be moved between domains by updating their
# `domain_id` attribute. Allowing such movement is not recommended if the scope
# of a domain admin is being restricted by use of an appropriate policy file
# (see `etc/policy.v3cloudsample.json` as an example). This feature is
# deprecated and will be removed in a future release, in favor of strictly
# immutable domain IDs. (boolean value)
# This option is deprecated for removal since M.
# Its value may be silently ignored in the future.
# Reason: The option to set domain_id_immutable to false has been deprecated in
# the M release and will be removed in the O release.
# from .default.keystone.domain_id_immutable
{{ if not .default.keystone.domain_id_immutable }}#{{ end }}domain_id_immutable = {{ .default.keystone.domain_id_immutable | default "true" }}

# If set to true, strict password length checking is performed for password
# manipulation. If a password exceeds the maximum length, the operation will
# fail with an HTTP 403 Forbidden error. If set to false, passwords are
# automatically truncated to the maximum length. (boolean value)
# from .default.keystone.strict_password_check
{{ if not .default.keystone.strict_password_check }}#{{ end }}strict_password_check = {{ .default.keystone.strict_password_check | default "false" }}

# DEPRECATED: The HTTP header used to determine the scheme for the original
# request, even if it was removed by an SSL terminating proxy. (string value)
# This option is deprecated for removal since N.
# Its value may be silently ignored in the future.
# Reason: This option has been deprecated in the N release and will be removed
# in the P release. Use oslo.middleware.http_proxy_to_wsgi configuration
# instead.
# from .default.keystone.secure_proxy_ssl_header
{{ if not .default.keystone.secure_proxy_ssl_header }}#{{ end }}secure_proxy_ssl_header = {{ .default.keystone.secure_proxy_ssl_header | default "HTTP_X_FORWARDED_PROTO" }}

# If set to true, then the server will return information in HTTP responses
# that may allow an unauthenticated or authenticated user to get more
# information than normal, such as additional details about why authentication
# failed. This may be useful for debugging but is insecure. (boolean value)
# from .default.keystone.insecure_debug
{{ if not .default.keystone.insecure_debug }}#{{ end }}insecure_debug = {{ .default.keystone.insecure_debug | default "false" }}

# Default `publisher_id` for outgoing notifications. If left undefined,
# Keystone will default to using the server's host name. (string value)
# from .default.keystone.default_publisher_id
{{ if not .default.keystone.default_publisher_id }}#{{ end }}default_publisher_id = {{ .default.keystone.default_publisher_id | default "<None>" }}

# Define the notification format for identity service events. A `basic`
# notification only has information about the resource being operated on. A
# `cadf` notification has the same information, as well as information about
# the initiator of the event. The `cadf` option is entirely backwards
# compatible with the `basic` option, but is fully CADF-compliant, and is
# recommended for auditing use cases. (string value)
# Allowed values: basic, cadf
# from .default.keystone.notification_format
{{ if not .default.keystone.notification_format }}#{{ end }}notification_format = {{ .default.keystone.notification_format | default "basic" }}

# If left undefined, keystone will emit notifications for all types of events.
# You can reduce the number of notifications keystone emits by using this
# option to enumerate notification topics that should be suppressed. Values are
# expected to be in the form `identity.<resource_type>.<operation>`. This field
# can be set multiple times in order to opt-out of multiple notification
# topics. For example: notification_opt_out=identity.user.create
# notification_opt_out=identity.authenticate.success (multi valued)
# from .default.keystone.notification_opt_out (multiopt)
{{ if not .default.keystone.notification_opt_out }}#notification_opt_out = {{ .default.keystone.notification_opt_out | default "" }}{{ else }}{{ range .default.keystone.notification_opt_out }}notification_opt_out = {{ . }}
{{ end }}{{ end }}

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
{{ if not .default.oslo.messaging.control_exchange }}#{{ end }}control_exchange = {{ .default.oslo.messaging.control_exchange | default "keystone" }}


[assignment]

#
# From keystone
#

# Entry point for the assignment backend driver (where role assignments are
# stored) in the `keystone.assignment` namespace. Only a SQL driver is supplied
# by keystone itself. If an assignment driver is not specified, the identity
# driver will choose the assignment driver based on the deprecated
# `[identity]/driver` option (the behavior will be removed in the "O" release).
# Unless you are writing proprietary drivers for keystone, you do not need to
# set this option. (string value)
# from .assignment.keystone.driver
{{ if not .assignment.keystone.driver }}#{{ end }}driver = {{ .assignment.keystone.driver | default "<None>" }}

# A list of role names which are prohibited from being an implied role. (list
# value)
# from .assignment.keystone.prohibited_implied_role
{{ if not .assignment.keystone.prohibited_implied_role }}#{{ end }}prohibited_implied_role = {{ .assignment.keystone.prohibited_implied_role | default "admin" }}


[auth]

#
# From keystone
#

# Allowed authentication methods. (list value)
# from .auth.keystone.methods
{{ if not .auth.keystone.methods }}#{{ end }}methods = {{ .auth.keystone.methods | default "external,password,token,oauth1" }}

# Entry point for the password auth plugin module in the
# `keystone.auth.password` namespace. You do not need to set this unless you
# are overriding keystone's own password authentication plugin. (string value)
# from .auth.keystone.password
{{ if not .auth.keystone.password }}#{{ end }}password = {{ .auth.keystone.password | default "<None>" }}

# Entry point for the token auth plugin module in the `keystone.auth.token`
# namespace. You do not need to set this unless you are overriding keystone's
# own token authentication plugin. (string value)
# from .auth.keystone.token
{{ if not .auth.keystone.token }}#{{ end }}token = {{ .auth.keystone.token | default "<None>" }}

# Entry point for the external (`REMOTE_USER`) auth plugin module in the
# `keystone.auth.external` namespace. Supplied drivers are `DefaultDomain` and
# `Domain`. The default driver is `DefaultDomain`, which assumes that all users
# identified by the username specified to keystone in the `REMOTE_USER`
# variable exist within the context of the default domain. The `Domain` option
# expects an additional environment variable be presented to keystone,
# `REMOTE_DOMAIN`, containing the domain name of the `REMOTE_USER` (if
# `REMOTE_DOMAIN` is not set, then the default domain will be used instead).
# You do not need to set this unless you are taking advantage of "external
# authentication", where the application server (such as Apache) is handling
# authentication instead of keystone. (string value)
# from .auth.keystone.external
{{ if not .auth.keystone.external }}#{{ end }}external = {{ .auth.keystone.external | default "<None>" }}

# Entry point for the OAuth 1.0a auth plugin module in the
# `keystone.auth.oauth1` namespace. You do not need to set this unless you are
# overriding keystone's own `oauth1` authentication plugin. (string value)
# from .auth.keystone.oauth1
{{ if not .auth.keystone.oauth1 }}#{{ end }}oauth1 = {{ .auth.keystone.oauth1 | default "<None>" }}


[cache]

#
# From oslo.cache
#

# Prefix for building the configuration dictionary for the cache region. This
# should not need to be changed unless there is another dogpile.cache region
# with the same configuration name. (string value)
# from .cache.oslo.cache.config_prefix
{{ if not .cache.oslo.cache.config_prefix }}#{{ end }}config_prefix = {{ .cache.oslo.cache.config_prefix | default "cache.oslo" }}

# Default TTL, in seconds, for any cached item in the dogpile.cache region.
# This applies to any cached method that doesn't have an explicit cache
# expiration time defined for it. (integer value)
# from .cache.oslo.cache.expiration_time
{{ if not .cache.oslo.cache.expiration_time }}#{{ end }}expiration_time = {{ .cache.oslo.cache.expiration_time | default "600" }}

# Dogpile.cache backend module. It is recommended that Memcache or Redis
# (dogpile.cache.redis) be used in production deployments. For eventlet-based
# or highly threaded servers, Memcache with pooling (oslo_cache.memcache_pool)
# is recommended. For low thread servers, dogpile.cache.memcached is
# recommended. Test environments with a single instance of the server can use
# the dogpile.cache.memory backend. (string value)
# from .cache.oslo.cache.backend
{{ if not .cache.oslo.cache.backend }}#{{ end }}backend = {{ .cache.oslo.cache.backend | default "dogpile.cache.null" }}

# Arguments supplied to the backend module. Specify this option once per
# argument to be passed to the dogpile.cache backend. Example format:
# "<argname>:<value>". (multi valued)
# from .cache.oslo.cache.backend_argument (multiopt)
{{ if not .cache.oslo.cache.backend_argument }}#backend_argument = {{ .cache.oslo.cache.backend_argument | default "" }}{{ else }}{{ range .cache.oslo.cache.backend_argument }}backend_argument = {{ . }}
{{ end }}{{ end }}

# Proxy classes to import that will affect the way the dogpile.cache backend
# functions. See the dogpile.cache documentation on changing-backend-behavior.
# (list value)
# from .cache.oslo.cache.proxies
{{ if not .cache.oslo.cache.proxies }}#{{ end }}proxies = {{ .cache.oslo.cache.proxies | default "" }}

# Global toggle for caching. (boolean value)
# from .cache.oslo.cache.enabled
{{ if not .cache.oslo.cache.enabled }}#{{ end }}enabled = {{ .cache.oslo.cache.enabled | default "true" }}

# Extra debugging from the cache backend (cache keys, get/set/delete/etc
# calls). This is only really useful if you need to see the specific cache-
# backend get/set/delete calls with the keys/values.  Typically this should be
# left set to false. (boolean value)
# from .cache.oslo.cache.debug_cache_backend
{{ if not .cache.oslo.cache.debug_cache_backend }}#{{ end }}debug_cache_backend = {{ .cache.oslo.cache.debug_cache_backend | default "false" }}

# Memcache servers in the format of "host:port". (dogpile.cache.memcache and
# oslo_cache.memcache_pool backends only). (list value)
# from .cache.oslo.cache.memcache_servers
{{ if not .cache.oslo.cache.memcache_servers }}#{{ end }}memcache_servers = {{ .cache.oslo.cache.memcache_servers | default "localhost:11211" }}

# Number of seconds memcached server is considered dead before it is tried
# again. (dogpile.cache.memcache and oslo_cache.memcache_pool backends only).
# (integer value)
# from .cache.oslo.cache.memcache_dead_retry
{{ if not .cache.oslo.cache.memcache_dead_retry }}#{{ end }}memcache_dead_retry = {{ .cache.oslo.cache.memcache_dead_retry | default "300" }}

# Timeout in seconds for every call to a server. (dogpile.cache.memcache and
# oslo_cache.memcache_pool backends only). (integer value)
# from .cache.oslo.cache.memcache_socket_timeout
{{ if not .cache.oslo.cache.memcache_socket_timeout }}#{{ end }}memcache_socket_timeout = {{ .cache.oslo.cache.memcache_socket_timeout | default "3" }}

# Max total number of open connections to every memcached server.
# (oslo_cache.memcache_pool backend only). (integer value)
# from .cache.oslo.cache.memcache_pool_maxsize
{{ if not .cache.oslo.cache.memcache_pool_maxsize }}#{{ end }}memcache_pool_maxsize = {{ .cache.oslo.cache.memcache_pool_maxsize | default "10" }}

# Number of seconds a connection to memcached is held unused in the pool before
# it is closed. (oslo_cache.memcache_pool backend only). (integer value)
# from .cache.oslo.cache.memcache_pool_unused_timeout
{{ if not .cache.oslo.cache.memcache_pool_unused_timeout }}#{{ end }}memcache_pool_unused_timeout = {{ .cache.oslo.cache.memcache_pool_unused_timeout | default "60" }}

# Number of seconds that an operation will wait to get a memcache client
# connection. (integer value)
# from .cache.oslo.cache.memcache_pool_connection_get_timeout
{{ if not .cache.oslo.cache.memcache_pool_connection_get_timeout }}#{{ end }}memcache_pool_connection_get_timeout = {{ .cache.oslo.cache.memcache_pool_connection_get_timeout | default "10" }}


[catalog]

#
# From keystone
#

# Absolute path to the file used for the templated catalog backend. This option
# is only used if the `[catalog] driver` is set to `templated`. (string value)
# from .catalog.keystone.template_file
{{ if not .catalog.keystone.template_file }}#{{ end }}template_file = {{ .catalog.keystone.template_file | default "default_catalog.templates" }}

# Entry point for the catalog driver in the `keystone.catalog` namespace.
# Keystone provides a `sql` option (which supports basic CRUD operations
# through SQL), a `templated` option (which loads the catalog from a templated
# catalog file on disk), and a `endpoint_filter.sql` option (which supports
# arbitrary service catalogs per project). (string value)
# from .catalog.keystone.driver
{{ if not .catalog.keystone.driver }}#{{ end }}driver = {{ .catalog.keystone.driver | default "sql" }}

# Toggle for catalog caching. This has no effect unless global caching is
# enabled. In a typical deployment, there is no reason to disable this.
# (boolean value)
# from .catalog.keystone.caching
{{ if not .catalog.keystone.caching }}#{{ end }}caching = {{ .catalog.keystone.caching | default "true" }}

# Time to cache catalog data (in seconds). This has no effect unless global and
# catalog caching are both enabled. Catalog data (services, endpoints, etc.)
# typically does not change frequently, and so a longer duration than the
# global default may be desirable. (integer value)
# from .catalog.keystone.cache_time
{{ if not .catalog.keystone.cache_time }}#{{ end }}cache_time = {{ .catalog.keystone.cache_time | default "<None>" }}

# Maximum number of entities that will be returned in a catalog collection.
# There is typically no reason to set this, as it would be unusual for a
# deployment to have enough services or endpoints to exceed a reasonable limit.
# (integer value)
# from .catalog.keystone.list_limit
{{ if not .catalog.keystone.list_limit }}#{{ end }}list_limit = {{ .catalog.keystone.list_limit | default "<None>" }}


[cors]

#
# From oslo.middleware
#

# Indicate whether this resource may be shared with the domain received in the
# requests "origin" header. Format: "<protocol>://<host>[:<port>]", no trailing
# slash. Example: https://horizon.example.com (list value)
# from .cors.oslo.middleware.allowed_origin
{{ if not .cors.oslo.middleware.allowed_origin }}#{{ end }}allowed_origin = {{ .cors.oslo.middleware.allowed_origin | default "<None>" }}

# Indicate that the actual request can include user credentials (boolean value)
# from .cors.oslo.middleware.allow_credentials
{{ if not .cors.oslo.middleware.allow_credentials }}#{{ end }}allow_credentials = {{ .cors.oslo.middleware.allow_credentials | default "true" }}

# Indicate which headers are safe to expose to the API. Defaults to HTTP Simple
# Headers. (list value)
# from .cors.oslo.middleware.expose_headers
{{ if not .cors.oslo.middleware.expose_headers }}#{{ end }}expose_headers = {{ .cors.oslo.middleware.expose_headers | default "X-Auth-Token,X-Openstack-Request-Id,X-Subject-Token" }}

# Maximum cache age of CORS preflight requests. (integer value)
# from .cors.oslo.middleware.max_age
{{ if not .cors.oslo.middleware.max_age }}#{{ end }}max_age = {{ .cors.oslo.middleware.max_age | default "3600" }}

# Indicate which methods can be used during the actual request. (list value)
# from .cors.oslo.middleware.allow_methods
{{ if not .cors.oslo.middleware.allow_methods }}#{{ end }}allow_methods = {{ .cors.oslo.middleware.allow_methods | default "GET,PUT,POST,DELETE,PATCH" }}

# Indicate which header field names may be used during the actual request.
# (list value)
# from .cors.oslo.middleware.allow_headers
{{ if not .cors.oslo.middleware.allow_headers }}#{{ end }}allow_headers = {{ .cors.oslo.middleware.allow_headers | default "X-Auth-Token,X-Openstack-Request-Id,X-Subject-Token,X-Project-Id,X-Project-Name,X-Project-Domain-Id,X-Project-Domain-Name,X-Domain-Id,X-Domain-Name" }}


[cors.subdomain]

#
# From oslo.middleware
#

# Indicate whether this resource may be shared with the domain received in the
# requests "origin" header. Format: "<protocol>://<host>[:<port>]", no trailing
# slash. Example: https://horizon.example.com (list value)
# from .cors.subdomain.oslo.middleware.allowed_origin
{{ if not .cors.subdomain.oslo.middleware.allowed_origin }}#{{ end }}allowed_origin = {{ .cors.subdomain.oslo.middleware.allowed_origin | default "<None>" }}

# Indicate that the actual request can include user credentials (boolean value)
# from .cors.subdomain.oslo.middleware.allow_credentials
{{ if not .cors.subdomain.oslo.middleware.allow_credentials }}#{{ end }}allow_credentials = {{ .cors.subdomain.oslo.middleware.allow_credentials | default "true" }}

# Indicate which headers are safe to expose to the API. Defaults to HTTP Simple
# Headers. (list value)
# from .cors.subdomain.oslo.middleware.expose_headers
{{ if not .cors.subdomain.oslo.middleware.expose_headers }}#{{ end }}expose_headers = {{ .cors.subdomain.oslo.middleware.expose_headers | default "X-Auth-Token,X-Openstack-Request-Id,X-Subject-Token" }}

# Maximum cache age of CORS preflight requests. (integer value)
# from .cors.subdomain.oslo.middleware.max_age
{{ if not .cors.subdomain.oslo.middleware.max_age }}#{{ end }}max_age = {{ .cors.subdomain.oslo.middleware.max_age | default "3600" }}

# Indicate which methods can be used during the actual request. (list value)
# from .cors.subdomain.oslo.middleware.allow_methods
{{ if not .cors.subdomain.oslo.middleware.allow_methods }}#{{ end }}allow_methods = {{ .cors.subdomain.oslo.middleware.allow_methods | default "GET,PUT,POST,DELETE,PATCH" }}

# Indicate which header field names may be used during the actual request.
# (list value)
# from .cors.subdomain.oslo.middleware.allow_headers
{{ if not .cors.subdomain.oslo.middleware.allow_headers }}#{{ end }}allow_headers = {{ .cors.subdomain.oslo.middleware.allow_headers | default "X-Auth-Token,X-Openstack-Request-Id,X-Subject-Token,X-Project-Id,X-Project-Name,X-Project-Domain-Id,X-Project-Domain-Name,X-Domain-Id,X-Domain-Name" }}


[credential]

#
# From keystone
#

# Entry point for the credential backend driver in the `keystone.credential`
# namespace. Keystone only provides a `sql` driver, so there's no reason to
# change this unless you are providing a custom entry point. (string value)
# from .credential.keystone.driver
{{ if not .credential.keystone.driver }}#{{ end }}driver = {{ .credential.keystone.driver | default "sql" }}

# Entry point for credential encryption and decryption operations in the
# `keystone.credential.provider` namespace. Keystone only provides a `fernet`
# driver, so there's no reason to change this unless you are providing a custom
# entry point to encrypt and decrypt credentials. (string value)
# from .credential.keystone.provider
{{ if not .credential.keystone.provider }}#{{ end }}provider = {{ .credential.keystone.provider | default "fernet" }}

# Directory containing Fernet keys used to encrypt and decrypt credentials
# stored in the credential backend. Fernet keys used to encrypt credentials
# have no relationship to Fernet keys used to encrypt Fernet tokens. Both sets
# of keys should be managed separately and require different rotation policies.
# Do not share this repository with the repository used to manage keys for
# Fernet tokens. (string value)
# from .credential.keystone.key_repository
{{ if not .credential.keystone.key_repository }}#{{ end }}key_repository = {{ .credential.keystone.key_repository | default "/etc/keystone/credential-keys/" }}


[database]

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


[domain_config]

#
# From keystone
#

# Entry point for the domain-specific configuration driver in the
# `keystone.resource.domain_config` namespace. Only a `sql` option is provided
# by keystone, so there is no reason to set this unless you are providing a
# custom entry point. (string value)
# from .domain_config.keystone.driver
{{ if not .domain_config.keystone.driver }}#{{ end }}driver = {{ .domain_config.keystone.driver | default "sql" }}

# Toggle for caching of the domain-specific configuration backend. This has no
# effect unless global caching is enabled. There is normally no reason to
# disable this. (boolean value)
# from .domain_config.keystone.caching
{{ if not .domain_config.keystone.caching }}#{{ end }}caching = {{ .domain_config.keystone.caching | default "true" }}

# Time-to-live (TTL, in seconds) to cache domain-specific configuration data.
# This has no effect unless `[domain_config] caching` is enabled. (integer
# value)
# from .domain_config.keystone.cache_time
{{ if not .domain_config.keystone.cache_time }}#{{ end }}cache_time = {{ .domain_config.keystone.cache_time | default "300" }}


[endpoint_filter]

#
# From keystone
#

# Entry point for the endpoint filter driver in the `keystone.endpoint_filter`
# namespace. Only a `sql` option is provided by keystone, so there is no reason
# to set this unless you are providing a custom entry point. (string value)
# from .endpoint_filter.keystone.driver
{{ if not .endpoint_filter.keystone.driver }}#{{ end }}driver = {{ .endpoint_filter.keystone.driver | default "sql" }}

# This controls keystone's behavior if the configured endpoint filters do not
# result in any endpoints for a user + project pair (and therefore a
# potentially empty service catalog). If set to true, keystone will return the
# entire service catalog. If set to false, keystone will return an empty
# service catalog. (boolean value)
# from .endpoint_filter.keystone.return_all_endpoints_if_no_filter
{{ if not .endpoint_filter.keystone.return_all_endpoints_if_no_filter }}#{{ end }}return_all_endpoints_if_no_filter = {{ .endpoint_filter.keystone.return_all_endpoints_if_no_filter | default "true" }}


[endpoint_policy]

#
# From keystone
#

# DEPRECATED: Enable endpoint-policy functionality, which allows policies to be
# associated with either specific endpoints, or endpoints of a given service
# type. (boolean value)
# This option is deprecated for removal since M.
# Its value may be silently ignored in the future.
# Reason: The option to enable the OS-ENDPOINT-POLICY API extension has been
# deprecated in the M release and will be removed in the O release. The OS-
# ENDPOINT-POLICY API extension will be enabled by default.
# from .endpoint_policy.keystone.enabled
{{ if not .endpoint_policy.keystone.enabled }}#{{ end }}enabled = {{ .endpoint_policy.keystone.enabled | default "true" }}

# Entry point for the endpoint policy driver in the `keystone.endpoint_policy`
# namespace. Only a `sql` driver is provided by keystone, so there is no reason
# to set this unless you are providing a custom entry point. (string value)
# from .endpoint_policy.keystone.driver
{{ if not .endpoint_policy.keystone.driver }}#{{ end }}driver = {{ .endpoint_policy.keystone.driver | default "sql" }}


[eventlet_server]

#
# From keystone
#

# DEPRECATED: The IP address of the network interface for the public service to
# listen on. (string value)
# Deprecated group/name - [DEFAULT]/bind_host
# Deprecated group/name - [DEFAULT]/public_bind_host
# This option is deprecated for removal since K.
# Its value may be silently ignored in the future.
# Reason: Support for running keystone under eventlet has been removed in the
# Newton release. These options remain for backwards compatibility because they
# are used for URL substitutions.
# from .eventlet_server.keystone.public_bind_host
{{ if not .eventlet_server.keystone.public_bind_host }}#{{ end }}public_bind_host = {{ .eventlet_server.keystone.public_bind_host | default "0.0.0.0" }}

# DEPRECATED: The port number for the public service to listen on. (port value)
# Minimum value: 0
# Maximum value: 65535
# Deprecated group/name - [DEFAULT]/public_port
# This option is deprecated for removal since K.
# Its value may be silently ignored in the future.
# Reason: Support for running keystone under eventlet has been removed in the
# Newton release. These options remain for backwards compatibility because they
# are used for URL substitutions.
# from .eventlet_server.keystone.public_port
{{ if not .eventlet_server.keystone.public_port }}#{{ end }}public_port = {{ .eventlet_server.keystone.public_port | default "5000" }}

# DEPRECATED: The IP address of the network interface for the admin service to
# listen on. (string value)
# Deprecated group/name - [DEFAULT]/bind_host
# Deprecated group/name - [DEFAULT]/admin_bind_host
# This option is deprecated for removal since K.
# Its value may be silently ignored in the future.
# Reason: Support for running keystone under eventlet has been removed in the
# Newton release. These options remain for backwards compatibility because they
# are used for URL substitutions.
# from .eventlet_server.keystone.admin_bind_host
{{ if not .eventlet_server.keystone.admin_bind_host }}#{{ end }}admin_bind_host = {{ .eventlet_server.keystone.admin_bind_host | default "0.0.0.0" }}

# DEPRECATED: The port number for the admin service to listen on. (port value)
# Minimum value: 0
# Maximum value: 65535
# Deprecated group/name - [DEFAULT]/admin_port
# This option is deprecated for removal since K.
# Its value may be silently ignored in the future.
# Reason: Support for running keystone under eventlet has been removed in the
# Newton release. These options remain for backwards compatibility because they
# are used for URL substitutions.
# from .eventlet_server.keystone.admin_port
{{ if not .eventlet_server.keystone.admin_port }}#{{ end }}admin_port = {{ .eventlet_server.keystone.admin_port | default "35357" }}


[federation]

#
# From keystone
#

# Entry point for the federation backend driver in the `keystone.federation`
# namespace. Keystone only provides a `sql` driver, so there is no reason to
# set this option unless you are providing a custom entry point. (string value)
# from .federation.keystone.driver
{{ if not .federation.keystone.driver }}#{{ end }}driver = {{ .federation.keystone.driver | default "sql" }}

# Prefix to use when filtering environment variable names for federated
# assertions. Matched variables are passed into the federated mapping engine.
# (string value)
# from .federation.keystone.assertion_prefix
{{ if not .federation.keystone.assertion_prefix }}#{{ end }}assertion_prefix = {{ .federation.keystone.assertion_prefix | default "" }}

# Value to be used to obtain the entity ID of the Identity Provider from the
# environment. For `mod_shib`, this would be `Shib-Identity-Provider`. For For
# `mod_auth_openidc`, this could be `HTTP_OIDC_ISS`. For `mod_auth_mellon`,
# this could be `MELLON_IDP`. (string value)
# from .federation.keystone.remote_id_attribute
{{ if not .federation.keystone.remote_id_attribute }}#{{ end }}remote_id_attribute = {{ .federation.keystone.remote_id_attribute | default "<None>" }}

# An arbitrary domain name that is reserved to allow federated ephemeral users
# to have a domain concept. Note that an admin will not be able to create a
# domain with this name or update an existing domain to this name. You are not
# advised to change this value unless you really have to. (string value)
# from .federation.keystone.federated_domain_name
{{ if not .federation.keystone.federated_domain_name }}#{{ end }}federated_domain_name = {{ .federation.keystone.federated_domain_name | default "Federated" }}

# A list of trusted dashboard hosts. Before accepting a Single Sign-On request
# to return a token, the origin host must be a member of this list. This
# configuration option may be repeated for multiple values. You must set this
# in order to use web-based SSO flows. For example:
# trusted_dashboard=https://acme.example.com/auth/websso
# trusted_dashboard=https://beta.example.com/auth/websso (multi valued)
# from .federation.keystone.trusted_dashboard (multiopt)
{{ if not .federation.keystone.trusted_dashboard }}#trusted_dashboard = {{ .federation.keystone.trusted_dashboard | default "" }}{{ else }}{{ range .federation.keystone.trusted_dashboard }}trusted_dashboard = {{ . }}
{{ end }}{{ end }}

# Absolute path to an HTML file used as a Single Sign-On callback handler. This
# page is expected to redirect the user from keystone back to a trusted
# dashboard host, by form encoding a token in a POST request. Keystone's
# default value should be sufficient for most deployments. (string value)
# from .federation.keystone.sso_callback_template
{{ if not .federation.keystone.sso_callback_template }}#{{ end }}sso_callback_template = {{ .federation.keystone.sso_callback_template | default "/etc/keystone/sso_callback_template.html" }}

# Toggle for federation caching. This has no effect unless global caching is
# enabled. There is typically no reason to disable this. (boolean value)
# from .federation.keystone.caching
{{ if not .federation.keystone.caching }}#{{ end }}caching = {{ .federation.keystone.caching | default "true" }}


[fernet_tokens]

#
# From keystone
#

# Directory containing Fernet token keys. This directory must exist before
# using `keystone-manage fernet_setup` for the first time, must be writable by
# the user running `keystone-manage fernet_setup` or `keystone-manage
# fernet_rotate`, and of course must be readable by keystone's server process.
# The repository may contain keys in one of three states: a single staged key
# (always index 0) used for token validation, a single primary key (always the
# highest index) used for token creation and validation, and any number of
# secondary keys (all other index values) used for token validation. With
# multiple keystone nodes, each node must share the same key repository
# contents, with the exception of the staged key (index 0). It is safe to run
# `keystone-manage fernet_rotate` once on any one node to promote a staged key
# (index 0) to be the new primary (incremented from the previous highest
# index), and produce a new staged key (a new key with index 0); the resulting
# repository can then be atomically replicated to other nodes without any risk
# of race conditions (for example, it is safe to run `keystone-manage
# fernet_rotate` on host A, wait any amount of time, create a tarball of the
# directory on host A, unpack it on host B to a temporary location, and
# atomically move (`mv`) the directory into place on host B). Running
# `keystone-manage fernet_rotate` *twice* on a key repository without syncing
# other nodes will result in tokens that can not be validated by all nodes.
# (string value)
# from .fernet_tokens.keystone.key_repository
{{ if not .fernet_tokens.keystone.key_repository }}#{{ end }}key_repository = {{ .fernet_tokens.keystone.key_repository | default "/etc/keystone/fernet-keys/" }}

# This controls how many keys are held in rotation by `keystone-manage
# fernet_rotate` before they are discarded. The default value of 3 means that
# keystone will maintain one staged key (always index 0), one primary key (the
# highest numerical index), and one secondary key (every other index).
# Increasing this value means that additional secondary keys will be kept in
# the rotation. (integer value)
# Minimum value: 1
# from .fernet_tokens.keystone.max_active_keys
{{ if not .fernet_tokens.keystone.max_active_keys }}#{{ end }}max_active_keys = {{ .fernet_tokens.keystone.max_active_keys | default "3" }}


[identity]

#
# From keystone
#

# This references the domain to use for all Identity API v2 requests (which are
# not aware of domains). A domain with this ID can optionally be created for
# you by `keystone-manage bootstrap`. The domain referenced by this ID cannot
# be deleted on the v3 API, to prevent accidentally breaking the v2 API. There
# is nothing special about this domain, other than the fact that it must exist
# to order to maintain support for your v2 clients. There is typically no
# reason to change this value. (string value)
# from .identity.keystone.default_domain_id
{{ if not .identity.keystone.default_domain_id }}#{{ end }}default_domain_id = {{ .identity.keystone.default_domain_id | default "default" }}

# A subset (or all) of domains can have their own identity driver, each with
# their own partial configuration options, stored in either the resource
# backend or in a file in a domain configuration directory (depending on the
# setting of `[identity] domain_configurations_from_database`). Only values
# specific to the domain need to be specified in this manner. This feature is
# disabled by default, but may be enabled by default in a future release; set
# to true to enable. (boolean value)
# from .identity.keystone.domain_specific_drivers_enabled
{{ if not .identity.keystone.domain_specific_drivers_enabled }}#{{ end }}domain_specific_drivers_enabled = {{ .identity.keystone.domain_specific_drivers_enabled | default "false" }}

# By default, domain-specific configuration data is read from files in the
# directory identified by `[identity] domain_config_dir`. Enabling this
# configuration option allows you to instead manage domain-specific
# configurations through the API, which are then persisted in the backend
# (typically, a SQL database), rather than using configuration files on disk.
# (boolean value)
# from .identity.keystone.domain_configurations_from_database
{{ if not .identity.keystone.domain_configurations_from_database }}#{{ end }}domain_configurations_from_database = {{ .identity.keystone.domain_configurations_from_database | default "false" }}

# Absolute path where keystone should locate domain-specific `[identity]`
# configuration files. This option has no effect unless `[identity]
# domain_specific_drivers_enabled` is set to true. There is typically no reason
# to change this value. (string value)
# from .identity.keystone.domain_config_dir
{{ if not .identity.keystone.domain_config_dir }}#{{ end }}domain_config_dir = {{ .identity.keystone.domain_config_dir | default "/etc/keystone/domains" }}

# Entry point for the identity backend driver in the `keystone.identity`
# namespace. Keystone provides a `sql` and `ldap` driver. This option is also
# used as the default driver selection (along with the other configuration
# variables in this section) in the event that `[identity]
# domain_specific_drivers_enabled` is enabled, but no applicable domain-
# specific configuration is defined for the domain in question. Unless your
# deployment primarily relies on `ldap` AND is not using domain-specific
# configuration, you should typically leave this set to `sql`. (string value)
# from .identity.keystone.driver
{{ if not .identity.keystone.driver }}#{{ end }}driver = {{ .identity.keystone.driver | default "sql" }}

# Toggle for identity caching. This has no effect unless global caching is
# enabled. There is typically no reason to disable this. (boolean value)
# from .identity.keystone.caching
{{ if not .identity.keystone.caching }}#{{ end }}caching = {{ .identity.keystone.caching | default "true" }}

# Time to cache identity data (in seconds). This has no effect unless global
# and identity caching are enabled. (integer value)
# from .identity.keystone.cache_time
{{ if not .identity.keystone.cache_time }}#{{ end }}cache_time = {{ .identity.keystone.cache_time | default "600" }}

# Maximum allowed length for user passwords. Decrease this value to improve
# performance. Changing this value does not effect existing passwords. (integer
# value)
# Maximum value: 4096
# from .identity.keystone.max_password_length
{{ if not .identity.keystone.max_password_length }}#{{ end }}max_password_length = {{ .identity.keystone.max_password_length | default "4096" }}

# Maximum number of entities that will be returned in an identity collection.
# (integer value)
# from .identity.keystone.list_limit
{{ if not .identity.keystone.list_limit }}#{{ end }}list_limit = {{ .identity.keystone.list_limit | default "<None>" }}


[identity_mapping]

#
# From keystone
#

# Entry point for the identity mapping backend driver in the
# `keystone.identity.id_mapping` namespace. Keystone only provides a `sql`
# driver, so there is no reason to change this unless you are providing a
# custom entry point. (string value)
# from .identity_mapping.keystone.driver
{{ if not .identity_mapping.keystone.driver }}#{{ end }}driver = {{ .identity_mapping.keystone.driver | default "sql" }}

# Entry point for the public ID generator for user and group entities in the
# `keystone.identity.id_generator` namespace. The Keystone identity mapper only
# supports generators that produce 64 bytes or less. Keystone only provides a
# `sha256` entry point, so there is no reason to change this value unless
# you're providing a custom entry point. (string value)
# from .identity_mapping.keystone.generator
{{ if not .identity_mapping.keystone.generator }}#{{ end }}generator = {{ .identity_mapping.keystone.generator | default "sha256" }}

# The format of user and group IDs changed in Juno for backends that do not
# generate UUIDs (for example, LDAP), with keystone providing a hash mapping to
# the underlying attribute in LDAP. By default this mapping is disabled, which
# ensures that existing IDs will not change. Even when the mapping is enabled
# by using domain-specific drivers (`[identity]
# domain_specific_drivers_enabled`), any users and groups from the default
# domain being handled by LDAP will still not be mapped to ensure their IDs
# remain backward compatible. Setting this value to false will enable the new
# mapping for all backends, including the default LDAP driver. It is only
# guaranteed to be safe to enable this option if you do not already have
# assignments for users and groups from the default LDAP domain, and you
# consider it to be acceptable for Keystone to provide the different IDs to
# clients than it did previously (existing IDs in the API will suddenly
# change). Typically this means that the only time you can set this value to
# false is when configuring a fresh installation, although that is the
# recommended value. (boolean value)
# from .identity_mapping.keystone.backward_compatible_ids
{{ if not .identity_mapping.keystone.backward_compatible_ids }}#{{ end }}backward_compatible_ids = {{ .identity_mapping.keystone.backward_compatible_ids | default "true" }}


[kvs]

#
# From keystone
#

# Extra `dogpile.cache` backend modules to register with the `dogpile.cache`
# library. It is not necessary to set this value unless you are providing a
# custom KVS backend beyond what `dogpile.cache` already supports. (list value)
# from .kvs.keystone.backends
{{ if not .kvs.keystone.backends }}#{{ end }}backends = {{ .kvs.keystone.backends | default "" }}

# Prefix for building the configuration dictionary for the KVS region. This
# should not need to be changed unless there is another `dogpile.cache` region
# with the same configuration name. (string value)
# from .kvs.keystone.config_prefix
{{ if not .kvs.keystone.config_prefix }}#{{ end }}config_prefix = {{ .kvs.keystone.config_prefix | default "keystone.kvs" }}

# Set to false to disable using a key-mangling function, which ensures fixed-
# length keys are used in the KVS store. This is configurable for debugging
# purposes, and it is therefore highly recommended to always leave this set to
# true. (boolean value)
# from .kvs.keystone.enable_key_mangler
{{ if not .kvs.keystone.enable_key_mangler }}#{{ end }}enable_key_mangler = {{ .kvs.keystone.enable_key_mangler | default "true" }}

# Number of seconds after acquiring a distributed lock that the backend should
# consider the lock to be expired. This option should be tuned relative to the
# longest amount of time that it takes to perform a successful operation. If
# this value is set too low, then a cluster will end up performing work
# redundantly. If this value is set too high, then a cluster will not be able
# to efficiently recover and retry after a failed operation. A non-zero value
# is recommended if the backend supports lock timeouts, as zero prevents locks
# from expiring altogether. (integer value)
# Minimum value: 0
# from .kvs.keystone.default_lock_timeout
{{ if not .kvs.keystone.default_lock_timeout }}#{{ end }}default_lock_timeout = {{ .kvs.keystone.default_lock_timeout | default "5" }}


[ldap]

#
# From keystone
#

# URL(s) for connecting to the LDAP server. Multiple LDAP URLs may be specified
# as a comma separated string. The first URL to successfully bind is used for
# the connection. (string value)
# from .ldap.keystone.url
{{ if not .ldap.keystone.url }}#{{ end }}url = {{ .ldap.keystone.url | default "ldap://localhost" }}

# The user name of the administrator bind DN to use when querying the LDAP
# server, if your LDAP server requires it. (string value)
# from .ldap.keystone.user
{{ if not .ldap.keystone.user }}#{{ end }}user = {{ .ldap.keystone.user | default "<None>" }}

# The password of the administrator bind DN to use when querying the LDAP
# server, if your LDAP server requires it. (string value)
# from .ldap.keystone.password
{{ if not .ldap.keystone.password }}#{{ end }}password = {{ .ldap.keystone.password | default "<None>" }}

# The default LDAP server suffix to use, if a DN is not defined via either
# `[ldap] user_tree_dn` or `[ldap] group_tree_dn`. (string value)
# from .ldap.keystone.suffix
{{ if not .ldap.keystone.suffix }}#{{ end }}suffix = {{ .ldap.keystone.suffix | default "cn=example,cn=com" }}

# DEPRECATED: If true, keystone will add a dummy member based on the `[ldap]
# dumb_member` option when creating new groups. This is required if the object
# class for groups requires the `member` attribute. This option is only used
# for write operations. (boolean value)
# This option is deprecated for removal since M.
# Its value may be silently ignored in the future.
# Reason: Write support for the LDAP identity backend has been deprecated in
# the Mitaka release and will be removed in the Ocata release.
# from .ldap.keystone.use_dumb_member
{{ if not .ldap.keystone.use_dumb_member }}#{{ end }}use_dumb_member = {{ .ldap.keystone.use_dumb_member | default "false" }}

# DEPRECATED: DN of the "dummy member" to use when `[ldap] use_dumb_member` is
# enabled. This option is only used for write operations. (string value)
# This option is deprecated for removal since M.
# Its value may be silently ignored in the future.
# Reason: Write support for the LDAP identity backend has been deprecated in
# the Mitaka release and will be removed in the Ocata release.
# from .ldap.keystone.dumb_member
{{ if not .ldap.keystone.dumb_member }}#{{ end }}dumb_member = {{ .ldap.keystone.dumb_member | default "cn=dumb,dc=nonexistent" }}

# DEPRECATED: Delete subtrees using the subtree delete control. Only enable
# this option if your LDAP server supports subtree deletion. This option is
# only used for write operations. (boolean value)
# This option is deprecated for removal since M.
# Its value may be silently ignored in the future.
# Reason: Write support for the LDAP identity backend has been deprecated in
# the Mitaka release and will be removed in the Ocata release.
# from .ldap.keystone.allow_subtree_delete
{{ if not .ldap.keystone.allow_subtree_delete }}#{{ end }}allow_subtree_delete = {{ .ldap.keystone.allow_subtree_delete | default "false" }}

# The search scope which defines how deep to search within the search base. A
# value of `one` (representing `oneLevel` or `singleLevel`) indicates a search
# of objects immediately below to the base object, but does not include the
# base object itself. A value of `sub` (representing `subtree` or
# `wholeSubtree`) indicates a search of both the base object itself and the
# entire subtree below it. (string value)
# Allowed values: one, sub
# from .ldap.keystone.query_scope
{{ if not .ldap.keystone.query_scope }}#{{ end }}query_scope = {{ .ldap.keystone.query_scope | default "one" }}

# Defines the maximum number of results per page that keystone should request
# from the LDAP server when listing objects. A value of zero (`0`) disables
# paging. (integer value)
# Minimum value: 0
# from .ldap.keystone.page_size
{{ if not .ldap.keystone.page_size }}#{{ end }}page_size = {{ .ldap.keystone.page_size | default "0" }}

# The LDAP dereferencing option to use for queries involving aliases. A value
# of `default` falls back to using default dereferencing behavior configured by
# your `ldap.conf`. A value of `never` prevents aliases from being dereferenced
# at all. A value of `searching` dereferences aliases only after name
# resolution. A value of `finding` dereferences aliases only during name
# resolution. A value of `always` dereferences aliases in all cases. (string
# value)
# Allowed values: never, searching, always, finding, default
# from .ldap.keystone.alias_dereferencing
{{ if not .ldap.keystone.alias_dereferencing }}#{{ end }}alias_dereferencing = {{ .ldap.keystone.alias_dereferencing | default "default" }}

# Sets the LDAP debugging level for LDAP calls. A value of 0 means that
# debugging is not enabled. This value is a bitmask, consult your LDAP
# documentation for possible values. (integer value)
# Minimum value: -1
# from .ldap.keystone.debug_level
{{ if not .ldap.keystone.debug_level }}#{{ end }}debug_level = {{ .ldap.keystone.debug_level | default "<None>" }}

# Sets keystone's referral chasing behavior across directory partitions. If
# left unset, the system's default behavior will be used. (boolean value)
# from .ldap.keystone.chase_referrals
{{ if not .ldap.keystone.chase_referrals }}#{{ end }}chase_referrals = {{ .ldap.keystone.chase_referrals | default "<None>" }}

# The search base to use for users. Defaults to the `[ldap] suffix` value.
# (string value)
# from .ldap.keystone.user_tree_dn
{{ if not .ldap.keystone.user_tree_dn }}#{{ end }}user_tree_dn = {{ .ldap.keystone.user_tree_dn | default "<None>" }}

# The LDAP search filter to use for users. (string value)
# from .ldap.keystone.user_filter
{{ if not .ldap.keystone.user_filter }}#{{ end }}user_filter = {{ .ldap.keystone.user_filter | default "<None>" }}

# The LDAP object class to use for users. (string value)
# from .ldap.keystone.user_objectclass
{{ if not .ldap.keystone.user_objectclass }}#{{ end }}user_objectclass = {{ .ldap.keystone.user_objectclass | default "inetOrgPerson" }}

# The LDAP attribute mapped to user IDs in keystone. This must NOT be a
# multivalued attribute. User IDs are expected to be globally unique across
# keystone domains and URL-safe. (string value)
# from .ldap.keystone.user_id_attribute
{{ if not .ldap.keystone.user_id_attribute }}#{{ end }}user_id_attribute = {{ .ldap.keystone.user_id_attribute | default "cn" }}

# The LDAP attribute mapped to user names in keystone. User names are expected
# to be unique only within a keystone domain and are not expected to be URL-
# safe. (string value)
# from .ldap.keystone.user_name_attribute
{{ if not .ldap.keystone.user_name_attribute }}#{{ end }}user_name_attribute = {{ .ldap.keystone.user_name_attribute | default "sn" }}

# The LDAP attribute mapped to user descriptions in keystone. (string value)
# from .ldap.keystone.user_description_attribute
{{ if not .ldap.keystone.user_description_attribute }}#{{ end }}user_description_attribute = {{ .ldap.keystone.user_description_attribute | default "description" }}

# The LDAP attribute mapped to user emails in keystone. (string value)
# from .ldap.keystone.user_mail_attribute
{{ if not .ldap.keystone.user_mail_attribute }}#{{ end }}user_mail_attribute = {{ .ldap.keystone.user_mail_attribute | default "mail" }}

# The LDAP attribute mapped to user passwords in keystone. (string value)
# from .ldap.keystone.user_pass_attribute
{{ if not .ldap.keystone.user_pass_attribute }}#{{ end }}user_pass_attribute = {{ .ldap.keystone.user_pass_attribute | default "userPassword" }}

# The LDAP attribute mapped to the user enabled attribute in keystone. If
# setting this option to `userAccountControl`, then you may be interested in
# setting `[ldap] user_enabled_mask` and `[ldap] user_enabled_default` as well.
# (string value)
# from .ldap.keystone.user_enabled_attribute
{{ if not .ldap.keystone.user_enabled_attribute }}#{{ end }}user_enabled_attribute = {{ .ldap.keystone.user_enabled_attribute | default "enabled" }}

# Logically negate the boolean value of the enabled attribute obtained from the
# LDAP server. Some LDAP servers use a boolean lock attribute where "true"
# means an account is disabled. Setting `[ldap] user_enabled_invert = true`
# will allow these lock attributes to be used. This option will have no effect
# if either the `[ldap] user_enabled_mask` or `[ldap] user_enabled_emulation`
# options are in use. (boolean value)
# from .ldap.keystone.user_enabled_invert
{{ if not .ldap.keystone.user_enabled_invert }}#{{ end }}user_enabled_invert = {{ .ldap.keystone.user_enabled_invert | default "false" }}

# Bitmask integer to select which bit indicates the enabled value if the LDAP
# server represents "enabled" as a bit on an integer rather than as a discrete
# boolean. A value of `0` indicates that the mask is not used. If this is not
# set to `0` the typical value is `2`. This is typically used when `[ldap]
# user_enabled_attribute = userAccountControl`. Setting this option causes
# keystone to ignore the value of `[ldap] user_enabled_invert`. (integer value)
# Minimum value: 0
# from .ldap.keystone.user_enabled_mask
{{ if not .ldap.keystone.user_enabled_mask }}#{{ end }}user_enabled_mask = {{ .ldap.keystone.user_enabled_mask | default "0" }}

# The default value to enable users. This should match an appropriate integer
# value if the LDAP server uses non-boolean (bitmask) values to indicate if a
# user is enabled or disabled. If this is not set to `True`, then the typical
# value is `512`. This is typically used when `[ldap] user_enabled_attribute =
# userAccountControl`. (string value)
# from .ldap.keystone.user_enabled_default
{{ if not .ldap.keystone.user_enabled_default }}#{{ end }}user_enabled_default = {{ .ldap.keystone.user_enabled_default | default "True" }}

# DEPRECATED: List of user attributes to ignore on create and update. This is
# only used for write operations. (list value)
# This option is deprecated for removal since M.
# Its value may be silently ignored in the future.
# Reason: Write support for the LDAP identity backend has been deprecated in
# the Mitaka release and will be removed in the Ocata release.
# from .ldap.keystone.user_attribute_ignore
{{ if not .ldap.keystone.user_attribute_ignore }}#{{ end }}user_attribute_ignore = {{ .ldap.keystone.user_attribute_ignore | default "default_project_id" }}

# The LDAP attribute mapped to a user's default_project_id in keystone. This is
# most commonly used when keystone has write access to LDAP. (string value)
# from .ldap.keystone.user_default_project_id_attribute
{{ if not .ldap.keystone.user_default_project_id_attribute }}#{{ end }}user_default_project_id_attribute = {{ .ldap.keystone.user_default_project_id_attribute | default "<None>" }}

# DEPRECATED: If enabled, keystone is allowed to create users in the LDAP
# server. (boolean value)
# This option is deprecated for removal since M.
# Its value may be silently ignored in the future.
# Reason: Write support for the LDAP identity backend has been deprecated in
# the Mitaka release and will be removed in the Ocata release.
# from .ldap.keystone.user_allow_create
{{ if not .ldap.keystone.user_allow_create }}#{{ end }}user_allow_create = {{ .ldap.keystone.user_allow_create | default "true" }}

# DEPRECATED: If enabled, keystone is allowed to update users in the LDAP
# server. (boolean value)
# This option is deprecated for removal since M.
# Its value may be silently ignored in the future.
# Reason: Write support for the LDAP identity backend has been deprecated in
# the Mitaka release and will be removed in the Ocata release.
# from .ldap.keystone.user_allow_update
{{ if not .ldap.keystone.user_allow_update }}#{{ end }}user_allow_update = {{ .ldap.keystone.user_allow_update | default "true" }}

# DEPRECATED: If enabled, keystone is allowed to delete users in the LDAP
# server. (boolean value)
# This option is deprecated for removal since M.
# Its value may be silently ignored in the future.
# Reason: Write support for the LDAP identity backend has been deprecated in
# the Mitaka release and will be removed in the Ocata release.
# from .ldap.keystone.user_allow_delete
{{ if not .ldap.keystone.user_allow_delete }}#{{ end }}user_allow_delete = {{ .ldap.keystone.user_allow_delete | default "true" }}

# If enabled, keystone uses an alternative method to determine if a user is
# enabled or not by checking if they are a member of the group defined by the
# `[ldap] user_enabled_emulation_dn` option. Enabling this option causes
# keystone to ignore the value of `[ldap] user_enabled_invert`. (boolean value)
# from .ldap.keystone.user_enabled_emulation
{{ if not .ldap.keystone.user_enabled_emulation }}#{{ end }}user_enabled_emulation = {{ .ldap.keystone.user_enabled_emulation | default "false" }}

# DN of the group entry to hold enabled users when using enabled emulation.
# Setting this option has no effect unless `[ldap] user_enabled_emulation` is
# also enabled. (string value)
# from .ldap.keystone.user_enabled_emulation_dn
{{ if not .ldap.keystone.user_enabled_emulation_dn }}#{{ end }}user_enabled_emulation_dn = {{ .ldap.keystone.user_enabled_emulation_dn | default "<None>" }}

# Use the `[ldap] group_member_attribute` and `[ldap] group_objectclass`
# settings to determine membership in the emulated enabled group. Enabling this
# option has no effect unless `[ldap] user_enabled_emulation` is also enabled.
# (boolean value)
# from .ldap.keystone.user_enabled_emulation_use_group_config
{{ if not .ldap.keystone.user_enabled_emulation_use_group_config }}#{{ end }}user_enabled_emulation_use_group_config = {{ .ldap.keystone.user_enabled_emulation_use_group_config | default "false" }}

# A list of LDAP attribute to keystone user attribute pairs used for mapping
# additional attributes to users in keystone. The expected format is
# `<ldap_attr>:<user_attr>`, where `ldap_attr` is the attribute in the LDAP
# object and `user_attr` is the attribute which should appear in the identity
# API. (list value)
# from .ldap.keystone.user_additional_attribute_mapping
{{ if not .ldap.keystone.user_additional_attribute_mapping }}#{{ end }}user_additional_attribute_mapping = {{ .ldap.keystone.user_additional_attribute_mapping | default "" }}

# The search base to use for groups. Defaults to the `[ldap] suffix` value.
# (string value)
# from .ldap.keystone.group_tree_dn
{{ if not .ldap.keystone.group_tree_dn }}#{{ end }}group_tree_dn = {{ .ldap.keystone.group_tree_dn | default "<None>" }}

# The LDAP search filter to use for groups. (string value)
# from .ldap.keystone.group_filter
{{ if not .ldap.keystone.group_filter }}#{{ end }}group_filter = {{ .ldap.keystone.group_filter | default "<None>" }}

# The LDAP object class to use for groups. If setting this option to
# `posixGroup`, you may also be interested in enabling the `[ldap]
# group_members_are_ids` option. (string value)
# from .ldap.keystone.group_objectclass
{{ if not .ldap.keystone.group_objectclass }}#{{ end }}group_objectclass = {{ .ldap.keystone.group_objectclass | default "groupOfNames" }}

# The LDAP attribute mapped to group IDs in keystone. This must NOT be a
# multivalued attribute. Group IDs are expected to be globally unique across
# keystone domains and URL-safe. (string value)
# from .ldap.keystone.group_id_attribute
{{ if not .ldap.keystone.group_id_attribute }}#{{ end }}group_id_attribute = {{ .ldap.keystone.group_id_attribute | default "cn" }}

# The LDAP attribute mapped to group names in keystone. Group names are
# expected to be unique only within a keystone domain and are not expected to
# be URL-safe. (string value)
# from .ldap.keystone.group_name_attribute
{{ if not .ldap.keystone.group_name_attribute }}#{{ end }}group_name_attribute = {{ .ldap.keystone.group_name_attribute | default "ou" }}

# The LDAP attribute used to indicate that a user is a member of the group.
# (string value)
# from .ldap.keystone.group_member_attribute
{{ if not .ldap.keystone.group_member_attribute }}#{{ end }}group_member_attribute = {{ .ldap.keystone.group_member_attribute | default "member" }}

# Enable this option if the members of the group object class are keystone user
# IDs rather than LDAP DNs. This is the case when using `posixGroup` as the
# group object class in Open Directory. (boolean value)
# from .ldap.keystone.group_members_are_ids
{{ if not .ldap.keystone.group_members_are_ids }}#{{ end }}group_members_are_ids = {{ .ldap.keystone.group_members_are_ids | default "false" }}

# The LDAP attribute mapped to group descriptions in keystone. (string value)
# from .ldap.keystone.group_desc_attribute
{{ if not .ldap.keystone.group_desc_attribute }}#{{ end }}group_desc_attribute = {{ .ldap.keystone.group_desc_attribute | default "description" }}

# DEPRECATED: List of group attributes to ignore on create and update. This is
# only used for write operations. (list value)
# This option is deprecated for removal since M.
# Its value may be silently ignored in the future.
# Reason: Write support for the LDAP identity backend has been deprecated in
# the Mitaka release and will be removed in the Ocata release.
# from .ldap.keystone.group_attribute_ignore
{{ if not .ldap.keystone.group_attribute_ignore }}#{{ end }}group_attribute_ignore = {{ .ldap.keystone.group_attribute_ignore | default "" }}

# DEPRECATED: If enabled, keystone is allowed to create groups in the LDAP
# server. (boolean value)
# This option is deprecated for removal since M.
# Its value may be silently ignored in the future.
# Reason: Write support for the LDAP identity backend has been deprecated in
# the Mitaka release and will be removed in the Ocata release.
# from .ldap.keystone.group_allow_create
{{ if not .ldap.keystone.group_allow_create }}#{{ end }}group_allow_create = {{ .ldap.keystone.group_allow_create | default "true" }}

# DEPRECATED: If enabled, keystone is allowed to update groups in the LDAP
# server. (boolean value)
# This option is deprecated for removal since M.
# Its value may be silently ignored in the future.
# Reason: Write support for the LDAP identity backend has been deprecated in
# the Mitaka release and will be removed in the Ocata release.
# from .ldap.keystone.group_allow_update
{{ if not .ldap.keystone.group_allow_update }}#{{ end }}group_allow_update = {{ .ldap.keystone.group_allow_update | default "true" }}

# DEPRECATED: If enabled, keystone is allowed to delete groups in the LDAP
# server. (boolean value)
# This option is deprecated for removal since M.
# Its value may be silently ignored in the future.
# Reason: Write support for the LDAP identity backend has been deprecated in
# the Mitaka release and will be removed in the Ocata release.
# from .ldap.keystone.group_allow_delete
{{ if not .ldap.keystone.group_allow_delete }}#{{ end }}group_allow_delete = {{ .ldap.keystone.group_allow_delete | default "true" }}

# A list of LDAP attribute to keystone group attribute pairs used for mapping
# additional attributes to groups in keystone. The expected format is
# `<ldap_attr>:<group_attr>`, where `ldap_attr` is the attribute in the LDAP
# object and `group_attr` is the attribute which should appear in the identity
# API. (list value)
# from .ldap.keystone.group_additional_attribute_mapping
{{ if not .ldap.keystone.group_additional_attribute_mapping }}#{{ end }}group_additional_attribute_mapping = {{ .ldap.keystone.group_additional_attribute_mapping | default "" }}

# If enabled, groups queries will use Active Directory specific filters for
# nested groups. (boolean value)
# from .ldap.keystone.group_ad_nesting
{{ if not .ldap.keystone.group_ad_nesting }}#{{ end }}group_ad_nesting = {{ .ldap.keystone.group_ad_nesting | default "false" }}

# An absolute path to a CA certificate file to use when communicating with LDAP
# servers. This option will take precedence over `[ldap] tls_cacertdir`, so
# there is no reason to set both. (string value)
# from .ldap.keystone.tls_cacertfile
{{ if not .ldap.keystone.tls_cacertfile }}#{{ end }}tls_cacertfile = {{ .ldap.keystone.tls_cacertfile | default "<None>" }}

# An absolute path to a CA certificate directory to use when communicating with
# LDAP servers. There is no reason to set this option if you've also set
# `[ldap] tls_cacertfile`. (string value)
# from .ldap.keystone.tls_cacertdir
{{ if not .ldap.keystone.tls_cacertdir }}#{{ end }}tls_cacertdir = {{ .ldap.keystone.tls_cacertdir | default "<None>" }}

# Enable TLS when communicating with LDAP servers. You should also set the
# `[ldap] tls_cacertfile` and `[ldap] tls_cacertdir` options when using this
# option. Do not set this option if you are using LDAP over SSL (LDAPS) instead
# of TLS. (boolean value)
# from .ldap.keystone.use_tls
{{ if not .ldap.keystone.use_tls }}#{{ end }}use_tls = {{ .ldap.keystone.use_tls | default "false" }}

# Specifies which checks to perform against client certificates on incoming TLS
# sessions. If set to `demand`, then a certificate will always be requested and
# required from the LDAP server. If set to `allow`, then a certificate will
# always be requested but not required from the LDAP server. If set to `never`,
# then a certificate will never be requested. (string value)
# Allowed values: demand, never, allow
# from .ldap.keystone.tls_req_cert
{{ if not .ldap.keystone.tls_req_cert }}#{{ end }}tls_req_cert = {{ .ldap.keystone.tls_req_cert | default "demand" }}

# Enable LDAP connection pooling for queries to the LDAP server. There is
# typically no reason to disable this. (boolean value)
# from .ldap.keystone.use_pool
{{ if not .ldap.keystone.use_pool }}#{{ end }}use_pool = {{ .ldap.keystone.use_pool | default "true" }}

# The size of the LDAP connection pool. This option has no effect unless
# `[ldap] use_pool` is also enabled. (integer value)
# Minimum value: 1
# from .ldap.keystone.pool_size
{{ if not .ldap.keystone.pool_size }}#{{ end }}pool_size = {{ .ldap.keystone.pool_size | default "10" }}

# The maximum number of times to attempt reconnecting to the LDAP server before
# aborting. A value of zero prevents retries. This option has no effect unless
# `[ldap] use_pool` is also enabled. (integer value)
# Minimum value: 0
# from .ldap.keystone.pool_retry_max
{{ if not .ldap.keystone.pool_retry_max }}#{{ end }}pool_retry_max = {{ .ldap.keystone.pool_retry_max | default "3" }}

# The number of seconds to wait before attempting to reconnect to the LDAP
# server. This option has no effect unless `[ldap] use_pool` is also enabled.
# (floating point value)
# from .ldap.keystone.pool_retry_delay
{{ if not .ldap.keystone.pool_retry_delay }}#{{ end }}pool_retry_delay = {{ .ldap.keystone.pool_retry_delay | default "0.1" }}

# The connection timeout to use with the LDAP server. A value of `-1` means
# that connections will never timeout. This option has no effect unless `[ldap]
# use_pool` is also enabled. (integer value)
# Minimum value: -1
# from .ldap.keystone.pool_connection_timeout
{{ if not .ldap.keystone.pool_connection_timeout }}#{{ end }}pool_connection_timeout = {{ .ldap.keystone.pool_connection_timeout | default "-1" }}

# The maximum connection lifetime to the LDAP server in seconds. When this
# lifetime is exceeded, the connection will be unbound and removed from the
# connection pool. This option has no effect unless `[ldap] use_pool` is also
# enabled. (integer value)
# Minimum value: 1
# from .ldap.keystone.pool_connection_lifetime
{{ if not .ldap.keystone.pool_connection_lifetime }}#{{ end }}pool_connection_lifetime = {{ .ldap.keystone.pool_connection_lifetime | default "600" }}

# Enable LDAP connection pooling for end user authentication. There is
# typically no reason to disable this. (boolean value)
# from .ldap.keystone.use_auth_pool
{{ if not .ldap.keystone.use_auth_pool }}#{{ end }}use_auth_pool = {{ .ldap.keystone.use_auth_pool | default "true" }}

# The size of the connection pool to use for end user authentication. This
# option has no effect unless `[ldap] use_auth_pool` is also enabled. (integer
# value)
# Minimum value: 1
# from .ldap.keystone.auth_pool_size
{{ if not .ldap.keystone.auth_pool_size }}#{{ end }}auth_pool_size = {{ .ldap.keystone.auth_pool_size | default "100" }}

# The maximum end user authentication connection lifetime to the LDAP server in
# seconds. When this lifetime is exceeded, the connection will be unbound and
# removed from the connection pool. This option has no effect unless `[ldap]
# use_auth_pool` is also enabled. (integer value)
# Minimum value: 1
# from .ldap.keystone.auth_pool_connection_lifetime
{{ if not .ldap.keystone.auth_pool_connection_lifetime }}#{{ end }}auth_pool_connection_lifetime = {{ .ldap.keystone.auth_pool_connection_lifetime | default "60" }}


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


[memcache]

#
# From keystone
#

# Comma-separated list of memcached servers in the format of
# `host:port,host:port` that keystone should use for the `memcache` token
# persistence provider and other memcache-backed KVS drivers. This
# configuration value is NOT used for intermediary caching between keystone and
# other backends, such as SQL and LDAP (for that, see the `[cache]` section).
# Multiple keystone servers in the same deployment should use the same set of
# memcached servers to ensure that data (such as UUID tokens) created by one
# node is available to the others. (list value)
# from .memcache.keystone.servers
{{ if not .memcache.keystone.servers }}#{{ end }}servers = {{ .memcache.keystone.servers | default "localhost:11211" }}

# Number of seconds memcached server is considered dead before it is tried
# again. This is used by the key value store system (including, the `memcache`
# and `memcache_pool` options for the `[token] driver` persistence backend).
# (integer value)
# from .memcache.keystone.dead_retry
{{ if not .memcache.keystone.dead_retry }}#{{ end }}dead_retry = {{ .memcache.keystone.dead_retry | default "300" }}

# Timeout in seconds for every call to a server. This is used by the key value
# store system (including, the `memcache` and `memcache_pool` options for the
# `[token] driver` persistence backend). (integer value)
# from .memcache.keystone.socket_timeout
{{ if not .memcache.keystone.socket_timeout }}#{{ end }}socket_timeout = {{ .memcache.keystone.socket_timeout | default "3" }}

# Max total number of open connections to every memcached server. This is used
# by the key value store system (including, the `memcache` and `memcache_pool`
# options for the `[token] driver` persistence backend). (integer value)
# from .memcache.keystone.pool_maxsize
{{ if not .memcache.keystone.pool_maxsize }}#{{ end }}pool_maxsize = {{ .memcache.keystone.pool_maxsize | default "10" }}

# Number of seconds a connection to memcached is held unused in the pool before
# it is closed. This is used by the key value store system (including, the
# `memcache` and `memcache_pool` options for the `[token] driver` persistence
# backend). (integer value)
# from .memcache.keystone.pool_unused_timeout
{{ if not .memcache.keystone.pool_unused_timeout }}#{{ end }}pool_unused_timeout = {{ .memcache.keystone.pool_unused_timeout | default "60" }}

# Number of seconds that an operation will wait to get a memcache client
# connection. This is used by the key value store system (including, the
# `memcache` and `memcache_pool` options for the `[token] driver` persistence
# backend). (integer value)
# from .memcache.keystone.pool_connection_get_timeout
{{ if not .memcache.keystone.pool_connection_get_timeout }}#{{ end }}pool_connection_get_timeout = {{ .memcache.keystone.pool_connection_get_timeout | default "10" }}


[oauth1]

#
# From keystone
#

# Entry point for the OAuth backend driver in the `keystone.oauth1` namespace.
# Typically, there is no reason to set this option unless you are providing a
# custom entry point. (string value)
# from .oauth1.keystone.driver
{{ if not .oauth1.keystone.driver }}#{{ end }}driver = {{ .oauth1.keystone.driver | default "sql" }}

# Number of seconds for the OAuth Request Token to remain valid after being
# created. This is the amount of time the user has to authorize the token.
# Setting this option to zero means that request tokens will last forever.
# (integer value)
# Minimum value: 0
# from .oauth1.keystone.request_token_duration
{{ if not .oauth1.keystone.request_token_duration }}#{{ end }}request_token_duration = {{ .oauth1.keystone.request_token_duration | default "28800" }}

# Number of seconds for the OAuth Access Token to remain valid after being
# created. This is the amount of time the consumer has to interact with the
# service provider (which is typically keystone). Setting this option to zero
# means that access tokens will last forever. (integer value)
# Minimum value: 0
# from .oauth1.keystone.access_token_duration
{{ if not .oauth1.keystone.access_token_duration }}#{{ end }}access_token_duration = {{ .oauth1.keystone.access_token_duration | default "86400" }}


[os_inherit]

#
# From keystone
#

# DEPRECATED: This allows domain-based role assignments to be inherited to
# projects owned by that domain, or from parent projects to child projects.
# (boolean value)
# This option is deprecated for removal since M.
# Its value may be silently ignored in the future.
# Reason: The option to disable the OS-INHERIT functionality has been
# deprecated in the Mitaka release and will be removed in the Ocata release.
# Starting in the Ocata release, OS-INHERIT functionality will always be
# enabled.
# from .os_inherit.keystone.enabled
{{ if not .os_inherit.keystone.enabled }}#{{ end }}enabled = {{ .os_inherit.keystone.enabled | default "true" }}


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
# From oslo.middleware
#

# The maximum body size for each  request, in bytes. (integer value)
# Deprecated group/name - [DEFAULT]/osapi_max_request_body_size
# Deprecated group/name - [DEFAULT]/max_request_body_size
# from .oslo_middleware.oslo.middleware.max_request_body_size
{{ if not .oslo_middleware.oslo.middleware.max_request_body_size }}#{{ end }}max_request_body_size = {{ .oslo_middleware.oslo.middleware.max_request_body_size | default "114688" }}

# DEPRECATED: The HTTP Header that will be used to determine what the original
# request protocol scheme was, even if it was hidden by a SSL termination
# proxy. (string value)
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# from .oslo_middleware.oslo.middleware.secure_proxy_ssl_header
{{ if not .oslo_middleware.oslo.middleware.secure_proxy_ssl_header }}#{{ end }}secure_proxy_ssl_header = {{ .oslo_middleware.oslo.middleware.secure_proxy_ssl_header | default "X-Forwarded-Proto" }}

# Whether the application is behind a proxy or not. This determines if the
# middleware should parse the headers or not. (boolean value)
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


[paste_deploy]

#
# From keystone
#

# Name of (or absolute path to) the Paste Deploy configuration file that
# composes middleware and the keystone application itself into actual WSGI
# entry points. See http://pythonpaste.org/deploy/ for additional documentation
# on the file's format. (string value)
# from .paste_deploy.keystone.config_file
{{ if not .paste_deploy.keystone.config_file }}#{{ end }}config_file = {{ .paste_deploy.keystone.config_file | default "keystone-paste.ini" }}


[policy]

#
# From keystone
#

# Entry point for the policy backend driver in the `keystone.policy` namespace.
# Supplied drivers are `rules` (which does not support any CRUD operations for
# the v3 policy API) and `sql`. Typically, there is no reason to set this
# option unless you are providing a custom entry point. (string value)
# from .policy.keystone.driver
{{ if not .policy.keystone.driver }}#{{ end }}driver = {{ .policy.keystone.driver | default "sql" }}

# Maximum number of entities that will be returned in a policy collection.
# (integer value)
# from .policy.keystone.list_limit
{{ if not .policy.keystone.list_limit }}#{{ end }}list_limit = {{ .policy.keystone.list_limit | default "<None>" }}


[profiler]

#
# From osprofiler
#

#
# Enables the profiling for all services on this node. Default value is False
# (fully disable the profiling feature).
#
# Possible values:
#
# * True: Enables the feature
# * False: Disables the feature. The profiling cannot be started via this
# project
# operations. If the profiling is triggered by another project, this project
# part
# will be empty.
#  (boolean value)
# Deprecated group/name - [profiler]/profiler_enabled
# from .profiler.osprofiler.enabled
{{ if not .profiler.osprofiler.enabled }}#{{ end }}enabled = {{ .profiler.osprofiler.enabled | default "false" }}

#
# Enables SQL requests profiling in services. Default value is False (SQL
# requests won't be traced).
#
# Possible values:
#
# * True: Enables SQL requests profiling. Each SQL query will be part of the
# trace and can the be analyzed by how much time was spent for that.
# * False: Disables SQL requests profiling. The spent time is only shown on a
# higher level of operations. Single SQL queries cannot be analyzed this
# way.
#  (boolean value)
# from .profiler.osprofiler.trace_sqlalchemy
{{ if not .profiler.osprofiler.trace_sqlalchemy }}#{{ end }}trace_sqlalchemy = {{ .profiler.osprofiler.trace_sqlalchemy | default "false" }}

#
# Secret key(s) to use for encrypting context data for performance profiling.
# This string value should have the following format:
# <key1>[,<key2>,...<keyn>],
# where each key is some random string. A user who triggers the profiling via
# the REST API has to set one of these keys in the headers of the REST API call
# to include profiling results of this node for this particular project.
#
# Both "enabled" flag and "hmac_keys" config options should be set to enable
# profiling. Also, to generate correct profiling information across all
# services
# at least one key needs to be consistent between OpenStack projects. This
# ensures it can be used from client side to generate the trace, containing
# information from all possible resources. (string value)
# from .profiler.osprofiler.hmac_keys
{{ if not .profiler.osprofiler.hmac_keys }}#{{ end }}hmac_keys = {{ .profiler.osprofiler.hmac_keys | default "SECRET_KEY" }}

#
# Connection string for a notifier backend. Default value is messaging:// which
# sets the notifier to oslo_messaging.
#
# Examples of possible values:
#
# * messaging://: use oslo_messaging driver for sending notifications.
#  (string value)
# from .profiler.osprofiler.connection_string
{{ if not .profiler.osprofiler.connection_string }}#{{ end }}connection_string = {{ .profiler.osprofiler.connection_string | default "messaging://" }}


[resource]

#
# From keystone
#

# Entry point for the resource driver in the `keystone.resource` namespace.
# Only a `sql` driver is supplied by keystone. If a resource driver is not
# specified, the assignment driver will choose the resource driver to maintain
# backwards compatibility with older configuration files. (string value)
# from .resource.keystone.driver
{{ if not .resource.keystone.driver }}#{{ end }}driver = {{ .resource.keystone.driver | default "<None>" }}

# Toggle for resource caching. This has no effect unless global caching is
# enabled. (boolean value)
# Deprecated group/name - [assignment]/caching
# from .resource.keystone.caching
{{ if not .resource.keystone.caching }}#{{ end }}caching = {{ .resource.keystone.caching | default "true" }}

# Time to cache resource data in seconds. This has no effect unless global
# caching is enabled. (integer value)
# Deprecated group/name - [assignment]/cache_time
# from .resource.keystone.cache_time
{{ if not .resource.keystone.cache_time }}#{{ end }}cache_time = {{ .resource.keystone.cache_time | default "<None>" }}

# Maximum number of entities that will be returned in a resource collection.
# (integer value)
# Deprecated group/name - [assignment]/list_limit
# from .resource.keystone.list_limit
{{ if not .resource.keystone.list_limit }}#{{ end }}list_limit = {{ .resource.keystone.list_limit | default "<None>" }}

# Name of the domain that owns the `admin_project_name`. If left unset, then
# there is no admin project. `[resource] admin_project_name` must also be set
# to use this option. (string value)
# from .resource.keystone.admin_project_domain_name
{{ if not .resource.keystone.admin_project_domain_name }}#{{ end }}admin_project_domain_name = {{ .resource.keystone.admin_project_domain_name | default "<None>" }}

# This is a special project which represents cloud-level administrator
# privileges across services. Tokens scoped to this project will contain a true
# `is_admin_project` attribute to indicate to policy systems that the role
# assignments on that specific project should apply equally across every
# project. If left unset, then there is no admin project, and thus no explicit
# means of cross-project role assignments. `[resource]
# admin_project_domain_name` must also be set to use this option. (string
# value)
# from .resource.keystone.admin_project_name
{{ if not .resource.keystone.admin_project_name }}#{{ end }}admin_project_name = {{ .resource.keystone.admin_project_name | default "<None>" }}

# This controls whether the names of projects are restricted from containing
# URL-reserved characters. If set to `new`, attempts to create or update a
# project with a URL-unsafe name will fail. If set to `strict`, attempts to
# scope a token with a URL-unsafe project name will fail, thereby forcing all
# project names to be updated to be URL-safe. (string value)
# Allowed values: off, new, strict
# from .resource.keystone.project_name_url_safe
{{ if not .resource.keystone.project_name_url_safe }}#{{ end }}project_name_url_safe = {{ .resource.keystone.project_name_url_safe | default "off" }}

# This controls whether the names of domains are restricted from containing
# URL-reserved characters. If set to `new`, attempts to create or update a
# domain with a URL-unsafe name will fail. If set to `strict`, attempts to
# scope a token with a URL-unsafe domain name will fail, thereby forcing all
# domain names to be updated to be URL-safe. (string value)
# Allowed values: off, new, strict
# from .resource.keystone.domain_name_url_safe
{{ if not .resource.keystone.domain_name_url_safe }}#{{ end }}domain_name_url_safe = {{ .resource.keystone.domain_name_url_safe | default "off" }}


[revoke]

#
# From keystone
#

# Entry point for the token revocation backend driver in the `keystone.revoke`
# namespace. Keystone only provides a `sql` driver, so there is no reason to
# set this option unless you are providing a custom entry point. (string value)
# from .revoke.keystone.driver
{{ if not .revoke.keystone.driver }}#{{ end }}driver = {{ .revoke.keystone.driver | default "sql" }}

# The number of seconds after a token has expired before a corresponding
# revocation event may be purged from the backend. (integer value)
# Minimum value: 0
# from .revoke.keystone.expiration_buffer
{{ if not .revoke.keystone.expiration_buffer }}#{{ end }}expiration_buffer = {{ .revoke.keystone.expiration_buffer | default "1800" }}

# Toggle for revocation event caching. This has no effect unless global caching
# is enabled. (boolean value)
# from .revoke.keystone.caching
{{ if not .revoke.keystone.caching }}#{{ end }}caching = {{ .revoke.keystone.caching | default "true" }}

# Time to cache the revocation list and the revocation events (in seconds).
# This has no effect unless global and `[revoke] caching` are both enabled.
# (integer value)
# Deprecated group/name - [token]/revocation_cache_time
# from .revoke.keystone.cache_time
{{ if not .revoke.keystone.cache_time }}#{{ end }}cache_time = {{ .revoke.keystone.cache_time | default "3600" }}


[role]

#
# From keystone
#

# Entry point for the role backend driver in the `keystone.role` namespace.
# Keystone only provides a `sql` driver, so there's no reason to change this
# unless you are providing a custom entry point. (string value)
# from .role.keystone.driver
{{ if not .role.keystone.driver }}#{{ end }}driver = {{ .role.keystone.driver | default "<None>" }}

# Toggle for role caching. This has no effect unless global caching is enabled.
# In a typical deployment, there is no reason to disable this. (boolean value)
# from .role.keystone.caching
{{ if not .role.keystone.caching }}#{{ end }}caching = {{ .role.keystone.caching | default "true" }}

# Time to cache role data, in seconds. This has no effect unless both global
# caching and `[role] caching` are enabled. (integer value)
# from .role.keystone.cache_time
{{ if not .role.keystone.cache_time }}#{{ end }}cache_time = {{ .role.keystone.cache_time | default "<None>" }}

# Maximum number of entities that will be returned in a role collection. This
# may be useful to tune if you have a large number of discrete roles in your
# deployment. (integer value)
# from .role.keystone.list_limit
{{ if not .role.keystone.list_limit }}#{{ end }}list_limit = {{ .role.keystone.list_limit | default "<None>" }}


[saml]

#
# From keystone
#

# Determines the lifetime for any SAML assertions generated by keystone, using
# `NotOnOrAfter` attributes. (integer value)
# from .saml.keystone.assertion_expiration_time
{{ if not .saml.keystone.assertion_expiration_time }}#{{ end }}assertion_expiration_time = {{ .saml.keystone.assertion_expiration_time | default "3600" }}

# Name of, or absolute path to, the binary to be used for XML signing. Although
# only the XML Security Library (`xmlsec1`) is supported, it may have a non-
# standard name or path on your system. If keystone cannot find the binary
# itself, you may need to install the appropriate package, use this option to
# specify an absolute path, or adjust keystone's PATH environment variable.
# (string value)
# from .saml.keystone.xmlsec1_binary
{{ if not .saml.keystone.xmlsec1_binary }}#{{ end }}xmlsec1_binary = {{ .saml.keystone.xmlsec1_binary | default "xmlsec1" }}

# Absolute path to the public certificate file to use for SAML signing. The
# value cannot contain a comma (`,`). (string value)
# from .saml.keystone.certfile
{{ if not .saml.keystone.certfile }}#{{ end }}certfile = {{ .saml.keystone.certfile | default "/etc/keystone/ssl/certs/signing_cert.pem" }}

# Absolute path to the private key file to use for SAML signing. The value
# cannot contain a comma (`,`). (string value)
# from .saml.keystone.keyfile
{{ if not .saml.keystone.keyfile }}#{{ end }}keyfile = {{ .saml.keystone.keyfile | default "/etc/keystone/ssl/private/signing_key.pem" }}

# This is the unique entity identifier of the identity provider (keystone) to
# use when generating SAML assertions. This value is required to generate
# identity provider metadata and must be a URI (a URL is recommended). For
# example: `https://keystone.example.com/v3/OS-FEDERATION/saml2/idp`. (uri
# value)
# from .saml.keystone.idp_entity_id
{{ if not .saml.keystone.idp_entity_id }}#{{ end }}idp_entity_id = {{ .saml.keystone.idp_entity_id | default "<None>" }}

# This is the single sign-on (SSO) service location of the identity provider
# which accepts HTTP POST requests. A value is required to generate identity
# provider metadata. For example: `https://keystone.example.com/v3/OS-
# FEDERATION/saml2/sso`. (uri value)
# from .saml.keystone.idp_sso_endpoint
{{ if not .saml.keystone.idp_sso_endpoint }}#{{ end }}idp_sso_endpoint = {{ .saml.keystone.idp_sso_endpoint | default "<None>" }}

# This is the language used by the identity provider's organization. (string
# value)
# from .saml.keystone.idp_lang
{{ if not .saml.keystone.idp_lang }}#{{ end }}idp_lang = {{ .saml.keystone.idp_lang | default "en" }}

# This is the name of the identity provider's organization. (string value)
# from .saml.keystone.idp_organization_name
{{ if not .saml.keystone.idp_organization_name }}#{{ end }}idp_organization_name = {{ .saml.keystone.idp_organization_name | default "SAML Identity Provider" }}

# This is the name of the identity provider's organization to be displayed.
# (string value)
# from .saml.keystone.idp_organization_display_name
{{ if not .saml.keystone.idp_organization_display_name }}#{{ end }}idp_organization_display_name = {{ .saml.keystone.idp_organization_display_name | default "OpenStack SAML Identity Provider" }}

# This is the URL of the identity provider's organization. The URL referenced
# here should be useful to humans. (uri value)
# from .saml.keystone.idp_organization_url
{{ if not .saml.keystone.idp_organization_url }}#{{ end }}idp_organization_url = {{ .saml.keystone.idp_organization_url | default "https://example.com/" }}

# This is the company name of the identity provider's contact person. (string
# value)
# from .saml.keystone.idp_contact_company
{{ if not .saml.keystone.idp_contact_company }}#{{ end }}idp_contact_company = {{ .saml.keystone.idp_contact_company | default "Example, Inc." }}

# This is the given name of the identity provider's contact person. (string
# value)
# from .saml.keystone.idp_contact_name
{{ if not .saml.keystone.idp_contact_name }}#{{ end }}idp_contact_name = {{ .saml.keystone.idp_contact_name | default "SAML Identity Provider Support" }}

# This is the surname of the identity provider's contact person. (string value)
# from .saml.keystone.idp_contact_surname
{{ if not .saml.keystone.idp_contact_surname }}#{{ end }}idp_contact_surname = {{ .saml.keystone.idp_contact_surname | default "Support" }}

# This is the email address of the identity provider's contact person. (string
# value)
# from .saml.keystone.idp_contact_email
{{ if not .saml.keystone.idp_contact_email }}#{{ end }}idp_contact_email = {{ .saml.keystone.idp_contact_email | default "support@example.com" }}

# This is the telephone number of the identity provider's contact person.
# (string value)
# from .saml.keystone.idp_contact_telephone
{{ if not .saml.keystone.idp_contact_telephone }}#{{ end }}idp_contact_telephone = {{ .saml.keystone.idp_contact_telephone | default "+1 800 555 0100" }}

# This is the type of contact that best describes the identity provider's
# contact person. (string value)
# Allowed values: technical, support, administrative, billing, other
# from .saml.keystone.idp_contact_type
{{ if not .saml.keystone.idp_contact_type }}#{{ end }}idp_contact_type = {{ .saml.keystone.idp_contact_type | default "other" }}

# Absolute path to the identity provider metadata file. This file should be
# generated with the `keystone-manage saml_idp_metadata` command. There is
# typically no reason to change this value. (string value)
# from .saml.keystone.idp_metadata_path
{{ if not .saml.keystone.idp_metadata_path }}#{{ end }}idp_metadata_path = {{ .saml.keystone.idp_metadata_path | default "/etc/keystone/saml2_idp_metadata.xml" }}

# The prefix of the RelayState SAML attribute to use when generating enhanced
# client and proxy (ECP) assertions. In a typical deployment, there is no
# reason to change this value. (string value)
# from .saml.keystone.relay_state_prefix
{{ if not .saml.keystone.relay_state_prefix }}#{{ end }}relay_state_prefix = {{ .saml.keystone.relay_state_prefix | default "ss:mem:" }}


[security_compliance]

#
# From keystone
#

# The maximum number of days a user can go without authenticating before being
# considered "inactive" and automatically disabled (locked). This feature is
# disabled by default; set any value to enable it. This feature depends on the
# `sql` backend for the `[identity] driver`. When a user exceeds this threshold
# and is considered "inactive", the user's `enabled` attribute in the HTTP API
# may not match the value of the user's `enabled` column in the user table.
# (integer value)
# Minimum value: 1
# from .security_compliance.keystone.disable_user_account_days_inactive
{{ if not .security_compliance.keystone.disable_user_account_days_inactive }}#{{ end }}disable_user_account_days_inactive = {{ .security_compliance.keystone.disable_user_account_days_inactive | default "<None>" }}

# The maximum number of times that a user can fail to authenticate before the
# user account is locked for the number of seconds specified by
# `[security_compliance] lockout_duration`. This feature is disabled by
# default. If this feature is enabled and `[security_compliance]
# lockout_duration` is not set, then users may be locked out indefinitely until
# the user is explicitly enabled via the API. This feature depends on the `sql`
# backend for the `[identity] driver`. (integer value)
# Minimum value: 1
# from .security_compliance.keystone.lockout_failure_attempts
{{ if not .security_compliance.keystone.lockout_failure_attempts }}#{{ end }}lockout_failure_attempts = {{ .security_compliance.keystone.lockout_failure_attempts | default "<None>" }}

# The number of seconds a user account will be locked when the maximum number
# of failed authentication attempts (as specified by `[security_compliance]
# lockout_failure_attempts`) is exceeded. Setting this option will have no
# effect unless you also set `[security_compliance] lockout_failure_attempts`
# to a non-zero value. This feature depends on the `sql` backend for the
# `[identity] driver`. (integer value)
# Minimum value: 1
# from .security_compliance.keystone.lockout_duration
{{ if not .security_compliance.keystone.lockout_duration }}#{{ end }}lockout_duration = {{ .security_compliance.keystone.lockout_duration | default "1800" }}

# The number of days for which a password will be considered valid before
# requiring it to be changed. This feature is disabled by default. If enabled,
# new password changes will have an expiration date, however existing passwords
# would not be impacted. This feature depends on the `sql` backend for the
# `[identity] driver`. (integer value)
# Minimum value: 1
# from .security_compliance.keystone.password_expires_days
{{ if not .security_compliance.keystone.password_expires_days }}#{{ end }}password_expires_days = {{ .security_compliance.keystone.password_expires_days | default "<None>" }}

# Comma separated list of user IDs to be ignored when checking if a password is
# expired. Passwords for users in this list will not expire. This feature will
# only be enabled if `[security_compliance] password_expires_days` is set.
# (list value)
# from .security_compliance.keystone.password_expires_ignore_user_ids
{{ if not .security_compliance.keystone.password_expires_ignore_user_ids }}#{{ end }}password_expires_ignore_user_ids = {{ .security_compliance.keystone.password_expires_ignore_user_ids | default "" }}

# This controls the number of previous user password iterations to keep in
# history, in order to enforce that newly created passwords are unique. Setting
# the value to one (the default) disables this feature. Thus, to enable this
# feature, values must be greater than 1. This feature depends on the `sql`
# backend for the `[identity] driver`. (integer value)
# Minimum value: 1
# from .security_compliance.keystone.unique_last_password_count
{{ if not .security_compliance.keystone.unique_last_password_count }}#{{ end }}unique_last_password_count = {{ .security_compliance.keystone.unique_last_password_count | default "1" }}

# The number of days that a password must be used before the user can change
# it. This prevents users from changing their passwords immediately in order to
# wipe out their password history and reuse an old password. This feature does
# not prevent administrators from manually resetting passwords. It is disabled
# by default and allows for immediate password changes. This feature depends on
# the `sql` backend for the `[identity] driver`. Note: If
# `[security_compliance] password_expires_days` is set, then the value for this
# option should be less than the `password_expires_days`. (integer value)
# Minimum value: 0
# from .security_compliance.keystone.minimum_password_age
{{ if not .security_compliance.keystone.minimum_password_age }}#{{ end }}minimum_password_age = {{ .security_compliance.keystone.minimum_password_age | default "0" }}

# The regular expression used to validate password strength requirements. By
# default, the regular expression will match any password. The following is an
# example of a pattern which requires at least 1 letter, 1 digit, and have a
# minimum length of 7 characters: ^(?=.*\d)(?=.*[a-zA-Z]).{7,}$ This feature
# depends on the `sql` backend for the `[identity] driver`. (string value)
# from .security_compliance.keystone.password_regex
{{ if not .security_compliance.keystone.password_regex }}#{{ end }}password_regex = {{ .security_compliance.keystone.password_regex | default "<None>" }}

# Describe your password regular expression here in language for humans. If a
# password fails to match the regular expression, the contents of this
# configuration variable will be returned to users to explain why their
# requested password was insufficient. (string value)
# from .security_compliance.keystone.password_regex_description
{{ if not .security_compliance.keystone.password_regex_description }}#{{ end }}password_regex_description = {{ .security_compliance.keystone.password_regex_description | default "<None>" }}


[shadow_users]

#
# From keystone
#

# Entry point for the shadow users backend driver in the
# `keystone.identity.shadow_users` namespace. This driver is used for
# persisting local user references to externally-managed identities (via
# federation, LDAP, etc). Keystone only provides a `sql` driver, so there is no
# reason to change this option unless you are providing a custom entry point.
# (string value)
# from .shadow_users.keystone.driver
{{ if not .shadow_users.keystone.driver }}#{{ end }}driver = {{ .shadow_users.keystone.driver | default "sql" }}


[signing]

#
# From keystone
#

# DEPRECATED: Absolute path to the public certificate file to use for signing
# PKI and PKIZ tokens. Set this together with `[signing] keyfile`. For non-
# production environments, you may be interested in using `keystone-manage
# pki_setup` to generate self-signed certificates. There is no reason to set
# this option unless you are using either a `pki` or `pkiz` `[token] provider`.
# (string value)
# This option is deprecated for removal since M.
# Its value may be silently ignored in the future.
# Reason: PKI token support has been deprecated in the M release and will be
# removed in the O release. Fernet or UUID tokens are recommended.
# from .signing.keystone.certfile
{{ if not .signing.keystone.certfile }}#{{ end }}certfile = {{ .signing.keystone.certfile | default "/etc/keystone/ssl/certs/signing_cert.pem" }}

# DEPRECATED: Absolute path to the private key file to use for signing PKI and
# PKIZ tokens. Set this together with `[signing] certfile`. There is no reason
# to set this option unless you are using either a `pki` or `pkiz` `[token]
# provider`. (string value)
# This option is deprecated for removal since M.
# Its value may be silently ignored in the future.
# Reason: PKI token support has been deprecated in the M release and will be
# removed in the O release. Fernet or UUID tokens are recommended.
# from .signing.keystone.keyfile
{{ if not .signing.keystone.keyfile }}#{{ end }}keyfile = {{ .signing.keystone.keyfile | default "/etc/keystone/ssl/private/signing_key.pem" }}

# DEPRECATED: Absolute path to the public certificate authority (CA) file to
# use when creating self-signed certificates with `keystone-manage pki_setup`.
# Set this together with `[signing] ca_key`. There is no reason to set this
# option unless you are using a `pki` or `pkiz` `[token] provider` value in a
# non-production environment. Use a `[signing] certfile` issued from a trusted
# certificate authority instead. (string value)
# This option is deprecated for removal since M.
# Its value may be silently ignored in the future.
# Reason: PKI token support has been deprecated in the M release and will be
# removed in the O release. Fernet or UUID tokens are recommended.
# from .signing.keystone.ca_certs
{{ if not .signing.keystone.ca_certs }}#{{ end }}ca_certs = {{ .signing.keystone.ca_certs | default "/etc/keystone/ssl/certs/ca.pem" }}

# DEPRECATED: Absolute path to the private certificate authority (CA) key file
# to use when creating self-signed certificates with `keystone-manage
# pki_setup`. Set this together with `[signing] ca_certs`. There is no reason
# to set this option unless you are using a `pki` or `pkiz` `[token] provider`
# value in a non-production environment. Use a `[signing] certfile` issued from
# a trusted certificate authority instead. (string value)
# This option is deprecated for removal since M.
# Its value may be silently ignored in the future.
# Reason: PKI token support has been deprecated in the M release and will be
# removed in the O release. Fernet or UUID tokens are recommended.
# from .signing.keystone.ca_key
{{ if not .signing.keystone.ca_key }}#{{ end }}ca_key = {{ .signing.keystone.ca_key | default "/etc/keystone/ssl/private/cakey.pem" }}

# DEPRECATED: Key size (in bits) to use when generating a self-signed token
# signing certificate. There is no reason to set this option unless you are
# using a `pki` or `pkiz` `[token] provider` value in a non-production
# environment. Use a `[signing] certfile` issued from a trusted certificate
# authority instead. (integer value)
# Minimum value: 1024
# This option is deprecated for removal since M.
# Its value may be silently ignored in the future.
# Reason: PKI token support has been deprecated in the M release and will be
# removed in the O release. Fernet or UUID tokens are recommended.
# from .signing.keystone.key_size
{{ if not .signing.keystone.key_size }}#{{ end }}key_size = {{ .signing.keystone.key_size | default "2048" }}

# DEPRECATED: The validity period (in days) to use when generating a self-
# signed token signing certificate. There is no reason to set this option
# unless you are using a `pki` or `pkiz` `[token] provider` value in a non-
# production environment. Use a `[signing] certfile` issued from a trusted
# certificate authority instead. (integer value)
# This option is deprecated for removal since M.
# Its value may be silently ignored in the future.
# Reason: PKI token support has been deprecated in the M release and will be
# removed in the O release. Fernet or UUID tokens are recommended.
# from .signing.keystone.valid_days
{{ if not .signing.keystone.valid_days }}#{{ end }}valid_days = {{ .signing.keystone.valid_days | default "3650" }}

# DEPRECATED: The certificate subject to use when generating a self-signed
# token signing certificate. There is no reason to set this option unless you
# are using a `pki` or `pkiz` `[token] provider` value in a non-production
# environment. Use a `[signing] certfile` issued from a trusted certificate
# authority instead. (string value)
# This option is deprecated for removal since M.
# Its value may be silently ignored in the future.
# Reason: PKI token support has been deprecated in the M release and will be
# removed in the O release. Fernet or UUID tokens are recommended.
# from .signing.keystone.cert_subject
{{ if not .signing.keystone.cert_subject }}#{{ end }}cert_subject = {{ .signing.keystone.cert_subject | default "/C=US/ST=Unset/L=Unset/O=Unset/CN=www.example.com" }}


[token]

#
# From keystone
#

# This is a list of external authentication mechanisms which should add token
# binding metadata to tokens, such as `kerberos` or `x509`. Binding metadata is
# enforced according to the `[token] enforce_token_bind` option. (list value)
# from .token.keystone.bind
{{ if not .token.keystone.bind }}#{{ end }}bind = {{ .token.keystone.bind | default "" }}

# This controls the token binding enforcement policy on tokens presented to
# keystone with token binding metadata (as specified by the `[token] bind`
# option). `disabled` completely bypasses token binding validation.
# `permissive` and `strict` do not require tokens to have binding metadata (but
# will validate it if present), whereas `required` will always demand tokens to
# having binding metadata. `permissive` will allow unsupported binding metadata
# to pass through without validation (usually to be validated at another time
# by another component), whereas `strict` and `required` will demand that the
# included binding metadata be supported by keystone. (string value)
# Allowed values: disabled, permissive, strict, required
# from .token.keystone.enforce_token_bind
{{ if not .token.keystone.enforce_token_bind }}#{{ end }}enforce_token_bind = {{ .token.keystone.enforce_token_bind | default "permissive" }}

# The amount of time that a token should remain valid (in seconds). Drastically
# reducing this value may break "long-running" operations that involve multiple
# services to coordinate together, and will force users to authenticate with
# keystone more frequently. Drastically increasing this value will increase
# load on the `[token] driver`, as more tokens will be simultaneously valid.
# Keystone tokens are also bearer tokens, so a shorter duration will also
# reduce the potential security impact of a compromised token. (integer value)
# Minimum value: 0
# Maximum value: 9223372036854775807
# from .token.keystone.expiration
{{ if not .token.keystone.expiration }}#{{ end }}expiration = {{ .token.keystone.expiration | default "3600" }}

# Entry point for the token provider in the `keystone.token.provider`
# namespace. The token provider controls the token construction, validation,
# and revocation operations. Keystone includes `fernet`, `pkiz`, `pki`, and
# `uuid` token providers. `uuid` tokens must be persisted (using the backend
# specified in the `[token] driver` option), but do not require any extra
# configuration or setup. `fernet` tokens do not need to be persisted at all,
# but require that you run `keystone-manage fernet_setup` (also see the
# `keystone-manage fernet_rotate` command). `pki` and `pkiz` tokens can be
# validated offline, without making HTTP calls to keystone, but require that
# certificates be installed and distributed to facilitate signing tokens and
# later validating those signatures. (string value)
# from .token.keystone.provider
{{ if not .token.keystone.provider }}#{{ end }}provider = {{ .token.keystone.provider | default "uuid" }}

# Entry point for the token persistence backend driver in the
# `keystone.token.persistence` namespace. Keystone provides `kvs`, `memcache`,
# `memcache_pool`, and `sql` drivers. The `kvs` backend depends on the
# configuration in the `[kvs]` section. The `memcache` and `memcache_pool`
# options depend on the configuration in the `[memcache]` section. The `sql`
# option (default) depends on the options in your `[database]` section. If
# you're using the `fernet` `[token] provider`, this backend will not be
# utilized to persist tokens at all. (string value)
# from .token.keystone.driver
{{ if not .token.keystone.driver }}#{{ end }}driver = {{ .token.keystone.driver | default "sql" }}

# Toggle for caching token creation and validation data. This has no effect
# unless global caching is enabled. (boolean value)
# from .token.keystone.caching
{{ if not .token.keystone.caching }}#{{ end }}caching = {{ .token.keystone.caching | default "true" }}

# The number of seconds to cache token creation and validation data. This has
# no effect unless both global and `[token] caching` are enabled. (integer
# value)
# Minimum value: 0
# Maximum value: 9223372036854775807
# from .token.keystone.cache_time
{{ if not .token.keystone.cache_time }}#{{ end }}cache_time = {{ .token.keystone.cache_time | default "<None>" }}

# This toggles support for revoking individual tokens by the token identifier
# and thus various token enumeration operations (such as listing all tokens
# issued to a specific user). These operations are used to determine the list
# of tokens to consider revoked. Do not disable this option if you're using the
# `kvs` `[revoke] driver`. (boolean value)
# from .token.keystone.revoke_by_id
{{ if not .token.keystone.revoke_by_id }}#{{ end }}revoke_by_id = {{ .token.keystone.revoke_by_id | default "true" }}

# This toggles whether scoped tokens may be be re-scoped to a new project or
# domain, thereby preventing users from exchanging a scoped token (including
# those with a default project scope) for any other token. This forces users to
# either authenticate for unscoped tokens (and later exchange that unscoped
# token for tokens with a more specific scope) or to provide their credentials
# in every request for a scoped token to avoid re-scoping altogether. (boolean
# value)
# from .token.keystone.allow_rescope_scoped_token
{{ if not .token.keystone.allow_rescope_scoped_token }}#{{ end }}allow_rescope_scoped_token = {{ .token.keystone.allow_rescope_scoped_token | default "true" }}

# DEPRECATED: This controls the hash algorithm to use to uniquely identify PKI
# tokens without having to transmit the entire token to keystone (which may be
# several kilobytes). This can be set to any algorithm that hashlib supports.
# WARNING: Before changing this value, the `auth_token` middleware protecting
# all other services must be configured with the set of hash algorithms to
# expect from keystone (both your old and new value for this option), otherwise
# token revocation will not be processed correctly. (string value)
# Allowed values: md5, sha1, sha224, sha256, sha384, sha512
# This option is deprecated for removal since M.
# Its value may be silently ignored in the future.
# Reason: PKI token support has been deprecated in the M release and will be
# removed in the O release. Fernet or UUID tokens are recommended.
# from .token.keystone.hash_algorithm
{{ if not .token.keystone.hash_algorithm }}#{{ end }}hash_algorithm = {{ .token.keystone.hash_algorithm | default "md5" }}

# This controls whether roles should be included with tokens that are not
# directly assigned to the token's scope, but are instead linked implicitly to
# other role assignments. (boolean value)
# from .token.keystone.infer_roles
{{ if not .token.keystone.infer_roles }}#{{ end }}infer_roles = {{ .token.keystone.infer_roles | default "true" }}

# Enable storing issued token data to token validation cache so that first
# token validation doesn't actually cause full validation cycle. (boolean
# value)
# from .token.keystone.cache_on_issue
{{ if not .token.keystone.cache_on_issue }}#{{ end }}cache_on_issue = {{ .token.keystone.cache_on_issue | default "false" }}


[tokenless_auth]

#
# From keystone
#

# The list of distinguished names which identify trusted issuers of client
# certificates allowed to use X.509 tokenless authorization. If the option is
# absent then no certificates will be allowed. The format for the values of a
# distinguished name (DN) must be separated by a comma and contain no spaces.
# Furthermore, because an individual DN may contain commas, this configuration
# option may be repeated multiple times to represent multiple values. For
# example, keystone.conf would include two consecutive lines in order to trust
# two different DNs, such as `trusted_issuer = CN=john,OU=keystone,O=openstack`
# and `trusted_issuer = CN=mary,OU=eng,O=abc`. (multi valued)
# from .tokenless_auth.keystone.trusted_issuer (multiopt)
{{ if not .tokenless_auth.keystone.trusted_issuer }}#trusted_issuer = {{ .tokenless_auth.keystone.trusted_issuer | default "" }}{{ else }}{{ range .tokenless_auth.keystone.trusted_issuer }}trusted_issuer = {{ . }}
{{ end }}{{ end }}

# The federated protocol ID used to represent X.509 tokenless authorization.
# This is used in combination with the value of `[tokenless_auth]
# issuer_attribute` to find a corresponding federated mapping. In a typical
# deployment, there is no reason to change this value. (string value)
# from .tokenless_auth.keystone.protocol
{{ if not .tokenless_auth.keystone.protocol }}#{{ end }}protocol = {{ .tokenless_auth.keystone.protocol | default "x509" }}

# The name of the WSGI environment variable used to pass the issuer of the
# client certificate to keystone. This attribute is used as an identity
# provider ID for the X.509 tokenless authorization along with the protocol to
# look up its corresponding mapping. In a typical deployment, there is no
# reason to change this value. (string value)
# from .tokenless_auth.keystone.issuer_attribute
{{ if not .tokenless_auth.keystone.issuer_attribute }}#{{ end }}issuer_attribute = {{ .tokenless_auth.keystone.issuer_attribute | default "SSL_CLIENT_I_DN" }}


[trust]

#
# From keystone
#

# Delegation and impersonation features using trusts can be optionally
# disabled. (boolean value)
# from .trust.keystone.enabled
{{ if not .trust.keystone.enabled }}#{{ end }}enabled = {{ .trust.keystone.enabled | default "true" }}

# Allows authorization to be redelegated from one user to another, effectively
# chaining trusts together. When disabled, the `remaining_uses` attribute of a
# trust is constrained to be zero. (boolean value)
# from .trust.keystone.allow_redelegation
{{ if not .trust.keystone.allow_redelegation }}#{{ end }}allow_redelegation = {{ .trust.keystone.allow_redelegation | default "false" }}

# Maximum number of times that authorization can be redelegated from one user
# to another in a chain of trusts. This number may be reduced further for a
# specific trust. (integer value)
# from .trust.keystone.max_redelegation_count
{{ if not .trust.keystone.max_redelegation_count }}#{{ end }}max_redelegation_count = {{ .trust.keystone.max_redelegation_count | default "3" }}

# Entry point for the trust backend driver in the `keystone.trust` namespace.
# Keystone only provides a `sql` driver, so there is no reason to change this
# unless you are providing a custom entry point. (string value)
# from .trust.keystone.driver
{{ if not .trust.keystone.driver }}#{{ end }}driver = {{ .trust.keystone.driver | default "sql" }}

{{- end -}}

