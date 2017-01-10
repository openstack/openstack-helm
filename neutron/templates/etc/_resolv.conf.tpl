search {{ .Release.Namespace }}.svc.{{ .Values.network.dns.kubernetes_domain }} svc.{{ .Values.network.dns.kubernetes_domain }} {{ .Values.network.dns.kubernetes_domain }}
{{- range .Values.network.dns.servers }}
nameserver {{ . | title }}
{{- end }}
options ndots:5
