[heat_api]
bind_port = {{ .Values.service.api.port }}
bind_host = 0.0.0.0
workers = {{ .Values.resources.api.workers }}
