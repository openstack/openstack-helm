{{/*
Copyright 2017 The Openstack-Helm Authors.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/}}

# Keystone PasteDeploy configuration file.

[filter:debug]
use = egg:oslo.middleware#debug

[filter:request_id]
use = egg:oslo.middleware#request_id

[filter:build_auth_context]
use = egg:keystone#build_auth_context

[filter:token_auth]
use = egg:keystone#token_auth

[filter:json_body]
use = egg:keystone#json_body

[filter:cors]
use = egg:oslo.middleware#cors
oslo_config_project = keystone

[filter:http_proxy_to_wsgi]
use = egg:oslo.middleware#http_proxy_to_wsgi

[filter:ec2_extension]
use = egg:keystone#ec2_extension

[filter:ec2_extension_v3]
use = egg:keystone#ec2_extension_v3

[filter:s3_extension]
use = egg:keystone#s3_extension

[filter:url_normalize]
use = egg:keystone#url_normalize

[filter:sizelimit]
use = egg:oslo.middleware#sizelimit

[filter:osprofiler]
use = egg:osprofiler#osprofiler

[app:public_service]
use = egg:keystone#public_service

[app:service_v3]
use = egg:keystone#service_v3

[app:admin_service]
use = egg:keystone#admin_service

[pipeline:public_api]
# The last item in this pipeline must be public_service or an equivalent
# application. It cannot be a filter.
pipeline = cors sizelimit http_proxy_to_wsgi osprofiler url_normalize request_id build_auth_context token_auth json_body ec2_extension public_service

[pipeline:admin_api]
# The last item in this pipeline must be admin_service or an equivalent
# application. It cannot be a filter.
pipeline = cors sizelimit http_proxy_to_wsgi osprofiler url_normalize request_id build_auth_context token_auth json_body ec2_extension s3_extension admin_service

[pipeline:api_v3]
# The last item in this pipeline must be service_v3 or an equivalent
# application. It cannot be a filter.
pipeline = cors sizelimit http_proxy_to_wsgi osprofiler url_normalize request_id build_auth_context token_auth json_body ec2_extension_v3 s3_extension service_v3

[app:public_version_service]
use = egg:keystone#public_version_service

[app:admin_version_service]
use = egg:keystone#admin_version_service

[pipeline:public_version_api]
pipeline = cors sizelimit osprofiler url_normalize public_version_service

[pipeline:admin_version_api]
pipeline = cors sizelimit osprofiler url_normalize admin_version_service

[composite:main]
use = egg:Paste#urlmap
/v2.0 = public_api
/v3 = api_v3
/ = public_version_api

[composite:admin]
use = egg:Paste#urlmap
/v2.0 = admin_api
/v3 = api_v3
/ = admin_version_api