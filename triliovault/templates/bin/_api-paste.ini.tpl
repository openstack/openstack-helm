  
[composite:osapi_workloads]
use = call:workloadmgr.api:root_app_factory
/ = apiversions
/v1 = openstack_workloads_api_v1
    
[composite:openstack_workloads_api_v1]
use = call:workloadmgr.api.middleware.auth:pipeline_factory
noauth = faultwrap sizelimit noauth apiv1
keystone = faultwrap sizelimit authtoken keystonecontext apiv1
keystone_nolimit = faultwrap sizelimit authtoken keystonecontext apiv1

[filter:faultwrap]
paste.filter_factory = workloadmgr.api.middleware.fault:FaultWrapper.factory

[filter:noauth]
paste.filter_factory = workloadmgr.api.middleware.auth:NoAuthMiddleware.factory

[filter:sizelimit]
paste.filter_factory = oslo_middleware.sizelimit:RequestBodySizeLimiter.factory

[app:apiv1]
paste.app_factory = workloadmgr.api.v1.router:APIRouter.factory

[pipeline:apiversions]
pipeline = faultwrap osworkloadsversionapp

[app:osworkloadsversionapp]
paste.app_factory = workloadmgr.api.versions:Versions.factory

[filter:keystonecontext]
paste.filter_factory = workloadmgr.api.middleware.auth:WorkloadMgrKeystoneContext.factory

[filter:authtoken]
paste.filter_factory =  keystonemiddleware.auth_token:filter_factory
auth_host = {{ tuple "identity" .Values.conf.triliovault.interface . | include "helm-toolkit.endpoints.endpoint_host_lookup" }}
auth_port = {{ tuple "identity" .Values.conf.triliovault.interface "api" . | include "helm-toolkit.endpoints.endpoint_port_lookup" }}
auth_protocol = {{ tuple "identity" .Values.conf.triliovault.interface "api" . | include "helm-toolkit.endpoints.keystone_endpoint_scheme_lookup" }}
admin_tenant_name = {{ .Values.endpoints.identity.auth.triliovault_wlm.project_name }}
project_name = {{ .Values.endpoints.identity.auth.triliovault_wlm.project_name }}
admin_user = {{ .Values.endpoints.identity.auth.triliovault_wlm.username }}
admin_password = {{ .Values.endpoints.identity.auth.triliovault_wlm.password }}
signing_dir = /var/cache/workloadmgr
insecure = True
interface = {{ .Values.conf.triliovault.interface }}
