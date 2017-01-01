[DEFAULT]
trusts_delegated_roles = "Member"
deferred_auth_method = "trusts"

[trustee]
auth_type = "password"
auth_section = "trustee_keystone"

[trustee_keystone]

auth_version = v3
auth_uri = {{ .Values.keystone.auth_uri }}
auth_url = {{ .Values.keystone.auth_url }}
auth_type = password
region_name = {{ .Values.keystone.heat_trustee_region_name }}
user_domain_name = {{ .Values.keystone.heat_trustee_user_domain }}
username = {{ .Values.keystone.heat_trustee_user }}
password = {{ .Values.keystone.heat_trustee_password }}

signing_dir = "/var/cache/heat"

memcached_servers = "{{ .Values.memcached.host }}:{{ .Values.memcached.port }}"
