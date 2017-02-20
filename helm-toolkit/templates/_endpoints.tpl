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

# this should be a generic function leveraging a tuple
# for input, e.g. { endpoint keystone internal . }
# however, constructing this appears to be a
# herculean effort in gotpl

{{- define "helm-toolkit.endpoint_keystone_internal" -}}
{{- $fqdn := .Release.Namespace -}}
{{- if .Values.endpoints.fqdn -}}
{{- $fqdn := .Values.endpoints.fqdn -}}
{{- end -}}
{{- with .Values.endpoints.keystone -}}
	{{.scheme}}://{{.hosts.internal | default .hosts.default}}.{{ $fqdn }}:{{.port.public}}{{.path}}
{{- end -}}
{{- end -}}

{{- define "helm-toolkit.endpoint_keystone_admin" -}}
{{- $fqdn := .Release.Namespace -}}
{{- if .Values.endpoints.fqdn -}}
{{- $fqdn := .Values.endpoints.fqdn -}}
{{- end -}}
{{- with .Values.endpoints.keystone -}}
	{{.scheme}}://{{.hosts.internal | default .hosts.default}}.{{ $fqdn }}:{{.port.admin}}{{.path}}
{{- end -}}
{{- end -}}

{{- define "helm-toolkit.endpoint_nova_api_internal" -}}
{{- $fqdn := .Release.Namespace -}}
{{- if .Values.endpoints.fqdn -}}
{{- $fqdn := .Values.endpoints.fqdn -}}
{{- end -}}
{{- with .Values.endpoints.nova -}}
	{{.scheme}}://{{.hosts.internal | default .hosts.default}}.{{ $fqdn }}:{{.port.api}}{{.path}}
{{- end -}}
{{- end -}}

{{- define "helm-toolkit.endpoint_nova_metadata_internal" -}}
{{- $fqdn := .Release.Namespace -}}
{{- if .Values.endpoints.fqdn -}}
{{- $fqdn := .Values.endpoints.fqdn -}}
{{- end -}}
{{- with .Values.endpoints.nova -}}
	{{.scheme}}://{{.hosts.internal | default .hosts.default}}.{{ $fqdn }}:{{.port.metadata}}{{.path}}
{{- end -}}
{{- end -}}

{{- define "helm-toolkit.endpoint_nova_novncproxy_internal" -}}
{{- $fqdn := .Release.Namespace -}}
{{- if .Values.endpoints.fqdn -}}
{{- $fqdn := .Values.endpoints.fqdn -}}
{{- end -}}
{{- with .Values.endpoints.nova -}}
	{{.scheme}}://{{.hosts.internal | default .hosts.default}}.{{ $fqdn }}:{{.port.novncproxy}}{{.path}}
{{- end -}}
{{- end -}}

{{- define "helm-toolkit.endpoint_glance_api_internal" -}}
{{- $fqdn := .Release.Namespace -}}
{{- if .Values.endpoints.fqdn -}}
{{- $fqdn := .Values.endpoints.fqdn -}}
{{- end -}}
{{- with .Values.endpoints.glance -}}
	{{.scheme}}://{{.hosts.internal | default .hosts.default}}.{{ $fqdn }}:{{.port.api}}{{.path}}
{{- end -}}
{{- end -}}

{{- define "helm-toolkit.endpoint_glance_registry_internal" -}}
{{- $fqdn := .Release.Namespace -}}
{{- if .Values.endpoints.fqdn -}}
{{- $fqdn := .Values.endpoints.fqdn -}}
{{- end -}}
{{- with .Values.endpoints.glance -}}
	{{.scheme}}://{{.hosts.internal | default .hosts.default}}.{{ $fqdn }}:{{.port.registry}}{{.path}}
{{- end -}}
{{- end -}}

{{- define "helm-toolkit.endpoint_neutron_api_internal" -}}
{{- $fqdn := .Release.Namespace -}}
{{- if .Values.endpoints.fqdn -}}
{{- $fqdn := .Values.endpoints.fqdn -}}
{{- end -}}
{{- with .Values.endpoints.neutron -}}
	{{.scheme}}://{{.hosts.internal | default .hosts.default}}.{{ $fqdn }}:{{.port.api}}{{.path}}
{{- end -}}
{{- end -}}

# this function returns the endpoint uri for a service, it takes an tuple
# input in the form: service-name, endpoint-class, port-name. eg:
# { tuple "heat" "public" "api" . | include "helm-toolkit.endpoint_uri_lookup" }
# will return the appropriate URI. Once merged this should phase out the above.

{{- define "helm-toolkit.endpoint_uri_lookup" -}}
{{- $name := index . 0 -}}
{{- $endpoint := index . 1 -}}
{{- $port := index . 2 -}}
{{- $context := index . 3 -}}
{{- $nameNorm := $name | replace "-" "_" }}
{{- $endpointMap := index $context.Values.endpoints $nameNorm }}
{{- $fqdn := $context.Release.Namespace -}}
{{- if $context.Values.endpoints.fqdn -}}
{{- $fqdn := $context.Values.endpoints.fqdn -}}
{{- end -}}
{{- with $endpointMap -}}
{{- $endpointScheme := .scheme }}
{{- $endpointHost := index .hosts $endpoint | default .hosts.default}}
{{- $endpointPort := index .port $port }}
{{- $endpointPath := .path }}
{{- printf "%s://%s.%s:%1.f%s" $endpointScheme $endpointHost $fqdn $endpointPort $endpointPath  | quote -}}
{{- end -}}
{{- end -}}


#-------------------------------
# endpoint type lookup
#-------------------------------

# this function is used in endpoint management templates
# it returns the service type for an openstack service eg:
# { tuple heat . | include "ks_endpoint_type" }
# will return "orchestration"

{{- define "helm-toolkit.endpoint_type_lookup" -}}
{{- $name := index . 0 -}}
{{- $context := index . 1 -}}
{{- $nameNorm := $name | replace "-" "_" }}
{{- $endpointMap := index $context.Values.endpoints $nameNorm }}
{{- $endpointType := index $endpointMap "type" }}
{{- $endpointType | quote -}}
{{- end -}}

#-------------------------------
# kolla helpers
#-------------------------------
{{ define "helm-toolkit.keystone_auth" }}{'auth_url':'{{ include "helm-toolkit.endpoint_keystone_internal" . }}', 'username':'{{ .Values.keystone.admin_user }}','password':'{{ .Values.keystone.admin_password }}','project_name':'{{ .Values.keystone.admin_project_name }}','domain_name':'default'}{{end}}
