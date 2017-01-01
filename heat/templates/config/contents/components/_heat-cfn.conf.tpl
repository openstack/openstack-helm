[heat_api_cfn]
bind_port = {{ .Values.service.cfn.port }}
bind_host = 0.0.0.0
workers = {{ .Values.resources.cfn.workers }}
