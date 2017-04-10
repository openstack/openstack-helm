
# Copyright 2017 The Openstack-Helm Authors.
#
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

{{ include "nova.conf.nova_values_skeleton" .Values.conf.nova | trunc 0 }}
{{ include "nova.conf.nova" .Values.conf.nova }}

{{- define "nova.conf.nova_values_skeleton" -}}

{{- if not .default -}}{{- set . "default" dict -}}{{- end -}}
{{- if not .default.nova -}}{{- set .default "nova" dict -}}{{- end -}}
{{- if not .default.nova.conf -}}{{- set .default.nova "conf" dict -}}{{- end -}}
{{- if not .default.oslo -}}{{- set .default "oslo" dict -}}{{- end -}}
{{- if not .default.oslo.log -}}{{- set .default.oslo "log" dict -}}{{- end -}}
{{- if not .default.oslo.messaging -}}{{- set .default.oslo "messaging" dict -}}{{- end -}}
{{- if not .default.oslo.service -}}{{- set .default.oslo "service" dict -}}{{- end -}}
{{- if not .default.oslo.service.periodic_task -}}{{- set .default.oslo.service "periodic_task" dict -}}{{- end -}}
{{- if not .default.oslo.service.service -}}{{- set .default.oslo.service "service" dict -}}{{- end -}}
{{- if not .api_database -}}{{- set . "api_database" dict -}}{{- end -}}
{{- if not .api_database.nova -}}{{- set .api_database "nova" dict -}}{{- end -}}
{{- if not .api_database.nova.conf -}}{{- set .api_database.nova "conf" dict -}}{{- end -}}
{{- if not .barbican -}}{{- set . "barbican" dict -}}{{- end -}}
{{- if not .barbican.nova -}}{{- set .barbican "nova" dict -}}{{- end -}}
{{- if not .barbican.nova.conf -}}{{- set .barbican.nova "conf" dict -}}{{- end -}}
{{- if not .cache -}}{{- set . "cache" dict -}}{{- end -}}
{{- if not .cache.nova -}}{{- set .cache "nova" dict -}}{{- end -}}
{{- if not .cache.nova.conf -}}{{- set .cache.nova "conf" dict -}}{{- end -}}
{{- if not .cells -}}{{- set . "cells" dict -}}{{- end -}}
{{- if not .cells.nova -}}{{- set .cells "nova" dict -}}{{- end -}}
{{- if not .cells.nova.conf -}}{{- set .cells.nova "conf" dict -}}{{- end -}}
{{- if not .cinder -}}{{- set . "cinder" dict -}}{{- end -}}
{{- if not .cinder.nova -}}{{- set .cinder "nova" dict -}}{{- end -}}
{{- if not .cinder.nova.conf -}}{{- set .cinder.nova "conf" dict -}}{{- end -}}
{{- if not .cloudpipe -}}{{- set . "cloudpipe" dict -}}{{- end -}}
{{- if not .cloudpipe.nova -}}{{- set .cloudpipe "nova" dict -}}{{- end -}}
{{- if not .cloudpipe.nova.conf -}}{{- set .cloudpipe.nova "conf" dict -}}{{- end -}}
{{- if not .conductor -}}{{- set . "conductor" dict -}}{{- end -}}
{{- if not .conductor.nova -}}{{- set .conductor "nova" dict -}}{{- end -}}
{{- if not .conductor.nova.conf -}}{{- set .conductor.nova "conf" dict -}}{{- end -}}
{{- if not .cors -}}{{- set . "cors" dict -}}{{- end -}}
{{- if not .cors.oslo -}}{{- set .cors "oslo" dict -}}{{- end -}}
{{- if not .cors.oslo.middleware -}}{{- set .cors.oslo "middleware" dict -}}{{- end -}}
{{- if not .cors.subdomain -}}{{- set .cors "subdomain" dict -}}{{- end -}}
{{- if not .cors.subdomain.oslo -}}{{- set .cors.subdomain "oslo" dict -}}{{- end -}}
{{- if not .cors.subdomain.oslo.middleware -}}{{- set .cors.subdomain.oslo "middleware" dict -}}{{- end -}}
{{- if not .crypto -}}{{- set . "crypto" dict -}}{{- end -}}
{{- if not .crypto.nova -}}{{- set .crypto "nova" dict -}}{{- end -}}
{{- if not .crypto.nova.conf -}}{{- set .crypto.nova "conf" dict -}}{{- end -}}
{{- if not .database -}}{{- set . "database" dict -}}{{- end -}}
{{- if not .database.oslo -}}{{- set .database "oslo" dict -}}{{- end -}}
{{- if not .database.oslo.db -}}{{- set .database.oslo "db" dict -}}{{- end -}}
{{- if not .database.oslo.db.concurrency -}}{{- set .database.oslo.db "concurrency" dict -}}{{- end -}}
{{- if not .ephemeral_storage_encryption -}}{{- set . "ephemeral_storage_encryption" dict -}}{{- end -}}
{{- if not .ephemeral_storage_encryption.nova -}}{{- set .ephemeral_storage_encryption "nova" dict -}}{{- end -}}
{{- if not .ephemeral_storage_encryption.nova.conf -}}{{- set .ephemeral_storage_encryption.nova "conf" dict -}}{{- end -}}
{{- if not .glance -}}{{- set . "glance" dict -}}{{- end -}}
{{- if not .glance.nova -}}{{- set .glance "nova" dict -}}{{- end -}}
{{- if not .glance.nova.conf -}}{{- set .glance.nova "conf" dict -}}{{- end -}}
{{- if not .guestfs -}}{{- set . "guestfs" dict -}}{{- end -}}
{{- if not .guestfs.nova -}}{{- set .guestfs "nova" dict -}}{{- end -}}
{{- if not .guestfs.nova.conf -}}{{- set .guestfs.nova "conf" dict -}}{{- end -}}
{{- if not .hyperv -}}{{- set . "hyperv" dict -}}{{- end -}}
{{- if not .hyperv.nova -}}{{- set .hyperv "nova" dict -}}{{- end -}}
{{- if not .hyperv.nova.conf -}}{{- set .hyperv.nova "conf" dict -}}{{- end -}}
{{- if not .image_file_url -}}{{- set . "image_file_url" dict -}}{{- end -}}
{{- if not .image_file_url.nova -}}{{- set .image_file_url "nova" dict -}}{{- end -}}
{{- if not .image_file_url.nova.conf -}}{{- set .image_file_url.nova "conf" dict -}}{{- end -}}
{{- if not .ironic -}}{{- set . "ironic" dict -}}{{- end -}}
{{- if not .ironic.nova -}}{{- set .ironic "nova" dict -}}{{- end -}}
{{- if not .ironic.nova.conf -}}{{- set .ironic.nova "conf" dict -}}{{- end -}}
{{- if not .key_manager -}}{{- set . "key_manager" dict -}}{{- end -}}
{{- if not .key_manager.nova -}}{{- set .key_manager "nova" dict -}}{{- end -}}
{{- if not .key_manager.nova.conf -}}{{- set .key_manager.nova "conf" dict -}}{{- end -}}
{{- if not .keystone_authtoken -}}{{- set . "keystone_authtoken" dict -}}{{- end -}}
{{- if not .keystone_authtoken.keystonemiddleware -}}{{- set .keystone_authtoken "keystonemiddleware" dict -}}{{- end -}}
{{- if not .keystone_authtoken.keystonemiddleware.auth_token -}}{{- set .keystone_authtoken.keystonemiddleware "auth_token" dict -}}{{- end -}}
{{- if not .libvirt -}}{{- set . "libvirt" dict -}}{{- end -}}
{{- if not .libvirt.nova -}}{{- set .libvirt "nova" dict -}}{{- end -}}
{{- if not .libvirt.nova.conf -}}{{- set .libvirt.nova "conf" dict -}}{{- end -}}
{{- if not .matchmaker_redis -}}{{- set . "matchmaker_redis" dict -}}{{- end -}}
{{- if not .matchmaker_redis.oslo -}}{{- set .matchmaker_redis "oslo" dict -}}{{- end -}}
{{- if not .matchmaker_redis.oslo.messaging -}}{{- set .matchmaker_redis.oslo "messaging" dict -}}{{- end -}}
{{- if not .metrics -}}{{- set . "metrics" dict -}}{{- end -}}
{{- if not .metrics.nova -}}{{- set .metrics "nova" dict -}}{{- end -}}
{{- if not .metrics.nova.conf -}}{{- set .metrics.nova "conf" dict -}}{{- end -}}
{{- if not .mks -}}{{- set . "mks" dict -}}{{- end -}}
{{- if not .mks.nova -}}{{- set .mks "nova" dict -}}{{- end -}}
{{- if not .mks.nova.conf -}}{{- set .mks.nova "conf" dict -}}{{- end -}}
{{- if not .neutron -}}{{- set . "neutron" dict -}}{{- end -}}
{{- if not .neutron.nova -}}{{- set .neutron "nova" dict -}}{{- end -}}
{{- if not .neutron.nova.conf -}}{{- set .neutron.nova "conf" dict -}}{{- end -}}
{{- if not .osapi_v21 -}}{{- set . "osapi_v21" dict -}}{{- end -}}
{{- if not .osapi_v21.nova -}}{{- set .osapi_v21 "nova" dict -}}{{- end -}}
{{- if not .osapi_v21.nova.conf -}}{{- set .osapi_v21.nova "conf" dict -}}{{- end -}}
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
{{- if not .placement -}}{{- set . "placement" dict -}}{{- end -}}
{{- if not .placement.nova -}}{{- set .placement "nova" dict -}}{{- end -}}
{{- if not .placement.nova.conf -}}{{- set .placement.nova "conf" dict -}}{{- end -}}
{{- if not .placement_database -}}{{- set . "placement_database" dict -}}{{- end -}}
{{- if not .placement_database.nova -}}{{- set .placement_database "nova" dict -}}{{- end -}}
{{- if not .placement_database.nova.conf -}}{{- set .placement_database.nova "conf" dict -}}{{- end -}}
{{- if not .rdp -}}{{- set . "rdp" dict -}}{{- end -}}
{{- if not .rdp.nova -}}{{- set .rdp "nova" dict -}}{{- end -}}
{{- if not .rdp.nova.conf -}}{{- set .rdp.nova "conf" dict -}}{{- end -}}
{{- if not .remote_debug -}}{{- set . "remote_debug" dict -}}{{- end -}}
{{- if not .remote_debug.nova -}}{{- set .remote_debug "nova" dict -}}{{- end -}}
{{- if not .remote_debug.nova.conf -}}{{- set .remote_debug.nova "conf" dict -}}{{- end -}}
{{- if not .serial_console -}}{{- set . "serial_console" dict -}}{{- end -}}
{{- if not .serial_console.nova -}}{{- set .serial_console "nova" dict -}}{{- end -}}
{{- if not .serial_console.nova.conf -}}{{- set .serial_console.nova "conf" dict -}}{{- end -}}
{{- if not .spice -}}{{- set . "spice" dict -}}{{- end -}}
{{- if not .spice.nova -}}{{- set .spice "nova" dict -}}{{- end -}}
{{- if not .spice.nova.conf -}}{{- set .spice.nova "conf" dict -}}{{- end -}}
{{- if not .ssl -}}{{- set . "ssl" dict -}}{{- end -}}
{{- if not .ssl.nova -}}{{- set .ssl "nova" dict -}}{{- end -}}
{{- if not .ssl.nova.conf -}}{{- set .ssl.nova "conf" dict -}}{{- end -}}
{{- if not .trusted_computing -}}{{- set . "trusted_computing" dict -}}{{- end -}}
{{- if not .trusted_computing.nova -}}{{- set .trusted_computing "nova" dict -}}{{- end -}}
{{- if not .trusted_computing.nova.conf -}}{{- set .trusted_computing.nova "conf" dict -}}{{- end -}}
{{- if not .upgrade_levels -}}{{- set . "upgrade_levels" dict -}}{{- end -}}
{{- if not .upgrade_levels.nova -}}{{- set .upgrade_levels "nova" dict -}}{{- end -}}
{{- if not .upgrade_levels.nova.conf -}}{{- set .upgrade_levels.nova "conf" dict -}}{{- end -}}
{{- if not .vmware -}}{{- set . "vmware" dict -}}{{- end -}}
{{- if not .vmware.nova -}}{{- set .vmware "nova" dict -}}{{- end -}}
{{- if not .vmware.nova.conf -}}{{- set .vmware.nova "conf" dict -}}{{- end -}}
{{- if not .vnc -}}{{- set . "vnc" dict -}}{{- end -}}
{{- if not .vnc.nova -}}{{- set .vnc "nova" dict -}}{{- end -}}
{{- if not .vnc.nova.conf -}}{{- set .vnc.nova "conf" dict -}}{{- end -}}
{{- if not .workarounds -}}{{- set . "workarounds" dict -}}{{- end -}}
{{- if not .workarounds.nova -}}{{- set .workarounds "nova" dict -}}{{- end -}}
{{- if not .workarounds.nova.conf -}}{{- set .workarounds.nova "conf" dict -}}{{- end -}}
{{- if not .wsgi -}}{{- set . "wsgi" dict -}}{{- end -}}
{{- if not .wsgi.nova -}}{{- set .wsgi "nova" dict -}}{{- end -}}
{{- if not .wsgi.nova.conf -}}{{- set .wsgi.nova "conf" dict -}}{{- end -}}
{{- if not .xenserver -}}{{- set . "xenserver" dict -}}{{- end -}}
{{- if not .xenserver.nova -}}{{- set .xenserver "nova" dict -}}{{- end -}}
{{- if not .xenserver.nova.conf -}}{{- set .xenserver.nova "conf" dict -}}{{- end -}}
{{- if not .xvp -}}{{- set . "xvp" dict -}}{{- end -}}
{{- if not .xvp.nova -}}{{- set .xvp "nova" dict -}}{{- end -}}
{{- if not .xvp.nova.conf -}}{{- set .xvp.nova "conf" dict -}}{{- end -}}

{{- end -}}


{{- define "nova.conf.nova" -}}

[DEFAULT]

#
# This determines the strategy to use for authentication: keystone or noauth2.
# 'noauth2' is designed for testing only, as it does no actual credential
# checking. 'noauth2' provides administrative credentials only if 'admin' is
# specified as the username.
#  (string value)
# Allowed values: keystone, noauth2
# from .default.nova.conf.auth_strategy
{{ if not .default.nova.conf.auth_strategy }}#{{ end }}auth_strategy = {{ .default.nova.conf.auth_strategy | default "keystone" }}

#
# When True, the 'X-Forwarded-For' header is treated as the canonical remote
# address. When False (the default), the 'remote_address' header is used.
#
# You should only enable this if you have an HTML sanitizing proxy.
#  (boolean value)
# from .default.nova.conf.use_forwarded_for
{{ if not .default.nova.conf.use_forwarded_for }}#{{ end }}use_forwarded_for = {{ .default.nova.conf.use_forwarded_for | default "false" }}

#
# When gathering the existing metadata for a config drive, the EC2-style
# metadata is returned for all versions that don't appear in this option.
# As of the Liberty release, the available versions are:
#
# * 1.0
# * 2007-01-19
# * 2007-03-01
# * 2007-08-29
# * 2007-10-10
# * 2007-12-15
# * 2008-02-01
# * 2008-09-01
# * 2009-04-04
#
# The option is in the format of a single string, with each version separated
# by a space.
#
# Possible values:
#
# * Any string that represents zero or more versions, separated by spaces.
#  (string value)
# from .default.nova.conf.config_drive_skip_versions
{{ if not .default.nova.conf.config_drive_skip_versions }}#{{ end }}config_drive_skip_versions = {{ .default.nova.conf.config_drive_skip_versions | default "1.0 2007-01-19 2007-03-01 2007-08-29 2007-10-10 2007-12-15 2008-02-01 2008-09-01" }}

# DEPRECATED:
# When returning instance metadata, this is the class that is used
# for getting vendor metadata when that class isn't specified in the individual
# request. The value should be the full dot-separated path to the class to use.
#
# Possible values:
#
# * Any valid dot-separated class path that can be imported.
#  (string value)
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# from .default.nova.conf.vendordata_driver
{{ if not .default.nova.conf.vendordata_driver }}#{{ end }}vendordata_driver = {{ .default.nova.conf.vendordata_driver | default "nova.api.metadata.vendordata_json.JsonFileVendorData" }}

#
# A list of vendordata providers.
#
# vendordata providers are how deployers can provide metadata via configdrive
# and metadata that is specific to their deployment. There are currently two
# supported providers: StaticJSON and DynamicJSON.
#
# StaticJSON reads a JSON file configured by the flag vendordata_jsonfile_path
# and places the JSON from that file into vendor_data.json and
# vendor_data2.json.
#
# DynamicJSON is configured via the vendordata_dynamic_targets flag, which is
# documented separately. For each of the endpoints specified in that flag, a
# section is added to the vendor_data2.json.
#
# For more information on the requirements for implementing a vendordata
# dynamic endpoint, please see the vendordata.rst file in the nova developer
# reference.
#
# Possible values:
#
# * A list of vendordata providers, with StaticJSON and DynamicJSON being
#   current options.
#
# Related options:
#
# * vendordata_dynamic_targets
# * vendordata_dynamic_ssl_certfile
# * vendordata_dynamic_connect_timeout
# * vendordata_dynamic_read_timeout
#  (list value)
# from .default.nova.conf.vendordata_providers
{{ if not .default.nova.conf.vendordata_providers }}#{{ end }}vendordata_providers = {{ .default.nova.conf.vendordata_providers | default "" }}

#
# A list of targets for the dynamic vendordata provider. These targets are of
# the form <name>@<url>.
#
# The dynamic vendordata provider collects metadata by contacting external REST
# services and querying them for information about the instance. This behaviour
# is documented in the vendordata.rst file in the nova developer reference.
#  (list value)
# from .default.nova.conf.vendordata_dynamic_targets
{{ if not .default.nova.conf.vendordata_dynamic_targets }}#{{ end }}vendordata_dynamic_targets = {{ .default.nova.conf.vendordata_dynamic_targets | default "" }}

<<<<<<< HEAD
#
# Path to an optional certificate file or CA bundle to verify dynamic
# vendordata REST services ssl certificates against.
#
# Possible values:
#
# * An empty string, or a path to a valid certificate file
#
# Related options:
#
# * vendordata_providers
# * vendordata_dynamic_targets
# * vendordata_dynamic_connect_timeout
# * vendordata_dynamic_read_timeout
#  (string value)
# from .default.nova.conf.vendordata_dynamic_ssl_certfile
{{ if not .default.nova.conf.vendordata_dynamic_ssl_certfile }}#{{ end }}vendordata_dynamic_ssl_certfile = {{ .default.nova.conf.vendordata_dynamic_ssl_certfile | default "" }}

#
# Maximum wait time for an external REST service to connect.
#
# Possible values:
#
# * Any integer with a value greater than three (the TCP packet retransmission
#   timeout). Note that instance start may be blocked during this wait time,
#   so this value should be kept small.
#
# Related options:
#
# * vendordata_providers
# * vendordata_dynamic_targets
# * vendordata_dynamic_ssl_certfile
# * vendordata_dynamic_read_timeout
#  (integer value)
# Minimum value: 3
# from .default.nova.conf.vendordata_dynamic_connect_timeout
{{ if not .default.nova.conf.vendordata_dynamic_connect_timeout }}#{{ end }}vendordata_dynamic_connect_timeout = {{ .default.nova.conf.vendordata_dynamic_connect_timeout | default "5" }}

#
# Maximum wait time for an external REST service to return data once connected.
#
# Possible values:
#
# * Any integer. Note that instance start is blocked during this wait time,
#   so this value should be kept small.
#
# Related options:
#
# * vendordata_providers
# * vendordata_dynamic_targets
# * vendordata_dynamic_ssl_certfile
# * vendordata_dynamic_connect_timeout
#  (integer value)
# Minimum value: 0
# from .default.nova.conf.vendordata_dynamic_read_timeout
{{ if not .default.nova.conf.vendordata_dynamic_read_timeout }}#{{ end }}vendordata_dynamic_read_timeout = {{ .default.nova.conf.vendordata_dynamic_read_timeout | default "5" }}

#
# This option is the time (in seconds) to cache metadata. When set to 0,
# metadata caching is disabled entirely; this is generally not recommended for
# performance reasons. Increasing this setting should improve response times
# of the metadata API when under heavy load. Higher values may increase memory
# usage, and result in longer times for host metadata changes to take effect.
#  (integer value)
# Minimum value: 0
# from .default.nova.conf.metadata_cache_expiration
{{ if not .default.nova.conf.metadata_cache_expiration }}#{{ end }}metadata_cache_expiration = {{ .default.nova.conf.metadata_cache_expiration | default "15" }}

#
# Cloud providers may store custom data in vendor data file that will then be
# available to the instances via the metadata service, and to the rendering of
# config-drive. The default class for this, JsonFileVendorData, loads this
# information from a JSON file, whose path is configured by this option. If
# there is no path set by this option, the class returns an empty dictionary.
#
# Possible values:
#
# * Any string representing the path to the data file, or an empty string
#     (default).
#  (string value)
# from .default.nova.conf.vendordata_jsonfile_path
{{ if not .default.nova.conf.vendordata_jsonfile_path }}#{{ end }}vendordata_jsonfile_path = {{ .default.nova.conf.vendordata_jsonfile_path | default "<None>" }}

#
# As a query can potentially return many thousands of items, you can limit the
# maximum number of items in a single response by setting this option.
#  (integer value)
# Minimum value: 0
# from .default.nova.conf.osapi_max_limit
{{ if not .default.nova.conf.osapi_max_limit }}#{{ end }}osapi_max_limit = {{ .default.nova.conf.osapi_max_limit | default "1000" }}

#
# This string is prepended to the normal URL that is returned in links to the
# OpenStack Compute API. If it is empty (the default), the URLs are returned
# unchanged.
#
# Possible values:
#
# * Any string, including an empty string (the default).
#  (string value)
# from .default.nova.conf.osapi_compute_link_prefix
{{ if not .default.nova.conf.osapi_compute_link_prefix }}#{{ end }}osapi_compute_link_prefix = {{ .default.nova.conf.osapi_compute_link_prefix | default "<None>" }}

#
# This string is prepended to the normal URL that is returned in links to
# Glance resources. If it is empty (the default), the URLs are returned
# unchanged.
#
# Possible values:
#
# * Any string, including an empty string (the default).
#  (string value)
# from .default.nova.conf.osapi_glance_link_prefix
{{ if not .default.nova.conf.osapi_glance_link_prefix }}#{{ end }}osapi_glance_link_prefix = {{ .default.nova.conf.osapi_glance_link_prefix | default "<None>" }}

#
# Operators can turn off the ability for a user to take snapshots of their
# instances by setting this option to False. When disabled, any attempt to
# take a snapshot will result in a HTTP 400 response ("Bad Request").
#  (boolean value)
# from .default.nova.conf.allow_instance_snapshots
{{ if not .default.nova.conf.allow_instance_snapshots }}#{{ end }}allow_instance_snapshots = {{ .default.nova.conf.allow_instance_snapshots | default "true" }}

#
# This option is a list of all instance states for which network address
# information should not be returned from the API.
#
# Possible values:
#
#   A list of strings, where each string is a valid VM state, as defined in
#   nova/compute/vm_states.py. As of the Newton release, they are:
#
# * "active"
# * "building"
# * "paused"
# * "suspended"
# * "stopped"
# * "rescued"
# * "resized"
# * "soft-delete"
# * "deleted"
# * "error"
# * "shelved"
# * "shelved_offloaded"
#  (list value)
# from .default.nova.conf.osapi_hide_server_address_states
{{ if not .default.nova.conf.osapi_hide_server_address_states }}#{{ end }}osapi_hide_server_address_states = {{ .default.nova.conf.osapi_hide_server_address_states | default "building" }}

# The full path to the fping binary. (string value)
# from .default.nova.conf.fping_path
{{ if not .default.nova.conf.fping_path }}#{{ end }}fping_path = {{ .default.nova.conf.fping_path | default "/usr/sbin/fping" }}

# DEPRECATED:
# This option is used to enable or disable quota checking for tenant networks.
#
# Related options:
#
# * quota_networks
#  (boolean value)
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# Reason:
# CRUD operations on tenant networks are only available when using nova-network
# and nova-network is itself deprecated.
# from .default.nova.conf.enable_network_quota
{{ if not .default.nova.conf.enable_network_quota }}#{{ end }}enable_network_quota = {{ .default.nova.conf.enable_network_quota | default "false" }}

#
# When True, the TenantNetworkController will query the Neutron API to get the
# default networks to use.
#
# Related options:
#
# * neutron_default_tenant_id
#  (boolean value)
# from .default.nova.conf.use_neutron_default_nets
{{ if not .default.nova.conf.use_neutron_default_nets }}#{{ end }}use_neutron_default_nets = {{ .default.nova.conf.use_neutron_default_nets | default "false" }}

#
# Tenant ID for getting the default network from Neutron API (also referred in
# some places as the 'project ID') to use.
#
# Related options:
#
# * use_neutron_default_nets
#  (string value)
# from .default.nova.conf.neutron_default_tenant_id
{{ if not .default.nova.conf.neutron_default_tenant_id }}#{{ end }}neutron_default_tenant_id = {{ .default.nova.conf.neutron_default_tenant_id | default "default" }}

# DEPRECATED:
# This option controls the number of private networks that can be created per
# project (or per tenant).
#
# Related options:
#
# * enable_network_quota
#  (integer value)
# Minimum value: 0
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# Reason:
# CRUD operations on tenant networks are only available when using nova-network
# and nova-network is itself deprecated.
# from .default.nova.conf.quota_networks
{{ if not .default.nova.conf.quota_networks }}#{{ end }}quota_networks = {{ .default.nova.conf.quota_networks | default "3" }}

#
# Enables returning of the instance password by the relevant server API calls
# such as create, rebuild, evacuate, or rescue. If the hypervisor does not
# support password injection, then the password returned will not be correct,
# so if your hypervisor does not support password injection, set this to False.
#  (boolean value)
# from .default.nova.conf.enable_instance_password
{{ if not .default.nova.conf.enable_instance_password }}#{{ end }}enable_instance_password = {{ .default.nova.conf.enable_instance_password | default "true" }}

#
# This option specifies the name of the availability zone for the
# internal services. Services like nova-scheduler, nova-network,
# nova-conductor are internal services. These services will appear in
# their own internal availability_zone.
#
# Possible values:
#
#     * Any string representing an availability zone name
#     * 'internal' is the default value
#
#  (string value)
# from .default.nova.conf.internal_service_availability_zone
{{ if not .default.nova.conf.internal_service_availability_zone }}#{{ end }}internal_service_availability_zone = {{ .default.nova.conf.internal_service_availability_zone | default "internal" }}

#
# Default compute node availability_zone.
#
# This option determines the availability zone to be used when it is not
# specified in the VM creation request. If this option is not set,
# the default availability zone 'nova' is used.
#
# Possible values:
#
#     * Any string representing an availability zone name
#     * 'nova' is the default value
#
#  (string value)
# from .default.nova.conf.default_availability_zone
{{ if not .default.nova.conf.default_availability_zone }}#{{ end }}default_availability_zone = {{ .default.nova.conf.default_availability_zone | default "nova" }}

# Length of generated instance admin passwords. (integer value)
# Minimum value: 0
# from .default.nova.conf.password_length
{{ if not .default.nova.conf.password_length }}#{{ end }}password_length = {{ .default.nova.conf.password_length | default "12" }}

#
# Time period to generate instance usages for. It is possible to define optional
# offset to given period by appending @ character followed by a number defining
# offset.
#
# Possible values:
#   *  period, example: ``hour``, ``day``, ``month` or ``year``
#   *  period with offset, example: ``month@15``
#      will result in monthly audits starting on 15th day of month.
#  (string value)
# from .default.nova.conf.instance_usage_audit_period
{{ if not .default.nova.conf.instance_usage_audit_period }}#{{ end }}instance_usage_audit_period = {{ .default.nova.conf.instance_usage_audit_period | default "month" }}

#
# Start and use a daemon that can run the commands that need to be run with
# root privileges. This option is usually enabled on nodes that run nova compute
# processes.
#  (boolean value)
# from .default.nova.conf.use_rootwrap_daemon
{{ if not .default.nova.conf.use_rootwrap_daemon }}#{{ end }}use_rootwrap_daemon = {{ .default.nova.conf.use_rootwrap_daemon | default "false" }}

#
# Path to the rootwrap configuration file.
#
# Goal of the root wrapper is to allow a service-specific unprivileged user to
# run a number of actions as the root user in the safest manner possible.
# The configuration file used here must match the one defined in the sudoers
# entry.
#  (string value)
# from .default.nova.conf.rootwrap_config
{{ if not .default.nova.conf.rootwrap_config }}#{{ end }}rootwrap_config = {{ .default.nova.conf.rootwrap_config | default "/etc/nova/rootwrap.conf" }}

# Explicitly specify the temporary working directory. (string value)
# from .default.nova.conf.tempdir
{{ if not .default.nova.conf.tempdir }}#{{ end }}tempdir = {{ .default.nova.conf.tempdir | default "<None>" }}

#
# Determine if monkey patching should be applied.
#
# Related options:
#
#   * ``monkey_patch_modules``: This must have values set for this option to
# have
#   any effect
#  (boolean value)
# from .default.nova.conf.monkey_patch
{{ if not .default.nova.conf.monkey_patch }}#{{ end }}monkey_patch = {{ .default.nova.conf.monkey_patch | default "false" }}

#
# List of modules/decorators to monkey patch.
#
# This option allows you to patch a decorator for all functions in specified
# modules.
#
# Possible values:
#
#   * nova.compute.api:nova.notifications.notify_decorator
#   * nova.api.ec2.cloud:nova.notifications.notify_decorator
#   * [...]
#
# Related options:
#
#   * ``monkey_patch``: This must be set to ``True`` for this option to
#     have any effect
#  (list value)
# from .default.nova.conf.monkey_patch_modules
{{ if not .default.nova.conf.monkey_patch_modules }}#{{ end }}monkey_patch_modules = {{ .default.nova.conf.monkey_patch_modules | default "nova.compute.api:nova.notifications.notify_decorator" }}

# DEPRECATED:
# Determines the RPC topic that the cert nodes listen on. For most deployments
# there is no need to ever change it.
#  (string value)
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# Reason:
# Since the nova-cert service is marked for deprecation, the feature to change
# RPC topic that cert nodes listen may be removed as early as the 15.0.0
# Ocata release.
# from .default.nova.conf.cert_topic
{{ if not .default.nova.conf.cert_topic }}#{{ end }}cert_topic = {{ .default.nova.conf.cert_topic | default "cert" }}

#
# Allow destination machine to match source for resize. Useful when
# testing in single-host environments. By default it is not allowed
# to resize to the same host. Setting this option to true will add
# the same host to the destination options.
#  (boolean value)
# from .default.nova.conf.allow_resize_to_same_host
{{ if not .default.nova.conf.allow_resize_to_same_host }}#{{ end }}allow_resize_to_same_host = {{ .default.nova.conf.allow_resize_to_same_host | default "false" }}

#
# Availability zone to use when user doesn't specify one.
#
# This option is used by the scheduler to determine which availability
# zone to place a new VM instance into if the user did not specify one
# at the time of VM boot request.
#
# Possible values:
#
# * Any string representing an availability zone name
# * Default value is None.
#  (string value)
# from .default.nova.conf.default_schedule_zone
{{ if not .default.nova.conf.default_schedule_zone }}#{{ end }}default_schedule_zone = {{ .default.nova.conf.default_schedule_zone | default "<None>" }}

#
# Image properties that should not be inherited from the instance
# when taking a snapshot.
#
# This option gives an opportunity to select which image-properties
# should not be inherited by newly created snapshots.
#
# Possible values:
#
# * A list whose item is an image property. Usually only the image
#   properties that are only needed by base images can be included
#   here, since the snapshots that are created from the base images
#   doesn't need them.
# * Default list: ['cache_in_nova', 'bittorrent']
#  (list value)
# from .default.nova.conf.non_inheritable_image_properties
{{ if not .default.nova.conf.non_inheritable_image_properties }}#{{ end }}non_inheritable_image_properties = {{ .default.nova.conf.non_inheritable_image_properties | default "cache_in_nova,bittorrent" }}

#
# This option is used to decide when an image should have no external
# ramdisk or kernel. By default this is set to 'nokernel', so when an
# image is booted with the property 'kernel_id' with the value
# 'nokernel', Nova assumes the image doesn't require an external kernel
# and ramdisk.
#  (string value)
# from .default.nova.conf.null_kernel
{{ if not .default.nova.conf.null_kernel }}#{{ end }}null_kernel = {{ .default.nova.conf.null_kernel | default "nokernel" }}

#
# When creating multiple instances with a single request using the
# os-multiple-create API extension, this template will be used to build
# the display name for each instance. The benefit is that the instances
# end up with different hostnames. Example display names when creating
# two VM's: name-1, name-2.
#
# Possible values:
#
# * Valid keys for the template are: name, uuid, count.
#  (string value)
# from .default.nova.conf.multi_instance_display_name_template
{{ if not .default.nova.conf.multi_instance_display_name_template }}#{{ end }}multi_instance_display_name_template = {{ .default.nova.conf.multi_instance_display_name_template | default "%(name)s-%(count)d" }}

#
# Maximum number of devices that will result in a local image being
# created on the hypervisor node.
#
# A negative number means unlimited. Setting max_local_block_devices
# to 0 means that any request that attempts to create a local disk
# will fail. This option is meant to limit the number of local discs
# (so root local disc that is the result of --image being used, and
# any other ephemeral and swap disks). 0 does not mean that images
# will be automatically converted to volumes and boot instances from
# volumes - it just means that all requests that attempt to create a
# local disk will fail.
#
# Possible values:
#
# * 0: Creating a local disk is not allowed.
# * Negative number: Allows unlimited number of local discs.
# * Positive number: Allows only these many number of local discs.
#                        (Default value is 3).
#  (integer value)
# from .default.nova.conf.max_local_block_devices
{{ if not .default.nova.conf.max_local_block_devices }}#{{ end }}max_local_block_devices = {{ .default.nova.conf.max_local_block_devices | default "3" }}

# DEPRECATED:
# Monitor classes available to the compute which may be specified more than
# once.
# This option is DEPRECATED and no longer used. Use setuptools entry points to
# list available monitor plugins.
#  (multi valued)
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# Reason: stevedore and setuptools entry points now allow a set of plugins to be
# specified without this config option.
# from .default.nova.conf.compute_available_monitors (multiopt)
{{ if not .default.nova.conf.compute_available_monitors }}#compute_available_monitors = {{ .default.nova.conf.compute_available_monitors | default "" }}{{ else }}{{ range .default.nova.conf.compute_available_monitors }}compute_available_monitors = {{ . }}{{ end }}{{ end }}

#
# A list of monitors that can be used for getting compute metrics.
# You can use the alias/name from the setuptools entry points for
# nova.compute.monitors.* namespaces. If no namespace is supplied,
# the "cpu." namespace is assumed for backwards-compatibility.
#
# Possible values:
#
# * An empty list will disable the feature(Default).
# * An example value that would enable both the CPU and NUMA memory
#   bandwidth monitors that used the virt driver variant:
#   ["cpu.virt_driver", "numa_mem_bw.virt_driver"]
#  (list value)
# from .default.nova.conf.compute_monitors
{{ if not .default.nova.conf.compute_monitors }}#{{ end }}compute_monitors = {{ .default.nova.conf.compute_monitors | default "" }}

#
# Amount of disk resources in MB to make them always available to host. The
# disk usage gets reported back to the scheduler from nova-compute running
# on the compute nodes. To prevent the disk resources from being considered
# as available, this option can be used to reserve disk space for that host.
#
# Possible values:
#
#   * Any positive integer representing amount of disk in MB to reserve
#     for the host.
#  (integer value)
# Minimum value: 0
# from .default.nova.conf.reserved_host_disk_mb
{{ if not .default.nova.conf.reserved_host_disk_mb }}#{{ end }}reserved_host_disk_mb = {{ .default.nova.conf.reserved_host_disk_mb | default "0" }}

#
# Amount of memory in MB to reserve for the host so that it is always available
# to host processes. The host resources usage is reported back to the scheduler
# continuously from nova-compute running on the compute node. To prevent the
# host
# memory from being considered as available, this option is used to reserve
# memory for the host.
#
# Possible values:
#
#   * Any positive integer representing amount of memory in MB to reserve
#     for the host.
#  (integer value)
# Minimum value: 0
# from .default.nova.conf.reserved_host_memory_mb
{{ if not .default.nova.conf.reserved_host_memory_mb }}#{{ end }}reserved_host_memory_mb = {{ .default.nova.conf.reserved_host_memory_mb | default "512" }}

# DEPRECATED:
# Abstracts out managing compute host stats to pluggable class. This class
# manages and updates stats for the local compute host after an instance
# is changed. These configurable compute stats may be useful for a
# particular scheduler implementation.
#
# Possible values
#
#   * A string representing fully qualified class name.
#  (string value)
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# from .default.nova.conf.compute_stats_class
{{ if not .default.nova.conf.compute_stats_class }}#{{ end }}compute_stats_class = {{ .default.nova.conf.compute_stats_class | default "nova.compute.stats.Stats" }}

#
# This option helps you specify virtual CPU to physical CPU allocation
# ratio which affects all CPU filters.
#
# This configuration specifies ratio for CoreFilter which can be set
# per compute node. For AggregateCoreFilter, it will fall back to this
# configuration value if no per-aggregate setting is found.
#
# Possible values:
#
#     * Any valid positive integer or float value
#     * Default value is 0.0
#
# NOTE: This can be set per-compute, or if set to 0.0, the value
# set on the scheduler node(s) or compute node(s) will be used
# and defaulted to 16.0'.
#  (floating point value)
# from .default.nova.conf.cpu_allocation_ratio
{{ if not .default.nova.conf.cpu_allocation_ratio }}#{{ end }}cpu_allocation_ratio = {{ .default.nova.conf.cpu_allocation_ratio | default "0.0" }}

#
# This option helps you specify virtual RAM to physical RAM
# allocation ratio which affects all RAM filters.
#
# This configuration specifies ratio for RamFilter which can be set
# per compute node. For AggregateRamFilter, it will fall back to this
# configuration value if no per-aggregate setting found.
#
# Possible values:
#
#     * Any valid positive integer or float value
#     * Default value is 0.0
#
# NOTE: This can be set per-compute, or if set to 0.0, the value
# set on the scheduler node(s) or compute node(s) will be used and
# defaulted to 1.5.
#  (floating point value)
# from .default.nova.conf.ram_allocation_ratio
{{ if not .default.nova.conf.ram_allocation_ratio }}#{{ end }}ram_allocation_ratio = {{ .default.nova.conf.ram_allocation_ratio | default "0.0" }}

#
# This option helps you specify virtual disk to physical disk
# allocation ratio used by the disk_filter.py script to determine if
# a host has sufficient disk space to fit a requested instance.
#
# A ratio greater than 1.0 will result in over-subscription of the
# available physical disk, which can be useful for more
# efficiently packing instances created with images that do not
# use the entire virtual disk, such as sparse or compressed
# images. It can be set to a value between 0.0 and 1.0 in order
# to preserve a percentage of the disk for uses other than
# instances.
#
# Possible values:
#
#     * Any valid positive integer or float value
#     * Default value is 0.0
#
# NOTE: This can be set per-compute, or if set to 0.0, the value
# set on the scheduler node(s) or compute node(s) will be used and
# defaulted to 1.0'.
#  (floating point value)
# from .default.nova.conf.disk_allocation_ratio
{{ if not .default.nova.conf.disk_allocation_ratio }}#{{ end }}disk_allocation_ratio = {{ .default.nova.conf.disk_allocation_ratio | default "0.0" }}

#
# Console proxy host to be used to connect to instances on this host. It is the
# publicly visible name for the console host.
#
# Possible values:
#
# * Current hostname (default) or any string representing hostname.
#  (string value)
# from .default.nova.conf.console_host
{{ if not .default.nova.conf.console_host }}#{{ end }}console_host = {{ .default.nova.conf.console_host | default "socket.gethostname()" }}

#
# Name of the network to be used to set access IPs for instances. If there are
# multiple IPs to choose from, an arbitrary one will be chosen.
#
# Possible values:
#
# * None (default)
# * Any string representing network name.
#  (string value)
# from .default.nova.conf.default_access_ip_network_name
{{ if not .default.nova.conf.default_access_ip_network_name }}#{{ end }}default_access_ip_network_name = {{ .default.nova.conf.default_access_ip_network_name | default "<None>" }}

#
# Whether to batch up the application of IPTables rules during a host restart
# and apply all at the end of the init phase.
#  (boolean value)
# from .default.nova.conf.defer_iptables_apply
{{ if not .default.nova.conf.defer_iptables_apply }}#{{ end }}defer_iptables_apply = {{ .default.nova.conf.defer_iptables_apply | default "false" }}

#
# Specifies where instances are stored on the hypervisor's disk.
# It can point to locally attached storage or a directory on NFS.
#
# Possible values:
#
# * $state_path/instances where state_path is a config option that specifies
#   the top-level directory for maintaining nova's state. (default) or
#   Any string representing directory path.
#  (string value)
# from .default.nova.conf.instances_path
{{ if not .default.nova.conf.instances_path }}#{{ end }}instances_path = {{ .default.nova.conf.instances_path | default "$state_path/instances" }}

#
# This option enables periodic compute.instance.exists notifications. Each
# compute node must be configured to generate system usage data. These
# notifications are consumed by OpenStack Telemetry service.
#  (boolean value)
# from .default.nova.conf.instance_usage_audit
{{ if not .default.nova.conf.instance_usage_audit }}#{{ end }}instance_usage_audit = {{ .default.nova.conf.instance_usage_audit | default "false" }}

#
# Maximum number of 1 second retries in live_migration. It specifies number
# of retries to iptables when it complains. It happens when an user continously
# sends live-migration request to same host leading to concurrent request
# to iptables.
#
# Possible values:
#
# * Any positive integer representing retry count.
#  (integer value)
# Minimum value: 0
# from .default.nova.conf.live_migration_retry_count
{{ if not .default.nova.conf.live_migration_retry_count }}#{{ end }}live_migration_retry_count = {{ .default.nova.conf.live_migration_retry_count | default "30" }}

#
# This option specifies whether to start guests that were running before the
# host rebooted. It ensures that all of the instances on a Nova compute node
# resume their state each time the compute node boots or restarts.
#  (boolean value)
# from .default.nova.conf.resume_guests_state_on_host_boot
{{ if not .default.nova.conf.resume_guests_state_on_host_boot }}#{{ end }}resume_guests_state_on_host_boot = {{ .default.nova.conf.resume_guests_state_on_host_boot | default "false" }}

#
# Number of times to retry network allocation. It is required to attempt network
# allocation retries if the virtual interface plug fails.
#
# Possible values:
#
# * Any positive integer representing retry count.
#  (integer value)
# Minimum value: 0
# from .default.nova.conf.network_allocate_retries
{{ if not .default.nova.conf.network_allocate_retries }}#{{ end }}network_allocate_retries = {{ .default.nova.conf.network_allocate_retries | default "0" }}

#
# Limits the maximum number of instance builds to run concurrently by
# nova-compute. Compute service can attempt to build an infinite number of
# instances, if asked to do so. This limit is enforced to avoid building
# unlimited instance concurrently on a compute node. This value can be set
# per compute node.
#
# Possible Values:
#
# * 0 : treated as unlimited.
# * Any positive integer representing maximum concurrent builds.
#  (integer value)
# Minimum value: 0
# from .default.nova.conf.max_concurrent_builds
{{ if not .default.nova.conf.max_concurrent_builds }}#{{ end }}max_concurrent_builds = {{ .default.nova.conf.max_concurrent_builds | default "10" }}

#
# Maximum number of live migrations to run concurrently. This limit is enforced
# to avoid outbound live migrations overwhelming the host/network and causing
# failures. It is not recommended that you change this unless you are very sure
# that doing so is safe and stable in your environment.
#
# Possible values:
#
# * 0 : treated as unlimited.
# * Negative value defaults to 0.
# * Any positive integer representing maximum number of live migrations
#   to run concurrently.
#  (integer value)
# from .default.nova.conf.max_concurrent_live_migrations
{{ if not .default.nova.conf.max_concurrent_live_migrations }}#{{ end }}max_concurrent_live_migrations = {{ .default.nova.conf.max_concurrent_live_migrations | default "1" }}

#
# Number of times to retry block device allocation on failures. Starting with
# Liberty, Cinder can use image volume cache. This may help with block device
# allocation performance. Look at the cinder image_volume_cache_enabled
# configuration option.
#
# Possible values:
#
# * 60 (default)
# * If value is 0, then one attempt is made.
# * Any negative value is treated as 0.
# * For any value > 0, total attempts are (value + 1)
#  (integer value)
# from .default.nova.conf.block_device_allocate_retries
{{ if not .default.nova.conf.block_device_allocate_retries }}#{{ end }}block_device_allocate_retries = {{ .default.nova.conf.block_device_allocate_retries | default "60" }}

#
# Number of greenthreads available for use to sync power states.
#
# This option can be used to reduce the number of concurrent requests
# made to the hypervisor or system with real instance power states
# for performance reasons, for example, with Ironic.
#
# Possible values:
#
# * Any positive integer representing greenthreads count.
#  (integer value)
# from .default.nova.conf.sync_power_state_pool_size
{{ if not .default.nova.conf.sync_power_state_pool_size }}#{{ end }}sync_power_state_pool_size = {{ .default.nova.conf.sync_power_state_pool_size | default "1000" }}

# Interval to pull network bandwidth usage info. Not supported on all
# hypervisors. Set to -1 to disable. Setting this to 0 will run at the default
# rate. (integer value)
# from .default.nova.conf.bandwidth_poll_interval
{{ if not .default.nova.conf.bandwidth_poll_interval }}#{{ end }}bandwidth_poll_interval = {{ .default.nova.conf.bandwidth_poll_interval | default "600" }}

# Interval to sync power states between the database and the hypervisor. Set to
# -1 to disable. Setting this to 0 will run at the default rate. (integer value)
# from .default.nova.conf.sync_power_state_interval
{{ if not .default.nova.conf.sync_power_state_interval }}#{{ end }}sync_power_state_interval = {{ .default.nova.conf.sync_power_state_interval | default "600" }}

# Number of seconds between instance network information cache updates (integer
# value)
# from .default.nova.conf.heal_instance_info_cache_interval
{{ if not .default.nova.conf.heal_instance_info_cache_interval }}#{{ end }}heal_instance_info_cache_interval = {{ .default.nova.conf.heal_instance_info_cache_interval | default "60" }}

# Interval in seconds for reclaiming deleted instances. It takes effect only
# when value is greater than 0. (integer value)
# Minimum value: 0
# from .default.nova.conf.reclaim_instance_interval
{{ if not .default.nova.conf.reclaim_instance_interval }}#{{ end }}reclaim_instance_interval = {{ .default.nova.conf.reclaim_instance_interval | default "0" }}

# Interval in seconds for gathering volume usages (integer value)
# from .default.nova.conf.volume_usage_poll_interval
{{ if not .default.nova.conf.volume_usage_poll_interval }}#{{ end }}volume_usage_poll_interval = {{ .default.nova.conf.volume_usage_poll_interval | default "0" }}

# Interval in seconds for polling shelved instances to offload. Set to -1 to
# disable.Setting this to 0 will run at the default rate. (integer value)
# from .default.nova.conf.shelved_poll_interval
{{ if not .default.nova.conf.shelved_poll_interval }}#{{ end }}shelved_poll_interval = {{ .default.nova.conf.shelved_poll_interval | default "3600" }}

# Time in seconds before a shelved instance is eligible for removing from a
# host. -1 never offload, 0 offload immediately when shelved (integer value)
# from .default.nova.conf.shelved_offload_time
{{ if not .default.nova.conf.shelved_offload_time }}#{{ end }}shelved_offload_time = {{ .default.nova.conf.shelved_offload_time | default "0" }}

# Interval in seconds for retrying failed instance file deletes. Set to -1 to
# disable. Setting this to 0 will run at the default rate. (integer value)
# from .default.nova.conf.instance_delete_interval
{{ if not .default.nova.conf.instance_delete_interval }}#{{ end }}instance_delete_interval = {{ .default.nova.conf.instance_delete_interval | default "300" }}

# Waiting time interval (seconds) between block device allocation retries on
# failures (integer value)
# from .default.nova.conf.block_device_allocate_retries_interval
{{ if not .default.nova.conf.block_device_allocate_retries_interval }}#{{ end }}block_device_allocate_retries_interval = {{ .default.nova.conf.block_device_allocate_retries_interval | default "3" }}

# Waiting time interval (seconds) between sending the scheduler a list of
# current instance UUIDs to verify that its view of instances is in sync with
# nova. If the CONF option `scheduler_tracks_instance_changes` is False,
# changing this option will have no effect. (integer value)
# from .default.nova.conf.scheduler_instance_sync_interval
{{ if not .default.nova.conf.scheduler_instance_sync_interval }}#{{ end }}scheduler_instance_sync_interval = {{ .default.nova.conf.scheduler_instance_sync_interval | default "120" }}

# Interval in seconds for updating compute resources. A number less than 0 means
# to disable the task completely. Leaving this at the default of 0 will cause
# this to run at the default periodic interval. Setting it to any positive value
# will cause it to run at approximately that number of seconds. (integer value)
# from .default.nova.conf.update_resources_interval
{{ if not .default.nova.conf.update_resources_interval }}#{{ end }}update_resources_interval = {{ .default.nova.conf.update_resources_interval | default "0" }}

#
# Time interval after which an instance is hard rebooted automatically.
#
# When doing a soft reboot, it is possible that a guest kernel is
# completely hung in a way that causes the soft reboot task
# to not ever finish. Setting this option to a time period in seconds
# will automatically hard reboot an instance if it has been stuck
# in a rebooting state longer than N seconds.
#
# Possible values:
#
# * 0: Disables the option (default).
# * Any positive integer in seconds: Enables the option.
#  (integer value)
# Minimum value: 0
# from .default.nova.conf.reboot_timeout
{{ if not .default.nova.conf.reboot_timeout }}#{{ end }}reboot_timeout = {{ .default.nova.conf.reboot_timeout | default "0" }}

#
# Maximum time in seconds that an instance can take to build.
#
# If this timer expires, instance status will be changed to ERROR.
# Enabling this option will make sure an instance will not be stuck
# in BUILD state for a longer period.
#
# Possible values:
#
# * 0: Disables the option (default)
# * Any positive integer in seconds: Enables the option.
#  (integer value)
# Minimum value: 0
# from .default.nova.conf.instance_build_timeout
{{ if not .default.nova.conf.instance_build_timeout }}#{{ end }}instance_build_timeout = {{ .default.nova.conf.instance_build_timeout | default "0" }}

#
# Interval to wait before un-rescuing an instance stuck in RESCUE.
#
# Possible values:
#
# * 0: Disables the option (default)
# * Any positive integer in seconds: Enables the option.
#  (integer value)
# Minimum value: 0
# from .default.nova.conf.rescue_timeout
{{ if not .default.nova.conf.rescue_timeout }}#{{ end }}rescue_timeout = {{ .default.nova.conf.rescue_timeout | default "0" }}

#
# Automatically confirm resizes after N seconds.
#
# Resize functionality will save the existing server before resizing.
# After the resize completes, user is requested to confirm the resize.
# The user has the opportunity to either confirm or revert all
# changes. Confirm resize removes the original server and changes
# server status from resized to active. Setting this option to a time
# period (in seconds) will automatically confirm the resize if the
# server is in resized state longer than that time.
#
# Possible values:
#
# * 0: Disables the option (default)
# * Any positive integer in seconds: Enables the option.
#  (integer value)
# Minimum value: 0
# from .default.nova.conf.resize_confirm_window
{{ if not .default.nova.conf.resize_confirm_window }}#{{ end }}resize_confirm_window = {{ .default.nova.conf.resize_confirm_window | default "0" }}

#
# Total time to wait in seconds for an instance toperform a clean
# shutdown.
#
# It determines the overall period (in seconds) a VM is allowed to
# perform a clean shutdown. While performing stop, rescue and shelve,
# rebuild operations, configuring this option gives the VM a chance
# to perform a controlled shutdown before the instance is powered off.
# The default timeout is 60 seconds.
#
# The timeout value can be overridden on a per image basis by means
# of os_shutdown_timeout that is an image metadata setting allowing
# different types of operating systems to specify how much time they
# need to shut down cleanly.
#
# Possible values:
#
# * Any positive integer in seconds (default value is 60).
#  (integer value)
# Minimum value: 1
# from .default.nova.conf.shutdown_timeout
{{ if not .default.nova.conf.shutdown_timeout }}#{{ end }}shutdown_timeout = {{ .default.nova.conf.shutdown_timeout | default "60" }}

#
# The compute service periodically checks for instances that have been
# deleted in the database but remain running on the compute node. The
# above option enables action to be taken when such instances are
# identified.
#
# Possible values:
#
# * reap: Powers down the instances and deletes them(default)
# * log: Logs warning message about deletion of the resource
# * shutdown: Powers down instances and marks them as non-
#   bootable which can be later used for debugging/analysis
# * noop: Takes no action
#
# Related options:
#
# * running_deleted_instance_poll
# * running_deleted_instance_timeout
#  (string value)
# Allowed values: noop, log, shutdown, reap
# from .default.nova.conf.running_deleted_instance_action
{{ if not .default.nova.conf.running_deleted_instance_action }}#{{ end }}running_deleted_instance_action = {{ .default.nova.conf.running_deleted_instance_action | default "reap" }}

#
# Time interval in seconds to wait between runs for the clean up action.
# If set to 0, above check will be disabled. If "running_deleted_instance
# _action" is set to "log" or "reap", a value greater than 0 must be set.
#
# Possible values:
#
# * Any positive integer in seconds enables the option.
# * 0: Disables the option.
# * 1800: Default value.
#
# Related options:
#
# * running_deleted_instance_action
#  (integer value)
# from .default.nova.conf.running_deleted_instance_poll_interval
{{ if not .default.nova.conf.running_deleted_instance_poll_interval }}#{{ end }}running_deleted_instance_poll_interval = {{ .default.nova.conf.running_deleted_instance_poll_interval | default "1800" }}

#
# Time interval in seconds to wait for the instances that have
# been marked as deleted in database to be eligible for cleanup.
#
# Possible values:
#
# * Any positive integer in seconds(default is 0).
#
# Related options:
#
# * "running_deleted_instance_action"
#  (integer value)
# from .default.nova.conf.running_deleted_instance_timeout
{{ if not .default.nova.conf.running_deleted_instance_timeout }}#{{ end }}running_deleted_instance_timeout = {{ .default.nova.conf.running_deleted_instance_timeout | default "0" }}

# The number of times to attempt to reap an instance's files. (integer value)
# from .default.nova.conf.maximum_instance_delete_attempts
{{ if not .default.nova.conf.maximum_instance_delete_attempts }}#{{ end }}maximum_instance_delete_attempts = {{ .default.nova.conf.maximum_instance_delete_attempts | default "5" }}

#
# This is the message queue topic that the compute service 'listens' on. It is
# used when the compute service is started up to configure the queue, and
# whenever an RPC call to the compute service is made.
#
# * Possible values:
#
#     Any string, but there is almost never any reason to ever change this value
#     from its default of 'compute'.
#
# * Services that use this:
#
#     ``nova-compute``
#
# * Related options:
#
#     None
#  (string value)
# from .default.nova.conf.compute_topic
{{ if not .default.nova.conf.compute_topic }}#{{ end }}compute_topic = {{ .default.nova.conf.compute_topic | default "compute" }}

#
# Sets the scope of the check for unique instance names.
#
# The default doesn't check for unique names. If a scope for the name check is
# set, a launch of a new instance or an update of an existing instance with a
# duplicate name will result in an ''InstanceExists'' error. The uniqueness is
# case-insensitive. Setting this option can increase the usability for end
# users as they don't have to distinguish among instances with the same name
# by their IDs.
#
# Possible values:
#
# * '': An empty value means that no uniqueness check is done and duplicate
#   names are possible.
# * "project": The instance name check is done only for instances within the
#   same project.
# * "global": The instance name check is done for all instances regardless of
#   the project.
#  (string value)
# Allowed values: '', project, global
# from .default.nova.conf.osapi_compute_unique_server_name_scope
{{ if not .default.nova.conf.osapi_compute_unique_server_name_scope }}#{{ end }}osapi_compute_unique_server_name_scope = {{ .default.nova.conf.osapi_compute_unique_server_name_scope | default "" }}

#
# Enable new services on this host automatically.
#
# When a new service (for example "nova-compute") starts up, it gets
# registered in the database as an enabled service. Sometimes it can be useful
# to register new services in disabled state and then enabled them at a later
# point in time. This option can set this behavior for all services per host.
#
# Possible values:
#
# * ``True``: Each new service is enabled as soon as it registers itself.
# * ``False``: Services must be enabled via a REST API call or with the CLI
#   with ``nova service-enable <hostname> <binary>``, otherwise they are not
#   ready to use.
#  (boolean value)
# from .default.nova.conf.enable_new_services
{{ if not .default.nova.conf.enable_new_services }}#{{ end }}enable_new_services = {{ .default.nova.conf.enable_new_services | default "true" }}

#
# Template string to be used to generate instance names.
#
# This template controls the creation of the database name of an instance. This
# is *not* the display name you enter when creating an instance (via Horizon
# or CLI). For a new deployment it is advisable to change the default value
# (which uses the database autoincrement) to another value which makes use
# of the attributes of an instance, like ``instance-%(uuid)s``. If you
# already have instances in your deployment when you change this, your
# deployment will break.
#
# Possible values:
#
# * A string which either uses the instance database ID (like the
#   default)
# * A string with a list of named database columns, for example ``%(id)d``
#   or ``%(uuid)s`` or ``%(hostname)s``.
#
# Related options:
#
# * not to be confused with: ``multi_instance_display_name_template``
#  (string value)
# from .default.nova.conf.instance_name_template
{{ if not .default.nova.conf.instance_name_template }}#{{ end }}instance_name_template = {{ .default.nova.conf.instance_name_template | default "instance-%08x" }}

# DEPRECATED: Template string to be used to generate snapshot names (string
# value)
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# Reason: This is not used anymore and will be removed in the O release.
# from .default.nova.conf.snapshot_name_template
{{ if not .default.nova.conf.snapshot_name_template }}#{{ end }}snapshot_name_template = {{ .default.nova.conf.snapshot_name_template | default "snapshot-%s" }}

#
# Number of times to retry live-migration before failing.
#
# Possible values:
#
# * If == -1, try until out of hosts (default)
# * If == 0, only try once, no retries
# * Integer greater than 0
#  (integer value)
# Minimum value: -1
# from .default.nova.conf.migrate_max_retries
{{ if not .default.nova.conf.migrate_max_retries }}#{{ end }}migrate_max_retries = {{ .default.nova.conf.migrate_max_retries | default "-1" }}

#
# Configuration drive format
#
# Configuration drive format that will contain metadata attached to the
# instance when it boots.
#
# Possible values:
#
# * iso9660: A file system image standard that is widely supported across
#   operating systems. NOTE: Mind the libvirt bug
#   (https://bugs.launchpad.net/nova/+bug/1246201) - If your hypervisor
#   driver is libvirt, and you want live migrate to work without shared storage,
#   then use VFAT.
# * vfat: For legacy reasons, you can configure the configuration drive to
#   use VFAT format instead of ISO 9660.
#
# Related options:
#
# * This option is meaningful when one of the following alternatives occur:
#   1. force_config_drive option set to 'true'
#   2. the REST API call to create the instance contains an enable flag for
#      config drive option
#   3. the image used to create the instance requires a config drive,
#      this is defined by img_config_drive property for that image.
# * A compute node running Hyper-V hypervisor can be configured to attach
#   configuration drive as a CD drive. To attach the configuration drive as a CD
#   drive, set config_drive_cdrom option at hyperv section, to true.
#  (string value)
# Allowed values: iso9660, vfat
# from .default.nova.conf.config_drive_format
{{ if not .default.nova.conf.config_drive_format }}#{{ end }}config_drive_format = {{ .default.nova.conf.config_drive_format | default "iso9660" }}

#
# Force injection to take place on a config drive
#
# When this option is set to true configuration drive functionality will be
# forced enabled by default, otherwise user can still enable configuration
# drives via the REST API or image metadata properties.
#
# Possible values:
#
# * True: Force to use of configuration drive regardless the user's input in the
#         REST API call.
# * False: Do not force use of configuration drive. Config drives can still be
#          enabled via the REST API or image metadata properties.
#
# Related options:
#
# * Use the 'mkisofs_cmd' flag to set the path where you install the
#   genisoimage program. If genisoimage is in same path as the
#   nova-compute service, you do not need to set this flag.
# * To use configuration drive with Hyper-V, you must set the
#   'mkisofs_cmd' value to the full path to an mkisofs.exe installation.
#   Additionally, you must set the qemu_img_cmd value in the hyperv
#   configuration section to the full path to an qemu-img command
#   installation.
#  (boolean value)
# from .default.nova.conf.force_config_drive
{{ if not .default.nova.conf.force_config_drive }}#{{ end }}force_config_drive = {{ .default.nova.conf.force_config_drive | default "false" }}

#
# Name or path of the tool used for ISO image creation
#
# Use the mkisofs_cmd flag to set the path where you install the genisoimage
# program. If genisoimage is on the system path, you do not need to change
# the default value.
#
# To use configuration drive with Hyper-V, you must set the mkisofs_cmd value
# to the full path to an mkisofs.exe installation. Additionally, you must set
# the qemu_img_cmd value in the hyperv configuration section to the full path
# to an qemu-img command installation.
#
# Possible values:
#
# * Name of the ISO image creator program, in case it is in the same directory
#   as the nova-compute service
# * Path to ISO image creator program
#
# Related options:
#
# * This option is meaningful when config drives are enabled.
# * To use configuration drive with Hyper-V, you must set the qemu_img_cmd
#   value in the hyperv configuration section to the full path to an qemu-img
#   command installation.
#  (string value)
# from .default.nova.conf.mkisofs_cmd
{{ if not .default.nova.conf.mkisofs_cmd }}#{{ end }}mkisofs_cmd = {{ .default.nova.conf.mkisofs_cmd | default "genisoimage" }}

#
# Adds list of allowed origins to the console websocket proxy to allow
# connections from other origin hostnames.
# Websocket proxy matches the host header with the origin header to
# prevent cross-site requests. This list specifies if any there are
# values other than host are allowed in the origin header.
#
# Possible values
#
#   * An empty list (default) or list of allowed origin hostnames.
#  (list value)
# from .default.nova.conf.console_allowed_origins
{{ if not .default.nova.conf.console_allowed_origins }}#{{ end }}console_allowed_origins = {{ .default.nova.conf.console_allowed_origins | default "" }}

#
# Represents the message queue topic name used by nova-console
# service when communicating via the AMQP server. The Nova API uses a message
# queue to communicate with nova-console to retrieve a console URL for that
# host.
#
# Possible values
#
#   * 'console' (default) or any string representing topic exchange name.
#  (string value)
# from .default.nova.conf.console_topic
{{ if not .default.nova.conf.console_topic }}#{{ end }}console_topic = {{ .default.nova.conf.console_topic | default "console" }}

#
# Nova-console proxy is used to set up multi-tenant VM console access.
# This option allows pluggable driver program for the console session
# and represents driver to use for the console proxy.
#
# Possible values
#
#   * 'nova.console.xvp.XVPConsoleProxy' (default) or
#     a string representing fully classified class name of console driver.
#  (string value)
# from .default.nova.conf.console_driver
{{ if not .default.nova.conf.console_driver }}#{{ end }}console_driver = {{ .default.nova.conf.console_driver | default "nova.console.xvp.XVPConsoleProxy" }}

#
# Publicly visible name for this console host.
#
# Possible values
#
#   * Current hostname (default) or any string representing hostname.
#  (string value)
# from .default.nova.conf.console_public_hostname
{{ if not .default.nova.conf.console_public_hostname }}#{{ end }}console_public_hostname = {{ .default.nova.conf.console_public_hostname | default "hpdesktop" }}

#
# This option allows you to change the message topic used by nova-consoleauth
# service when communicating via the AMQP server. Nova Console Authentication
# server authenticates nova consoles. Users can then access their instances
# through VNC clients. The Nova API service uses a message queue to
# communicate with nova-consoleauth to get a VNC console.
#
# Possible Values:
#
#   * 'consoleauth' (default) or Any string representing topic exchange name.
#  (string value)
# from .default.nova.conf.consoleauth_topic
{{ if not .default.nova.conf.consoleauth_topic }}#{{ end }}consoleauth_topic = {{ .default.nova.conf.consoleauth_topic | default "consoleauth" }}

#
# This option indicates the lifetime of a console auth token. A console auth
# token is used in authorizing console access for a user. Once the auth token
# time to live count has elapsed, the token is considered expired. Expired
# tokens are then deleted.
#  (integer value)
# Minimum value: 0
# from .default.nova.conf.console_token_ttl
{{ if not .default.nova.conf.console_token_ttl }}#{{ end }}console_token_ttl = {{ .default.nova.conf.console_token_ttl | default "600" }}

# DEPRECATED: The driver to use for database access (string value)
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# from .default.nova.conf.db_driver
{{ if not .default.nova.conf.db_driver }}#{{ end }}db_driver = {{ .default.nova.conf.db_driver | default "nova.db" }}

# DEPRECATED:
# When set to true, this option enables validation of exception
# message format.
#
# This option is used to detect errors in NovaException class when it formats
# error messages. If True, raise an exception; if False, use the unformatted
# message.
#  (boolean value)
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# Reason: This is only used for internal testing.
# from .default.nova.conf.fatal_exception_format_errors
{{ if not .default.nova.conf.fatal_exception_format_errors }}#{{ end }}fatal_exception_format_errors = {{ .default.nova.conf.fatal_exception_format_errors | default "false" }}

# DEPRECATED:
# Default flavor to use for the EC2 API only.
# The Nova API does not support a default flavor.
#  (string value)
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# Reason: The EC2 API is deprecated
# from .default.nova.conf.default_flavor
{{ if not .default.nova.conf.default_flavor }}#{{ end }}default_flavor = {{ .default.nova.conf.default_flavor | default "m1.small" }}

#
# Default pool for floating IPs.
#
# This option specifies the default floating IP pool for allocating floating
# IPs.
#
# While allocating a floating ip, users can optionally pass in the name of the
# pool they want to allocate from, otherwise it will be pulled from the
# default pool.
#
# If this option is not set, then 'nova' is used as default floating pool.
#
# Possible values:
#
#     * Any string representing a floating IP pool name
#  (string value)
# from .default.nova.conf.default_floating_pool
{{ if not .default.nova.conf.default_floating_pool }}#{{ end }}default_floating_pool = {{ .default.nova.conf.default_floating_pool | default "nova" }}

#
# Autoassigning floating IP to VM
#
# When set to True, floating IP is auto allocated and associated
# to the VM upon creation.
#  (boolean value)
# from .default.nova.conf.auto_assign_floating_ip
{{ if not .default.nova.conf.auto_assign_floating_ip }}#{{ end }}auto_assign_floating_ip = {{ .default.nova.conf.auto_assign_floating_ip | default "false" }}

#
# Full class name for the DNS Manager for floating IPs.
#
# This option specifies the class of the driver that provides functionality
# to manage DNS entries associated with floating IPs.
#
# When a user adds a DNS entry for a specified domain to a floating IP,
# nova will add a DNS entry using the specified floating DNS driver.
# When a floating IP is deallocated, its DNS entry will automatically be
# deleted.
#
# Possible values:
#
#     * Full Python path to the class to be used
#  (string value)
# from .default.nova.conf.floating_ip_dns_manager
{{ if not .default.nova.conf.floating_ip_dns_manager }}#{{ end }}floating_ip_dns_manager = {{ .default.nova.conf.floating_ip_dns_manager | default "nova.network.noop_dns_driver.NoopDNSDriver" }}

#
# Full class name for the DNS Manager for instance IPs.
#
# This option specifies the class of the driver that provides functionality
# to manage DNS entries for instances.
#
# On instance creation, nova will add DNS entries for the instance name and
# id, using the specified instance DNS driver and domain. On instance deletion,
# nova will remove the DNS entries.
#
# Possible values:
#
#     * Full Python path to the class to be used
#  (string value)
# from .default.nova.conf.instance_dns_manager
{{ if not .default.nova.conf.instance_dns_manager }}#{{ end }}instance_dns_manager = {{ .default.nova.conf.instance_dns_manager | default "nova.network.noop_dns_driver.NoopDNSDriver" }}

#
# If specified, Nova checks if the availability_zone of every instance matches
# what the database says the availability_zone should be for the specified
# dns_domain.
#  (string value)
# from .default.nova.conf.instance_dns_domain
{{ if not .default.nova.conf.instance_dns_domain }}#{{ end }}instance_dns_domain = {{ .default.nova.conf.instance_dns_domain | default "" }}

#
# Abstracts out IPv6 address generation to pluggable backends.
#
# nova-network can be put into dual-stack mode, so that it uses
# both IPv4 and IPv6 addresses. In dual-stack mode, by default, instances
# acquire IPv6 global unicast addresses with the help of stateless address
# auto-configuration mechanism.
#
# Related options:
#
# * use_neutron: this option only works with nova-network.
# * use_ipv6: this option only works if ipv6 is enabled for nova-network.
#  (string value)
# Allowed values: rfc2462, account_identifier
# from .default.nova.conf.ipv6_backend
{{ if not .default.nova.conf.ipv6_backend }}#{{ end }}ipv6_backend = {{ .default.nova.conf.ipv6_backend | default "rfc2462" }}

#
# The IP address which the host is using to connect to the management network.
#
# Possible values:
#
# * String with valid IP address. Default is IPv4 address of this host.
#
# Related options:
#
# * metadata_host
# * my_block_storage_ip
# * routing_source_ip
# * vpn_ip
#  (string value)
# from .default.nova.conf.my_ip
{{ if not .default.nova.conf.my_ip }}#{{ end }}my_ip = {{ .default.nova.conf.my_ip | default "68.121.13.249" }}

#
# The IP address which is used to connect to the block storage network.
#
# Possible values:
#
# * String with valid IP address. Default is IP address of this host.
#
# Related options:
#
# * my_ip - if my_block_storage_ip is not set, then my_ip value is used.
#  (string value)
# from .default.nova.conf.my_block_storage_ip
{{ if not .default.nova.conf.my_block_storage_ip }}#{{ end }}my_block_storage_ip = {{ .default.nova.conf.my_block_storage_ip | default "$my_ip" }}

#
# Hostname, FQDN or IP address of this host. Must be valid within AMQP key.
#
# Possible values:
#
# * String with hostname, FQDN or IP address. Default is hostname of this host.
#  (string value)
# from .default.nova.conf.host
{{ if not .default.nova.conf.host }}#{{ end }}host = {{ .default.nova.conf.host | default "hpdesktop" }}

#
# Assign IPv6 and IPv4 addresses when creating instances.
#
# Related options:
#
# * use_neutron: this only works with nova-network.
#  (boolean value)
# from .default.nova.conf.use_ipv6
{{ if not .default.nova.conf.use_ipv6 }}#{{ end }}use_ipv6 = {{ .default.nova.conf.use_ipv6 | default "false" }}

#
# This option is a list of full paths to one or more configuration files for
# dhcpbridge. In most cases the default path of '/etc/nova/nova-dhcpbridge.conf'
# should be sufficient, but if you have special needs for configuring
# dhcpbridge,
# you can change or add to this list.
#
# Possible values
#
#     A list of strings, where each string is the full path to a dhcpbridge
#     configuration file.
#  (multi valued)
# from .default.nova.conf.dhcpbridge_flagfile (multiopt)
{{ if not .default.nova.conf.dhcpbridge_flagfile }}#dhcpbridge_flagfile = {{ .default.nova.conf.dhcpbridge_flagfile | default "/etc/nova/nova-dhcpbridge.conf" }}{{ else }}{{ range .default.nova.conf.dhcpbridge_flagfile }}dhcpbridge_flagfile = {{ . }}{{ end }}{{ end }}

#
# The location where the network configuration files will be kept. The default
# is
# the 'networks' directory off of the location where nova's Python module is
# installed.
#
# Possible values
#
#     A string containing the full path to the desired configuration directory
#  (string value)
# from .default.nova.conf.networks_path
{{ if not .default.nova.conf.networks_path }}#{{ end }}networks_path = {{ .default.nova.conf.networks_path | default "$state_path/networks" }}

#
# This is the name of the network interface for public IP addresses. The default
# is 'eth0'.
#
# Possible values:
#
#     Any string representing a network interface name
#  (string value)
# from .default.nova.conf.public_interface
{{ if not .default.nova.conf.public_interface }}#{{ end }}public_interface = {{ .default.nova.conf.public_interface | default "eth0" }}

#
# The location of the binary nova-dhcpbridge. By default it is the binary named
# 'nova-dhcpbridge' that is installed with all the other nova binaries.
#
# Possible values:
#
#     Any string representing the full path to the binary for dhcpbridge
#  (string value)
# from .default.nova.conf.dhcpbridge
{{ if not .default.nova.conf.dhcpbridge }}#{{ end }}dhcpbridge = {{ .default.nova.conf.dhcpbridge | default "$bindir/nova-dhcpbridge" }}

#
# This is the public IP address of the network host. It is used when creating a
# SNAT rule.
#
# Possible values:
#
#     Any valid IP address
#
# Related options:
#
#     force_snat_range
#  (string value)
# from .default.nova.conf.routing_source_ip
{{ if not .default.nova.conf.routing_source_ip }}#{{ end }}routing_source_ip = {{ .default.nova.conf.routing_source_ip | default "$my_ip" }}

#
# The lifetime of a DHCP lease, in seconds. The default is 86400 (one day).
#
# Possible values:
#
#     Any positive integer value.
#  (integer value)
# Minimum value: 1
# from .default.nova.conf.dhcp_lease_time
{{ if not .default.nova.conf.dhcp_lease_time }}#{{ end }}dhcp_lease_time = {{ .default.nova.conf.dhcp_lease_time | default "86400" }}

#
# Despite the singular form of the name of this option, it is actually a list of
# zero or more server addresses that dnsmasq will use for DNS nameservers. If
# this is not empty, dnsmasq will not read /etc/resolv.conf, but will only use
# the servers specified in this option. If the option use_network_dns_servers is
# True, the dns1 and dns2 servers from the network will be appended to this
# list,
# and will be used as DNS servers, too.
#
# Possible values:
#
#     A list of strings, where each string is either an IP address or a FQDN.
#
# Related options:
#
#     use_network_dns_servers
#  (multi valued)
# from .default.nova.conf.dns_server (multiopt)
{{ if not .default.nova.conf.dns_server }}#dns_server = {{ .default.nova.conf.dns_server | default "" }}{{ else }}{{ range .default.nova.conf.dns_server }}dns_server = {{ . }}{{ end }}{{ end }}

#
# When this option is set to True, the dns1 and dns2 servers for the network
# specified by the user on boot will be used for DNS, as well as any specified
# in
# the `dns_server` option.
#
# Related options:
#
#     dns_server
#  (boolean value)
# from .default.nova.conf.use_network_dns_servers
{{ if not .default.nova.conf.use_network_dns_servers }}#{{ end }}use_network_dns_servers = {{ .default.nova.conf.use_network_dns_servers | default "false" }}

#
# This option is a list of zero or more IP address ranges in your network's DMZ
# that should be accepted.
#
# Possible values:
#
#     A list of strings, each of which should be a valid CIDR.
#  (list value)
# from .default.nova.conf.dmz_cidr
{{ if not .default.nova.conf.dmz_cidr }}#{{ end }}dmz_cidr = {{ .default.nova.conf.dmz_cidr | default "" }}

#
# This is a list of zero or more IP ranges that traffic from the
# `routing_source_ip` will be SNATted to. If the list is empty, then no SNAT
# rules are created.
#
# Possible values:
#
#     A list of strings, each of which should be a valid CIDR.
#
# Related options:
#
#     routing_source_ip
#  (multi valued)
# from .default.nova.conf.force_snat_range (multiopt)
{{ if not .default.nova.conf.force_snat_range }}#force_snat_range = {{ .default.nova.conf.force_snat_range | default "" }}{{ else }}{{ range .default.nova.conf.force_snat_range }}force_snat_range = {{ . }}{{ end }}{{ end }}

#
# The path to the custom dnsmasq configuration file, if any.
#
# Possible values:
#
#     The full path to the configuration file, or an empty string if there is no
#     custom dnsmasq configuration file.
#  (string value)
# from .default.nova.conf.dnsmasq_config_file
{{ if not .default.nova.conf.dnsmasq_config_file }}#{{ end }}dnsmasq_config_file = {{ .default.nova.conf.dnsmasq_config_file | default "" }}

#
# This is the class used as the ethernet device driver for linuxnet bridge
# operations. The default value should be all you need for most cases, but if
# you
# wish to use a customized class, set this option to the full dot-separated
# import path for that class.
#
# Possible values:
#
#     Any string representing a dot-separated class path that Nova can import.
#  (string value)
# from .default.nova.conf.linuxnet_interface_driver
{{ if not .default.nova.conf.linuxnet_interface_driver }}#{{ end }}linuxnet_interface_driver = {{ .default.nova.conf.linuxnet_interface_driver | default "nova.network.linux_net.LinuxBridgeInterfaceDriver" }}

#
# The name of the Open vSwitch bridge that is used with linuxnet when connecting
# with Open vSwitch."
#
# Possible values:
#
#     Any string representing a valid bridge name.
#  (string value)
# from .default.nova.conf.linuxnet_ovs_integration_bridge
{{ if not .default.nova.conf.linuxnet_ovs_integration_bridge }}#{{ end }}linuxnet_ovs_integration_bridge = {{ .default.nova.conf.linuxnet_ovs_integration_bridge | default "br-int" }}

#
# When True, when a device starts up, and upon binding floating IP addresses,
# arp
# messages will be sent to ensure that the arp caches on the compute hosts are
# up-to-date.
#
# Related options:
#
#     send_arp_for_ha_count
#  (boolean value)
# from .default.nova.conf.send_arp_for_ha
{{ if not .default.nova.conf.send_arp_for_ha }}#{{ end }}send_arp_for_ha = {{ .default.nova.conf.send_arp_for_ha | default "false" }}

#
# When arp messages are configured to be sent, they will be sent with the count
# set to the value of this option. Of course, if this is set to zero, no arp
# messages will be sent.
#
# Possible values:
#
#     Any integer greater than or equal to 0
#
# Related options:
#
#     send_arp_for_ha
#  (integer value)
# from .default.nova.conf.send_arp_for_ha_count
{{ if not .default.nova.conf.send_arp_for_ha_count }}#{{ end }}send_arp_for_ha_count = {{ .default.nova.conf.send_arp_for_ha_count | default "3" }}

#
# When set to True, only the firt nic of a VM will get its default gateway from
# the DHCP server.
#  (boolean value)
# from .default.nova.conf.use_single_default_gateway
{{ if not .default.nova.conf.use_single_default_gateway }}#{{ end }}use_single_default_gateway = {{ .default.nova.conf.use_single_default_gateway | default "false" }}

#
# One or more interfaces that bridges can forward traffic to. If any of the
# items
# in this list is the special keyword 'all', then all traffic will be forwarded.
#
# Possible values:
#
#     A list of zero or more interface names, or the word 'all'.
#  (multi valued)
# from .default.nova.conf.forward_bridge_interface (multiopt)
{{ if not .default.nova.conf.forward_bridge_interface }}#forward_bridge_interface = {{ .default.nova.conf.forward_bridge_interface | default "all" }}{{ else }}{{ range .default.nova.conf.forward_bridge_interface }}forward_bridge_interface = {{ . }}{{ end }}{{ end }}

#
# This option determines the IP address for the network metadata API server.
#
# Possible values:
#
#    * Any valid IP address. The default is the address of the Nova API server.
#
# Related options:
#
#     * metadata_port
#  (string value)
# from .default.nova.conf.metadata_host
{{ if not .default.nova.conf.metadata_host }}#{{ end }}metadata_host = {{ .default.nova.conf.metadata_host | default "$my_ip" }}

#
# This option determines the port used for the metadata API server.
#
# Related options:
#
#     * metadata_host
#  (port value)
# Minimum value: 0
# Maximum value: 65535
# from .default.nova.conf.metadata_port
{{ if not .default.nova.conf.metadata_port }}#{{ end }}metadata_port = {{ .default.nova.conf.metadata_port | default "8775" }}

#
# This expression, if defined, will select any matching iptables rules and place
# them at the top when applying metadata changes to the rules.
#
# Possible values:
#
#     * Any string representing a valid regular expression, or an empty string
#
# Related options:
#
#     * iptables_bottom_regex
#  (string value)
# from .default.nova.conf.iptables_top_regex
{{ if not .default.nova.conf.iptables_top_regex }}#{{ end }}iptables_top_regex = {{ .default.nova.conf.iptables_top_regex | default "" }}

#
# This expression, if defined, will select any matching iptables rules and place
# them at the bottom when applying metadata changes to the rules.
#
# Possible values:
#
#     * Any string representing a valid regular expression, or an empty string
#
# Related options:
#
#     * iptables_top_regex
#  (string value)
# from .default.nova.conf.iptables_bottom_regex
{{ if not .default.nova.conf.iptables_bottom_regex }}#{{ end }}iptables_bottom_regex = {{ .default.nova.conf.iptables_bottom_regex | default "" }}

#
# By default, packets that do not pass the firewall are DROPped. In many cases,
# though, an operator may find it more useful to change this from DROP to
# REJECT,
# so that the user issuing those packets may have a better idea as to what's
# going on, or LOGDROP in order to record the blocked traffic before DROPping.
#
# Possible values:
#
#     * A string representing an iptables chain. The default is DROP.
#  (string value)
# from .default.nova.conf.iptables_drop_action
{{ if not .default.nova.conf.iptables_drop_action }}#{{ end }}iptables_drop_action = {{ .default.nova.conf.iptables_drop_action | default "DROP" }}

#
# This option represents the period of time, in seconds, that the ovs_vsctl
# calls
# will wait for a response from the database before timing out. A setting of 0
# means that the utility should wait forever for a response.
#
# Possible values:
#
#     * Any positive integer if a limited timeout is desired, or zero if the
#     calls should wait forever for a response.
#  (integer value)
# Minimum value: 0
# from .default.nova.conf.ovs_vsctl_timeout
{{ if not .default.nova.conf.ovs_vsctl_timeout }}#{{ end }}ovs_vsctl_timeout = {{ .default.nova.conf.ovs_vsctl_timeout | default "120" }}

#
# This option is used mainly in testing to avoid calls to the underlying network
# utilities.
#  (boolean value)
# from .default.nova.conf.fake_network
{{ if not .default.nova.conf.fake_network }}#{{ end }}fake_network = {{ .default.nova.conf.fake_network | default "false" }}

#
# This option determines the number of times to retry ebtables commands before
# giving up. The minimum number of retries is 1.
#
# Possible values:
#
#     * Any positive integer
#
# Related options:
#
#     * ebtables_retry_interval
#  (integer value)
# Minimum value: 1
# from .default.nova.conf.ebtables_exec_attempts
{{ if not .default.nova.conf.ebtables_exec_attempts }}#{{ end }}ebtables_exec_attempts = {{ .default.nova.conf.ebtables_exec_attempts | default "3" }}

#
# This option determines the time, in seconds, that the system will sleep in
# between ebtables retries. Note that each successive retry waits a multiple of
# this value, so for example, if this is set to the default of 1.0 seconds, and
# ebtables_exec_attempts is 4, after the first failure, the system will sleep
# for
# 1 * 1.0 seconds, after the second failure it will sleep 2 * 1.0 seconds, and
# after the third failure it will sleep 3 * 1.0 seconds.
#
# Possible values:
#
#     * Any non-negative float or integer. Setting this to zero will result in
# no
#     waiting between attempts.
#
# Related options:
#
#     * ebtables_exec_attempts
#  (floating point value)
# from .default.nova.conf.ebtables_retry_interval
{{ if not .default.nova.conf.ebtables_retry_interval }}#{{ end }}ebtables_retry_interval = {{ .default.nova.conf.ebtables_retry_interval | default "1.0" }}

#
# This option determines the bridge used for simple network interfaces when no
# bridge is specified in the VM creation request.
#
# Please note that this option is only used when using nova-network instead of
# Neutron in your deployment.
#
# Possible values:
#
#     Any string representing a valid network bridge, such as 'br100'
#
# Related options:
#
#     ``use_neutron``
#  (string value)
# from .default.nova.conf.flat_network_bridge
{{ if not .default.nova.conf.flat_network_bridge }}#{{ end }}flat_network_bridge = {{ .default.nova.conf.flat_network_bridge | default "<None>" }}

#
# This is the address of the DNS server for a simple network. If this option is
# not specified, the default of '8.8.4.4' is used.
#
# Please note that this option is only used when using nova-network instead of
# Neutron in your deployment.
#
# Possible values:
#
#     Any valid IP address.
#
# Related options:
#
#     ``use_neutron``
#  (string value)
# from .default.nova.conf.flat_network_dns
{{ if not .default.nova.conf.flat_network_dns }}#{{ end }}flat_network_dns = {{ .default.nova.conf.flat_network_dns | default "8.8.4.4" }}

#
# This option determines whether the network setup information is injected into
# the VM before it is booted. While it was originally designed to be used only
# by
# nova-network, it is also used by the vmware and xenapi virt drivers to control
# whether network information is injected into a VM.
#  (boolean value)
# from .default.nova.conf.flat_injected
{{ if not .default.nova.conf.flat_injected }}#{{ end }}flat_injected = {{ .default.nova.conf.flat_injected | default "false" }}

#
# This option is the name of the virtual interface of the VM on which the bridge
# will be built. While it was originally designed to be used only by
# nova-network, it is also used by libvirt for the bridge interface name.
#
# Possible values:
#
#     Any valid virtual interface name, such as 'eth0'
#  (string value)
# from .default.nova.conf.flat_interface
{{ if not .default.nova.conf.flat_interface }}#{{ end }}flat_interface = {{ .default.nova.conf.flat_interface | default "<None>" }}

#
# This is the VLAN number used for private networks. Note that the when creating
# the networks, if the specified number has already been assigned, nova-network
# will increment this number until it finds an available VLAN.
#
# Please note that this option is only used when using nova-network instead of
# Neutron in your deployment. It also will be ignored if the configuration
# option
# for `network_manager` is not set to the default of
# 'nova.network.manager.VlanManager'.
#
# Possible values:
#
#     Any integer between 1 and 4094. Values outside of that range will raise a
#     ValueError exception. Default = 100.
#
# Related options:
#
#     ``network_manager``, ``use_neutron``
#  (integer value)
# Minimum value: 1
# Maximum value: 4094
# from .default.nova.conf.vlan_start
{{ if not .default.nova.conf.vlan_start }}#{{ end }}vlan_start = {{ .default.nova.conf.vlan_start | default "100" }}

#
# This option is the name of the virtual interface of the VM on which the VLAN
# bridge will be built. While it was originally designed to be used only by
# nova-network, it is also used by libvirt and xenapi for the bridge interface
# name.
#
# Please note that this setting will be ignored in nova-network if the
# configuration option for `network_manager` is not set to the default of
# 'nova.network.manager.VlanManager'.
#
# Possible values:
#
#     Any valid virtual interface name, such as 'eth0'
#  (string value)
# from .default.nova.conf.vlan_interface
{{ if not .default.nova.conf.vlan_interface }}#{{ end }}vlan_interface = {{ .default.nova.conf.vlan_interface | default "<None>" }}

#
# This option represents the number of networks to create if not explicitly
# specified when the network is created. The only time this is used is if a CIDR
# is specified, but an explicit network_size is not. In that case, the subnets
# are created by diving the IP address space of the CIDR by num_networks. The
# resulting subnet sizes cannot be larger than the configuration option
# `network_size`; in that event, they are reduced to `network_size`, and a
# warning is logged.
#
# Please note that this option is only used when using nova-network instead of
# Neutron in your deployment.
#
# Possible values:
#
#     Any positive integer is technically valid, although there are practical
#     limits based upon available IP address space and virtual interfaces. The
#     default is 1.
#
# Related options:
#
#     ``use_neutron``, ``network_size``
#  (integer value)
# Minimum value: 1
# from .default.nova.conf.num_networks
{{ if not .default.nova.conf.num_networks }}#{{ end }}num_networks = {{ .default.nova.conf.num_networks | default "1" }}

#
# This is the public IP address for the cloudpipe VPN servers. It defaults to
# the
# IP address of the host.
#
# Please note that this option is only used when using nova-network instead of
# Neutron in your deployment. It also will be ignored if the configuration
# option
# for `network_manager` is not set to the default of
# 'nova.network.manager.VlanManager'.
#
# Possible values:
#
#     Any valid IP address. The default is $my_ip, the IP address of the VM.
#
# Related options:
#
#     ``network_manager``, ``use_neutron``, ``vpn_start``
#  (string value)
# from .default.nova.conf.vpn_ip
{{ if not .default.nova.conf.vpn_ip }}#{{ end }}vpn_ip = {{ .default.nova.conf.vpn_ip | default "$my_ip" }}

#
# This is the port number to use as the first VPN port for private networks.
#
# Please note that this option is only used when using nova-network instead of
# Neutron in your deployment. It also will be ignored if the configuration
# option
# for `network_manager` is not set to the default of
# 'nova.network.manager.VlanManager', or if you specify a value the 'vpn_start'
# parameter when creating a network.
#
# Possible values:
#
#     Any integer representing a valid port number. The default is 1000.
#
# Related options:
#
#     ``use_neutron``, ``vpn_ip``, ``network_manager``
#  (port value)
# Minimum value: 0
# Maximum value: 65535
# from .default.nova.conf.vpn_start
{{ if not .default.nova.conf.vpn_start }}#{{ end }}vpn_start = {{ .default.nova.conf.vpn_start | default "1000" }}

#
# This option determines the number of addresses in each private subnet.
#
# Please note that this option is only used when using nova-network instead of
# Neutron in your deployment.
#
# Possible values:
#
#     Any positive integer that is less than or equal to the available network
#     size. Note that if you are creating multiple networks, they must all fit
# in
#     the available IP address space. The default is 256.
#
# Related options:
#
#     ``use_neutron``, ``num_networks``
#  (integer value)
# Minimum value: 1
# from .default.nova.conf.network_size
{{ if not .default.nova.conf.network_size }}#{{ end }}network_size = {{ .default.nova.conf.network_size | default "256" }}

#
# This option determines the fixed IPv6 address block when creating a network.
#
# Please note that this option is only used when using nova-network instead of
# Neutron in your deployment.
#
# Possible values:
#
#     Any valid IPv6 CIDR. The default value is "fd00::/48".
#
# Related options:
#
#     ``use_neutron``
#  (string value)
# from .default.nova.conf.fixed_range_v6
{{ if not .default.nova.conf.fixed_range_v6 }}#{{ end }}fixed_range_v6 = {{ .default.nova.conf.fixed_range_v6 | default "fd00::/48" }}

#
# This is the default IPv4 gateway. It is used only in the testing suite.
#
# Please note that this option is only used when using nova-network instead of
# Neutron in your deployment.
#
# Possible values:
#
#     Any valid IP address.
#
# Related options:
#
#     ``use_neutron``, ``gateway_v6``
#  (string value)
# from .default.nova.conf.gateway
{{ if not .default.nova.conf.gateway }}#{{ end }}gateway = {{ .default.nova.conf.gateway | default "<None>" }}

#
# This is the default IPv6 gateway. It is used only in the testing suite.
#
# Please note that this option is only used when using nova-network instead of
# Neutron in your deployment.
#
# Possible values:
#
#     Any valid IP address.
#
# Related options:
#
#     ``use_neutron``, ``gateway``
#  (string value)
# from .default.nova.conf.gateway_v6
{{ if not .default.nova.conf.gateway_v6 }}#{{ end }}gateway_v6 = {{ .default.nova.conf.gateway_v6 | default "<None>" }}

#
# This option represents the number of IP addresses to reserve at the top of the
# address range for VPN clients. It also will be ignored if the configuration
# option for `network_manager` is not set to the default of
# 'nova.network.manager.VlanManager'.
#
# Possible values:
#
#     Any integer, 0 or greater. The default is 0.
#
# Related options:
#
#     ``use_neutron``, ``network_manager``
#  (integer value)
# Minimum value: 0
# from .default.nova.conf.cnt_vpn_clients
{{ if not .default.nova.conf.cnt_vpn_clients }}#{{ end }}cnt_vpn_clients = {{ .default.nova.conf.cnt_vpn_clients | default "0" }}

#
# This is the number of seconds to wait before disassociating a deallocated
# fixed
# IP address. This is only used with the nova-network service, and has no effect
# when using neutron for networking.
#
# Possible values:
#
#     Any integer, zero or greater. The default is 600 (10 minutes).
#
# Related options:
#
#     ``use_neutron``
#  (integer value)
# Minimum value: 0
# from .default.nova.conf.fixed_ip_disassociate_timeout
{{ if not .default.nova.conf.fixed_ip_disassociate_timeout }}#{{ end }}fixed_ip_disassociate_timeout = {{ .default.nova.conf.fixed_ip_disassociate_timeout | default "600" }}

#
# This option determines how many times nova-network will attempt to create a
# unique MAC address before giving up and raising a
# `VirtualInterfaceMacAddressException` error.
#
# Possible values:
#
#     Any positive integer. The default is 5.
#
# Related options:
#
#     ``use_neutron``
#  (integer value)
# Minimum value: 1
# from .default.nova.conf.create_unique_mac_address_attempts
{{ if not .default.nova.conf.create_unique_mac_address_attempts }}#{{ end }}create_unique_mac_address_attempts = {{ .default.nova.conf.create_unique_mac_address_attempts | default "5" }}

#
# Determines whether unused gateway devices, both VLAN and bridge, are deleted
# if
# the network is in nova-network VLAN mode and is multi-hosted.
#
# Related options:
#
#     ``use_neutron``, ``vpn_ip``, ``fake_network``
#  (boolean value)
# from .default.nova.conf.teardown_unused_network_gateway
{{ if not .default.nova.conf.teardown_unused_network_gateway }}#{{ end }}teardown_unused_network_gateway = {{ .default.nova.conf.teardown_unused_network_gateway | default "false" }}

#
# When this option is True, a call is made to release the DHCP for the instance
# when that instance is terminated.
#
# Related options:
#
#     ``use_neutron``
#  (boolean value)
# from .default.nova.conf.force_dhcp_release
{{ if not .default.nova.conf.force_dhcp_release }}#{{ end }}force_dhcp_release = {{ .default.nova.conf.force_dhcp_release | default "true" }}

#
# When this option is True, whenever a DNS entry must be updated, a fanout cast
# message is sent to all network hosts to update their DNS entries in multi-host
# mode.
#
# Related options:
#
#     ``use_neutron``
#  (boolean value)
# from .default.nova.conf.update_dns_entries
{{ if not .default.nova.conf.update_dns_entries }}#{{ end }}update_dns_entries = {{ .default.nova.conf.update_dns_entries | default "false" }}

#
# This option determines the time, in seconds, to wait between refreshing DNS
# entries for the network.
#
# Possible values:
#
#     Either -1 (default), or any positive integer. A negative value will
# disable
#     the updates.
#
# Related options:
#
#     ``use_neutron``
#  (integer value)
# Minimum value: -1
# from .default.nova.conf.dns_update_periodic_interval
{{ if not .default.nova.conf.dns_update_periodic_interval }}#{{ end }}dns_update_periodic_interval = {{ .default.nova.conf.dns_update_periodic_interval | default "-1" }}

#
# This option allows you to specify the domain for the DHCP server.
#
# Possible values:
#
#     Any string that is a valid domain name.
#
# Related options:
#
#     ``use_neutron``
#  (string value)
# from .default.nova.conf.dhcp_domain
{{ if not .default.nova.conf.dhcp_domain }}#{{ end }}dhcp_domain = {{ .default.nova.conf.dhcp_domain | default "novalocal" }}

#
# This option allows you to specify the L3 management library to be used.
#
# Possible values:
#
#     Any dot-separated string that represents the import path to an L3
#     networking library.
#
# Related options:
#
#     ``use_neutron``
#  (string value)
# from .default.nova.conf.l3_lib
{{ if not .default.nova.conf.l3_lib }}#{{ end }}l3_lib = {{ .default.nova.conf.l3_lib | default "nova.network.l3.LinuxNetL3" }}

# DEPRECATED:
# THIS VALUE SHOULD BE SET WHEN CREATING THE NETWORK.
#
# If True in multi_host mode, all compute hosts share the same dhcp address. The
# same IP address used for DHCP will be added on each nova-network node which is
# only visible to the VMs on the same host.
#
# The use of this configuration has been deprecated and may be removed in any
# release after Mitaka. It is recommended that instead of relying on this
# option,
# an explicit value should be passed to 'create_networks()' as a keyword
# argument
# with the name 'share_address'.
#  (boolean value)
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# from .default.nova.conf.share_dhcp_address
{{ if not .default.nova.conf.share_dhcp_address }}#{{ end }}share_dhcp_address = {{ .default.nova.conf.share_dhcp_address | default "false" }}

# Whether to use Neutron or Nova Network as the back end for networking.
# Defaults to False (indicating Nova network).Set to True to use neutron.
# (boolean value)
# from .default.nova.conf.use_neutron
{{ if not .default.nova.conf.use_neutron }}#{{ end }}use_neutron = {{ .default.nova.conf.use_neutron | default "false" }}

# URL for LDAP server which will store DNS entries (string value)
# from .default.nova.conf.ldap_dns_url
{{ if not .default.nova.conf.ldap_dns_url }}#{{ end }}ldap_dns_url = {{ .default.nova.conf.ldap_dns_url | default "ldap://ldap.example.com:389" }}

# User for LDAP DNS (string value)
# from .default.nova.conf.ldap_dns_user
{{ if not .default.nova.conf.ldap_dns_user }}#{{ end }}ldap_dns_user = {{ .default.nova.conf.ldap_dns_user | default "uid=admin,ou=people,dc=example,dc=org" }}

# Password for LDAP DNS (string value)
# from .default.nova.conf.ldap_dns_password
{{ if not .default.nova.conf.ldap_dns_password }}#{{ end }}ldap_dns_password = {{ .default.nova.conf.ldap_dns_password | default "password" }}

# Hostmaster for LDAP DNS driver Statement of Authority (string value)
# from .default.nova.conf.ldap_dns_soa_hostmaster
{{ if not .default.nova.conf.ldap_dns_soa_hostmaster }}#{{ end }}ldap_dns_soa_hostmaster = {{ .default.nova.conf.ldap_dns_soa_hostmaster | default "hostmaster@example.org" }}

# DNS Servers for LDAP DNS driver (multi valued)
# from .default.nova.conf.ldap_dns_servers (multiopt)
{{ if not .default.nova.conf.ldap_dns_servers }}#ldap_dns_servers = {{ .default.nova.conf.ldap_dns_servers | default "dns.example.org" }}{{ else }}{{ range .default.nova.conf.ldap_dns_servers }}ldap_dns_servers = {{ . }}{{ end }}{{ end }}

# Base DN for DNS entries in LDAP (string value)
# from .default.nova.conf.ldap_dns_base_dn
{{ if not .default.nova.conf.ldap_dns_base_dn }}#{{ end }}ldap_dns_base_dn = {{ .default.nova.conf.ldap_dns_base_dn | default "ou=hosts,dc=example,dc=org" }}

# Refresh interval (in seconds) for LDAP DNS driver Statement of Authority
# (string value)
# from .default.nova.conf.ldap_dns_soa_refresh
{{ if not .default.nova.conf.ldap_dns_soa_refresh }}#{{ end }}ldap_dns_soa_refresh = {{ .default.nova.conf.ldap_dns_soa_refresh | default "1800" }}

# Retry interval (in seconds) for LDAP DNS driver Statement of Authority (string
# value)
# from .default.nova.conf.ldap_dns_soa_retry
{{ if not .default.nova.conf.ldap_dns_soa_retry }}#{{ end }}ldap_dns_soa_retry = {{ .default.nova.conf.ldap_dns_soa_retry | default "3600" }}

# Expiry interval (in seconds) for LDAP DNS driver Statement of Authority
# (string value)
# from .default.nova.conf.ldap_dns_soa_expiry
{{ if not .default.nova.conf.ldap_dns_soa_expiry }}#{{ end }}ldap_dns_soa_expiry = {{ .default.nova.conf.ldap_dns_soa_expiry | default "86400" }}

# Minimum interval (in seconds) for LDAP DNS driver Statement of Authority
# (string value)
# from .default.nova.conf.ldap_dns_soa_minimum
{{ if not .default.nova.conf.ldap_dns_soa_minimum }}#{{ end }}ldap_dns_soa_minimum = {{ .default.nova.conf.ldap_dns_soa_minimum | default "7200" }}

# The topic network nodes listen on (string value)
# from .default.nova.conf.network_topic
{{ if not .default.nova.conf.network_topic }}#{{ end }}network_topic = {{ .default.nova.conf.network_topic | default "network" }}

# Default value for multi_host in networks. Also, if set, some rpc network calls
# will be sent directly to host. (boolean value)
# from .default.nova.conf.multi_host
{{ if not .default.nova.conf.multi_host }}#{{ end }}multi_host = {{ .default.nova.conf.multi_host | default "false" }}

# Driver to use for network creation (string value)
# from .default.nova.conf.network_driver
{{ if not .default.nova.conf.network_driver }}#{{ end }}network_driver = {{ .default.nova.conf.network_driver | default "nova.network.linux_net" }}

#
# If set, send compute.instance.update notifications on instance state
# changes.
#
# Please refer to https://wiki.openstack.org/wiki/SystemUsageData for
# additional information on notifications.
#
# Possible values:
#
# * None - no notifications
# * "vm_state" - notifications on VM state changes
# * "vm_and_task_state" - notifications on VM and task state changes
#  (string value)
# Allowed values: <None>, vm_state, vm_and_task_state
# from .default.nova.conf.notify_on_state_change
{{ if not .default.nova.conf.notify_on_state_change }}#{{ end }}notify_on_state_change = {{ .default.nova.conf.notify_on_state_change | default "<None>" }}

#
# If enabled, send api.fault notifications on caught exceptions in the
# API service.
#  (boolean value)
# from .default.nova.conf.notify_api_faults
{{ if not .default.nova.conf.notify_api_faults }}#{{ end }}notify_api_faults = {{ .default.nova.conf.notify_api_faults | default "false" }}

# Default notification level for outgoing notifications. (string value)
# Allowed values: DEBUG, INFO, WARN, ERROR, CRITICAL
# from .default.nova.conf.default_notification_level
{{ if not .default.nova.conf.default_notification_level }}#{{ end }}default_notification_level = {{ .default.nova.conf.default_notification_level | default "INFO" }}

#
# Default publisher_id for outgoing notifications. If you consider routing
# notifications using different publisher, change this value accordingly.
#
# Possible values:
#
# * Defaults to the IPv4 address of this host, but it can be any valid
#   oslo.messaging publisher_id
#
# Related options:
#
# *  my_ip - IP address of this host
#  (string value)
# from .default.nova.conf.default_publisher_id
{{ if not .default.nova.conf.default_publisher_id }}#{{ end }}default_publisher_id = {{ .default.nova.conf.default_publisher_id | default "$my_ip" }}

#
# Filename that will be used for storing websocket frames received
# and sent by a proxy service (like VNC, spice, serial) running on this host.
# If this is not set, no recording will be done.
#  (string value)
# from .default.nova.conf.record
{{ if not .default.nova.conf.record }}#{{ end }}record = {{ .default.nova.conf.record | default "<None>" }}

# Run as a background process. (boolean value)
# from .default.nova.conf.daemon
{{ if not .default.nova.conf.daemon }}#{{ end }}daemon = {{ .default.nova.conf.daemon | default "false" }}

# Disallow non-encrypted connections. (boolean value)
# from .default.nova.conf.ssl_only
{{ if not .default.nova.conf.ssl_only }}#{{ end }}ssl_only = {{ .default.nova.conf.ssl_only | default "false" }}

# Set to True if source host is addressed with IPv6. (boolean value)
# from .default.nova.conf.source_is_ipv6
{{ if not .default.nova.conf.source_is_ipv6 }}#{{ end }}source_is_ipv6 = {{ .default.nova.conf.source_is_ipv6 | default "false" }}

# Path to SSL certificate file. (string value)
# from .default.nova.conf.cert
{{ if not .default.nova.conf.cert }}#{{ end }}cert = {{ .default.nova.conf.cert | default "self.pem" }}

# SSL key file (if separate from cert). (string value)
# from .default.nova.conf.key
{{ if not .default.nova.conf.key }}#{{ end }}key = {{ .default.nova.conf.key | default "<None>" }}

#
# Path to directory with content which will be served by a web server.
#  (string value)
# from .default.nova.conf.web
{{ if not .default.nova.conf.web }}#{{ end }}web = {{ .default.nova.conf.web | default "/usr/share/spice-html5" }}

#
# The directory where the Nova python modules are installed.
#
# This directory is used to store template files for networking and remote
# console access. It is also the default path for other config options which
# need to persist Nova internal data. It is very unlikely that you need to
# change this option from its default value.
#
# Possible values:
#
# * The full path to a directory.
#
# Related options:
#
# * ``state_path``
#  (string value)
# from .default.nova.conf.pybasedir
{{ if not .default.nova.conf.pybasedir }}#{{ end }}pybasedir = {{ .default.nova.conf.pybasedir | default "/data/alan/Workbench/openstack/nova" }}

#
# The directory where the Nova binaries are installed.
#
# This option is only relevant if the networking capabilities from Nova are
# used (see services below). Nova's networking capabilities are targeted to
# be fully replaced by Neutron in the future. It is very unlikely that you need
# to change this option from its default value.
#
# Possible values:
#
# * The full path to a directory.
#  (string value)
# from .default.nova.conf.bindir
{{ if not .default.nova.conf.bindir }}#{{ end }}bindir = {{ .default.nova.conf.bindir | default "/data/alan/Workbench/openstack/nova/.tox/py27/local/bin" }}

#
# The top-level directory for maintaining Nova's state.
#
# This directory is used to store Nova's internal state. It is used by a
# variety of other config options which derive from this. In some scenarios
# (for example migrations) it makes sense to use a storage location which is
# shared between multiple compute hosts (for example via NFS). Unless the
# option ``instances_path`` gets overwritten, this directory can grow very
# large.
#
# Possible values:
#
# * The full path to a directory. Defaults to value provided in ``pybasedir``.
#  (string value)
# from .default.nova.conf.state_path
{{ if not .default.nova.conf.state_path }}#{{ end }}state_path = {{ .default.nova.conf.state_path | default "$pybasedir" }}

#
# An alias for a PCI passthrough device requirement.
#
# This allows users to specify the alias in the extra_spec for a flavor, without
# needing to repeat all the PCI property requirements.
#
# Possible Values:
#
# * A list of JSON values which describe the aliases. For example:
#
#     pci_alias = {
#       "name": "QuickAssist",
#       "product_id": "0443",
#       "vendor_id": "8086",
#       "device_type": "type-PCI"
#     }
#
#   defines an alias for the Intel QuickAssist card. (multi valued). Valid key
#   values are :
#
#   * "name": Name of the PCI alias.
#   * "product_id": Product ID of the device in hexadecimal.
#   * "vendor_id": Vendor ID of the device in hexadecimal.
#   * "device_type": Type of PCI device. Valid values are: "type-PCI",
#     "type-PF" and "type-VF".
#  (multi valued)
# from .default.nova.conf.pci_alias (multiopt)
{{ if not .default.nova.conf.pci_alias }}#pci_alias = {{ .default.nova.conf.pci_alias | default "" }}{{ else }}{{ range .default.nova.conf.pci_alias }}pci_alias = {{ . }}{{ end }}{{ end }}

#
# White list of PCI devices available to VMs.
#
# Possible values:
#
# * A JSON dictionary which describe a whitelisted PCI device. It should take
#   the following format:
#
#     ["vendor_id": "<id>",] ["product_id": "<id>",]
#     ["address": "[[[[<domain>]:]<bus>]:][<slot>][.[<function>]]" |
#      "devname": "<name>",]
#     {"<tag>": "<tag_value>",}
#
#   Where '[' indicates zero or one occurrences, '{' indicates zero or multiple
#   occurrences, and '|' mutually exclusive options. Note that any missing
#   fields are automatically wildcarded.
#
#   Valid key values are :
#
#   * "vendor_id": Vendor ID of the device in hexadecimal.
#   * "product_id": Product ID of the device in hexadecimal.
#   * "address": PCI address of the device.
#   * "devname": Device name of the device (for e.g. interface name). Not all
#     PCI devices have a name.
#   * "<tag>": Additional <tag> and <tag_value> used for matching PCI devices.
#     Supported <tag>: "physical_network".
#
#   Valid examples are:
#
#     pci_passthrough_whitelist = {"devname":"eth0",
#                                  "physical_network":"physnet"}
#     pci_passthrough_whitelist = {"address":"*:0a:00.*"}
#     pci_passthrough_whitelist = {"address":":0a:00.",
#                                  "physical_network":"physnet1"}
#     pci_passthrough_whitelist = {"vendor_id":"1137",
#                                  "product_id":"0071"}
#     pci_passthrough_whitelist = {"vendor_id":"1137",
#                                  "product_id":"0071",
#                                  "address": "0000:0a:00.1",
#                                  "physical_network":"physnet1"}
#
#   The following are invalid, as they specify mutually exclusive options:
#
#     pci_passthrough_whitelist = {"devname":"eth0",
#                                  "physical_network":"physnet",
#                                  "address":"*:0a:00.*"}
#
# * A JSON list of JSON dictionaries corresponding to the above format. For
#   example:
#
#     pci_passthrough_whitelist = [{"product_id":"0001", "vendor_id":"8086"},
#                                  {"product_id":"0002", "vendor_id":"8086"}]
#  (multi valued)
# from .default.nova.conf.pci_passthrough_whitelist (multiopt)
{{ if not .default.nova.conf.pci_passthrough_whitelist }}#pci_passthrough_whitelist = {{ .default.nova.conf.pci_passthrough_whitelist | default "" }}{{ else }}{{ range .default.nova.conf.pci_passthrough_whitelist }}pci_passthrough_whitelist = {{ . }}{{ end }}{{ end }}

#
# The number of instances allowed per project.
#
# Possible Values
#
#  * 10 (default) or any positive integer.
#  * -1 : treated as unlimited.
#  (integer value)
# Minimum value: -1
# from .default.nova.conf.quota_instances
{{ if not .default.nova.conf.quota_instances }}#{{ end }}quota_instances = {{ .default.nova.conf.quota_instances | default "10" }}

#
# The number of instance cores or VCPUs allowed per project.
#
# Possible values:
#
#  * 20 (default) or any positive integer.
#  * -1 : treated as unlimited.
#  (integer value)
# Minimum value: -1
# from .default.nova.conf.quota_cores
{{ if not .default.nova.conf.quota_cores }}#{{ end }}quota_cores = {{ .default.nova.conf.quota_cores | default "20" }}

#
# The number of megabytes of instance RAM allowed per project.
#
# Possible values:
#
#  * 51200 (default) or any positive integer.
#  * -1 : treated as unlimited.
#  (integer value)
# Minimum value: -1
# from .default.nova.conf.quota_ram
{{ if not .default.nova.conf.quota_ram }}#{{ end }}quota_ram = {{ .default.nova.conf.quota_ram | default "51200" }}

#
# The number of floating IPs allowed per project. Floating IPs are not allocated
# to instances by default. Users need to select them from the pool configured by
# the OpenStack administrator to attach to their instances.
#
# Possible values:
#
#  * 10 (default) or any positive integer.
#  * -1 : treated as unlimited.
#  (integer value)
# Minimum value: -1
# from .default.nova.conf.quota_floating_ips
{{ if not .default.nova.conf.quota_floating_ips }}#{{ end }}quota_floating_ips = {{ .default.nova.conf.quota_floating_ips | default "10" }}

#
# The number of fixed IPs allowed per project (this should be at least the
# number
# of instances allowed). Unlike floating IPs, fixed IPs are allocated
# dynamically
# by the network component when instances boot up.
#
# Possible values:
#
#  * -1 (default) : treated as unlimited.
#  * Any positive integer.
#  (integer value)
# Minimum value: -1
# from .default.nova.conf.quota_fixed_ips
{{ if not .default.nova.conf.quota_fixed_ips }}#{{ end }}quota_fixed_ips = {{ .default.nova.conf.quota_fixed_ips | default "-1" }}

#
# The number of metadata items allowed per instance. User can associate metadata
# while instance creation in the form of key-value pairs.
#
# Possible values:
#
#  * 128 (default) or any positive integer.
#  * -1 : treated as unlimited.
#  (integer value)
# Minimum value: -1
# from .default.nova.conf.quota_metadata_items
{{ if not .default.nova.conf.quota_metadata_items }}#{{ end }}quota_metadata_items = {{ .default.nova.conf.quota_metadata_items | default "128" }}

#
# The number of injected files allowed. It allow users to customize the
# personality of an instance by injecting data into it upon boot. Only text
# file injection is permitted. Binary or zip files won't work. During file
# injection, any existing files that match specified files are renamed to
# include
# .bak extension appended with a timestamp.
#
# Possible values:
#
#  * 5 (default) or any positive integer.
#  * -1 : treated as unlimited.
#  (integer value)
# Minimum value: -1
# from .default.nova.conf.quota_injected_files
{{ if not .default.nova.conf.quota_injected_files }}#{{ end }}quota_injected_files = {{ .default.nova.conf.quota_injected_files | default "5" }}

#
# The number of bytes allowed per injected file.
#
# Possible values:
#
#  * 10240 (default) or any positive integer representing number of bytes.
#  * -1 : treated as unlimited.
#  (integer value)
# Minimum value: -1
# from .default.nova.conf.quota_injected_file_content_bytes
{{ if not .default.nova.conf.quota_injected_file_content_bytes }}#{{ end }}quota_injected_file_content_bytes = {{ .default.nova.conf.quota_injected_file_content_bytes | default "10240" }}

#
# The maximum allowed injected file path length.
#
# Possible values:
#
#  * 255 (default) or any positive integer.
#  * -1 : treated as unlimited.
#  (integer value)
# Minimum value: -1
# from .default.nova.conf.quota_injected_file_path_length
{{ if not .default.nova.conf.quota_injected_file_path_length }}#{{ end }}quota_injected_file_path_length = {{ .default.nova.conf.quota_injected_file_path_length | default "255" }}

#
# The number of security groups per project.
#
# Possible values:
#
#  * 10 (default) or any positive integer.
#  * -1 : treated as unlimited.
#  (integer value)
# Minimum value: -1
# from .default.nova.conf.quota_security_groups
{{ if not .default.nova.conf.quota_security_groups }}#{{ end }}quota_security_groups = {{ .default.nova.conf.quota_security_groups | default "10" }}

#
# The number of security rules per security group. The associated rules in each
# security group control the traffic to instances in the group.
#
# Possible values:
#
#  * 20 (default) or any positive integer.
#  * -1 : treated as unlimited.
#  (integer value)
# Minimum value: -1
# from .default.nova.conf.quota_security_group_rules
{{ if not .default.nova.conf.quota_security_group_rules }}#{{ end }}quota_security_group_rules = {{ .default.nova.conf.quota_security_group_rules | default "20" }}

#
# The maximum number of key pairs allowed per user. Users can create at least
# one
# key pair for each project and use the key pair for multiple instances that
# belong to that project.
#
# Possible values:
#
#  * 100 (default) or any positive integer.
#  * -1 : treated as unlimited.
#  (integer value)
# Minimum value: -1
# from .default.nova.conf.quota_key_pairs
{{ if not .default.nova.conf.quota_key_pairs }}#{{ end }}quota_key_pairs = {{ .default.nova.conf.quota_key_pairs | default "100" }}

#
# Add quota values to constrain the number of server groups per project. Server
# group used to control the affinity and anti-affinity scheduling policy for a
# group of servers or instances. Reducing the quota will not affect any existing
# group, but new servers will not be allowed into groups that have become over
# quota.
#
# Possible values:
#
#  * 10 (default) or any positive integer.
#  * -1 : treated as unlimited.
#  (integer value)
# Minimum value: -1
# from .default.nova.conf.quota_server_groups
{{ if not .default.nova.conf.quota_server_groups }}#{{ end }}quota_server_groups = {{ .default.nova.conf.quota_server_groups | default "10" }}

#
# Add quota values to constrain the number of servers per server group.
#
# Possible values:
#
#  * 10 (default) or any positive integer.
#  * -1 : treated as unlimited.
#  (integer value)
# Minimum value: -1
# from .default.nova.conf.quota_server_group_members
{{ if not .default.nova.conf.quota_server_group_members }}#{{ end }}quota_server_group_members = {{ .default.nova.conf.quota_server_group_members | default "10" }}

#
# The number of seconds until a reservation expires. It represents the time
# period for invalidating quota reservations.
#
# Possible values:
#
#  * 86400 (default) or any positive integer representing number of seconds.
#  (integer value)
# from .default.nova.conf.reservation_expire
{{ if not .default.nova.conf.reservation_expire }}#{{ end }}reservation_expire = {{ .default.nova.conf.reservation_expire | default "86400" }}

#
# The count of reservations until usage is refreshed. This defaults to 0 (off)
# to
# avoid additional load but it is useful to turn on to help keep quota usage
# up-to-date and reduce the impact of out of sync usage issues.
#
# Possible values:
#
#  * 0 (default) or any positive integer.
#  (integer value)
# Minimum value: 0
# from .default.nova.conf.until_refresh
{{ if not .default.nova.conf.until_refresh }}#{{ end }}until_refresh = {{ .default.nova.conf.until_refresh | default "0" }}

#
# The number of seconds between subsequent usage refreshes. This defaults to 0
# (off) to avoid additional load but it is useful to turn on to help keep quota
# usage up-to-date and reduce the impact of out of sync usage issues. Note that
# quotas are not updated on a periodic task, they will update on a new
# reservation if max_age has passed since the last reservation.
#
# Possible values:
#
#  * 0 (default) or any positive integer representing number of seconds.
#  (integer value)
# Minimum value: 0
# from .default.nova.conf.max_age
{{ if not .default.nova.conf.max_age }}#{{ end }}max_age = {{ .default.nova.conf.max_age | default "0" }}

# DEPRECATED:
# Provides abstraction for quota checks. Users can configure a specific
# driver to use for quota checks.
#
# Possible values:
#
#  * nova.quota.DbQuotaDriver (default) or any string representing fully
#    qualified class name.
#  (string value)
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# from .default.nova.conf.quota_driver
{{ if not .default.nova.conf.quota_driver }}#{{ end }}quota_driver = {{ .default.nova.conf.quota_driver | default "nova.quota.DbQuotaDriver" }}

# Specifies which notification format shall be used by nova.
#
# The default value is fine for most deployments and rarely needs to be changed.
# This value can be set to 'versioned' once the infrastructure moves closer to
# consuming the newer format of notifications. After this occurs, this option
# will be removed (possibly in the "P" release).
#
# Possible values:
# * unversioned: Only the legacy unversioned notifications are emitted.
# * versioned: Only the new versioned notifications are emitted.
# * both: Both the legacy unversioned and the new versioned notifications are
#   emitted. (Default)
#
# The list of versioned notifications is visible in
# http://docs.openstack.org/developer/nova/notifications.html
#
# Related options:
#
# * None (string value)
# Allowed values: unversioned, versioned, both
# from .default.nova.conf.notification_format
{{ if not .default.nova.conf.notification_format }}#{{ end }}notification_format = {{ .default.nova.conf.notification_format | default "both" }}

# DEPRECATED:
# Parent directory for tempdir used for image decryption
#  (string value)
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# Reason: EC2 API related options are not supported.
# from .default.nova.conf.image_decryption_dir
{{ if not .default.nova.conf.image_decryption_dir }}#{{ end }}image_decryption_dir = {{ .default.nova.conf.image_decryption_dir | default "/tmp" }}

# DEPRECATED:
# Hostname or IP for OpenStack to use when accessing the S3 API
#  (string value)
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# Reason: EC2 API related options are not supported.
# from .default.nova.conf.s3_host
{{ if not .default.nova.conf.s3_host }}#{{ end }}s3_host = {{ .default.nova.conf.s3_host | default "$my_ip" }}

# DEPRECATED:
# Port used when accessing the S3 API. It should be in the range of
# 1 - 65535
#  (port value)
# Minimum value: 0
# Maximum value: 65535
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# Reason: EC2 API related options are not supported.
# from .default.nova.conf.s3_port
{{ if not .default.nova.conf.s3_port }}#{{ end }}s3_port = {{ .default.nova.conf.s3_port | default "3333" }}

# DEPRECATED: Access key to use S3 server for images (string value)
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# Reason: EC2 API related options are not supported.
# from .default.nova.conf.s3_access_key
{{ if not .default.nova.conf.s3_access_key }}#{{ end }}s3_access_key = {{ .default.nova.conf.s3_access_key | default "notchecked" }}

# DEPRECATED: Secret key to use for S3 server for images (string value)
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# Reason: EC2 API related options are not supported.
# from .default.nova.conf.s3_secret_key
{{ if not .default.nova.conf.s3_secret_key }}#{{ end }}s3_secret_key = {{ .default.nova.conf.s3_secret_key | default "notchecked" }}

# DEPRECATED: Whether to use SSL when talking to S3 (boolean value)
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# Reason: EC2 API related options are not supported.
# from .default.nova.conf.s3_use_ssl
{{ if not .default.nova.conf.s3_use_ssl }}#{{ end }}s3_use_ssl = {{ .default.nova.conf.s3_use_ssl | default "false" }}

# DEPRECATED:
# Whether to affix the tenant id to the access key when downloading from S3
#  (boolean value)
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# Reason: EC2 API related options are not supported.
# from .default.nova.conf.s3_affix_tenant
{{ if not .default.nova.conf.s3_affix_tenant }}#{{ end }}s3_affix_tenant = {{ .default.nova.conf.s3_affix_tenant | default "false" }}

#
# New instances will be scheduled on a host chosen randomly from a subset of the
# N best hosts, where N is the value set by this option.  Valid values are 1 or
# greater. Any value less than one will be treated as 1.
#
# Setting this to a value greater than 1 will reduce the chance that multiple
# scheduler processes handling similar requests will select the same host,
# creating a potential race condition. By selecting a host randomly from the N
# hosts that best fit the request, the chance of a conflict is reduced. However,
# the higher you set this value, the less optimal the chosen host may be for a
# given request.
#
# This option is only used by the FilterScheduler and its subclasses; if you use
# a different scheduler, this option has no effect.
#
# * Related options:
#
#     None
#  (integer value)
# from .default.nova.conf.scheduler_host_subset_size
{{ if not .default.nova.conf.scheduler_host_subset_size }}#{{ end }}scheduler_host_subset_size = {{ .default.nova.conf.scheduler_host_subset_size | default "1" }}

#
# This option specifies the filters used for filtering baremetal hosts. The
# value
# should be a list of strings, with each string being the name of a filter class
# to be used. When used, they will be applied in order, so place your most
# restrictive filters first to make the filtering process more efficient.
#
# This option is only used by the FilterScheduler and its subclasses; if you use
# a different scheduler, this option has no effect.
#
# * Related options:
#
#     If the 'scheduler_use_baremetal_filters' option is False, this option has
#     no effect.
#  (list value)
# from .default.nova.conf.baremetal_scheduler_default_filters
{{ if not .default.nova.conf.baremetal_scheduler_default_filters }}#{{ end }}baremetal_scheduler_default_filters = {{ .default.nova.conf.baremetal_scheduler_default_filters | default "RetryFilter,AvailabilityZoneFilter,ComputeFilter,ComputeCapabilitiesFilter,ImagePropertiesFilter,ExactRamFilter,ExactDiskFilter,ExactCoreFilter" }}

#
# Set this to True to tell the nova scheduler that it should use the filters
# specified in the 'baremetal_scheduler_default_filters' option. If you are not
# scheduling baremetal nodes, leave this at the default setting of False.
#
# This option is only used by the FilterScheduler and its subclasses; if you use
# a different scheduler, this option has no effect.
#
# * Related options:
#
#     If this option is set to True, then the filters specified in the
#     'baremetal_scheduler_default_filters' are used instead of the filters
#     specified in 'scheduler_default_filters'.
#  (boolean value)
# from .default.nova.conf.scheduler_use_baremetal_filters
{{ if not .default.nova.conf.scheduler_use_baremetal_filters }}#{{ end }}scheduler_use_baremetal_filters = {{ .default.nova.conf.scheduler_use_baremetal_filters | default "false" }}

#
# This is an unordered list of the filter classes the Nova scheduler may apply.
# Only the filters specified in the 'scheduler_default_filters' option will be
# used, but any filter appearing in that option must also be included in this
# list.
#
# By default, this is set to all filters that are included with Nova. If you
# wish
# to change this, replace this with a list of strings, where each element is the
# path to a filter.
#
# This option is only used by the FilterScheduler and its subclasses; if you use
# a different scheduler, this option has no effect.
#
# * Related options:
#
#     scheduler_default_filters
#  (multi valued)
# from .default.nova.conf.scheduler_available_filters (multiopt)
{{ if not .default.nova.conf.scheduler_available_filters }}#scheduler_available_filters = {{ .default.nova.conf.scheduler_available_filters | default "nova.scheduler.filters.all_filters" }}{{ else }}{{ range .default.nova.conf.scheduler_available_filters }}scheduler_available_filters = {{ . }}{{ end }}{{ end }}

#
# This option is the list of filter class names that will be used for filtering
# hosts. The use of 'default' in the name of this option implies that other
# filters may sometimes be used, but that is not the case. These filters will be
# applied in the order they are listed, so place your most restrictive filters
# first to make the filtering process more efficient.
#
# This option is only used by the FilterScheduler and its subclasses; if you use
# a different scheduler, this option has no effect.
#
# * Related options:
#
#     All of the filters in this option *must* be present in the
#     'scheduler_available_filters' option, or a SchedulerHostFilterNotFound
#     exception will be raised.
#  (list value)
# from .default.nova.conf.scheduler_default_filters
{{ if not .default.nova.conf.scheduler_default_filters }}#{{ end }}scheduler_default_filters = {{ .default.nova.conf.scheduler_default_filters | default "RetryFilter,AvailabilityZoneFilter,RamFilter,DiskFilter,ComputeFilter,ComputeCapabilitiesFilter,ImagePropertiesFilter,ServerGroupAntiAffinityFilter,ServerGroupAffinityFilter" }}

#
# This is a list of weigher class names. Only hosts which pass the filters are
# weighed. The weight for any host starts at 0, and the weighers order these
# hosts by adding to or subtracting from the weight assigned by the previous
# weigher. Weights may become negative.
#
# An instance will be scheduled to one of the N most-weighted hosts, where N is
# 'scheduler_host_subset_size'.
#
# By default, this is set to all weighers that are included with Nova. If you
# wish to change this, replace this with a list of strings, where each element
# is
# the path to a weigher.
#
# This option is only used by the FilterScheduler and its subclasses; if you use
# a different scheduler, this option has no effect.
#
# * Related options:
#
#     None
#  (list value)
# from .default.nova.conf.scheduler_weight_classes
{{ if not .default.nova.conf.scheduler_weight_classes }}#{{ end }}scheduler_weight_classes = {{ .default.nova.conf.scheduler_weight_classes | default "nova.scheduler.weights.all_weighers" }}

#
# The scheduler may need information about the instances on a host in order to
# evaluate its filters and weighers. The most common need for this information
# is
# for the (anti-)affinity filters, which need to choose a host based on the
# instances already running on a host.
#
# If the configured filters and weighers do not need this information, disabling
# this option will improve performance. It may also be disabled when the
# tracking
# overhead proves too heavy, although this will cause classes requiring host
# usage data to query the database on each request instead.
#
# This option is only used by the FilterScheduler and its subclasses; if you use
# a different scheduler, this option has no effect.
#
# * Related options:
#
#     None
#  (boolean value)
# from .default.nova.conf.scheduler_tracks_instance_changes
{{ if not .default.nova.conf.scheduler_tracks_instance_changes }}#{{ end }}scheduler_tracks_instance_changes = {{ .default.nova.conf.scheduler_tracks_instance_changes | default "true" }}

#
# This is the message queue topic that the scheduler 'listens' on. It is used
# when the scheduler service is started up to configure the queue, and whenever
# an RPC call to the scheduler is made. There is almost never any reason to ever
# change this value.
#
# * Related options:
#
#     None
#  (string value)
# from .default.nova.conf.scheduler_topic
{{ if not .default.nova.conf.scheduler_topic }}#{{ end }}scheduler_topic = {{ .default.nova.conf.scheduler_topic | default "scheduler" }}

#
# The scheduler host manager to use, which manages the in-memory picture of the
# hosts that the scheduler uses.
#
# The option value should be chosen from one of the entrypoints under the
# namespace 'nova.scheduler.host_manager' of file 'setup.cfg'. For example,
# 'host_manager' is the default setting. Aside from the default, the only other
# option as of the Mitaka release is 'ironic_host_manager', which should be used
# if you're using Ironic to provision bare-metal instances.
#
# * Related options:
#
#     None
#  (string value)
# Allowed values: host_manager, ironic_host_manager
# from .default.nova.conf.scheduler_host_manager
{{ if not .default.nova.conf.scheduler_host_manager }}#{{ end }}scheduler_host_manager = {{ .default.nova.conf.scheduler_host_manager | default "host_manager" }}

#
# The class of the driver used by the scheduler. This should be chosen from one
# of the entrypoints under the namespace 'nova.scheduler.driver' of file
# 'setup.cfg'. If nothing is specified in this option, the 'filter_scheduler' is
# used.
#
# This option also supports deprecated full Python path to the class to be used.
# For example, "nova.scheduler.filter_scheduler.FilterScheduler". But note: this
# support will be dropped in the N Release.
#
# Other options are:
#
#     * 'caching_scheduler' which aggressively caches the system state for
# better
#     individual scheduler performance at the risk of more retries when running
#     multiple schedulers.
#
#     * 'chance_scheduler' which simply picks a host at random.
#
#     * 'fake_scheduler' which is used for testing.
#
# * Related options:
#
#     None
#  (string value)
# from .default.nova.conf.scheduler_driver
{{ if not .default.nova.conf.scheduler_driver }}#{{ end }}scheduler_driver = {{ .default.nova.conf.scheduler_driver | default "filter_scheduler" }}

#
# This value controls how often (in seconds) to run periodic tasks in the
# scheduler. The specific tasks that are run for each period are determined by
# the particular scheduler being used.
#
# If this is larger than the nova-service 'service_down_time' setting, Nova may
# report the scheduler service as down. This is because the scheduler driver is
# responsible for sending a heartbeat and it will only do that as often as this
# option allows. As each scheduler can work a little differently than the
# others,
# be sure to test this with your selected scheduler.
#
# * Related options:
#
#     ``nova-service service_down_time``
#  (integer value)
# from .default.nova.conf.scheduler_driver_task_period
{{ if not .default.nova.conf.scheduler_driver_task_period }}#{{ end }}scheduler_driver_task_period = {{ .default.nova.conf.scheduler_driver_task_period | default "60" }}

#
# The absolute path to the scheduler configuration JSON file, if any. This file
# location is monitored by the scheduler for changes and reloads it if needed.
# It
# is converted from JSON to a Python data structure, and passed into the
# filtering and weighing functions of the scheduler, which can use it for
# dynamic
# configuration.
#
# * Related options:
#
#     None
#  (string value)
# from .default.nova.conf.scheduler_json_config_location
{{ if not .default.nova.conf.scheduler_json_config_location }}#{{ end }}scheduler_json_config_location = {{ .default.nova.conf.scheduler_json_config_location | default "" }}

#
# If there is a need to restrict some images to only run on certain designated
# hosts, list those image UUIDs here.
#
# This option is only used by the FilterScheduler and its subclasses; if you use
# a different scheduler, this option has no effect. Also note that this setting
# only affects scheduling if the 'IsolatedHostsFilter' filter is enabled.
#
# * Related options:
#
#     scheduler/isolated_hosts
#     scheduler/restrict_isolated_hosts_to_isolated_images
#  (list value)
# from .default.nova.conf.isolated_images
{{ if not .default.nova.conf.isolated_images }}#{{ end }}isolated_images = {{ .default.nova.conf.isolated_images | default "" }}

#
# If there is a need to restrict some images to only run on certain designated
# hosts, list those host names here.
#
# This option is only used by the FilterScheduler and its subclasses; if you use
# a different scheduler, this option has no effect. Also note that this setting
# only affects scheduling if the 'IsolatedHostsFilter' filter is enabled.
#
# * Related options:
#
#     scheduler/isolated_images
#     scheduler/restrict_isolated_hosts_to_isolated_images
#  (list value)
# from .default.nova.conf.isolated_hosts
{{ if not .default.nova.conf.isolated_hosts }}#{{ end }}isolated_hosts = {{ .default.nova.conf.isolated_hosts | default "" }}

#
# This setting determines if the scheduler's isolated_hosts filter will allow
# non-isolated images on a host designated as an isolated host. When set to True
# (the default), non-isolated images will not be allowed to be built on isolated
# hosts. When False, non-isolated images can be built on both isolated and
# non-isolated hosts alike.
#
# This option is only used by the FilterScheduler and its subclasses; if you use
# a different scheduler, this option has no effect. Also note that this setting
# only affects scheduling if the 'IsolatedHostsFilter' filter is enabled. Even
# then, this option doesn't affect the behavior of requests for isolated images,
# which will *always* be restricted to isolated hosts.
#
# * Related options:
#
#     scheduler/isolated_images
#     scheduler/isolated_hosts
#  (boolean value)
# from .default.nova.conf.restrict_isolated_hosts_to_isolated_images
{{ if not .default.nova.conf.restrict_isolated_hosts_to_isolated_images }}#{{ end }}restrict_isolated_hosts_to_isolated_images = {{ .default.nova.conf.restrict_isolated_hosts_to_isolated_images | default "true" }}

#
# This setting caps the number of instances on a host that can be actively
# performing IO (in a build, resize, snapshot, migrate, rescue, or unshelve task
# state) before that host becomes ineligible to build new instances.
#
# Valid values are positive integers: 1 or greater.
#
# This option is only used by the FilterScheduler and its subclasses; if you use
# a different scheduler, this option has no effect. Also note that this setting
# only affects scheduling if the 'io_ops_filter' filter is enabled.
#
# * Related options:
#
#     None
#  (integer value)
# from .default.nova.conf.max_io_ops_per_host
{{ if not .default.nova.conf.max_io_ops_per_host }}#{{ end }}max_io_ops_per_host = {{ .default.nova.conf.max_io_ops_per_host | default "8" }}

#
# Images and hosts can be configured so that certain images can only be
# scheduled
# to hosts in a particular aggregate. This is done with metadata values set on
# the host aggregate that are identified by beginning with the value of this
# option. If the host is part of an aggregate with such a metadata key, the
# image
# in the request spec must have the value of that metadata in its properties in
# order for the scheduler to consider the host as acceptable.
#
# Valid values are strings.
#
# This option is only used by the FilterScheduler and its subclasses; if you use
# a different scheduler, this option has no effect. Also note that this setting
# only affects scheduling if the 'aggregate_image_properties_isolation' filter
# is
# enabled.
#
# * Related options:
#
#     aggregate_image_properties_isolation_separator
#  (string value)
# from .default.nova.conf.aggregate_image_properties_isolation_namespace
{{ if not .default.nova.conf.aggregate_image_properties_isolation_namespace }}#{{ end }}aggregate_image_properties_isolation_namespace = {{ .default.nova.conf.aggregate_image_properties_isolation_namespace | default "<None>" }}

#
# When using the aggregate_image_properties_isolation filter, the relevant
# metadata keys are prefixed with the namespace defined in the
# aggregate_image_properties_isolation_namespace configuration option plus a
# separator. This option defines the separator to be used. It defaults to a
# period ('.').
#
# Valid values are strings.
#
# This option is only used by the FilterScheduler and its subclasses; if you use
# a different scheduler, this option has no effect. Also note that this setting
# only affects scheduling if the 'aggregate_image_properties_isolation' filter
# is
# enabled.
#
# * Related options:
#
#     aggregate_image_properties_isolation_namespace
#  (string value)
# from .default.nova.conf.aggregate_image_properties_isolation_separator
{{ if not .default.nova.conf.aggregate_image_properties_isolation_separator }}#{{ end }}aggregate_image_properties_isolation_separator = {{ .default.nova.conf.aggregate_image_properties_isolation_separator | default "." }}

#
# If you need to limit the number of instances on any given host, set this
# option
# to the maximum number of instances you want to allow. The num_instances_filter
# will reject any host that has at least as many instances as this option's
# value.
#
# Valid values are positive integers; setting it to zero will cause all hosts to
# be rejected if the num_instances_filter is active.
#
# This option is only used by the FilterScheduler and its subclasses; if you use
# a different scheduler, this option has no effect. Also note that this setting
# only affects scheduling if the 'num_instances_filter' filter is enabled.
#
# * Related options:
#
#     None
#  (integer value)
# from .default.nova.conf.max_instances_per_host
{{ if not .default.nova.conf.max_instances_per_host }}#{{ end }}max_instances_per_host = {{ .default.nova.conf.max_instances_per_host | default "50" }}

#
# This option determines how hosts with more or less available RAM are weighed.
# A
# positive value will result in the scheduler preferring hosts with more
# available RAM, and a negative number will result in the scheduler preferring
# hosts with less available RAM. Another way to look at it is that positive
# values for this option will tend to spread instances across many hosts, while
# negative values will tend to fill up (stack) hosts as much as possible before
# scheduling to a less-used host. The absolute value, whether positive or
# negative, controls how strong the RAM weigher is relative to other weighers.
#
# This option is only used by the FilterScheduler and its subclasses; if you use
# a different scheduler, this option has no effect. Also note that this setting
# only affects scheduling if the 'ram' weigher is enabled.
#
# Valid values are numeric, either integer or float.
#
# * Related options:
#
#     None
#  (floating point value)
# from .default.nova.conf.ram_weight_multiplier
{{ if not .default.nova.conf.ram_weight_multiplier }}#{{ end }}ram_weight_multiplier = {{ .default.nova.conf.ram_weight_multiplier | default "1.0" }}

# Multiplier used for weighing free disk space. Negative numbers mean to stack
# vs spread. (floating point value)
# from .default.nova.conf.disk_weight_multiplier
{{ if not .default.nova.conf.disk_weight_multiplier }}#{{ end }}disk_weight_multiplier = {{ .default.nova.conf.disk_weight_multiplier | default "1.0" }}

#
# This option determines how hosts with differing workloads are weighed.
# Negative
# values, such as the default, will result in the scheduler preferring hosts
# with
# lighter workloads whereas positive values will prefer hosts with heavier
# workloads. Another way to look at it is that positive values for this option
# will tend to schedule instances onto hosts that are already busy, while
# negative values will tend to distribute the workload across more hosts. The
# absolute value, whether positive or negative, controls how strong the io_ops
# weigher is relative to other weighers.
#
# This option is only used by the FilterScheduler and its subclasses; if you use
# a different scheduler, this option has no effect. Also note that this setting
# only affects scheduling if the 'io_ops' weigher is enabled.
#
# Valid values are numeric, either integer or float.
#
# * Related options:
#
#     None
#  (floating point value)
# from .default.nova.conf.io_ops_weight_multiplier
{{ if not .default.nova.conf.io_ops_weight_multiplier }}#{{ end }}io_ops_weight_multiplier = {{ .default.nova.conf.io_ops_weight_multiplier | default "-1.0" }}

#
# This is the maximum number of attempts that will be made to schedule an
# instance before it is assumed that the failures aren't due to normal
# occasional
# race conflicts, but rather some other problem. When this is reached a
# MaxRetriesExceeded exception is raised, and the instance is set to an error
# state.
#
# Valid values are positive integers (1 or greater).
#
# * Related options:
#
#     None
#  (integer value)
# from .default.nova.conf.scheduler_max_attempts
{{ if not .default.nova.conf.scheduler_max_attempts }}#{{ end }}scheduler_max_attempts = {{ .default.nova.conf.scheduler_max_attempts | default "3" }}

# Multiplier used for weighing hosts for group soft-affinity. Only a positive
# value is meaningful. Negative means that the behavior will change to the
# opposite, which is soft-anti-affinity. (floating point value)
# from .default.nova.conf.soft_affinity_weight_multiplier
{{ if not .default.nova.conf.soft_affinity_weight_multiplier }}#{{ end }}soft_affinity_weight_multiplier = {{ .default.nova.conf.soft_affinity_weight_multiplier | default "1.0" }}

# Multiplier used for weighing hosts for group soft-anti-affinity. Only a
# positive value is meaningful. Negative means that the behavior will change to
# the opposite, which is soft-affinity. (floating point value)
# from .default.nova.conf.soft_anti_affinity_weight_multiplier
{{ if not .default.nova.conf.soft_anti_affinity_weight_multiplier }}#{{ end }}soft_anti_affinity_weight_multiplier = {{ .default.nova.conf.soft_anti_affinity_weight_multiplier | default "1.0" }}

# Seconds between nodes reporting state to datastore (integer value)
# from .default.nova.conf.report_interval
{{ if not .default.nova.conf.report_interval }}#{{ end }}report_interval = {{ .default.nova.conf.report_interval | default "10" }}

# Enable periodic tasks (boolean value)
# from .default.nova.conf.periodic_enable
{{ if not .default.nova.conf.periodic_enable }}#{{ end }}periodic_enable = {{ .default.nova.conf.periodic_enable | default "true" }}

# Range of seconds to randomly delay when starting the periodic task scheduler
# to reduce stampeding. (Disable by setting to 0) (integer value)
# from .default.nova.conf.periodic_fuzzy_delay
{{ if not .default.nova.conf.periodic_fuzzy_delay }}#{{ end }}periodic_fuzzy_delay = {{ .default.nova.conf.periodic_fuzzy_delay | default "60" }}

# A list of APIs to enable by default (list value)
# from .default.nova.conf.enabled_apis
{{ if not .default.nova.conf.enabled_apis }}#{{ end }}enabled_apis = {{ .default.nova.conf.enabled_apis | default "osapi_compute,metadata" }}

# A list of APIs with enabled SSL (list value)
# from .default.nova.conf.enabled_ssl_apis
{{ if not .default.nova.conf.enabled_ssl_apis }}#{{ end }}enabled_ssl_apis = {{ .default.nova.conf.enabled_ssl_apis | default "" }}

# The IP address on which the OpenStack API will listen. (string value)
# from .default.nova.conf.osapi_compute_listen
{{ if not .default.nova.conf.osapi_compute_listen }}#{{ end }}osapi_compute_listen = {{ .default.nova.conf.osapi_compute_listen | default "0.0.0.0" }}

# The port on which the OpenStack API will listen. (port value)
# Minimum value: 0
# Maximum value: 65535
# from .default.nova.conf.osapi_compute_listen_port
{{ if not .default.nova.conf.osapi_compute_listen_port }}#{{ end }}osapi_compute_listen_port = {{ .default.nova.conf.osapi_compute_listen_port | default "8774" }}

# Number of workers for OpenStack API service. The default will be the number of
# CPUs available. (integer value)
# from .default.nova.conf.osapi_compute_workers
{{ if not .default.nova.conf.osapi_compute_workers }}#{{ end }}osapi_compute_workers = {{ .default.nova.conf.osapi_compute_workers | default "<None>" }}

# DEPRECATED: OpenStack metadata service manager (string value)
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# from .default.nova.conf.metadata_manager
{{ if not .default.nova.conf.metadata_manager }}#{{ end }}metadata_manager = {{ .default.nova.conf.metadata_manager | default "nova.api.manager.MetadataManager" }}

# The IP address on which the metadata API will listen. (string value)
# from .default.nova.conf.metadata_listen
{{ if not .default.nova.conf.metadata_listen }}#{{ end }}metadata_listen = {{ .default.nova.conf.metadata_listen | default "0.0.0.0" }}

# The port on which the metadata API will listen. (port value)
# Minimum value: 0
# Maximum value: 65535
# from .default.nova.conf.metadata_listen_port
{{ if not .default.nova.conf.metadata_listen_port }}#{{ end }}metadata_listen_port = {{ .default.nova.conf.metadata_listen_port | default "8775" }}

# Number of workers for metadata service. The default will be the number of CPUs
# available. (integer value)
# from .default.nova.conf.metadata_workers
{{ if not .default.nova.conf.metadata_workers }}#{{ end }}metadata_workers = {{ .default.nova.conf.metadata_workers | default "<None>" }}

# DEPRECATED: Full class name for the Manager for compute (string value)
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# from .default.nova.conf.compute_manager
{{ if not .default.nova.conf.compute_manager }}#{{ end }}compute_manager = {{ .default.nova.conf.compute_manager | default "nova.compute.manager.ComputeManager" }}

# DEPRECATED: Full class name for the Manager for console proxy (string value)
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# from .default.nova.conf.console_manager
{{ if not .default.nova.conf.console_manager }}#{{ end }}console_manager = {{ .default.nova.conf.console_manager | default "nova.console.manager.ConsoleProxyManager" }}

# DEPRECATED: Manager for console auth (string value)
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# from .default.nova.conf.consoleauth_manager
{{ if not .default.nova.conf.consoleauth_manager }}#{{ end }}consoleauth_manager = {{ .default.nova.conf.consoleauth_manager | default "nova.consoleauth.manager.ConsoleAuthManager" }}

# DEPRECATED: Full class name for the Manager for cert (string value)
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# from .default.nova.conf.cert_manager
{{ if not .default.nova.conf.cert_manager }}#{{ end }}cert_manager = {{ .default.nova.conf.cert_manager | default "nova.cert.manager.CertManager" }}

# Full class name for the Manager for network (string value)
# from .default.nova.conf.network_manager
{{ if not .default.nova.conf.network_manager }}#{{ end }}network_manager = {{ .default.nova.conf.network_manager | default "nova.network.manager.VlanManager" }}

# DEPRECATED: Full class name for the Manager for scheduler (string value)
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# from .default.nova.conf.scheduler_manager
{{ if not .default.nova.conf.scheduler_manager }}#{{ end }}scheduler_manager = {{ .default.nova.conf.scheduler_manager | default "nova.scheduler.manager.SchedulerManager" }}

# Maximum time since last check-in for up service (integer value)
# from .default.nova.conf.service_down_time
{{ if not .default.nova.conf.service_down_time }}#{{ end }}service_down_time = {{ .default.nova.conf.service_down_time | default "60" }}

#
# This option specifies the driver to be used for the servicegroup service.
#
# ServiceGroup API in nova enables checking status of a compute node. When a
# compute worker running the nova-compute daemon starts, it calls the join API
# to join the compute group. Services like nova scheduler can query the
# ServiceGroup API to check if a node is alive. Internally, the ServiceGroup
# client driver automatically updates the compute worker status. There are
# multiple backend implementations for this service: Database ServiceGroup
# driver
# and Memcache ServiceGroup driver.
#
# Possible Values:
#
#     * db : Database ServiceGroup driver
#     * mc : Memcache ServiceGroup driver
#
# Related Options:
#
#     * service_down_time (maximum time since last check-in for up service)
#  (string value)
# Allowed values: db, mc
# from .default.nova.conf.servicegroup_driver
{{ if not .default.nova.conf.servicegroup_driver }}#{{ end }}servicegroup_driver = {{ .default.nova.conf.servicegroup_driver | default "db" }}

#
# Defines which physical CPUs (pCPUs) can be used by instance
# virtual CPUs (vCPUs).
#
# Possible values:
#
# * A comma-separated list of physical CPU numbers that virtual CPUs can be
#   allocated to by default. Each element should be either a single CPU number,
#   a range of CPU numbers, or a caret followed by a CPU number to be
#   excluded from a previous range. For example:
#
#     vcpu_pin_set = "4-12,^8,15"
#  (string value)
# from .default.nova.conf.vcpu_pin_set
{{ if not .default.nova.conf.vcpu_pin_set }}#{{ end }}vcpu_pin_set = {{ .default.nova.conf.vcpu_pin_set | default "<None>" }}

#
# Defines which driver to use for controlling virtualization.
#
# Possible values:
#
# * ``libvirt.LibvirtDriver``
# * ``xenapi.XenAPIDriver``
# * ``fake.FakeDriver``
# * ``ironic.IronicDriver``
# * ``vmwareapi.VMwareVCDriver``
# * ``hyperv.HyperVDriver``
#  (string value)
# from .default.nova.conf.compute_driver
{{ if not .default.nova.conf.compute_driver }}#{{ end }}compute_driver = {{ .default.nova.conf.compute_driver | default "<None>" }}

#
# The default format an ephemeral_volume will be formatted with on creation.
#
# Possible values:
#
# * ``ext2``
# * ``ext3``
# * ``ext4``
# * ``xfs``
# * ``ntfs`` (only for Windows guests)
#  (string value)
# from .default.nova.conf.default_ephemeral_format
{{ if not .default.nova.conf.default_ephemeral_format }}#{{ end }}default_ephemeral_format = {{ .default.nova.conf.default_ephemeral_format | default "<None>" }}

#
# The image preallocation mode to use. Image preallocation allows
# storage for instance images to be allocated up front when the instance is
# initially provisioned. This ensures immediate feedback is given if enough
# space isn't available. In addition, it should significantly improve
# performance on writes to new blocks and may even improve I/O performance to
# prewritten blocks due to reduced fragmentation.
#
# Possible values:
#
# * "none"  => no storage provisioning is done up front
# * "space" => storage is fully allocated at instance start
#  (string value)
# Allowed values: none, space
# from .default.nova.conf.preallocate_images
{{ if not .default.nova.conf.preallocate_images }}#{{ end }}preallocate_images = {{ .default.nova.conf.preallocate_images | default "none" }}

#
# Enable use of copy-on-write (cow) images.
#
# QEMU/KVM allow the use of qcow2 as backing files. By disabling this,
# backing files will not be used.
#  (boolean value)
# from .default.nova.conf.use_cow_images
{{ if not .default.nova.conf.use_cow_images }}#{{ end }}use_cow_images = {{ .default.nova.conf.use_cow_images | default "true" }}

#
# Determine if instance should boot or fail on VIF plugging timeout.
#
# Nova sends a port update to Neutron after an instance has been scheduled,
# providing Neutron with the necessary information to finish setup of the port.
# Once completed, Neutron notifies Nova that it has finished setting up the
# port, at which point Nova resumes the boot of the instance since network
# connectivity is now supposed to be present. A timeout will occur if the reply
# is not received after a given interval.
#
# This option determines what Nova does when the VIF plugging timeout event
# happens. When enabled, the instance will error out. When disabled, the
# instance will continue to boot on the assumption that the port is ready.
#
# Possible values:
#
# * True: Instances should fail after VIF plugging timeout
# * False: Instances should continue booting after VIF plugging timeout
#  (boolean value)
# from .default.nova.conf.vif_plugging_is_fatal
{{ if not .default.nova.conf.vif_plugging_is_fatal }}#{{ end }}vif_plugging_is_fatal = {{ .default.nova.conf.vif_plugging_is_fatal | default "true" }}

#
# Timeout for Neutron VIF plugging event message arrival.
#
# Number of seconds to wait for Neutron vif plugging events to
# arrive before continuing or failing (see 'vif_plugging_is_fatal').
#
# Interdependencies to other options:
#
# * vif_plugging_is_fatal - If ``vif_plugging_timeout`` is set to zero and
#   ``vif_plugging_is_fatal`` is False, events should not be expected to
#   arrive at all.
#  (integer value)
# Minimum value: 0
# from .default.nova.conf.vif_plugging_timeout
{{ if not .default.nova.conf.vif_plugging_timeout }}#{{ end }}vif_plugging_timeout = {{ .default.nova.conf.vif_plugging_timeout | default "300" }}

#
# Firewall driver to use with ``nova-network`` service.
#
# This option only applies when using the ``nova-network`` service. When using
# another networking services, such as Neutron, this should be to set to the
# ``nova.virt.firewall.NoopFirewallDriver``.
#
# If unset (the default), this will default to the hypervisor-specified
# default driver.
#
# Possible values:
#
# * nova.virt.firewall.IptablesFirewallDriver
# * nova.virt.firewall.NoopFirewallDriver
# * nova.virt.libvirt.firewall.IptablesFirewallDriver
# * [...]
#
# Interdependencies to other options:
#
# * ``use_neutron``: This must be set to ``False`` to enable ``nova-network``
#   networking
#  (string value)
# from .default.nova.conf.firewall_driver
{{ if not .default.nova.conf.firewall_driver }}#{{ end }}firewall_driver = {{ .default.nova.conf.firewall_driver | default "<None>" }}

#
# Determine whether to allow network traffic from same network.
#
# When set to true, hosts on the same subnet are not filtered and are allowed
# to pass all types of traffic between them. On a flat network, this allows
# all instances from all projects unfiltered communication. With VLAN
# networking, this allows access between instances within the same project.
#
# This option only applies when using the ``nova-network`` service. When using
# another networking services, such as Neutron, security groups or other
# approaches should be used.
#
# Possible values:
#
# * True: Network traffic should be allowed pass between all instances on the
#   same network, regardless of their tenant and security policies
# * False: Network traffic should not be allowed pass between instances unless
#   it is unblocked in a security group
#
# Interdependencies to other options:
#
# * ``use_neutron``: This must be set to ``False`` to enable ``nova-network``
#   networking
# * ``firewall_driver``: This must be set to
#   ``nova.virt.libvirt.firewall.IptablesFirewallDriver`` to ensure the
#   libvirt firewall driver is enabled.
#  (boolean value)
# from .default.nova.conf.allow_same_net_traffic
{{ if not .default.nova.conf.allow_same_net_traffic }}#{{ end }}allow_same_net_traffic = {{ .default.nova.conf.allow_same_net_traffic | default "true" }}

#
# Force conversion of backing images to raw format.
#
# Possible values:
#
# * True: Backing image files will be converted to raw image format
# * False: Backing image files will not be converted
#
# Interdependencies to other options:
#
# * ``compute_driver``: Only the libvirt driver uses this option.
#  (boolean value)
# from .default.nova.conf.force_raw_images
{{ if not .default.nova.conf.force_raw_images }}#{{ end }}force_raw_images = {{ .default.nova.conf.force_raw_images | default "true" }}

# Template file for injected network (string value)
# from .default.nova.conf.injected_network_template
{{ if not .default.nova.conf.injected_network_template }}#{{ end }}injected_network_template = {{ .default.nova.conf.injected_network_template | default "$pybasedir/nova/virt/interfaces.template" }}

#
# Name of the mkfs commands for ephemeral device. The format is
# <os_type>=<mkfs command>
#  (multi valued)
# from .default.nova.conf.virt_mkfs (multiopt)
{{ if not .default.nova.conf.virt_mkfs }}#virt_mkfs = {{ .default.nova.conf.virt_mkfs | default "" }}{{ else }}{{ range .default.nova.conf.virt_mkfs }}virt_mkfs = {{ . }}{{ end }}{{ end }}

#
# If enabled, attempt to resize the filesystem by accessing the image over a
# block device. This is done by the host and may not be necessary if the image
# contains a recent version of cloud-init. Possible mechanisms require the nbd
# driver (for qcow and raw), or loop (for raw).
#  (boolean value)
# from .default.nova.conf.resize_fs_using_block_device
{{ if not .default.nova.conf.resize_fs_using_block_device }}#{{ end }}resize_fs_using_block_device = {{ .default.nova.conf.resize_fs_using_block_device | default "false" }}

# Amount of time, in seconds, to wait for NBD device start up. (integer value)
# Minimum value: 0
# from .default.nova.conf.timeout_nbd
{{ if not .default.nova.conf.timeout_nbd }}#{{ end }}timeout_nbd = {{ .default.nova.conf.timeout_nbd | default "10" }}

#
# Number of seconds to wait between runs of the image cache manager.
# Set to -1 to disable. Setting this to 0 will run at the default rate.
#  (integer value)
# Minimum value: -1
# from .default.nova.conf.image_cache_manager_interval
{{ if not .default.nova.conf.image_cache_manager_interval }}#{{ end }}image_cache_manager_interval = {{ .default.nova.conf.image_cache_manager_interval | default "2400" }}

#
# Where cached images are stored under $instances_path. This is NOT the full
# path - just a folder name. For per-compute-host cached images, set to
# _base_$my_ip
#  (string value)
# from .default.nova.conf.image_cache_subdirectory_name
{{ if not .default.nova.conf.image_cache_subdirectory_name }}#{{ end }}image_cache_subdirectory_name = {{ .default.nova.conf.image_cache_subdirectory_name | default "_base" }}

# Should unused base images be removed? (boolean value)
# from .default.nova.conf.remove_unused_base_images
{{ if not .default.nova.conf.remove_unused_base_images }}#{{ end }}remove_unused_base_images = {{ .default.nova.conf.remove_unused_base_images | default "true" }}

#
# Unused unresized base images younger than this will not be removed
#  (integer value)
# from .default.nova.conf.remove_unused_original_minimum_age_seconds
{{ if not .default.nova.conf.remove_unused_original_minimum_age_seconds }}#{{ end }}remove_unused_original_minimum_age_seconds = {{ .default.nova.conf.remove_unused_original_minimum_age_seconds | default "86400" }}

#
# Generic property to specify the pointer type.
#
# Input devices allow interaction with a graphical framebuffer. For
# example to provide a graphic tablet for absolute cursor movement.
#
# If set, the 'hw_pointer_model' image property takes precedence over
# this configuration option.
#
# Possible values:
#
# * None: Uses default behavior provided by drivers (mouse on PS2 for
#         libvirt x86)
# * ps2mouse: Uses relative movement. Mouse connected by PS2
# * usbtablet: Uses absolute movement. Tablet connect by USB
#
# Interdependencies to other options:
#
# * usbtablet must be configured with VNC enabled or SPICE enabled and SPICE
#   agent disabled. When used with libvirt the instance mode should be
#   configured as HVM.
#   (string value)
# Allowed values: <None>, ps2mouse, usbtablet
# from .default.nova.conf.pointer_model
{{ if not .default.nova.conf.pointer_model }}#{{ end }}pointer_model = {{ .default.nova.conf.pointer_model | default "usbtablet" }}

#
# Reserves a number of huge/large memory pages per NUMA host cells
#
# Possible values:
#
# * A list of valid key=value which reflect NUMA node ID, page size
#   (Default unit is KiB) and number of pages to be reserved.
#
#     reserved_huge_pages = node:0,size:2048,count:64
#     reserved_huge_pages = node:1,size:1GB,count:1
#
#   In this example we are reserving on NUMA node 0 64 pages of 2MiB
#   and on NUMA node 1 1 page of 1GiB.
#  (dict value)
# from .default.nova.conf.reserved_huge_pages (multiopt)
{{ if not .default.nova.conf.reserved_huge_pages }}#reserved_huge_pages = {{ .default.nova.conf.reserved_huge_pages | default "<None>" }}{{ else }}{{ range .default.nova.conf.reserved_huge_pages }}reserved_huge_pages = {{ . }}{{ end }}{{ end }}

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

#
# From oslo.service.periodic_task
#

# Some periodic tasks can be run in a separate process. Should we run them here?
# (boolean value)
# from .default.oslo.service.periodic_task.run_external_periodic_tasks
{{ if not .default.oslo.service.periodic_task.run_external_periodic_tasks }}#{{ end }}run_external_periodic_tasks = {{ .default.oslo.service.periodic_task.run_external_periodic_tasks | default "true" }}

#
# From oslo.service.service
#

# Enable eventlet backdoor.  Acceptable values are 0, <port>, and <start>:<end>,
# where 0 results in listening on a random tcp port number; <port> results in
# listening on the specified port number (and not enabling backdoor if that port
# is in use); and <start>:<end> results in listening on the smallest unused port
# number within the specified range of port numbers.  The chosen port is
# displayed in the service's log file. (string value)
# from .default.oslo.service.service.backdoor_port
{{ if not .default.oslo.service.service.backdoor_port }}#{{ end }}backdoor_port = {{ .default.oslo.service.service.backdoor_port | default "<None>" }}

# Enable eventlet backdoor, using the provided path as a unix socket that can
# receive connections. This option is mutually exclusive with 'backdoor_port' in
# that only one should be provided. If both are provided then the existence of
# this option overrides the usage of that option. (string value)
# from .default.oslo.service.service.backdoor_socket
{{ if not .default.oslo.service.service.backdoor_socket }}#{{ end }}backdoor_socket = {{ .default.oslo.service.service.backdoor_socket | default "<None>" }}

# Enables or disables logging values of all registered options when starting a
# service (at DEBUG level). (boolean value)
# from .default.oslo.service.service.log_options
{{ if not .default.oslo.service.service.log_options }}#{{ end }}log_options = {{ .default.oslo.service.service.log_options | default "true" }}

# Specify a timeout after which a gracefully shutdown server will exit. Zero
# value means endless wait. (integer value)
# from .default.oslo.service.service.graceful_shutdown_timeout
{{ if not .default.oslo.service.service.graceful_shutdown_timeout }}#{{ end }}graceful_shutdown_timeout = {{ .default.oslo.service.service.graceful_shutdown_timeout | default "60" }}


[api_database]
#
# The *Nova API Database* is a separate database which is used for information
# which is used across *cells*. This database is mandatory since the Mitaka
# release (13.0.0).

#
# From nova.conf
#

# The SQLAlchemy connection string to use to connect to the database.The
# SQLAlchemy connection string to use to connect to the database. (string value)
# from .api_database.nova.conf.connection
{{ if not .api_database.nova.conf.connection }}#{{ end }}connection = {{ .api_database.nova.conf.connection | default "<None>" }}

# If True, SQLite uses synchronous mode.If True, SQLite uses synchronous mode.
# (boolean value)
# from .api_database.nova.conf.sqlite_synchronous
{{ if not .api_database.nova.conf.sqlite_synchronous }}#{{ end }}sqlite_synchronous = {{ .api_database.nova.conf.sqlite_synchronous | default "true" }}

# The SQLAlchemy connection string to use to connect to the slave database.The
# SQLAlchemy connection string to use to connect to the slave database. (string
# value)
# from .api_database.nova.conf.slave_connection
{{ if not .api_database.nova.conf.slave_connection }}#{{ end }}slave_connection = {{ .api_database.nova.conf.slave_connection | default "<None>" }}

# The SQL mode to be used for MySQL sessions. This option, including the
# default, overrides any server-set SQL mode. To use whatever SQL mode is set by
# the server configuration, set this to no value. Example: mysql_sql_mode=The
# SQL mode to be used for MySQL sessions. This option, including the default,
# overrides any server-set SQL mode. To use whatever SQL mode is set by the
# server configuration, set this to no value. Example: mysql_sql_mode= (string
# value)
# from .api_database.nova.conf.mysql_sql_mode
{{ if not .api_database.nova.conf.mysql_sql_mode }}#{{ end }}mysql_sql_mode = {{ .api_database.nova.conf.mysql_sql_mode | default "TRADITIONAL" }}

# Timeout before idle SQL connections are reaped.Timeout before idle SQL
# connections are reaped. (integer value)
# from .api_database.nova.conf.idle_timeout
{{ if not .api_database.nova.conf.idle_timeout }}#{{ end }}idle_timeout = {{ .api_database.nova.conf.idle_timeout | default "3600" }}

# Maximum number of SQL connections to keep open in a pool. Setting a value of 0
# indicates no limit.Maximum number of SQL connections to keep open in a pool.
# Setting a value of 0 indicates no limit. (integer value)
# from .api_database.nova.conf.max_pool_size
{{ if not .api_database.nova.conf.max_pool_size }}#{{ end }}max_pool_size = {{ .api_database.nova.conf.max_pool_size | default "<None>" }}

# Maximum number of database connection retries during startup. Set to -1 to
# specify an infinite retry count.Maximum number of database connection retries
# during startup. Set to -1 to specify an infinite retry count. (integer value)
# from .api_database.nova.conf.max_retries
{{ if not .api_database.nova.conf.max_retries }}#{{ end }}max_retries = {{ .api_database.nova.conf.max_retries | default "10" }}

# Interval between retries of opening a SQL connection.Interval between retries
# of opening a SQL connection. (integer value)
# from .api_database.nova.conf.retry_interval
{{ if not .api_database.nova.conf.retry_interval }}#{{ end }}retry_interval = {{ .api_database.nova.conf.retry_interval | default "10" }}

# If set, use this value for max_overflow with SQLAlchemy.If set, use this value
# for max_overflow with SQLAlchemy. (integer value)
# from .api_database.nova.conf.max_overflow
{{ if not .api_database.nova.conf.max_overflow }}#{{ end }}max_overflow = {{ .api_database.nova.conf.max_overflow | default "<None>" }}

# Verbosity of SQL debugging information: 0=None, 100=Everything.Verbosity of
# SQL debugging information: 0=None, 100=Everything. (integer value)
# from .api_database.nova.conf.connection_debug
{{ if not .api_database.nova.conf.connection_debug }}#{{ end }}connection_debug = {{ .api_database.nova.conf.connection_debug | default "0" }}

# Add Python stack traces to SQL as comment strings.Add Python stack traces to
# SQL as comment strings. (boolean value)
# from .api_database.nova.conf.connection_trace
{{ if not .api_database.nova.conf.connection_trace }}#{{ end }}connection_trace = {{ .api_database.nova.conf.connection_trace | default "false" }}

# If set, use this value for pool_timeout with SQLAlchemy.If set, use this value
# for pool_timeout with SQLAlchemy. (integer value)
# from .api_database.nova.conf.pool_timeout
{{ if not .api_database.nova.conf.pool_timeout }}#{{ end }}pool_timeout = {{ .api_database.nova.conf.pool_timeout | default "<None>" }}


[barbican]

#
# From nova.conf
#

# DEPRECATED:
# Info to match when looking for barbican in the service
# catalog. Format is: separated values of the form:
# <service_type>:<service_name>:<endpoint_type>
#  (string value)
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# Reason: This option have been moved to the Castellan library
# from .barbican.nova.conf.catalog_info
{{ if not .barbican.nova.conf.catalog_info }}#{{ end }}catalog_info = {{ .barbican.nova.conf.catalog_info | default "key-manager:barbican:public" }}

# DEPRECATED:
# Override service catalog lookup with template for
# barbican endpoint e.g.
# http://localhost:9311/v1/%(project_id)s
#  (string value)
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# Reason: This option have been moved to the Castellan library
# from .barbican.nova.conf.endpoint_template
{{ if not .barbican.nova.conf.endpoint_template }}#{{ end }}endpoint_template = {{ .barbican.nova.conf.endpoint_template | default "<None>" }}

# DEPRECATED: Region name of this node (string value)
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# Reason: This option have been moved to the Castellan library
# from .barbican.nova.conf.os_region_name
{{ if not .barbican.nova.conf.os_region_name }}#{{ end }}os_region_name = {{ .barbican.nova.conf.os_region_name | default "<None>" }}

# Use this endpoint to connect to Barbican, for example:
# "http://localhost:9311/" (string value)
# from .barbican.nova.conf.barbican_endpoint
{{ if not .barbican.nova.conf.barbican_endpoint }}#{{ end }}barbican_endpoint = {{ .barbican.nova.conf.barbican_endpoint | default "<None>" }}

# Version of the Barbican API, for example: "v1" (string value)
# from .barbican.nova.conf.barbican_api_version
{{ if not .barbican.nova.conf.barbican_api_version }}#{{ end }}barbican_api_version = {{ .barbican.nova.conf.barbican_api_version | default "<None>" }}

# Use this endpoint to connect to Keystone (string value)
# from .barbican.nova.conf.auth_endpoint
{{ if not .barbican.nova.conf.auth_endpoint }}#{{ end }}auth_endpoint = {{ .barbican.nova.conf.auth_endpoint | default "http://localhost:5000/v3" }}

# Number of seconds to wait before retrying poll for key creation completion
# (integer value)
# from .barbican.nova.conf.retry_delay
{{ if not .barbican.nova.conf.retry_delay }}#{{ end }}retry_delay = {{ .barbican.nova.conf.retry_delay | default "1" }}

# Number of times to retry poll for key creation completion (integer value)
# from .barbican.nova.conf.number_of_retries
{{ if not .barbican.nova.conf.number_of_retries }}#{{ end }}number_of_retries = {{ .barbican.nova.conf.number_of_retries | default "60" }}


[cache]

#
# From nova.conf
#

# Prefix for building the configuration dictionary for the cache region. This
# should not need to be changed unless there is another dogpile.cache region
# with the same configuration name. (string value)
# from .cache.nova.conf.config_prefix
{{ if not .cache.nova.conf.config_prefix }}#{{ end }}config_prefix = {{ .cache.nova.conf.config_prefix | default "cache.oslo" }}

# Default TTL, in seconds, for any cached item in the dogpile.cache region. This
# applies to any cached method that doesn't have an explicit cache expiration
# time defined for it. (integer value)
# from .cache.nova.conf.expiration_time
{{ if not .cache.nova.conf.expiration_time }}#{{ end }}expiration_time = {{ .cache.nova.conf.expiration_time | default "600" }}

# Dogpile.cache backend module. It is recommended that Memcache or Redis
# (dogpile.cache.redis) be used in production deployments. For eventlet-based or
# highly threaded servers, Memcache with pooling (oslo_cache.memcache_pool) is
# recommended. For low thread servers, dogpile.cache.memcached is recommended.
# Test environments with a single instance of the server can use the
# dogpile.cache.memory backend. (string value)
# from .cache.nova.conf.backend
{{ if not .cache.nova.conf.backend }}#{{ end }}backend = {{ .cache.nova.conf.backend | default "dogpile.cache.null" }}

# Arguments supplied to the backend module. Specify this option once per
# argument to be passed to the dogpile.cache backend. Example format:
# "<argname>:<value>". (multi valued)
# from .cache.nova.conf.backend_argument (multiopt)
{{ if not .cache.nova.conf.backend_argument }}#backend_argument = {{ .cache.nova.conf.backend_argument | default "" }}{{ else }}{{ range .cache.nova.conf.backend_argument }}backend_argument = {{ . }}{{ end }}{{ end }}

# Proxy classes to import that will affect the way the dogpile.cache backend
# functions. See the dogpile.cache documentation on changing-backend-behavior.
# (list value)
# from .cache.nova.conf.proxies
{{ if not .cache.nova.conf.proxies }}#{{ end }}proxies = {{ .cache.nova.conf.proxies | default "" }}

# Global toggle for caching. (boolean value)
# from .cache.nova.conf.enabled
{{ if not .cache.nova.conf.enabled }}#{{ end }}enabled = {{ .cache.nova.conf.enabled | default "false" }}

# Extra debugging from the cache backend (cache keys, get/set/delete/etc calls).
# This is only really useful if you need to see the specific cache-backend
# get/set/delete calls with the keys/values.  Typically this should be left set
# to false. (boolean value)
# from .cache.nova.conf.debug_cache_backend
{{ if not .cache.nova.conf.debug_cache_backend }}#{{ end }}debug_cache_backend = {{ .cache.nova.conf.debug_cache_backend | default "false" }}

# Memcache servers in the format of "host:port". (dogpile.cache.memcache and
# oslo_cache.memcache_pool backends only). (list value)
# from .cache.nova.conf.memcache_servers
{{ if not .cache.nova.conf.memcache_servers }}#{{ end }}memcache_servers = {{ .cache.nova.conf.memcache_servers | default "localhost:11211" }}

# Number of seconds memcached server is considered dead before it is tried
# again. (dogpile.cache.memcache and oslo_cache.memcache_pool backends only).
# (integer value)
# from .cache.nova.conf.memcache_dead_retry
{{ if not .cache.nova.conf.memcache_dead_retry }}#{{ end }}memcache_dead_retry = {{ .cache.nova.conf.memcache_dead_retry | default "300" }}

# Timeout in seconds for every call to a server. (dogpile.cache.memcache and
# oslo_cache.memcache_pool backends only). (integer value)
# from .cache.nova.conf.memcache_socket_timeout
{{ if not .cache.nova.conf.memcache_socket_timeout }}#{{ end }}memcache_socket_timeout = {{ .cache.nova.conf.memcache_socket_timeout | default "3" }}

# Max total number of open connections to every memcached server.
# (oslo_cache.memcache_pool backend only). (integer value)
# from .cache.nova.conf.memcache_pool_maxsize
{{ if not .cache.nova.conf.memcache_pool_maxsize }}#{{ end }}memcache_pool_maxsize = {{ .cache.nova.conf.memcache_pool_maxsize | default "10" }}

# Number of seconds a connection to memcached is held unused in the pool before
# it is closed. (oslo_cache.memcache_pool backend only). (integer value)
# from .cache.nova.conf.memcache_pool_unused_timeout
{{ if not .cache.nova.conf.memcache_pool_unused_timeout }}#{{ end }}memcache_pool_unused_timeout = {{ .cache.nova.conf.memcache_pool_unused_timeout | default "60" }}

# Number of seconds that an operation will wait to get a memcache client
# connection. (integer value)
# from .cache.nova.conf.memcache_pool_connection_get_timeout
{{ if not .cache.nova.conf.memcache_pool_connection_get_timeout }}#{{ end }}memcache_pool_connection_get_timeout = {{ .cache.nova.conf.memcache_pool_connection_get_timeout | default "10" }}


[cells]
#
# Cells options allow you to use cells functionality in openstack
# deployment.
#

#
# From nova.conf
#

#
# Enable cell functionality
#
# When this functionality is enabled, it lets you to scale an OpenStack
# Compute cloud in a more distributed fashion without having to use
# complicated technologies like database and message queue clustering.
# Cells are configured as a tree. The top-level cell should have a host
# that runs a nova-api service, but no nova-compute services. Each
# child cell should run all of the typical nova-* services in a regular
# Compute cloud except for nova-api. You can think of cells as a normal
# Compute deployment in that each cell has its own database server and
# message queue broker.
#
# Related options:
#
# * name: A unique cell name must be given when this functionality
#   is enabled.
# * cell_type: Cell type should be defined for all cells.
#
#  (boolean value)
# from .cells.nova.conf.enable
{{ if not .cells.nova.conf.enable }}#{{ end }}enable = {{ .cells.nova.conf.enable | default "false" }}

#
# Topic
#
# This is the message queue topic that cells nodes listen on. It is
# used when the cells service is started up to configure the queue,
# and whenever an RPC call to the scheduler is made.
#
# Possible values:
#
# * cells: This is the recommended and the default value.
#
#  (string value)
# from .cells.nova.conf.topic
{{ if not .cells.nova.conf.topic }}#{{ end }}topic = {{ .cells.nova.conf.topic | default "cells" }}

#
# Name of the current cell
#
# This value must be unique for each cell. Name of a cell is used as
# its id, leaving this option unset or setting the same name for
# two or more cells may cause unexpected behaviour.
#
# Related options:
#
# * enabled: This option is meaningful only when cells service
#   is enabled
#
#  (string value)
# from .cells.nova.conf.name
{{ if not .cells.nova.conf.name }}#{{ end }}name = {{ .cells.nova.conf.name | default "nova" }}

#
# Cell capabilities
#
# List of arbitrary key=value pairs defining capabilities of the
# current cell to be sent to the parent cells. These capabilities
# are intended to be used in cells scheduler filters/weighers.
#
# Possible values:
#
# * key=value pairs list for example;
#   ``hypervisor=xenserver;kvm,os=linux;windows``
#
#  (list value)
# from .cells.nova.conf.capabilities
{{ if not .cells.nova.conf.capabilities }}#{{ end }}capabilities = {{ .cells.nova.conf.capabilities | default "hypervisor=xenserver;kvm,os=linux;windows" }}

#
# Call timeout
#
# Cell messaging module waits for response(s) to be put into the
# eventlet queue. This option defines the seconds waited for
# response from a call to a cell.
#
# Possible values:
#
# * Time in seconds.
#
#  (integer value)
# Minimum value: 0
# from .cells.nova.conf.call_timeout
{{ if not .cells.nova.conf.call_timeout }}#{{ end }}call_timeout = {{ .cells.nova.conf.call_timeout | default "60" }}

#
# Reserve percentage
#
# Percentage of cell capacity to hold in reserve, so the minimum
# amount of free resource is considered to be;
#   min_free = total * (reserve_percent / 100.0)
# This option affects both memory and disk utilization.
# The primary purpose of this reserve is to ensure some space is
# available for users who want to resize their instance to be larger.
# Note that currently once the capacity expands into this reserve
# space this option is ignored.
#
#  (floating point value)
# from .cells.nova.conf.reserve_percent
{{ if not .cells.nova.conf.reserve_percent }}#{{ end }}reserve_percent = {{ .cells.nova.conf.reserve_percent | default "10.0" }}

#
# Type of cell
#
# When cells feature is enabled the hosts in the OpenStack Compute
# cloud are partitioned into groups. Cells are configured as a tree.
# The top-level cell's cell_type must be set to ``api``. All other
# cells are defined as a ``compute cell`` by default.
#
# Related options:
#
# * compute_api_class: This option must be set to cells api driver
#   for the top-level cell (nova.compute.cells_api.ComputeCellsAPI)
# * quota_driver: Disable quota checking for the child cells.
#   (nova.quota.NoopQuotaDriver)
#  (string value)
# Allowed values: api, compute
# from .cells.nova.conf.cell_type
{{ if not .cells.nova.conf.cell_type }}#{{ end }}cell_type = {{ .cells.nova.conf.cell_type | default "compute" }}

#
# Mute child interval
#
# Number of seconds after which a lack of capability and capacity
# update the child cell is to be treated as a mute cell. Then the
# child cell will be weighed as recommend highly that it be skipped.
#
# Possible values:
#
# * Time in seconds.
#
#  (integer value)
# from .cells.nova.conf.mute_child_interval
{{ if not .cells.nova.conf.mute_child_interval }}#{{ end }}mute_child_interval = {{ .cells.nova.conf.mute_child_interval | default "300" }}

#
# Bandwidth update interval
#
# Seconds between bandwidth usage cache updates for cells.
#
# Possible values:
#
# * Time in seconds.
#
#  (integer value)
# from .cells.nova.conf.bandwidth_update_interval
{{ if not .cells.nova.conf.bandwidth_update_interval }}#{{ end }}bandwidth_update_interval = {{ .cells.nova.conf.bandwidth_update_interval | default "600" }}

#
# Instance update sync database limit
#
# Number of instances to pull from the database at one time for
# a sync. If there are more instances to update the results will
# be paged through.
#
# Possible values:
#
# * Number of instances.
#
#  (integer value)
# from .cells.nova.conf.instance_update_sync_database_limit
{{ if not .cells.nova.conf.instance_update_sync_database_limit }}#{{ end }}instance_update_sync_database_limit = {{ .cells.nova.conf.instance_update_sync_database_limit | default "100" }}

#
# Mute weight multiplier
#
# Multiplier used to weigh mute children. Mute children cells are
# recommended to be skipped so their weight is multiplied by this
# negative value.
#
# Possible values:
#
# * Negative numeric number
#
#  (floating point value)
# from .cells.nova.conf.mute_weight_multiplier
{{ if not .cells.nova.conf.mute_weight_multiplier }}#{{ end }}mute_weight_multiplier = {{ .cells.nova.conf.mute_weight_multiplier | default "-10000.0" }}

#
# Ram weight multiplier
#
# Multiplier used for weighing ram. Negative numbers indicate that
# Compute should stack VMs on one host instead of spreading out new
# VMs to more hosts in the cell.
#
# Possible values:
#
# * Numeric multiplier
#
#  (floating point value)
# from .cells.nova.conf.ram_weight_multiplier
{{ if not .cells.nova.conf.ram_weight_multiplier }}#{{ end }}ram_weight_multiplier = {{ .cells.nova.conf.ram_weight_multiplier | default "10.0" }}

#
# Offset weight multiplier
#
# Multiplier used to weigh offset weigher. Cells with higher
# weight_offsets in the DB will be preferred. The weight_offset
# is a property of a cell stored in the database. It can be used
# by a deployer to have scheduling decisions favor or disfavor
# cells based on the setting.
#
# Possible values:
#
# * Numeric multiplier
#
#  (floating point value)
# from .cells.nova.conf.offset_weight_multiplier
{{ if not .cells.nova.conf.offset_weight_multiplier }}#{{ end }}offset_weight_multiplier = {{ .cells.nova.conf.offset_weight_multiplier | default "1.0" }}

# DEPRECATED: Cells communication driver
#
# Driver for cell<->cell communication via RPC. This is used to
# setup the RPC consumers as well as to send a message to another cell.
# 'nova.cells.rpc_driver.CellsRPCDriver' starts up 2 separate servers
# for handling inter-cell communication via RPC.
#
#  (string value)
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# Reason: The only available driver is the RPC driver.
# from .cells.nova.conf.driver
{{ if not .cells.nova.conf.driver }}#{{ end }}driver = {{ .cells.nova.conf.driver | default "nova.cells.rpc_driver.CellsRPCDriver" }}

#
# Instance updated at threshold
#
# Number of seconds after an instance was updated or deleted to
# continue to update cells. This option lets cells manager to only
# attempt to sync instances that have been updated recently.
# i.e., a threshold of 3600 means to only update instances that
# have modified in the last hour.
#
# Possible values:
#
# * Threshold in seconds
#
# Related options:
#
# * This value is used with the ``instance_update_num_instances``
#   value in a periodic task run.
#
#  (integer value)
# from .cells.nova.conf.instance_updated_at_threshold
{{ if not .cells.nova.conf.instance_updated_at_threshold }}#{{ end }}instance_updated_at_threshold = {{ .cells.nova.conf.instance_updated_at_threshold | default "3600" }}

#
# Instance update num instances
#
# On every run of the periodic task, nova cells manager will attempt to
# sync instance_updated_at_threshold number of instances. When the
# manager gets the list of instances, it shuffles them so that multiple
# nova-cells services do not attempt to sync the same instances in
# lockstep.
#
# Possible values:
#
# * Positive integer number
#
# Related options:
#
# * This value is used with the ``instance_updated_at_threshold``
#   value in a periodic task run.
#
#  (integer value)
# from .cells.nova.conf.instance_update_num_instances
{{ if not .cells.nova.conf.instance_update_num_instances }}#{{ end }}instance_update_num_instances = {{ .cells.nova.conf.instance_update_num_instances | default "1" }}

#
# Maximum hop count
#
# When processing a targeted message, if the local cell is not the
# target, a route is defined between neighbouring cells. And the
# message is processed across the whole routing path. This option
# defines the maximum hop counts until reaching the target.
#
# Possible values:
#
# * Positive integer value
#
#  (integer value)
# from .cells.nova.conf.max_hop_count
{{ if not .cells.nova.conf.max_hop_count }}#{{ end }}max_hop_count = {{ .cells.nova.conf.max_hop_count | default "10" }}

#
# Cells scheduler
#
# The class of the driver used by the cells scheduler. This should be
# the full Python path to the class to be used. If nothing is specified
# in this option, the CellsScheduler is used.
#
#  (string value)
# from .cells.nova.conf.scheduler
{{ if not .cells.nova.conf.scheduler }}#{{ end }}scheduler = {{ .cells.nova.conf.scheduler | default "nova.cells.scheduler.CellsScheduler" }}

#
# RPC driver queue base
#
# When sending a message to another cell by JSON-ifying the message
# and making an RPC cast to 'process_message', a base queue is used.
# This option defines the base queue name to be used when communicating
# between cells. Various topics by message type will be appended to this.
#
# Possible values:
#
# * The base queue name to be used when communicating between cells.
#
#  (string value)
# from .cells.nova.conf.rpc_driver_queue_base
{{ if not .cells.nova.conf.rpc_driver_queue_base }}#{{ end }}rpc_driver_queue_base = {{ .cells.nova.conf.rpc_driver_queue_base | default "cells.intercell" }}

#
# Scheduler filter classes
#
# Filter classes the cells scheduler should use. An entry of
# "nova.cells.filters.all_filters" maps to all cells filters
# included with nova. As of the Mitaka release the following
# filter classes are available:
#
# Different cell filter: A scheduler hint of 'different_cell'
# with a value of a full cell name may be specified to route
# a build away from a particular cell.
#
# Image properties filter: Image metadata named
# 'hypervisor_version_requires' with a version specification
# may be specified to ensure the build goes to a cell which
# has hypervisors of the required version. If either the version
# requirement on the image or the hypervisor capability of the
# cell is not present, this filter returns without filtering out
# the cells.
#
# Target cell filter: A scheduler hint of 'target_cell' with a
# value of a full cell name may be specified to route a build to
# a particular cell. No error handling is done as there's no way
# to know whether the full path is a valid.
#
# As an admin user, you can also add a filter that directs builds
# to a particular cell.
#
#  (list value)
# from .cells.nova.conf.scheduler_filter_classes
{{ if not .cells.nova.conf.scheduler_filter_classes }}#{{ end }}scheduler_filter_classes = {{ .cells.nova.conf.scheduler_filter_classes | default "nova.cells.filters.all_filters" }}

#
# Scheduler weight classes
#
# Weigher classes the cells scheduler should use. An entry of
# "nova.cells.weights.all_weighers" maps to all cell weighers
# included with nova. As of the Mitaka release the following
# weight classes are available:
#
# mute_child: Downgrades the likelihood of child cells being
# chosen for scheduling requests, which haven't sent capacity
# or capability updates in a while. Options include
# mute_weight_multiplier (multiplier for mute children; value
# should be negative).
#
# ram_by_instance_type: Select cells with the most RAM capacity
# for the instance type being requested. Because higher weights
# win, Compute returns the number of available units for the
# instance type requested. The ram_weight_multiplier option defaults
# to 10.0 that adds to the weight by a factor of 10. Use a negative
# number to stack VMs on one host instead of spreading out new VMs
# to more hosts in the cell.
#
# weight_offset: Allows modifying the database to weight a particular
# cell. The highest weight will be the first cell to be scheduled for
# launching an instance. When the weight_offset of a cell is set to 0,
# it is unlikely to be picked but it could be picked if other cells
# have a lower weight, like if they're full. And when the weight_offset
# is set to a very high value (for example, '999999999999999'), it is
# likely to be picked if another cell do not have a higher weight.
#
#  (list value)
# from .cells.nova.conf.scheduler_weight_classes
{{ if not .cells.nova.conf.scheduler_weight_classes }}#{{ end }}scheduler_weight_classes = {{ .cells.nova.conf.scheduler_weight_classes | default "nova.cells.weights.all_weighers" }}

#
# Scheduler retries
#
# How many retries when no cells are available. Specifies how many
# times the scheduler tries to launch a new instance when no cells
# are available.
#
# Possible values:
#
# * Positive integer value
#
# Related options:
#
# * This value is used with the ``scheduler_retry_delay`` value
#   while retrying to find a suitable cell.
#
#  (integer value)
# from .cells.nova.conf.scheduler_retries
{{ if not .cells.nova.conf.scheduler_retries }}#{{ end }}scheduler_retries = {{ .cells.nova.conf.scheduler_retries | default "10" }}

#
# Scheduler retry delay
#
# Specifies the delay (in seconds) between scheduling retries when no
# cell can be found to place the new instance on. When the instance
# could not be scheduled to a cell after ``scheduler_retries`` in
# combination with ``scheduler_retry_delay``, then the scheduling
# of the instance failed.
#
# Possible values:
#
# * Time in seconds.
#
# Related options:
#
# * This value is used with the ``scheduler_retries`` value
#   while retrying to find a suitable cell.
#
#  (integer value)
# from .cells.nova.conf.scheduler_retry_delay
{{ if not .cells.nova.conf.scheduler_retry_delay }}#{{ end }}scheduler_retry_delay = {{ .cells.nova.conf.scheduler_retry_delay | default "2" }}

#
# DB check interval
#
# Cell state manager updates cell status for all cells from the DB
# only after this particular interval time is passed. Otherwise cached
# status are used. If this value is 0 or negative all cell status are
# updated from the DB whenever a state is needed.
#
# Possible values:
#
# * Interval time, in seconds.
#
#  (integer value)
# from .cells.nova.conf.db_check_interval
{{ if not .cells.nova.conf.db_check_interval }}#{{ end }}db_check_interval = {{ .cells.nova.conf.db_check_interval | default "60" }}

#
# Optional cells configuration
#
# Configuration file from which to read cells configuration. If given,
# overrides reading cells from the database.
#
# Cells store all inter-cell communication data, including user names
# and passwords, in the database. Because the cells data is not updated
# very frequently, use this option to specify a JSON file to store
# cells data. With this configuration, the database is no longer
# consulted when reloading the cells data. The file must have columns
# present in the Cell model (excluding common database fields and the
# id column). You must specify the queue connection information through
# a transport_url field, instead of username, password, and so on.
#
# The transport_url has the following form:
# rabbit://USERNAME:PASSWORD@HOSTNAME:PORT/VIRTUAL_HOST
#
# Possible values:
#
# The scheme can be either qpid or rabbit, the following sample shows
# this optional configuration:
#
#     {
#         "parent": {
#             "name": "parent",
#             "api_url": "http://api.example.com:8774",
#             "transport_url": "rabbit://rabbit.example.com",
#             "weight_offset": 0.0,
#             "weight_scale": 1.0,
#             "is_parent": true
#         },
#         "cell1": {
#             "name": "cell1",
#             "api_url": "http://api.example.com:8774",
#             "transport_url": "rabbit://rabbit1.example.com",
#             "weight_offset": 0.0,
#             "weight_scale": 1.0,
#             "is_parent": false
#         },
#         "cell2": {
#             "name": "cell2",
#             "api_url": "http://api.example.com:8774",
#             "transport_url": "rabbit://rabbit2.example.com",
#             "weight_offset": 0.0,
#             "weight_scale": 1.0,
#             "is_parent": false
#         }
#     }
#
#  (string value)
# from .cells.nova.conf.cells_config
{{ if not .cells.nova.conf.cells_config }}#{{ end }}cells_config = {{ .cells.nova.conf.cells_config | default "<None>" }}


[cinder]

#
# From nova.conf
#

#
# Info to match when looking for cinder in the service catalog.
#
# Possible values:
#
# * Format is separated values of the form:
#   <service_type>:<service_name>:<endpoint_type>
#
# Related options:
#
# * endpoint_template - Setting this option will override catalog_info
#  (string value)
# from .cinder.nova.conf.catalog_info
{{ if not .cinder.nova.conf.catalog_info }}#{{ end }}catalog_info = {{ .cinder.nova.conf.catalog_info | default "volumev2:cinderv2:publicURL" }}

#
# If this option is set then it will override service catalog lookup with
# this template for cinder endpoint
#
# Possible values:
#
# * URL for cinder endpoint API
#   e.g. http://localhost:8776/v1/%(project_id)s
#
# Related options:
#
# * catalog_info - If endpoint_template is not set, catalog_info will be used.
#  (string value)
# from .cinder.nova.conf.endpoint_template
{{ if not .cinder.nova.conf.endpoint_template }}#{{ end }}endpoint_template = {{ .cinder.nova.conf.endpoint_template | default "<None>" }}

#
# Region name of this node. This is used when picking the URL in the service
# catalog.
#
# Possible values:
#
# * Any string representing region name
#  (string value)
# from .cinder.nova.conf.os_region_name
{{ if not .cinder.nova.conf.os_region_name }}#{{ end }}os_region_name = {{ .cinder.nova.conf.os_region_name | default "<None>" }}

#
# Number of times cinderclient should retry on any failed http call.
# 0 means connection is attempted only once. Setting it to any positive integer
# means that on failure connection is retried that many times e.g. setting it
# to 3 means total attempts to connect will be 4.
#
# Possible values:
#
# * Any integer value. 0 means connection is attempted only once
#  (integer value)
# Minimum value: 0
# from .cinder.nova.conf.http_retries
{{ if not .cinder.nova.conf.http_retries }}#{{ end }}http_retries = {{ .cinder.nova.conf.http_retries | default "3" }}

#
# Allow attach between instance and volume in different availability zones.
#
# If False, volumes attached to an instance must be in the same availability
# zone in Cinder as the instance availability zone in Nova.
# This also means care should be taken when booting an instance from a volume
# where source is not "volume" because Nova will attempt to create a volume
# using
# the same availability zone as what is assigned to the instance.
# If that AZ is not in Cinder (or allow_availability_zone_fallback=False in
# cinder.conf), the volume create request will fail and the instance will fail
# the build request.
# By default there is no availability zone restriction on volume attach.
#  (boolean value)
# from .cinder.nova.conf.cross_az_attach
{{ if not .cinder.nova.conf.cross_az_attach }}#{{ end }}cross_az_attach = {{ .cinder.nova.conf.cross_az_attach | default "true" }}


[cloudpipe]

#
# From nova.conf
#

#
# Image ID used when starting up a cloudpipe VPN client.
#
# An empty instance is created and configured with OpenVPN using
# boot_script_template. This instance would be snapshotted and stored
# in glance. ID of the stored image is used in 'vpn_image_id' to
# create cloudpipe VPN client.
#
# Possible values:
#
# * Any valid ID of a VPN image
#  (string value)
# Deprecated group/name - [DEFAULT]/vpn_image_id
# from .cloudpipe.nova.conf.vpn_image_id
{{ if not .cloudpipe.nova.conf.vpn_image_id }}#{{ end }}vpn_image_id = {{ .cloudpipe.nova.conf.vpn_image_id | default "0" }}

#
# Flavor for VPN instances.
#
# Possible values:
#
# * Any valid flavor name
#  (string value)
# Deprecated group/name - [DEFAULT]/vpn_flavor
# from .cloudpipe.nova.conf.vpn_flavor
{{ if not .cloudpipe.nova.conf.vpn_flavor }}#{{ end }}vpn_flavor = {{ .cloudpipe.nova.conf.vpn_flavor | default "m1.tiny" }}

#
# Template for cloudpipe instance boot script.
#
# Possible values:
#
# * Any valid path to a cloudpipe instance boot script template
#
# Related options:
#
# The following options are required to configure cloudpipe-managed
# OpenVPN server.
#
# * dmz_net
# * dmz_mask
# * cnt_vpn_clients
#  (string value)
# Deprecated group/name - [DEFAULT]/boot_script_template
# from .cloudpipe.nova.conf.boot_script_template
{{ if not .cloudpipe.nova.conf.boot_script_template }}#{{ end }}boot_script_template = {{ .cloudpipe.nova.conf.boot_script_template | default "$pybasedir/nova/cloudpipe/bootscript.template" }}

#
# Network to push into OpenVPN config.
#
# Note: Above mentioned OpenVPN config can be found at
# /etc/openvpn/server.conf.
#
# Possible values:
#
# * Any valid IPv4/IPV6 address
#
# Related options:
#
# * boot_script_template - dmz_net is pushed into bootscript.template
#   to configure cloudpipe-managed OpenVPN server
#  (IP address value)
# Deprecated group/name - [DEFAULT]/dmz_net
# from .cloudpipe.nova.conf.dmz_net
{{ if not .cloudpipe.nova.conf.dmz_net }}#{{ end }}dmz_net = {{ .cloudpipe.nova.conf.dmz_net | default "10.0.0.0" }}

#
# Netmask to push into OpenVPN config.
#
# Possible values:
#
# * Any valid IPv4/IPV6 netmask
#
# Related options:
#
# * dmz_net - dmz_net and dmz_mask is pushed into bootscript.template
#   to configure cloudpipe-managed OpenVPN server
# * boot_script_template
#  (IP address value)
# Deprecated group/name - [DEFAULT]/dmz_mask
# from .cloudpipe.nova.conf.dmz_mask
{{ if not .cloudpipe.nova.conf.dmz_mask }}#{{ end }}dmz_mask = {{ .cloudpipe.nova.conf.dmz_mask | default "255.255.255.0" }}

#
# Suffix to add to project name for VPN key and secgroups
#
# Possible values:
#
# * Any string value representing the VPN key suffix
#  (string value)
# Deprecated group/name - [DEFAULT]/vpn_key_suffix
# from .cloudpipe.nova.conf.vpn_key_suffix
{{ if not .cloudpipe.nova.conf.vpn_key_suffix }}#{{ end }}vpn_key_suffix = {{ .cloudpipe.nova.conf.vpn_key_suffix | default "-vpn" }}


[conductor]
#
# Options under this group are used to define Conductor's communication,
# which manager should be act as a proxy between computes and database,
# and finally, how many worker processes will be used.

#
# From nova.conf
#

# DEPRECATED:
# Perform nova-conductor operations locally. This legacy mode was
# introduced to bridge a gap during the transition to the conductor service.
# It no longer represents a reasonable alternative for deployers.
#
# Removal may be as early as 14.0.
#  (boolean value)
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# from .conductor.nova.conf.use_local
{{ if not .conductor.nova.conf.use_local }}#{{ end }}use_local = {{ .conductor.nova.conf.use_local | default "false" }}

#
# Topic exchange name on which conductor nodes listen.
#  (string value)
# from .conductor.nova.conf.topic
{{ if not .conductor.nova.conf.topic }}#{{ end }}topic = {{ .conductor.nova.conf.topic | default "conductor" }}

# DEPRECATED:
# Full class name for the Manager for conductor.
#
# Removal in 14.0
#  (string value)
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# from .conductor.nova.conf.manager
{{ if not .conductor.nova.conf.manager }}#{{ end }}manager = {{ .conductor.nova.conf.manager | default "nova.conductor.manager.ConductorManager" }}

#
# Number of workers for OpenStack Conductor service. The default will be the
# number of CPUs available.
#  (integer value)
# from .conductor.nova.conf.workers
{{ if not .conductor.nova.conf.workers }}#{{ end }}workers = {{ .conductor.nova.conf.workers | default "<None>" }}


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
{{ if not .cors.oslo.middleware.expose_headers }}#{{ end }}expose_headers = {{ .cors.oslo.middleware.expose_headers | default "X-Auth-Token,X-Openstack-Request-Id,X-Subject-Token,X-Service-Token" }}

# Maximum cache age of CORS preflight requests. (integer value)
# from .cors.oslo.middleware.max_age
{{ if not .cors.oslo.middleware.max_age }}#{{ end }}max_age = {{ .cors.oslo.middleware.max_age | default "3600" }}

# Indicate which methods can be used during the actual request. (list value)
# from .cors.oslo.middleware.allow_methods
{{ if not .cors.oslo.middleware.allow_methods }}#{{ end }}allow_methods = {{ .cors.oslo.middleware.allow_methods | default "GET,PUT,POST,DELETE,PATCH" }}

# Indicate which header field names may be used during the actual request. (list
# value)
# from .cors.oslo.middleware.allow_headers
{{ if not .cors.oslo.middleware.allow_headers }}#{{ end }}allow_headers = {{ .cors.oslo.middleware.allow_headers | default "X-Auth-Token,X-Openstack-Request-Id,X-Identity-Status,X-Roles,X-Service-Catalog,X-User-Id,X-Tenant-Id" }}


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
{{ if not .cors.subdomain.oslo.middleware.expose_headers }}#{{ end }}expose_headers = {{ .cors.subdomain.oslo.middleware.expose_headers | default "X-Auth-Token,X-Openstack-Request-Id,X-Subject-Token,X-Service-Token" }}

# Maximum cache age of CORS preflight requests. (integer value)
# from .cors.subdomain.oslo.middleware.max_age
{{ if not .cors.subdomain.oslo.middleware.max_age }}#{{ end }}max_age = {{ .cors.subdomain.oslo.middleware.max_age | default "3600" }}

# Indicate which methods can be used during the actual request. (list value)
# from .cors.subdomain.oslo.middleware.allow_methods
{{ if not .cors.subdomain.oslo.middleware.allow_methods }}#{{ end }}allow_methods = {{ .cors.subdomain.oslo.middleware.allow_methods | default "GET,PUT,POST,DELETE,PATCH" }}

# Indicate which header field names may be used during the actual request. (list
# value)
# from .cors.subdomain.oslo.middleware.allow_headers
{{ if not .cors.subdomain.oslo.middleware.allow_headers }}#{{ end }}allow_headers = {{ .cors.subdomain.oslo.middleware.allow_headers | default "X-Auth-Token,X-Openstack-Request-Id,X-Identity-Status,X-Roles,X-Service-Catalog,X-User-Id,X-Tenant-Id" }}


[crypto]

#
# From nova.conf
#

#
# Filename of root CA (Certificate Authority). This is a container format
# and includes root certificates.
#
# Possible values:
#
# * Any file name containing root CA, cacert.pem is default
#
# Related options:
#
# * ca_path
#  (string value)
# Deprecated group/name - [DEFAULT]/ca_file
# from .crypto.nova.conf.ca_file
{{ if not .crypto.nova.conf.ca_file }}#{{ end }}ca_file = {{ .crypto.nova.conf.ca_file | default "cacert.pem" }}

#
# Filename of a private key.
#
# Related options:
#
# * keys_path
#  (string value)
# Deprecated group/name - [DEFAULT]/key_file
# from .crypto.nova.conf.key_file
{{ if not .crypto.nova.conf.key_file }}#{{ end }}key_file = {{ .crypto.nova.conf.key_file | default "private/cakey.pem" }}

#
# Filename of root Certificate Revocation List (CRL). This is a list of
# certificates that have been revoked, and therefore, entities presenting
# those (revoked) certificates should no longer be trusted.
#
# Related options:
#
# * ca_path
#  (string value)
# Deprecated group/name - [DEFAULT]/crl_file
# from .crypto.nova.conf.crl_file
{{ if not .crypto.nova.conf.crl_file }}#{{ end }}crl_file = {{ .crypto.nova.conf.crl_file | default "crl.pem" }}

#
# Directory path where keys are located.
#
# Related options:
#
# * key_file
#  (string value)
# Deprecated group/name - [DEFAULT]/keys_path
# from .crypto.nova.conf.keys_path
{{ if not .crypto.nova.conf.keys_path }}#{{ end }}keys_path = {{ .crypto.nova.conf.keys_path | default "$state_path/keys" }}

#
# Directory path where root CA is located.
#
# Related options:
#
# * ca_file
#  (string value)
# Deprecated group/name - [DEFAULT]/ca_path
# from .crypto.nova.conf.ca_path
{{ if not .crypto.nova.conf.ca_path }}#{{ end }}ca_path = {{ .crypto.nova.conf.ca_path | default "$state_path/CA" }}

# Option to enable/disable use of CA for each project. (boolean value)
# Deprecated group/name - [DEFAULT]/use_project_ca
# from .crypto.nova.conf.use_project_ca
{{ if not .crypto.nova.conf.use_project_ca }}#{{ end }}use_project_ca = {{ .crypto.nova.conf.use_project_ca | default "false" }}

#
# Subject for certificate for users, %s for
# project, user, timestamp
#  (string value)
# Deprecated group/name - [DEFAULT]/user_cert_subject
# from .crypto.nova.conf.user_cert_subject
{{ if not .crypto.nova.conf.user_cert_subject }}#{{ end }}user_cert_subject = {{ .crypto.nova.conf.user_cert_subject | default "/C=US/ST=California/O=OpenStack/OU=NovaDev/CN=%.16s-%.16s-%s" }}

#
# Subject for certificate for projects, %s for
# project, timestamp
#  (string value)
# Deprecated group/name - [DEFAULT]/project_cert_subject
# from .crypto.nova.conf.project_cert_subject
{{ if not .crypto.nova.conf.project_cert_subject }}#{{ end }}project_cert_subject = {{ .crypto.nova.conf.project_cert_subject | default "/C=US/ST=California/O=OpenStack/OU=NovaDev/CN=project-ca-%.16s-%s" }}


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


[ephemeral_storage_encryption]

#
# From nova.conf
#

#
# Enables/disables LVM ephemeral storage encryption.
#  (boolean value)
# from .ephemeral_storage_encryption.nova.conf.enabled
{{ if not .ephemeral_storage_encryption.nova.conf.enabled }}#{{ end }}enabled = {{ .ephemeral_storage_encryption.nova.conf.enabled | default "false" }}

#
# Cipher-mode string to be used
#
# The cipher and mode to be used to encrypt ephemeral
# storage. The set of cipher-mode combinations available
# depends on kernel support.
#
# Possible values:
#
#     * aes-xts-plain64 (Default), see /proc/crypto for available options.
#  (string value)
# from .ephemeral_storage_encryption.nova.conf.cipher
{{ if not .ephemeral_storage_encryption.nova.conf.cipher }}#{{ end }}cipher = {{ .ephemeral_storage_encryption.nova.conf.cipher | default "aes-xts-plain64" }}

#
# Encryption key length in bits
#
# The bit length of the encryption key to be used to
# encrypt ephemeral storage (in XTS mode only half of
# the bits are used for encryption key).
#  (integer value)
# Minimum value: 1
# from .ephemeral_storage_encryption.nova.conf.key_size
{{ if not .ephemeral_storage_encryption.nova.conf.key_size }}#{{ end }}key_size = {{ .ephemeral_storage_encryption.nova.conf.key_size | default "512" }}


[glance]

#
# From nova.conf
#

#
# A list of the glance api servers endpoints available to nova. These
# should be fully qualified urls of the form
# "scheme://hostname:port[/path]" (i.e. "http://10.0.1.0:9292" or
# "https://my.glance.server/image") (list value)
# from .glance.nova.conf.api_servers
{{ if not .glance.nova.conf.api_servers }}#{{ end }}api_servers = {{ .glance.nova.conf.api_servers | default "<None>" }}

# Allow to perform insecure SSL (https) requests to glance (boolean value)
# from .glance.nova.conf.api_insecure
{{ if not .glance.nova.conf.api_insecure }}#{{ end }}api_insecure = {{ .glance.nova.conf.api_insecure | default "false" }}

# Number of retries when uploading / downloading an image to / from glance.
# (integer value)
# from .glance.nova.conf.num_retries
{{ if not .glance.nova.conf.num_retries }}#{{ end }}num_retries = {{ .glance.nova.conf.num_retries | default "0" }}

# A list of url scheme that can be downloaded directly via the direct_url.
# Currently supported schemes: [file]. (list value)
# from .glance.nova.conf.allowed_direct_url_schemes
{{ if not .glance.nova.conf.allowed_direct_url_schemes }}#{{ end }}allowed_direct_url_schemes = {{ .glance.nova.conf.allowed_direct_url_schemes | default "" }}

# DEPRECATED:
# This flag allows reverting to glance v1 if for some reason glance v2 doesn't
# work in your environment. This will only exist in Newton, and a fully working
# Glance v2 will be a hard requirement in Ocata.
#
# * Possible values:
#
#     True or False
#
# * Services that use this:
#
#     ``nova-api``
#     ``nova-compute``
#     ``nova-conductor``
#
# * Related options:
#
#     None
#  (boolean value)
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# Reason: Glance v1 support will be removed in Ocata
# from .glance.nova.conf.use_glance_v1
{{ if not .glance.nova.conf.use_glance_v1 }}#{{ end }}use_glance_v1 = {{ .glance.nova.conf.use_glance_v1 | default "false" }}

# Require Nova to perform signature verification on each image downloaded from
# Glance. (boolean value)
# from .glance.nova.conf.verify_glance_signatures
{{ if not .glance.nova.conf.verify_glance_signatures }}#{{ end }}verify_glance_signatures = {{ .glance.nova.conf.verify_glance_signatures | default "false" }}

# Enable or disable debug logging with glanceclient. (boolean value)
# from .glance.nova.conf.debug
{{ if not .glance.nova.conf.debug }}#{{ end }}debug = {{ .glance.nova.conf.debug | default "false" }}


[guestfs]
#
# libguestfs is a set of tools for accessing and modifying virtual
# machine (VM) disk images. You can use this for viewing and editing
# files inside guests, scripting changes to VMs, monitoring disk
# used/free statistics, creating guests, P2V, V2V, performing backups,
# cloning VMs, building VMs, formatting disks and resizing disks.

#
# From nova.conf
#

#
# Enable/disables guestfs logging.
#
# This configures guestfs to debug messages and push them to Openstack
# logging system. When set to True, it traces libguestfs API calls and
# enable verbose debug messages. In order to use the above feature,
# "libguestfs" package must be installed.
#
# Related options:
# Since libguestfs access and modifies VM's managed by libvirt, below options
# should be set to give access to those VM's.
#     * libvirt.inject_key
#     * libvirt.inject_partition
#     * libvirt.inject_password
#  (boolean value)
# from .guestfs.nova.conf.debug
{{ if not .guestfs.nova.conf.debug }}#{{ end }}debug = {{ .guestfs.nova.conf.debug | default "false" }}


[hyperv]
#
# The hyperv feature allows you to configure the Hyper-V hypervisor
# driver to be used within an OpenStack deployment.

#
# From nova.conf
#

#
# Dynamic memory ratio
#
# Enables dynamic memory allocation (ballooning) when set to a value
# greater than 1. The value expresses the ratio between the total RAM
# assigned to an instance and its startup RAM amount. For example a
# ratio of 2.0 for an instance with 1024MB of RAM implies 512MB of
# RAM allocated at startup.
#
# Possible values:
#
# * 1.0: Disables dynamic memory allocation (Default).
# * Float values greater than 1.0: Enables allocation of total implied
#   RAM divided by this value for startup.
#  (floating point value)
# from .hyperv.nova.conf.dynamic_memory_ratio
{{ if not .hyperv.nova.conf.dynamic_memory_ratio }}#{{ end }}dynamic_memory_ratio = {{ .hyperv.nova.conf.dynamic_memory_ratio | default "1.0" }}

#
# Enable instance metrics collection
#
# Enables metrics collections for an instance by using Hyper-V's
# metric APIs. Collected data can by retrieved by other apps and
# services, e.g.: Ceilometer.
#  (boolean value)
# from .hyperv.nova.conf.enable_instance_metrics_collection
{{ if not .hyperv.nova.conf.enable_instance_metrics_collection }}#{{ end }}enable_instance_metrics_collection = {{ .hyperv.nova.conf.enable_instance_metrics_collection | default "false" }}

#
# Instances path share
#
# The name of a Windows share mapped to the "instances_path" dir
# and used by the resize feature to copy files to the target host.
# If left blank, an administrative share (hidden network share) will
# be used, looking for the same "instances_path" used locally.
#
# Possible values:
#
# * "": An administrative share will be used (Default).
# * Name of a Windows share.
#
# Related options:
#
# * "instances_path": The directory which will be used if this option
#   here is left blank.
#  (string value)
# from .hyperv.nova.conf.instances_path_share
{{ if not .hyperv.nova.conf.instances_path_share }}#{{ end }}instances_path_share = {{ .hyperv.nova.conf.instances_path_share | default "" }}

#
# Limit CPU features
#
# This flag is needed to support live migration to hosts with
# different CPU features and checked during instance creation
# in order to limit the CPU features used by the instance.
#  (boolean value)
# from .hyperv.nova.conf.limit_cpu_features
{{ if not .hyperv.nova.conf.limit_cpu_features }}#{{ end }}limit_cpu_features = {{ .hyperv.nova.conf.limit_cpu_features | default "false" }}

#
# Mounted disk query retry count
#
# The number of times to retry checking for a disk mounted via iSCSI.
# During long stress runs the WMI query that is looking for the iSCSI
# device number can incorrectly return no data. If the query is
# retried the appropriate data can then be obtained. The query runs
# until the device can be found or the retry count is reached.
#
# Possible values:
#
# * Positive integer values. Values greater than 1 is recommended
#   (Default: 10).
#
# Related options:
#
# * Time interval between disk mount retries is declared with
#   "mounted_disk_query_retry_interval" option.
#  (integer value)
# Minimum value: 0
# from .hyperv.nova.conf.mounted_disk_query_retry_count
{{ if not .hyperv.nova.conf.mounted_disk_query_retry_count }}#{{ end }}mounted_disk_query_retry_count = {{ .hyperv.nova.conf.mounted_disk_query_retry_count | default "10" }}

#
# Mounted disk query retry interval
#
# Interval between checks for a mounted iSCSI disk, in seconds.
#
# Possible values:
#
# * Time in seconds (Default: 5).
#
# Related options:
#
# * This option is meaningful when the mounted_disk_query_retry_count
#   is greater than 1.
# * The retry loop runs with mounted_disk_query_retry_count and
#   mounted_disk_query_retry_interval configuration options.
#  (integer value)
# Minimum value: 0
# from .hyperv.nova.conf.mounted_disk_query_retry_interval
{{ if not .hyperv.nova.conf.mounted_disk_query_retry_interval }}#{{ end }}mounted_disk_query_retry_interval = {{ .hyperv.nova.conf.mounted_disk_query_retry_interval | default "5" }}

#
# Power state check timeframe
#
# The timeframe to be checked for instance power state changes.
# This option is used to fetch the state of the instance from Hyper-V
# through the WMI interface, within the specified timeframe.
#
# Possible values:
#
# * Timeframe in seconds (Default: 60).
#  (integer value)
# Minimum value: 0
# from .hyperv.nova.conf.power_state_check_timeframe
{{ if not .hyperv.nova.conf.power_state_check_timeframe }}#{{ end }}power_state_check_timeframe = {{ .hyperv.nova.conf.power_state_check_timeframe | default "60" }}

#
# Power state event polling interval
#
# Instance power state change event polling frequency. Sets the
# listener interval for power state events to the given value.
# This option enhances the internal lifecycle notifications of
# instances that reboot themselves. It is unlikely that an operator
# has to change this value.
#
# Possible values:
#
# * Time in seconds (Default: 2).
#  (integer value)
# Minimum value: 0
# from .hyperv.nova.conf.power_state_event_polling_interval
{{ if not .hyperv.nova.conf.power_state_event_polling_interval }}#{{ end }}power_state_event_polling_interval = {{ .hyperv.nova.conf.power_state_event_polling_interval | default "2" }}

#
# qemu-img command
#
# qemu-img is required for some of the image related operations
# like converting between different image types. You can get it
# from here: (http://qemu.weilnetz.de/) or you can install the
# Cloudbase OpenStack Hyper-V Compute Driver
# (https://cloudbase.it/openstack-hyperv-driver/) which automatically
# sets the proper path for this config option. You can either give the
# full path of qemu-img.exe or set its path in the PATH environment
# variable and leave this option to the default value.
#
# Possible values:
#
# * Name of the qemu-img executable, in case it is in the same
#   directory as the nova-compute service or its path is in the
#   PATH environment variable (Default).
# * Path of qemu-img command (DRIVELETTER:\PATH\TO\QEMU-IMG\COMMAND).
#
# Related options:
#
# * If the config_drive_cdrom option is False, qemu-img will be used to
#   convert the ISO to a VHD, otherwise the configuration drive will
#   remain an ISO. To use configuration drive with Hyper-V, you must
#   set the mkisofs_cmd value to the full path to an mkisofs.exe
#   installation.
#  (string value)
# from .hyperv.nova.conf.qemu_img_cmd
{{ if not .hyperv.nova.conf.qemu_img_cmd }}#{{ end }}qemu_img_cmd = {{ .hyperv.nova.conf.qemu_img_cmd | default "qemu-img.exe" }}

#
# External virtual switch name
#
# The Hyper-V Virtual Switch is a software-based layer-2 Ethernet
# network switch that is available with the installation of the
# Hyper-V server role. The switch includes programmatically managed
# and extensible capabilities to connect virtual machines to both
# virtual networks and the physical network. In addition, Hyper-V
# Virtual Switch provides policy enforcement for security, isolation,
# and service levels. The vSwitch represented by this config option
# must be an external one (not internal or private).
#
# Possible values:
#
# * If not provided, the first of a list of available vswitches
#   is used. This list is queried using WQL.
# * Virtual switch name.
#  (string value)
# from .hyperv.nova.conf.vswitch_name
{{ if not .hyperv.nova.conf.vswitch_name }}#{{ end }}vswitch_name = {{ .hyperv.nova.conf.vswitch_name | default "<None>" }}

#
# Wait soft reboot seconds
#
# Number of seconds to wait for instance to shut down after soft
# reboot request is made. We fall back to hard reboot if instance
# does not shutdown within this window.
#
# Possible values:
#
# * Time in seconds (Default: 60).
#  (integer value)
# Minimum value: 0
# from .hyperv.nova.conf.wait_soft_reboot_seconds
{{ if not .hyperv.nova.conf.wait_soft_reboot_seconds }}#{{ end }}wait_soft_reboot_seconds = {{ .hyperv.nova.conf.wait_soft_reboot_seconds | default "60" }}

#
# Configuration drive cdrom
#
# OpenStack can be configured to write instance metadata to
# a configuration drive, which is then attached to the
# instance before it boots. The configuration drive can be
# attached as a disk drive (default) or as a CD drive.
#
# Possible values:
#
# * True: Attach the configuration drive image as a CD drive.
# * False: Attach the configuration drive image as a disk drive (Default).
#
# Related options:
#
# * This option is meaningful with force_config_drive option set to 'True'
#   or when the REST API call to create an instance will have
#   '--config-drive=True' flag.
# * config_drive_format option must be set to 'iso9660' in order to use
#   CD drive as the configuration drive image.
# * To use configuration drive with Hyper-V, you must set the
#   mkisofs_cmd value to the full path to an mkisofs.exe installation.
#   Additionally, you must set the qemu_img_cmd value to the full path
#   to an qemu-img command installation.
# * You can configure the Compute service to always create a configuration
#   drive by setting the force_config_drive option to 'True'.
#  (boolean value)
# from .hyperv.nova.conf.config_drive_cdrom
{{ if not .hyperv.nova.conf.config_drive_cdrom }}#{{ end }}config_drive_cdrom = {{ .hyperv.nova.conf.config_drive_cdrom | default "false" }}

#
# Configuration drive inject password
#
# Enables setting the admin password in the configuration drive image.
#
# Related options:
#
# * This option is meaningful when used with other options that enable
#   configuration drive usage with Hyper-V, such as force_config_drive.
# * Currently, the only accepted config_drive_format is 'iso9660'.
#  (boolean value)
# from .hyperv.nova.conf.config_drive_inject_password
{{ if not .hyperv.nova.conf.config_drive_inject_password }}#{{ end }}config_drive_inject_password = {{ .hyperv.nova.conf.config_drive_inject_password | default "false" }}

#
# Volume attach retry count
#
# The number of times to retry to attach a volume. This option is used
# to avoid incorrectly returned no data when the system is under load.
# Volume attachment is retried until success or the given retry count
# is reached. To prepare the Hyper-V node to be able to attach to
# volumes provided by cinder you must first make sure the Windows iSCSI
# initiator service is running and started automatically.
#
# Possible values:
#
# * Positive integer values (Default: 10).
#
# Related options:
#
# * Time interval between attachment attempts is declared with
#   volume_attach_retry_interval option.
#  (integer value)
# Minimum value: 0
# from .hyperv.nova.conf.volume_attach_retry_count
{{ if not .hyperv.nova.conf.volume_attach_retry_count }}#{{ end }}volume_attach_retry_count = {{ .hyperv.nova.conf.volume_attach_retry_count | default "10" }}

#
# Volume attach retry interval
#
# Interval between volume attachment attempts, in seconds.
#
# Possible values:
#
# * Time in seconds (Default: 5).
#
# Related options:
#
# * This options is meaningful when volume_attach_retry_count
#   is greater than 1.
# * The retry loop runs with volume_attach_retry_count and
#   volume_attach_retry_interval configuration options.
#  (integer value)
# Minimum value: 0
# from .hyperv.nova.conf.volume_attach_retry_interval
{{ if not .hyperv.nova.conf.volume_attach_retry_interval }}#{{ end }}volume_attach_retry_interval = {{ .hyperv.nova.conf.volume_attach_retry_interval | default "5" }}

#
# Enable RemoteFX feature
#
# This requires at least one DirectX 11 capable graphics adapter for
# Windows / Hyper-V Server 2012 R2 or newer and RDS-Virtualization
# feature has to be enabled.
#
# Instances with RemoteFX can be requested with the following flavor
# extra specs:
#
# **os:resolution**. Guest VM screen resolution size. Acceptable values::
#
#     1024x768, 1280x1024, 1600x1200, 1920x1200, 2560x1600, 3840x2160
#
# ``3840x2160`` is only available on Windows / Hyper-V Server 2016.
#
# **os:monitors**. Guest VM number of monitors. Acceptable values::
#
#     [1, 4] - Windows / Hyper-V Server 2012 R2
#     [1, 8] - Windows / Hyper-V Server 2016
#
# **os:vram**. Guest VM VRAM amount. Only available on
# Windows / Hyper-V Server 2016. Acceptable values::
#
#     64, 128, 256, 512, 1024
#  (boolean value)
# from .hyperv.nova.conf.enable_remotefx
{{ if not .hyperv.nova.conf.enable_remotefx }}#{{ end }}enable_remotefx = {{ .hyperv.nova.conf.enable_remotefx | default "false" }}


[image_file_url]

#
# From nova.conf
#

# DEPRECATED:
# List of file systems that are configured in this file in the
# image_file_url:<list entry name> sections
#  (list value)
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# Reason:
# The feature to download images from glance via filesystem is not used and will
# be removed in the future.
# from .image_file_url.nova.conf.filesystems
{{ if not .image_file_url.nova.conf.filesystems }}#{{ end }}filesystems = {{ .image_file_url.nova.conf.filesystems | default "" }}


[ironic]
#
# Configuration options for Ironic driver (Bare Metal).
# If using the Ironic driver following options must be set:
# * auth_type
# * auth_url
# * project_name
# * username
# * password
# * project_domain_id or project_domain_name
# * user_domain_id or user_domain_name
#
# Please note that if you are using Identity v2 API (deprecated),
# you don't need to provide domain information, since domains are
# a v3 concept.

#
# From nova.conf
#

# URL override for the Ironic API endpoint. (string value)
# from .ironic.nova.conf.api_endpoint
{{ if not .ironic.nova.conf.api_endpoint }}#{{ end }}api_endpoint = {{ .ironic.nova.conf.api_endpoint | default "http://ironic.example.org:6385/" }}

# DEPRECATED: Ironic keystone admin name. Use ``username`` instead. (string
# value)
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# from .ironic.nova.conf.admin_username
{{ if not .ironic.nova.conf.admin_username }}#{{ end }}admin_username = {{ .ironic.nova.conf.admin_username | default "<None>" }}

# DEPRECATED: Ironic keystone admin password. Use ``password`` instead. (string
# value)
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# from .ironic.nova.conf.admin_password
{{ if not .ironic.nova.conf.admin_password }}#{{ end }}admin_password = {{ .ironic.nova.conf.admin_password | default "<None>" }}

# DEPRECATED: Keystone public API endpoint. Use ``auth_url`` instead. (string
# value)
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# from .ironic.nova.conf.admin_url
{{ if not .ironic.nova.conf.admin_url }}#{{ end }}admin_url = {{ .ironic.nova.conf.admin_url | default "<None>" }}

# DEPRECATED: Ironic keystone tenant name. Use ``project_name`` instead. (string
# value)
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# from .ironic.nova.conf.admin_tenant_name
{{ if not .ironic.nova.conf.admin_tenant_name }}#{{ end }}admin_tenant_name = {{ .ironic.nova.conf.admin_tenant_name | default "<None>" }}

#
# The number of times to retry when a request conflicts.
# If set to 0, only try once, no retries.
#
# Related options:
#
# * api_retry_interval
#  (integer value)
# Minimum value: 0
# from .ironic.nova.conf.api_max_retries
{{ if not .ironic.nova.conf.api_max_retries }}#{{ end }}api_max_retries = {{ .ironic.nova.conf.api_max_retries | default "60" }}

#
# The number of seconds to wait before retrying the request.
#
# Related options:
#
# * api_max_retries
#  (integer value)
# Minimum value: 0
# from .ironic.nova.conf.api_retry_interval
{{ if not .ironic.nova.conf.api_retry_interval }}#{{ end }}api_retry_interval = {{ .ironic.nova.conf.api_retry_interval | default "2" }}

# PEM encoded Certificate Authority to use when verifying HTTPs connections.
# (string value)
# from .ironic.nova.conf.cafile
{{ if not .ironic.nova.conf.cafile }}#{{ end }}cafile = {{ .ironic.nova.conf.cafile | default "<None>" }}

# PEM encoded client certificate cert file (string value)
# from .ironic.nova.conf.certfile
{{ if not .ironic.nova.conf.certfile }}#{{ end }}certfile = {{ .ironic.nova.conf.certfile | default "<None>" }}

# PEM encoded client certificate key file (string value)
# from .ironic.nova.conf.keyfile
{{ if not .ironic.nova.conf.keyfile }}#{{ end }}keyfile = {{ .ironic.nova.conf.keyfile | default "<None>" }}

# Verify HTTPS connections. (boolean value)
# from .ironic.nova.conf.insecure
{{ if not .ironic.nova.conf.insecure }}#{{ end }}insecure = {{ .ironic.nova.conf.insecure | default "false" }}

# Timeout value for http requests (integer value)
# from .ironic.nova.conf.timeout
{{ if not .ironic.nova.conf.timeout }}#{{ end }}timeout = {{ .ironic.nova.conf.timeout | default "<None>" }}

# Authentication type to load (string value)
# Deprecated group/name - [ironic]/auth_plugin
# from .ironic.nova.conf.auth_type
{{ if not .ironic.nova.conf.auth_type }}#{{ end }}auth_type = {{ .ironic.nova.conf.auth_type | default "<None>" }}

# Config Section from which to load plugin specific options (string value)
# from .ironic.nova.conf.auth_section
{{ if not .ironic.nova.conf.auth_section }}#{{ end }}auth_section = {{ .ironic.nova.conf.auth_section | default "<None>" }}

# Authentication URL (string value)
# from .ironic.nova.conf.auth_url
{{ if not .ironic.nova.conf.auth_url }}#{{ end }}auth_url = {{ .ironic.nova.conf.auth_url | default "<None>" }}

# Domain ID to scope to (string value)
# from .ironic.nova.conf.domain_id
{{ if not .ironic.nova.conf.domain_id }}#{{ end }}domain_id = {{ .ironic.nova.conf.domain_id | default "<None>" }}

# Domain name to scope to (string value)
# from .ironic.nova.conf.domain_name
{{ if not .ironic.nova.conf.domain_name }}#{{ end }}domain_name = {{ .ironic.nova.conf.domain_name | default "<None>" }}

# Project ID to scope to (string value)
# from .ironic.nova.conf.project_id
{{ if not .ironic.nova.conf.project_id }}#{{ end }}project_id = {{ .ironic.nova.conf.project_id | default "<None>" }}

# Project name to scope to (string value)
# from .ironic.nova.conf.project_name
{{ if not .ironic.nova.conf.project_name }}#{{ end }}project_name = {{ .ironic.nova.conf.project_name | default "<None>" }}

# Domain ID containing project (string value)
# from .ironic.nova.conf.project_domain_id
{{ if not .ironic.nova.conf.project_domain_id }}#{{ end }}project_domain_id = {{ .ironic.nova.conf.project_domain_id | default "<None>" }}

# Domain name containing project (string value)
# from .ironic.nova.conf.project_domain_name
{{ if not .ironic.nova.conf.project_domain_name }}#{{ end }}project_domain_name = {{ .ironic.nova.conf.project_domain_name | default "<None>" }}

# Trust ID (string value)
# from .ironic.nova.conf.trust_id
{{ if not .ironic.nova.conf.trust_id }}#{{ end }}trust_id = {{ .ironic.nova.conf.trust_id | default "<None>" }}

# User ID (string value)
# from .ironic.nova.conf.user_id
{{ if not .ironic.nova.conf.user_id }}#{{ end }}user_id = {{ .ironic.nova.conf.user_id | default "<None>" }}

# Username (string value)
# Deprecated group/name - [ironic]/user-name
# from .ironic.nova.conf.username
{{ if not .ironic.nova.conf.username }}#{{ end }}username = {{ .ironic.nova.conf.username | default "<None>" }}

# User's domain id (string value)
# from .ironic.nova.conf.user_domain_id
{{ if not .ironic.nova.conf.user_domain_id }}#{{ end }}user_domain_id = {{ .ironic.nova.conf.user_domain_id | default "<None>" }}

# User's domain name (string value)
# from .ironic.nova.conf.user_domain_name
{{ if not .ironic.nova.conf.user_domain_name }}#{{ end }}user_domain_name = {{ .ironic.nova.conf.user_domain_name | default "<None>" }}

# User's password (string value)
# from .ironic.nova.conf.password
{{ if not .ironic.nova.conf.password }}#{{ end }}password = {{ .ironic.nova.conf.password | default "<None>" }}


[key_manager]

#
# From nova.conf
#

#
# Fixed key returned by key manager, specified in hex.
#
# Possible values:
#
# * Empty string or a key in hex value
#  (string value)
# Deprecated group/name - [keymgr]/fixed_key
# from .key_manager.nova.conf.fixed_key
{{ if not .key_manager.nova.conf.fixed_key }}#{{ end }}fixed_key = {{ .key_manager.nova.conf.fixed_key | default "<None>" }}

# The full class name of the key manager API class (string value)
# from .key_manager.nova.conf.api_class
{{ if not .key_manager.nova.conf.api_class }}#{{ end }}api_class = {{ .key_manager.nova.conf.api_class | default "castellan.key_manager.barbican_key_manager.BarbicanKeyManager" }}

# The type of authentication credential to create. Possible values are 'token',
# 'password', 'keystone_token', and 'keystone_password'. Required if no context
# is passed to the credential factory. (string value)
# from .key_manager.nova.conf.auth_type
{{ if not .key_manager.nova.conf.auth_type }}#{{ end }}auth_type = {{ .key_manager.nova.conf.auth_type | default "<None>" }}

# Token for authentication. Required for 'token' and 'keystone_token' auth_type
# if no context is passed to the credential factory. (string value)
# from .key_manager.nova.conf.token
{{ if not .key_manager.nova.conf.token }}#{{ end }}token = {{ .key_manager.nova.conf.token | default "<None>" }}

# Username for authentication. Required for 'password' auth_type. Optional for
# the 'keystone_password' auth_type. (string value)
# from .key_manager.nova.conf.username
{{ if not .key_manager.nova.conf.username }}#{{ end }}username = {{ .key_manager.nova.conf.username | default "<None>" }}

# Password for authentication. Required for 'password' and 'keystone_password'
# auth_type. (string value)
# from .key_manager.nova.conf.password
{{ if not .key_manager.nova.conf.password }}#{{ end }}password = {{ .key_manager.nova.conf.password | default "<None>" }}

# User ID for authentication. Optional for 'keystone_token' and
# 'keystone_password' auth_type. (string value)
# from .key_manager.nova.conf.user_id
{{ if not .key_manager.nova.conf.user_id }}#{{ end }}user_id = {{ .key_manager.nova.conf.user_id | default "<None>" }}

# User's domain ID for authentication. Optional for 'keystone_token' and
# 'keystone_password' auth_type. (string value)
# from .key_manager.nova.conf.user_domain_id
{{ if not .key_manager.nova.conf.user_domain_id }}#{{ end }}user_domain_id = {{ .key_manager.nova.conf.user_domain_id | default "<None>" }}

# User's domain name for authentication. Optional for 'keystone_token' and
# 'keystone_password' auth_type. (string value)
# from .key_manager.nova.conf.user_domain_name
{{ if not .key_manager.nova.conf.user_domain_name }}#{{ end }}user_domain_name = {{ .key_manager.nova.conf.user_domain_name | default "<None>" }}

# Trust ID for trust scoping. Optional for 'keystone_token' and
# 'keystone_password' auth_type. (string value)
# from .key_manager.nova.conf.trust_id
{{ if not .key_manager.nova.conf.trust_id }}#{{ end }}trust_id = {{ .key_manager.nova.conf.trust_id | default "<None>" }}

# Domain ID for domain scoping. Optional for 'keystone_token' and
# 'keystone_password' auth_type. (string value)
# from .key_manager.nova.conf.domain_id
{{ if not .key_manager.nova.conf.domain_id }}#{{ end }}domain_id = {{ .key_manager.nova.conf.domain_id | default "<None>" }}

# Domain name for domain scoping. Optional for 'keystone_token' and
# 'keystone_password' auth_type. (string value)
# from .key_manager.nova.conf.domain_name
{{ if not .key_manager.nova.conf.domain_name }}#{{ end }}domain_name = {{ .key_manager.nova.conf.domain_name | default "<None>" }}

# Project ID for project scoping. Optional for 'keystone_token' and
# 'keystone_password' auth_type. (string value)
# from .key_manager.nova.conf.project_id
{{ if not .key_manager.nova.conf.project_id }}#{{ end }}project_id = {{ .key_manager.nova.conf.project_id | default "<None>" }}

# Project name for project scoping. Optional for 'keystone_token' and
# 'keystone_password' auth_type. (string value)
# from .key_manager.nova.conf.project_name
{{ if not .key_manager.nova.conf.project_name }}#{{ end }}project_name = {{ .key_manager.nova.conf.project_name | default "<None>" }}

# Project's domain ID for project. Optional for 'keystone_token' and
# 'keystone_password' auth_type. (string value)
# from .key_manager.nova.conf.project_domain_id
{{ if not .key_manager.nova.conf.project_domain_id }}#{{ end }}project_domain_id = {{ .key_manager.nova.conf.project_domain_id | default "<None>" }}

# Project's domain name for project. Optional for 'keystone_token' and
# 'keystone_password' auth_type. (string value)
# from .key_manager.nova.conf.project_domain_name
{{ if not .key_manager.nova.conf.project_domain_name }}#{{ end }}project_domain_name = {{ .key_manager.nova.conf.project_domain_name | default "<None>" }}

# Allow fetching a new token if the current one is going to expire. Optional for
# 'keystone_token' and 'keystone_password' auth_type. (boolean value)
# from .key_manager.nova.conf.reauthenticate
{{ if not .key_manager.nova.conf.reauthenticate }}#{{ end }}reauthenticate = {{ .key_manager.nova.conf.reauthenticate | default "true" }}


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
# "admin" endpoint, as it should be accessible by all end users. Unauthenticated
# clients are redirected to this endpoint to authenticate. Although this
# endpoint should  ideally be unversioned, client support in the wild varies.
# If you're using a versioned v2 endpoint here, then this  should *not* be the
# same endpoint the service user utilizes  for validating tokens, because normal
# end users may not be  able to reach that endpoint. (string value)
# from .keystone_authtoken.keystonemiddleware.auth_token.auth_uri
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.auth_uri }}#{{ end }}auth_uri = {{ .keystone_authtoken.keystonemiddleware.auth_token.auth_uri | default "<None>" }}

# FIXME(alanmeadows) - added for some newton images using older keystoneauth1 libs but are still "newton"
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.auth_url }}#{{ end }}auth_url = {{ .keystone_authtoken.keystonemiddleware.auth_token.auth_url | default "<None>" }}

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


[libvirt]
#
# Libvirt options allows cloud administrator to configure related
# libvirt hypervisor driver to be used within an OpenStack deployment.

#
# From nova.conf
#

#
# The ID of the image to boot from to rescue data from a corrupted instance.
#
# If the rescue REST API operation doesn't provide an ID of an image to
# use, the image which is referenced by this ID is used. If this
# option is not set, the image from the instance is used.
#
# Possible values:
#
# * An ID of an image or nothing. If it points to an *Amazon Machine
#   Image* (AMI), consider to set the config options ``rescue_kernel_id``
#   and ``rescue_ramdisk_id`` too. If nothing is set, the image of the instance
#   is used.
#
# Related options:
#
# * ``rescue_kernel_id``: If the chosen rescue image allows the separate
#   definition of its kernel disk, the value of this option is used,
#   if specified. This is the case when *Amazon*'s AMI/AKI/ARI image
#   format is used for the rescue image.
# * ``rescue_ramdisk_id``: If the chosen rescue image allows the separate
#   definition of its RAM disk, the value of this option is used if,
#   specified. This is the case when *Amazon*'s AMI/AKI/ARI image
#   format is used for the rescue image.
#  (string value)
# from .libvirt.nova.conf.rescue_image_id
{{ if not .libvirt.nova.conf.rescue_image_id }}#{{ end }}rescue_image_id = {{ .libvirt.nova.conf.rescue_image_id | default "<None>" }}

#
# The ID of the kernel (AKI) image to use with the rescue image.
#
# If the chosen rescue image allows the separate definition of its kernel
# disk, the value of this option is used, if specified. This is the case
# when *Amazon*'s AMI/AKI/ARI image format is used for the rescue image.
#
# Possible values:
#
# * An ID of an kernel image or nothing. If nothing is specified, the kernel
#   disk from the instance is used if it was launched with one.
#
# Related options:
#
# * ``rescue_image_id``: If that option points to an image in *Amazon*'s
#   AMI/AKI/ARI image format, it's useful to use ``rescue_kernel_id`` too.
#  (string value)
# from .libvirt.nova.conf.rescue_kernel_id
{{ if not .libvirt.nova.conf.rescue_kernel_id }}#{{ end }}rescue_kernel_id = {{ .libvirt.nova.conf.rescue_kernel_id | default "<None>" }}

#
# The ID of the RAM disk (ARI) image to use with the rescue image.
#
# If the chosen rescue image allows the separate definition of its RAM
# disk, the value of this option is used, if specified. This is the case
# when *Amazon*'s AMI/AKI/ARI image format is used for the rescue image.
#
# Possible values:
#
# * An ID of a RAM disk image or nothing. If nothing is specified, the RAM
#   disk from the instance is used if it was launched with one.
#
# Related options:
#
# * ``rescue_image_id``: If that option points to an image in *Amazon*'s
#   AMI/AKI/ARI image format, it's useful to use ``rescue_ramdisk_id`` too.
#  (string value)
# from .libvirt.nova.conf.rescue_ramdisk_id
{{ if not .libvirt.nova.conf.rescue_ramdisk_id }}#{{ end }}rescue_ramdisk_id = {{ .libvirt.nova.conf.rescue_ramdisk_id | default "<None>" }}

#
# Describes the virtualization type (or so called domain type) libvirt should
# use.
#
# The choice of this type must match the underlying virtualization strategy
# you have chosen for this host.
#
# Possible values:
#
# * See the predefined set of case-sensitive values.
#
# Related options:
#
# * ``connection_uri``: depends on this
# * ``disk_prefix``: depends on this
# * ``cpu_mode``: depends on this
# * ``cpu_model``: depends on this
#  (string value)
# Allowed values: kvm, lxc, qemu, uml, xen, parallels
# from .libvirt.nova.conf.virt_type
{{ if not .libvirt.nova.conf.virt_type }}#{{ end }}virt_type = {{ .libvirt.nova.conf.virt_type | default "kvm" }}

#
# Overrides the default libvirt URI of the chosen virtualization type.
#
# If set, Nova will use this URI to connect to libvirt.
#
# Possible values:
#
# * An URI like ``qemu:///system`` or ``xen+ssh://oirase/`` for example.
#   This is only necessary if the URI differs to the commonly known URIs
#   for the chosen virtualization type.
#
# Related options:
#
# * ``virt_type``: Influences what is used as default value here.
#  (string value)
# from .libvirt.nova.conf.connection_uri
{{ if not .libvirt.nova.conf.connection_uri }}#{{ end }}connection_uri = {{ .libvirt.nova.conf.connection_uri | default "" }}

#
# Allow the injection of an admin password for instance only at ``create`` and
# ``rebuild`` process.
#
# There is no agent needed within the image to do this. If *libguestfs* is
# available on the host, it will be used. Otherwise *nbd* is used. The file
# system of the image will be mounted and the admin password, which is provided
# in the REST API call will be injected as password for the root user. If no
# root user is available, the instance won't be launched and an error is thrown.
# Be aware that the injection is *not* possible when the instance gets launched
# from a volume.
#
# Possible values:
#
# * True: Allows the injection.
# * False (default): Disallows the injection. Any via the REST API provided
# admin password will be silently ignored.
#
# Related options:
#
# * ``inject_partition``: That option will decide about the discovery and usage
#   of the file system. It also can disable the injection at all.
#  (boolean value)
# from .libvirt.nova.conf.inject_password
{{ if not .libvirt.nova.conf.inject_password }}#{{ end }}inject_password = {{ .libvirt.nova.conf.inject_password | default "false" }}

#
# Allow the injection of an SSH key at boot time.
#
# There is no agent needed within the image to do this. If *libguestfs* is
# available on the host, it will be used. Otherwise *nbd* is used. The file
# system of the image will be mounted and the SSH key, which is provided
# in the REST API call will be injected as SSH key for the root user and
# appended to the ``authorized_keys`` of that user. The SELinux context will
# be set if necessary. Be aware that the injection is *not* possible when the
# instance gets launched from a volume.
#
# This config option will enable directly modifying the instance disk and does
# not affect what cloud-init may do using data from config_drive option or the
# metadata service.
#
# Related options:
#
# * ``inject_partition``: That option will decide about the discovery and usage
#   of the file system. It also can disable the injection at all.
#  (boolean value)
# from .libvirt.nova.conf.inject_key
{{ if not .libvirt.nova.conf.inject_key }}#{{ end }}inject_key = {{ .libvirt.nova.conf.inject_key | default "false" }}

#
# Determines the way how the file system is chosen to inject data into it.
#
# *libguestfs* will be used a first solution to inject data. If that's not
# available on the host, the image will be locally mounted on the host as a
# fallback solution. If libguestfs is not able to determine the root partition
# (because there are more or less than one root partition) or cannot mount the
# file system it will result in an error and the instance won't be boot.
#
# Possible values:
#
# * -2 => disable the injection of data.
# * -1 => find the root partition with the file system to mount with libguestfs
# *  0 => The image is not partitioned
# * >0 => The number of the partition to use for the injection
#
# Related options:
#
# * ``inject_key``: If this option allows the injection of a SSH key it depends
#   on value greater or equal to -1 for ``inject_partition``.
# * ``inject_password``: If this option allows the injection of an admin
# password
#   it depends on value greater or equal to -1 for ``inject_partition``.
# * ``guestfs`` You can enable the debug log level of libguestfs with this
#   config option. A more verbose output will help in debugging issues.
# * ``virt_type``: If you use ``lxc`` as virt_type it will be treated as a
#   single partition image
#  (integer value)
# Minimum value: -2
# from .libvirt.nova.conf.inject_partition
{{ if not .libvirt.nova.conf.inject_partition }}#{{ end }}inject_partition = {{ .libvirt.nova.conf.inject_partition | default "-2" }}

# DEPRECATED:
# Enable a mouse cursor within a graphical VNC or SPICE sessions.
#
# This will only be taken into account if the VM is fully virtualized and VNC
# and/or SPICE is enabled. If the node doesn't support a graphical framebuffer,
# then it is valid to set this to False.
#
# Related options:
# * ``[vnc]enabled``: If VNC is enabled, ``use_usb_tablet`` will have an effect.
# * ``[spice]enabled`` + ``[spice].agent_enabled``: If SPICE is enabled and the
#   spice agent is disabled, the config value of ``use_usb_tablet`` will have
#   an effect.
#  (boolean value)
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# Reason: This option is being replaced by the 'pointer_model' option.
# from .libvirt.nova.conf.use_usb_tablet
{{ if not .libvirt.nova.conf.use_usb_tablet }}#{{ end }}use_usb_tablet = {{ .libvirt.nova.conf.use_usb_tablet | default "true" }}

# Live migration target ip or hostname (if this option is set to None, which is
# the default, the hostname of the migration target compute node will be used)
# (string value)
# from .libvirt.nova.conf.live_migration_inbound_addr
{{ if not .libvirt.nova.conf.live_migration_inbound_addr }}#{{ end }}live_migration_inbound_addr = {{ .libvirt.nova.conf.live_migration_inbound_addr | default "<None>" }}

# Override the default libvirt live migration target URI (which is dependent on
# virt_type) (any included "%s" is replaced with the migration target hostname)
# (string value)
# from .libvirt.nova.conf.live_migration_uri
{{ if not .libvirt.nova.conf.live_migration_uri }}#{{ end }}live_migration_uri = {{ .libvirt.nova.conf.live_migration_uri | default "<None>" }}

# Whether to use tunnelled migration, where migration data is transported over
# the libvirtd connection. If True, we use the VIR_MIGRATE_TUNNELLED migration
# flag, avoiding the need to configure the network to allow direct hypervisor to
# hypervisor communication. If False, use the native transport. If not set, Nova
# will choose a sensible default based on, for example the availability of
# native encryption support in the hypervisor. (boolean value)
# from .libvirt.nova.conf.live_migration_tunnelled
{{ if not .libvirt.nova.conf.live_migration_tunnelled }}#{{ end }}live_migration_tunnelled = {{ .libvirt.nova.conf.live_migration_tunnelled | default "false" }}

# Maximum bandwidth(in MiB/s) to be used during migration. If set to 0, will
# choose a suitable default. Some hypervisors do not support this feature and
# will return an error if bandwidth is not 0. Please refer to the libvirt
# documentation for further details (integer value)
# from .libvirt.nova.conf.live_migration_bandwidth
{{ if not .libvirt.nova.conf.live_migration_bandwidth }}#{{ end }}live_migration_bandwidth = {{ .libvirt.nova.conf.live_migration_bandwidth | default "0" }}

# Maximum permitted downtime, in milliseconds, for live migration switchover.
# Will be rounded up to a minimum of 100ms. Use a large value if guest liveness
# is unimportant. (integer value)
# from .libvirt.nova.conf.live_migration_downtime
{{ if not .libvirt.nova.conf.live_migration_downtime }}#{{ end }}live_migration_downtime = {{ .libvirt.nova.conf.live_migration_downtime | default "500" }}

# Number of incremental steps to reach max downtime value. Will be rounded up to
# a minimum of 3 steps (integer value)
# from .libvirt.nova.conf.live_migration_downtime_steps
{{ if not .libvirt.nova.conf.live_migration_downtime_steps }}#{{ end }}live_migration_downtime_steps = {{ .libvirt.nova.conf.live_migration_downtime_steps | default "10" }}

# Time to wait, in seconds, between each step increase of the migration
# downtime. Minimum delay is 10 seconds. Value is per GiB of guest RAM + disk to
# be transferred, with lower bound of a minimum of 2 GiB per device (integer
# value)
# from .libvirt.nova.conf.live_migration_downtime_delay
{{ if not .libvirt.nova.conf.live_migration_downtime_delay }}#{{ end }}live_migration_downtime_delay = {{ .libvirt.nova.conf.live_migration_downtime_delay | default "75" }}

# Time to wait, in seconds, for migration to successfully complete transferring
# data before aborting the operation. Value is per GiB of guest RAM + disk to be
# transferred, with lower bound of a minimum of 2 GiB. Should usually be larger
# than downtime delay * downtime steps. Set to 0 to disable timeouts. (integer
# value)
# Note: This option can be changed without restarting.
# from .libvirt.nova.conf.live_migration_completion_timeout
{{ if not .libvirt.nova.conf.live_migration_completion_timeout }}#{{ end }}live_migration_completion_timeout = {{ .libvirt.nova.conf.live_migration_completion_timeout | default "800" }}

# Time to wait, in seconds, for migration to make forward progress in
# transferring data before aborting the operation. Set to 0 to disable timeouts.
# (integer value)
# Note: This option can be changed without restarting.
# from .libvirt.nova.conf.live_migration_progress_timeout
{{ if not .libvirt.nova.conf.live_migration_progress_timeout }}#{{ end }}live_migration_progress_timeout = {{ .libvirt.nova.conf.live_migration_progress_timeout | default "150" }}

#
# This option allows nova to switch an on-going live migration to post-copy
# mode, i.e., switch the active VM to the one on the destination node before the
# migration is complete, therefore ensuring an upper bound on the memory that
# needs to be transferred. Post-copy requires libvirt>=1.3.3 and QEMU>=2.5.0.
#
# When permitted, post-copy mode will be automatically activated if a
# live-migration memory copy iteration does not make percentage increase of at
# least 10% over the last iteration.
#
# The live-migration force complete API also uses post-copy when permitted. If
# post-copy mode is not available, force complete falls back to pausing the VM
# to ensure the live-migration operation will complete.
#
# When using post-copy mode, if the source and destination hosts loose network
# connectivity, the VM being live-migrated will need to be rebooted. For more
# details, please see the Administration guide.
#
# Related options:
#
#     * live_migration_permit_auto_converge
#  (boolean value)
# from .libvirt.nova.conf.live_migration_permit_post_copy
{{ if not .libvirt.nova.conf.live_migration_permit_post_copy }}#{{ end }}live_migration_permit_post_copy = {{ .libvirt.nova.conf.live_migration_permit_post_copy | default "false" }}

#
# This option allows nova to start live migration with auto converge on.
# Auto converge throttles down CPU if a progress of on-going live migration
# is slow. Auto converge will only be used if this flag is set to True and
# post copy is not permitted or post copy is unavailable due to the version
# of libvirt and QEMU in use. Auto converge requires libvirt>=1.2.3 and
# QEMU>=1.6.0.
#
# Related options:
#
#     * live_migration_permit_post_copy
#  (boolean value)
# from .libvirt.nova.conf.live_migration_permit_auto_converge
{{ if not .libvirt.nova.conf.live_migration_permit_auto_converge }}#{{ end }}live_migration_permit_auto_converge = {{ .libvirt.nova.conf.live_migration_permit_auto_converge | default "false" }}

# Snapshot image format. Defaults to same as source image (string value)
# Allowed values: raw, qcow2, vmdk, vdi
# from .libvirt.nova.conf.snapshot_image_format
{{ if not .libvirt.nova.conf.snapshot_image_format }}#{{ end }}snapshot_image_format = {{ .libvirt.nova.conf.snapshot_image_format | default "<None>" }}

#
# Override the default disk prefix for the devices attached to an instance.
#
# If set, this is used to identify a free disk device name for a bus.
#
# Possible values:
#
# * Any prefix which will result in a valid disk device name like 'sda' or 'hda'
#   for example. This is only necessary if the device names differ to the
#   commonly known device name prefixes for a virtualization type such as: sd,
#   xvd, uvd, vd.
#
# Related options:
#
# * ``virt_type``: Influences which device type is used, which determines
#   the default disk prefix.
#  (string value)
# from .libvirt.nova.conf.disk_prefix
{{ if not .libvirt.nova.conf.disk_prefix }}#{{ end }}disk_prefix = {{ .libvirt.nova.conf.disk_prefix | default "<None>" }}

# Number of seconds to wait for instance to shut down after soft reboot request
# is made. We fall back to hard reboot if instance does not shutdown within this
# window. (integer value)
# from .libvirt.nova.conf.wait_soft_reboot_seconds
{{ if not .libvirt.nova.conf.wait_soft_reboot_seconds }}#{{ end }}wait_soft_reboot_seconds = {{ .libvirt.nova.conf.wait_soft_reboot_seconds | default "120" }}

#
# Is used to set the CPU mode an instance should have.
#
# If virt_type="kvm|qemu", it will default to "host-model", otherwise it will
# default to "none".
#
# Possible values:
#
# * ``host-model``: Clones the host CPU feature flags.
# * ``host-passthrough``: Use the host CPU model exactly;
# * ``custom``: Use a named CPU model;
# * ``none``: Not set any CPU model.
#
# Related options:
#
# * ``cpu_model``: If ``custom`` is used for ``cpu_mode``, set this config
#   option too, otherwise this would result in an error and the instance won't
#   be launched.
#  (string value)
# Allowed values: host-model, host-passthrough, custom, none
# from .libvirt.nova.conf.cpu_mode
{{ if not .libvirt.nova.conf.cpu_mode }}#{{ end }}cpu_mode = {{ .libvirt.nova.conf.cpu_mode | default "<None>" }}

#
# Set the name of the libvirt CPU model the instance should use.
#
# Possible values:
#
# * The names listed in /usr/share/libvirt/cpu_map.xml
#
# Related options:
#
# * ``cpu_mode``: Don't set this when ``cpu_mode`` is NOT set to ``custom``.
#   This would result in an error and the instance won't be launched.
# * ``virt_type``: Only the virtualization types ``kvm`` and ``qemu`` use this.
#  (string value)
# from .libvirt.nova.conf.cpu_model
{{ if not .libvirt.nova.conf.cpu_model }}#{{ end }}cpu_model = {{ .libvirt.nova.conf.cpu_model | default "<None>" }}

# Location where libvirt driver will store snapshots before uploading them to
# image service (string value)
# from .libvirt.nova.conf.snapshots_directory
{{ if not .libvirt.nova.conf.snapshots_directory }}#{{ end }}snapshots_directory = {{ .libvirt.nova.conf.snapshots_directory | default "$instances_path/snapshots" }}

# Location where the Xen hvmloader is kept (string value)
# from .libvirt.nova.conf.xen_hvmloader_path
{{ if not .libvirt.nova.conf.xen_hvmloader_path }}#{{ end }}xen_hvmloader_path = {{ .libvirt.nova.conf.xen_hvmloader_path | default "/usr/lib/xen/boot/hvmloader" }}

# Specific cachemodes to use for different disk types e.g:
# file=directsync,block=none (list value)
# from .libvirt.nova.conf.disk_cachemodes
{{ if not .libvirt.nova.conf.disk_cachemodes }}#{{ end }}disk_cachemodes = {{ .libvirt.nova.conf.disk_cachemodes | default "" }}

# A path to a device that will be used as source of entropy on the host.
# Permitted options are: /dev/random or /dev/hwrng (string value)
# from .libvirt.nova.conf.rng_dev_path
{{ if not .libvirt.nova.conf.rng_dev_path }}#{{ end }}rng_dev_path = {{ .libvirt.nova.conf.rng_dev_path | default "<None>" }}

# For qemu or KVM guests, set this option to specify a default machine type per
# host architecture. You can find a list of supported machine types in your
# environment by checking the output of the "virsh capabilities"command. The
# format of the value for this config option is host-arch=machine-type. For
# example: x86_64=machinetype1,armv7l=machinetype2 (list value)
# from .libvirt.nova.conf.hw_machine_type
{{ if not .libvirt.nova.conf.hw_machine_type }}#{{ end }}hw_machine_type = {{ .libvirt.nova.conf.hw_machine_type | default "<None>" }}

# The data source used to the populate the host "serial" UUID exposed to guest
# in the virtual BIOS. (string value)
# Allowed values: none, os, hardware, auto
# from .libvirt.nova.conf.sysinfo_serial
{{ if not .libvirt.nova.conf.sysinfo_serial }}#{{ end }}sysinfo_serial = {{ .libvirt.nova.conf.sysinfo_serial | default "auto" }}

# A number of seconds to memory usage statistics period. Zero or negative value
# mean to disable memory usage statistics. (integer value)
# from .libvirt.nova.conf.mem_stats_period_seconds
{{ if not .libvirt.nova.conf.mem_stats_period_seconds }}#{{ end }}mem_stats_period_seconds = {{ .libvirt.nova.conf.mem_stats_period_seconds | default "10" }}

# List of uid targets and ranges.Syntax is guest-uid:host-uid:countMaximum of 5
# allowed. (list value)
# from .libvirt.nova.conf.uid_maps
{{ if not .libvirt.nova.conf.uid_maps }}#{{ end }}uid_maps = {{ .libvirt.nova.conf.uid_maps | default "" }}

# List of guid targets and ranges.Syntax is guest-gid:host-gid:countMaximum of 5
# allowed. (list value)
# from .libvirt.nova.conf.gid_maps
{{ if not .libvirt.nova.conf.gid_maps }}#{{ end }}gid_maps = {{ .libvirt.nova.conf.gid_maps | default "" }}

# In a realtime host context vCPUs for guest will run in that scheduling
# priority. Priority depends on the host kernel (usually 1-99) (integer value)
# from .libvirt.nova.conf.realtime_scheduler_priority
{{ if not .libvirt.nova.conf.realtime_scheduler_priority }}#{{ end }}realtime_scheduler_priority = {{ .libvirt.nova.conf.realtime_scheduler_priority | default "1" }}

#
# This is a performance event list which could be used as monitor. These events
# will be passed to libvirt domain xml while creating a new instances.
# Then event statistics data can be collected from libvirt.  The minimum
# libvirt version is 2.0.0. For more information about `Performance monitoring
# events`, refer https://libvirt.org/formatdomain.html#elementsPerf .
#
# * Possible values:
#     A string list.
#     For example:
#     ``enabled_perf_events = cmt, mbml, mbmt``
#
#     The supported events list can be found in
#     https://libvirt.org/html/libvirt-libvirt-domain.html , which
#     you may need to search key words ``VIR_PERF_PARAM_*``
#
# * Services that use this:
#
#     ``nova-compute``
#
# * Related options:
#     None
#
#  (list value)
# from .libvirt.nova.conf.enabled_perf_events
{{ if not .libvirt.nova.conf.enabled_perf_events }}#{{ end }}enabled_perf_events = {{ .libvirt.nova.conf.enabled_perf_events | default "" }}

# VM Images format. If default is specified, then use_cow_images flag is used
# instead of this one. (string value)
# Allowed values: raw, flat, qcow2, lvm, rbd, ploop, default
# from .libvirt.nova.conf.images_type
{{ if not .libvirt.nova.conf.images_type }}#{{ end }}images_type = {{ .libvirt.nova.conf.images_type | default "default" }}

# LVM Volume Group that is used for VM images, when you specify images_type=lvm.
# (string value)
# from .libvirt.nova.conf.images_volume_group
{{ if not .libvirt.nova.conf.images_volume_group }}#{{ end }}images_volume_group = {{ .libvirt.nova.conf.images_volume_group | default "<None>" }}

# Create sparse logical volumes (with virtualsize) if this flag is set to True.
# (boolean value)
# from .libvirt.nova.conf.sparse_logical_volumes
{{ if not .libvirt.nova.conf.sparse_logical_volumes }}#{{ end }}sparse_logical_volumes = {{ .libvirt.nova.conf.sparse_logical_volumes | default "false" }}

# The RADOS pool in which rbd volumes are stored (string value)
# from .libvirt.nova.conf.images_rbd_pool
{{ if not .libvirt.nova.conf.images_rbd_pool }}#{{ end }}images_rbd_pool = {{ .libvirt.nova.conf.images_rbd_pool | default "rbd" }}

# Path to the ceph configuration file to use (string value)
# from .libvirt.nova.conf.images_rbd_ceph_conf
{{ if not .libvirt.nova.conf.images_rbd_ceph_conf }}#{{ end }}images_rbd_ceph_conf = {{ .libvirt.nova.conf.images_rbd_ceph_conf | default "" }}

# Discard option for nova managed disks. Need Libvirt(1.0.6) Qemu1.5 (raw
# format) Qemu1.6(qcow2 format) (string value)
# Allowed values: ignore, unmap
# from .libvirt.nova.conf.hw_disk_discard
{{ if not .libvirt.nova.conf.hw_disk_discard }}#{{ end }}hw_disk_discard = {{ .libvirt.nova.conf.hw_disk_discard | default "<None>" }}

# DEPRECATED: Allows image information files to be stored in non-standard
# locations (string value)
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# Reason: Image info files are no longer used by the image cache
# from .libvirt.nova.conf.image_info_filename_pattern
{{ if not .libvirt.nova.conf.image_info_filename_pattern }}#{{ end }}image_info_filename_pattern = {{ .libvirt.nova.conf.image_info_filename_pattern | default "$instances_path/$image_cache_subdirectory_name/%(image)s.info" }}

# Unused resized base images younger than this will not be removed (integer
# value)
# from .libvirt.nova.conf.remove_unused_resized_minimum_age_seconds
{{ if not .libvirt.nova.conf.remove_unused_resized_minimum_age_seconds }}#{{ end }}remove_unused_resized_minimum_age_seconds = {{ .libvirt.nova.conf.remove_unused_resized_minimum_age_seconds | default "3600" }}

# DEPRECATED: Write a checksum for files in _base to disk (boolean value)
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# Reason: The image cache no longer periodically calculates checksums of stored
# images. Data integrity can be checked at the block or filesystem level.
# from .libvirt.nova.conf.checksum_base_images
{{ if not .libvirt.nova.conf.checksum_base_images }}#{{ end }}checksum_base_images = {{ .libvirt.nova.conf.checksum_base_images | default "false" }}

# DEPRECATED: How frequently to checksum base images (integer value)
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# Reason: The image cache no longer periodically calculates checksums of stored
# images. Data integrity can be checked at the block or filesystem level.
# from .libvirt.nova.conf.checksum_interval_seconds
{{ if not .libvirt.nova.conf.checksum_interval_seconds }}#{{ end }}checksum_interval_seconds = {{ .libvirt.nova.conf.checksum_interval_seconds | default "3600" }}

# Method used to wipe old volumes. (string value)
# Allowed values: none, zero, shred
# from .libvirt.nova.conf.volume_clear
{{ if not .libvirt.nova.conf.volume_clear }}#{{ end }}volume_clear = {{ .libvirt.nova.conf.volume_clear | default "zero" }}

# Size in MiB to wipe at start of old volumes. 0 => all (integer value)
# from .libvirt.nova.conf.volume_clear_size
{{ if not .libvirt.nova.conf.volume_clear_size }}#{{ end }}volume_clear_size = {{ .libvirt.nova.conf.volume_clear_size | default "0" }}

# Compress snapshot images when possible. This currently applies exclusively to
# qcow2 images (boolean value)
# from .libvirt.nova.conf.snapshot_compression
{{ if not .libvirt.nova.conf.snapshot_compression }}#{{ end }}snapshot_compression = {{ .libvirt.nova.conf.snapshot_compression | default "false" }}

# Use virtio for bridge interfaces with KVM/QEMU (boolean value)
# from .libvirt.nova.conf.use_virtio_for_bridges
{{ if not .libvirt.nova.conf.use_virtio_for_bridges }}#{{ end }}use_virtio_for_bridges = {{ .libvirt.nova.conf.use_virtio_for_bridges | default "true" }}

# Protocols listed here will be accessed directly from QEMU. Currently supported
# protocols: [gluster] (list value)
# from .libvirt.nova.conf.qemu_allowed_storage_drivers
{{ if not .libvirt.nova.conf.qemu_allowed_storage_drivers }}#{{ end }}qemu_allowed_storage_drivers = {{ .libvirt.nova.conf.qemu_allowed_storage_drivers | default "" }}

# Use multipath connection of the iSCSI or FC volume (boolean value)
# Deprecated group/name - [libvirt]/iscsi_use_multipath
# from .libvirt.nova.conf.volume_use_multipath
{{ if not .libvirt.nova.conf.volume_use_multipath }}#{{ end }}volume_use_multipath = {{ .libvirt.nova.conf.volume_use_multipath | default "false" }}

# Number of times to rediscover AoE target to find volume (integer value)
# from .libvirt.nova.conf.num_aoe_discover_tries
{{ if not .libvirt.nova.conf.num_aoe_discover_tries }}#{{ end }}num_aoe_discover_tries = {{ .libvirt.nova.conf.num_aoe_discover_tries | default "3" }}

# Directory where the glusterfs volume is mounted on the compute node (string
# value)
# from .libvirt.nova.conf.glusterfs_mount_point_base
{{ if not .libvirt.nova.conf.glusterfs_mount_point_base }}#{{ end }}glusterfs_mount_point_base = {{ .libvirt.nova.conf.glusterfs_mount_point_base | default "$state_path/mnt" }}

# Number of times to rescan iSCSI target to find volume (integer value)
# from .libvirt.nova.conf.num_iscsi_scan_tries
{{ if not .libvirt.nova.conf.num_iscsi_scan_tries }}#{{ end }}num_iscsi_scan_tries = {{ .libvirt.nova.conf.num_iscsi_scan_tries | default "5" }}

# The iSCSI transport iface to use to connect to target in case offload support
# is desired. Default format is of the form <transport_name>.<hwaddress> where
# <transport_name> is one of (be2iscsi, bnx2i, cxgb3i, cxgb4i, qla4xxx, ocs) and
# <hwaddress> is the MAC address of the interface and can be generated via the
# iscsiadm -m iface command. Do not confuse the iscsi_iface parameter to be
# provided here with the actual transport name. (string value)
# Deprecated group/name - [libvirt]/iscsi_transport
# from .libvirt.nova.conf.iscsi_iface
{{ if not .libvirt.nova.conf.iscsi_iface }}#{{ end }}iscsi_iface = {{ .libvirt.nova.conf.iscsi_iface | default "<None>" }}

# Number of times to rescan iSER target to find volume (integer value)
# from .libvirt.nova.conf.num_iser_scan_tries
{{ if not .libvirt.nova.conf.num_iser_scan_tries }}#{{ end }}num_iser_scan_tries = {{ .libvirt.nova.conf.num_iser_scan_tries | default "5" }}

# Use multipath connection of the iSER volume (boolean value)
# from .libvirt.nova.conf.iser_use_multipath
{{ if not .libvirt.nova.conf.iser_use_multipath }}#{{ end }}iser_use_multipath = {{ .libvirt.nova.conf.iser_use_multipath | default "false" }}

# The RADOS client name for accessing rbd volumes (string value)
# from .libvirt.nova.conf.rbd_user
{{ if not .libvirt.nova.conf.rbd_user }}#{{ end }}rbd_user = {{ .libvirt.nova.conf.rbd_user | default "<None>" }}

# The libvirt UUID of the secret for the rbd_uservolumes (string value)
# from .libvirt.nova.conf.rbd_secret_uuid
{{ if not .libvirt.nova.conf.rbd_secret_uuid }}#{{ end }}rbd_secret_uuid = {{ .libvirt.nova.conf.rbd_secret_uuid | default "<None>" }}

# Directory where the NFS volume is mounted on the compute node (string value)
# from .libvirt.nova.conf.nfs_mount_point_base
{{ if not .libvirt.nova.conf.nfs_mount_point_base }}#{{ end }}nfs_mount_point_base = {{ .libvirt.nova.conf.nfs_mount_point_base | default "$state_path/mnt" }}

# Mount options passed to the NFS client. See section of the nfs man page for
# details (string value)
# from .libvirt.nova.conf.nfs_mount_options
{{ if not .libvirt.nova.conf.nfs_mount_options }}#{{ end }}nfs_mount_options = {{ .libvirt.nova.conf.nfs_mount_options | default "<None>" }}

# Directory where the Quobyte volume is mounted on the compute node (string
# value)
# from .libvirt.nova.conf.quobyte_mount_point_base
{{ if not .libvirt.nova.conf.quobyte_mount_point_base }}#{{ end }}quobyte_mount_point_base = {{ .libvirt.nova.conf.quobyte_mount_point_base | default "$state_path/mnt" }}

# Path to a Quobyte Client configuration file. (string value)
# from .libvirt.nova.conf.quobyte_client_cfg
{{ if not .libvirt.nova.conf.quobyte_client_cfg }}#{{ end }}quobyte_client_cfg = {{ .libvirt.nova.conf.quobyte_client_cfg | default "<None>" }}

# Path or URL to Scality SOFS configuration file (string value)
# from .libvirt.nova.conf.scality_sofs_config
{{ if not .libvirt.nova.conf.scality_sofs_config }}#{{ end }}scality_sofs_config = {{ .libvirt.nova.conf.scality_sofs_config | default "<None>" }}

# Base dir where Scality SOFS shall be mounted (string value)
# from .libvirt.nova.conf.scality_sofs_mount_point
{{ if not .libvirt.nova.conf.scality_sofs_mount_point }}#{{ end }}scality_sofs_mount_point = {{ .libvirt.nova.conf.scality_sofs_mount_point | default "$state_path/scality" }}

# Directory where the SMBFS shares are mounted on the compute node (string
# value)
# from .libvirt.nova.conf.smbfs_mount_point_base
{{ if not .libvirt.nova.conf.smbfs_mount_point_base }}#{{ end }}smbfs_mount_point_base = {{ .libvirt.nova.conf.smbfs_mount_point_base | default "$state_path/mnt" }}

# Mount options passed to the SMBFS client. See mount.cifs man page for details.
# Note that the libvirt-qemu uid and gid must be specified. (string value)
# from .libvirt.nova.conf.smbfs_mount_options
{{ if not .libvirt.nova.conf.smbfs_mount_options }}#{{ end }}smbfs_mount_options = {{ .libvirt.nova.conf.smbfs_mount_options | default "" }}

# Use ssh or rsync transport for creating, copying, removing files on the remote
# host. (string value)
# Allowed values: ssh, rsync
# from .libvirt.nova.conf.remote_filesystem_transport
{{ if not .libvirt.nova.conf.remote_filesystem_transport }}#{{ end }}remote_filesystem_transport = {{ .libvirt.nova.conf.remote_filesystem_transport | default "ssh" }}

#
# Directory where the Virtuozzo Storage clusters are mounted on the compute
# node.
#
# This option defines non-standard mountpoint for Vzstorage cluster.
#
# * Services that use this:
#
#     ``nova-compute``
#
# * Related options:
#
#     vzstorage_mount_* group of parameters
#  (string value)
# from .libvirt.nova.conf.vzstorage_mount_point_base
{{ if not .libvirt.nova.conf.vzstorage_mount_point_base }}#{{ end }}vzstorage_mount_point_base = {{ .libvirt.nova.conf.vzstorage_mount_point_base | default "$state_path/mnt" }}

#
# Mount owner user name.
#
# This option defines the owner user of Vzstorage cluster mountpoint.
#
# * Services that use this:
#
#     ``nova-compute``
#
# * Related options:
#
#     vzstorage_mount_* group of parameters
#  (string value)
# from .libvirt.nova.conf.vzstorage_mount_user
{{ if not .libvirt.nova.conf.vzstorage_mount_user }}#{{ end }}vzstorage_mount_user = {{ .libvirt.nova.conf.vzstorage_mount_user | default "stack" }}

#
# Mount owner group name.
#
# This option defines the owner group of Vzstorage cluster mountpoint.
#
# * Services that use this:
#
#     ``nova-compute``
#
# * Related options:
#
#     vzstorage_mount_* group of parameters
#  (string value)
# from .libvirt.nova.conf.vzstorage_mount_group
{{ if not .libvirt.nova.conf.vzstorage_mount_group }}#{{ end }}vzstorage_mount_group = {{ .libvirt.nova.conf.vzstorage_mount_group | default "qemu" }}

#
# Mount access mode.
#
# This option defines the access bits of Vzstorage cluster mountpoint,
# in the format similar to one of chmod(1) utility, like this: 0770.
# It consists of one to four digits ranging from 0 to 7, with missing
# lead digits assumed to be 0's.
#
# * Services that use this:
#
#     ``nova-compute``
#
# * Related options:
#
#     vzstorage_mount_* group of parameters
#  (string value)
# from .libvirt.nova.conf.vzstorage_mount_perms
{{ if not .libvirt.nova.conf.vzstorage_mount_perms }}#{{ end }}vzstorage_mount_perms = {{ .libvirt.nova.conf.vzstorage_mount_perms | default "0770" }}

#
# Path to vzstorage client log.
#
# This option defines the log of cluster operations,
# it should include "%(cluster_name)s" template to separate
# logs from multiple shares.
#
# * Services that use this:
#
#     ``nova-compute``
#
# * Related options:
#
#     vzstorage_mount_opts may include more detailed logging options.
#  (string value)
# from .libvirt.nova.conf.vzstorage_log_path
{{ if not .libvirt.nova.conf.vzstorage_log_path }}#{{ end }}vzstorage_log_path = {{ .libvirt.nova.conf.vzstorage_log_path | default "/var/log/pstorage/%(cluster_name)s/nova.log.gz" }}

#
# Path to the SSD cache file.
#
# You can attach an SSD drive to a client and configure the drive to store
# a local cache of frequently accessed data. By having a local cache on a
# client's SSD drive, you can increase the overall cluster performance by
# up to 10 and more times.
# WARNING! There is a lot of SSD models which are not server grade and
# may loose arbitrary set of data changes on power loss.
# Such SSDs should not be used in Vstorage and are dangerous as may lead
# to data corruptions and inconsistencies. Please consult with the manual
# on which SSD models are known to be safe or verify it using
# vstorage-hwflush-check(1) utility.
#
# This option defines the path which should include "%(cluster_name)s"
# template to separate caches from multiple shares.
#
# * Services that use this:
#
#     ``nova-compute``
#
# * Related options:
#
#     vzstorage_mount_opts may include more detailed cache options.
#  (string value)
# from .libvirt.nova.conf.vzstorage_cache_path
{{ if not .libvirt.nova.conf.vzstorage_cache_path }}#{{ end }}vzstorage_cache_path = {{ .libvirt.nova.conf.vzstorage_cache_path | default "<None>" }}

#
# Extra mount options for pstorage-mount
#
# For full description of them, see
# https://static.openvz.org/vz-man/man1/pstorage-mount.1.gz.html
# Format is a python string representation of arguments list, like:
# "['-v', '-R', '500']"
# Shouldn't include -c, -l, -C, -u, -g and -m as those have
# explicit vzstorage_* options.
#
# * Services that use this:
#
#     ``nova-compute``
#
# * Related options:
#
#     All other vzstorage_* options
#  (list value)
# from .libvirt.nova.conf.vzstorage_mount_opts
{{ if not .libvirt.nova.conf.vzstorage_mount_opts }}#{{ end }}vzstorage_mount_opts = {{ .libvirt.nova.conf.vzstorage_mount_opts | default "" }}


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


[metrics]

#
# From nova.conf
#

#
# When using metrics to weight the suitability of a host, you can use this
# option
# to change how the calculated weight influences the weight assigned to a host
# as
# follows:
#
#     * Greater than 1.0: increases the effect of the metric on overall weight.
#
#     * Equal to 1.0: No change to the calculated weight.
#
#     * Less than 1.0, greater than 0: reduces the effect of the metric on
#     overall weight.
#
#     * 0: The metric value is ignored, and the value of the
#     'weight_of_unavailable' option is returned instead.
#
#     * Greater than -1.0, less than 0: the effect is reduced and reversed.
#
#     * -1.0: the effect is reversed
#
#     * Less than -1.0: the effect is increased proportionally and reversed.
#
# Valid values are numeric, either integer or float.
#
# This option is only used by the FilterScheduler and its subclasses; if you use
# a different scheduler, this option has no effect.
#
# * Related options:
#
#     weight_of_unavailable
#  (floating point value)
# from .metrics.nova.conf.weight_multiplier
{{ if not .metrics.nova.conf.weight_multiplier }}#{{ end }}weight_multiplier = {{ .metrics.nova.conf.weight_multiplier | default "1.0" }}

#
# This setting specifies the metrics to be weighed and the relative ratios for
# each metric. This should be a single string value, consisting of a series of
# one or more 'name=ratio' pairs, separated by commas, where 'name' is the name
# of the metric to be weighed, and 'ratio' is the relative weight for that
# metric.
#
# Note that if the ratio is set to 0, the metric value is ignored, and instead
# the weight will be set to the value of the 'weight_of_unavailable' option.
#
# As an example, let's consider the case where this option is set to:
#
#     ``name1=1.0, name2=-1.3``
#
# The final weight will be:
#
#     ``(name1.value * 1.0) + (name2.value * -1.3)``
#
# This option is only used by the FilterScheduler and its subclasses; if you use
# a different scheduler, this option has no effect.
#
# * Related options:
#
#     weight_of_unavailable
#  (list value)
# from .metrics.nova.conf.weight_setting
{{ if not .metrics.nova.conf.weight_setting }}#{{ end }}weight_setting = {{ .metrics.nova.conf.weight_setting | default "" }}

#
# This setting determines how any unavailable metrics are treated. If this
# option
# is set to True, any hosts for which a metric is unavailable will raise an
# exception, so it is recommended to also use the MetricFilter to filter out
# those hosts before weighing.
#
# When this option is False, any metric being unavailable for a host will set
# the
# host weight to 'weight_of_unavailable'.
#
# This option is only used by the FilterScheduler and its subclasses; if you use
# a different scheduler, this option has no effect.
#
# * Related options:
#
#     weight_of_unavailable
#  (boolean value)
# from .metrics.nova.conf.required
{{ if not .metrics.nova.conf.required }}#{{ end }}required = {{ .metrics.nova.conf.required | default "true" }}

#
# When any of the following conditions are met, this value will be used in place
# of any actual metric value:
#
#     * One of the metrics named in 'weight_setting' is not available for a
# host,
#     and the value of 'required' is False.
#
#     * The ratio specified for a metric in 'weight_setting' is 0.
#
#     * The 'weight_multiplier' option is set to 0.
#
# This option is only used by the FilterScheduler and its subclasses; if you use
# a different scheduler, this option has no effect.
#
# * Related options:
#
#     weight_setting
#     required
#     weight_multiplier
#  (floating point value)
# from .metrics.nova.conf.weight_of_unavailable
{{ if not .metrics.nova.conf.weight_of_unavailable }}#{{ end }}weight_of_unavailable = {{ .metrics.nova.conf.weight_of_unavailable | default "-10000.0" }}


[mks]
#
# Nova compute node uses WebMKS, a desktop sharing protocol to provide
# instance console access to VM's created by VMware hypervisors.
#
# Related options:
# Following options must be set to provide console access.
# * mksproxy_base_url
# * enabled

#
# From nova.conf
#

#
# Location of MKS web console proxy
#
# The URL in the response points to a WebMKS proxy which
# starts proxying between client and corresponding vCenter
# server where instance runs. In order to use the web based
# console access, WebMKS proxy should be installed and configured
#
# Possible values:
#
# * Must be a valid URL of the form:``http://host:port/``
#  (string value)
# from .mks.nova.conf.mksproxy_base_url
{{ if not .mks.nova.conf.mksproxy_base_url }}#{{ end }}mksproxy_base_url = {{ .mks.nova.conf.mksproxy_base_url | default "http://127.0.0.1:6090/" }}

#
# Enables graphical console access for virtual machines.
#  (boolean value)
# from .mks.nova.conf.enabled
{{ if not .mks.nova.conf.enabled }}#{{ end }}enabled = {{ .mks.nova.conf.enabled | default "false" }}


[neutron]
#
# Configuration options for neutron (network connectivity as a service).

#
# From nova.conf
#

#
# This option specifies the URL for connecting to Neutron.
#
# Possible values:
#
# * Any valid URL that points to the Neutron API service is appropriate here.
#   This typically matches the URL returned for the 'network' service type
#   from the Keystone service catalog.
#  (uri value)
# from .neutron.nova.conf.url
{{ if not .neutron.nova.conf.url }}#{{ end }}url = {{ .neutron.nova.conf.url | default "http://127.0.0.1:9696" }}

#
# Region name for connecting to Neutron in admin context.
#
# This option is used in multi-region setups. If there are two Neutron
# servers running in two regions in two different machines, then two
# services need to be created in Keystone with two different regions and
# associate corresponding endpoints to those services. When requests are made
# to Keystone, the Keystone service uses the region_name to determine the
# region the request is coming from.
#  (string value)
# from .neutron.nova.conf.region_name
{{ if not .neutron.nova.conf.region_name }}#{{ end }}region_name = {{ .neutron.nova.conf.region_name | default "RegionOne" }}

#
# Specifies the name of an integration bridge interface used by OpenvSwitch.
# This option is used only if Neutron does not specify the OVS bridge name.
#
# Possible values:
#
# * Any string representing OVS bridge name.
#  (string value)
# from .neutron.nova.conf.ovs_bridge
{{ if not .neutron.nova.conf.ovs_bridge }}#{{ end }}ovs_bridge = {{ .neutron.nova.conf.ovs_bridge | default "br-int" }}

#
# Integer value representing the number of seconds to wait before querying
# Neutron for extensions.  After this number of seconds the next time Nova
# needs to create a resource in Neutron it will requery Neutron for the
# extensions that it has loaded.  Setting value to 0 will refresh the
# extensions with no wait.
#  (integer value)
# Minimum value: 0
# from .neutron.nova.conf.extension_sync_interval
{{ if not .neutron.nova.conf.extension_sync_interval }}#{{ end }}extension_sync_interval = {{ .neutron.nova.conf.extension_sync_interval | default "600" }}

#
# When set to True, this option indicates that Neutron will be used to proxy
# metadata requests and resolve instance ids. Otherwise, the instance ID must be
# passed to the metadata request in the 'X-Instance-ID' header.
#
# Related options:
#
# * metadata_proxy_shared_secret
#  (boolean value)
# from .neutron.nova.conf.service_metadata_proxy
{{ if not .neutron.nova.conf.service_metadata_proxy }}#{{ end }}service_metadata_proxy = {{ .neutron.nova.conf.service_metadata_proxy | default "false" }}

#
# This option holds the shared secret string used to validate proxy requests to
# Neutron metadata requests. In order to be used, the
# 'X-Metadata-Provider-Signature' header must be supplied in the request.
#
# Related options:
#
# * service_metadata_proxy
#  (string value)
# from .neutron.nova.conf.metadata_proxy_shared_secret
{{ if not .neutron.nova.conf.metadata_proxy_shared_secret }}#{{ end }}metadata_proxy_shared_secret = {{ .neutron.nova.conf.metadata_proxy_shared_secret | default "" }}

# PEM encoded Certificate Authority to use when verifying HTTPs connections.
# (string value)
# from .neutron.nova.conf.cafile
{{ if not .neutron.nova.conf.cafile }}#{{ end }}cafile = {{ .neutron.nova.conf.cafile | default "<None>" }}

# PEM encoded client certificate cert file (string value)
# from .neutron.nova.conf.certfile
{{ if not .neutron.nova.conf.certfile }}#{{ end }}certfile = {{ .neutron.nova.conf.certfile | default "<None>" }}

# PEM encoded client certificate key file (string value)
# from .neutron.nova.conf.keyfile
{{ if not .neutron.nova.conf.keyfile }}#{{ end }}keyfile = {{ .neutron.nova.conf.keyfile | default "<None>" }}

# Verify HTTPS connections. (boolean value)
# from .neutron.nova.conf.insecure
{{ if not .neutron.nova.conf.insecure }}#{{ end }}insecure = {{ .neutron.nova.conf.insecure | default "false" }}

# Timeout value for http requests (integer value)
# from .neutron.nova.conf.timeout
{{ if not .neutron.nova.conf.timeout }}#{{ end }}timeout = {{ .neutron.nova.conf.timeout | default "<None>" }}

# Authentication type to load (string value)
# Deprecated group/name - [neutron]/auth_plugin
# from .neutron.nova.conf.auth_type
{{ if not .neutron.nova.conf.auth_type }}#{{ end }}auth_type = {{ .neutron.nova.conf.auth_type | default "<None>" }}

# Config Section from which to load plugin specific options (string value)
# from .neutron.nova.conf.auth_section
{{ if not .neutron.nova.conf.auth_section }}#{{ end }}auth_section = {{ .neutron.nova.conf.auth_section | default "<None>" }}

# Authentication URL (string value)
# from .neutron.nova.conf.auth_url
{{ if not .neutron.nova.conf.auth_url }}#{{ end }}auth_url = {{ .neutron.nova.conf.auth_url | default "<None>" }}

# Domain ID to scope to (string value)
# from .neutron.nova.conf.domain_id
{{ if not .neutron.nova.conf.domain_id }}#{{ end }}domain_id = {{ .neutron.nova.conf.domain_id | default "<None>" }}

# Domain name to scope to (string value)
# from .neutron.nova.conf.domain_name
{{ if not .neutron.nova.conf.domain_name }}#{{ end }}domain_name = {{ .neutron.nova.conf.domain_name | default "<None>" }}

# Project ID to scope to (string value)
# from .neutron.nova.conf.project_id
{{ if not .neutron.nova.conf.project_id }}#{{ end }}project_id = {{ .neutron.nova.conf.project_id | default "<None>" }}

# Project name to scope to (string value)
# from .neutron.nova.conf.project_name
{{ if not .neutron.nova.conf.project_name }}#{{ end }}project_name = {{ .neutron.nova.conf.project_name | default "<None>" }}

# Domain ID containing project (string value)
# from .neutron.nova.conf.project_domain_id
{{ if not .neutron.nova.conf.project_domain_id }}#{{ end }}project_domain_id = {{ .neutron.nova.conf.project_domain_id | default "<None>" }}

# Domain name containing project (string value)
# from .neutron.nova.conf.project_domain_name
{{ if not .neutron.nova.conf.project_domain_name }}#{{ end }}project_domain_name = {{ .neutron.nova.conf.project_domain_name | default "<None>" }}

# Trust ID (string value)
# from .neutron.nova.conf.trust_id
{{ if not .neutron.nova.conf.trust_id }}#{{ end }}trust_id = {{ .neutron.nova.conf.trust_id | default "<None>" }}

# Optional domain ID to use with v3 and v2 parameters. It will be used for both
# the user and project domain in v3 and ignored in v2 authentication. (string
# value)
# from .neutron.nova.conf.default_domain_id
{{ if not .neutron.nova.conf.default_domain_id }}#{{ end }}default_domain_id = {{ .neutron.nova.conf.default_domain_id | default "<None>" }}

# Optional domain name to use with v3 API and v2 parameters. It will be used for
# both the user and project domain in v3 and ignored in v2 authentication.
# (string value)
# from .neutron.nova.conf.default_domain_name
{{ if not .neutron.nova.conf.default_domain_name }}#{{ end }}default_domain_name = {{ .neutron.nova.conf.default_domain_name | default "<None>" }}

# User ID (string value)
# from .neutron.nova.conf.user_id
{{ if not .neutron.nova.conf.user_id }}#{{ end }}user_id = {{ .neutron.nova.conf.user_id | default "<None>" }}

# Username (string value)
# Deprecated group/name - [neutron]/user-name
# from .neutron.nova.conf.username
{{ if not .neutron.nova.conf.username }}#{{ end }}username = {{ .neutron.nova.conf.username | default "<None>" }}

# User's domain id (string value)
# from .neutron.nova.conf.user_domain_id
{{ if not .neutron.nova.conf.user_domain_id }}#{{ end }}user_domain_id = {{ .neutron.nova.conf.user_domain_id | default "<None>" }}

# User's domain name (string value)
# from .neutron.nova.conf.user_domain_name
{{ if not .neutron.nova.conf.user_domain_name }}#{{ end }}user_domain_name = {{ .neutron.nova.conf.user_domain_name | default "<None>" }}

# User's password (string value)
# from .neutron.nova.conf.password
{{ if not .neutron.nova.conf.password }}#{{ end }}password = {{ .neutron.nova.conf.password | default "<None>" }}

# Tenant ID (string value)
# from .neutron.nova.conf.tenant_id
{{ if not .neutron.nova.conf.tenant_id }}#{{ end }}tenant_id = {{ .neutron.nova.conf.tenant_id | default "<None>" }}

# Tenant Name (string value)
# from .neutron.nova.conf.tenant_name
{{ if not .neutron.nova.conf.tenant_name }}#{{ end }}tenant_name = {{ .neutron.nova.conf.tenant_name | default "<None>" }}


[osapi_v21]

#
# From nova.conf
#

# DEPRECATED:
# This option is a list of all of the v2.1 API extensions to never load.
# However,
# it will be removed in the near future, after which all the functionality
# that was previously in extensions will be part of the standard API, and thus
# always accessible.
#
# Possible values:
#
# * A list of strings, each being the alias of an extension that you do not
#   wish to load.
#
# Related options:
#
# * enabled
# * extensions_whitelist
#  (list value)
# Deprecated group/name - [osapi_v21]/extensions_blacklist
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# from .osapi_v21.nova.conf.extensions_blacklist
{{ if not .osapi_v21.nova.conf.extensions_blacklist }}#{{ end }}extensions_blacklist = {{ .osapi_v21.nova.conf.extensions_blacklist | default "" }}

# DEPRECATED:
# This is a list of extensions. If it is empty, then *all* extensions except
# those specified in the extensions_blacklist option will be loaded. If it is
# not
# empty, then only those extensions in this list will be loaded, provided that
# they are also not in the extensions_blacklist option. Once this deprecated
# option is removed, after which the all the functionality that was previously
# in
# extensions will be part of the standard API, and thus always accessible.
#
# Possible values:
#
# * A list of strings, each being the alias of an extension that you wish to
#   load, or an empty list, which indicates that all extensions are to be run.
#
# Related options:
#
# * enabled
# * extensions_blacklist
#  (list value)
# Deprecated group/name - [osapi_v21]/extensions_whitelist
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# from .osapi_v21.nova.conf.extensions_whitelist
{{ if not .osapi_v21.nova.conf.extensions_whitelist }}#{{ end }}extensions_whitelist = {{ .osapi_v21.nova.conf.extensions_whitelist | default "" }}

# DEPRECATED:
# This option is a string representing a regular expression (regex) that matches
# the project_id as contained in URLs. If not set, it will match normal UUIDs
# created by keystone.
#
# Possible values:
#
# * A string representing any legal regular expression
#  (string value)
# Deprecated group/name - [osapi_v21]/project_id_regex
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# from .osapi_v21.nova.conf.project_id_regex
{{ if not .osapi_v21.nova.conf.project_id_regex }}#{{ end }}project_id_regex = {{ .osapi_v21.nova.conf.project_id_regex | default "<None>" }}


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
{{ if not .oslo_messaging_notifications.oslo.messaging.driver }}#driver = {{ .oslo_messaging_notifications.oslo.messaging.driver | default "" }}{{ else }}{{ range .oslo_messaging_notifications.oslo.messaging.driver }}driver = {{ . }}{{ end }}{{ end }}

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
# From oslo.middleware
#

# The maximum body size for each  request, in bytes. (integer value)
# Deprecated group/name - [DEFAULT]/osapi_max_request_body_size
# Deprecated group/name - [DEFAULT]/max_request_body_size
# from .oslo_middleware.oslo.middleware.max_request_body_size
{{ if not .oslo_middleware.oslo.middleware.max_request_body_size }}#{{ end }}max_request_body_size = {{ .oslo_middleware.oslo.middleware.max_request_body_size | default "114688" }}

# DEPRECATED: The HTTP Header that will be used to determine what the original
# request protocol scheme was, even if it was hidden by a SSL termination proxy.
# (string value)
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
{{ if not .oslo_policy.oslo.policy.policy_dirs }}#policy_dirs = {{ .oslo_policy.oslo.policy.policy_dirs | default "policy.d" }}{{ else }}{{ range .oslo_policy.oslo.policy.policy_dirs }}policy_dirs = {{ . }}{{ end }}{{ end }}


[placement]

#
# From nova.conf
#

#
# Region name of this node. This is used when picking the URL in the service
# catalog.
#
# Possible values:
#
# * Any string representing region name
#  (string value)
# from .placement.nova.conf.os_region_name
{{ if not .placement.nova.conf.os_region_name }}#{{ end }}os_region_name = {{ .placement.nova.conf.os_region_name | default "<None>" }}

# PEM encoded Certificate Authority to use when verifying HTTPs connections.
# (string value)
# from .placement.nova.conf.cafile
{{ if not .placement.nova.conf.cafile }}#{{ end }}cafile = {{ .placement.nova.conf.cafile | default "<None>" }}

# PEM encoded client certificate cert file (string value)
# from .placement.nova.conf.certfile
{{ if not .placement.nova.conf.certfile }}#{{ end }}certfile = {{ .placement.nova.conf.certfile | default "<None>" }}

# PEM encoded client certificate key file (string value)
# from .placement.nova.conf.keyfile
{{ if not .placement.nova.conf.keyfile }}#{{ end }}keyfile = {{ .placement.nova.conf.keyfile | default "<None>" }}

# Verify HTTPS connections. (boolean value)
# from .placement.nova.conf.insecure
{{ if not .placement.nova.conf.insecure }}#{{ end }}insecure = {{ .placement.nova.conf.insecure | default "false" }}

# Timeout value for http requests (integer value)
# from .placement.nova.conf.timeout
{{ if not .placement.nova.conf.timeout }}#{{ end }}timeout = {{ .placement.nova.conf.timeout | default "<None>" }}

# Authentication type to load (string value)
# Deprecated group/name - [placement]/auth_plugin
# from .placement.nova.conf.auth_type
{{ if not .placement.nova.conf.auth_type }}#{{ end }}auth_type = {{ .placement.nova.conf.auth_type | default "<None>" }}

# Config Section from which to load plugin specific options (string value)
# from .placement.nova.conf.auth_section
{{ if not .placement.nova.conf.auth_section }}#{{ end }}auth_section = {{ .placement.nova.conf.auth_section | default "<None>" }}

# Authentication URL (string value)
# from .placement.nova.conf.auth_url
{{ if not .placement.nova.conf.auth_url }}#{{ end }}auth_url = {{ .placement.nova.conf.auth_url | default "<None>" }}

# Domain ID to scope to (string value)
# from .placement.nova.conf.domain_id
{{ if not .placement.nova.conf.domain_id }}#{{ end }}domain_id = {{ .placement.nova.conf.domain_id | default "<None>" }}

# Domain name to scope to (string value)
# from .placement.nova.conf.domain_name
{{ if not .placement.nova.conf.domain_name }}#{{ end }}domain_name = {{ .placement.nova.conf.domain_name | default "<None>" }}

# Project ID to scope to (string value)
# from .placement.nova.conf.project_id
{{ if not .placement.nova.conf.project_id }}#{{ end }}project_id = {{ .placement.nova.conf.project_id | default "<None>" }}

# Project name to scope to (string value)
# from .placement.nova.conf.project_name
{{ if not .placement.nova.conf.project_name }}#{{ end }}project_name = {{ .placement.nova.conf.project_name | default "<None>" }}

# Domain ID containing project (string value)
# from .placement.nova.conf.project_domain_id
{{ if not .placement.nova.conf.project_domain_id }}#{{ end }}project_domain_id = {{ .placement.nova.conf.project_domain_id | default "<None>" }}

# Domain name containing project (string value)
# from .placement.nova.conf.project_domain_name
{{ if not .placement.nova.conf.project_domain_name }}#{{ end }}project_domain_name = {{ .placement.nova.conf.project_domain_name | default "<None>" }}

# Trust ID (string value)
# from .placement.nova.conf.trust_id
{{ if not .placement.nova.conf.trust_id }}#{{ end }}trust_id = {{ .placement.nova.conf.trust_id | default "<None>" }}

# Optional domain ID to use with v3 and v2 parameters. It will be used for both
# the user and project domain in v3 and ignored in v2 authentication. (string
# value)
# from .placement.nova.conf.default_domain_id
{{ if not .placement.nova.conf.default_domain_id }}#{{ end }}default_domain_id = {{ .placement.nova.conf.default_domain_id | default "<None>" }}

# Optional domain name to use with v3 API and v2 parameters. It will be used for
# both the user and project domain in v3 and ignored in v2 authentication.
# (string value)
# from .placement.nova.conf.default_domain_name
{{ if not .placement.nova.conf.default_domain_name }}#{{ end }}default_domain_name = {{ .placement.nova.conf.default_domain_name | default "<None>" }}

# User ID (string value)
# from .placement.nova.conf.user_id
{{ if not .placement.nova.conf.user_id }}#{{ end }}user_id = {{ .placement.nova.conf.user_id | default "<None>" }}

# Username (string value)
# Deprecated group/name - [placement]/user-name
# from .placement.nova.conf.username
{{ if not .placement.nova.conf.username }}#{{ end }}username = {{ .placement.nova.conf.username | default "<None>" }}

# User's domain id (string value)
# from .placement.nova.conf.user_domain_id
{{ if not .placement.nova.conf.user_domain_id }}#{{ end }}user_domain_id = {{ .placement.nova.conf.user_domain_id | default "<None>" }}

# User's domain name (string value)
# from .placement.nova.conf.user_domain_name
{{ if not .placement.nova.conf.user_domain_name }}#{{ end }}user_domain_name = {{ .placement.nova.conf.user_domain_name | default "<None>" }}

# User's password (string value)
# from .placement.nova.conf.password
{{ if not .placement.nova.conf.password }}#{{ end }}password = {{ .placement.nova.conf.password | default "<None>" }}

# Tenant ID (string value)
# from .placement.nova.conf.tenant_id
{{ if not .placement.nova.conf.tenant_id }}#{{ end }}tenant_id = {{ .placement.nova.conf.tenant_id | default "<None>" }}

# Tenant Name (string value)
# from .placement.nova.conf.tenant_name
{{ if not .placement.nova.conf.tenant_name }}#{{ end }}tenant_name = {{ .placement.nova.conf.tenant_name | default "<None>" }}


[placement_database]
#
# The *Placement API Database* is a separate database which is used for the new
# placement-api service. In Ocata release (14.0.0) this database is optional: if
# connection option is not set, api database will be used instead.  However,
# this
# is not recommended, as it implies a potentially lengthy data migration in the
# future. Operators are advised to use a separate database for Placement API
# from
# the start.

#
# From nova.conf
#

# The SQLAlchemy connection string to use to connect to the database.The
# SQLAlchemy connection string to use to connect to the database. (string value)
# from .placement_database.nova.conf.connection
{{ if not .placement_database.nova.conf.connection }}#{{ end }}connection = {{ .placement_database.nova.conf.connection | default "<None>" }}

# If True, SQLite uses synchronous mode.If True, SQLite uses synchronous mode.
# (boolean value)
# from .placement_database.nova.conf.sqlite_synchronous
{{ if not .placement_database.nova.conf.sqlite_synchronous }}#{{ end }}sqlite_synchronous = {{ .placement_database.nova.conf.sqlite_synchronous | default "true" }}

# The SQLAlchemy connection string to use to connect to the slave database.The
# SQLAlchemy connection string to use to connect to the slave database. (string
# value)
# from .placement_database.nova.conf.slave_connection
{{ if not .placement_database.nova.conf.slave_connection }}#{{ end }}slave_connection = {{ .placement_database.nova.conf.slave_connection | default "<None>" }}

# The SQL mode to be used for MySQL sessions. This option, including the
# default, overrides any server-set SQL mode. To use whatever SQL mode is set by
# the server configuration, set this to no value. Example: mysql_sql_mode=The
# SQL mode to be used for MySQL sessions. This option, including the default,
# overrides any server-set SQL mode. To use whatever SQL mode is set by the
# server configuration, set this to no value. Example: mysql_sql_mode= (string
# value)
# from .placement_database.nova.conf.mysql_sql_mode
{{ if not .placement_database.nova.conf.mysql_sql_mode }}#{{ end }}mysql_sql_mode = {{ .placement_database.nova.conf.mysql_sql_mode | default "TRADITIONAL" }}

# Timeout before idle SQL connections are reaped.Timeout before idle SQL
# connections are reaped. (integer value)
# from .placement_database.nova.conf.idle_timeout
{{ if not .placement_database.nova.conf.idle_timeout }}#{{ end }}idle_timeout = {{ .placement_database.nova.conf.idle_timeout | default "3600" }}

# Maximum number of SQL connections to keep open in a pool. Setting a value of 0
# indicates no limit.Maximum number of SQL connections to keep open in a pool.
# Setting a value of 0 indicates no limit. (integer value)
# from .placement_database.nova.conf.max_pool_size
{{ if not .placement_database.nova.conf.max_pool_size }}#{{ end }}max_pool_size = {{ .placement_database.nova.conf.max_pool_size | default "<None>" }}

# Maximum number of database connection retries during startup. Set to -1 to
# specify an infinite retry count.Maximum number of database connection retries
# during startup. Set to -1 to specify an infinite retry count. (integer value)
# from .placement_database.nova.conf.max_retries
{{ if not .placement_database.nova.conf.max_retries }}#{{ end }}max_retries = {{ .placement_database.nova.conf.max_retries | default "10" }}

# Interval between retries of opening a SQL connection.Interval between retries
# of opening a SQL connection. (integer value)
# from .placement_database.nova.conf.retry_interval
{{ if not .placement_database.nova.conf.retry_interval }}#{{ end }}retry_interval = {{ .placement_database.nova.conf.retry_interval | default "10" }}

# If set, use this value for max_overflow with SQLAlchemy.If set, use this value
# for max_overflow with SQLAlchemy. (integer value)
# from .placement_database.nova.conf.max_overflow
{{ if not .placement_database.nova.conf.max_overflow }}#{{ end }}max_overflow = {{ .placement_database.nova.conf.max_overflow | default "<None>" }}

# Verbosity of SQL debugging information: 0=None, 100=Everything.Verbosity of
# SQL debugging information: 0=None, 100=Everything. (integer value)
# from .placement_database.nova.conf.connection_debug
{{ if not .placement_database.nova.conf.connection_debug }}#{{ end }}connection_debug = {{ .placement_database.nova.conf.connection_debug | default "0" }}

# Add Python stack traces to SQL as comment strings.Add Python stack traces to
# SQL as comment strings. (boolean value)
# from .placement_database.nova.conf.connection_trace
{{ if not .placement_database.nova.conf.connection_trace }}#{{ end }}connection_trace = {{ .placement_database.nova.conf.connection_trace | default "false" }}

# If set, use this value for pool_timeout with SQLAlchemy.If set, use this value
# for pool_timeout with SQLAlchemy. (integer value)
# from .placement_database.nova.conf.pool_timeout
{{ if not .placement_database.nova.conf.pool_timeout }}#{{ end }}pool_timeout = {{ .placement_database.nova.conf.pool_timeout | default "<None>" }}


[rdp]
#
# Options under this group enable and configure Remote Desktop Protocol (
# RDP) related features.
#
# This group is only relevant to Hyper-V users.

#
# From nova.conf
#

#
# Enable Remote Desktop Protocol (RDP) related features.
#
# Hyper-V, unlike the majority of the hypervisors employed on Nova compute
# nodes, uses RDP instead of VNC and SPICE as a desktop sharing protocol to
# provide instance console access. This option enables RDP for graphical
# console access for virtual machines created by Hyper-V.
#
# **Note:** RDP should only be enabled on compute nodes that support the Hyper-V
# virtualization platform.
#
# Related options:
#
# * ``compute_driver``: Must be hyperv.
#
#  (boolean value)
# from .rdp.nova.conf.enabled
{{ if not .rdp.nova.conf.enabled }}#{{ end }}enabled = {{ .rdp.nova.conf.enabled | default "false" }}

#
# The URL an end user would use to connect to the RDP HTML5 console proxy.
# The console proxy service is called with this token-embedded URL and
# establishes the connection to the proper instance.
#
# An RDP HTML5 console proxy service will need to be configured to listen on the
# address configured here. Typically the console proxy service would be run on a
# controller node. The localhost address used as default would only work in a
# single node environment i.e. devstack.
#
# An RDP HTML5 proxy allows a user to access via the web the text or graphical
# console of any Windows server or workstation using RDP. RDP HTML5 console
# proxy services include FreeRDP, wsgate.
# See https://github.com/FreeRDP/FreeRDP-WebConnect
#
# Possible values:
#
# * <scheme>://<ip-address>:<port-number>/
#
#   The scheme must be identical to the scheme configured for the RDP HTML5
#   console proxy service.
#
#   The IP address must be identical to the address on which the RDP HTML5
#   console proxy service is listening.
#
#   The port must be identical to the port on which the RDP HTML5 console proxy
#   service is listening.
#
# Related options:
#
# * ``rdp.enabled``: Must be set to ``True`` for ``html5_proxy_base_url`` to be
#   effective.
#  (string value)
# from .rdp.nova.conf.html5_proxy_base_url
{{ if not .rdp.nova.conf.html5_proxy_base_url }}#{{ end }}html5_proxy_base_url = {{ .rdp.nova.conf.html5_proxy_base_url | default "http://127.0.0.1:6083/" }}


[remote_debug]

#
# From nova.conf
#

#
# Debug host (IP or name) to connect to. This command line parameter is used
# when
# you want to connect to a nova service via a debugger running on a different
# host.
#
# Note that using the remote debug option changes how Nova uses the eventlet
# library to support async IO. This could result in failures that do not occur
# under normal operation. Use at your own risk.
#
# Possible Values:
#
#    * IP address of a remote host as a command line parameter
#      to a nova service. For Example:
#
#     /usr/local/bin/nova-compute --config-file /etc/nova/nova.conf
#     --remote_debug-host <IP address where the debugger is running>
#  (string value)
# from .remote_debug.nova.conf.host
{{ if not .remote_debug.nova.conf.host }}#{{ end }}host = {{ .remote_debug.nova.conf.host | default "<None>" }}

#
# Debug port to connect to. This command line parameter allows you to specify
# the port you want to use to connect to a nova service via a debugger running
# on different host.
#
# Note that using the remote debug option changes how Nova uses the eventlet
# library to support async IO. This could result in failures that do not occur
# under normal operation. Use at your own risk.
#
# Possible Values:
#
#    * Port number you want to use as a command line parameter
#      to a nova service. For Example:
#
#     /usr/local/bin/nova-compute --config-file /etc/nova/nova.conf
#     --remote_debug-host <IP address where the debugger is running>
#     --remote_debug-port <port> it's listening on>.
#  (port value)
# Minimum value: 0
# Maximum value: 65535
# from .remote_debug.nova.conf.port
{{ if not .remote_debug.nova.conf.port }}#{{ end }}port = {{ .remote_debug.nova.conf.port | default "<None>" }}


[serial_console]
#
# The serial console feature allows you to connect to a guest in case a
# graphical console like VNC, RDP or SPICE is not available. This is only
# currently supported for the libvirt and hyper-v drivers.

#
# From nova.conf
#

#
# Enable the serial console feature.
#
# In order to use this feature, the service ``nova-serialproxy`` needs to run.
# This service is typically executed on the controller node.
#
# Possible values:
#
# * True: Enables the feature
# * False: Disables the feature
#
# Services which consume this:
#
# * ``nova-compute``
#
# Interdependencies to other options:
#
# * None
#  (boolean value)
# from .serial_console.nova.conf.enabled
{{ if not .serial_console.nova.conf.enabled }}#{{ end }}enabled = {{ .serial_console.nova.conf.enabled | default "false" }}

#
# A range of TCP ports a guest can use for its backend.
#
# Each instance which gets created will use one port out of this range. If the
# range is not big enough to provide another port for an new instance, this
# instance won't get launched.
#
# Possible values:
#
# Each string which passes the regex ``\d+:\d+`` For example ``10000:20000``.
# Be sure that the first port number is lower than the second port number.
#
# Services which consume this:
#
# * ``nova-compute``
#
# Interdependencies to other options:
#
# * None
#  (string value)
# from .serial_console.nova.conf.port_range
{{ if not .serial_console.nova.conf.port_range }}#{{ end }}port_range = {{ .serial_console.nova.conf.port_range | default "10000:20000" }}

#
# The URL an end user would use to connect to the ``nova-serialproxy`` service.
#
# The ``nova-serialproxy`` service is called with this token enriched URL
# and establishes the connection to the proper instance.
#
# Possible values:
#
# * <scheme><IP-address><port-number>
#
# Services which consume this:
#
# * ``nova-compute``
#
# Interdependencies to other options:
#
# * The IP address must be identical to the address to which the
#   ``nova-serialproxy`` service is listening (see option ``serialproxy_host``
#   in this section).
# * The port must be the same as in the option ``serialproxy_port`` of this
#   section.
# * If you choose to use a secured websocket connection, then start this option
#   with ``wss://`` instead of the unsecured ``ws://``. The options ``cert``
#   and ``key`` in the ``[DEFAULT]`` section have to be set for that.
#  (string value)
# from .serial_console.nova.conf.base_url
{{ if not .serial_console.nova.conf.base_url }}#{{ end }}base_url = {{ .serial_console.nova.conf.base_url | default "ws://127.0.0.1:6083/" }}

#
# The IP address to which proxy clients (like ``nova-serialproxy``) should
# connect to get the serial console of an instance.
#
# This is typically the IP address of the host of a ``nova-compute`` service.
#
# Possible values:
#
# * An IP address
#
# Services which consume this:
#
# * ``nova-compute``
#
# Interdependencies to other options:
#
# * None
#  (string value)
# from .serial_console.nova.conf.proxyclient_address
{{ if not .serial_console.nova.conf.proxyclient_address }}#{{ end }}proxyclient_address = {{ .serial_console.nova.conf.proxyclient_address | default "127.0.0.1" }}

#
# The IP address which is used by the ``nova-serialproxy`` service to listen
# for incoming requests.
#
# The ``nova-serialproxy`` service listens on this IP address for incoming
# connection requests to instances which expose serial console.
#
# Possible values:
#
# * An IP address
#
# Services which consume this:
#
# * ``nova-serialproxy``
#
# Interdependencies to other options:
#
# * Ensure that this is the same IP address which is defined in the option
#   ``base_url`` of this section or use ``0.0.0.0`` to listen on all addresses.
#  (string value)
# from .serial_console.nova.conf.serialproxy_host
{{ if not .serial_console.nova.conf.serialproxy_host }}#{{ end }}serialproxy_host = {{ .serial_console.nova.conf.serialproxy_host | default "0.0.0.0" }}

#
# The port number which is used by the ``nova-serialproxy`` service to listen
# for incoming requests.
#
# The ``nova-serialproxy`` service listens on this port number for incoming
# connection requests to instances which expose serial console.
#
# Possible values:
#
# * A port number
#
# Services which consume this:
#
# * ``nova-serialproxy``
#
# Interdependencies to other options:
#
# * Ensure that this is the same port number which is defined in the option
#   ``base_url`` of this section.
#  (port value)
# Minimum value: 0
# Maximum value: 65535
# from .serial_console.nova.conf.serialproxy_port
{{ if not .serial_console.nova.conf.serialproxy_port }}#{{ end }}serialproxy_port = {{ .serial_console.nova.conf.serialproxy_port | default "6083" }}


[spice]

#
# From nova.conf
#

#
# Location of spice HTML5 console proxy, in the form
# "http://127.0.0.1:6082/spice_auto.html"
#  (string value)
# from .spice.nova.conf.html5proxy_base_url
{{ if not .spice.nova.conf.html5proxy_base_url }}#{{ end }}html5proxy_base_url = {{ .spice.nova.conf.html5proxy_base_url | default "http://127.0.0.1:6082/spice_auto.html" }}

#
# IP address on which instance spice server should listen
#  (string value)
# from .spice.nova.conf.server_listen
{{ if not .spice.nova.conf.server_listen }}#{{ end }}server_listen = {{ .spice.nova.conf.server_listen | default "127.0.0.1" }}

#
# The address to which proxy clients (like nova-spicehtml5proxy) should connect
#  (string value)
# from .spice.nova.conf.server_proxyclient_address
{{ if not .spice.nova.conf.server_proxyclient_address }}#{{ end }}server_proxyclient_address = {{ .spice.nova.conf.server_proxyclient_address | default "127.0.0.1" }}

#
# Enable spice related features.
#  (boolean value)
# from .spice.nova.conf.enabled
{{ if not .spice.nova.conf.enabled }}#{{ end }}enabled = {{ .spice.nova.conf.enabled | default "false" }}

#
# Enable the spice guest agent support.
#  (boolean value)
# from .spice.nova.conf.agent_enabled
{{ if not .spice.nova.conf.agent_enabled }}#{{ end }}agent_enabled = {{ .spice.nova.conf.agent_enabled | default "true" }}

#
# Keymap for spice
#  (string value)
# from .spice.nova.conf.keymap
{{ if not .spice.nova.conf.keymap }}#{{ end }}keymap = {{ .spice.nova.conf.keymap | default "en-us" }}

#
# Host on which to listen for incoming requests
#  (string value)
# from .spice.nova.conf.html5proxy_host
{{ if not .spice.nova.conf.html5proxy_host }}#{{ end }}html5proxy_host = {{ .spice.nova.conf.html5proxy_host | default "0.0.0.0" }}

#
# Port on which to listen for incoming requests
#  (port value)
# Minimum value: 0
# Maximum value: 65535
# from .spice.nova.conf.html5proxy_port
{{ if not .spice.nova.conf.html5proxy_port }}#{{ end }}html5proxy_port = {{ .spice.nova.conf.html5proxy_port | default "6082" }}


[ssl]

#
# From nova.conf
#

# CA certificate file to use to verify connecting clients. (string value)
# Deprecated group/name - [DEFAULT]/ssl_ca_file
# from .ssl.nova.conf.ca_file
{{ if not .ssl.nova.conf.ca_file }}#{{ end }}ca_file = {{ .ssl.nova.conf.ca_file | default "<None>" }}

# Certificate file to use when starting the server securely. (string value)
# Deprecated group/name - [DEFAULT]/ssl_cert_file
# from .ssl.nova.conf.cert_file
{{ if not .ssl.nova.conf.cert_file }}#{{ end }}cert_file = {{ .ssl.nova.conf.cert_file | default "<None>" }}

# Private key file to use when starting the server securely. (string value)
# Deprecated group/name - [DEFAULT]/ssl_key_file
# from .ssl.nova.conf.key_file
{{ if not .ssl.nova.conf.key_file }}#{{ end }}key_file = {{ .ssl.nova.conf.key_file | default "<None>" }}

# SSL version to use (valid only if SSL enabled). Valid values are TLSv1 and
# SSLv23. SSLv2, SSLv3, TLSv1_1, and TLSv1_2 may be available on some
# distributions. (string value)
# from .ssl.nova.conf.version
{{ if not .ssl.nova.conf.version }}#{{ end }}version = {{ .ssl.nova.conf.version | default "<None>" }}

# Sets the list of available ciphers. value should be a string in the OpenSSL
# cipher list format. (string value)
# from .ssl.nova.conf.ciphers
{{ if not .ssl.nova.conf.ciphers }}#{{ end }}ciphers = {{ .ssl.nova.conf.ciphers | default "<None>" }}


[trusted_computing]

#
# From nova.conf
#

#
# The host to use as the attestation server.
#
# Cloud computing pools can involve thousands of compute nodes located at
# different geographical locations, making it difficult for cloud providers to
# identify a node's trustworthiness. When using the Trusted filter, users can
# request that their VMs only be placed on nodes that have been verified by the
# attestation server specified in this option.
#
# The value is a string, and can be either an IP address or FQDN.
#
# This option is only used by the FilterScheduler and its subclasses; if you use
# a different scheduler, this option has no effect. Also note that this setting
# only affects scheduling if the 'TrustedFilter' filter is enabled.
#
# * Related options:
#
#     attestation_server_ca_file
#     attestation_port
#     attestation_api_url
#     attestation_auth_blob
#     attestation_auth_timeout
#     attestation_insecure_ssl
#  (string value)
# from .trusted_computing.nova.conf.attestation_server
{{ if not .trusted_computing.nova.conf.attestation_server }}#{{ end }}attestation_server = {{ .trusted_computing.nova.conf.attestation_server | default "<None>" }}

#
# The absolute path to the certificate to use for authentication when connecting
# to the attestation server. See the `attestation_server` help text for more
# information about host verification.
#
# The value is a string, and must point to a file that is readable by the
# scheduler.
#
# This option is only used by the FilterScheduler and its subclasses; if you use
# a different scheduler, this option has no effect. Also note that this setting
# only affects scheduling if the 'TrustedFilter' filter is enabled.
#
# * Related options:
#
#     attestation_server
#     attestation_port
#     attestation_api_url
#     attestation_auth_blob
#     attestation_auth_timeout
#     attestation_insecure_ssl
#  (string value)
# from .trusted_computing.nova.conf.attestation_server_ca_file
{{ if not .trusted_computing.nova.conf.attestation_server_ca_file }}#{{ end }}attestation_server_ca_file = {{ .trusted_computing.nova.conf.attestation_server_ca_file | default "<None>" }}

#
# The port to use when connecting to the attestation server. See the
# `attestation_server` help text for more information about host verification.
#
# Valid values are strings, not integers, but must be digits only.
#
# This option is only used by the FilterScheduler and its subclasses; if you use
# a different scheduler, this option has no effect. Also note that this setting
# only affects scheduling if the 'TrustedFilter' filter is enabled.
#
# * Related options:
#
#     attestation_server
#     attestation_server_ca_file
#     attestation_api_url
#     attestation_auth_blob
#     attestation_auth_timeout
#     attestation_insecure_ssl
#  (string value)
# from .trusted_computing.nova.conf.attestation_port
{{ if not .trusted_computing.nova.conf.attestation_port }}#{{ end }}attestation_port = {{ .trusted_computing.nova.conf.attestation_port | default "8443" }}

#
# The URL on the attestation server to use. See the `attestation_server` help
# text for more information about host verification.
#
# This value must be just that path portion of the full URL, as it will be
# joined
# to the host specified in the attestation_server option.
#
# This option is only used by the FilterScheduler and its subclasses; if you use
# a different scheduler, this option has no effect. Also note that this setting
# only affects scheduling if the 'TrustedFilter' filter is enabled.
#
# * Related options:
#
#     attestation_server
#     attestation_server_ca_file
#     attestation_port
#     attestation_auth_blob
#     attestation_auth_timeout
#     attestation_insecure_ssl
#  (string value)
# from .trusted_computing.nova.conf.attestation_api_url
{{ if not .trusted_computing.nova.conf.attestation_api_url }}#{{ end }}attestation_api_url = {{ .trusted_computing.nova.conf.attestation_api_url | default "/OpenAttestationWebServices/V1.0" }}

#
# Attestation servers require a specific blob that is used to authenticate. The
# content and format of the blob are determined by the particular attestation
# server being used. There is no default value; you must supply the value as
# specified by your attestation service. See the `attestation_server` help text
# for more information about host verification.
#
# This option is only used by the FilterScheduler and its subclasses; if you use
# a different scheduler, this option has no effect. Also note that this setting
# only affects scheduling if the 'TrustedFilter' filter is enabled.
#
# * Related options:
#
#     attestation_server
#     attestation_server_ca_file
#     attestation_port
#     attestation_api_url
#     attestation_auth_timeout
#     attestation_insecure_ssl
#  (string value)
# from .trusted_computing.nova.conf.attestation_auth_blob
{{ if not .trusted_computing.nova.conf.attestation_auth_blob }}#{{ end }}attestation_auth_blob = {{ .trusted_computing.nova.conf.attestation_auth_blob | default "<None>" }}

#
# This value controls how long a successful attestation is cached. Once this
# period has elapsed, a new attestation request will be made. See the
# `attestation_server` help text for more information about host verification.
#
# The value is in seconds. Valid values must be positive integers for any
# caching; setting this to zero or a negative value will result in calls to the
# attestation_server for every request, which may impact performance.
#
# This option is only used by the FilterScheduler and its subclasses; if you use
# a different scheduler, this option has no effect. Also note that this setting
# only affects scheduling if the 'TrustedFilter' filter is enabled.
#
# * Related options:
#
#     attestation_server
#     attestation_server_ca_file
#     attestation_port
#     attestation_api_url
#     attestation_auth_blob
#     attestation_insecure_ssl
#  (integer value)
# from .trusted_computing.nova.conf.attestation_auth_timeout
{{ if not .trusted_computing.nova.conf.attestation_auth_timeout }}#{{ end }}attestation_auth_timeout = {{ .trusted_computing.nova.conf.attestation_auth_timeout | default "60" }}

#
# When set to True, the SSL certificate verification is skipped for the
# attestation service. See the `attestation_server` help text for more
# information about host verification.
#
# Valid values are True or False. The default is False.
#
# This option is only used by the FilterScheduler and its subclasses; if you use
# a different scheduler, this option has no effect. Also note that this setting
# only affects scheduling if the 'TrustedFilter' filter is enabled.
#
# * Related options:
#
#     attestation_server
#     attestation_server_ca_file
#     attestation_port
#     attestation_api_url
#     attestation_auth_blob
#     attestation_auth_timeout
#  (boolean value)
# from .trusted_computing.nova.conf.attestation_insecure_ssl
{{ if not .trusted_computing.nova.conf.attestation_insecure_ssl }}#{{ end }}attestation_insecure_ssl = {{ .trusted_computing.nova.conf.attestation_insecure_ssl | default "false" }}


[upgrade_levels]

#
# From nova.conf
#

#
# Cells version
#
# Cells client-side RPC API version. Use this option to set a version
# cap for messages sent to local cells services.
#
# Possible values:
#
# * None: This is the default value.
# * grizzly: message version 1.6.
# * havana: message version 1.24.
# * icehouse: message version 1.27.
# * juno: message version 1.29.
# * kilo: message version 1.34.
# * liberty: message version 1.37.
#
# Services which consume this:
#
# * nova-cells
#
# Related options:
#
# * None
#  (string value)
# from .upgrade_levels.nova.conf.cells
{{ if not .upgrade_levels.nova.conf.cells }}#{{ end }}cells = {{ .upgrade_levels.nova.conf.cells | default "<None>" }}

#
# Intercell version
#
# Intercell RPC API is the client side of the Cell<->Cell RPC API.
# Use this option to set a version cap for messages sent between
# cells services.
#
# Possible values:
#
# * None: This is the default value.
# * grizzly: message version 1.0.
#
# Services which consume this:
#
# * nova-cells
#
# Related options:
#
# * None
#  (string value)
# from .upgrade_levels.nova.conf.intercell
{{ if not .upgrade_levels.nova.conf.intercell }}#{{ end }}intercell = {{ .upgrade_levels.nova.conf.intercell | default "<None>" }}

#
#
# Specifies the maximum version for messages sent from cert services. This
# should
# be the minimum value that is supported by all of the deployed cert services.
#
# Possible values:
#
# Any valid OpenStack release name, in lower case, such as 'mitaka' or
# 'liberty'.
# Alternatively, it can be any string representing a version number in the
# format
# 'N.N'; for example, possible values might be '1.12' or '2.0'.
#
# Services which consume this:
#
# * nova-cert
#
# Related options:
#
# * None
#  (string value)
# from .upgrade_levels.nova.conf.cert
{{ if not .upgrade_levels.nova.conf.cert }}#{{ end }}cert = {{ .upgrade_levels.nova.conf.cert | default "<None>" }}

# Set a version cap for messages sent to compute services. Set this option to
# "auto" if you want to let the compute RPC module automatically determine what
# version to use based on the service versions in the deployment. Otherwise, you
# can set this to a specific version to pin this service to messages at a
# particular level. All services of a single type (i.e. compute) should be
# configured to use the same version, and it should be set to the minimum
# commonly-supported version of all those services in the deployment. (string
# value)
# from .upgrade_levels.nova.conf.compute
{{ if not .upgrade_levels.nova.conf.compute }}#{{ end }}compute = {{ .upgrade_levels.nova.conf.compute | default "<None>" }}

#
# Sets a version cap (limit) for messages sent to scheduler services. In the
# situation where there were multiple scheduler services running, and they were
# not being upgraded together, you would set this to the lowest deployed version
# to guarantee that other services never send messages that any of your running
# schedulers cannot understand.
#
# This is rarely needed in practice as most deployments run a single scheduler.
# It exists mainly for design compatibility with the other services, such as
# compute, which are routinely upgraded in a rolling fashion.
#
# Services that use this:
#
# * nova-compute, nova-conductor
#
# Related options:
#
# * None
#  (string value)
# from .upgrade_levels.nova.conf.scheduler
{{ if not .upgrade_levels.nova.conf.scheduler }}#{{ end }}scheduler = {{ .upgrade_levels.nova.conf.scheduler | default "<None>" }}

# Set a version cap for messages sent to conductor services (string value)
# from .upgrade_levels.nova.conf.conductor
{{ if not .upgrade_levels.nova.conf.conductor }}#{{ end }}conductor = {{ .upgrade_levels.nova.conf.conductor | default "<None>" }}

# Set a version cap for messages sent to console services (string value)
# from .upgrade_levels.nova.conf.console
{{ if not .upgrade_levels.nova.conf.console }}#{{ end }}console = {{ .upgrade_levels.nova.conf.console | default "<None>" }}

# Set a version cap for messages sent to consoleauth services (string value)
# from .upgrade_levels.nova.conf.consoleauth
{{ if not .upgrade_levels.nova.conf.consoleauth }}#{{ end }}consoleauth = {{ .upgrade_levels.nova.conf.consoleauth | default "<None>" }}

# Set a version cap for messages sent to network services (string value)
# from .upgrade_levels.nova.conf.network
{{ if not .upgrade_levels.nova.conf.network }}#{{ end }}network = {{ .upgrade_levels.nova.conf.network | default "<None>" }}

# Set a version cap for messages sent to the base api in any service (string
# value)
# from .upgrade_levels.nova.conf.baseapi
{{ if not .upgrade_levels.nova.conf.baseapi }}#{{ end }}baseapi = {{ .upgrade_levels.nova.conf.baseapi | default "<None>" }}


[vmware]
#
# Related options:
# Following options must be set in order to launch VMware-based
# virtual machines.
#
# * compute_driver: Must use vmwareapi.VMwareVCDriver.
# * vmware.host_username
# * vmware.host_password
# * vmware.cluster_name

#
# From nova.conf
#

#
# This option specifies the physical ethernet adapter name for VLAN
# networking.
#
# Set the vlan_interface configuration option to match the ESX host
# interface that handles VLAN-tagged VM traffic.
#
# Possible values:
#
# * Any valid string representing VLAN interface name
#  (string value)
# from .vmware.nova.conf.vlan_interface
{{ if not .vmware.nova.conf.vlan_interface }}#{{ end }}vlan_interface = {{ .vmware.nova.conf.vlan_interface | default "vmnic0" }}

#
# This option should be configured only when using the NSX-MH Neutron
# plugin. This is the name of the integration bridge on the ESXi server
# or host. This should not be set for any other Neutron plugin. Hence
# the default value is not set.
#
# Possible values:
#
# * Any valid string representing the name of the integration bridge
#  (string value)
# from .vmware.nova.conf.integration_bridge
{{ if not .vmware.nova.conf.integration_bridge }}#{{ end }}integration_bridge = {{ .vmware.nova.conf.integration_bridge | default "<None>" }}

#
# Set this value if affected by an increased network latency causing
# repeated characters when typing in a remote console.
#  (integer value)
# Minimum value: 0
# from .vmware.nova.conf.console_delay_seconds
{{ if not .vmware.nova.conf.console_delay_seconds }}#{{ end }}console_delay_seconds = {{ .vmware.nova.conf.console_delay_seconds | default "<None>" }}

#
# Identifies the remote system where the serial port traffic will
# be sent.
#
# This option adds a virtual serial port which sends console output to
# a configurable service URI. At the service URI address there will be
# virtual serial port concentrator that will collect console logs.
# If this is not set, no serial ports will be added to the created VMs.
#
# Possible values:
#
# * Any valid URI
#  (string value)
# from .vmware.nova.conf.serial_port_service_uri
{{ if not .vmware.nova.conf.serial_port_service_uri }}#{{ end }}serial_port_service_uri = {{ .vmware.nova.conf.serial_port_service_uri | default "<None>" }}

#
# Identifies a proxy service that provides network access to the
# serial_port_service_uri.
#
# Possible values:
#
# * Any valid URI
#
# Related options:
# This option is ignored if serial_port_service_uri is not specified.
# * serial_port_service_uri
#  (string value)
# from .vmware.nova.conf.serial_port_proxy_uri
{{ if not .vmware.nova.conf.serial_port_proxy_uri }}#{{ end }}serial_port_proxy_uri = {{ .vmware.nova.conf.serial_port_proxy_uri | default "<None>" }}

#
# Hostname or IP address for connection to VMware vCenter host. (string value)
# from .vmware.nova.conf.host_ip
{{ if not .vmware.nova.conf.host_ip }}#{{ end }}host_ip = {{ .vmware.nova.conf.host_ip | default "<None>" }}

# Port for connection to VMware vCenter host. (port value)
# Minimum value: 0
# Maximum value: 65535
# from .vmware.nova.conf.host_port
{{ if not .vmware.nova.conf.host_port }}#{{ end }}host_port = {{ .vmware.nova.conf.host_port | default "443" }}

# Username for connection to VMware vCenter host. (string value)
# from .vmware.nova.conf.host_username
{{ if not .vmware.nova.conf.host_username }}#{{ end }}host_username = {{ .vmware.nova.conf.host_username | default "<None>" }}

# Password for connection to VMware vCenter host. (string value)
# from .vmware.nova.conf.host_password
{{ if not .vmware.nova.conf.host_password }}#{{ end }}host_password = {{ .vmware.nova.conf.host_password | default "<None>" }}

#
# Specifies the CA bundle file to be used in verifying the vCenter
# server certificate.
#  (string value)
# from .vmware.nova.conf.ca_file
{{ if not .vmware.nova.conf.ca_file }}#{{ end }}ca_file = {{ .vmware.nova.conf.ca_file | default "<None>" }}

#
# If true, the vCenter server certificate is not verified. If false,
# then the default CA truststore is used for verification.
#
# Related options:
# * ca_file: This option is ignored if "ca_file" is set.
#  (boolean value)
# from .vmware.nova.conf.insecure
{{ if not .vmware.nova.conf.insecure }}#{{ end }}insecure = {{ .vmware.nova.conf.insecure | default "false" }}

# Name of a VMware Cluster ComputeResource. (string value)
# from .vmware.nova.conf.cluster_name
{{ if not .vmware.nova.conf.cluster_name }}#{{ end }}cluster_name = {{ .vmware.nova.conf.cluster_name | default "<None>" }}

#
# Regular expression pattern to match the name of datastore.
#
# The datastore_regex setting specifies the datastores to use with
# Compute. For example, datastore_regex="nas.*" selects all the data
# stores that have a name starting with "nas".
#
# NOTE: If no regex is given, it just picks the datastore with the
# most freespace.
#
# Possible values:
#
# * Any matching regular expression to a datastore must be given
#  (string value)
# from .vmware.nova.conf.datastore_regex
{{ if not .vmware.nova.conf.datastore_regex }}#{{ end }}datastore_regex = {{ .vmware.nova.conf.datastore_regex | default "<None>" }}

#
# Time interval in seconds to poll remote tasks invoked on
# VMware VC server.
#  (floating point value)
# from .vmware.nova.conf.task_poll_interval
{{ if not .vmware.nova.conf.task_poll_interval }}#{{ end }}task_poll_interval = {{ .vmware.nova.conf.task_poll_interval | default "0.5" }}

#
# Number of times VMware vCenter server API must be retried on connection
# failures, e.g. socket error, etc.
#  (integer value)
# Minimum value: 0
# from .vmware.nova.conf.api_retry_count
{{ if not .vmware.nova.conf.api_retry_count }}#{{ end }}api_retry_count = {{ .vmware.nova.conf.api_retry_count | default "10" }}

#
# This option specifies VNC starting port.
#
# Every VM created by ESX host has an option of enabling VNC client
# for remote connection. Above option 'vnc_port' helps you to set
# default starting port for the VNC client.
#
# Possible values:
#
# * Any valid port number within 5900 -(5900 + vnc_port_total)
#
# Related options:
# Below options should be set to enable VNC client.
# * vnc.enabled = True
# * vnc_port_total
#  (port value)
# Minimum value: 0
# Maximum value: 65535
# from .vmware.nova.conf.vnc_port
{{ if not .vmware.nova.conf.vnc_port }}#{{ end }}vnc_port = {{ .vmware.nova.conf.vnc_port | default "5900" }}

#
# Total number of VNC ports.
#  (integer value)
# Minimum value: 0
# from .vmware.nova.conf.vnc_port_total
{{ if not .vmware.nova.conf.vnc_port_total }}#{{ end }}vnc_port_total = {{ .vmware.nova.conf.vnc_port_total | default "10000" }}

#
# This option enables/disables the use of linked clone.
#
# The ESX hypervisor requires a copy of the VMDK file in order to boot
# up a virtual machine. The compute driver must download the VMDK via
# HTTP from the OpenStack Image service to a datastore that is visible
# to the hypervisor and cache it. Subsequent virtual machines that need
# the VMDK use the cached version and don't have to copy the file again
# from the OpenStack Image service.
#
# If set to false, even with a cached VMDK, there is still a copy
# operation from the cache location to the hypervisor file directory
# in the shared datastore. If set to true, the above copy operation
# is avoided as it creates copy of the virtual machine that shares
# virtual disks with its parent VM.
#  (boolean value)
# from .vmware.nova.conf.use_linked_clone
{{ if not .vmware.nova.conf.use_linked_clone }}#{{ end }}use_linked_clone = {{ .vmware.nova.conf.use_linked_clone | default "true" }}

#
# This option specifies VIM Service WSDL Location
#
# If vSphere API versions 5.1 and later is being used, this section can
# be ignored. If version is less than 5.1, WSDL files must be hosted
# locally and their location must be specified in the above section.
#
# Optional over-ride to default location for bug work-arounds.
#
# Possible values:
#
# * http://<server>/vimService.wsdl
# * file:///opt/stack/vmware/SDK/wsdl/vim25/vimService.wsdl
#  (string value)
# from .vmware.nova.conf.wsdl_location
{{ if not .vmware.nova.conf.wsdl_location }}#{{ end }}wsdl_location = {{ .vmware.nova.conf.wsdl_location | default "<None>" }}

#
# This option enables or disables storage policy based placement
# of instances.
#
# Related options:
#
# * pbm_default_policy
#  (boolean value)
# from .vmware.nova.conf.pbm_enabled
{{ if not .vmware.nova.conf.pbm_enabled }}#{{ end }}pbm_enabled = {{ .vmware.nova.conf.pbm_enabled | default "false" }}

#
# This option specifies the PBM service WSDL file location URL.
#
# Setting this will disable storage policy based placement
# of instances.
#
# Possible values:
#
# * Any valid file path
#   e.g file:///opt/SDK/spbm/wsdl/pbmService.wsdl
#  (string value)
# from .vmware.nova.conf.pbm_wsdl_location
{{ if not .vmware.nova.conf.pbm_wsdl_location }}#{{ end }}pbm_wsdl_location = {{ .vmware.nova.conf.pbm_wsdl_location | default "<None>" }}

#
# This option specifies the default policy to be used.
#
# If pbm_enabled is set and there is no defined storage policy for the
# specific request, then this policy will be used.
#
# Possible values:
#
# * Any valid storage policy such as VSAN default storage policy
#
# Related options:
#
# * pbm_enabled
#  (string value)
# from .vmware.nova.conf.pbm_default_policy
{{ if not .vmware.nova.conf.pbm_default_policy }}#{{ end }}pbm_default_policy = {{ .vmware.nova.conf.pbm_default_policy | default "<None>" }}

#
# This option specifies the limit on the maximum number of objects to
# return in a single result.
#
# A positive value will cause the operation to suspend the retrieval
# when the count of objects reaches the specified limit. The server may
# still limit the count to something less than the configured value.
# Any remaining objects may be retrieved with additional requests.
#  (integer value)
# Minimum value: 0
# from .vmware.nova.conf.maximum_objects
{{ if not .vmware.nova.conf.maximum_objects }}#{{ end }}maximum_objects = {{ .vmware.nova.conf.maximum_objects | default "100" }}

#
# This option adds a prefix to the folder where cached images are stored
#
# This is not the full path - just a folder prefix. This should only be
# used when a datastore cache is shared between compute nodes.
#
# Note: This should only be used when the compute nodes are running on same
# host or they have a shared file system.
#
# Possible values:
#
# * Any string representing the cache prefix to the folder
#  (string value)
# from .vmware.nova.conf.cache_prefix
{{ if not .vmware.nova.conf.cache_prefix }}#{{ end }}cache_prefix = {{ .vmware.nova.conf.cache_prefix | default "<None>" }}


[vnc]
#
# Virtual Network Computer (VNC) can be used to provide remote desktop
# console access to instances for tenants and/or administrators.

#
# From nova.conf
#

#
# Enable VNC related features.
#
# Guests will get created with graphical devices to support this. Clients
# (for example Horizon) can then establish a VNC connection to the guest.
#  (boolean value)
# Deprecated group/name - [DEFAULT]/vnc_enabled
# from .vnc.nova.conf.enabled
{{ if not .vnc.nova.conf.enabled }}#{{ end }}enabled = {{ .vnc.nova.conf.enabled | default "true" }}

#
# Keymap for VNC.
#
# The keyboard mapping (keymap) determines which keyboard layout a VNC
# session should use by default.
#
# Possible values:
#
# * A keyboard layout which is supported by the underlying hypervisor on
#   this node. This is usually an 'IETF language tag' (for example
#   'en-us').  If you use QEMU as hypervisor, you should find the  list
#   of supported keyboard layouts at ``/usr/share/qemu/keymaps``.
#  (string value)
# Deprecated group/name - [DEFAULT]/vnc_keymap
# from .vnc.nova.conf.keymap
{{ if not .vnc.nova.conf.keymap }}#{{ end }}keymap = {{ .vnc.nova.conf.keymap | default "en-us" }}

#
# The IP address or hostname on which an instance should listen to for
# incoming VNC connection requests on this node.
#  (string value)
# Deprecated group/name - [DEFAULT]/vncserver_listen
# from .vnc.nova.conf.vncserver_listen
{{ if not .vnc.nova.conf.vncserver_listen }}#{{ end }}vncserver_listen = {{ .vnc.nova.conf.vncserver_listen | default "127.0.0.1" }}

#
# Private, internal IP address or hostname of VNC console proxy.
#
# The VNC proxy is an OpenStack component that enables compute service
# users to access their instances through VNC clients.
#
# This option sets the private address to which proxy clients, such as
# ``nova-xvpvncproxy``, should connect to.
#  (string value)
# Deprecated group/name - [DEFAULT]/vncserver_proxyclient_address
# from .vnc.nova.conf.vncserver_proxyclient_address
{{ if not .vnc.nova.conf.vncserver_proxyclient_address }}#{{ end }}vncserver_proxyclient_address = {{ .vnc.nova.conf.vncserver_proxyclient_address | default "127.0.0.1" }}

#
# Public address of noVNC VNC console proxy.
#
# The VNC proxy is an OpenStack component that enables compute service
# users to access their instances through VNC clients. noVNC provides
# VNC support through a websocket-based client.
#
# This option sets the public base URL to which client systems will
# connect. noVNC clients can use this address to connect to the noVNC
# instance and, by extension, the VNC sessions.
#
# Related options:
#
# * novncproxy_host
# * novncproxy_port
#  (uri value)
# Deprecated group/name - [DEFAULT]/novncproxy_base_url
# from .vnc.nova.conf.novncproxy_base_url
{{ if not .vnc.nova.conf.novncproxy_base_url }}#{{ end }}novncproxy_base_url = {{ .vnc.nova.conf.novncproxy_base_url | default "http://127.0.0.1:6080/vnc_auto.html" }}

#
# IP address or hostname that the XVP VNC console proxy should bind to.
#
# The VNC proxy is an OpenStack component that enables compute service
# users to access their instances through VNC clients. Xen provides
# the Xenserver VNC Proxy, or XVP, as an alternative to the
# websocket-based noVNC proxy used by Libvirt. In contrast to noVNC,
# XVP clients are Java-based.
#
# This option sets the private address to which the XVP VNC console proxy
# service should bind to.
#
# Related options:
#
# * xvpvncproxy_port
# * xvpvncproxy_base_url
#  (string value)
# Deprecated group/name - [DEFAULT]/xvpvncproxy_host
# from .vnc.nova.conf.xvpvncproxy_host
{{ if not .vnc.nova.conf.xvpvncproxy_host }}#{{ end }}xvpvncproxy_host = {{ .vnc.nova.conf.xvpvncproxy_host | default "0.0.0.0" }}

#
# Port that the XVP VNC console proxy should bind to.
#
# The VNC proxy is an OpenStack component that enables compute service
# users to access their instances through VNC clients. Xen provides
# the Xenserver VNC Proxy, or XVP, as an alternative to the
# websocket-based noVNC proxy used by Libvirt. In contrast to noVNC,
# XVP clients are Java-based.
#
# This option sets the private port to which the XVP VNC console proxy
# service should bind to.
#
# Related options:
#
# * xvpvncproxy_host
# * xvpvncproxy_base_url
#  (port value)
# Minimum value: 0
# Maximum value: 65535
# Deprecated group/name - [DEFAULT]/xvpvncproxy_port
# from .vnc.nova.conf.xvpvncproxy_port
{{ if not .vnc.nova.conf.xvpvncproxy_port }}#{{ end }}xvpvncproxy_port = {{ .vnc.nova.conf.xvpvncproxy_port | default "6081" }}

#
# Public URL address of XVP VNC console proxy.
#
# The VNC proxy is an OpenStack component that enables compute service
# users to access their instances through VNC clients. Xen provides
# the Xenserver VNC Proxy, or XVP, as an alternative to the
# websocket-based noVNC proxy used by Libvirt. In contrast to noVNC,
# XVP clients are Java-based.
#
# This option sets the public base URL to which client systems will
# connect. XVP clients can use this address to connect to the XVP
# instance and, by extension, the VNC sessions.
#
# Related options:
#
# * xvpvncproxy_host
# * xvpvncproxy_port
#  (uri value)
# Deprecated group/name - [DEFAULT]/xvpvncproxy_base_url
# from .vnc.nova.conf.xvpvncproxy_base_url
{{ if not .vnc.nova.conf.xvpvncproxy_base_url }}#{{ end }}xvpvncproxy_base_url = {{ .vnc.nova.conf.xvpvncproxy_base_url | default "http://127.0.0.1:6081/console" }}

#
# IP address that the noVNC console proxy should bind to.
#
# The VNC proxy is an OpenStack component that enables compute service
# users to access their instances through VNC clients. noVNC provides
# VNC support through a websocket-based client.
#
# This option sets the private address to which the noVNC console proxy
# service should bind to.
#
# Related options:
#
# * novncproxy_port
# * novncproxy_base_url
#  (string value)
# Deprecated group/name - [DEFAULT]/novncproxy_host
# from .vnc.nova.conf.novncproxy_host
{{ if not .vnc.nova.conf.novncproxy_host }}#{{ end }}novncproxy_host = {{ .vnc.nova.conf.novncproxy_host | default "0.0.0.0" }}

#
# Port that the noVNC console proxy should bind to.
#
# The VNC proxy is an OpenStack component that enables compute service
# users to access their instances through VNC clients. noVNC provides
# VNC support through a websocket-based client.
#
# This option sets the private port to which the noVNC console proxy
# service should bind to.
#
# Related options:
#
# * novncproxy_host
# * novncproxy_base_url
#  (port value)
# Minimum value: 0
# Maximum value: 65535
# Deprecated group/name - [DEFAULT]/novncproxy_port
# from .vnc.nova.conf.novncproxy_port
{{ if not .vnc.nova.conf.novncproxy_port }}#{{ end }}novncproxy_port = {{ .vnc.nova.conf.novncproxy_port | default "6080" }}


[workarounds]
#
# A collection of workarounds used to mitigate bugs or issues found in system
# tools (e.g. Libvirt or QEMU) or Nova itself under certain conditions. These
# should only be enabled in exceptional circumstances. All options are linked
# against bug IDs, where more information on the issue can be found.

#
# From nova.conf
#

#
# Use sudo instead of rootwrap.
#
# Allow fallback to sudo for performance reasons.
#
# For more information, refer to the bug report:
#
#   https://bugs.launchpad.net/nova/+bug/1415106
#
# Possible values:
#
# * True: Use sudo instead of rootwrap
# * False: Use rootwrap as usual
#
# Interdependencies to other options:
#
# * Any options that affect 'rootwrap' will be ignored.
#  (boolean value)
# from .workarounds.nova.conf.disable_rootwrap
{{ if not .workarounds.nova.conf.disable_rootwrap }}#{{ end }}disable_rootwrap = {{ .workarounds.nova.conf.disable_rootwrap | default "false" }}

#
# Disable live snapshots when using the libvirt driver.
#
# Live snapshots allow the snapshot of the disk to happen without an
# interruption to the guest, using coordination with a guest agent to
# quiesce the filesystem.
#
# When using libvirt 1.2.2 live snapshots fail intermittently under load
# (likely related to concurrent libvirt/qemu operations). This config
# option provides a mechanism to disable live snapshot, in favor of cold
# snapshot, while this is resolved. Cold snapshot causes an instance
# outage while the guest is going through the snapshotting process.
#
# For more information, refer to the bug report:
#
#   https://bugs.launchpad.net/nova/+bug/1334398
#
# Possible values:
#
# * True: Live snapshot is disabled when using libvirt
# * False: Live snapshots are always used when snapshotting (as long as
#   there is a new enough libvirt and the backend storage supports it)
#  (boolean value)
# from .workarounds.nova.conf.disable_libvirt_livesnapshot
{{ if not .workarounds.nova.conf.disable_libvirt_livesnapshot }}#{{ end }}disable_libvirt_livesnapshot = {{ .workarounds.nova.conf.disable_libvirt_livesnapshot | default "true" }}

#
# Enable handling of events emitted from compute drivers.
#
# Many compute drivers emit lifecycle events, which are events that occur when,
# for example, an instance is starting or stopping. If the instance is going
# through task state changes due to an API operation, like resize, the events
# are ignored.
#
# This is an advanced feature which allows the hypervisor to signal to the
# compute service that an unexpected state change has occurred in an instance
# and that the instance can be shutdown automatically. Unfortunately, this can
# race in some conditions, for example in reboot operations or when the compute
# service or when host is rebooted (planned or due to an outage). If such races
# are common, then it is advisable to disable this feature.
#
# Care should be taken when this feature is disabled and
# 'sync_power_state_interval' is set to a negative value. In this case, any
# instances that get out of sync between the hypervisor and the Nova database
# will have to be synchronized manually.
#
# For more information, refer to the bug report:
#
#   https://bugs.launchpad.net/bugs/1444630
#
# Interdependencies to other options:
#
# * If ``sync_power_state_interval`` is negative and this feature is disabled,
#   then instances that get out of sync between the hypervisor and the Nova
#   database will have to be synchronized manually.
#  (boolean value)
# from .workarounds.nova.conf.handle_virt_lifecycle_events
{{ if not .workarounds.nova.conf.handle_virt_lifecycle_events }}#{{ end }}handle_virt_lifecycle_events = {{ .workarounds.nova.conf.handle_virt_lifecycle_events | default "true" }}


[wsgi]
#
# Options under this group are used to configure WSGI (Web Server Gateway
# Interface). WSGI is used to serve API requests.

#
# From nova.conf
#

#
# This option represents a file name for the paste.deploy config for nova-api.
#
# Possible values:
#  * A string representing file name for the paste.deploy config.
#  (string value)
# Deprecated group/name - [DEFAULT]/api_paste_config
# from .wsgi.nova.conf.api_paste_config
{{ if not .wsgi.nova.conf.api_paste_config }}#{{ end }}api_paste_config = {{ .wsgi.nova.conf.api_paste_config | default "api-paste.ini" }}

#
# It represents a python format string that is used as the template to generate
# log lines. The following values can be formatted into it: client_ip,
# date_time, request_line, status_code, body_length, wall_seconds.
#
# This option is used for building custom request loglines.
#
# Possible values:
#
#  * '%(client_ip)s "%(request_line)s" status: %(status_code)s'
#    'len: %(body_length)s time: %(wall_seconds).7f' (default)
#  * Any formatted string formed by specific values.
#  (string value)
# Deprecated group/name - [DEFAULT]/wsgi_log_format
# from .wsgi.nova.conf.wsgi_log_format
{{ if not .wsgi.nova.conf.wsgi_log_format }}#{{ end }}wsgi_log_format = {{ .wsgi.nova.conf.wsgi_log_format | default "%(client_ip)s \"%(request_line)s\" status: %(status_code)s len: %(body_length)s time: %(wall_seconds).7f" }}

#
# This option specifies the HTTP header used to determine the protocol scheme
# for the original request, even if it was removed by a SSL terminating proxy.
#
# Possible values:
#
#  * None (default) - the request scheme is not influenced by any HTTP headers.
#  * Valid HTTP header, like HTTP_X_FORWARDED_PROTO
#  (string value)
# Deprecated group/name - [DEFAULT]/secure_proxy_ssl_header
# from .wsgi.nova.conf.secure_proxy_ssl_header
{{ if not .wsgi.nova.conf.secure_proxy_ssl_header }}#{{ end }}secure_proxy_ssl_header = {{ .wsgi.nova.conf.secure_proxy_ssl_header | default "<None>" }}

#
# This option allows setting path to the CA certificate file that should be used
# to verify connecting clients.
#
# Possible values:
#
#  * String representing path to the CA certificate file.
#
# Related options:
#
#  * enabled_ssl_apis
#  (string value)
# Deprecated group/name - [DEFAULT]/ssl_ca_file
# from .wsgi.nova.conf.ssl_ca_file
{{ if not .wsgi.nova.conf.ssl_ca_file }}#{{ end }}ssl_ca_file = {{ .wsgi.nova.conf.ssl_ca_file | default "<None>" }}

#
# This option allows setting path to the SSL certificate of API server.
#
# Possible values:
#
#  * String representing path to the SSL certificate.
#
# Related options:
#
#  * enabled_ssl_apis
#  (string value)
# Deprecated group/name - [DEFAULT]/ssl_cert_file
# from .wsgi.nova.conf.ssl_cert_file
{{ if not .wsgi.nova.conf.ssl_cert_file }}#{{ end }}ssl_cert_file = {{ .wsgi.nova.conf.ssl_cert_file | default "<None>" }}

#
# This option specifies the path to the file where SSL private key of API
# server is stored when SSL is in effect.
#
# Possible values:
#
#  * String representing path to the SSL private key.
#
# Related options:
#
#  * enabled_ssl_apis
#  (string value)
# Deprecated group/name - [DEFAULT]/ssl_key_file
# from .wsgi.nova.conf.ssl_key_file
{{ if not .wsgi.nova.conf.ssl_key_file }}#{{ end }}ssl_key_file = {{ .wsgi.nova.conf.ssl_key_file | default "<None>" }}

#
# This option sets the value of TCP_KEEPIDLE in seconds for each server socket.
# It specifies the duration of time to keep connection active. TCP generates a
# KEEPALIVE transmission for an application that requests to keep connection
# active. Not supported on OS X.
#
# Related options:
#
#  * keep_alive
#  (integer value)
# Minimum value: 0
# Deprecated group/name - [DEFAULT]/tcp_keepidle
# from .wsgi.nova.conf.tcp_keepidle
{{ if not .wsgi.nova.conf.tcp_keepidle }}#{{ end }}tcp_keepidle = {{ .wsgi.nova.conf.tcp_keepidle | default "600" }}

#
# This option specifies the size of the pool of greenthreads used by wsgi.
# It is possible to limit the number of concurrent connections using this
# option.
#  (integer value)
# Minimum value: 0
# Deprecated group/name - [DEFAULT]/wsgi_default_pool_size
# from .wsgi.nova.conf.default_pool_size
{{ if not .wsgi.nova.conf.default_pool_size }}#{{ end }}default_pool_size = {{ .wsgi.nova.conf.default_pool_size | default "1000" }}

#
# This option specifies the maximum line size of message headers to be accepted.
# max_header_line may need to be increased when using large tokens (typically
# those generated by the Keystone v3 API with big service catalogs).
#
# Since TCP is a stream based protocol, in order to reuse a connection, the HTTP
# has to have a way to indicate the end of the previous response and beginning
# of the next. Hence, in a keep_alive case, all messages must have a
# self-defined message length.
#  (integer value)
# Minimum value: 0
# Deprecated group/name - [DEFAULT]/max_header_line
# from .wsgi.nova.conf.max_header_line
{{ if not .wsgi.nova.conf.max_header_line }}#{{ end }}max_header_line = {{ .wsgi.nova.conf.max_header_line | default "16384" }}

#
# This option allows using the same TCP connection to send and receive multiple
# HTTP requests/responses, as opposed to opening a new one for every single
# request/response pair. HTTP keep-alive indicates HTTP connection reuse.
#
# Possible values:
#
#  * True : reuse HTTP connection.
#  * False : closes the client socket connection explicitly.
#
# Related options:
#
#  * tcp_keepidle
#  (boolean value)
# Deprecated group/name - [DEFAULT]/wsgi_keep_alive
# from .wsgi.nova.conf.keep_alive
{{ if not .wsgi.nova.conf.keep_alive }}#{{ end }}keep_alive = {{ .wsgi.nova.conf.keep_alive | default "true" }}

#
# This option specifies the timeout for client connections' socket operations.
# If an incoming connection is idle for this number of seconds it will be
# closed. It indicates timeout on individual read/writes on the socket
# connection. To wait forever set to 0.
#  (integer value)
# Minimum value: 0
# Deprecated group/name - [DEFAULT]/client_socket_timeout
# from .wsgi.nova.conf.client_socket_timeout
{{ if not .wsgi.nova.conf.client_socket_timeout }}#{{ end }}client_socket_timeout = {{ .wsgi.nova.conf.client_socket_timeout | default "900" }}


[xenserver]
#
# XenServer options are used when the compute_driver is set to use
# XenServer (compute_driver=xenapi.XenAPIDriver).
#
# Must specify connection_url, and connection_password to use
# compute_driver=xenapi.XenAPIDriver.

#
# From nova.conf
#

#
# Number of seconds to wait for agent's reply to a request.
#
# Nova configures/performs certain administrative actions on a server with the
# help of an agent that's installed on the server. The communication between
# Nova and the agent is achieved via sharing messages, called records, over
# xenstore, a shared storage across all the domains on a Xenserver host.
# Operations performed by the agent on behalf of nova are: 'version','
# key_init',
# 'password','resetnetwork','inject_file', and 'agentupdate'.
#
# To perform one of the above operations, the xapi 'agent' plugin writes the
# command and its associated parameters to a certain location known to the
# domain
# and awaits response. On being notified of the message, the agent performs
# appropriate actions on the server and writes the result back to xenstore. This
# result is then read by the xapi 'agent' plugin to determine the
# success/failure
# of the operation.
#
# This config option determines how long the xapi 'agent' plugin shall wait to
# read the response off of xenstore for a given request/command. If the agent on
# the instance fails to write the result in this time period, the operation is
# considered to have timed out.
#
# Related options:
#   * ``agent_version_timeout``
#   * ``agent_resetnetwork_timeout``
#  (integer value)
# Minimum value: 0
# from .xenserver.nova.conf.agent_timeout
{{ if not .xenserver.nova.conf.agent_timeout }}#{{ end }}agent_timeout = {{ .xenserver.nova.conf.agent_timeout | default "30" }}

#
# Number of seconds to wait for agent't reply to version request.
#
# This indicates the amount of time xapi 'agent' plugin waits for the agent to
# respond to the 'version' request specifically. The generic timeout for agent
# communication ``agent_timeout`` is ignored in this case.
#
# During the build process the 'version' request is used to determine if the
# agent is available/operational to perform other requests such as
# 'resetnetwork', 'password', 'key_init' and 'inject_file'. If the 'version'
# call
# fails, the other configuration is skipped. So, this configuration option can
# also be interpreted as time in which agent is expected to be fully
# operational.
#  (integer value)
# Minimum value: 0
# from .xenserver.nova.conf.agent_version_timeout
{{ if not .xenserver.nova.conf.agent_version_timeout }}#{{ end }}agent_version_timeout = {{ .xenserver.nova.conf.agent_version_timeout | default "300" }}

#
# Number of seconds to wait for agent's reply to resetnetwork
# request.
#
# This indicates the amount of time xapi 'agent' plugin waits for the agent to
# respond to the 'resetnetwork' request specifically. The generic timeout for
# agent communication ``agent_timeout`` is ignored in this case.
#  (integer value)
# Minimum value: 0
# from .xenserver.nova.conf.agent_resetnetwork_timeout
{{ if not .xenserver.nova.conf.agent_resetnetwork_timeout }}#{{ end }}agent_resetnetwork_timeout = {{ .xenserver.nova.conf.agent_resetnetwork_timeout | default "60" }}

#
# Path to locate guest agent on the server.
#
# Specifies the path in which the XenAPI guest agent should be located. If the
# agent is present, network configuration is not injected into the image.
#
# Related options:
#   For this option to have an effect:
#   * ``flat_injected`` should be set to ``True``
#   * ``compute_driver`` should be set to ``xenapi.XenAPIDriver``
#  (string value)
# from .xenserver.nova.conf.agent_path
{{ if not .xenserver.nova.conf.agent_path }}#{{ end }}agent_path = {{ .xenserver.nova.conf.agent_path | default "usr/sbin/xe-update-networking" }}

#
# Disables the use of XenAPI agent.
#
# This configuration option suggests whether the use of agent should be enabled
# or not regardless of what image properties are present. Image properties have
# an effect only when this is set to ``True``. Read description of config option
# ``use_agent_default`` for more information.
#
# Related options:
#   * ``use_agent_default``
#  (boolean value)
# from .xenserver.nova.conf.disable_agent
{{ if not .xenserver.nova.conf.disable_agent }}#{{ end }}disable_agent = {{ .xenserver.nova.conf.disable_agent | default "false" }}

#
# Whether or not to use the agent by default when its usage is enabled but not
# indicated by the image.
#
# The use of XenAPI agent can be disabled altogether using the configuration
# option ``disable_agent``. However, if it is not disabled, the use of an agent
# can still be controlled by the image in use through one of its properties,
# ``xenapi_use_agent``. If this property is either not present or specified
# incorrectly on the image, the use of agent is determined by this configuration
# option.
#
# Note that if this configuration is set to ``True`` when the agent is not
# present, the boot times will increase significantly.
#
# Related options:
#   * ``disable_agent``
#  (boolean value)
# from .xenserver.nova.conf.use_agent_default
{{ if not .xenserver.nova.conf.use_agent_default }}#{{ end }}use_agent_default = {{ .xenserver.nova.conf.use_agent_default | default "false" }}

# Timeout in seconds for XenAPI login. (integer value)
# from .xenserver.nova.conf.login_timeout
{{ if not .xenserver.nova.conf.login_timeout }}#{{ end }}login_timeout = {{ .xenserver.nova.conf.login_timeout | default "10" }}

# Maximum number of concurrent XenAPI connections. Used only if
# compute_driver=xenapi.XenAPIDriver (integer value)
# from .xenserver.nova.conf.connection_concurrent
{{ if not .xenserver.nova.conf.connection_concurrent }}#{{ end }}connection_concurrent = {{ .xenserver.nova.conf.connection_concurrent | default "5" }}

# Base URL for torrent files; must contain a slash character (see RFC 1808, step
# 6) (string value)
# from .xenserver.nova.conf.torrent_base_url
{{ if not .xenserver.nova.conf.torrent_base_url }}#{{ end }}torrent_base_url = {{ .xenserver.nova.conf.torrent_base_url | default "<None>" }}

# Probability that peer will become a seeder. (1.0 = 100%) (floating point
# value)
# from .xenserver.nova.conf.torrent_seed_chance
{{ if not .xenserver.nova.conf.torrent_seed_chance }}#{{ end }}torrent_seed_chance = {{ .xenserver.nova.conf.torrent_seed_chance | default "1.0" }}

# Number of seconds after downloading an image via BitTorrent that it should be
# seeded for other peers. (integer value)
# from .xenserver.nova.conf.torrent_seed_duration
{{ if not .xenserver.nova.conf.torrent_seed_duration }}#{{ end }}torrent_seed_duration = {{ .xenserver.nova.conf.torrent_seed_duration | default "3600" }}

# Cached torrent files not accessed within this number of seconds can be reaped
# (integer value)
# from .xenserver.nova.conf.torrent_max_last_accessed
{{ if not .xenserver.nova.conf.torrent_max_last_accessed }}#{{ end }}torrent_max_last_accessed = {{ .xenserver.nova.conf.torrent_max_last_accessed | default "86400" }}

# Beginning of port range to listen on (port value)
# Minimum value: 0
# Maximum value: 65535
# from .xenserver.nova.conf.torrent_listen_port_start
{{ if not .xenserver.nova.conf.torrent_listen_port_start }}#{{ end }}torrent_listen_port_start = {{ .xenserver.nova.conf.torrent_listen_port_start | default "6881" }}

# End of port range to listen on (port value)
# Minimum value: 0
# Maximum value: 65535
# from .xenserver.nova.conf.torrent_listen_port_end
{{ if not .xenserver.nova.conf.torrent_listen_port_end }}#{{ end }}torrent_listen_port_end = {{ .xenserver.nova.conf.torrent_listen_port_end | default "6891" }}

# Number of seconds a download can remain at the same progress percentage w/o
# being considered a stall (integer value)
# from .xenserver.nova.conf.torrent_download_stall_cutoff
{{ if not .xenserver.nova.conf.torrent_download_stall_cutoff }}#{{ end }}torrent_download_stall_cutoff = {{ .xenserver.nova.conf.torrent_download_stall_cutoff | default "600" }}

# Maximum number of seeder processes to run concurrently within a given dom0.
# (-1 = no limit) (integer value)
# from .xenserver.nova.conf.torrent_max_seeder_processes_per_host
{{ if not .xenserver.nova.conf.torrent_max_seeder_processes_per_host }}#{{ end }}torrent_max_seeder_processes_per_host = {{ .xenserver.nova.conf.torrent_max_seeder_processes_per_host | default "1" }}

#
# Cache glance images locally.
#
# The value for this option must be choosen from the choices listed
# here. Configuring a value other than these will default to 'all'.
#
# Note: There is nothing that deletes these images.
#
# Possible values:
#
# * `all`: will cache all images.
# * `some`: will only cache images that have the
#   image_property `cache_in_nova=True`.
# * `none`: turns off caching entirely.
#  (string value)
# Allowed values: all, some, none
# from .xenserver.nova.conf.cache_images
{{ if not .xenserver.nova.conf.cache_images }}#{{ end }}cache_images = {{ .xenserver.nova.conf.cache_images | default "all" }}

#
# Compression level for images.
#
# By setting this option we can configure the gzip compression level.
# This option sets GZIP environment variable before spawning tar -cz
# to force the compression level. It defaults to none, which means the
# GZIP environment variable is not set and the default (usually -6)
# is used.
#
# Possible values:
#
# * Range is 1-9, e.g., 9 for gzip -9, 9 being most
#   compressed but most CPU intensive on dom0.
# * Any values out of this range will default to None.
#  (integer value)
# Minimum value: 1
# Maximum value: 9
# from .xenserver.nova.conf.image_compression_level
{{ if not .xenserver.nova.conf.image_compression_level }}#{{ end }}image_compression_level = {{ .xenserver.nova.conf.image_compression_level | default "<None>" }}

# Default OS type used when uploading an image to glance (string value)
# from .xenserver.nova.conf.default_os_type
{{ if not .xenserver.nova.conf.default_os_type }}#{{ end }}default_os_type = {{ .xenserver.nova.conf.default_os_type | default "linux" }}

# Time in secs to wait for a block device to be created (integer value)
# Minimum value: 1
# from .xenserver.nova.conf.block_device_creation_timeout
{{ if not .xenserver.nova.conf.block_device_creation_timeout }}#{{ end }}block_device_creation_timeout = {{ .xenserver.nova.conf.block_device_creation_timeout | default "10" }}

#
# Maximum size in bytes of kernel or ramdisk images.
#
# Specifying the maximum size of kernel or ramdisk will avoid copying
# large files to dom0 and fill up /boot/guest.
#  (integer value)
# from .xenserver.nova.conf.max_kernel_ramdisk_size
{{ if not .xenserver.nova.conf.max_kernel_ramdisk_size }}#{{ end }}max_kernel_ramdisk_size = {{ .xenserver.nova.conf.max_kernel_ramdisk_size | default "16777216" }}

#
# Filter for finding the SR to be used to install guest instances on.
#
# Possible values:
#
# * To use the Local Storage in default XenServer/XCP installations
#   set this flag to other-config:i18n-key=local-storage.
# * To select an SR with a different matching criteria, you could
#   set it to other-config:my_favorite_sr=true.
# * To fall back on the Default SR, as displayed by XenCenter,
#   set this flag to: default-sr:true.
#  (string value)
# from .xenserver.nova.conf.sr_matching_filter
{{ if not .xenserver.nova.conf.sr_matching_filter }}#{{ end }}sr_matching_filter = {{ .xenserver.nova.conf.sr_matching_filter | default "default-sr:true" }}

#
# Whether to use sparse_copy for copying data on a resize down.
# (False will use standard dd). This speeds up resizes down
# considerably since large runs of zeros won't have to be rsynced.
#  (boolean value)
# from .xenserver.nova.conf.sparse_copy
{{ if not .xenserver.nova.conf.sparse_copy }}#{{ end }}sparse_copy = {{ .xenserver.nova.conf.sparse_copy | default "true" }}

#
# Maximum number of retries to unplug VBD.
# If set to 0, should try once, no retries.
#  (integer value)
# Minimum value: 0
# from .xenserver.nova.conf.num_vbd_unplug_retries
{{ if not .xenserver.nova.conf.num_vbd_unplug_retries }}#{{ end }}num_vbd_unplug_retries = {{ .xenserver.nova.conf.num_vbd_unplug_retries | default "10" }}

#
# Whether or not to download images via Bit Torrent.
#
# The value for this option must be choosen from the choices listed
# here. Configuring a value other than these will default to 'none'.
#
# Possible values:
#
# * `all`: will download all images.
# * `some`: will only download images that have the image_property
#           `bittorrent=true'.
# * `none`: will turnoff downloading images via Bit Torrent.
#  (string value)
# Allowed values: all, some, none
# from .xenserver.nova.conf.torrent_images
{{ if not .xenserver.nova.conf.torrent_images }}#{{ end }}torrent_images = {{ .xenserver.nova.conf.torrent_images | default "none" }}

#
# Name of network to use for booting iPXE ISOs.
#
# An iPXE ISO is a specially crafted ISO which supports iPXE booting.
# This feature gives a means to roll your own image.
#
# By default this option is not set. Enable this option to
# boot an iPXE ISO.
#
# Related Options:
#
# * `ipxe_boot_menu_url`
# * `ipxe_mkisofs_cmd`
#  (string value)
# from .xenserver.nova.conf.ipxe_network_name
{{ if not .xenserver.nova.conf.ipxe_network_name }}#{{ end }}ipxe_network_name = {{ .xenserver.nova.conf.ipxe_network_name | default "<None>" }}

#
# URL to the iPXE boot menu.
#
# An iPXE ISO is a specially crafted ISO which supports iPXE booting.
# This feature gives a means to roll your own image.
#
# By default this option is not set. Enable this option to
# boot an iPXE ISO.
#
# Related Options:
#
# * `ipxe_network_name`
# * `ipxe_mkisofs_cmd`
#  (string value)
# from .xenserver.nova.conf.ipxe_boot_menu_url
{{ if not .xenserver.nova.conf.ipxe_boot_menu_url }}#{{ end }}ipxe_boot_menu_url = {{ .xenserver.nova.conf.ipxe_boot_menu_url | default "<None>" }}

#
# Name and optionally path of the tool used for ISO image creation.
#
# An iPXE ISO is a specially crafted ISO which supports iPXE booting.
# This feature gives a means to roll your own image.
#
# Note: By default `mkisofs` is not present in the Dom0, so the
# package can either be manually added to Dom0 or include the
# `mkisofs` binary in the image itself.
#
# Related Options:
#
# * `ipxe_network_name`
# * `ipxe_boot_menu_url`
#  (string value)
# from .xenserver.nova.conf.ipxe_mkisofs_cmd
{{ if not .xenserver.nova.conf.ipxe_mkisofs_cmd }}#{{ end }}ipxe_mkisofs_cmd = {{ .xenserver.nova.conf.ipxe_mkisofs_cmd | default "mkisofs" }}

#
# URL for connection to XenServer/Xen Cloud Platform. A special value
# of unix://local can be used to connect to the local unix socket.
#
# Possible values:
#
# * Any string that represents a URL. The connection_url is
#   generally the management network IP address of the XenServer.
# * This option must be set if you chose the XenServer driver.
#  (string value)
# from .xenserver.nova.conf.connection_url
{{ if not .xenserver.nova.conf.connection_url }}#{{ end }}connection_url = {{ .xenserver.nova.conf.connection_url | default "<None>" }}

# Username for connection to XenServer/Xen Cloud Platform (string value)
# from .xenserver.nova.conf.connection_username
{{ if not .xenserver.nova.conf.connection_username }}#{{ end }}connection_username = {{ .xenserver.nova.conf.connection_username | default "root" }}

# Password for connection to XenServer/Xen Cloud Platform (string value)
# from .xenserver.nova.conf.connection_password
{{ if not .xenserver.nova.conf.connection_password }}#{{ end }}connection_password = {{ .xenserver.nova.conf.connection_password | default "<None>" }}

#
# The interval used for polling of coalescing vhds.
#
# This is the interval after which the task of coalesce VHD is
# performed, until it reaches the max attempts that is set by
# vhd_coalesce_max_attempts.
#
# Related options:
#
# * `vhd_coalesce_max_attempts`
#  (floating point value)
# Minimum value: 0
# from .xenserver.nova.conf.vhd_coalesce_poll_interval
{{ if not .xenserver.nova.conf.vhd_coalesce_poll_interval }}#{{ end }}vhd_coalesce_poll_interval = {{ .xenserver.nova.conf.vhd_coalesce_poll_interval | default "5.0" }}

#
# Ensure compute service is running on host XenAPI connects to.
# This option must be set to false if the 'independent_compute'
# option is set to true.
#
# Possible values:
#
# * Setting this option to true will make sure that compute service
#   is running on the same host that is specified by connection_url.
# * Setting this option to false, doesn't perform the check.
#
# Related options:
#
# * `independent_compute`
#  (boolean value)
# from .xenserver.nova.conf.check_host
{{ if not .xenserver.nova.conf.check_host }}#{{ end }}check_host = {{ .xenserver.nova.conf.check_host | default "true" }}

#
# Max number of times to poll for VHD to coalesce.
#
# This option determines the maximum number of attempts that can be
# made for coalescing the VHD before giving up.
#
# Related opitons:
#
# * `vhd_coalesce_poll_interval`
#  (integer value)
# Minimum value: 0
# from .xenserver.nova.conf.vhd_coalesce_max_attempts
{{ if not .xenserver.nova.conf.vhd_coalesce_max_attempts }}#{{ end }}vhd_coalesce_max_attempts = {{ .xenserver.nova.conf.vhd_coalesce_max_attempts | default "20" }}

#
# Base path to the storage repository on the XenServer host.
#  (string value)
# from .xenserver.nova.conf.sr_base_path
{{ if not .xenserver.nova.conf.sr_base_path }}#{{ end }}sr_base_path = {{ .xenserver.nova.conf.sr_base_path | default "/var/run/sr-mount" }}

#
# The iSCSI Target Host.
#
# This option represents the hostname or ip of the iSCSI Target.
# If the target host is not present in the connection information from
# the volume provider then the value from this option is taken.
#
# Possible values:
#
# * Any string that represents hostname/ip of Target.
#  (string value)
# from .xenserver.nova.conf.target_host
{{ if not .xenserver.nova.conf.target_host }}#{{ end }}target_host = {{ .xenserver.nova.conf.target_host | default "<None>" }}

#
# The iSCSI Target Port.
#
# This option represents the port of the iSCSI Target. If the
# target port is not present in the connection information from the
# volume provider then the value from this option is taken.
#  (string value)
# from .xenserver.nova.conf.target_port
{{ if not .xenserver.nova.conf.target_port }}#{{ end }}target_port = {{ .xenserver.nova.conf.target_port | default "3260" }}

#
# Used to enable the remapping of VBD dev.
# (Works around an issue in Ubuntu Maverick)
#  (boolean value)
# from .xenserver.nova.conf.remap_vbd_dev
{{ if not .xenserver.nova.conf.remap_vbd_dev }}#{{ end }}remap_vbd_dev = {{ .xenserver.nova.conf.remap_vbd_dev | default "false" }}

#
# Specify prefix to remap VBD dev to (ex. /dev/xvdb -> /dev/sdb).
#
# Related options:
#
# * If `remap_vbd_dev` is set to False this option has no impact.
#  (string value)
# from .xenserver.nova.conf.remap_vbd_dev_prefix
{{ if not .xenserver.nova.conf.remap_vbd_dev_prefix }}#{{ end }}remap_vbd_dev_prefix = {{ .xenserver.nova.conf.remap_vbd_dev_prefix | default "sd" }}

#
# Used to prevent attempts to attach VBDs locally, so Nova can
# be run in a VM on a different host.
#
# Related options:
#
# * ``CONF.flat_injected`` (Must be False)
# * ``CONF.xenserver.check_host`` (Must be False)
# * ``CONF.default_ephemeral_format`` (Must be unset or 'ext3')
# * Joining host aggregates (will error if attempted)
# * Swap disks for Windows VMs (will error if attempted)
# * Nova-based auto_configure_disk (will error if attempted)
#  (boolean value)
# from .xenserver.nova.conf.independent_compute
{{ if not .xenserver.nova.conf.independent_compute }}#{{ end }}independent_compute = {{ .xenserver.nova.conf.independent_compute | default "false" }}

# Number of seconds to wait for instance to go to running state (integer value)
# from .xenserver.nova.conf.running_timeout
{{ if not .xenserver.nova.conf.running_timeout }}#{{ end }}running_timeout = {{ .xenserver.nova.conf.running_timeout | default "60" }}

# The XenAPI VIF driver using XenServer Network APIs. (string value)
# from .xenserver.nova.conf.vif_driver
{{ if not .xenserver.nova.conf.vif_driver }}#{{ end }}vif_driver = {{ .xenserver.nova.conf.vif_driver | default "nova.virt.xenapi.vif.XenAPIBridgeDriver" }}

# Dom0 plugin driver used to handle image uploads. (string value)
# from .xenserver.nova.conf.image_upload_handler
{{ if not .xenserver.nova.conf.image_upload_handler }}#{{ end }}image_upload_handler = {{ .xenserver.nova.conf.image_upload_handler | default "nova.virt.xenapi.image.glance.GlanceStore" }}

#
# Number of seconds to wait for SR to settle if the VDI
# does not exist when first introduced.
#
# Some SRs, particularly iSCSI connections are slow to see the VDIs
# right after they got introduced. Setting this option to a
# time interval will make the SR to wait for that time period
# before raising VDI not found exception.
#  (integer value)
# Minimum value: 0
# from .xenserver.nova.conf.introduce_vdi_retry_wait
{{ if not .xenserver.nova.conf.introduce_vdi_retry_wait }}#{{ end }}introduce_vdi_retry_wait = {{ .xenserver.nova.conf.introduce_vdi_retry_wait | default "20" }}

#
# The name of the integration Bridge that is used with xenapi
# when connecting with Open vSwitch.
#
# Note: The value of this config option is dependent on the
# environment, therefore this configuration value must be set
# accordingly if you are using XenAPI.
#
# Possible options:
#
#    * Any string that represents a bridge name(default is xapi1).
#  (string value)
# from .xenserver.nova.conf.ovs_integration_bridge
{{ if not .xenserver.nova.conf.ovs_integration_bridge }}#{{ end }}ovs_integration_bridge = {{ .xenserver.nova.conf.ovs_integration_bridge | default "xapi1" }}

#
# When adding new host to a pool, this will append a --force flag to the
# command, forcing hosts to join a pool, even if they have different CPUs.
#
# Since XenServer version 5.6 it is possible to create a pool of hosts that have
# different CPU capabilities. To accommodate CPU differences, XenServer limited
# features it uses to determine CPU compatibility to only the ones that are
# exposed by CPU and support for CPU masking was added.
# Despite this effort to level differences between CPUs, it is still possible
# that adding new host will fail, thus option to force join was introduced.
#  (boolean value)
# from .xenserver.nova.conf.use_join_force
{{ if not .xenserver.nova.conf.use_join_force }}#{{ end }}use_join_force = {{ .xenserver.nova.conf.use_join_force | default "true" }}


[xvp]
#
# Configuration options for XVP.
#
# xvp (Xen VNC Proxy) is a proxy server providing password-protected VNC-based
# access to the consoles of virtual machines hosted on Citrix XenServer.

#
# From nova.conf
#

# XVP conf template (string value)
# Deprecated group/name - [DEFAULT]/console_xvp_conf_template
# from .xvp.nova.conf.console_xvp_conf_template
{{ if not .xvp.nova.conf.console_xvp_conf_template }}#{{ end }}console_xvp_conf_template = {{ .xvp.nova.conf.console_xvp_conf_template | default "$pybasedir/nova/console/xvp.conf.template" }}

# Generated XVP conf file (string value)
# Deprecated group/name - [DEFAULT]/console_xvp_conf
# from .xvp.nova.conf.console_xvp_conf
{{ if not .xvp.nova.conf.console_xvp_conf }}#{{ end }}console_xvp_conf = {{ .xvp.nova.conf.console_xvp_conf | default "/etc/xvp.conf" }}

# XVP master process pid file (string value)
# Deprecated group/name - [DEFAULT]/console_xvp_pid
# from .xvp.nova.conf.console_xvp_pid
{{ if not .xvp.nova.conf.console_xvp_pid }}#{{ end }}console_xvp_pid = {{ .xvp.nova.conf.console_xvp_pid | default "/var/run/xvp.pid" }}

# XVP log file (string value)
# Deprecated group/name - [DEFAULT]/console_xvp_log
# from .xvp.nova.conf.console_xvp_log
{{ if not .xvp.nova.conf.console_xvp_log }}#{{ end }}console_xvp_log = {{ .xvp.nova.conf.console_xvp_log | default "/var/log/xvp.log" }}

# Port for XVP to multiplex VNC connections on (port value)
# Minimum value: 0
# Maximum value: 65535
# Deprecated group/name - [DEFAULT]/console_xvp_multiplex_port
# from .xvp.nova.conf.console_xvp_multiplex_port
{{ if not .xvp.nova.conf.console_xvp_multiplex_port }}#{{ end }}console_xvp_multiplex_port = {{ .xvp.nova.conf.console_xvp_multiplex_port | default "5900" }}

{{- end -}}

