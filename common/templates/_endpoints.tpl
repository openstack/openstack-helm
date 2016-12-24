#-----------------------------------------
# endpoints
#-----------------------------------------
{{- define "endpoint_keystone_internal" -}}
{{- with .Values.endpoints.keystone -}}
	{{.scheme}}://{{.hosts.internal | default .hosts.default}}:{{.port.public}}{{.path}}
{{- end -}}
{{- end -}}

