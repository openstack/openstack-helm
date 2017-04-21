[pipeline:main]
pipeline = cors healthcheck request_id authtoken api_v1

[app:api_v1]
paste.app_factory = magnum.api.app:app_factory

[filter:authtoken]
acl_public_routes = /, /v1
paste.filter_factory = magnum.api.middleware.auth_token:AuthTokenMiddleware.factory

[filter:request_id]
paste.filter_factory = oslo_middleware:RequestId.factory

[filter:cors]
paste.filter_factory =  oslo_middleware.cors:filter_factory
oslo_config_project = magnum

[filter:healthcheck]
paste.filter_factory = oslo_middleware:Healthcheck.factory
backends = disable_by_file
disable_by_file_path = /etc/magnum/healthcheck_disable
