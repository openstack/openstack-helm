[DEFAULT]
debug = {{ .Values.metadata_agent.default.debug }}

# Neutron credentials for API access
auth_plugin = password
auth_url = {{ include "endpoint_keystone_admin" . }}
auth_uri = {{ include "endpoint_keystone_internal" . }}
auth_region = {{ .Values.keystone.neutron_region_name }}
admin_tenant_name = service
project_domain_id = default
user_domain_id = default
project_name = service
username = {{ .Values.keystone.admin_user }}
password = {{ .Values.keystone.admin_password }}
endpoint_type = adminURL

# Nova metadata service IP and port
nova_metadata_ip = {{ include "nova_metadata_host" . }}
nova_metadata_port = {{ .Values.network.port.metadata }}
nova_metadata_protocol = http

# Metadata proxy shared secret
metadata_proxy_shared_secret = {{ .Values.neutron.metadata_secret }}

metadata_port = {{ .Values.network.port.metadata }}

# Workers and backlog requests
metadata_workers = {{ .Values.metadata.workers }}

# Caching
cache_url = memory://?default_ttl=5