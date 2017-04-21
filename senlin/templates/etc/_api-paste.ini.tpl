# senlin-api pipeline
[pipeline:senlin-api]
pipeline = request_id faultwrap ssl versionnegotiation webhook authtoken context trust apiv1app

[app:apiv1app]
paste.app_factory = senlin.api.common.wsgi:app_factory
senlin.app_factory = senlin.api.openstack.v1.router:API

# Middleware to set x-openstack-request-id in http response header
[filter:request_id]
paste.filter_factory = oslo_middleware.request_id:RequestId.factory

[filter:faultwrap]
paste.filter_factory = senlin.api.common.wsgi:filter_factory
senlin.filter_factory = senlin.api.middleware:fault_filter

[filter:context]
paste.filter_factory = senlin.api.common.wsgi:filter_factory
senlin.filter_factory = senlin.api.middleware:context_filter

[filter:ssl]
paste.filter_factory = oslo_middleware.ssl:SSLMiddleware.factory

[filter:versionnegotiation]
paste.filter_factory = senlin.api.common.wsgi:filter_factory
senlin.filter_factory = senlin.api.middleware:version_filter

[filter:trust]
paste.filter_factory = senlin.api.common.wsgi:filter_factory
senlin.filter_factory = senlin.api.middleware:trust_filter

[filter:webhook]
paste.filter_factory = senlin.api.common.wsgi:filter_factory
senlin.filter_factory = senlin.api.middleware:webhook_filter

# Auth middleware that validates token against keystone
[filter:authtoken]
paste.filter_factory = keystonemiddleware.auth_token:filter_factory
