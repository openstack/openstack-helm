  
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
admin_tenant_name = service
admin_user = triliovault
admin_password = password
admin_user_domain_id = <TODO>
signing_dir = /var/cache/workloadmgr
insecure = True
auth_host = {{ tuple "identity" .Values.conf.triliovault.interface . | include "helm-toolkit.endpoints.endpoint_host_lookup" }}
