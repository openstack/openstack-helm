[DEFAULT]
heat_metadata_server_url = {{ .Values.service.cfn.proto }}://{{ .Values.service.cfn.name }}:{{ .Values.service.cfn.port }}
heat_waitcondition_server_url = {{ .Values.service.cfn.proto }}://{{ .Values.service.cfn.name }}:{{ .Values.service.cfn.port }}/v1/waitcondition
heat_watch_server_url = {{ .Values.service.cloudwatch.proto }}://{{ .Values.service.cloudwatch.name }}:{{ .Values.service.cloudwatch.port }}
