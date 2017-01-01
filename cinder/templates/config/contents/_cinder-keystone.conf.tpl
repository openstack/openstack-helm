[DEFAULT]
auth_strategy = keystone
os_region_name = {{ .Values.keystone.cinder_region_name }}

[keystone_authtoken]
auth_uri = {{ .Values.keystone.auth_uri }}
auth_url = {{ .Values.keystone.auth_url }}
auth_type = password
project_domain_name = {{ .Values.keystone.cinder_project_domain }}
user_domain_name = {{ .Values.keystone.cinder_user_domain }}
project_name = {{ .Values.keystone.cinder_project_name }}
username = {{ .Values.keystone.cinder_user }}
password = {{ .Values.keystone.cinder_password }}
