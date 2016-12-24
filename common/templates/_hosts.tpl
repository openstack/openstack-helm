# fqdn
{{- define "region"}}cluster{{- end}}
{{- define "tld"}}local{{- end}}

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
