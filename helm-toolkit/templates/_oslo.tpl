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

#-----------------------------------------------
# oslo settings we will dynamically manufacture
#-----------------------------------------------

{{- define "helm-toolkit.oslo_values_setup" -}}

{{ $obj := index . 0 }}
{{ $root := index . 1 }}

# generate database uri and set $conf.conf.oslo.db.connection
{{- if empty $obj.database.oslo.db.connection -}}
{{- tuple "oslo_db" "internal" "user" "mysql" $root | include "helm-toolkit.authenticated_endpoint_uri_lookup"| set $obj.database.oslo.db "connection" -}}
{{- end -}}

# generate amqp transport uri and set $conf.endpoints.messaging
{{- if empty $obj.default.oslo.messaging.transport_url -}}
{{- tuple "oslo_messaging" "internal" "user" "amqp" $root | include "helm-toolkit.authenticated_endpoint_uri_lookup" | set $obj.default.oslo.messaging "transport_url" -}}
{{- end -}}

# generate memcache host:port and set $conf.endpoints.memcache
{{- if empty $obj.cache.oslo.cache -}}
{{- tuple "oslo_cache" "internal" "memcache" $root | include "helm-toolkit.hostname_endpoint_uri_lookup" | set $obj.cache.oslo.cache "memcache_servers" -}}
{{- end -}}

{{- end -}}
