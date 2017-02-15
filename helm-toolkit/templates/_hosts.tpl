# fqdn
{{- define "helm-toolkit.region"}}cluster{{- end}}
{{- define "helm-toolkit.tld"}}local{{- end}}

{{- define "helm-toolkit.fqdn" -}}
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
{{- define "helm-toolkit.rabbitmq_host"}}memcached.{{.Release.Namespace}}.svc.{{ include "helm-toolkit.region" . }}.{{ include "helm-toolkit.tld" . }}{{- end}}
{{- define "helm-toolkit.mariadb_host"}}mariadb.{{.Release.Namespace}}.svc.{{ include "helm-toolkit.region" . }}.{{ include "helm-toolkit.tld" . }}{{- end}}

# nova defaults
{{- define "helm-toolkit.nova_metadata_host"}}nova-api.{{ include "helm-toolkit.fqdn" . }}{{- end}}
