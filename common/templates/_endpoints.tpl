#-----------------------------------------
# endpoints
#-----------------------------------------

# this function returns the endpoint uri for a service, it takes an tuple
# input in ther form: service-name, endpoint-class, port-name. eg:
# { tuple "heat" "public" "api" . | include "endpoint_addr_lookup" }
# will return the appropriate URI

{{- define "endpoint_addr_lookup" -}}
{{- $name := index . 0 -}}
{{- $endpoint := index . 1 -}}
{{- $port := index . 2 -}}
{{- $context := index . 3 -}}
{{- $nameNorm := $name | replace "-" "_" }}
{{- $endpointMap := index $context.Values.endpoints $nameNorm }}
{{- $endpointScheme := index $endpointMap "scheme" }}
{{- $endpointPath := index $endpointMap "path" }}
{{- $fqdn := $context.Release.Namespace -}}
{{- if $context.Values.endpoints.fqdn -}}
{{- $fqdn := $context.Values.endpoints.fqdn -}}
{{- end -}}
{{- with $endpointMap -}}
{{- $endpointHost := index .hosts $endpoint | default .hosts.default}}
{{- $endpointPort := index .port $port }}
{{- printf "%s://%s.%s:%1.f%s" $endpointScheme $endpointHost $fqdn $endpointPort $endpointPath  | quote -}}
{{- end -}}
{{- end -}}


# this should be a generic function leveraging a tuple
# for input, e.g. { endpoint keystone internal . }
# however, constructing this appears to be a
# herculean effort in gotpl

{{- define "endpoint_keystone_internal" -}}
{{- $fqdn := .Release.Namespace -}}
{{- if .Values.endpoints.fqdn -}}
{{- $fqdn := .Values.endpoints.fqdn -}}
{{- end -}}
{{- with .Values.endpoints.keystone -}}
	{{.scheme}}://{{.hosts.internal | default .hosts.default}}.{{ $fqdn }}:{{.port.public}}{{.path}}
{{- end -}}
{{- end -}}

{{- define "endpoint_keystone_admin" -}}
{{- $fqdn := .Release.Namespace -}}
{{- if .Values.endpoints.fqdn -}}
{{- $fqdn := .Values.endpoints.fqdn -}}
{{- end -}}
{{- with .Values.endpoints.keystone -}}
	{{.scheme}}://{{.hosts.internal | default .hosts.default}}.{{ $fqdn }}:{{.port.admin}}{{.path}}
{{- end -}}
{{- end -}}

{{- define "endpoint_nova_api_internal" -}}
{{- $fqdn := .Release.Namespace -}}
{{- if .Values.endpoints.fqdn -}}
{{- $fqdn := .Values.endpoints.fqdn -}}
{{- end -}}
{{- with .Values.endpoints.nova -}}
	{{.scheme}}://{{.hosts.internal | default .hosts.default}}.{{ $fqdn }}:{{.port.api}}{{.path}}
{{- end -}}
{{- end -}}

{{- define "endpoint_nova_metadata_internal" -}}
{{- $fqdn := .Release.Namespace -}}
{{- if .Values.endpoints.fqdn -}}
{{- $fqdn := .Values.endpoints.fqdn -}}
{{- end -}}
{{- with .Values.endpoints.nova -}}
	{{.scheme}}://{{.hosts.internal | default .hosts.default}}.{{ $fqdn }}:{{.port.metadata}}{{.path}}
{{- end -}}
{{- end -}}

{{- define "endpoint_nova_novncproxy_internal" -}}
{{- $fqdn := .Release.Namespace -}}
{{- if .Values.endpoints.fqdn -}}
{{- $fqdn := .Values.endpoints.fqdn -}}
{{- end -}}
{{- with .Values.endpoints.nova -}}
	{{.scheme}}://{{.hosts.internal | default .hosts.default}}.{{ $fqdn }}:{{.port.novncproxy}}{{.path}}
{{- end -}}
{{- end -}}

{{- define "endpoint_glance_api_internal" -}}
{{- $fqdn := .Release.Namespace -}}
{{- if .Values.endpoints.fqdn -}}
{{- $fqdn := .Values.endpoints.fqdn -}}
{{- end -}}
{{- with .Values.endpoints.glance -}}
	{{.scheme}}://{{.hosts.internal | default .hosts.default}}.{{ $fqdn }}:{{.port.api}}{{.path}}
{{- end -}}
{{- end -}}

{{- define "endpoint_glance_registry_internal" -}}
{{- $fqdn := .Release.Namespace -}}
{{- if .Values.endpoints.fqdn -}}
{{- $fqdn := .Values.endpoints.fqdn -}}
{{- end -}}
{{- with .Values.endpoints.glance -}}
	{{.scheme}}://{{.hosts.internal | default .hosts.default}}.{{ $fqdn }}:{{.port.registry}}{{.path}}
{{- end -}}
{{- end -}}

{{- define "endpoint_neutron_api_internal" -}}
{{- $fqdn := .Release.Namespace -}}
{{- if .Values.endpoints.fqdn -}}
{{- $fqdn := .Values.endpoints.fqdn -}}
{{- end -}}
{{- with .Values.endpoints.neutron -}}
	{{.scheme}}://{{.hosts.internal | default .hosts.default}}.{{ $fqdn }}:{{.port.api}}{{.path}}
{{- end -}}
{{- end -}}


#-------------------------------
# endpoint type lookup
#-------------------------------

# this function is used in endpoint management templates
# it returns the service type for an openstack service eg:
# { tuple heat . | include "ks_endpoint_type" }
# will return "orchestration"

{{- define "endpoint_type_lookup" -}}
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
{{ define "keystone_auth" }}{'auth_url':'{{ include "endpoint_keystone_internal" . }}', 'username':'{{ .Values.keystone.admin_user }}','password':'{{ .Values.keystone.admin_password }}','project_name':'{{ .Values.keystone.admin_project_name }}','domain_name':'default'}{{end}}
