#-----------------------------------------
# endpoints
#-----------------------------------------

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
# kolla helpers
#-------------------------------
{{ define "keystone_auth" }}{'auth_url':'{{ include "endpoint_keystone_internal" . }}', 'username':'{{ .Values.keystone.admin_user }}','password':'{{ .Values.keystone.admin_password }}','project_name':'{{ .Values.keystone.admin_project_name }}','domain_name':'default'}{{end}}

