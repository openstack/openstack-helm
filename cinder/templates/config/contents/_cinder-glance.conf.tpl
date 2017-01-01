[DEFAULT]
glance_api_servers = "{{ .Values.glance.proto }}://{{ .Values.glance.host }}:{{ .Values.glance.port }}"
glance_api_version = {{ .Values.glance.version }}
