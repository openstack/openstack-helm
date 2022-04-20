[filter:authtoken]
paste.filter_factory =  keystonemiddleware.auth_token:filter_factory
admin_tenant_name = service
admin_user = triliovault
admin_password = password
admin_user_domain_id = <TODO>
signing_dir = /var/cache/workloadmgr
insecure = True
auth_host: {{ tuple "identity" .Values.conf.triliovault.interface . | include "helm-toolkit.endpoints.endpoint_host_lookup" }}
