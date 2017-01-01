[DEFAULT]
enable_v1_api = false
volume_name_template = %s

osapi_volume_workers = {{ .Values.api.workers }}
osapi_volume_listen = 0.0.0.0
osapi_volume_listen_port = {{ .Values.service.api.port }}

api_paste_config = /etc/cinder/api-paste.ini

[oslo_concurrency]
lock_path = /var/lib/cinder/tmp
