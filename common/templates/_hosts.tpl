# fqdn
{{- define "region"}}cluster{{- end}}
{{- define "tld"}}local{{- end}}

{{- define "fqdn" -}}
{{- $fqdn := .Release.Namespace -}}
{{- if .Values.endpoints.fqdn -}}
{{- $fqdn := .Values.endpoints.fqdn -}}
{{- end -}}
{{- $fqdn -}}
{{- end -}}

#-----------------------------------------
# hosts
#-----------------------------------------

# infrastructure services
{{- define "rabbitmq_host"}}rabbitmq.{{.Release.Namespace}}.svc.{{ include "region" . }}.{{ include "tld" . }}{{- end}}
{{- define "memcached_host"}}memcached.{{.Release.Namespace}}.svc.{{ include "region" . }}.{{ include "tld" . }}{{- end}}
{{- define "mariadb_host"}}mariadb.{{.Release.Namespace}}.svc.{{ include "region" . }}.{{ include "tld" . }}{{- end}}

# keystone defaults
{{- define "keystone_db_host"}}{{ include "mariadb_host" . }}{{- end}}
{{- define "keystone_api_endpoint_host_admin"}}keystone-api.{{.Release.Namespace}}.svc.{{ include "region" . }}.{{ include "tld" . }}{{- end}}
{{- define "keystone_api_endpoint_host_internal"}}keystone-api.{{.Release.Namespace}}.svc.{{ include "region" . }}.{{ include "tld" . }}{{- end}}
{{- define "keystone_api_endpoint_host_public"}}keystone-api.{{ include "region" . }}.{{ include "tld" . }}{{- end}}
{{- define "keystone_api_endpoint_host_admin_ext"}}keystone-api.{{ include "region" . }}.{{ include "tld" . }}{{- end}}

# glance defaults
{{- define "glance_registry_host"}}glance-registry.{{ include "fqdn" . }}{{- end}}

# nova defaults
{{- define "nova_metadata_host"}}nova-api.{{ include "fqdn" . }}{{- end}}

# neutron defaults
{{- define "neutron_db_host"}}{{ include "mariadb_host" . }}{{- end}}
{{- define "neutron_rabbit_host"}}{{- include "rabbitmq_host" .}}{{- end}}

