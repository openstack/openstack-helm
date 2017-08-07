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

{{ include "glance.conf.glance_values_skeleton" .Values.conf.glance | trunc 0 }}
{{ include "glance.conf.glance" .Values.conf.glance }}


{{- define "glance.conf.glance_values_skeleton" -}}

{{- if not .default -}}{{- set . "default" dict -}}{{- end -}}
{{- if not .default.glance -}}{{- set .default "glance" dict -}}{{- end -}}
{{- if not .default.glance.api -}}{{- set .default.glance "api" dict -}}{{- end -}}
{{- if not .default.oslo -}}{{- set .default "oslo" dict -}}{{- end -}}
{{- if not .default.oslo.log -}}{{- set .default.oslo "log" dict -}}{{- end -}}
{{- if not .default.oslo.messaging -}}{{- set .default.oslo "messaging" dict -}}{{- end -}}
{{- if not .cors -}}{{- set . "cors" dict -}}{{- end -}}
{{- if not .cors.oslo -}}{{- set .cors "oslo" dict -}}{{- end -}}
{{- if not .cors.oslo.middleware -}}{{- set .cors.oslo "middleware" dict -}}{{- end -}}
{{- if not .cors.oslo.middleware.cors -}}{{- set .cors.oslo.middleware "cors" dict -}}{{- end -}}
{{- if not .cors.subdomain -}}{{- set .cors "subdomain" dict -}}{{- end -}}
{{- if not .cors.subdomain.oslo -}}{{- set .cors.subdomain "oslo" dict -}}{{- end -}}
{{- if not .cors.subdomain.oslo.middleware -}}{{- set .cors.subdomain.oslo "middleware" dict -}}{{- end -}}
{{- if not .cors.subdomain.oslo.middleware.cors -}}{{- set .cors.subdomain.oslo.middleware "cors" dict -}}{{- end -}}
{{- if not .database -}}{{- set . "database" dict -}}{{- end -}}
{{- if not .database.oslo -}}{{- set .database "oslo" dict -}}{{- end -}}
{{- if not .database.oslo.db -}}{{- set .database.oslo "db" dict -}}{{- end -}}
{{- if not .database.oslo.db.concurrency -}}{{- set .database.oslo.db "concurrency" dict -}}{{- end -}}
{{- if not .glance_store -}}{{- set . "glance_store" dict -}}{{- end -}}
{{- if not .glance_store.glance -}}{{- set .glance_store "glance" dict -}}{{- end -}}
{{- if not .glance_store.glance.store -}}{{- set .glance_store.glance "store" dict -}}{{- end -}}
{{- if not .image_format -}}{{- set . "image_format" dict -}}{{- end -}}
{{- if not .image_format.glance -}}{{- set .image_format "glance" dict -}}{{- end -}}
{{- if not .image_format.glance.api -}}{{- set .image_format.glance "api" dict -}}{{- end -}}
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
{{- if not .oslo_middleware.oslo.middleware.http_proxy_to_wsgi -}}{{- set .oslo_middleware.oslo.middleware "http_proxy_to_wsgi" dict -}}{{- end -}}
{{- if not .oslo_policy -}}{{- set . "oslo_policy" dict -}}{{- end -}}
{{- if not .oslo_policy.oslo -}}{{- set .oslo_policy "oslo" dict -}}{{- end -}}
{{- if not .oslo_policy.oslo.policy -}}{{- set .oslo_policy.oslo "policy" dict -}}{{- end -}}
{{- if not .paste_deploy -}}{{- set . "paste_deploy" dict -}}{{- end -}}
{{- if not .paste_deploy.glance -}}{{- set .paste_deploy "glance" dict -}}{{- end -}}
{{- if not .paste_deploy.glance.api -}}{{- set .paste_deploy.glance "api" dict -}}{{- end -}}
{{- if not .profiler -}}{{- set . "profiler" dict -}}{{- end -}}
{{- if not .profiler.glance -}}{{- set .profiler "glance" dict -}}{{- end -}}
{{- if not .profiler.glance.api -}}{{- set .profiler.glance "api" dict -}}{{- end -}}
{{- if not .store_type_location_strategy -}}{{- set . "store_type_location_strategy" dict -}}{{- end -}}
{{- if not .store_type_location_strategy.glance -}}{{- set .store_type_location_strategy "glance" dict -}}{{- end -}}
{{- if not .store_type_location_strategy.glance.api -}}{{- set .store_type_location_strategy.glance "api" dict -}}{{- end -}}
{{- if not .task -}}{{- set . "task" dict -}}{{- end -}}
{{- if not .task.glance -}}{{- set .task "glance" dict -}}{{- end -}}
{{- if not .task.glance.api -}}{{- set .task.glance "api" dict -}}{{- end -}}
{{- if not .taskflow_executor -}}{{- set . "taskflow_executor" dict -}}{{- end -}}
{{- if not .taskflow_executor.glance -}}{{- set .taskflow_executor "glance" dict -}}{{- end -}}
{{- if not .taskflow_executor.glance.api -}}{{- set .taskflow_executor.glance "api" dict -}}{{- end -}}

{{- end -}}


{{- define "glance.conf.glance" -}}

[DEFAULT]

#
# From glance.api
#

#
# Set the image owner to tenant or the authenticated user.
#
# Assign a boolean value to determine the owner of an image. When set to
# True, the owner of the image is the tenant. When set to False, the
# owner of the image will be the authenticated user issuing the request.
# Setting it to False makes the image private to the associated user and
# sharing with other users within the same tenant (or "project")
# requires explicit image sharing via image membership.
#
# Possible values:
#     * True
#     * False
#
# Related options:
#     * None
#
#  (boolean value)
# from .default.glance.api.owner_is_tenant
{{ if not .default.glance.api.owner_is_tenant }}#{{ end }}owner_is_tenant = {{ .default.glance.api.owner_is_tenant | default "true" }}

#
# Role used to identify an authenticated user as administrator.
#
# Provide a string value representing a Keystone role to identify an
# administrative user. Users with this role will be granted
# administrative privileges. The default value for this option is
# 'admin'.
#
# Possible values:
#     * A string value which is a valid Keystone role
#
# Related options:
#     * None
#
#  (string value)
# from .default.glance.api.admin_role
{{ if not .default.glance.api.admin_role }}#{{ end }}admin_role = {{ .default.glance.api.admin_role | default "admin" }}

#
# Allow limited access to unauthenticated users.
#
# Assign a boolean to determine API access for unathenticated
# users. When set to False, the API cannot be accessed by
# unauthenticated users. When set to True, unauthenticated users can
# access the API with read-only privileges. This however only applies
# when using ContextMiddleware.
#
# Possible values:
#     * True
#     * False
#
# Related options:
#     * None
#
#  (boolean value)
# from .default.glance.api.allow_anonymous_access
{{ if not .default.glance.api.allow_anonymous_access }}#{{ end }}allow_anonymous_access = {{ .default.glance.api.allow_anonymous_access | default "false" }}

#
# Limit the request ID length.
#
# Provide  an integer value to limit the length of the request ID to
# the specified length. The default value is 64. Users can change this
# to any ineteger value between 0 and 16384 however keeping in mind that
# a larger value may flood the logs.
#
# Possible values:
#     * Integer value between 0 and 16384
#
# Related options:
#     * None
#
#  (integer value)
# Minimum value: 0
# from .default.glance.api.max_request_id_length
{{ if not .default.glance.api.max_request_id_length }}#{{ end }}max_request_id_length = {{ .default.glance.api.max_request_id_length | default "64" }}

#
# Public url endpoint to use for Glance/Glare versions response.
#
# This is the public url endpoint that will appear in the Glance/Glare
# "versions" response. If no value is specified, the endpoint that is
# displayed in the version's response is that of the host running the
# API service. Change the endpoint to represent the proxy URL if the
# API service is running behind a proxy. If the service is running
# behind a load balancer, add the load balancer's URL for this value.
#
# Possible values:
#     * None
#     * Proxy URL
#     * Load balancer URL
#
# Related options:
#     * None
#
#  (string value)
# from .default.glance.api.public_endpoint
{{ if not .default.glance.api.public_endpoint }}#{{ end }}public_endpoint = {{ .default.glance.api.public_endpoint | default "<None>" }}

#
# Allow users to add additional/custom properties to images.
#
# Glance defines a standard set of properties (in its schema) that
# appear on every image. These properties are also known as
# ``base properties``. In addition to these properties, Glance
# allows users to add custom properties to images. These are known
# as ``additional properties``.
#
# By default, this configuration option is set to ``True`` and users
# are allowed to add additional properties. The number of additional
# properties that can be added to an image can be controlled via
# ``image_property_quota`` configuration option.
#
# Possible values:
#     * True
#     * False
#
# Related options:
#     * image_property_quota
#
#  (boolean value)
# from .default.glance.api.allow_additional_image_properties
{{ if not .default.glance.api.allow_additional_image_properties }}#{{ end }}allow_additional_image_properties = {{ .default.glance.api.allow_additional_image_properties | default "true" }}

#
# Maximum number of image members per image.
#
# This limits the maximum of users an image can be shared with. Any negative
# value is interpreted as unlimited.
#
# Related options:
#     * None
#
#  (integer value)
# from .default.glance.api.image_member_quota
{{ if not .default.glance.api.image_member_quota }}#{{ end }}image_member_quota = {{ .default.glance.api.image_member_quota | default "128" }}

#
# Maximum number of properties allowed on an image.
#
# This enforces an upper limit on the number of additional properties an image
# can have. Any negative value is interpreted as unlimited.
#
# NOTE: This won't have any impact if additional properties are disabled. Please
# refer to ``allow_additional_image_properties``.
#
# Related options:
#     * ``allow_additional_image_properties``
#
#  (integer value)
# from .default.glance.api.image_property_quota
{{ if not .default.glance.api.image_property_quota }}#{{ end }}image_property_quota = {{ .default.glance.api.image_property_quota | default "128" }}

#
# Maximum number of tags allowed on an image.
#
# Any negative value is interpreted as unlimited.
#
# Related options:
#     * None
#
#  (integer value)
# from .default.glance.api.image_tag_quota
{{ if not .default.glance.api.image_tag_quota }}#{{ end }}image_tag_quota = {{ .default.glance.api.image_tag_quota | default "128" }}

#
# Maximum number of locations allowed on an image.
#
# Any negative value is interpreted as unlimited.
#
# Related options:
#     * None
#
#  (integer value)
# from .default.glance.api.image_location_quota
{{ if not .default.glance.api.image_location_quota }}#{{ end }}image_location_quota = {{ .default.glance.api.image_location_quota | default "10" }}

#
# Python module path of data access API.
#
# Specifies the path to the API to use for accessing the data model.
# This option determines how the image catalog data will be accessed.
#
# Possible values:
#     * glance.db.sqlalchemy.api
#     * glance.db.registry.api
#     * glance.db.simple.api
#
# If this option is set to ``glance.db.sqlalchemy.api`` then the image
# catalog data is stored in and read from the database via the
# SQLAlchemy Core and ORM APIs.
#
# Setting this option to ``glance.db.registry.api`` will force all
# database access requests to be routed through the Registry service.
# This avoids data access from the Glance API nodes for an added layer
# of security, scalability and manageability.
#
# NOTE: In v2 OpenStack Images API, the registry service is optional.
# In order to use the Registry API in v2, the option
# ``enable_v2_registry`` must be set to ``True``.
#
# Finally, when this configuration option is set to
# ``glance.db.simple.api``, image catalog data is stored in and read
# from an in-memory data structure. This is primarily used for testing.
#
# Related options:
#     * enable_v2_api
#     * enable_v2_registry
#
#  (string value)
# from .default.glance.api.data_api
{{ if not .default.glance.api.data_api }}#{{ end }}data_api = {{ .default.glance.api.data_api | default "glance.db.sqlalchemy.api" }}

#
# The default number of results to return for a request.
#
# Responses to certain API requests, like list images, may return
# multiple items. The number of results returned can be explicitly
# controlled by specifying the ``limit`` parameter in the API request.
# However, if a ``limit`` parameter is not specified, this
# configuration value will be used as the default number of results to
# be returned for any API request.
#
# NOTES:
#     * The value of this configuration option may not be greater than
#       the value specified by ``api_limit_max``.
#     * Setting this to a very large value may slow down database
#       queries and increase response times. Setting this to a
#       very low value may result in poor user experience.
#
# Possible values:
#     * Any positive integer
#
# Related options:
#     * api_limit_max
#
#  (integer value)
# Minimum value: 1
# from .default.glance.api.limit_param_default
{{ if not .default.glance.api.limit_param_default }}#{{ end }}limit_param_default = {{ .default.glance.api.limit_param_default | default "25" }}

#
# Maximum number of results that could be returned by a request.
#
# As described in the help text of ``limit_param_default``, some
# requests may return multiple results. The number of results to be
# returned are governed either by the ``limit`` parameter in the
# request or the ``limit_param_default`` configuration option.
# The value in either case, can't be greater than the absolute maximum
# defined by this configuration option. Anything greater than this
# value is trimmed down to the maximum value defined here.
#
# NOTE: Setting this to a very large value may slow down database
#       queries and increase response times. Setting this to a
#       very low value may result in poor user experience.
#
# Possible values:
#     * Any positive integer
#
# Related options:
#     * limit_param_default
#
#  (integer value)
# Minimum value: 1
# from .default.glance.api.api_limit_max
{{ if not .default.glance.api.api_limit_max }}#{{ end }}api_limit_max = {{ .default.glance.api.api_limit_max | default "1000" }}

#
# Show direct image location when returning an image.
#
# This configuration option indicates whether to show the direct image
# location when returning image details to the user. The direct image
# location is where the image data is stored in backend storage. This
# image location is shown under the image property ``direct_url``.
#
# When multiple image locations exist for an image, the best location
# is displayed based on the location strategy indicated by the
# configuration option ``location_strategy``.
#
# NOTES:
#     * Revealing image locations can present a GRAVE SECURITY RISK as
#       image locations can sometimes include credentials. Hence, this
#       is set to ``False`` by default. Set this to ``True`` with
#       EXTREME CAUTION and ONLY IF you know what you are doing!
#     * If an operator wishes to avoid showing any image location(s)
#       to the user, then both this option and
#       ``show_multiple_locations`` MUST be set to ``False``.
#
# Possible values:
#     * True
#     * False
#
# Related options:
#     * show_multiple_locations
#     * location_strategy
#
#  (boolean value)
# from .default.glance.api.show_image_direct_url
{{ if not .default.glance.api.show_image_direct_url }}#{{ end }}show_image_direct_url = {{ .default.glance.api.show_image_direct_url | default "false" }}

# DEPRECATED:
# Show all image locations when returning an image.
#
# This configuration option indicates whether to show all the image
# locations when returning image details to the user. When multiple
# image locations exist for an image, the locations are ordered based
# on the location strategy indicated by the configuration opt
# ``location_strategy``. The image locations are shown under the
# image property ``locations``.
#
# NOTES:
#     * Revealing image locations can present a GRAVE SECURITY RISK as
#       image locations can sometimes include credentials. Hence, this
#       is set to ``False`` by default. Set this to ``True`` with
#       EXTREME CAUTION and ONLY IF you know what you are doing!
#     * If an operator wishes to avoid showing any image location(s)
#       to the user, then both this option and
#       ``show_image_direct_url`` MUST be set to ``False``.
#
# Possible values:
#     * True
#     * False
#
# Related options:
#     * show_image_direct_url
#     * location_strategy
#
#  (boolean value)
# This option is deprecated for removal since Newton.
# Its value may be silently ignored in the future.
# Reason: This option will be removed in the Ocata release because the same
# functionality can be achieved with greater granularity by using policies.
# Please see the Newton release notes for more information.
# from .default.glance.api.show_multiple_locations
{{ if not .default.glance.api.show_multiple_locations }}#{{ end }}show_multiple_locations = {{ .default.glance.api.show_multiple_locations | default "false" }}

#
# Maximum size of image a user can upload in bytes.
#
# An image upload greater than the size mentioned here would result
# in an image creation failure. This configuration option defaults to
# 1099511627776 bytes (1 TiB).
#
# NOTES:
#     * This value should only be increased after careful
#       consideration and must be set less than or equal to
#       8 EiB (9223372036854775808).
#     * This value must be set with careful consideration of the
#       backend storage capacity. Setting this to a very low value
#       may result in a large number of image failures. And, setting
#       this to a very large value may result in faster consumption
#       of storage. Hence, this must be set according to the nature of
#       images created and storage capacity available.
#
# Possible values:
#     * Any positive number less than or equal to 9223372036854775808
#
#  (integer value)
# Minimum value: 1
# Maximum value: 9223372036854775808
# from .default.glance.api.image_size_cap
{{ if not .default.glance.api.image_size_cap }}#{{ end }}image_size_cap = {{ .default.glance.api.image_size_cap | default "1099511627776" }}

#
# Maximum amount of image storage per tenant.
#
# This enforces an upper limit on the cumulative storage consumed by all images
# of a tenant across all stores. This is a per-tenant limit.
#
# The default unit for this configuration option is Bytes. However, storage
# units can be specified using case-sensitive literals ``B``, ``KB``, ``MB``,
# ``GB`` and ``TB`` representing Bytes, KiloBytes, MegaBytes, GigaBytes and
# TeraBytes respectively. Note that there should not be any space between the
# value and unit. Value ``0`` signifies no quota enforcement. Negative values
# are invalid and result in errors.
#
# Possible values:
#     * A string that is a valid concatenation of a non-negative integer
#       representing the storage value and an optional string literal
#       representing storage units as mentioned above.
#
# Related options:
#     * None
#
#  (string value)
# from .default.glance.api.user_storage_quota
{{ if not .default.glance.api.user_storage_quota }}#{{ end }}user_storage_quota = {{ .default.glance.api.user_storage_quota | default "0" }}

#
# Deploy the v1 OpenStack Images API.
#
# When this option is set to ``True``, Glance service will respond to
# requests on registered endpoints conforming to the v1 OpenStack
# Images API.
#
# NOTES:
#     * If this option is enabled, then ``enable_v1_registry`` must
#       also be set to ``True`` to enable mandatory usage of Registry
#       service with v1 API.
#
#     * If this option is disabled, then the ``enable_v1_registry``
#       option, which is enabled by default, is also recommended
#       to be disabled.
#
#     * This option is separate from ``enable_v2_api``, both v1 and v2
#       OpenStack Images API can be deployed independent of each
#       other.
#
#     * If deploying only the v2 Images API, this option, which is
#       enabled by default, should be disabled.
#
# Possible values:
#     * True
#     * False
#
# Related options:
#     * enable_v1_registry
#     * enable_v2_api
#
#  (boolean value)
# from .default.glance.api.enable_v1_api
{{ if not .default.glance.api.enable_v1_api }}#{{ end }}enable_v1_api = {{ .default.glance.api.enable_v1_api | default "true" }}

#
# Deploy the v2 OpenStack Images API.
#
# When this option is set to ``True``, Glance service will respond
# to requests on registered endpoints conforming to the v2 OpenStack
# Images API.
#
# NOTES:
#     * If this option is disabled, then the ``enable_v2_registry``
#       option, which is enabled by default, is also recommended
#       to be disabled.
#
#     * This option is separate from ``enable_v1_api``, both v1 and v2
#       OpenStack Images API can be deployed independent of each
#       other.
#
#     * If deploying only the v1 Images API, this option, which is
#       enabled by default, should be disabled.
#
# Possible values:
#     * True
#     * False
#
# Related options:
#     * enable_v2_registry
#     * enable_v1_api
#
#  (boolean value)
# from .default.glance.api.enable_v2_api
{{ if not .default.glance.api.enable_v2_api }}#{{ end }}enable_v2_api = {{ .default.glance.api.enable_v2_api | default "true" }}

#
# Deploy the v1 API Registry service.
#
# When this option is set to ``True``, the Registry service
# will be enabled in Glance for v1 API requests.
#
# NOTES:
#     * Use of Registry is mandatory in v1 API, so this option must
#       be set to ``True`` if the ``enable_v1_api`` option is enabled.
#
#     * If deploying only the v2 OpenStack Images API, this option,
#       which is enabled by default, should be disabled.
#
# Possible values:
#     * True
#     * False
#
# Related options:
#     * enable_v1_api
#
#  (boolean value)
# from .default.glance.api.enable_v1_registry
{{ if not .default.glance.api.enable_v1_registry }}#{{ end }}enable_v1_registry = {{ .default.glance.api.enable_v1_registry | default "true" }}

#
# Deploy the v2 API Registry service.
#
# When this option is set to ``True``, the Registry service
# will be enabled in Glance for v2 API requests.
#
# NOTES:
#     * Use of Registry is optional in v2 API, so this option
#       must only be enabled if both ``enable_v2_api`` is set to
#       ``True`` and the ``data_api`` option is set to
#       ``glance.db.registry.api``.
#
#     * If deploying only the v1 OpenStack Images API, this option,
#       which is enabled by default, should be disabled.
#
# Possible values:
#     * True
#     * False
#
# Related options:
#     * enable_v2_api
#     * data_api
#
#  (boolean value)
# from .default.glance.api.enable_v2_registry
{{ if not .default.glance.api.enable_v2_registry }}#{{ end }}enable_v2_registry = {{ .default.glance.api.enable_v2_registry | default "true" }}

#
# Host address of the pydev server.
#
# Provide a string value representing the hostname or IP of the
# pydev server to use for debugging. The pydev server listens for
# debug connections on this address, facilitating remote debugging
# in Glance.
#
# Possible values:
#     * Valid hostname
#     * Valid IP address
#
# Related options:
#     * None
#
#  (string value)
# from .default.glance.api.pydev_worker_debug_host
{{ if not .default.glance.api.pydev_worker_debug_host }}#{{ end }}pydev_worker_debug_host = {{ .default.glance.api.pydev_worker_debug_host | default "localhost" }}

#
# Port number that the pydev server will listen on.
#
# Provide a port number to bind the pydev server to. The pydev
# process accepts debug connections on this port and facilitates
# remote debugging in Glance.
#
# Possible values:
#     * A valid port number
#
# Related options:
#     * None
#
#  (port value)
# Minimum value: 0
# Maximum value: 65535
# from .default.glance.api.pydev_worker_debug_port
{{ if not .default.glance.api.pydev_worker_debug_port }}#{{ end }}pydev_worker_debug_port = {{ .default.glance.api.pydev_worker_debug_port | default "5678" }}

#
# AES key for encrypting store location metadata.
#
# Provide a string value representing the AES cipher to use for
# encrypting Glance store metadata.
#
# NOTE: The AES key to use must be set to a random string of length
# 16, 24 or 32 bytes.
#
# Possible values:
#     * String value representing a valid AES key
#
# Related options:
#     * None
#
#  (string value)
# from .default.glance.api.metadata_encryption_key
{{ if not .default.glance.api.metadata_encryption_key }}#{{ end }}metadata_encryption_key = {{ .default.glance.api.metadata_encryption_key | default "<None>" }}

#
# Digest algorithm to use for digital signature.
#
# Provide a string value representing the digest algorithm to
# use for generating digital signatures. By default, ``sha256``
# is used.
#
# To get a list of the available algorithms supported by the version
# of OpenSSL on your platform, run the command:
# ``openssl list-message-digest-algorithms``.
# Examples are 'sha1', 'sha256', and 'sha512'.
#
# NOTE: ``digest_algorithm`` is not related to Glance's image signing
# and verification. It is only used to sign the universally unique
# identifier (UUID) as a part of the certificate file and key file
# validation.
#
# Possible values:
#     * An OpenSSL message digest algorithm identifier
#
# Relation options:
#     * None
#
#  (string value)
# from .default.glance.api.digest_algorithm
{{ if not .default.glance.api.digest_algorithm }}#{{ end }}digest_algorithm = {{ .default.glance.api.digest_algorithm | default "sha256" }}

#
# Strategy to determine the preference order of image locations.
#
# This configuration option indicates the strategy to determine
# the order in which an image's locations must be accessed to
# serve the image's data. Glance then retrieves the image data
# from the first responsive active location it finds in this list.
#
# This option takes one of two possible values ``location_order``
# and ``store_type``. The default value is ``location_order``,
# which suggests that image data be served by using locations in
# the order they are stored in Glance. The ``store_type`` value
# sets the image location preference based on the order in which
# the storage backends are listed as a comma separated list for
# the configuration option ``store_type_preference``.
#
# Possible values:
#     * location_order
#     * store_type
#
# Related options:
#     * store_type_preference
#
#  (string value)
# Allowed values: location_order, store_type
# from .default.glance.api.location_strategy
{{ if not .default.glance.api.location_strategy }}#{{ end }}location_strategy = {{ .default.glance.api.location_strategy | default "location_order" }}

#
# The location of the property protection file.
#
# Provide a valid path to the property protection file which contains
# the rules for property protections and the roles/policies associated
# with them.
#
# A property protection file, when set, restricts the Glance image
# properties to be created, read, updated and/or deleted by a specific
# set of users that are identified by either roles or policies.
# If this configuration option is not set, by default, property
# protections won't be enforced. If a value is specified and the file
# is not found, the glance-api service will fail to start.
# More information on property protections can be found at:
# http://docs.openstack.org/developer/glance/property-protections.html
#
# Possible values:
#     * Empty string
#     * Valid path to the property protection configuration file
#
# Related options:
#     * property_protection_rule_format
#
#  (string value)
# from .default.glance.api.property_protection_file
{{ if not .default.glance.api.property_protection_file }}#{{ end }}property_protection_file = {{ .default.glance.api.property_protection_file | default "<None>" }}

#
# Rule format for property protection.
#
# Provide the desired way to set property protection on Glance
# image properties. The two permissible values are ``roles``
# and ``policies``. The default value is ``roles``.
#
# If the value is ``roles``, the property protection file must
# contain a comma separated list of user roles indicating
# permissions for each of the CRUD operations on each property
# being protected. If set to ``policies``, a policy defined in
# policy.json is used to express property protections for each
# of the CRUD operations. Examples of how property protections
# are enforced based on ``roles`` or ``policies`` can be found at:
# http://docs.openstack.org/developer/glance/property-protections.html#examples
#
# Possible values:
#     * roles
#     * policies
#
# Related options:
#     * property_protection_file
#
#  (string value)
# Allowed values: roles, policies
# from .default.glance.api.property_protection_rule_format
{{ if not .default.glance.api.property_protection_rule_format }}#{{ end }}property_protection_rule_format = {{ .default.glance.api.property_protection_rule_format | default "roles" }}

#
# List of allowed exception modules to handle RPC exceptions.
#
# Provide a comma separated list of modules whose exceptions are
# permitted to be recreated upon receiving exception data via an RPC
# call made to Glance. The default list includes
# ``glance.common.exception``, ``builtins``, and ``exceptions``.
#
# The RPC protocol permits interaction with Glance via calls across a
# network or within the same system. Including a list of exception
# namespaces with this option enables RPC to propagate the exceptions
# back to the users.
#
# Possible values:
#     * A comma separated list of valid exception modules
#
# Related options:
#     * None
#  (list value)
# from .default.glance.api.allowed_rpc_exception_modules
{{ if not .default.glance.api.allowed_rpc_exception_modules }}#{{ end }}allowed_rpc_exception_modules = {{ .default.glance.api.allowed_rpc_exception_modules | default "glance.common.exception,builtins,exceptions" }}

#
# IP address to bind the glance servers to.
#
# Provide an IP address to bind the glance server to. The default
# value is ``0.0.0.0``.
#
# Edit this option to enable the server to listen on one particular
# IP address on the network card. This facilitates selection of a
# particular network interface for the server.
#
# Possible values:
#     * A valid IPv4 address
#     * A valid IPv6 address
#
# Related options:
#     * None
#
#  (string value)
# from .default.glance.api.bind_host
{{ if not .default.glance.api.bind_host }}#{{ end }}bind_host = {{ .default.glance.api.bind_host | default "0.0.0.0" }}

#
# Port number on which the server will listen.
#
# Provide a valid port number to bind the server's socket to. This
# port is then set to identify processes and forward network messages
# that arrive at the server. The default bind_port value for the API
# server is 9292 and for the registry server is 9191.
#
# Possible values:
#     * A valid port number (0 to 65535)
#
# Related options:
#     * None
#
#  (port value)
# Minimum value: 0
# Maximum value: 65535
# from .default.glance.api.bind_port
{{ if not .default.glance.api.bind_port }}#{{ end }}bind_port = {{ .default.glance.api.bind_port | default "<None>" }}

#
# Number of Glance worker processes to start.
#
# Provide a non-negative integer value to set the number of child
# process workers to service requests. By default, the number of CPUs
# available is set as the value for ``workers``.
#
# Each worker process is made to listen on the port set in the
# configuration file and contains a greenthread pool of size 1000.
#
# NOTE: Setting the number of workers to zero, triggers the creation
# of a single API process with a greenthread pool of size 1000.
#
# Possible values:
#     * 0
#     * Positive integer value (typically equal to the number of CPUs)
#
# Related options:
#     * None
#
#  (integer value)
# Minimum value: 0
# from .default.glance.api.workers
{{ if not .default.glance.api.workers }}#{{ end }}workers = {{ .default.glance.api.workers | default "<None>" }}

#
# Maximum line size of message headers.
#
# Provide an integer value representing a length to limit the size of
# message headers. The default value is 16384.
#
# NOTE: ``max_header_line`` may need to be increased when using large
# tokens (typically those generated by the Keystone v3 API with big
# service catalogs). However, it is to be kept in mind that larger
# values for ``max_header_line`` would flood the logs.
#
# Setting ``max_header_line`` to 0 sets no limit for the line size of
# message headers.
#
# Possible values:
#     * 0
#     * Positive integer
#
# Related options:
#     * None
#
#  (integer value)
# Minimum value: 0
# from .default.glance.api.max_header_line
{{ if not .default.glance.api.max_header_line }}#{{ end }}max_header_line = {{ .default.glance.api.max_header_line | default "16384" }}

#
# Set keep alive option for HTTP over TCP.
#
# Provide a boolean value to determine sending of keep alive packets.
# If set to ``False``, the server returns the header
# "Connection: close". If set to ``True``, the server returns a
# "Connection: Keep-Alive" in its responses. This enables retention of
# the same TCP connection for HTTP conversations instead of opening a
# new one with each new request.
#
# This option must be set to ``False`` if the client socket connection
# needs to be closed explicitly after the response is received and
# read successfully by the client.
#
# Possible values:
#     * True
#     * False
#
# Related options:
#     * None
#
#  (boolean value)
# from .default.glance.api.http_keepalive
{{ if not .default.glance.api.http_keepalive }}#{{ end }}http_keepalive = {{ .default.glance.api.http_keepalive | default "true" }}

#
# Timeout for client connections' socket operations.
#
# Provide a valid integer value representing time in seconds to set
# the period of wait before an incoming connection can be closed. The
# default value is 900 seconds.
#
# The value zero implies wait forever.
#
# Possible values:
#     * Zero
#     * Positive integer
#
# Related options:
#     * None
#
#  (integer value)
# Minimum value: 0
# from .default.glance.api.client_socket_timeout
{{ if not .default.glance.api.client_socket_timeout }}#{{ end }}client_socket_timeout = {{ .default.glance.api.client_socket_timeout | default "900" }}

#
# Set the number of incoming connection requests.
#
# Provide a positive integer value to limit the number of requests in
# the backlog queue. The default queue size is 4096.
#
# An incoming connection to a TCP listener socket is queued before a
# connection can be established with the server. Setting the backlog
# for a TCP socket ensures a limited queue size for incoming traffic.
#
# Possible values:
#     * Positive integer
#
# Related options:
#     * None
#
#  (integer value)
# Minimum value: 1
# from .default.glance.api.backlog
{{ if not .default.glance.api.backlog }}#{{ end }}backlog = {{ .default.glance.api.backlog | default "4096" }}

#
# Set the wait time before a connection recheck.
#
# Provide a positive integer value representing time in seconds which
# is set as the idle wait time before a TCP keep alive packet can be
# sent to the host. The default value is 600 seconds.
#
# Setting ``tcp_keepidle`` helps verify at regular intervals that a
# connection is intact and prevents frequent TCP connection
# reestablishment.
#
# Possible values:
#     * Positive integer value representing time in seconds
#
# Related options:
#     * None
#
#  (integer value)
# Minimum value: 1
# from .default.glance.api.tcp_keepidle
{{ if not .default.glance.api.tcp_keepidle }}#{{ end }}tcp_keepidle = {{ .default.glance.api.tcp_keepidle | default "600" }}

#
# Absolute path to the CA file.
#
# Provide a string value representing a valid absolute path to
# the Certificate Authority file to use for client authentication.
#
# A CA file typically contains necessary trusted certificates to
# use for the client authentication. This is essential to ensure
# that a secure connection is established to the server via the
# internet.
#
# Possible values:
#     * Valid absolute path to the CA file
#
# Related options:
#     * None
#
#  (string value)
# from .default.glance.api.ca_file
{{ if not .default.glance.api.ca_file }}#{{ end }}ca_file = {{ .default.glance.api.ca_file | default "/etc/ssl/cafile" }}

#
# Absolute path to the certificate file.
#
# Provide a string value representing a valid absolute path to the
# certificate file which is required to start the API service
# securely.
#
# A certificate file typically is a public key container and includes
# the server's public key, server name, server information and the
# signature which was a result of the verification process using the
# CA certificate. This is required for a secure connection
# establishment.
#
# Possible values:
#     * Valid absolute path to the certificate file
#
# Related options:
#     * None
#
#  (string value)
# from .default.glance.api.cert_file
{{ if not .default.glance.api.cert_file }}#{{ end }}cert_file = {{ .default.glance.api.cert_file | default "/etc/ssl/certs" }}

#
# Absolute path to a private key file.
#
# Provide a string value representing a valid absolute path to a
# private key file which is required to establish the client-server
# connection.
#
# Possible values:
#     * Absolute path to the private key file
#
# Related options:
#     * None
#
#  (string value)
# from .default.glance.api.key_file
{{ if not .default.glance.api.key_file }}#{{ end }}key_file = {{ .default.glance.api.key_file | default "/etc/ssl/key/key-file.pem" }}

# DEPRECATED: The HTTP header used to determine the scheme for the original
# request, even if it was removed by an SSL terminating proxy. Typical value is
# "HTTP_X_FORWARDED_PROTO". (string value)
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# Reason: Use the http_proxy_to_wsgi middleware instead.
# from .default.glance.api.secure_proxy_ssl_header
{{ if not .default.glance.api.secure_proxy_ssl_header }}#{{ end }}secure_proxy_ssl_header = {{ .default.glance.api.secure_proxy_ssl_header | default "<None>" }}

#
# The relative path to sqlite file database that will be used for image cache
# management.
#
# This is a relative path to the sqlite file database that tracks the age and
# usage statistics of image cache. The path is relative to image cache base
# directory, specified by the configuration option ``image_cache_dir``.
#
# This is a lightweight database with just one table.
#
# Possible values:
#     * A valid relative path to sqlite file database
#
# Related options:
#     * ``image_cache_dir``
#
#  (string value)
# from .default.glance.api.image_cache_sqlite_db
{{ if not .default.glance.api.image_cache_sqlite_db }}#{{ end }}image_cache_sqlite_db = {{ .default.glance.api.image_cache_sqlite_db | default "cache.db" }}

#
# The driver to use for image cache management.
#
# This configuration option provides the flexibility to choose between the
# different image-cache drivers available. An image-cache driver is responsible
# for providing the essential functions of image-cache like write images to/read
# images from cache, track age and usage of cached images, provide a list of
# cached images, fetch size of the cache, queue images for caching and clean up
# the cache, etc.
#
# The essential functions of a driver are defined in the base class
# ``glance.image_cache.drivers.base.Driver``. All image-cache drivers (existing
# and prospective) must implement this interface. Currently available drivers
# are ``sqlite`` and ``xattr``. These drivers primarily differ in the way they
# store the information about cached images:
#     * The ``sqlite`` driver uses a sqlite database (which sits on every glance
#     node locally) to track the usage of cached images.
#     * The ``xattr`` driver uses the extended attributes of files to store this
#     information. It also requires a filesystem that sets ``atime`` on the
# files
#     when accessed.
#
# Possible values:
#     * sqlite
#     * xattr
#
# Related options:
#     * None
#
#  (string value)
# Allowed values: sqlite, xattr
# from .default.glance.api.image_cache_driver
{{ if not .default.glance.api.image_cache_driver }}#{{ end }}image_cache_driver = {{ .default.glance.api.image_cache_driver | default "sqlite" }}

#
# The upper limit on cache size, in bytes, after which the cache-pruner cleans
# up the image cache.
#
# NOTE: This is just a threshold for cache-pruner to act upon. It is NOT a
# hard limit beyond which the image cache would never grow. In fact, depending
# on how often the cache-pruner runs and how quickly the cache fills, the image
# cache can far exceed the size specified here very easily. Hence, care must be
# taken to appropriately schedule the cache-pruner and in setting this limit.
#
# Glance caches an image when it is downloaded. Consequently, the size of the
# image cache grows over time as the number of downloads increases. To keep the
# cache size from becoming unmanageable, it is recommended to run the
# cache-pruner as a periodic task. When the cache pruner is kicked off, it
# compares the current size of image cache and triggers a cleanup if the image
# cache grew beyond the size specified here. After the cleanup, the size of
# cache is less than or equal to size specified here.
#
# Possible values:
#     * Any non-negative integer
#
# Related options:
#     * None
#
#  (integer value)
# Minimum value: 0
# from .default.glance.api.image_cache_max_size
{{ if not .default.glance.api.image_cache_max_size }}#{{ end }}image_cache_max_size = {{ .default.glance.api.image_cache_max_size | default "10737418240" }}

#
# The amount of time, in seconds, an incomplete image remains in the cache.
#
# Incomplete images are images for which download is in progress. Please see the
# description of configuration option ``image_cache_dir`` for more detail.
# Sometimes, due to various reasons, it is possible the download may hang and
# the incompletely downloaded image remains in the ``incomplete`` directory.
# This configuration option sets a time limit on how long the incomplete images
# should remain in the ``incomplete`` directory before they are cleaned up.
# Once an incomplete image spends more time than is specified here, it'll be
# removed by cache-cleaner on its next run.
#
# It is recommended to run cache-cleaner as a periodic task on the Glance API
# nodes to keep the incomplete images from occupying disk space.
#
# Possible values:
#     * Any non-negative integer
#
# Related options:
#     * None
#
#  (integer value)
# Minimum value: 0
# from .default.glance.api.image_cache_stall_time
{{ if not .default.glance.api.image_cache_stall_time }}#{{ end }}image_cache_stall_time = {{ .default.glance.api.image_cache_stall_time | default "86400" }}

#
# Base directory for image cache.
#
# This is the location where image data is cached and served out of. All cached
# images are stored directly under this directory. This directory also contains
# three subdirectories, namely, ``incomplete``, ``invalid`` and ``queue``.
#
# The ``incomplete`` subdirectory is the staging area for downloading images. An
# image is first downloaded to this directory. When the image download is
# successful it is moved to the base directory. However, if the download fails,
# the partially downloaded image file is moved to the ``invalid`` subdirectory.
#
# The ``queue``subdirectory is used for queuing images for download. This is
# used primarily by the cache-prefetcher, which can be scheduled as a periodic
# task like cache-pruner and cache-cleaner, to cache images ahead of their
# usage.
# Upon receiving the request to cache an image, Glance touches a file in the
# ``queue`` directory with the image id as the file name. The cache-prefetcher,
# when running, polls for the files in ``queue`` directory and starts
# downloading them in the order they were created. When the download is
# successful, the zero-sized file is deleted from the ``queue`` directory.
# If the download fails, the zero-sized file remains and it'll be retried the
# next time cache-prefetcher runs.
#
# Possible values:
#     * A valid path
#
# Related options:
#     * ``image_cache_sqlite_db``
#
#  (string value)
# from .default.glance.api.image_cache_dir
{{ if not .default.glance.api.image_cache_dir }}#{{ end }}image_cache_dir = {{ .default.glance.api.image_cache_dir | default "<None>" }}

#
# Default publisher_id for outgoing Glance notifications.
#
# This is the value that the notification driver will use to identify
# messages for events originating from the Glance service. Typically,
# this is the hostname of the instance that generated the message.
#
# Possible values:
#     * Any reasonable instance identifier, for example: image.host1
#
# Related options:
#     * None
#
#  (string value)
# from .default.glance.api.default_publisher_id
{{ if not .default.glance.api.default_publisher_id }}#{{ end }}default_publisher_id = {{ .default.glance.api.default_publisher_id | default "image.localhost" }}

#
# List of notifications to be disabled.
#
# Specify a list of notifications that should not be emitted.
# A notification can be given either as a notification type to
# disable a single event notification, or as a notification group
# prefix to disable all event notifications within a group.
#
# Possible values:
#     A comma-separated list of individual notification types or
#     notification groups to be disabled. Currently supported groups:
#         * image
#         * image.member
#         * task
#         * metadef_namespace
#         * metadef_object
#         * metadef_property
#         * metadef_resource_type
#         * metadef_tag
#     For a complete listing and description of each event refer to:
#     http://docs.openstack.org/developer/glance/notifications.html
#
#     The values must be specified as: <group_name>.<event_name>
#     For example: image.create,task.success,metadef_tag
#
# Related options:
#     * None
#
#  (list value)
# from .default.glance.api.disabled_notifications
{{ if not .default.glance.api.disabled_notifications }}#{{ end }}disabled_notifications = {{ .default.glance.api.disabled_notifications | default "" }}

#
# Address the registry server is hosted on.
#
# Possible values:
#     * A valid IP or hostname
#
# Related options:
#     * None
#
#  (string value)
# from .default.glance.api.registry_host
{{ if not .default.glance.api.registry_host }}#{{ end }}registry_host = {{ .default.glance.api.registry_host | default "0.0.0.0" }}

#
# Port the registry server is listening on.
#
# Possible values:
#     * A valid port number
#
# Related options:
#     * None
#
#  (port value)
# Minimum value: 0
# Maximum value: 65535
# from .default.glance.api.registry_port
{{ if not .default.glance.api.registry_port }}#{{ end }}registry_port = {{ .default.glance.api.registry_port | default "9191" }}

# DEPRECATED: Whether to pass through the user token when making requests to the
# registry. To prevent failures with token expiration during big files upload,
# it is recommended to set this parameter to False.If "use_user_token" is not in
# effect, then admin credentials can be specified. (boolean value)
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# Reason: This option was considered harmful and has been deprecated in M
# release. It will be removed in O release. For more information read OSSN-0060.
# Related functionality with uploading big images has been implemented with
# Keystone trusts support.
# from .default.glance.api.use_user_token
{{ if not .default.glance.api.use_user_token }}#{{ end }}use_user_token = {{ .default.glance.api.use_user_token | default "true" }}

# DEPRECATED: The administrators user name. If "use_user_token" is not in
# effect, then admin credentials can be specified. (string value)
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# Reason: This option was considered harmful and has been deprecated in M
# release. It will be removed in O release. For more information read OSSN-0060.
# Related functionality with uploading big images has been implemented with
# Keystone trusts support.
# from .default.glance.api.admin_user
{{ if not .default.glance.api.admin_user }}#{{ end }}admin_user = {{ .default.glance.api.admin_user | default "<None>" }}

# DEPRECATED: The administrators password. If "use_user_token" is not in effect,
# then admin credentials can be specified. (string value)
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# Reason: This option was considered harmful and has been deprecated in M
# release. It will be removed in O release. For more information read OSSN-0060.
# Related functionality with uploading big images has been implemented with
# Keystone trusts support.
# from .default.glance.api.admin_password
{{ if not .default.glance.api.admin_password }}#{{ end }}admin_password = {{ .default.glance.api.admin_password | default "<None>" }}

# DEPRECATED: The tenant name of the administrative user. If "use_user_token" is
# not in effect, then admin tenant name can be specified. (string value)
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# Reason: This option was considered harmful and has been deprecated in M
# release. It will be removed in O release. For more information read OSSN-0060.
# Related functionality with uploading big images has been implemented with
# Keystone trusts support.
# from .default.glance.api.admin_tenant_name
{{ if not .default.glance.api.admin_tenant_name }}#{{ end }}admin_tenant_name = {{ .default.glance.api.admin_tenant_name | default "<None>" }}

# DEPRECATED: The URL to the keystone service. If "use_user_token" is not in
# effect and using keystone auth, then URL of keystone can be specified. (string
# value)
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# Reason: This option was considered harmful and has been deprecated in M
# release. It will be removed in O release. For more information read OSSN-0060.
# Related functionality with uploading big images has been implemented with
# Keystone trusts support.
# from .default.glance.api.auth_url
{{ if not .default.glance.api.auth_url }}#{{ end }}auth_url = {{ .default.glance.api.auth_url | default "<None>" }}

# DEPRECATED: The strategy to use for authentication. If "use_user_token" is not
# in effect, then auth strategy can be specified. (string value)
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# Reason: This option was considered harmful and has been deprecated in M
# release. It will be removed in O release. For more information read OSSN-0060.
# Related functionality with uploading big images has been implemented with
# Keystone trusts support.
# from .default.glance.api.auth_strategy
{{ if not .default.glance.api.auth_strategy }}#{{ end }}auth_strategy = {{ .default.glance.api.auth_strategy | default "noauth" }}

# DEPRECATED: The region for the authentication service. If "use_user_token" is
# not in effect and using keystone auth, then region name can be specified.
# (string value)
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# Reason: This option was considered harmful and has been deprecated in M
# release. It will be removed in O release. For more information read OSSN-0060.
# Related functionality with uploading big images has been implemented with
# Keystone trusts support.
# from .default.glance.api.auth_region
{{ if not .default.glance.api.auth_region }}#{{ end }}auth_region = {{ .default.glance.api.auth_region | default "<None>" }}

#
# Protocol to use for communication with the registry server.
#
# Provide a string value representing the protocol to use for
# communication with the registry server. By default, this option is
# set to ``http`` and the connection is not secure.
#
# This option can be set to ``https`` to establish a secure connection
# to the registry server. In this case, provide a key to use for the
# SSL connection using the ``registry_client_key_file`` option. Also
# include the CA file and cert file using the options
# ``registry_client_ca_file`` and ``registry_client_cert_file``
# respectively.
#
# Possible values:
#     * http
#     * https
#
# Related options:
#     * registry_client_key_file
#     * registry_client_cert_file
#     * registry_client_ca_file
#
#  (string value)
# Allowed values: http, https
# from .default.glance.api.registry_client_protocol
{{ if not .default.glance.api.registry_client_protocol }}#{{ end }}registry_client_protocol = {{ .default.glance.api.registry_client_protocol | default "http" }}

#
# Absolute path to the private key file.
#
# Provide a string value representing a valid absolute path to the
# private key file to use for establishing a secure connection to
# the registry server.
#
# NOTE: This option must be set if ``registry_client_protocol`` is
# set to ``https``. Alternatively, the GLANCE_CLIENT_KEY_FILE
# environment variable may be set to a filepath of the key file.
#
# Possible values:
#     * String value representing a valid absolute path to the key
#       file.
#
# Related options:
#     * registry_client_protocol
#
#  (string value)
# from .default.glance.api.registry_client_key_file
{{ if not .default.glance.api.registry_client_key_file }}#{{ end }}registry_client_key_file = {{ .default.glance.api.registry_client_key_file | default "/etc/ssl/key/key-file.pem" }}

#
# Absolute path to the certificate file.
#
# Provide a string value representing a valid absolute path to the
# certificate file to use for establishing a secure connection to
# the registry server.
#
# NOTE: This option must be set if ``registry_client_protocol`` is
# set to ``https``. Alternatively, the GLANCE_CLIENT_CERT_FILE
# environment variable may be set to a filepath of the certificate
# file.
#
# Possible values:
#     * String value representing a valid absolute path to the
#       certificate file.
#
# Related options:
#     * registry_client_protocol
#
#  (string value)
# from .default.glance.api.registry_client_cert_file
{{ if not .default.glance.api.registry_client_cert_file }}#{{ end }}registry_client_cert_file = {{ .default.glance.api.registry_client_cert_file | default "/etc/ssl/certs/file.crt" }}

#
# Absolute path to the Certificate Authority file.
#
# Provide a string value representing a valid absolute path to the
# certificate authority file to use for establishing a secure
# connection to the registry server.
#
# NOTE: This option must be set if ``registry_client_protocol`` is
# set to ``https``. Alternatively, the GLANCE_CLIENT_CA_FILE
# environment variable may be set to a filepath of the CA file.
# This option is ignored if the ``registry_client_insecure`` option
# is set to ``True``.
#
# Possible values:
#     * String value representing a valid absolute path to the CA
#       file.
#
# Related options:
#     * registry_client_protocol
#     * registry_client_insecure
#
#  (string value)
# from .default.glance.api.registry_client_ca_file
{{ if not .default.glance.api.registry_client_ca_file }}#{{ end }}registry_client_ca_file = {{ .default.glance.api.registry_client_ca_file | default "/etc/ssl/cafile/file.ca" }}

#
# Set verification of the registry server certificate.
#
# Provide a boolean value to determine whether or not to validate
# SSL connections to the registry server. By default, this option
# is set to ``False`` and the SSL connections are validated.
#
# If set to ``True``, the connection to the registry server is not
# validated via a certifying authority and the
# ``registry_client_ca_file`` option is ignored. This is the
# registry's equivalent of specifying --insecure on the command line
# using glanceclient for the API.
#
# Possible values:
#     * True
#     * False
#
# Related options:
#     * registry_client_protocol
#     * registry_client_ca_file
#
#  (boolean value)
# from .default.glance.api.registry_client_insecure
{{ if not .default.glance.api.registry_client_insecure }}#{{ end }}registry_client_insecure = {{ .default.glance.api.registry_client_insecure | default "false" }}

#
# Timeout value for registry requests.
#
# Provide an integer value representing the period of time in seconds
# that the API server will wait for a registry request to complete.
# The default value is 600 seconds.
#
# A value of 0 implies that a request will never timeout.
#
# Possible values:
#     * Zero
#     * Positive integer
#
# Related options:
#     * None
#
#  (integer value)
# Minimum value: 0
# from .default.glance.api.registry_client_timeout
{{ if not .default.glance.api.registry_client_timeout }}#{{ end }}registry_client_timeout = {{ .default.glance.api.registry_client_timeout | default "600" }}

#
# Send headers received from identity when making requests to
# registry.
#
# Typically, Glance registry can be deployed in multiple flavors,
# which may or may not include authentication. For example,
# ``trusted-auth`` is a flavor that does not require the registry
# service to authenticate the requests it receives. However, the
# registry service may still need a user context to be populated to
# serve the requests. This can be achieved by the caller
# (the Glance API usually) passing through the headers it received
# from authenticating with identity for the same request. The typical
# headers sent are ``X-User-Id``, ``X-Tenant-Id``, ``X-Roles``,
# ``X-Identity-Status`` and ``X-Service-Catalog``.
#
# Provide a boolean value to determine whether to send the identity
# headers to provide tenant and user information along with the
# requests to registry service. By default, this option is set to
# ``False``, which means that user and tenant information is not
# available readily. It must be obtained by authenticating. Hence, if
# this is set to ``False``, ``flavor`` must be set to value that
# either includes authentication or authenticated user context.
#
# Possible values:
#     * True
#     * False
#
# Related options:
#     * flavor
#
#  (boolean value)
# from .default.glance.api.send_identity_headers
{{ if not .default.glance.api.send_identity_headers }}#{{ end }}send_identity_headers = {{ .default.glance.api.send_identity_headers | default "false" }}

#
# The amount of time, in seconds, to delay image scrubbing.
#
# When delayed delete is turned on, an image is put into ``pending_delete``
# state upon deletion until the scrubber deletes its image data. Typically, soon
# after the image is put into ``pending_delete`` state, it is available for
# scrubbing. However, scrubbing can be delayed until a later point using this
# configuration option. This option denotes the time period an image spends in
# ``pending_delete`` state before it is available for scrubbing.
#
# It is important to realize that this has storage implications. The larger the
# ``scrub_time``, the longer the time to reclaim backend storage from deleted
# images.
#
# Possible values:
#     * Any non-negative integer
#
# Related options:
#     * ``delayed_delete``
#
#  (integer value)
# Minimum value: 0
# from .default.glance.api.scrub_time
{{ if not .default.glance.api.scrub_time }}#{{ end }}scrub_time = {{ .default.glance.api.scrub_time | default "0" }}

#
# The size of thread pool to be used for scrubbing images.
#
# When there are a large number of images to scrub, it is beneficial to scrub
# images in parallel so that the scrub queue stays in control and the backend
# storage is reclaimed in a timely fashion. This configuration option denotes
# the maximum number of images to be scrubbed in parallel. The default value is
# one, which signifies serial scrubbing. Any value above one indicates parallel
# scrubbing.
#
# Possible values:
#     * Any non-zero positive integer
#
# Related options:
#     * ``delayed_delete``
#
#  (integer value)
# Minimum value: 1
# from .default.glance.api.scrub_pool_size
{{ if not .default.glance.api.scrub_pool_size }}#{{ end }}scrub_pool_size = {{ .default.glance.api.scrub_pool_size | default "1" }}

#
# Turn on/off delayed delete.
#
# Typically when an image is deleted, the ``glance-api`` service puts the image
# into ``deleted`` state and deletes its data at the same time. Delayed delete
# is a feature in Glance that delays the actual deletion of image data until a
# later point in time (as determined by the configuration option
# ``scrub_time``).
# When delayed delete is turned on, the ``glance-api`` service puts the image
# into ``pending_delete`` state upon deletion and leaves the image data in the
# storage backend for the image scrubber to delete at a later time. The image
# scrubber will move the image into ``deleted`` state upon successful deletion
# of image data.
#
# NOTE: When delayed delete is turned on, image scrubber MUST be running as a
# periodic task to prevent the backend storage from filling up with undesired
# usage.
#
# Possible values:
#     * True
#     * False
#
# Related options:
#     * ``scrub_time``
#     * ``wakeup_time``
#     * ``scrub_pool_size``
#
#  (boolean value)
# from .default.glance.api.delayed_delete
{{ if not .default.glance.api.delayed_delete }}#{{ end }}delayed_delete = {{ .default.glance.api.delayed_delete | default "false" }}

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
# instantaneously. It makes sense only if log_file option is specified and Linux
# platform is used. This option is ignored if log_config_append is set. (boolean
# value)
# from .default.oslo.log.watch_log_file
{{ if not .default.oslo.log.watch_log_file }}#{{ end }}watch_log_file = {{ .default.oslo.log.watch_log_file | default "false" }}

# Use syslog for logging. Existing syslog format is DEPRECATED and will be
# changed later to honor RFC5424. This option is ignored if log_config_append is
# set. (boolean value)
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

# Additional data to append to log message when logging level for the message is
# DEBUG. (string value)
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

# The format for an instance that is passed with the log message. (string value)
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

# Seconds to wait before a cast expires (TTL). The default value of -1 specifies
# an infinite linger period. The value of 0 specifies no linger period. Pending
# messages shall be discarded immediately when the socket is closed. Only
# supported by impl_zmq. (integer value)
# Deprecated group/name - [DEFAULT]/rpc_cast_timeout
# from .default.oslo.messaging.rpc_cast_timeout
{{ if not .default.oslo.messaging.rpc_cast_timeout }}#{{ end }}rpc_cast_timeout = {{ .default.oslo.messaging.rpc_cast_timeout | default "-1" }}

# The default number of seconds that poll should wait. Poll raises timeout
# exception when timeout expired. (integer value)
# Deprecated group/name - [DEFAULT]/rpc_poll_timeout
# from .default.oslo.messaging.rpc_poll_timeout
{{ if not .default.oslo.messaging.rpc_poll_timeout }}#{{ end }}rpc_poll_timeout = {{ .default.oslo.messaging.rpc_poll_timeout | default "1" }}

# Expiration timeout in seconds of a name service record about existing target (
# < 0 means no timeout). (integer value)
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
{{ if not .default.oslo.messaging.control_exchange }}#{{ end }}control_exchange = {{ .default.oslo.messaging.control_exchange | default "openstack" }}


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
{{ if not .cors.oslo.middleware.cors.expose_headers }}#{{ end }}expose_headers = {{ .cors.oslo.middleware.cors.expose_headers | default "X-Image-Meta-Checksum,X-Auth-Token,X-Subject-Token,X-Service-Token,X-OpenStack-Request-ID" }}

# Maximum cache age of CORS preflight requests. (integer value)
# from .cors.oslo.middleware.cors.max_age
{{ if not .cors.oslo.middleware.cors.max_age }}#{{ end }}max_age = {{ .cors.oslo.middleware.cors.max_age | default "3600" }}

# Indicate which methods can be used during the actual request. (list value)
# from .cors.oslo.middleware.cors.allow_methods
{{ if not .cors.oslo.middleware.cors.allow_methods }}#{{ end }}allow_methods = {{ .cors.oslo.middleware.cors.allow_methods | default "GET,PUT,POST,DELETE,PATCH" }}

# Indicate which header field names may be used during the actual request. (list
# value)
# from .cors.oslo.middleware.cors.allow_headers
{{ if not .cors.oslo.middleware.cors.allow_headers }}#{{ end }}allow_headers = {{ .cors.oslo.middleware.cors.allow_headers | default "Content-MD5,X-Image-Meta-Checksum,X-Storage-Token,Accept-Encoding,X-Auth-Token,X-Identity-Status,X-Roles,X-Service-Catalog,X-User-Id,X-Tenant-Id,X-OpenStack-Request-ID" }}


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
{{ if not .cors.subdomain.oslo.middleware.cors.expose_headers }}#{{ end }}expose_headers = {{ .cors.subdomain.oslo.middleware.cors.expose_headers | default "X-Image-Meta-Checksum,X-Auth-Token,X-Subject-Token,X-Service-Token,X-OpenStack-Request-ID" }}

# Maximum cache age of CORS preflight requests. (integer value)
# from .cors.subdomain.oslo.middleware.cors.max_age
{{ if not .cors.subdomain.oslo.middleware.cors.max_age }}#{{ end }}max_age = {{ .cors.subdomain.oslo.middleware.cors.max_age | default "3600" }}

# Indicate which methods can be used during the actual request. (list value)
# from .cors.subdomain.oslo.middleware.cors.allow_methods
{{ if not .cors.subdomain.oslo.middleware.cors.allow_methods }}#{{ end }}allow_methods = {{ .cors.subdomain.oslo.middleware.cors.allow_methods | default "GET,PUT,POST,DELETE,PATCH" }}

# Indicate which header field names may be used during the actual request. (list
# value)
# from .cors.subdomain.oslo.middleware.cors.allow_headers
{{ if not .cors.subdomain.oslo.middleware.cors.allow_headers }}#{{ end }}allow_headers = {{ .cors.subdomain.oslo.middleware.cors.allow_headers | default "Content-MD5,X-Image-Meta-Checksum,X-Storage-Token,Accept-Encoding,X-Auth-Token,X-Identity-Status,X-Roles,X-Service-Catalog,X-User-Id,X-Tenant-Id,X-OpenStack-Request-ID" }}


[database]

#
# From oslo.db
#

# DEPRECATED: The file name to use with SQLite. (string value)
# Deprecated group/name - [DEFAULT]/sqlite_db
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# Reason: Should use config option connection or slave_connection to connect the
# database.
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
# default, overrides any server-set SQL mode. To use whatever SQL mode is set by
# the server configuration, set this to no value. Example: mysql_sql_mode=
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

# Maximum number of SQL connections to keep open in a pool. Setting a value of 0
# indicates no limit. (integer value)
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

# Enable the experimental use of database reconnect on connection lost. (boolean
# value)
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

#
# From oslo.db.concurrency
#

# Enable the experimental use of thread pooling for all DB API calls (boolean
# value)
# Deprecated group/name - [DEFAULT]/dbapi_use_tpool
# from .database.oslo.db.concurrency.use_tpool
{{ if not .database.oslo.db.concurrency.use_tpool }}#{{ end }}use_tpool = {{ .database.oslo.db.concurrency.use_tpool | default "false" }}


[glance_store]

#
# From glance.store
#

#
# List of enabled Glance stores.
#
# Register the storage backends to use for storing disk images
# as a comma separated list. The default stores enabled for
# storing disk images with Glance are ``file`` and ``http``.
#
# Possible values:
#     * A comma separated list that could include:
#         * file
#         * http
#         * swift
#         * rbd
#         * sheepdog
#         * cinder
#         * vmware
#
# Related Options:
#     * default_store
#
#  (list value)
# from .glance_store.glance.store.stores
{{ if not .glance_store.glance.store.stores }}#{{ end }}stores = {{ .glance_store.glance.store.stores | default "file,http" }}

#
# The default scheme to use for storing images.
#
# Provide a string value representing the default scheme to use for
# storing images. If not set, Glance uses ``file`` as the default
# scheme to store images with the ``file`` store.
#
# NOTE: The value given for this configuration option must be a valid
# scheme for a store registered with the ``stores`` configuration
# option.
#
# Possible values:
#     * file
#     * filesystem
#     * http
#     * https
#     * swift
#     * swift+http
#     * swift+https
#     * swift+config
#     * rbd
#     * sheepdog
#     * cinder
#     * vsphere
#
# Related Options:
#     * stores
#
#  (string value)
# Allowed values: file, filesystem, http, https, swift, swift+http, swift+https, swift+config, rbd, sheepdog, cinder, vsphere
# from .glance_store.glance.store.default_store
{{ if not .glance_store.glance.store.default_store }}#{{ end }}default_store = {{ .glance_store.glance.store.default_store | default "file" }}

#
# Minimum interval in seconds to execute updating dynamic storage
# capabilities based on current backend status.
#
# Provide an integer value representing time in seconds to set the
# minimum interval before an update of dynamic storage capabilities
# for a storage backend can be attempted. Setting
# ``store_capabilities_update_min_interval`` does not mean updates
# occur periodically based on the set interval. Rather, the update
# is performed at the elapse of this interval set, if an operation
# of the store is triggered.
#
# By default, this option is set to zero and is disabled. Provide an
# integer value greater than zero to enable this option.
#
# NOTE: For more information on store capabilities and their updates,
# please visit: https://specs.openstack.org/openstack/glance-specs/specs/kilo
# /store-capabilities.html
#
# For more information on setting up a particular store in your
# deplyment and help with the usage of this feature, please contact
# the storage driver maintainers listed here:
# http://docs.openstack.org/developer/glance_store/drivers/index.html
#
# Possible values:
#     * Zero
#     * Positive integer
#
# Related Options:
#     * None
#
#  (integer value)
# Minimum value: 0
# from .glance_store.glance.store.store_capabilities_update_min_interval
{{ if not .glance_store.glance.store.store_capabilities_update_min_interval }}#{{ end }}store_capabilities_update_min_interval = {{ .glance_store.glance.store.store_capabilities_update_min_interval | default "0" }}

#
# Chunk size for images to be stored in Sheepdog data store.
#
# Provide an integer value representing the size in mebibyte
# (1048576 bytes) to chunk Glance images into. The default
# chunk size is 64 mebibytes.
#
# When using Sheepdog distributed storage system, the images are
# chunked into objects of this size and then stored across the
# distributed data store to use for Glance.
#
# Chunk sizes, if a power of two, help avoid fragmentation and
# enable improved performance.
#
# Possible values:
#     * Positive integer value representing size in mebibytes.
#
# Related Options:
#     * None
#
#  (integer value)
# Minimum value: 1
# from .glance_store.glance.store.sheepdog_store_chunk_size
{{ if not .glance_store.glance.store.sheepdog_store_chunk_size }}#{{ end }}sheepdog_store_chunk_size = {{ .glance_store.glance.store.sheepdog_store_chunk_size | default "64" }}

#
# Port number on which the sheep daemon will listen.
#
# Provide an integer value representing a valid port number on
# which you want the Sheepdog daemon to listen on. The default
# port is 7000.
#
# The Sheepdog daemon, also called 'sheep', manages the storage
# in the distributed cluster by writing objects across the storage
# network. It identifies and acts on the messages it receives on
# the port number set using ``sheepdog_store_port`` option to store
# chunks of Glance images.
#
# Possible values:
#     * A valid port number (0 to 65535)
#
# Related Options:
#     * sheepdog_store_address
#
#  (port value)
# Minimum value: 0
# Maximum value: 65535
# from .glance_store.glance.store.sheepdog_store_port
{{ if not .glance_store.glance.store.sheepdog_store_port }}#{{ end }}sheepdog_store_port = {{ .glance_store.glance.store.sheepdog_store_port | default "7000" }}

#
# Address to bind the Sheepdog daemon to.
#
# Provide a string value representing the address to bind the
# Sheepdog daemon to. The default address set for the 'sheep'
# is 127.0.0.1.
#
# The Sheepdog daemon, also called 'sheep', manages the storage
# in the distributed cluster by writing objects across the storage
# network. It identifies and acts on the messages directed to the
# address set using ``sheepdog_store_address`` option to store
# chunks of Glance images.
#
# Possible values:
#     * A valid IPv4 address
#     * A valid IPv6 address
#     * A valid hostname
#
# Related Options:
#     * sheepdog_store_port
#
#  (string value)
# from .glance_store.glance.store.sheepdog_store_address
{{ if not .glance_store.glance.store.sheepdog_store_address }}#{{ end }}sheepdog_store_address = {{ .glance_store.glance.store.sheepdog_store_address | default "127.0.0.1" }}

#
# Set verification of the server certificate.
#
# This boolean determines whether or not to verify the server
# certificate. If this option is set to True, swiftclient won't check
# for a valid SSL certificate when authenticating. If the option is set
# to False, then the default CA truststore is used for verification.
#
# Possible values:
#     * True
#     * False
#
# Related options:
#     * swift_store_cacert
#
#  (boolean value)
# from .glance_store.glance.store.swift_store_auth_insecure
{{ if not .glance_store.glance.store.swift_store_auth_insecure }}#{{ end }}swift_store_auth_insecure = {{ .glance_store.glance.store.swift_store_auth_insecure | default "false" }}

#
# Path to the CA bundle file.
#
# This configuration option enables the operator to specify the path to
# a custom Certificate Authority file for SSL verification when
# connecting to Swift.
#
# Possible values:
#     * A valid path to a CA file
#
# Related options:
#     * swift_store_auth_insecure
#
#  (string value)
# from .glance_store.glance.store.swift_store_cacert
{{ if not .glance_store.glance.store.swift_store_cacert }}#{{ end }}swift_store_cacert = {{ .glance_store.glance.store.swift_store_cacert | default "/etc/ssl/certs/ca-certificates.crt" }}

#
# The region of Swift endpoint to use by Glance.
#
# Provide a string value representing a Swift region where Glance
# can connect to for image storage. By default, there is no region
# set.
#
# When Glance uses Swift as the storage backend to store images
# for a specific tenant that has multiple endpoints, setting of a
# Swift region with ``swift_store_region`` allows Glance to connect
# to Swift in the specified region as opposed to a single region
# connectivity.
#
# This option can be configured for both single-tenant and
# multi-tenant storage.
#
# NOTE: Setting the region with ``swift_store_region`` is
# tenant-specific and is necessary ``only if`` the tenant has
# multiple endpoints across different regions.
#
# Possible values:
#     * A string value representing a valid Swift region.
#
# Related Options:
#     * None
#
#  (string value)
# from .glance_store.glance.store.swift_store_region
{{ if not .glance_store.glance.store.swift_store_region }}#{{ end }}swift_store_region = {{ .glance_store.glance.store.swift_store_region | default "RegionTwo" }}

#
# The URL endpoint to use for Swift backend storage.
#
# Provide a string value representing the URL endpoint to use for
# storing Glance images in Swift store. By default, an endpoint
# is not set and the storage URL returned by ``auth`` is used.
# Setting an endpoint with ``swift_store_endpoint`` overrides the
# storage URL and is used for Glance image storage.
#
# NOTE: The URL should include the path up to, but excluding the
# container. The location of an object is obtained by appending
# the container and object to the configured URL.
#
# Possible values:
#     * String value representing a valid URL path up to a Swift container
#
# Related Options:
#     * None
#
#  (string value)
# from .glance_store.glance.store.swift_store_endpoint
{{ if not .glance_store.glance.store.swift_store_endpoint }}#{{ end }}swift_store_endpoint = {{ .glance_store.glance.store.swift_store_endpoint | default "https://swift.openstack.example.org/v1/path_not_including_container_name" }}

#
# Endpoint Type of Swift service.
#
# This string value indicates the endpoint type to use to fetch the
# Swift endpoint. The endpoint type determines the actions the user will
# be allowed to perform, for instance, reading and writing to the Store.
# This setting is only used if swift_store_auth_version is greater than
# 1.
#
# Possible values:
#     * publicURL
#     * adminURL
#     * internalURL
#
# Related options:
#     * swift_store_endpoint
#
#  (string value)
# Allowed values: publicURL, adminURL, internalURL
# from .glance_store.glance.store.swift_store_endpoint_type
{{ if not .glance_store.glance.store.swift_store_endpoint_type }}#{{ end }}swift_store_endpoint_type = {{ .glance_store.glance.store.swift_store_endpoint_type | default "publicURL" }}

#
# Type of Swift service to use.
#
# Provide a string value representing the service type to use for
# storing images while using Swift backend storage. The default
# service type is set to ``object-store``.
#
# NOTE: If ``swift_store_auth_version`` is set to 2, the value for
# this configuration option needs to be ``object-store``. If using
# a higher version of Keystone or a different auth scheme, this
# option may be modified.
#
# Possible values:
#     * A string representing a valid service type for Swift storage.
#
# Related Options:
#     * None
#
#  (string value)
# from .glance_store.glance.store.swift_store_service_type
{{ if not .glance_store.glance.store.swift_store_service_type }}#{{ end }}swift_store_service_type = {{ .glance_store.glance.store.swift_store_service_type | default "object-store" }}

#
# Name of single container to store images/name prefix for multiple containers
#
# When a single container is being used to store images, this configuration
# option indicates the container within the Glance account to be used for
# storing all images. When multiple containers are used to store images, this
# will be the name prefix for all containers. Usage of single/multiple
# containers can be controlled using the configuration option
# ``swift_store_multiple_containers_seed``.
#
# When using multiple containers, the containers will be named after the value
# set for this configuration option with the first N chars of the image UUID
# as the suffix delimited by an underscore (where N is specified by
# ``swift_store_multiple_containers_seed``).
#
# Example: if the seed is set to 3 and swift_store_container = ``glance``, then
# an image with UUID ``fdae39a1-bac5-4238-aba4-69bcc726e848`` would be placed in
# the container ``glance_fda``. All dashes in the UUID are included when
# creating the container name but do not count toward the character limit, so
# when N=10 the container name would be ``glance_fdae39a1-ba.``
#
# Possible values:
#     * If using single container, this configuration option can be any string
#       that is a valid swift container name in Glance's Swift account
#     * If using multiple containers, this configuration option can be any
#       string as long as it satisfies the container naming rules enforced by
#       Swift. The value of ``swift_store_multiple_containers_seed`` should be
#       taken into account as well.
#
# Related options:
#     * ``swift_store_multiple_containers_seed``
#     * ``swift_store_multi_tenant``
#     * ``swift_store_create_container_on_put``
#
#  (string value)
# from .glance_store.glance.store.swift_store_container
{{ if not .glance_store.glance.store.swift_store_container }}#{{ end }}swift_store_container = {{ .glance_store.glance.store.swift_store_container | default "glance" }}

#
# The size threshold, in MB, after which Glance will start segmenting image
# data.
#
# Swift has an upper limit on the size of a single uploaded object. By default,
# this is 5GB. To upload objects bigger than this limit, objects are segmented
# into multiple smaller objects that are tied together with a manifest file.
# For more detail, refer to
# http://docs.openstack.org/developer/swift/overview_large_objects.html
#
# This configuration option specifies the size threshold over which the Swift
# driver will start segmenting image data into multiple smaller files.
# Currently, the Swift driver only supports creating Dynamic Large Objects.
#
# NOTE: This should be set by taking into account the large object limit
# enforced by the Swift cluster in consideration.
#
# Possible values:
#     * A positive integer that is less than or equal to the large object limit
#       enforced by the Swift cluster in consideration.
#
# Related options:
#     * ``swift_store_large_object_chunk_size``
#
#  (integer value)
# Minimum value: 1
# from .glance_store.glance.store.swift_store_large_object_size
{{ if not .glance_store.glance.store.swift_store_large_object_size }}#{{ end }}swift_store_large_object_size = {{ .glance_store.glance.store.swift_store_large_object_size | default "5120" }}

#
# The maximum size, in MB, of the segments when image data is segmented.
#
# When image data is segmented to upload images that are larger than the limit
# enforced by the Swift cluster, image data is broken into segments that are no
# bigger than the size specified by this configuration option.
# Refer to ``swift_store_large_object_size`` for more detail.
#
# For example: if ``swift_store_large_object_size`` is 5GB and
# ``swift_store_large_object_chunk_size`` is 1GB, an image of size 6.2GB will be
# segmented into 7 segments where the first six segments will be 1GB in size and
# the seventh segment will be 0.2GB.
#
# Possible values:
#     * A positive integer that is less than or equal to the large object limit
#       enforced by Swift cluster in consideration.
#
# Related options:
#     * ``swift_store_large_object_size``
#
#  (integer value)
# Minimum value: 1
# from .glance_store.glance.store.swift_store_large_object_chunk_size
{{ if not .glance_store.glance.store.swift_store_large_object_chunk_size }}#{{ end }}swift_store_large_object_chunk_size = {{ .glance_store.glance.store.swift_store_large_object_chunk_size | default "200" }}

#
# Create container, if it doesn't already exist, when uploading image.
#
# At the time of uploading an image, if the corresponding container doesn't
# exist, it will be created provided this configuration option is set to True.
# By default, it won't be created. This behavior is applicable for both single
# and multiple containers mode.
#
# Possible values:
#     * True
#     * False
#
# Related options:
#     * None
#
#  (boolean value)
# from .glance_store.glance.store.swift_store_create_container_on_put
{{ if not .glance_store.glance.store.swift_store_create_container_on_put }}#{{ end }}swift_store_create_container_on_put = {{ .glance_store.glance.store.swift_store_create_container_on_put | default "false" }}

#
# Store images in tenant's Swift account.
#
# This enables multi-tenant storage mode which causes Glance images to be stored
# in tenant specific Swift accounts. If this is disabled, Glance stores all
# images in its own account. More details multi-tenant store can be found at
# https://wiki.openstack.org/wiki/GlanceSwiftTenantSpecificStorage
#
# Possible values:
#     * True
#     * False
#
# Related options:
#     * None
#
#  (boolean value)
# from .glance_store.glance.store.swift_store_multi_tenant
{{ if not .glance_store.glance.store.swift_store_multi_tenant }}#{{ end }}swift_store_multi_tenant = {{ .glance_store.glance.store.swift_store_multi_tenant | default "false" }}

#
# Seed indicating the number of containers to use for storing images.
#
# When using a single-tenant store, images can be stored in one or more than one
# containers. When set to 0, all images will be stored in one single container.
# When set to an integer value between 1 and 32, multiple containers will be
# used to store images. This configuration option will determine how many
# containers are created. The total number of containers that will be used is
# equal to 16^N, so if this config option is set to 2, then 16^2=256 containers
# will be used to store images.
#
# Please refer to ``swift_store_container`` for more detail on the naming
# convention. More detail about using multiple containers can be found at
# https://specs.openstack.org/openstack/glance-specs/specs/kilo/swift-store-
# multiple-containers.html
#
# NOTE: This is used only when swift_store_multi_tenant is disabled.
#
# Possible values:
#     * A non-negative integer less than or equal to 32
#
# Related options:
#     * ``swift_store_container``
#     * ``swift_store_multi_tenant``
#     * ``swift_store_create_container_on_put``
#
#  (integer value)
# Minimum value: 0
# Maximum value: 32
# from .glance_store.glance.store.swift_store_multiple_containers_seed
{{ if not .glance_store.glance.store.swift_store_multiple_containers_seed }}#{{ end }}swift_store_multiple_containers_seed = {{ .glance_store.glance.store.swift_store_multiple_containers_seed | default "0" }}

#
# List of tenants that will be granted admin access.
#
# This is a list of tenants that will be granted read/write access on
# all Swift containers created by Glance in multi-tenant mode. The
# default value is an empty list.
#
# Possible values:
#     * A comma separated list of strings representing UUIDs of Keystone
#       projects/tenants
#
# Related options:
#     * None
#
#  (list value)
# from .glance_store.glance.store.swift_store_admin_tenants
{{ if not .glance_store.glance.store.swift_store_admin_tenants }}#{{ end }}swift_store_admin_tenants = {{ .glance_store.glance.store.swift_store_admin_tenants | default "" }}

#
# SSL layer compression for HTTPS Swift requests.
#
# Provide a boolean value to determine whether or not to compress
# HTTPS Swift requests for images at the SSL layer. By default,
# compression is enabled.
#
# When using Swift as the backend store for Glance image storage,
# SSL layer compression of HTTPS Swift requests can be set using
# this option. If set to False, SSL layer compression of HTTPS
# Swift requests is disabled. Disabling this option may improve
# performance for images which are already in a compressed format,
# for example, qcow2.
#
# Possible values:
#     * True
#     * False
#
# Related Options:
#     * None
#
#  (boolean value)
# from .glance_store.glance.store.swift_store_ssl_compression
{{ if not .glance_store.glance.store.swift_store_ssl_compression }}#{{ end }}swift_store_ssl_compression = {{ .glance_store.glance.store.swift_store_ssl_compression | default "true" }}

#
# The number of times a Swift download will be retried before the
# request fails.
#
# Provide an integer value representing the number of times an image
# download must be retried before erroring out. The default value is
# zero (no retry on a failed image download). When set to a positive
# integer value, ``swift_store_retry_get_count`` ensures that the
# download is attempted this many more times upon a download failure
# before sending an error message.
#
# Possible values:
#     * Zero
#     * Positive integer value
#
# Related Options:
#     * None
#
#  (integer value)
# Minimum value: 0
# from .glance_store.glance.store.swift_store_retry_get_count
{{ if not .glance_store.glance.store.swift_store_retry_get_count }}#{{ end }}swift_store_retry_get_count = {{ .glance_store.glance.store.swift_store_retry_get_count | default "0" }}

#
# Time in seconds defining the size of the window in which a new
# token may be requested before the current token is due to expire.
#
# Typically, the Swift storage driver fetches a new token upon the
# expiration of the current token to ensure continued access to
# Swift. However, some Swift transactions (like uploading image
# segments) may not recover well if the token expires on the fly.
#
# Hence, by fetching a new token before the current token expiration,
# we make sure that the token does not expire or is close to expiry
# before a transaction is attempted. By default, the Swift storage
# driver requests for a new token 60 seconds or less before the
# current token expiration.
#
# Possible values:
#     * Zero
#     * Positive integer value
#
# Related Options:
#     * None
#
#  (integer value)
# Minimum value: 0
# from .glance_store.glance.store.swift_store_expire_soon_interval
{{ if not .glance_store.glance.store.swift_store_expire_soon_interval }}#{{ end }}swift_store_expire_soon_interval = {{ .glance_store.glance.store.swift_store_expire_soon_interval | default "60" }}

#
# Use trusts for multi-tenant Swift store.
#
# This option instructs the Swift store to create a trust for each
# add/get request when the multi-tenant store is in use. Using trusts
# allows the Swift store to avoid problems that can be caused by an
# authentication token expiring during the upload or download of data.
#
# By default, ``swift_store_use_trusts`` is set to ``True``(use of
# trusts is enabled). If set to ``False``, a user token is used for
# the Swift connection instead, eliminating the overhead of trust
# creation.
#
# NOTE: This option is considered only when
# ``swift_store_multi_tenant`` is set to ``True``
#
# Possible values:
#     * True
#     * False
#
# Related options:
#     * swift_store_multi_tenant
#
#  (boolean value)
# from .glance_store.glance.store.swift_store_use_trusts
{{ if not .glance_store.glance.store.swift_store_use_trusts }}#{{ end }}swift_store_use_trusts = {{ .glance_store.glance.store.swift_store_use_trusts | default "true" }}

#
# Reference to default Swift account/backing store parameters.
#
# Provide a string value representing a reference to the default set
# of parameters required for using swift account/backing store for
# image storage. The default reference value for this configuration
# option is 'ref1'. This configuration option dereferences the
# parameters and facilitates image storage in Swift storage backend
# every time a new image is added.
#
# Possible values:
#     * A valid string value
#
# Related options:
#     * None
#
#  (string value)
# from .glance_store.glance.store.default_swift_reference
{{ if not .glance_store.glance.store.default_swift_reference }}#{{ end }}default_swift_reference = {{ .glance_store.glance.store.default_swift_reference | default "ref1" }}

# DEPRECATED: Version of the authentication service to use. Valid versions are 2
# and 3 for keystone and 1 (deprecated) for swauth and rackspace. (string value)
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# Reason:
# The option 'auth_version' in the Swift back-end configuration file is
# used instead.
# from .glance_store.glance.store.swift_store_auth_version
{{ if not .glance_store.glance.store.swift_store_auth_version }}#{{ end }}swift_store_auth_version = {{ .glance_store.glance.store.swift_store_auth_version | default "2" }}

# DEPRECATED: The address where the Swift authentication service is listening.
# (string value)
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# Reason:
# The option 'auth_address' in the Swift back-end configuration file is
# used instead.
# from .glance_store.glance.store.swift_store_auth_address
{{ if not .glance_store.glance.store.swift_store_auth_address }}#{{ end }}swift_store_auth_address = {{ .glance_store.glance.store.swift_store_auth_address | default "<None>" }}

# DEPRECATED: The user to authenticate against the Swift authentication service.
# (string value)
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# Reason:
# The option 'user' in the Swift back-end configuration file is set instead.
# from .glance_store.glance.store.swift_store_user
{{ if not .glance_store.glance.store.swift_store_user }}#{{ end }}swift_store_user = {{ .glance_store.glance.store.swift_store_user | default "<None>" }}

# DEPRECATED: Auth key for the user authenticating against the Swift
# authentication service. (string value)
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# Reason:
# The option 'key' in the Swift back-end configuration file is used
# to set the authentication key instead.
# from .glance_store.glance.store.swift_store_key
{{ if not .glance_store.glance.store.swift_store_key }}#{{ end }}swift_store_key = {{ .glance_store.glance.store.swift_store_key | default "<None>" }}

#
# Absolute path to the file containing the swift account(s)
# configurations.
#
# Include a string value representing the path to a configuration
# file that has references for each of the configured Swift
# account(s)/backing stores. By default, no file path is specified
# and customized Swift referencing is disabled. Configuring this
# option is highly recommended while using Swift storage backend for
# image storage as it avoids storage of credentials in the database.
#
# Possible values:
#     * String value representing an absolute path on the glance-api
#       node
#
# Related options:
#     * None
#
#  (string value)
# from .glance_store.glance.store.swift_store_config_file
{{ if not .glance_store.glance.store.swift_store_config_file }}#{{ end }}swift_store_config_file = {{ .glance_store.glance.store.swift_store_config_file | default "<None>" }}

#
# Directory to which the filesystem backend store writes images.
#
# Upon start up, Glance creates the directory if it doesn't already
# exist and verifies write access to the user under which
# ``glance-api`` runs. If the write access isn't available, a
# ``BadStoreConfiguration`` exception is raised and the filesystem
# store may not be available for adding new images.
#
# NOTE: This directory is used only when filesystem store is used as a
# storage backend. Either ``filesystem_store_datadir`` or
# ``filesystem_store_datadirs`` option must be specified in
# ``glance-api.conf``. If both options are specified, a
# ``BadStoreConfiguration`` will be raised and the filesystem store
# may not be available for adding new images.
#
# Possible values:
#     * A valid path to a directory
#
# Related options:
#     * ``filesystem_store_datadirs``
#     * ``filesystem_store_file_perm``
#
#  (string value)
# from .glance_store.glance.store.filesystem_store_datadir
{{ if not .glance_store.glance.store.filesystem_store_datadir }}#{{ end }}filesystem_store_datadir = {{ .glance_store.glance.store.filesystem_store_datadir | default "/var/lib/glance/images" }}

#
# List of directories and their priorities to which the filesystem
# backend store writes images.
#
# The filesystem store can be configured to store images in multiple
# directories as opposed to using a single directory specified by the
# ``filesystem_store_datadir`` configuration option. When using
# multiple directories, each directory can be given an optional
# priority to specify the preference order in which they should
# be used. Priority is an integer that is concatenated to the
# directory path with a colon where a higher value indicates higher
# priority. When two directories have the same priority, the directory
# with most free space is used. When no priority is specified, it
# defaults to zero.
#
# More information on configuring filesystem store with multiple store
# directories can be found at
# http://docs.openstack.org/developer/glance/configuring.html
#
# NOTE: This directory is used only when filesystem store is used as a
# storage backend. Either ``filesystem_store_datadir`` or
# ``filesystem_store_datadirs`` option must be specified in
# ``glance-api.conf``. If both options are specified, a
# ``BadStoreConfiguration`` will be raised and the filesystem store
# may not be available for adding new images.
#
# Possible values:
#     * List of strings of the following form:
#         * ``<a valid directory path>:<optional integer priority>``
#
# Related options:
#     * ``filesystem_store_datadir``
#     * ``filesystem_store_file_perm``
#
#  (multi valued)
# from .glance_store.glance.store.filesystem_store_datadirs (multiopt)
{{ if not .glance_store.glance.store.filesystem_store_datadirs }}#filesystem_store_datadirs = {{ .glance_store.glance.store.filesystem_store_datadirs | default "" }}{{ else }}{{ range .glance_store.glance.store.filesystem_store_datadirs }}filesystem_store_datadirs = {{ . }}
{{ end }}{{ end }}

#
# Filesystem store metadata file.
#
# The path to a file which contains the metadata to be returned with
# any location associated with the filesystem store. The file must
# contain a valid JSON object. The object should contain the keys
# ``id`` and ``mountpoint``. The value for both keys should be a
# string.
#
# Possible values:
#     * A valid path to the store metadata file
#
# Related options:
#     * None
#
#  (string value)
# from .glance_store.glance.store.filesystem_store_metadata_file
{{ if not .glance_store.glance.store.filesystem_store_metadata_file }}#{{ end }}filesystem_store_metadata_file = {{ .glance_store.glance.store.filesystem_store_metadata_file | default "<None>" }}

#
# File access permissions for the image files.
#
# Set the intended file access permissions for image data. This provides
# a way to enable other services, e.g. Nova, to consume images directly
# from the filesystem store. The users running the services that are
# intended to be given access to could be made a member of the group
# that owns the files created. Assigning a value less then or equal to
# zero for this configuration option signifies that no changes be made
# to the  default permissions. This value will be decoded as an octal
# digit.
#
# For more information, please refer the documentation at
# http://docs.openstack.org/developer/glance/configuring.html
#
# Possible values:
#     * A valid file access permission
#     * Zero
#     * Any negative integer
#
# Related options:
#     * None
#
#  (integer value)
# from .glance_store.glance.store.filesystem_store_file_perm
{{ if not .glance_store.glance.store.filesystem_store_file_perm }}#{{ end }}filesystem_store_file_perm = {{ .glance_store.glance.store.filesystem_store_file_perm | default "0" }}

#
# Size, in megabytes, to chunk RADOS images into.
#
# Provide an integer value representing the size in megabytes to chunk
# Glance images into. The default chunk size is 8 megabytes. For optimal
# performance, the value should be a power of two.
#
# When Ceph's RBD object storage system is used as the storage backend
# for storing Glance images, the images are chunked into objects of the
# size set using this option. These chunked objects are then stored
# across the distributed block data store to use for Glance.
#
# Possible Values:
#     * Any positive integer value
#
# Related options:
#     * None
#
#  (integer value)
# Minimum value: 1
# from .glance_store.glance.store.rbd_store_chunk_size
{{ if not .glance_store.glance.store.rbd_store_chunk_size }}#{{ end }}rbd_store_chunk_size = {{ .glance_store.glance.store.rbd_store_chunk_size | default "8" }}

#
# RADOS pool in which images are stored.
#
# When RBD is used as the storage backend for storing Glance images, the
# images are stored by means of logical grouping of the objects (chunks
# of images) into a ``pool``. Each pool is defined with the number of
# placement groups it can contain. The default pool that is used is
# 'images'.
#
# More information on the RBD storage backend can be found here:
# http://ceph.com/planet/how-data-is-stored-in-ceph-cluster/
#
# Possible Values:
#     * A valid pool name
#
# Related options:
#     * None
#
#  (string value)
# from .glance_store.glance.store.rbd_store_pool
{{ if not .glance_store.glance.store.rbd_store_pool }}#{{ end }}rbd_store_pool = {{ .glance_store.glance.store.rbd_store_pool | default "images" }}

#
# RADOS user to authenticate as.
#
# This configuration option takes in the RADOS user to authenticate as.
# This is only needed when RADOS authentication is enabled and is
# applicable only if the user is using Cephx authentication. If the
# value for this option is not set by the user or is set to None, a
# default value will be chosen, which will be based on the client.
# section in rbd_store_ceph_conf.
#
# Possible Values:
#     * A valid RADOS user
#
# Related options:
#     * rbd_store_ceph_conf
#
#  (string value)
# from .glance_store.glance.store.rbd_store_user
{{ if not .glance_store.glance.store.rbd_store_user }}#{{ end }}rbd_store_user = {{ .glance_store.glance.store.rbd_store_user | default "<None>" }}

#
# Ceph configuration file path.
#
# This configuration option takes in the path to the Ceph configuration
# file to be used. If the value for this option is not set by the user
# or is set to None, librados will locate the default configuration file
# which is located at /etc/ceph/ceph.conf. If using Cephx
# authentication, this file should include a reference to the right
# keyring in a client.<USER> section
#
# Possible Values:
#     * A valid path to a configuration file
#
# Related options:
#     * rbd_store_user
#
#  (string value)
# from .glance_store.glance.store.rbd_store_ceph_conf
{{ if not .glance_store.glance.store.rbd_store_ceph_conf }}#{{ end }}rbd_store_ceph_conf = {{ .glance_store.glance.store.rbd_store_ceph_conf | default "/etc/ceph/ceph.conf" }}

#
# Timeout value for connecting to Ceph cluster.
#
# This configuration option takes in the timeout value in seconds used
# when connecting to the Ceph cluster i.e. it sets the time to wait for
# glance-api before closing the connection. This prevents glance-api
# hangups during the connection to RBD. If the value for this option
# is set to less than or equal to 0, no timeout is set and the default
# librados value is used.
#
# Possible Values:
#     * Any integer value
#
# Related options:
#     * None
#
#  (integer value)
# from .glance_store.glance.store.rados_connect_timeout
{{ if not .glance_store.glance.store.rados_connect_timeout }}#{{ end }}rados_connect_timeout = {{ .glance_store.glance.store.rados_connect_timeout | default "0" }}

#
# Path to the CA bundle file.
#
# This configuration option enables the operator to use a custom
# Certificate Authority file to verify the remote server certificate. If
# this option is set, the ``https_insecure`` option will be ignored and
# the CA file specified will be used to authenticate the server
# certificate and establish a secure connection to the server.
#
# Possible values:
#     * A valid path to a CA file
#
# Related options:
#     * https_insecure
#
#  (string value)
# from .glance_store.glance.store.https_ca_certificates_file
{{ if not .glance_store.glance.store.https_ca_certificates_file }}#{{ end }}https_ca_certificates_file = {{ .glance_store.glance.store.https_ca_certificates_file | default "<None>" }}

#
# Set verification of the remote server certificate.
#
# This configuration option takes in a boolean value to determine
# whether or not to verify the remote server certificate. If set to
# True, the remote server certificate is not verified. If the option is
# set to False, then the default CA truststore is used for verification.
#
# This option is ignored if ``https_ca_certificates_file`` is set.
# The remote server certificate will then be verified using the file
# specified using the ``https_ca_certificates_file`` option.
#
# Possible values:
#     * True
#     * False
#
# Related options:
#     * https_ca_certificates_file
#
#  (boolean value)
# from .glance_store.glance.store.https_insecure
{{ if not .glance_store.glance.store.https_insecure }}#{{ end }}https_insecure = {{ .glance_store.glance.store.https_insecure | default "true" }}

#
# The http/https proxy information to be used to connect to the remote
# server.
#
# This configuration option specifies the http/https proxy information
# that should be used to connect to the remote server. The proxy
# information should be a key value pair of the scheme and proxy, for
# example, http:10.0.0.1:3128. You can also specify proxies for multiple
# schemes by separating the key value pairs with a comma, for example,
# http:10.0.0.1:3128, https:10.0.0.1:1080.
#
# Possible values:
#     * A comma separated list of scheme:proxy pairs as described above
#
# Related options:
#     * None
#
#  (dict value)
# from .glance_store.glance.store.http_proxy_information
{{ if not .glance_store.glance.store.http_proxy_information }}#{{ end }}http_proxy_information = {{ .glance_store.glance.store.http_proxy_information | default "" }}

#
# Information to match when looking for cinder in the service catalog.
#
# When the ``cinder_endpoint_template`` is not set and any of
# ``cinder_store_auth_address``, ``cinder_store_user_name``,
# ``cinder_store_project_name``, ``cinder_store_password`` is not set,
# cinder store uses this information to lookup cinder endpoint from the service
# catalog in the current context. ``cinder_os_region_name``, if set, is taken
# into consideration to fetch the appropriate endpoint.
#
# The service catalog can be listed by the ``openstack catalog list`` command.
#
# Possible values:
#     * A string of of the following form:
#       ``<service_type>:<service_name>:<endpoint_type>``
#       At least ``service_type`` and ``endpoint_type`` should be specified.
#       ``service_name`` can be omitted.
#
# Related options:
#     * cinder_os_region_name
#     * cinder_endpoint_template
#     * cinder_store_auth_address
#     * cinder_store_user_name
#     * cinder_store_project_name
#     * cinder_store_password
#
#  (string value)
# from .glance_store.glance.store.cinder_catalog_info
{{ if not .glance_store.glance.store.cinder_catalog_info }}#{{ end }}cinder_catalog_info = {{ .glance_store.glance.store.cinder_catalog_info | default "volumev2::publicURL" }}

#
# Override service catalog lookup with template for cinder endpoint.
#
# When this option is set, this value is used to generate cinder endpoint,
# instead of looking up from the service catalog.
# This value is ignored if ``cinder_store_auth_address``,
# ``cinder_store_user_name``, ``cinder_store_project_name``, and
# ``cinder_store_password`` are specified.
#
# If this configuration option is set, ``cinder_catalog_info`` will be ignored.
#
# Possible values:
#     * URL template string for cinder endpoint, where ``%%(tenant)s`` is
#       replaced with the current tenant (project) name.
#       For example: ``http://cinder.openstack.example.org/v2/%%(tenant)s``
#
# Related options:
#     * cinder_store_auth_address
#     * cinder_store_user_name
#     * cinder_store_project_name
#     * cinder_store_password
#     * cinder_catalog_info
#
#  (string value)
# from .glance_store.glance.store.cinder_endpoint_template
{{ if not .glance_store.glance.store.cinder_endpoint_template }}#{{ end }}cinder_endpoint_template = {{ .glance_store.glance.store.cinder_endpoint_template | default "<None>" }}

#
# Region name to lookup cinder service from the service catalog.
#
# This is used only when ``cinder_catalog_info`` is used for determining the
# endpoint. If set, the lookup for cinder endpoint by this node is filtered to
# the specified region. It is useful when multiple regions are listed in the
# catalog. If this is not set, the endpoint is looked up from every region.
#
# Possible values:
#     * A string that is a valid region name.
#
# Related options:
#     * cinder_catalog_info
#
#  (string value)
# Deprecated group/name - [glance_store]/os_region_name
# from .glance_store.glance.store.cinder_os_region_name
{{ if not .glance_store.glance.store.cinder_os_region_name }}#{{ end }}cinder_os_region_name = {{ .glance_store.glance.store.cinder_os_region_name | default "<None>" }}

#
# Location of a CA certificates file used for cinder client requests.
#
# The specified CA certificates file, if set, is used to verify cinder
# connections via HTTPS endpoint. If the endpoint is HTTP, this value is
# ignored.
# ``cinder_api_insecure`` must be set to ``True`` to enable the verification.
#
# Possible values:
#     * Path to a ca certificates file
#
# Related options:
#     * cinder_api_insecure
#
#  (string value)
# from .glance_store.glance.store.cinder_ca_certificates_file
{{ if not .glance_store.glance.store.cinder_ca_certificates_file }}#{{ end }}cinder_ca_certificates_file = {{ .glance_store.glance.store.cinder_ca_certificates_file | default "<None>" }}

#
# Number of cinderclient retries on failed http calls.
#
# When a call failed by any errors, cinderclient will retry the call up to the
# specified times after sleeping a few seconds.
#
# Possible values:
#     * A positive integer
#
# Related options:
#     * None
#
#  (integer value)
# Minimum value: 0
# from .glance_store.glance.store.cinder_http_retries
{{ if not .glance_store.glance.store.cinder_http_retries }}#{{ end }}cinder_http_retries = {{ .glance_store.glance.store.cinder_http_retries | default "3" }}

#
# Time period, in seconds, to wait for a cinder volume transition to
# complete.
#
# When the cinder volume is created, deleted, or attached to the glance node to
# read/write the volume data, the volume's state is changed. For example, the
# newly created volume status changes from ``creating`` to ``available`` after
# the creation process is completed. This specifies the maximum time to wait for
# the status change. If a timeout occurs while waiting, or the status is changed
# to an unexpected value (e.g. `error``), the image creation fails.
#
# Possible values:
#     * A positive integer
#
# Related options:
#     * None
#
#  (integer value)
# Minimum value: 0
# from .glance_store.glance.store.cinder_state_transition_timeout
{{ if not .glance_store.glance.store.cinder_state_transition_timeout }}#{{ end }}cinder_state_transition_timeout = {{ .glance_store.glance.store.cinder_state_transition_timeout | default "300" }}

#
# Allow to perform insecure SSL requests to cinder.
#
# If this option is set to True, HTTPS endpoint connection is verified using the
# CA certificates file specified by ``cinder_ca_certificates_file`` option.
#
# Possible values:
#     * True
#     * False
#
# Related options:
#     * cinder_ca_certificates_file
#
#  (boolean value)
# from .glance_store.glance.store.cinder_api_insecure
{{ if not .glance_store.glance.store.cinder_api_insecure }}#{{ end }}cinder_api_insecure = {{ .glance_store.glance.store.cinder_api_insecure | default "false" }}

#
# The address where the cinder authentication service is listening.
#
# When all of ``cinder_store_auth_address``, ``cinder_store_user_name``,
# ``cinder_store_project_name``, and ``cinder_store_password`` options are
# specified, the specified values are always used for the authentication.
# This is useful to hide the image volumes from users by storing them in a
# project/tenant specific to the image service. It also enables users to share
# the image volume among other projects under the control of glance's ACL.
#
# If either of these options are not set, the cinder endpoint is looked up
# from the service catalog, and current context's user and project are used.
#
# Possible values:
#     * A valid authentication service address, for example:
#       ``http://openstack.example.org/identity/v2.0``
#
# Related options:
#     * cinder_store_user_name
#     * cinder_store_password
#     * cinder_store_project_name
#
#  (string value)
# from .glance_store.glance.store.cinder_store_auth_address
{{ if not .glance_store.glance.store.cinder_store_auth_address }}#{{ end }}cinder_store_auth_address = {{ .glance_store.glance.store.cinder_store_auth_address | default "<None>" }}

#
# User name to authenticate against cinder.
#
# This must be used with all the following related options. If any of these are
# not specified, the user of the current context is used.
#
# Possible values:
#     * A valid user name
#
# Related options:
#     * cinder_store_auth_address
#     * cinder_store_password
#     * cinder_store_project_name
#
#  (string value)
# from .glance_store.glance.store.cinder_store_user_name
{{ if not .glance_store.glance.store.cinder_store_user_name }}#{{ end }}cinder_store_user_name = {{ .glance_store.glance.store.cinder_store_user_name | default "<None>" }}

#
# Password for the user authenticating against cinder.
#
# This must be used with all the following related options. If any of these are
# not specified, the user of the current context is used.
#
# Possible values:
#     * A valid password for the user specified by ``cinder_store_user_name``
#
# Related options:
#     * cinder_store_auth_address
#     * cinder_store_user_name
#     * cinder_store_project_name
#
#  (string value)
# from .glance_store.glance.store.cinder_store_password
{{ if not .glance_store.glance.store.cinder_store_password }}#{{ end }}cinder_store_password = {{ .glance_store.glance.store.cinder_store_password | default "<None>" }}

#
# Project name where the image volume is stored in cinder.
#
# If this configuration option is not set, the project in current context is
# used.
#
# This must be used with all the following related options. If any of these are
# not specified, the project of the current context is used.
#
# Possible values:
#     * A valid project name
#
# Related options:
#     * ``cinder_store_auth_address``
#     * ``cinder_store_user_name``
#     * ``cinder_store_password``
#
#  (string value)
# from .glance_store.glance.store.cinder_store_project_name
{{ if not .glance_store.glance.store.cinder_store_project_name }}#{{ end }}cinder_store_project_name = {{ .glance_store.glance.store.cinder_store_project_name | default "<None>" }}

#
# Path to the rootwrap configuration file to use for running commands as root.
#
# The cinder store requires root privileges to operate the image volumes (for
# connecting to iSCSI/FC volumes and reading/writing the volume data, etc.).
# The configuration file should allow the required commands by cinder store and
# os-brick library.
#
# Possible values:
#     * Path to the rootwrap config file
#
# Related options:
#     * None
#
#  (string value)
# from .glance_store.glance.store.rootwrap_config
{{ if not .glance_store.glance.store.rootwrap_config }}#{{ end }}rootwrap_config = {{ .glance_store.glance.store.rootwrap_config | default "/etc/glance/rootwrap.conf" }}

#
# Address of the ESX/ESXi or vCenter Server target system.
#
# This configuration option sets the address of the ESX/ESXi or vCenter
# Server target system. This option is required when using the VMware
# storage backend. The address can contain an IP address (127.0.0.1) or
# a DNS name (www.my-domain.com).
#
# Possible Values:
#     * A valid IPv4 or IPv6 address
#     * A valid DNS name
#
# Related options:
#     * vmware_server_username
#     * vmware_server_password
#
#  (string value)
# from .glance_store.glance.store.vmware_server_host
{{ if not .glance_store.glance.store.vmware_server_host }}#{{ end }}vmware_server_host = {{ .glance_store.glance.store.vmware_server_host | default "127.0.0.1" }}

#
# Server username.
#
# This configuration option takes the username for authenticating with
# the VMware ESX/ESXi or vCenter Server. This option is required when
# using the VMware storage backend.
#
# Possible Values:
#     * Any string that is the username for a user with appropriate
#       privileges
#
# Related options:
#     * vmware_server_host
#     * vmware_server_password
#
#  (string value)
# from .glance_store.glance.store.vmware_server_username
{{ if not .glance_store.glance.store.vmware_server_username }}#{{ end }}vmware_server_username = {{ .glance_store.glance.store.vmware_server_username | default "root" }}

#
# Server password.
#
# This configuration option takes the password for authenticating with
# the VMware ESX/ESXi or vCenter Server. This option is required when
# using the VMware storage backend.
#
# Possible Values:
#     * Any string that is a password corresponding to the username
#       specified using the "vmware_server_username" option
#
# Related options:
#     * vmware_server_host
#     * vmware_server_username
#
#  (string value)
# from .glance_store.glance.store.vmware_server_password
{{ if not .glance_store.glance.store.vmware_server_password }}#{{ end }}vmware_server_password = {{ .glance_store.glance.store.vmware_server_password | default "vmware" }}

#
# The number of VMware API retries.
#
# This configuration option specifies the number of times the VMware
# ESX/VC server API must be retried upon connection related issues or
# server API call overload. It is not possible to specify 'retry
# forever'.
#
# Possible Values:
#     * Any positive integer value
#
# Related options:
#     * None
#
#  (integer value)
# Minimum value: 1
# from .glance_store.glance.store.vmware_api_retry_count
{{ if not .glance_store.glance.store.vmware_api_retry_count }}#{{ end }}vmware_api_retry_count = {{ .glance_store.glance.store.vmware_api_retry_count | default "10" }}

#
# Interval in seconds used for polling remote tasks invoked on VMware
# ESX/VC server.
#
# This configuration option takes in the sleep time in seconds for polling an
# on-going async task as part of the VMWare ESX/VC server API call.
#
# Possible Values:
#     * Any positive integer value
#
# Related options:
#     * None
#
#  (integer value)
# Minimum value: 1
# from .glance_store.glance.store.vmware_task_poll_interval
{{ if not .glance_store.glance.store.vmware_task_poll_interval }}#{{ end }}vmware_task_poll_interval = {{ .glance_store.glance.store.vmware_task_poll_interval | default "5" }}

#
# The directory where the glance images will be stored in the datastore.
#
# This configuration option specifies the path to the directory where the
# glance images will be stored in the VMware datastore. If this option
# is not set,  the default directory where the glance images are stored
# is openstack_glance.
#
# Possible Values:
#     * Any string that is a valid path to a directory
#
# Related options:
#     * None
#
#  (string value)
# from .glance_store.glance.store.vmware_store_image_dir
{{ if not .glance_store.glance.store.vmware_store_image_dir }}#{{ end }}vmware_store_image_dir = {{ .glance_store.glance.store.vmware_store_image_dir | default "/openstack_glance" }}

#
# Set verification of the ESX/vCenter server certificate.
#
# This configuration option takes a boolean value to determine
# whether or not to verify the ESX/vCenter server certificate. If this
# option is set to True, the ESX/vCenter server certificate is not
# verified. If this option is set to False, then the default CA
# truststore is used for verification.
#
# This option is ignored if the "vmware_ca_file" option is set. In that
# case, the ESX/vCenter server certificate will then be verified using
# the file specified using the "vmware_ca_file" option .
#
# Possible Values:
#     * True
#     * False
#
# Related options:
#     * vmware_ca_file
#
#  (boolean value)
# Deprecated group/name - [glance_store]/vmware_api_insecure
# from .glance_store.glance.store.vmware_insecure
{{ if not .glance_store.glance.store.vmware_insecure }}#{{ end }}vmware_insecure = {{ .glance_store.glance.store.vmware_insecure | default "false" }}

#
# Absolute path to the CA bundle file.
#
# This configuration option enables the operator to use a custom
# Cerificate Authority File to verify the ESX/vCenter certificate.
#
# If this option is set, the "vmware_insecure" option will be ignored
# and the CA file specified will be used to authenticate the ESX/vCenter
# server certificate and establish a secure connection to the server.
#
# Possible Values:
#     * Any string that is a valid absolute path to a CA file
#
# Related options:
#     * vmware_insecure
#
#  (string value)
# from .glance_store.glance.store.vmware_ca_file
{{ if not .glance_store.glance.store.vmware_ca_file }}#{{ end }}vmware_ca_file = {{ .glance_store.glance.store.vmware_ca_file | default "/etc/ssl/certs/ca-certificates.crt" }}

#
# The datastores where the image can be stored.
#
# This configuration option specifies the datastores where the image can
# be stored in the VMWare store backend. This option may be specified
# multiple times for specifying multiple datastores. The datastore name
# should be specified after its datacenter path, separated by ":". An
# optional weight may be given after the datastore name, separated again
# by ":" to specify the priority. Thus, the required format becomes
# <datacenter_path>:<datastore_name>:<optional_weight>.
#
# When adding an image, the datastore with highest weight will be
# selected, unless there is not enough free space available in cases
# where the image size is already known. If no weight is given, it is
# assumed to be zero and the directory will be considered for selection
# last. If multiple datastores have the same weight, then the one with
# the most free space available is selected.
#
# Possible Values:
#     * Any string of the format:
#       <datacenter_path>:<datastore_name>:<optional_weight>
#
# Related options:
#    * None
#
#  (multi valued)
# from .glance_store.glance.store.vmware_datastores (multiopt)
{{ if not .glance_store.glance.store.vmware_datastores }}#vmware_datastores = {{ .glance_store.glance.store.vmware_datastores | default "" }}{{ else }}{{ range .glance_store.glance.store.vmware_datastores }}vmware_datastores = {{ . }}
{{ end }}{{ end }}


[image_format]

#
# From glance.api
#

# Supported values for the 'container_format' image attribute (list value)
# Deprecated group/name - [DEFAULT]/container_formats
# from .image_format.glance.api.container_formats
{{ if not .image_format.glance.api.container_formats }}#{{ end }}container_formats = {{ .image_format.glance.api.container_formats | default "ami,ari,aki,bare,ovf,ova,docker" }}

# Supported values for the 'disk_format' image attribute (list value)
# Deprecated group/name - [DEFAULT]/disk_formats
# from .image_format.glance.api.disk_formats
{{ if not .image_format.glance.api.disk_formats }}#{{ end }}disk_formats = {{ .image_format.glance.api.disk_formats | default "ami,ari,aki,vhd,vhdx,vmdk,raw,qcow2,vdi,iso" }}


[keystone_authtoken]

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

# FIXME(alanmeadows) - added for some newton images using older keystoneauth1 libs but are still "newton"
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.auth_url }}#{{ end }}auth_url = {{ .keystone_authtoken.keystonemiddleware.auth_token.auth_url | default "<None>" }}

#
# From keystonemiddleware.auth_token
#

# Complete "public" Identity API endpoint. This endpoint should not be an
# "admin" endpoint, as it should be accessible by all end users. Unauthenticated
# clients are redirected to this endpoint to authenticate. Although this
# endpoint should  ideally be unversioned, client support in the wild varies.
# If you're using a versioned v2 endpoint here, then this  should *not* be the
# same endpoint the service user utilizes  for validating tokens, because normal
# end users may not be  able to reach that endpoint. (string value)
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

# How many times are we trying to reconnect when communicating with Identity API
# Server. (integer value)
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
# caches previously-seen tokens for a configurable duration (in seconds). Set to
# -1 to disable caching completely. (integer value)
# from .keystone_authtoken.keystonemiddleware.auth_token.token_cache_time
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.token_cache_time }}#{{ end }}token_cache_time = {{ .keystone_authtoken.keystonemiddleware.auth_token.token_cache_time | default "300" }}

# Determines the frequency at which the list of revoked tokens is retrieved from
# the Identity service (in seconds). A high number of revocation events combined
# with a low cache duration may significantly reduce performance. Only valid for
# PKI tokens. (integer value)
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

# (Optional) Maximum total number of open connections to every memcached server.
# (integer value)
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
# information if the bind type is of a form known to the server and ignore it if
# not. "strict" like "permissive" but if the bind type is unknown the token will
# be rejected. "required" any form of token binding is needed to be allowed.
# Finally the name of a binding method that must be present in tokens. (string
# value)
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


[oslo_concurrency]

#
# From oslo.concurrency
#

# Enables or disables inter-process locks. (boolean value)
# Deprecated group/name - [DEFAULT]/disable_process_locking
# from .oslo_concurrency.oslo.concurrency.disable_process_locking
{{ if not .oslo_concurrency.oslo.concurrency.disable_process_locking }}#{{ end }}disable_process_locking = {{ .oslo_concurrency.oslo.concurrency.disable_process_locking | default "false" }}

# Directory to use for lock files.  For security, the specified directory should
# only be writable by the user running the processes that need locking. Defaults
# to environment variable OSLO_LOCK_PATH. If external locks are used, a lock
# path must be set. (string value)
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

# The deadline for an rpc reply message delivery. Only used when caller does not
# provide a timeout expiry. (integer value)
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
# the message bus to identify messages that should be delivered in a round-robin
# fashion across consumers. (string value)
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

# The Drivers(s) to handle sending notifications. Possible values are messaging,
# messagingv2, routing, log, test, noop (multi valued)
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
# currently connected to becomes unavailable. Takes effect only if more than one
# RabbitMQ node is provided in config. (string value)
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

# DEPRECATED: The RabbitMQ broker port where a single node is used. (port value)
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
# is no longer controlled by the x-ha-policy argument when declaring a queue. If
# you just want to make sure that all queues (except  those with auto-generated
# names) are mirrored across all nodes, run: "rabbitmqctl set_policy HA
# '^(?!amq\.).*' '{"ha-mode": "all"}' " (boolean value)
# Deprecated group/name - [DEFAULT]/rabbit_ha_queues
# from .oslo_messaging_rabbit.oslo.messaging.rabbit_ha_queues
{{ if not .oslo_messaging_rabbit.oslo.messaging.rabbit_ha_queues }}#{{ end }}rabbit_ha_queues = {{ .oslo_messaging_rabbit.oslo.messaging.rabbit_ha_queues | default "false" }}

# Positive integer representing duration in seconds for queue TTL (x-expires).
# Queues which are unused for the duration of the TTL are automatically deleted.
# The parameter affects only reply and fanout queues. (integer value)
# Minimum value: 1
# from .oslo_messaging_rabbit.oslo.messaging.rabbit_transient_queues_ttl
{{ if not .oslo_messaging_rabbit.oslo.messaging.rabbit_transient_queues_ttl }}#{{ end }}rabbit_transient_queues_ttl = {{ .oslo_messaging_rabbit.oslo.messaging.rabbit_transient_queues_ttl | default "1800" }}

# Specifies the number of messages to prefetch. Setting to zero allows unlimited
# messages. (integer value)
# from .oslo_messaging_rabbit.oslo.messaging.rabbit_qos_prefetch_count
{{ if not .oslo_messaging_rabbit.oslo.messaging.rabbit_qos_prefetch_count }}#{{ end }}rabbit_qos_prefetch_count = {{ .oslo_messaging_rabbit.oslo.messaging.rabbit_qos_prefetch_count | default "0" }}

# Number of seconds after which the Rabbit broker is considered down if
# heartbeat's keep-alive fails (0 disable the heartbeat). EXPERIMENTAL (integer
# value)
# from .oslo_messaging_rabbit.oslo.messaging.heartbeat_timeout_threshold
{{ if not .oslo_messaging_rabbit.oslo.messaging.heartbeat_timeout_threshold }}#{{ end }}heartbeat_timeout_threshold = {{ .oslo_messaging_rabbit.oslo.messaging.heartbeat_timeout_threshold | default "60" }}

# How often times during the heartbeat_timeout_threshold we check the heartbeat.
# (integer value)
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

# Set TCP_USER_TIMEOUT in seconds for connection's socket (floating point value)
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

# Maximum number of connections to create above `pool_max_size`. (integer value)
# from .oslo_messaging_rabbit.oslo.messaging.pool_max_overflow
{{ if not .oslo_messaging_rabbit.oslo.messaging.pool_max_overflow }}#{{ end }}pool_max_overflow = {{ .oslo_messaging_rabbit.oslo.messaging.pool_max_overflow | default "0" }}

# Default number of seconds to wait for a connections to available (integer
# value)
# from .oslo_messaging_rabbit.oslo.messaging.pool_timeout
{{ if not .oslo_messaging_rabbit.oslo.messaging.pool_timeout }}#{{ end }}pool_timeout = {{ .oslo_messaging_rabbit.oslo.messaging.pool_timeout | default "30" }}

# Lifetime of a connection (since creation) in seconds or None for no recycling.
# Expired connections are closed on acquire. (integer value)
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

# Max number of not acknowledged message which RabbitMQ can send to notification
# listener. (integer value)
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

# Reconnecting retry count in case of connectivity problem during sending reply.
# -1 means infinite retry during rpc_timeout (integer value)
# from .oslo_messaging_rabbit.oslo.messaging.rpc_reply_retry_attempts
{{ if not .oslo_messaging_rabbit.oslo.messaging.rpc_reply_retry_attempts }}#{{ end }}rpc_reply_retry_attempts = {{ .oslo_messaging_rabbit.oslo.messaging.rpc_reply_retry_attempts | default "-1" }}

# Reconnecting retry delay in case of connectivity problem during sending reply.
# (floating point value)
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

# Seconds to wait before a cast expires (TTL). The default value of -1 specifies
# an infinite linger period. The value of 0 specifies no linger period. Pending
# messages shall be discarded immediately when the socket is closed. Only
# supported by impl_zmq. (integer value)
# Deprecated group/name - [DEFAULT]/rpc_cast_timeout
# from .oslo_messaging_zmq.oslo.messaging.rpc_cast_timeout
{{ if not .oslo_messaging_zmq.oslo.messaging.rpc_cast_timeout }}#{{ end }}rpc_cast_timeout = {{ .oslo_messaging_zmq.oslo.messaging.rpc_cast_timeout | default "-1" }}

# The default number of seconds that poll should wait. Poll raises timeout
# exception when timeout expired. (integer value)
# Deprecated group/name - [DEFAULT]/rpc_poll_timeout
# from .oslo_messaging_zmq.oslo.messaging.rpc_poll_timeout
{{ if not .oslo_messaging_zmq.oslo.messaging.rpc_poll_timeout }}#{{ end }}rpc_poll_timeout = {{ .oslo_messaging_zmq.oslo.messaging.rpc_poll_timeout | default "1" }}

# Expiration timeout in seconds of a name service record about existing target (
# < 0 means no timeout). (integer value)
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


[paste_deploy]

#
# From glance.api
#

#
# Deployment flavor to use in the server application pipeline.
#
# Provide a string value representing the appropriate deployment
# flavor used in the server application pipleline. This is typically
# the partial name of a pipeline in the paste configuration file with
# the service name removed.
#
# For example, if your paste section name in the paste configuration
# file is [pipeline:glance-api-keystone], set ``flavor`` to
# ``keystone``.
#
# Possible values:
#     * String value representing a partial pipeline name.
#
# Related Options:
#     * config_file
#
#  (string value)
# from .paste_deploy.glance.api.flavor
{{ if not .paste_deploy.glance.api.flavor }}#{{ end }}flavor = {{ .paste_deploy.glance.api.flavor | default "keystone" }}

#
# Name of the paste configuration file.
#
# Provide a string value representing the name of the paste
# configuration file to use for configuring piplelines for
# server application deployments.
#
# NOTES:
#     * Provide the name or the path relative to the glance directory
#       for the paste configuration file and not the absolute path.
#     * The sample paste configuration file shipped with Glance need
#       not be edited in most cases as it comes with ready-made
#       pipelines for all common deployment flavors.
#
# If no value is specified for this option, the ``paste.ini`` file
# with the prefix of the corresponding Glance service's configuration
# file name will be searched for in the known configuration
# directories. (For example, if this option is missing from or has no
# value set in ``glance-api.conf``, the service will look for a file
# named ``glance-api-paste.ini``.) If the paste configuration file is
# not found, the service will not start.
#
# Possible values:
#     * A string value representing the name of the paste configuration
#       file.
#
# Related Options:
#     * flavor
#
#  (string value)
# from .paste_deploy.glance.api.config_file
{{ if not .paste_deploy.glance.api.config_file }}#{{ end }}config_file = {{ .paste_deploy.glance.api.config_file | default "glance-api-paste.ini" }}


[profiler]

#
# From glance.api
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
# from .profiler.glance.api.enabled
{{ if not .profiler.glance.api.enabled }}#{{ end }}enabled = {{ .profiler.glance.api.enabled | default "false" }}

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
# from .profiler.glance.api.trace_sqlalchemy
{{ if not .profiler.glance.api.trace_sqlalchemy }}#{{ end }}trace_sqlalchemy = {{ .profiler.glance.api.trace_sqlalchemy | default "false" }}

#
# Secret key(s) to use for encrypting context data for performance profiling.
# This string value should have the following format: <key1>[,<key2>,...<keyn>],
# where each key is some random string. A user who triggers the profiling via
# the REST API has to set one of these keys in the headers of the REST API call
# to include profiling results of this node for this particular project.
#
# Both "enabled" flag and "hmac_keys" config options should be set to enable
# profiling. Also, to generate correct profiling information across all services
# at least one key needs to be consistent between OpenStack projects. This
# ensures it can be used from client side to generate the trace, containing
# information from all possible resources. (string value)
# from .profiler.glance.api.hmac_keys
{{ if not .profiler.glance.api.hmac_keys }}#{{ end }}hmac_keys = {{ .profiler.glance.api.hmac_keys | default "SECRET_KEY" }}

#
# Connection string for a notifier backend. Default value is messaging:// which
# sets the notifier to oslo_messaging.
#
# Examples of possible values:
#
# * messaging://: use oslo_messaging driver for sending notifications.
#  (string value)
# from .profiler.glance.api.connection_string
{{ if not .profiler.glance.api.connection_string }}#{{ end }}connection_string = {{ .profiler.glance.api.connection_string | default "messaging://" }}


[store_type_location_strategy]

#
# From glance.api
#

#
# Preference order of storage backends.
#
# Provide a comma separated list of store names in the order in
# which images should be retrieved from storage backends.
# These store names must be registered with the ``stores``
# configuration option.
#
# NOTE: The ``store_type_preference`` configuration option is applied
# only if ``store_type`` is chosen as a value for the
# ``location_strategy`` configuration option. An empty list will not
# change the location order.
#
# Possible values:
#     * Empty list
#     * Comma separated list of registered store names. Legal values are:
#         * file
#         * http
#         * rbd
#         * swift
#         * sheepdog
#         * cinder
#         * vmware
#
# Related options:
#     * location_strategy
#     * stores
#
#  (list value)
# from .store_type_location_strategy.glance.api.store_type_preference
{{ if not .store_type_location_strategy.glance.api.store_type_preference }}#{{ end }}store_type_preference = {{ .store_type_location_strategy.glance.api.store_type_preference | default "" }}


[task]

#
# From glance.api
#

# Time in hours for which a task lives after, either succeeding or failing
# (integer value)
# Deprecated group/name - [DEFAULT]/task_time_to_live
# from .task.glance.api.task_time_to_live
{{ if not .task.glance.api.task_time_to_live }}#{{ end }}task_time_to_live = {{ .task.glance.api.task_time_to_live | default "48" }}

#
# Task executor to be used to run task scripts.
#
# Provide a string value representing the executor to use for task
# executions. By default, ``TaskFlow`` executor is used.
#
# ``TaskFlow`` helps make task executions easy, consistent, scalable
# and reliable. It also enables creation of lightweight task objects
# and/or functions that are combined together into flows in a
# declarative manner.
#
# Possible values:
#     * taskflow
#
# Related Options:
#     * None
#
#  (string value)
# from .task.glance.api.task_executor
{{ if not .task.glance.api.task_executor }}#{{ end }}task_executor = {{ .task.glance.api.task_executor | default "taskflow" }}

#
# Absolute path to the work directory to use for asynchronous
# task operations.
#
# The directory set here will be used to operate over images -
# normally before they are imported in the destination store.
#
# NOTE: When providing a value for ``work_dir``, please make sure
# that enough space is provided for concurrent tasks to run
# efficiently without running out of space.
#
# A rough estimation can be done by multiplying the number of
# ``max_workers`` with an average image size (e.g 500MB). The image
# size estimation should be done based on the average size in your
# deployment. Note that depending on the tasks running you may need
# to multiply this number by some factor depending on what the task
# does. For example, you may want to double the available size if
# image conversion is enabled. All this being said, remember these
# are just estimations and you should do them based on the worst
# case scenario and be prepared to act in case they were wrong.
#
# Possible values:
#     * String value representing the absolute path to the working
#       directory
#
# Related Options:
#     * None
#
#  (string value)
# from .task.glance.api.work_dir
{{ if not .task.glance.api.work_dir }}#{{ end }}work_dir = {{ .task.glance.api.work_dir | default "/work_dir" }}


[taskflow_executor]

#
# From glance.api
#

#
# Set the taskflow engine mode.
#
# Provide a string type value to set the mode in which the taskflow
# engine would schedule tasks to the workers on the hosts. Based on
# this mode, the engine executes tasks either in single or multiple
# threads. The possible values for this configuration option are:
# ``serial`` and ``parallel``. When set to ``serial``, the engine runs
# all the tasks in a single thread which results in serial execution
# of tasks. Setting this to ``parallel`` makes the engine run tasks in
# multiple threads. This results in parallel execution of tasks.
#
# Possible values:
#     * serial
#     * parallel
#
# Related options:
#     * max_workers
#
#  (string value)
# Allowed values: serial, parallel
# from .taskflow_executor.glance.api.engine_mode
{{ if not .taskflow_executor.glance.api.engine_mode }}#{{ end }}engine_mode = {{ .taskflow_executor.glance.api.engine_mode | default "parallel" }}

#
# Set the number of engine executable tasks.
#
# Provide an integer value to limit the number of workers that can be
# instantiated on the hosts. In other words, this number defines the
# number of parallel tasks that can be executed at the same time by
# the taskflow engine. This value can be greater than one when the
# engine mode is set to parallel.
#
# Possible values:
#     * Integer value greater than or equal to 1
#
# Related options:
#     * engine_mode
#
#  (integer value)
# Minimum value: 1
# Deprecated group/name - [task]/eventlet_executor_pool_size
# from .taskflow_executor.glance.api.max_workers
{{ if not .taskflow_executor.glance.api.max_workers }}#{{ end }}max_workers = {{ .taskflow_executor.glance.api.max_workers | default "10" }}

#
# Set the desired image conversion format.
#
# Provide a valid image format to which you want images to be
# converted before they are stored for consumption by Glance.
# Appropriate image format conversions are desirable for specific
# storage backends in order to facilitate efficient handling of
# bandwidth and usage of the storage infrastructure.
#
# By default, ``conversion_format`` is not set and must be set
# explicitly in the configuration file.
#
# The allowed values for this option are ``raw``, ``qcow2`` and
# ``vmdk``. The  ``raw`` format is the unstructured disk format and
# should be chosen when RBD or Ceph storage backends are used for
# image storage. ``qcow2`` is supported by the QEMU emulator that
# expands dynamically and supports Copy on Write. The ``vmdk`` is
# another common disk format supported by many common virtual machine
# monitors like VMWare Workstation.
#
# Possible values:
#     * qcow2
#     * raw
#     * vmdk
#
# Related options:
#     * disk_formats
#
#  (string value)
# Allowed values: qcow2, raw, vmdk
# from .taskflow_executor.glance.api.conversion_format
{{ if not .taskflow_executor.glance.api.conversion_format }}#{{ end }}conversion_format = {{ .taskflow_executor.glance.api.conversion_format | default "raw" }}

{{- end -}}
