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

#-----------------------------------------
# endpoints
#-----------------------------------------

# this function returns the endpoint uri for a service, it takes an tuple
# input in the form: service-type, endpoint-class, port-name. eg:
# { tuple "orchestration" "public" "api" . | include "helm-toolkit.keystone_endpoint_uri_lookup" }
# will return the appropriate URI. Once merged this should phase out the above.

{{- define "helm-toolkit.keystone_endpoint_uri_lookup" -}}
{{- $type := index . 0 -}}
{{- $endpoint := index . 1 -}}
{{- $port := index . 2 -}}
{{- $context := index . 3 -}}
{{- $endpointMap := index $context.Values.endpoints $type }}
{{- $fqdn := $context.Release.Namespace -}}
{{- if $context.Values.endpoints.fqdn -}}
{{- $fqdn := $context.Values.endpoints.fqdn -}}
{{- end -}}
{{- with $endpointMap -}}
{{- $endpointScheme := .scheme }}
{{- $endpointHost := index .hosts $endpoint | default .hosts.default}}
{{- $endpointPort := index .port $port }}
{{- $endpointPath := .path | default "" }}
{{- printf "%s://%s.%s:%1.f%s" $endpointScheme $endpointHost $fqdn $endpointPort $endpointPath -}}
{{- end -}}
{{- end -}}

# this function helps resolve database style endpoints, which really follow the same
# pattern as above, except they have a username and password component
# 
# presuming that .Values contains an endpoint: definition for 'neutron-db' with the
# appropriate attributes, a call such as:
# 
# { tuple "neutron-db" "internal" "userClass" "portName" . | include "helm-toolkit.authenticated_endpoint_uri_lookup" }
#
# where portName is optional if a default port has been defined in .Values
#
# returns: mysql+pymysql://username:password@internal_host:3306/dbname

{{- define "helm-toolkit.authenticated_endpoint_uri_lookup" -}}
{{- $type := index . 0 -}}
{{- $endpoint := index . 1 -}}
{{- $userclass := index . 2 -}}
{{- $port := index . 3 -}}
{{- $context := index . 4 -}}
{{- $endpointMap := index $context.Values.endpoints $type }}
{{- $userMap := index $endpointMap.auth $userclass }}
{{- $fqdn := $context.Release.Namespace -}}
{{- if $context.Values.endpoints.fqdn -}}
{{- $fqdn := $context.Values.endpoints.fqdn -}}
{{- end -}}
{{- with $endpointMap -}}
{{- $endpointScheme := .scheme }}
{{- $endpointUser := index $userMap "username" }}
{{- $endpointPass := index $userMap "password" }}
{{- $endpointHost := index .hosts $endpoint | default .hosts.default}}
{{- $endpointPort := index .port $port | default .port.default }}
{{- $endpointPath := .path | default "" }}
{{- printf "%s://%s:%s@%s.%s:%1.f%s" $endpointScheme $endpointUser $endpointPass $endpointHost $fqdn $endpointPort $endpointPath -}}
{{- end -}}
{{- end -}}

# this function returns hostnames from endpoint definitions for use cases
# where the uri style return is not appropriate, and only the hostname 
# portion is used or relevant in the template
#
# { tuple "memcache" "internal" "portName" . | include "helm-toolkit.hostname_endpoint_uri_lookup" }
#
# returns: internal_host:port
#
# output that requires the port aspect striped should simply split the output based on ':'

{{- define "helm-toolkit.hostname_endpoint_uri_lookup" -}}
{{- $type := index . 0 -}}
{{- $endpoint := index . 1 -}}
{{- $port := index . 2 -}}
{{- $context := index . 3 -}}
{{- $endpointMap := index $context.Values.endpoints $type }}
{{- $fqdn := $context.Release.Namespace -}}
{{- if $context.Values.endpoints.fqdn -}}
{{- $fqdn := $context.Values.endpoints.fqdn -}}
{{- end -}}
{{- with $endpointMap -}}
{{- $endpointScheme := .scheme }}
{{- $endpointHost := index .hosts $endpoint | default .hosts.default}}
{{- $endpointPort := index .port $port | default .port.default }}
{{- printf "%s.%s:%1.f" $endpointHost $fqdn $endpointPort -}}
{{- end -}}
{{- end -}}

#-------------------------------
# endpoint name lookup
#-------------------------------

# this function is used in endpoint management templates
# it returns the service type for an openstack service eg:
# { tuple orchestration . | include "ks_endpoint_type" }
# will return "heat"

{{- define "helm-toolkit.keystone_endpoint_name_lookup" -}}
{{- $type := index . 0 -}}
{{- $context := index . 1 -}}
{{- $endpointMap := index $context.Values.endpoints $type }}
{{- $endpointName := index $endpointMap "name" }}
{{- $endpointName | quote -}}
{{- end -}}

#-------------------------------
# kolla helpers
#-------------------------------
{{ define "helm-toolkit.keystone_auth" }}{'auth_url':'{{ tuple "identity" "internal" "api" . | include "helm-toolkit.keystone_endpoint_uri_lookup" }}', 'username':'{{ .Values.keystone.admin_user }}','password':'{{ .Values.keystone.admin_password }}','project_name':'{{ .Values.keystone.admin_project_name }}','domain_name':'default'}{{end}}
