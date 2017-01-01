[keystone_authtoken]
auth_version = v3
auth_uri = {{ .Values.keystone.auth_uri }}
auth_url = {{ .Values.keystone.auth_url }}
auth_type = password
region_name = {{ .Values.keystone.heat_region_name }}
project_domain_name = {{ .Values.keystone.heat_project_domain }}
project_name = {{ .Values.keystone.heat_project_name }}
user_domain_name = {{ .Values.keystone.heat_user_domain }}
username = {{ .Values.keystone.heat_user }}
password = {{ .Values.keystone.heat_password }}

signing_dir = "/var/cache/heat"

memcached_servers = "{{ .Values.memcached.host }}:{{ .Values.memcached.port }}"
