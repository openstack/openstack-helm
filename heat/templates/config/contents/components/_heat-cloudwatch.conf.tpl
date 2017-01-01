[heat_api_cloudwatch]
bind_port = {{ .Values.service.cloudwatch.port }}
bind_host = 0.0.0.0
workers = {{ .Values.resources.cloudwatch.workers }}
