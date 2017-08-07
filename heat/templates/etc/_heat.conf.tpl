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

{{ include "heat.conf.heat_values_skeleton" .Values.conf.heat | trunc 0 }}
{{ include "heat.conf.heat" .Values.conf.heat }}


{{- define "heat.conf.heat_values_skeleton" -}}

{{- if not .default -}}{{- set . "default" dict -}}{{- end -}}
{{- if not .default.heat -}}{{- set .default "heat" dict -}}{{- end -}}
{{- if not .default.heat.api -}}{{- set .default.heat "api" dict -}}{{- end -}}
{{- if not .default.heat.api.middleware -}}{{- set .default.heat.api "middleware" dict -}}{{- end -}}
{{- if not .default.heat.api.middleware.ssl -}}{{- set .default.heat.api.middleware "ssl" dict -}}{{- end -}}
{{- if not .default.heat.common -}}{{- set .default.heat "common" dict -}}{{- end -}}
{{- if not .default.heat.common.config -}}{{- set .default.heat.common "config" dict -}}{{- end -}}
{{- if not .default.heat.common.crypt -}}{{- set .default.heat.common "crypt" dict -}}{{- end -}}
{{- if not .default.heat.common.wsgi -}}{{- set .default.heat.common "wsgi" dict -}}{{- end -}}
{{- if not .default.heat.engine -}}{{- set .default.heat "engine" dict -}}{{- end -}}
{{- if not .default.heat.engine.clients -}}{{- set .default.heat.engine "clients" dict -}}{{- end -}}
{{- if not .default.heat.engine.notification -}}{{- set .default.heat.engine "notification" dict -}}{{- end -}}
{{- if not .default.heat.engine.resources -}}{{- set .default.heat.engine "resources" dict -}}{{- end -}}
{{- if not .default.oslo -}}{{- set .default "oslo" dict -}}{{- end -}}
{{- if not .default.oslo.log -}}{{- set .default.oslo "log" dict -}}{{- end -}}
{{- if not .default.oslo.messaging -}}{{- set .default.oslo "messaging" dict -}}{{- end -}}
{{- if not .default.oslo.service -}}{{- set .default.oslo "service" dict -}}{{- end -}}
{{- if not .default.oslo.service.periodic_task -}}{{- set .default.oslo.service "periodic_task" dict -}}{{- end -}}
{{- if not .default.oslo.service.service -}}{{- set .default.oslo.service "service" dict -}}{{- end -}}
{{- if not .auth_password -}}{{- set . "auth_password" dict -}}{{- end -}}
{{- if not .auth_password.heat -}}{{- set .auth_password "heat" dict -}}{{- end -}}
{{- if not .auth_password.heat.common -}}{{- set .auth_password.heat "common" dict -}}{{- end -}}
{{- if not .auth_password.heat.common.config -}}{{- set .auth_password.heat.common "config" dict -}}{{- end -}}
{{- if not .clients -}}{{- set . "clients" dict -}}{{- end -}}
{{- if not .clients.heat -}}{{- set .clients "heat" dict -}}{{- end -}}
{{- if not .clients.heat.common -}}{{- set .clients.heat "common" dict -}}{{- end -}}
{{- if not .clients.heat.common.config -}}{{- set .clients.heat.common "config" dict -}}{{- end -}}
{{- if not .clients_aodh -}}{{- set . "clients_aodh" dict -}}{{- end -}}
{{- if not .clients_aodh.heat -}}{{- set .clients_aodh "heat" dict -}}{{- end -}}
{{- if not .clients_aodh.heat.common -}}{{- set .clients_aodh.heat "common" dict -}}{{- end -}}
{{- if not .clients_aodh.heat.common.config -}}{{- set .clients_aodh.heat.common "config" dict -}}{{- end -}}
{{- if not .clients_barbican -}}{{- set . "clients_barbican" dict -}}{{- end -}}
{{- if not .clients_barbican.heat -}}{{- set .clients_barbican "heat" dict -}}{{- end -}}
{{- if not .clients_barbican.heat.common -}}{{- set .clients_barbican.heat "common" dict -}}{{- end -}}
{{- if not .clients_barbican.heat.common.config -}}{{- set .clients_barbican.heat.common "config" dict -}}{{- end -}}
{{- if not .clients_ceilometer -}}{{- set . "clients_ceilometer" dict -}}{{- end -}}
{{- if not .clients_ceilometer.heat -}}{{- set .clients_ceilometer "heat" dict -}}{{- end -}}
{{- if not .clients_ceilometer.heat.common -}}{{- set .clients_ceilometer.heat "common" dict -}}{{- end -}}
{{- if not .clients_ceilometer.heat.common.config -}}{{- set .clients_ceilometer.heat.common "config" dict -}}{{- end -}}
{{- if not .clients_cinder -}}{{- set . "clients_cinder" dict -}}{{- end -}}
{{- if not .clients_cinder.heat -}}{{- set .clients_cinder "heat" dict -}}{{- end -}}
{{- if not .clients_cinder.heat.common -}}{{- set .clients_cinder.heat "common" dict -}}{{- end -}}
{{- if not .clients_cinder.heat.common.config -}}{{- set .clients_cinder.heat.common "config" dict -}}{{- end -}}
{{- if not .clients_designate -}}{{- set . "clients_designate" dict -}}{{- end -}}
{{- if not .clients_designate.heat -}}{{- set .clients_designate "heat" dict -}}{{- end -}}
{{- if not .clients_designate.heat.common -}}{{- set .clients_designate.heat "common" dict -}}{{- end -}}
{{- if not .clients_designate.heat.common.config -}}{{- set .clients_designate.heat.common "config" dict -}}{{- end -}}
{{- if not .clients_glance -}}{{- set . "clients_glance" dict -}}{{- end -}}
{{- if not .clients_glance.heat -}}{{- set .clients_glance "heat" dict -}}{{- end -}}
{{- if not .clients_glance.heat.common -}}{{- set .clients_glance.heat "common" dict -}}{{- end -}}
{{- if not .clients_glance.heat.common.config -}}{{- set .clients_glance.heat.common "config" dict -}}{{- end -}}
{{- if not .clients_heat -}}{{- set . "clients_heat" dict -}}{{- end -}}
{{- if not .clients_heat.heat -}}{{- set .clients_heat "heat" dict -}}{{- end -}}
{{- if not .clients_heat.heat.common -}}{{- set .clients_heat.heat "common" dict -}}{{- end -}}
{{- if not .clients_heat.heat.common.config -}}{{- set .clients_heat.heat.common "config" dict -}}{{- end -}}
{{- if not .clients_keystone -}}{{- set . "clients_keystone" dict -}}{{- end -}}
{{- if not .clients_keystone.heat -}}{{- set .clients_keystone "heat" dict -}}{{- end -}}
{{- if not .clients_keystone.heat.common -}}{{- set .clients_keystone.heat "common" dict -}}{{- end -}}
{{- if not .clients_keystone.heat.common.config -}}{{- set .clients_keystone.heat.common "config" dict -}}{{- end -}}
{{- if not .clients_magnum -}}{{- set . "clients_magnum" dict -}}{{- end -}}
{{- if not .clients_magnum.heat -}}{{- set .clients_magnum "heat" dict -}}{{- end -}}
{{- if not .clients_magnum.heat.common -}}{{- set .clients_magnum.heat "common" dict -}}{{- end -}}
{{- if not .clients_magnum.heat.common.config -}}{{- set .clients_magnum.heat.common "config" dict -}}{{- end -}}
{{- if not .clients_manila -}}{{- set . "clients_manila" dict -}}{{- end -}}
{{- if not .clients_manila.heat -}}{{- set .clients_manila "heat" dict -}}{{- end -}}
{{- if not .clients_manila.heat.common -}}{{- set .clients_manila.heat "common" dict -}}{{- end -}}
{{- if not .clients_manila.heat.common.config -}}{{- set .clients_manila.heat.common "config" dict -}}{{- end -}}
{{- if not .clients_mistral -}}{{- set . "clients_mistral" dict -}}{{- end -}}
{{- if not .clients_mistral.heat -}}{{- set .clients_mistral "heat" dict -}}{{- end -}}
{{- if not .clients_mistral.heat.common -}}{{- set .clients_mistral.heat "common" dict -}}{{- end -}}
{{- if not .clients_mistral.heat.common.config -}}{{- set .clients_mistral.heat.common "config" dict -}}{{- end -}}
{{- if not .clients_monasca -}}{{- set . "clients_monasca" dict -}}{{- end -}}
{{- if not .clients_monasca.heat -}}{{- set .clients_monasca "heat" dict -}}{{- end -}}
{{- if not .clients_monasca.heat.common -}}{{- set .clients_monasca.heat "common" dict -}}{{- end -}}
{{- if not .clients_monasca.heat.common.config -}}{{- set .clients_monasca.heat.common "config" dict -}}{{- end -}}
{{- if not .clients_neutron -}}{{- set . "clients_neutron" dict -}}{{- end -}}
{{- if not .clients_neutron.heat -}}{{- set .clients_neutron "heat" dict -}}{{- end -}}
{{- if not .clients_neutron.heat.common -}}{{- set .clients_neutron.heat "common" dict -}}{{- end -}}
{{- if not .clients_neutron.heat.common.config -}}{{- set .clients_neutron.heat.common "config" dict -}}{{- end -}}
{{- if not .clients_nova -}}{{- set . "clients_nova" dict -}}{{- end -}}
{{- if not .clients_nova.heat -}}{{- set .clients_nova "heat" dict -}}{{- end -}}
{{- if not .clients_nova.heat.common -}}{{- set .clients_nova.heat "common" dict -}}{{- end -}}
{{- if not .clients_nova.heat.common.config -}}{{- set .clients_nova.heat.common "config" dict -}}{{- end -}}
{{- if not .clients_sahara -}}{{- set . "clients_sahara" dict -}}{{- end -}}
{{- if not .clients_sahara.heat -}}{{- set .clients_sahara "heat" dict -}}{{- end -}}
{{- if not .clients_sahara.heat.common -}}{{- set .clients_sahara.heat "common" dict -}}{{- end -}}
{{- if not .clients_sahara.heat.common.config -}}{{- set .clients_sahara.heat.common "config" dict -}}{{- end -}}
{{- if not .clients_senlin -}}{{- set . "clients_senlin" dict -}}{{- end -}}
{{- if not .clients_senlin.heat -}}{{- set .clients_senlin "heat" dict -}}{{- end -}}
{{- if not .clients_senlin.heat.common -}}{{- set .clients_senlin.heat "common" dict -}}{{- end -}}
{{- if not .clients_senlin.heat.common.config -}}{{- set .clients_senlin.heat.common "config" dict -}}{{- end -}}
{{- if not .clients_swift -}}{{- set . "clients_swift" dict -}}{{- end -}}
{{- if not .clients_swift.heat -}}{{- set .clients_swift "heat" dict -}}{{- end -}}
{{- if not .clients_swift.heat.common -}}{{- set .clients_swift.heat "common" dict -}}{{- end -}}
{{- if not .clients_swift.heat.common.config -}}{{- set .clients_swift.heat.common "config" dict -}}{{- end -}}
{{- if not .clients_trove -}}{{- set . "clients_trove" dict -}}{{- end -}}
{{- if not .clients_trove.heat -}}{{- set .clients_trove "heat" dict -}}{{- end -}}
{{- if not .clients_trove.heat.common -}}{{- set .clients_trove.heat "common" dict -}}{{- end -}}
{{- if not .clients_trove.heat.common.config -}}{{- set .clients_trove.heat.common "config" dict -}}{{- end -}}
{{- if not .clients_zaqar -}}{{- set . "clients_zaqar" dict -}}{{- end -}}
{{- if not .clients_zaqar.heat -}}{{- set .clients_zaqar "heat" dict -}}{{- end -}}
{{- if not .clients_zaqar.heat.common -}}{{- set .clients_zaqar.heat "common" dict -}}{{- end -}}
{{- if not .clients_zaqar.heat.common.config -}}{{- set .clients_zaqar.heat.common "config" dict -}}{{- end -}}
{{- if not .cors -}}{{- set . "cors" dict -}}{{- end -}}
{{- if not .cors.oslo -}}{{- set .cors "oslo" dict -}}{{- end -}}
{{- if not .cors.oslo.middleware -}}{{- set .cors.oslo "middleware" dict -}}{{- end -}}
{{- if not .cors.subdomain -}}{{- set .cors "subdomain" dict -}}{{- end -}}
{{- if not .cors.subdomain.oslo -}}{{- set .cors.subdomain "oslo" dict -}}{{- end -}}
{{- if not .cors.subdomain.oslo.middleware -}}{{- set .cors.subdomain.oslo "middleware" dict -}}{{- end -}}
{{- if not .database -}}{{- set . "database" dict -}}{{- end -}}
{{- if not .database.oslo -}}{{- set .database "oslo" dict -}}{{- end -}}
{{- if not .database.oslo.db -}}{{- set .database.oslo "db" dict -}}{{- end -}}
{{- if not .ec2authtoken -}}{{- set . "ec2authtoken" dict -}}{{- end -}}
{{- if not .ec2authtoken.heat -}}{{- set .ec2authtoken "heat" dict -}}{{- end -}}
{{- if not .ec2authtoken.heat.api -}}{{- set .ec2authtoken.heat "api" dict -}}{{- end -}}
{{- if not .ec2authtoken.heat.api.aws -}}{{- set .ec2authtoken.heat.api "aws" dict -}}{{- end -}}
{{- if not .ec2authtoken.heat.api.aws.ec2token -}}{{- set .ec2authtoken.heat.api.aws "ec2token" dict -}}{{- end -}}
{{- if not .eventlet_opts -}}{{- set . "eventlet_opts" dict -}}{{- end -}}
{{- if not .eventlet_opts.heat -}}{{- set .eventlet_opts "heat" dict -}}{{- end -}}
{{- if not .eventlet_opts.heat.common -}}{{- set .eventlet_opts.heat "common" dict -}}{{- end -}}
{{- if not .eventlet_opts.heat.common.wsgi -}}{{- set .eventlet_opts.heat.common "wsgi" dict -}}{{- end -}}
{{- if not .heat_api -}}{{- set . "heat_api" dict -}}{{- end -}}
{{- if not .heat_api.heat -}}{{- set .heat_api "heat" dict -}}{{- end -}}
{{- if not .heat_api.heat.common -}}{{- set .heat_api.heat "common" dict -}}{{- end -}}
{{- if not .heat_api.heat.common.wsgi -}}{{- set .heat_api.heat.common "wsgi" dict -}}{{- end -}}
{{- if not .heat_api_cfn -}}{{- set . "heat_api_cfn" dict -}}{{- end -}}
{{- if not .heat_api_cfn.heat -}}{{- set .heat_api_cfn "heat" dict -}}{{- end -}}
{{- if not .heat_api_cfn.heat.common -}}{{- set .heat_api_cfn.heat "common" dict -}}{{- end -}}
{{- if not .heat_api_cfn.heat.common.wsgi -}}{{- set .heat_api_cfn.heat.common "wsgi" dict -}}{{- end -}}
{{- if not .heat_api_cloudwatch -}}{{- set . "heat_api_cloudwatch" dict -}}{{- end -}}
{{- if not .heat_api_cloudwatch.heat -}}{{- set .heat_api_cloudwatch "heat" dict -}}{{- end -}}
{{- if not .heat_api_cloudwatch.heat.common -}}{{- set .heat_api_cloudwatch.heat "common" dict -}}{{- end -}}
{{- if not .heat_api_cloudwatch.heat.common.wsgi -}}{{- set .heat_api_cloudwatch.heat.common "wsgi" dict -}}{{- end -}}
{{- if not .keystone_authtoken -}}{{- set . "keystone_authtoken" dict -}}{{- end -}}
{{- if not .keystone_authtoken.keystonemiddleware -}}{{- set .keystone_authtoken "keystonemiddleware" dict -}}{{- end -}}
{{- if not .keystone_authtoken.keystonemiddleware.auth_token -}}{{- set .keystone_authtoken.keystonemiddleware "auth_token" dict -}}{{- end -}}
{{- if not .matchmaker_redis -}}{{- set . "matchmaker_redis" dict -}}{{- end -}}
{{- if not .matchmaker_redis.oslo -}}{{- set .matchmaker_redis "oslo" dict -}}{{- end -}}
{{- if not .matchmaker_redis.oslo.messaging -}}{{- set .matchmaker_redis.oslo "messaging" dict -}}{{- end -}}
{{- if not .oslo_messaging_amqp -}}{{- set . "oslo_messaging_amqp" dict -}}{{- end -}}
{{- if not .oslo_messaging_amqp.oslo -}}{{- set .oslo_messaging_amqp "oslo" dict -}}{{- end -}}
{{- if not .oslo_messaging_amqp.oslo.messaging -}}{{- set .oslo_messaging_amqp.oslo "messaging" dict -}}{{- end -}}
{{- if not .oslo_messaging_notifications -}}{{- set . "oslo_messaging_notifications" dict -}}{{- end -}}
{{- if not .oslo_messaging_notifications.oslo -}}{{- set .oslo_messaging_notifications "oslo" dict -}}{{- end -}}
{{- if not .oslo_messaging_notifications.oslo.messaging -}}{{- set .oslo_messaging_notifications.oslo "messaging" dict -}}{{- end -}}
{{- if not .oslo_messaging_rabbit -}}{{- set . "oslo_messaging_rabbit" dict -}}{{- end -}}
{{- if not .oslo_messaging_rabbit.oslo -}}{{- set .oslo_messaging_rabbit "oslo" dict -}}{{- end -}}
{{- if not .oslo_messaging_rabbit.oslo.messaging -}}{{- set .oslo_messaging_rabbit.oslo "messaging" dict -}}{{- end -}}
{{- if not .oslo_messaging_zmq -}}{{- set . "oslo_messaging_zmq" dict -}}{{- end -}}
{{- if not .oslo_messaging_zmq.oslo -}}{{- set .oslo_messaging_zmq "oslo" dict -}}{{- end -}}
{{- if not .oslo_messaging_zmq.oslo.messaging -}}{{- set .oslo_messaging_zmq.oslo "messaging" dict -}}{{- end -}}
{{- if not .oslo_middleware -}}{{- set . "oslo_middleware" dict -}}{{- end -}}
{{- if not .oslo_middleware.oslo -}}{{- set .oslo_middleware "oslo" dict -}}{{- end -}}
{{- if not .oslo_middleware.oslo.middleware -}}{{- set .oslo_middleware.oslo "middleware" dict -}}{{- end -}}
{{- if not .oslo_policy -}}{{- set . "oslo_policy" dict -}}{{- end -}}
{{- if not .oslo_policy.oslo -}}{{- set .oslo_policy "oslo" dict -}}{{- end -}}
{{- if not .oslo_policy.oslo.policy -}}{{- set .oslo_policy.oslo "policy" dict -}}{{- end -}}
{{- if not .paste_deploy -}}{{- set . "paste_deploy" dict -}}{{- end -}}
{{- if not .paste_deploy.heat -}}{{- set .paste_deploy "heat" dict -}}{{- end -}}
{{- if not .paste_deploy.heat.common -}}{{- set .paste_deploy.heat "common" dict -}}{{- end -}}
{{- if not .paste_deploy.heat.common.config -}}{{- set .paste_deploy.heat.common "config" dict -}}{{- end -}}
{{- if not .profiler -}}{{- set . "profiler" dict -}}{{- end -}}
{{- if not .profiler.heat -}}{{- set .profiler "heat" dict -}}{{- end -}}
{{- if not .profiler.heat.common -}}{{- set .profiler.heat "common" dict -}}{{- end -}}
{{- if not .profiler.heat.common.config -}}{{- set .profiler.heat.common "config" dict -}}{{- end -}}
{{- if not .revision -}}{{- set . "revision" dict -}}{{- end -}}
{{- if not .revision.heat -}}{{- set .revision "heat" dict -}}{{- end -}}
{{- if not .revision.heat.common -}}{{- set .revision.heat "common" dict -}}{{- end -}}
{{- if not .revision.heat.common.config -}}{{- set .revision.heat.common "config" dict -}}{{- end -}}
{{- if not .ssl -}}{{- set . "ssl" dict -}}{{- end -}}
{{- if not .ssl.oslo -}}{{- set .ssl "oslo" dict -}}{{- end -}}
{{- if not .ssl.oslo.service -}}{{- set .ssl.oslo "service" dict -}}{{- end -}}
{{- if not .ssl.oslo.service.sslutils -}}{{- set .ssl.oslo.service "sslutils" dict -}}{{- end -}}
{{- if not .trustee -}}{{- set . "trustee" dict -}}{{- end -}}
{{- if not .trustee.heat -}}{{- set .trustee "heat" dict -}}{{- end -}}
{{- if not .trustee.heat.common -}}{{- set .trustee.heat "common" dict -}}{{- end -}}
{{- if not .trustee.heat.common.context -}}{{- set .trustee.heat.common "context" dict -}}{{- end -}}
{{- if not .volumes -}}{{- set . "volumes" dict -}}{{- end -}}
{{- if not .volumes.heat -}}{{- set .volumes "heat" dict -}}{{- end -}}
{{- if not .volumes.heat.common -}}{{- set .volumes.heat "common" dict -}}{{- end -}}
{{- if not .volumes.heat.common.config -}}{{- set .volumes.heat.common "config" dict -}}{{- end -}}

{{- end -}}


{{- define "heat.conf.heat" -}}

[DEFAULT]

#
# From heat.api.middleware.ssl
#

# The HTTP Header that will be used to determine which the original request
# protocol scheme was, even if it was removed by an SSL terminator proxy.
# (string value)
# Deprecated group/name - [DEFAULT]/secure_proxy_ssl_header
# from .default.heat.api.middleware.ssl.secure_proxy_ssl_header
{{ if not .default.heat.api.middleware.ssl.secure_proxy_ssl_header }}#{{ end }}secure_proxy_ssl_header = {{ .default.heat.api.middleware.ssl.secure_proxy_ssl_header | default "X-Forwarded-Proto" }}

#
# From heat.common.config
#

# Name of the engine node. This can be an opaque identifier. It is not
# necessarily a hostname, FQDN, or IP address. (string value)
# from .default.heat.common.config.host
{{ if not .default.heat.common.config.host }}#{{ end }}host = {{ .default.heat.common.config.host | default "546f0a55deb6" }}

# List of directories to search for plug-ins. (list value)
# from .default.heat.common.config.plugin_dirs
{{ if not .default.heat.common.config.plugin_dirs }}#{{ end }}plugin_dirs = {{ .default.heat.common.config.plugin_dirs | default "/usr/lib64/heat,/usr/lib/heat,/usr/local/lib/heat,/usr/local/lib64/heat" }}

# The directory to search for environment files. (string value)
# from .default.heat.common.config.environment_dir
{{ if not .default.heat.common.config.environment_dir }}#{{ end }}environment_dir = {{ .default.heat.common.config.environment_dir | default "/etc/heat/environment.d" }}

# The directory to search for template files. (string value)
# from .default.heat.common.config.template_dir
{{ if not .default.heat.common.config.template_dir }}#{{ end }}template_dir = {{ .default.heat.common.config.template_dir | default "/etc/heat/templates" }}

# Select deferred auth method, stored password or trusts. (string value)
# Allowed values: password, trusts
# from .default.heat.common.config.deferred_auth_method
{{ if not .default.heat.common.config.deferred_auth_method }}#{{ end }}deferred_auth_method = {{ .default.heat.common.config.deferred_auth_method | default "trusts" }}

# Allow reauthentication on token expiry, such that long-running tasks may
# complete. Note this defeats the expiry of any provided user tokens. (string
# value)
# Allowed values: '', trusts
# from .default.heat.common.config.reauthentication_auth_method
{{ if not .default.heat.common.config.reauthentication_auth_method }}#{{ end }}reauthentication_auth_method = {{ .default.heat.common.config.reauthentication_auth_method | default "" }}

# Gap, in seconds, to determine whether the given token is about to expire.
# (integer value)
# from .default.heat.common.config.stale_token_duration
{{ if not .default.heat.common.config.stale_token_duration }}#{{ end }}stale_token_duration = {{ .default.heat.common.config.stale_token_duration | default "30" }}

# Subset of trustor roles to be delegated to heat. If left unset, all roles of
# a user will be delegated to heat when creating a stack. (list value)
# from .default.heat.common.config.trusts_delegated_roles
{{ if not .default.heat.common.config.trusts_delegated_roles }}#{{ end }}trusts_delegated_roles = {{ .default.heat.common.config.trusts_delegated_roles | default "" }}

# Maximum resources allowed per top-level stack. -1 stands for unlimited.
# (integer value)
# from .default.heat.common.config.max_resources_per_stack
{{ if not .default.heat.common.config.max_resources_per_stack }}#{{ end }}max_resources_per_stack = {{ .default.heat.common.config.max_resources_per_stack | default "1000" }}

# Maximum number of stacks any one tenant may have active at one time. (integer
# value)
# from .default.heat.common.config.max_stacks_per_tenant
{{ if not .default.heat.common.config.max_stacks_per_tenant }}#{{ end }}max_stacks_per_tenant = {{ .default.heat.common.config.max_stacks_per_tenant | default "100" }}

# Number of times to retry to bring a resource to a non-error state. Set to 0
# to disable retries. (integer value)
# from .default.heat.common.config.action_retry_limit
{{ if not .default.heat.common.config.action_retry_limit }}#{{ end }}action_retry_limit = {{ .default.heat.common.config.action_retry_limit | default "5" }}

# Number of times to retry when a client encounters an expected intermittent
# error. Set to 0 to disable retries. (integer value)
# from .default.heat.common.config.client_retry_limit
{{ if not .default.heat.common.config.client_retry_limit }}#{{ end }}client_retry_limit = {{ .default.heat.common.config.client_retry_limit | default "2" }}

# Maximum length of a server name to be used in nova. (integer value)
# Maximum value: 53
# from .default.heat.common.config.max_server_name_length
{{ if not .default.heat.common.config.max_server_name_length }}#{{ end }}max_server_name_length = {{ .default.heat.common.config.max_server_name_length | default "53" }}

# Number of times to check whether an interface has been attached or detached.
# (integer value)
# Minimum value: 1
# from .default.heat.common.config.max_interface_check_attempts
{{ if not .default.heat.common.config.max_interface_check_attempts }}#{{ end }}max_interface_check_attempts = {{ .default.heat.common.config.max_interface_check_attempts | default "10" }}

# Controls how many events will be pruned whenever a stack's events exceed
# max_events_per_stack. Set this lower to keep more events at the expense of
# more frequent purges. (integer value)
# from .default.heat.common.config.event_purge_batch_size
{{ if not .default.heat.common.config.event_purge_batch_size }}#{{ end }}event_purge_batch_size = {{ .default.heat.common.config.event_purge_batch_size | default "10" }}

# Maximum events that will be available per stack. Older events will be deleted
# when this is reached. Set to 0 for unlimited events per stack. (integer
# value)
# from .default.heat.common.config.max_events_per_stack
{{ if not .default.heat.common.config.max_events_per_stack }}#{{ end }}max_events_per_stack = {{ .default.heat.common.config.max_events_per_stack | default "1000" }}

# Timeout in seconds for stack action (ie. create or update). (integer value)
# from .default.heat.common.config.stack_action_timeout
{{ if not .default.heat.common.config.stack_action_timeout }}#{{ end }}stack_action_timeout = {{ .default.heat.common.config.stack_action_timeout | default "3600" }}

# The amount of time in seconds after an error has occurred that tasks may
# continue to run before being cancelled. (integer value)
# from .default.heat.common.config.error_wait_time
{{ if not .default.heat.common.config.error_wait_time }}#{{ end }}error_wait_time = {{ .default.heat.common.config.error_wait_time | default "240" }}

# RPC timeout for the engine liveness check that is used for stack locking.
# (integer value)
# from .default.heat.common.config.engine_life_check_timeout
{{ if not .default.heat.common.config.engine_life_check_timeout }}#{{ end }}engine_life_check_timeout = {{ .default.heat.common.config.engine_life_check_timeout | default "2" }}

# Enable the legacy OS::Heat::CWLiteAlarm resource. (boolean value)
# from .default.heat.common.config.enable_cloud_watch_lite
{{ if not .default.heat.common.config.enable_cloud_watch_lite }}#{{ end }}enable_cloud_watch_lite = {{ .default.heat.common.config.enable_cloud_watch_lite | default "false" }}

# Enable the preview Stack Abandon feature. (boolean value)
# from .default.heat.common.config.enable_stack_abandon
{{ if not .default.heat.common.config.enable_stack_abandon }}#{{ end }}enable_stack_abandon = {{ .default.heat.common.config.enable_stack_abandon | default "false" }}

# Enable the preview Stack Adopt feature. (boolean value)
# from .default.heat.common.config.enable_stack_adopt
{{ if not .default.heat.common.config.enable_stack_adopt }}#{{ end }}enable_stack_adopt = {{ .default.heat.common.config.enable_stack_adopt | default "false" }}

# Enables engine with convergence architecture. All stacks with this option
# will be created using convergence engine. (boolean value)
# from .default.heat.common.config.convergence_engine
{{ if not .default.heat.common.config.convergence_engine }}#{{ end }}convergence_engine = {{ .default.heat.common.config.convergence_engine | default "true" }}

# On update, enables heat to collect existing resource properties from reality
# and converge to updated template. (boolean value)
# from .default.heat.common.config.observe_on_update
{{ if not .default.heat.common.config.observe_on_update }}#{{ end }}observe_on_update = {{ .default.heat.common.config.observe_on_update | default "false" }}

# Template default for how the server should receive the metadata required for
# software configuration. POLL_SERVER_CFN will allow calls to the cfn API
# action DescribeStackResource authenticated with the provided keypair
# (requires enabled heat-api-cfn). POLL_SERVER_HEAT will allow calls to the
# Heat API resource-show using the provided keystone credentials (requires
# keystone v3 API, and configured stack_user_* config options). POLL_TEMP_URL
# will create and populate a Swift TempURL with metadata for polling (requires
# object-store endpoint which supports TempURL).ZAQAR_MESSAGE will create a
# dedicated zaqar queue and post the metadata for polling. (string value)
# Allowed values: POLL_SERVER_CFN, POLL_SERVER_HEAT, POLL_TEMP_URL, ZAQAR_MESSAGE
# from .default.heat.common.config.default_software_config_transport
{{ if not .default.heat.common.config.default_software_config_transport }}#{{ end }}default_software_config_transport = {{ .default.heat.common.config.default_software_config_transport | default "POLL_SERVER_CFN" }}

# Template default for how the server should signal to heat with the deployment
# output values. CFN_SIGNAL will allow an HTTP POST to a CFN keypair signed URL
# (requires enabled heat-api-cfn). TEMP_URL_SIGNAL will create a Swift TempURL
# to be signaled via HTTP PUT (requires object-store endpoint which supports
# TempURL). HEAT_SIGNAL will allow calls to the Heat API resource-signal using
# the provided keystone credentials. ZAQAR_SIGNAL will create a dedicated zaqar
# queue to be signaled using the provided keystone credentials. (string value)
# Allowed values: CFN_SIGNAL, TEMP_URL_SIGNAL, HEAT_SIGNAL, ZAQAR_SIGNAL
# from .default.heat.common.config.default_deployment_signal_transport
{{ if not .default.heat.common.config.default_deployment_signal_transport }}#{{ end }}default_deployment_signal_transport = {{ .default.heat.common.config.default_deployment_signal_transport | default "CFN_SIGNAL" }}

# Stacks containing these tag names will be hidden. Multiple tags should be
# given in a comma-delimited list (eg. hidden_stack_tags=hide_me,me_too). (list
# value)
# from .default.heat.common.config.hidden_stack_tags
{{ if not .default.heat.common.config.hidden_stack_tags }}#{{ end }}hidden_stack_tags = {{ .default.heat.common.config.hidden_stack_tags | default "data-processing-cluster" }}

# Deprecated. (string value)
# from .default.heat.common.config.onready
{{ if not .default.heat.common.config.onready }}#{{ end }}onready = {{ .default.heat.common.config.onready | default "<None>" }}

# When this feature is enabled, scheduler hints identifying the heat stack
# context of a server or volume resource are passed to the configured
# schedulers in nova and cinder, for creates done using heat resource types
# OS::Cinder::Volume, OS::Nova::Server, and AWS::EC2::Instance.
# heat_root_stack_id will be set to the id of the root stack of the resource,
# heat_stack_id will be set to the id of the resource's parent stack,
# heat_stack_name will be set to the name of the resource's parent stack,
# heat_path_in_stack will be set to a list of comma delimited strings of
# stackresourcename and stackname with list[0] being 'rootstackname',
# heat_resource_name will be set to the resource's name, and heat_resource_uuid
# will be set to the resource's orchestration id. (boolean value)
# from .default.heat.common.config.stack_scheduler_hints
{{ if not .default.heat.common.config.stack_scheduler_hints }}#{{ end }}stack_scheduler_hints = {{ .default.heat.common.config.stack_scheduler_hints | default "false" }}

# Encrypt template parameters that were marked as hidden and also all the
# resource properties before storing them in database. (boolean value)
# from .default.heat.common.config.encrypt_parameters_and_properties
{{ if not .default.heat.common.config.encrypt_parameters_and_properties }}#{{ end }}encrypt_parameters_and_properties = {{ .default.heat.common.config.encrypt_parameters_and_properties | default "false" }}

# Seconds between running periodic tasks. (integer value)
# from .default.heat.common.config.periodic_interval
{{ if not .default.heat.common.config.periodic_interval }}#{{ end }}periodic_interval = {{ .default.heat.common.config.periodic_interval | default "60" }}

# URL of the Heat metadata server. NOTE: Setting this is only needed if you
# require instances to use a different endpoint than in the keystone catalog
# (string value)
# from .default.heat.common.config.heat_metadata_server_url
{{ if not .default.heat.common.config.heat_metadata_server_url }}#{{ end }}heat_metadata_server_url = {{ .default.heat.common.config.heat_metadata_server_url | default "<None>" }}

# URL of the Heat waitcondition server. (string value)
# from .default.heat.common.config.heat_waitcondition_server_url
{{ if not .default.heat.common.config.heat_waitcondition_server_url }}#{{ end }}heat_waitcondition_server_url = {{ .default.heat.common.config.heat_waitcondition_server_url | default "<None>" }}

# URL of the Heat CloudWatch server. (string value)
# from .default.heat.common.config.heat_watch_server_url
{{ if not .default.heat.common.config.heat_watch_server_url }}#{{ end }}heat_watch_server_url = {{ .default.heat.common.config.heat_watch_server_url | default "" }}

# Instance connection to CFN/CW API via https. (string value)
# from .default.heat.common.config.instance_connection_is_secure
{{ if not .default.heat.common.config.instance_connection_is_secure }}#{{ end }}instance_connection_is_secure = {{ .default.heat.common.config.instance_connection_is_secure | default "0" }}

# Instance connection to CFN/CW API validate certs if SSL is used. (string
# value)
# from .default.heat.common.config.instance_connection_https_validate_certificates
{{ if not .default.heat.common.config.instance_connection_https_validate_certificates }}#{{ end }}instance_connection_https_validate_certificates = {{ .default.heat.common.config.instance_connection_https_validate_certificates | default "1" }}

# Default region name used to get services endpoints. (string value)
# from .default.heat.common.config.region_name_for_services
{{ if not .default.heat.common.config.region_name_for_services }}#{{ end }}region_name_for_services = {{ .default.heat.common.config.region_name_for_services | default "<None>" }}

# Keystone role for heat template-defined users. (string value)
# from .default.heat.common.config.heat_stack_user_role
{{ if not .default.heat.common.config.heat_stack_user_role }}#{{ end }}heat_stack_user_role = {{ .default.heat.common.config.heat_stack_user_role | default "heat_stack_user" }}

# Keystone domain ID which contains heat template-defined users. If this option
# is set, stack_user_domain_name option will be ignored. (string value)
# Deprecated group/name - [DEFAULT]/stack_user_domain
# from .default.heat.common.config.stack_user_domain_id
{{ if not .default.heat.common.config.stack_user_domain_id }}#{{ end }}stack_user_domain_id = {{ .default.heat.common.config.stack_user_domain_id | default "<None>" }}

# Keystone domain name which contains heat template-defined users. If
# `stack_user_domain_id` option is set, this option is ignored. (string value)
# from .default.heat.common.config.stack_user_domain_name
{{ if not .default.heat.common.config.stack_user_domain_name }}#{{ end }}stack_user_domain_name = {{ .default.heat.common.config.stack_user_domain_name | default "<None>" }}

# Keystone username, a user with roles sufficient to manage users and projects
# in the stack_user_domain. (string value)
# from .default.heat.common.config.stack_domain_admin
{{ if not .default.heat.common.config.stack_domain_admin }}#{{ end }}stack_domain_admin = {{ .default.heat.common.config.stack_domain_admin | default "<None>" }}

# Keystone password for stack_domain_admin user. (string value)
# from .default.heat.common.config.stack_domain_admin_password
{{ if not .default.heat.common.config.stack_domain_admin_password }}#{{ end }}stack_domain_admin_password = {{ .default.heat.common.config.stack_domain_admin_password | default "<None>" }}

# Maximum raw byte size of any template. (integer value)
# from .default.heat.common.config.max_template_size
{{ if not .default.heat.common.config.max_template_size }}#{{ end }}max_template_size = {{ .default.heat.common.config.max_template_size | default "524288" }}

# Maximum depth allowed when using nested stacks. (integer value)
# from .default.heat.common.config.max_nested_stack_depth
{{ if not .default.heat.common.config.max_nested_stack_depth }}#{{ end }}max_nested_stack_depth = {{ .default.heat.common.config.max_nested_stack_depth | default "5" }}

# Number of heat-engine processes to fork and run. Will default to either to 4
# or number of CPUs on the host, whichever is greater. (integer value)
# from .default.heat.common.config.num_engine_workers
{{ if not .default.heat.common.config.num_engine_workers }}#{{ end }}num_engine_workers = {{ .default.heat.common.config.num_engine_workers | default "<None>" }}

#
# From heat.common.crypt
#

# Key used to encrypt authentication info in the database. Length of this key
# must be 32 characters. (string value)
# from .default.heat.common.crypt.auth_encryption_key
{{ if not .default.heat.common.crypt.auth_encryption_key }}#{{ end }}auth_encryption_key = {{ .default.heat.common.crypt.auth_encryption_key | default "notgood but just long enough i t" }}

#
# From heat.common.wsgi
#

# Maximum raw byte size of JSON request body. Should be larger than
# max_template_size. (integer value)
# from .default.heat.common.wsgi.max_json_body_size
{{ if not .default.heat.common.wsgi.max_json_body_size }}#{{ end }}max_json_body_size = {{ .default.heat.common.wsgi.max_json_body_size | default "1048576" }}

#
# From heat.engine.clients
#

# Fully qualified class name to use as a client backend. (string value)
# from .default.heat.engine.clients.cloud_backend
{{ if not .default.heat.engine.clients.cloud_backend }}#{{ end }}cloud_backend = {{ .default.heat.engine.clients.cloud_backend | default "heat.engine.clients.OpenStackClients" }}

#
# From heat.engine.notification
#

# Default notification level for outgoing notifications. (string value)
# from .default.heat.engine.notification.default_notification_level
{{ if not .default.heat.engine.notification.default_notification_level }}#{{ end }}default_notification_level = {{ .default.heat.engine.notification.default_notification_level | default "INFO" }}

# Default publisher_id for outgoing notifications. (string value)
# from .default.heat.engine.notification.default_publisher_id
{{ if not .default.heat.engine.notification.default_publisher_id }}#{{ end }}default_publisher_id = {{ .default.heat.engine.notification.default_publisher_id | default "<None>" }}

#
# From heat.engine.resources
#

# Custom template for the built-in loadbalancer nested stack. (string value)
# from .default.heat.engine.resources.loadbalancer_template
{{ if not .default.heat.engine.resources.loadbalancer_template }}#{{ end }}loadbalancer_template = {{ .default.heat.engine.resources.loadbalancer_template | default "<None>" }}

#
# From oslo.log
#

# If set to true, the logging level will be set to DEBUG instead of the default
# INFO level. (boolean value)
# Note: This option can be changed without restarting.
# from .default.oslo.log.debug
{{ if not .default.oslo.log.debug }}#{{ end }}debug = {{ .default.oslo.log.debug | default "false" }}

# DEPRECATED: If set to false, the logging level will be set to WARNING instead
# of the default INFO level. (boolean value)
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# from .default.oslo.log.verbose
{{ if not .default.oslo.log.verbose }}#{{ end }}verbose = {{ .default.oslo.log.verbose | default "true" }}

# The name of a logging configuration file. This file is appended to any
# existing logging configuration files. For details about logging configuration
# files, see the Python logging module documentation. Note that when logging
# configuration files are used then all logging configuration is set in the
# configuration file and other logging configuration options are ignored (for
# example, logging_context_format_string). (string value)
# Note: This option can be changed without restarting.
# Deprecated group/name - [DEFAULT]/log_config
# from .default.oslo.log.log_config_append
{{ if not .default.oslo.log.log_config_append }}#{{ end }}log_config_append = {{ .default.oslo.log.log_config_append | default "<None>" }}

# Defines the format string for %%(asctime)s in log records. Default:
# %(default)s . This option is ignored if log_config_append is set. (string
# value)
# from .default.oslo.log.log_date_format
{{ if not .default.oslo.log.log_date_format }}#{{ end }}log_date_format = {{ .default.oslo.log.log_date_format | default "%Y-%m-%d %H:%M:%S" }}

# (Optional) Name of log file to send logging output to. If no default is set,
# logging will go to stderr as defined by use_stderr. This option is ignored if
# log_config_append is set. (string value)
# Deprecated group/name - [DEFAULT]/logfile
# from .default.oslo.log.log_file
{{ if not .default.oslo.log.log_file }}#{{ end }}log_file = {{ .default.oslo.log.log_file | default "<None>" }}

# (Optional) The base directory used for relative log_file  paths. This option
# is ignored if log_config_append is set. (string value)
# Deprecated group/name - [DEFAULT]/logdir
# from .default.oslo.log.log_dir
{{ if not .default.oslo.log.log_dir }}#{{ end }}log_dir = {{ .default.oslo.log.log_dir | default "<None>" }}

# Uses logging handler designed to watch file system. When log file is moved or
# removed this handler will open a new log file with specified path
# instantaneously. It makes sense only if log_file option is specified and
# Linux platform is used. This option is ignored if log_config_append is set.
# (boolean value)
# from .default.oslo.log.watch_log_file
{{ if not .default.oslo.log.watch_log_file }}#{{ end }}watch_log_file = {{ .default.oslo.log.watch_log_file | default "false" }}

# Use syslog for logging. Existing syslog format is DEPRECATED and will be
# changed later to honor RFC5424. This option is ignored if log_config_append
# is set. (boolean value)
# from .default.oslo.log.use_syslog
{{ if not .default.oslo.log.use_syslog }}#{{ end }}use_syslog = {{ .default.oslo.log.use_syslog | default "false" }}

# Syslog facility to receive log lines. This option is ignored if
# log_config_append is set. (string value)
# from .default.oslo.log.syslog_log_facility
{{ if not .default.oslo.log.syslog_log_facility }}#{{ end }}syslog_log_facility = {{ .default.oslo.log.syslog_log_facility | default "LOG_USER" }}

# Log output to standard error. This option is ignored if log_config_append is
# set. (boolean value)
# from .default.oslo.log.use_stderr
{{ if not .default.oslo.log.use_stderr }}#{{ end }}use_stderr = {{ .default.oslo.log.use_stderr | default "true" }}

# Format string to use for log messages with context. (string value)
# from .default.oslo.log.logging_context_format_string
{{ if not .default.oslo.log.logging_context_format_string }}#{{ end }}logging_context_format_string = {{ .default.oslo.log.logging_context_format_string | default "%(asctime)s.%(msecs)03d %(process)d %(levelname)s %(name)s [%(request_id)s %(user_identity)s] %(instance)s%(message)s" }}

# Format string to use for log messages when context is undefined. (string
# value)
# from .default.oslo.log.logging_default_format_string
{{ if not .default.oslo.log.logging_default_format_string }}#{{ end }}logging_default_format_string = {{ .default.oslo.log.logging_default_format_string | default "%(asctime)s.%(msecs)03d %(process)d %(levelname)s %(name)s [-] %(instance)s%(message)s" }}

# Additional data to append to log message when logging level for the message
# is DEBUG. (string value)
# from .default.oslo.log.logging_debug_format_suffix
{{ if not .default.oslo.log.logging_debug_format_suffix }}#{{ end }}logging_debug_format_suffix = {{ .default.oslo.log.logging_debug_format_suffix | default "%(funcName)s %(pathname)s:%(lineno)d" }}

# Prefix each line of exception output with this format. (string value)
# from .default.oslo.log.logging_exception_prefix
{{ if not .default.oslo.log.logging_exception_prefix }}#{{ end }}logging_exception_prefix = {{ .default.oslo.log.logging_exception_prefix | default "%(asctime)s.%(msecs)03d %(process)d ERROR %(name)s %(instance)s" }}

# Defines the format string for %(user_identity)s that is used in
# logging_context_format_string. (string value)
# from .default.oslo.log.logging_user_identity_format
{{ if not .default.oslo.log.logging_user_identity_format }}#{{ end }}logging_user_identity_format = {{ .default.oslo.log.logging_user_identity_format | default "%(user)s %(tenant)s %(domain)s %(user_domain)s %(project_domain)s" }}

# List of package logging levels in logger=LEVEL pairs. This option is ignored
# if log_config_append is set. (list value)
# from .default.oslo.log.default_log_levels
{{ if not .default.oslo.log.default_log_levels }}#{{ end }}default_log_levels = {{ .default.oslo.log.default_log_levels | default "amqp=WARN,amqplib=WARN,boto=WARN,qpid=WARN,sqlalchemy=WARN,suds=INFO,oslo.messaging=INFO,iso8601=WARN,requests.packages.urllib3.connectionpool=WARN,urllib3.connectionpool=WARN,websocket=WARN,requests.packages.urllib3.util.retry=WARN,urllib3.util.retry=WARN,keystonemiddleware=WARN,routes.middleware=WARN,stevedore=WARN,taskflow=WARN,keystoneauth=WARN,oslo.cache=INFO,dogpile.core.dogpile=INFO" }}

# Enables or disables publication of error events. (boolean value)
# from .default.oslo.log.publish_errors
{{ if not .default.oslo.log.publish_errors }}#{{ end }}publish_errors = {{ .default.oslo.log.publish_errors | default "false" }}

# The format for an instance that is passed with the log message. (string
# value)
# from .default.oslo.log.instance_format
{{ if not .default.oslo.log.instance_format }}#{{ end }}instance_format = {{ .default.oslo.log.instance_format | default "\"[instance: %(uuid)s] \"" }}

# The format for an instance UUID that is passed with the log message. (string
# value)
# from .default.oslo.log.instance_uuid_format
{{ if not .default.oslo.log.instance_uuid_format }}#{{ end }}instance_uuid_format = {{ .default.oslo.log.instance_uuid_format | default "\"[instance: %(uuid)s] \"" }}

# Enables or disables fatal status of deprecations. (boolean value)
# from .default.oslo.log.fatal_deprecations
{{ if not .default.oslo.log.fatal_deprecations }}#{{ end }}fatal_deprecations = {{ .default.oslo.log.fatal_deprecations | default "false" }}

#
# From oslo.messaging
#

# Size of RPC connection pool. (integer value)
# Deprecated group/name - [DEFAULT]/rpc_conn_pool_size
# from .default.oslo.messaging.rpc_conn_pool_size
{{ if not .default.oslo.messaging.rpc_conn_pool_size }}#{{ end }}rpc_conn_pool_size = {{ .default.oslo.messaging.rpc_conn_pool_size | default "30" }}

# The pool size limit for connections expiration policy (integer value)
# from .default.oslo.messaging.conn_pool_min_size
{{ if not .default.oslo.messaging.conn_pool_min_size }}#{{ end }}conn_pool_min_size = {{ .default.oslo.messaging.conn_pool_min_size | default "2" }}

# The time-to-live in sec of idle connections in the pool (integer value)
# from .default.oslo.messaging.conn_pool_ttl
{{ if not .default.oslo.messaging.conn_pool_ttl }}#{{ end }}conn_pool_ttl = {{ .default.oslo.messaging.conn_pool_ttl | default "1200" }}

# ZeroMQ bind address. Should be a wildcard (*), an ethernet interface, or IP.
# The "host" option should point or resolve to this address. (string value)
# Deprecated group/name - [DEFAULT]/rpc_zmq_bind_address
# from .default.oslo.messaging.rpc_zmq_bind_address
{{ if not .default.oslo.messaging.rpc_zmq_bind_address }}#{{ end }}rpc_zmq_bind_address = {{ .default.oslo.messaging.rpc_zmq_bind_address | default "*" }}

# MatchMaker driver. (string value)
# Allowed values: redis, dummy
# Deprecated group/name - [DEFAULT]/rpc_zmq_matchmaker
# from .default.oslo.messaging.rpc_zmq_matchmaker
{{ if not .default.oslo.messaging.rpc_zmq_matchmaker }}#{{ end }}rpc_zmq_matchmaker = {{ .default.oslo.messaging.rpc_zmq_matchmaker | default "redis" }}

# Number of ZeroMQ contexts, defaults to 1. (integer value)
# Deprecated group/name - [DEFAULT]/rpc_zmq_contexts
# from .default.oslo.messaging.rpc_zmq_contexts
{{ if not .default.oslo.messaging.rpc_zmq_contexts }}#{{ end }}rpc_zmq_contexts = {{ .default.oslo.messaging.rpc_zmq_contexts | default "1" }}

# Maximum number of ingress messages to locally buffer per topic. Default is
# unlimited. (integer value)
# Deprecated group/name - [DEFAULT]/rpc_zmq_topic_backlog
# from .default.oslo.messaging.rpc_zmq_topic_backlog
{{ if not .default.oslo.messaging.rpc_zmq_topic_backlog }}#{{ end }}rpc_zmq_topic_backlog = {{ .default.oslo.messaging.rpc_zmq_topic_backlog | default "<None>" }}

# Directory for holding IPC sockets. (string value)
# Deprecated group/name - [DEFAULT]/rpc_zmq_ipc_dir
# from .default.oslo.messaging.rpc_zmq_ipc_dir
{{ if not .default.oslo.messaging.rpc_zmq_ipc_dir }}#{{ end }}rpc_zmq_ipc_dir = {{ .default.oslo.messaging.rpc_zmq_ipc_dir | default "/var/run/openstack" }}

# Name of this node. Must be a valid hostname, FQDN, or IP address. Must match
# "host" option, if running Nova. (string value)
# Deprecated group/name - [DEFAULT]/rpc_zmq_host
# from .default.oslo.messaging.rpc_zmq_host
{{ if not .default.oslo.messaging.rpc_zmq_host }}#{{ end }}rpc_zmq_host = {{ .default.oslo.messaging.rpc_zmq_host | default "localhost" }}

# Seconds to wait before a cast expires (TTL). The default value of -1
# specifies an infinite linger period. The value of 0 specifies no linger
# period. Pending messages shall be discarded immediately when the socket is
# closed. Only supported by impl_zmq. (integer value)
# Deprecated group/name - [DEFAULT]/rpc_cast_timeout
# from .default.oslo.messaging.rpc_cast_timeout
{{ if not .default.oslo.messaging.rpc_cast_timeout }}#{{ end }}rpc_cast_timeout = {{ .default.oslo.messaging.rpc_cast_timeout | default "-1" }}

# The default number of seconds that poll should wait. Poll raises timeout
# exception when timeout expired. (integer value)
# Deprecated group/name - [DEFAULT]/rpc_poll_timeout
# from .default.oslo.messaging.rpc_poll_timeout
{{ if not .default.oslo.messaging.rpc_poll_timeout }}#{{ end }}rpc_poll_timeout = {{ .default.oslo.messaging.rpc_poll_timeout | default "1" }}

# Expiration timeout in seconds of a name service record about existing target
# ( < 0 means no timeout). (integer value)
# Deprecated group/name - [DEFAULT]/zmq_target_expire
# from .default.oslo.messaging.zmq_target_expire
{{ if not .default.oslo.messaging.zmq_target_expire }}#{{ end }}zmq_target_expire = {{ .default.oslo.messaging.zmq_target_expire | default "300" }}

# Update period in seconds of a name service record about existing target.
# (integer value)
# Deprecated group/name - [DEFAULT]/zmq_target_update
# from .default.oslo.messaging.zmq_target_update
{{ if not .default.oslo.messaging.zmq_target_update }}#{{ end }}zmq_target_update = {{ .default.oslo.messaging.zmq_target_update | default "180" }}

# Use PUB/SUB pattern for fanout methods. PUB/SUB always uses proxy. (boolean
# value)
# Deprecated group/name - [DEFAULT]/use_pub_sub
# from .default.oslo.messaging.use_pub_sub
{{ if not .default.oslo.messaging.use_pub_sub }}#{{ end }}use_pub_sub = {{ .default.oslo.messaging.use_pub_sub | default "true" }}

# Use ROUTER remote proxy. (boolean value)
# Deprecated group/name - [DEFAULT]/use_router_proxy
# from .default.oslo.messaging.use_router_proxy
{{ if not .default.oslo.messaging.use_router_proxy }}#{{ end }}use_router_proxy = {{ .default.oslo.messaging.use_router_proxy | default "true" }}

# Minimal port number for random ports range. (port value)
# Minimum value: 0
# Maximum value: 65535
# Deprecated group/name - [DEFAULT]/rpc_zmq_min_port
# from .default.oslo.messaging.rpc_zmq_min_port
{{ if not .default.oslo.messaging.rpc_zmq_min_port }}#{{ end }}rpc_zmq_min_port = {{ .default.oslo.messaging.rpc_zmq_min_port | default "49153" }}

# Maximal port number for random ports range. (integer value)
# Minimum value: 1
# Maximum value: 65536
# Deprecated group/name - [DEFAULT]/rpc_zmq_max_port
# from .default.oslo.messaging.rpc_zmq_max_port
{{ if not .default.oslo.messaging.rpc_zmq_max_port }}#{{ end }}rpc_zmq_max_port = {{ .default.oslo.messaging.rpc_zmq_max_port | default "65536" }}

# Number of retries to find free port number before fail with ZMQBindError.
# (integer value)
# Deprecated group/name - [DEFAULT]/rpc_zmq_bind_port_retries
# from .default.oslo.messaging.rpc_zmq_bind_port_retries
{{ if not .default.oslo.messaging.rpc_zmq_bind_port_retries }}#{{ end }}rpc_zmq_bind_port_retries = {{ .default.oslo.messaging.rpc_zmq_bind_port_retries | default "100" }}

# Default serialization mechanism for serializing/deserializing
# outgoing/incoming messages (string value)
# Allowed values: json, msgpack
# Deprecated group/name - [DEFAULT]/rpc_zmq_serialization
# from .default.oslo.messaging.rpc_zmq_serialization
{{ if not .default.oslo.messaging.rpc_zmq_serialization }}#{{ end }}rpc_zmq_serialization = {{ .default.oslo.messaging.rpc_zmq_serialization | default "json" }}

# This option configures round-robin mode in zmq socket. True means not keeping
# a queue when server side disconnects. False means to keep queue and messages
# even if server is disconnected, when the server appears we send all
# accumulated messages to it. (boolean value)
# from .default.oslo.messaging.zmq_immediate
{{ if not .default.oslo.messaging.zmq_immediate }}#{{ end }}zmq_immediate = {{ .default.oslo.messaging.zmq_immediate | default "false" }}

# Size of executor thread pool. (integer value)
# Deprecated group/name - [DEFAULT]/rpc_thread_pool_size
# from .default.oslo.messaging.executor_thread_pool_size
{{ if not .default.oslo.messaging.executor_thread_pool_size }}#{{ end }}executor_thread_pool_size = {{ .default.oslo.messaging.executor_thread_pool_size | default "64" }}

# Seconds to wait for a response from a call. (integer value)
# from .default.oslo.messaging.rpc_response_timeout
{{ if not .default.oslo.messaging.rpc_response_timeout }}#{{ end }}rpc_response_timeout = {{ .default.oslo.messaging.rpc_response_timeout | default "60" }}

# A URL representing the messaging driver to use and its full configuration.
# (string value)
# from .default.oslo.messaging.transport_url
{{ if not .default.oslo.messaging.transport_url }}#{{ end }}transport_url = {{ .default.oslo.messaging.transport_url | default "<None>" }}

# DEPRECATED: The messaging driver to use, defaults to rabbit. Other drivers
# include amqp and zmq. (string value)
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# Reason: Replaced by [DEFAULT]/transport_url
# from .default.oslo.messaging.rpc_backend
{{ if not .default.oslo.messaging.rpc_backend }}#{{ end }}rpc_backend = {{ .default.oslo.messaging.rpc_backend | default "rabbit" }}

# The default exchange under which topics are scoped. May be overridden by an
# exchange name specified in the transport_url option. (string value)
# from .default.oslo.messaging.control_exchange
{{ if not .default.oslo.messaging.control_exchange }}#{{ end }}control_exchange = {{ .default.oslo.messaging.control_exchange | default "openstack" }}

#
# From oslo.service.periodic_task
#

# Some periodic tasks can be run in a separate process. Should we run them
# here? (boolean value)
# from .default.oslo.service.periodic_task.run_external_periodic_tasks
{{ if not .default.oslo.service.periodic_task.run_external_periodic_tasks }}#{{ end }}run_external_periodic_tasks = {{ .default.oslo.service.periodic_task.run_external_periodic_tasks | default "true" }}

#
# From oslo.service.service
#

# Enable eventlet backdoor.  Acceptable values are 0, <port>, and
# <start>:<end>, where 0 results in listening on a random tcp port number;
# <port> results in listening on the specified port number (and not enabling
# backdoor if that port is in use); and <start>:<end> results in listening on
# the smallest unused port number within the specified range of port numbers.
# The chosen port is displayed in the service's log file. (string value)
# from .default.oslo.service.service.backdoor_port
{{ if not .default.oslo.service.service.backdoor_port }}#{{ end }}backdoor_port = {{ .default.oslo.service.service.backdoor_port | default "<None>" }}

# Enable eventlet backdoor, using the provided path as a unix socket that can
# receive connections. This option is mutually exclusive with 'backdoor_port'
# in that only one should be provided. If both are provided then the existence
# of this option overrides the usage of that option. (string value)
# from .default.oslo.service.service.backdoor_socket
{{ if not .default.oslo.service.service.backdoor_socket }}#{{ end }}backdoor_socket = {{ .default.oslo.service.service.backdoor_socket | default "<None>" }}

# Enables or disables logging values of all registered options when starting a
# service (at DEBUG level). (boolean value)
# from .default.oslo.service.service.log_options
{{ if not .default.oslo.service.service.log_options }}#{{ end }}log_options = {{ .default.oslo.service.service.log_options | default "true" }}

# Specify a timeout after which a gracefully shutdown server will exit. Zero
# value means endless wait. (integer value)
# from .default.oslo.service.service.graceful_shutdown_timeout
{{ if not .default.oslo.service.service.graceful_shutdown_timeout }}#{{ end }}graceful_shutdown_timeout = {{ .default.oslo.service.service.graceful_shutdown_timeout | default "60" }}


[auth_password]

#
# From heat.common.config
#

# Allow orchestration of multiple clouds. (boolean value)
# from .auth_password.heat.common.config.multi_cloud
{{ if not .auth_password.heat.common.config.multi_cloud }}#{{ end }}multi_cloud = {{ .auth_password.heat.common.config.multi_cloud | default "false" }}

# Allowed keystone endpoints for auth_uri when multi_cloud is enabled. At least
# one endpoint needs to be specified. (list value)
# from .auth_password.heat.common.config.allowed_auth_uris
{{ if not .auth_password.heat.common.config.allowed_auth_uris }}#{{ end }}allowed_auth_uris = {{ .auth_password.heat.common.config.allowed_auth_uris | default "" }}


[clients]

#
# From heat.common.config
#

# Type of endpoint in Identity service catalog to use for communication with
# the OpenStack service. (string value)
# from .clients.heat.common.config.endpoint_type
{{ if not .clients.heat.common.config.endpoint_type }}#{{ end }}endpoint_type = {{ .clients.heat.common.config.endpoint_type | default "publicURL" }}

# Optional CA cert file to use in SSL connections. (string value)
# from .clients.heat.common.config.ca_file
{{ if not .clients.heat.common.config.ca_file }}#{{ end }}ca_file = {{ .clients.heat.common.config.ca_file | default "<None>" }}

# Optional PEM-formatted certificate chain file. (string value)
# from .clients.heat.common.config.cert_file
{{ if not .clients.heat.common.config.cert_file }}#{{ end }}cert_file = {{ .clients.heat.common.config.cert_file | default "<None>" }}

# Optional PEM-formatted file that contains the private key. (string value)
# from .clients.heat.common.config.key_file
{{ if not .clients.heat.common.config.key_file }}#{{ end }}key_file = {{ .clients.heat.common.config.key_file | default "<None>" }}

# If set, then the server's certificate will not be verified. (boolean value)
# from .clients.heat.common.config.insecure
{{ if not .clients.heat.common.config.insecure }}#{{ end }}insecure = {{ .clients.heat.common.config.insecure | default "false" }}


[clients_aodh]

#
# From heat.common.config
#

# Type of endpoint in Identity service catalog to use for communication with
# the OpenStack service. (string value)
# from .clients_aodh.heat.common.config.endpoint_type
{{ if not .clients_aodh.heat.common.config.endpoint_type }}#{{ end }}endpoint_type = {{ .clients_aodh.heat.common.config.endpoint_type | default "<None>" }}

# Optional CA cert file to use in SSL connections. (string value)
# from .clients_aodh.heat.common.config.ca_file
{{ if not .clients_aodh.heat.common.config.ca_file }}#{{ end }}ca_file = {{ .clients_aodh.heat.common.config.ca_file | default "<None>" }}

# Optional PEM-formatted certificate chain file. (string value)
# from .clients_aodh.heat.common.config.cert_file
{{ if not .clients_aodh.heat.common.config.cert_file }}#{{ end }}cert_file = {{ .clients_aodh.heat.common.config.cert_file | default "<None>" }}

# Optional PEM-formatted file that contains the private key. (string value)
# from .clients_aodh.heat.common.config.key_file
{{ if not .clients_aodh.heat.common.config.key_file }}#{{ end }}key_file = {{ .clients_aodh.heat.common.config.key_file | default "<None>" }}

# If set, then the server's certificate will not be verified. (boolean value)
# from .clients_aodh.heat.common.config.insecure
{{ if not .clients_aodh.heat.common.config.insecure }}#{{ end }}insecure = {{ .clients_aodh.heat.common.config.insecure | default "<None>" }}


[clients_barbican]

#
# From heat.common.config
#

# Type of endpoint in Identity service catalog to use for communication with
# the OpenStack service. (string value)
# from .clients_barbican.heat.common.config.endpoint_type
{{ if not .clients_barbican.heat.common.config.endpoint_type }}#{{ end }}endpoint_type = {{ .clients_barbican.heat.common.config.endpoint_type | default "<None>" }}

# Optional CA cert file to use in SSL connections. (string value)
# from .clients_barbican.heat.common.config.ca_file
{{ if not .clients_barbican.heat.common.config.ca_file }}#{{ end }}ca_file = {{ .clients_barbican.heat.common.config.ca_file | default "<None>" }}

# Optional PEM-formatted certificate chain file. (string value)
# from .clients_barbican.heat.common.config.cert_file
{{ if not .clients_barbican.heat.common.config.cert_file }}#{{ end }}cert_file = {{ .clients_barbican.heat.common.config.cert_file | default "<None>" }}

# Optional PEM-formatted file that contains the private key. (string value)
# from .clients_barbican.heat.common.config.key_file
{{ if not .clients_barbican.heat.common.config.key_file }}#{{ end }}key_file = {{ .clients_barbican.heat.common.config.key_file | default "<None>" }}

# If set, then the server's certificate will not be verified. (boolean value)
# from .clients_barbican.heat.common.config.insecure
{{ if not .clients_barbican.heat.common.config.insecure }}#{{ end }}insecure = {{ .clients_barbican.heat.common.config.insecure | default "<None>" }}


[clients_ceilometer]

#
# From heat.common.config
#

# Type of endpoint in Identity service catalog to use for communication with
# the OpenStack service. (string value)
# from .clients_ceilometer.heat.common.config.endpoint_type
{{ if not .clients_ceilometer.heat.common.config.endpoint_type }}#{{ end }}endpoint_type = {{ .clients_ceilometer.heat.common.config.endpoint_type | default "<None>" }}

# Optional CA cert file to use in SSL connections. (string value)
# from .clients_ceilometer.heat.common.config.ca_file
{{ if not .clients_ceilometer.heat.common.config.ca_file }}#{{ end }}ca_file = {{ .clients_ceilometer.heat.common.config.ca_file | default "<None>" }}

# Optional PEM-formatted certificate chain file. (string value)
# from .clients_ceilometer.heat.common.config.cert_file
{{ if not .clients_ceilometer.heat.common.config.cert_file }}#{{ end }}cert_file = {{ .clients_ceilometer.heat.common.config.cert_file | default "<None>" }}

# Optional PEM-formatted file that contains the private key. (string value)
# from .clients_ceilometer.heat.common.config.key_file
{{ if not .clients_ceilometer.heat.common.config.key_file }}#{{ end }}key_file = {{ .clients_ceilometer.heat.common.config.key_file | default "<None>" }}

# If set, then the server's certificate will not be verified. (boolean value)
# from .clients_ceilometer.heat.common.config.insecure
{{ if not .clients_ceilometer.heat.common.config.insecure }}#{{ end }}insecure = {{ .clients_ceilometer.heat.common.config.insecure | default "<None>" }}


[clients_cinder]

#
# From heat.common.config
#

# Type of endpoint in Identity service catalog to use for communication with
# the OpenStack service. (string value)
# from .clients_cinder.heat.common.config.endpoint_type
{{ if not .clients_cinder.heat.common.config.endpoint_type }}#{{ end }}endpoint_type = {{ .clients_cinder.heat.common.config.endpoint_type | default "<None>" }}

# Optional CA cert file to use in SSL connections. (string value)
# from .clients_cinder.heat.common.config.ca_file
{{ if not .clients_cinder.heat.common.config.ca_file }}#{{ end }}ca_file = {{ .clients_cinder.heat.common.config.ca_file | default "<None>" }}

# Optional PEM-formatted certificate chain file. (string value)
# from .clients_cinder.heat.common.config.cert_file
{{ if not .clients_cinder.heat.common.config.cert_file }}#{{ end }}cert_file = {{ .clients_cinder.heat.common.config.cert_file | default "<None>" }}

# Optional PEM-formatted file that contains the private key. (string value)
# from .clients_cinder.heat.common.config.key_file
{{ if not .clients_cinder.heat.common.config.key_file }}#{{ end }}key_file = {{ .clients_cinder.heat.common.config.key_file | default "<None>" }}

# If set, then the server's certificate will not be verified. (boolean value)
# from .clients_cinder.heat.common.config.insecure
{{ if not .clients_cinder.heat.common.config.insecure }}#{{ end }}insecure = {{ .clients_cinder.heat.common.config.insecure | default "<None>" }}

# Allow client's debug log output. (boolean value)
# from .clients_cinder.heat.common.config.http_log_debug
{{ if not .clients_cinder.heat.common.config.http_log_debug }}#{{ end }}http_log_debug = {{ .clients_cinder.heat.common.config.http_log_debug | default "false" }}


[clients_designate]

#
# From heat.common.config
#

# Type of endpoint in Identity service catalog to use for communication with
# the OpenStack service. (string value)
# from .clients_designate.heat.common.config.endpoint_type
{{ if not .clients_designate.heat.common.config.endpoint_type }}#{{ end }}endpoint_type = {{ .clients_designate.heat.common.config.endpoint_type | default "<None>" }}

# Optional CA cert file to use in SSL connections. (string value)
# from .clients_designate.heat.common.config.ca_file
{{ if not .clients_designate.heat.common.config.ca_file }}#{{ end }}ca_file = {{ .clients_designate.heat.common.config.ca_file | default "<None>" }}

# Optional PEM-formatted certificate chain file. (string value)
# from .clients_designate.heat.common.config.cert_file
{{ if not .clients_designate.heat.common.config.cert_file }}#{{ end }}cert_file = {{ .clients_designate.heat.common.config.cert_file | default "<None>" }}

# Optional PEM-formatted file that contains the private key. (string value)
# from .clients_designate.heat.common.config.key_file
{{ if not .clients_designate.heat.common.config.key_file }}#{{ end }}key_file = {{ .clients_designate.heat.common.config.key_file | default "<None>" }}

# If set, then the server's certificate will not be verified. (boolean value)
# from .clients_designate.heat.common.config.insecure
{{ if not .clients_designate.heat.common.config.insecure }}#{{ end }}insecure = {{ .clients_designate.heat.common.config.insecure | default "<None>" }}


[clients_glance]

#
# From heat.common.config
#

# Type of endpoint in Identity service catalog to use for communication with
# the OpenStack service. (string value)
# from .clients_glance.heat.common.config.endpoint_type
{{ if not .clients_glance.heat.common.config.endpoint_type }}#{{ end }}endpoint_type = {{ .clients_glance.heat.common.config.endpoint_type | default "<None>" }}

# Optional CA cert file to use in SSL connections. (string value)
# from .clients_glance.heat.common.config.ca_file
{{ if not .clients_glance.heat.common.config.ca_file }}#{{ end }}ca_file = {{ .clients_glance.heat.common.config.ca_file | default "<None>" }}

# Optional PEM-formatted certificate chain file. (string value)
# from .clients_glance.heat.common.config.cert_file
{{ if not .clients_glance.heat.common.config.cert_file }}#{{ end }}cert_file = {{ .clients_glance.heat.common.config.cert_file | default "<None>" }}

# Optional PEM-formatted file that contains the private key. (string value)
# from .clients_glance.heat.common.config.key_file
{{ if not .clients_glance.heat.common.config.key_file }}#{{ end }}key_file = {{ .clients_glance.heat.common.config.key_file | default "<None>" }}

# If set, then the server's certificate will not be verified. (boolean value)
# from .clients_glance.heat.common.config.insecure
{{ if not .clients_glance.heat.common.config.insecure }}#{{ end }}insecure = {{ .clients_glance.heat.common.config.insecure | default "<None>" }}


[clients_heat]

#
# From heat.common.config
#

# Type of endpoint in Identity service catalog to use for communication with
# the OpenStack service. (string value)
# from .clients_heat.heat.common.config.endpoint_type
{{ if not .clients_heat.heat.common.config.endpoint_type }}#{{ end }}endpoint_type = {{ .clients_heat.heat.common.config.endpoint_type | default "<None>" }}

# Optional CA cert file to use in SSL connections. (string value)
# from .clients_heat.heat.common.config.ca_file
{{ if not .clients_heat.heat.common.config.ca_file }}#{{ end }}ca_file = {{ .clients_heat.heat.common.config.ca_file | default "<None>" }}

# Optional PEM-formatted certificate chain file. (string value)
# from .clients_heat.heat.common.config.cert_file
{{ if not .clients_heat.heat.common.config.cert_file }}#{{ end }}cert_file = {{ .clients_heat.heat.common.config.cert_file | default "<None>" }}

# Optional PEM-formatted file that contains the private key. (string value)
# from .clients_heat.heat.common.config.key_file
{{ if not .clients_heat.heat.common.config.key_file }}#{{ end }}key_file = {{ .clients_heat.heat.common.config.key_file | default "<None>" }}

# If set, then the server's certificate will not be verified. (boolean value)
# from .clients_heat.heat.common.config.insecure
{{ if not .clients_heat.heat.common.config.insecure }}#{{ end }}insecure = {{ .clients_heat.heat.common.config.insecure | default "<None>" }}

# Optional heat url in format like http://0.0.0.0:8004/v1/%(tenant_id)s.
# (string value)
# from .clients_heat.heat.common.config.url
{{ if not .clients_heat.heat.common.config.url }}#{{ end }}url = {{ .clients_heat.heat.common.config.url | default "" }}


[clients_keystone]

#
# From heat.common.config
#

# Type of endpoint in Identity service catalog to use for communication with
# the OpenStack service. (string value)
# from .clients_keystone.heat.common.config.endpoint_type
{{ if not .clients_keystone.heat.common.config.endpoint_type }}#{{ end }}endpoint_type = {{ .clients_keystone.heat.common.config.endpoint_type | default "<None>" }}

# Optional CA cert file to use in SSL connections. (string value)
# from .clients_keystone.heat.common.config.ca_file
{{ if not .clients_keystone.heat.common.config.ca_file }}#{{ end }}ca_file = {{ .clients_keystone.heat.common.config.ca_file | default "<None>" }}

# Optional PEM-formatted certificate chain file. (string value)
# from .clients_keystone.heat.common.config.cert_file
{{ if not .clients_keystone.heat.common.config.cert_file }}#{{ end }}cert_file = {{ .clients_keystone.heat.common.config.cert_file | default "<None>" }}

# Optional PEM-formatted file that contains the private key. (string value)
# from .clients_keystone.heat.common.config.key_file
{{ if not .clients_keystone.heat.common.config.key_file }}#{{ end }}key_file = {{ .clients_keystone.heat.common.config.key_file | default "<None>" }}

# If set, then the server's certificate will not be verified. (boolean value)
# from .clients_keystone.heat.common.config.insecure
{{ if not .clients_keystone.heat.common.config.insecure }}#{{ end }}insecure = {{ .clients_keystone.heat.common.config.insecure | default "<None>" }}

# Unversioned keystone url in format like http://0.0.0.0:5000. (string value)
# from .clients_keystone.heat.common.config.auth_uri
{{ if not .clients_keystone.heat.common.config.auth_uri }}#{{ end }}auth_uri = {{ .clients_keystone.heat.common.config.auth_uri | default "" }}


[clients_magnum]

#
# From heat.common.config
#

# Type of endpoint in Identity service catalog to use for communication with
# the OpenStack service. (string value)
# from .clients_magnum.heat.common.config.endpoint_type
{{ if not .clients_magnum.heat.common.config.endpoint_type }}#{{ end }}endpoint_type = {{ .clients_magnum.heat.common.config.endpoint_type | default "<None>" }}

# Optional CA cert file to use in SSL connections. (string value)
# from .clients_magnum.heat.common.config.ca_file
{{ if not .clients_magnum.heat.common.config.ca_file }}#{{ end }}ca_file = {{ .clients_magnum.heat.common.config.ca_file | default "<None>" }}

# Optional PEM-formatted certificate chain file. (string value)
# from .clients_magnum.heat.common.config.cert_file
{{ if not .clients_magnum.heat.common.config.cert_file }}#{{ end }}cert_file = {{ .clients_magnum.heat.common.config.cert_file | default "<None>" }}

# Optional PEM-formatted file that contains the private key. (string value)
# from .clients_magnum.heat.common.config.key_file
{{ if not .clients_magnum.heat.common.config.key_file }}#{{ end }}key_file = {{ .clients_magnum.heat.common.config.key_file | default "<None>" }}

# If set, then the server's certificate will not be verified. (boolean value)
# from .clients_magnum.heat.common.config.insecure
{{ if not .clients_magnum.heat.common.config.insecure }}#{{ end }}insecure = {{ .clients_magnum.heat.common.config.insecure | default "<None>" }}


[clients_manila]

#
# From heat.common.config
#

# Type of endpoint in Identity service catalog to use for communication with
# the OpenStack service. (string value)
# from .clients_manila.heat.common.config.endpoint_type
{{ if not .clients_manila.heat.common.config.endpoint_type }}#{{ end }}endpoint_type = {{ .clients_manila.heat.common.config.endpoint_type | default "<None>" }}

# Optional CA cert file to use in SSL connections. (string value)
# from .clients_manila.heat.common.config.ca_file
{{ if not .clients_manila.heat.common.config.ca_file }}#{{ end }}ca_file = {{ .clients_manila.heat.common.config.ca_file | default "<None>" }}

# Optional PEM-formatted certificate chain file. (string value)
# from .clients_manila.heat.common.config.cert_file
{{ if not .clients_manila.heat.common.config.cert_file }}#{{ end }}cert_file = {{ .clients_manila.heat.common.config.cert_file | default "<None>" }}

# Optional PEM-formatted file that contains the private key. (string value)
# from .clients_manila.heat.common.config.key_file
{{ if not .clients_manila.heat.common.config.key_file }}#{{ end }}key_file = {{ .clients_manila.heat.common.config.key_file | default "<None>" }}

# If set, then the server's certificate will not be verified. (boolean value)
# from .clients_manila.heat.common.config.insecure
{{ if not .clients_manila.heat.common.config.insecure }}#{{ end }}insecure = {{ .clients_manila.heat.common.config.insecure | default "<None>" }}


[clients_mistral]

#
# From heat.common.config
#

# Type of endpoint in Identity service catalog to use for communication with
# the OpenStack service. (string value)
# from .clients_mistral.heat.common.config.endpoint_type
{{ if not .clients_mistral.heat.common.config.endpoint_type }}#{{ end }}endpoint_type = {{ .clients_mistral.heat.common.config.endpoint_type | default "<None>" }}

# Optional CA cert file to use in SSL connections. (string value)
# from .clients_mistral.heat.common.config.ca_file
{{ if not .clients_mistral.heat.common.config.ca_file }}#{{ end }}ca_file = {{ .clients_mistral.heat.common.config.ca_file | default "<None>" }}

# Optional PEM-formatted certificate chain file. (string value)
# from .clients_mistral.heat.common.config.cert_file
{{ if not .clients_mistral.heat.common.config.cert_file }}#{{ end }}cert_file = {{ .clients_mistral.heat.common.config.cert_file | default "<None>" }}

# Optional PEM-formatted file that contains the private key. (string value)
# from .clients_mistral.heat.common.config.key_file
{{ if not .clients_mistral.heat.common.config.key_file }}#{{ end }}key_file = {{ .clients_mistral.heat.common.config.key_file | default "<None>" }}

# If set, then the server's certificate will not be verified. (boolean value)
# from .clients_mistral.heat.common.config.insecure
{{ if not .clients_mistral.heat.common.config.insecure }}#{{ end }}insecure = {{ .clients_mistral.heat.common.config.insecure | default "<None>" }}


[clients_monasca]

#
# From heat.common.config
#

# Type of endpoint in Identity service catalog to use for communication with
# the OpenStack service. (string value)
# from .clients_monasca.heat.common.config.endpoint_type
{{ if not .clients_monasca.heat.common.config.endpoint_type }}#{{ end }}endpoint_type = {{ .clients_monasca.heat.common.config.endpoint_type | default "<None>" }}

# Optional CA cert file to use in SSL connections. (string value)
# from .clients_monasca.heat.common.config.ca_file
{{ if not .clients_monasca.heat.common.config.ca_file }}#{{ end }}ca_file = {{ .clients_monasca.heat.common.config.ca_file | default "<None>" }}

# Optional PEM-formatted certificate chain file. (string value)
# from .clients_monasca.heat.common.config.cert_file
{{ if not .clients_monasca.heat.common.config.cert_file }}#{{ end }}cert_file = {{ .clients_monasca.heat.common.config.cert_file | default "<None>" }}

# Optional PEM-formatted file that contains the private key. (string value)
# from .clients_monasca.heat.common.config.key_file
{{ if not .clients_monasca.heat.common.config.key_file }}#{{ end }}key_file = {{ .clients_monasca.heat.common.config.key_file | default "<None>" }}

# If set, then the server's certificate will not be verified. (boolean value)
# from .clients_monasca.heat.common.config.insecure
{{ if not .clients_monasca.heat.common.config.insecure }}#{{ end }}insecure = {{ .clients_monasca.heat.common.config.insecure | default "<None>" }}


[clients_neutron]

#
# From heat.common.config
#

# Type of endpoint in Identity service catalog to use for communication with
# the OpenStack service. (string value)
# from .clients_neutron.heat.common.config.endpoint_type
{{ if not .clients_neutron.heat.common.config.endpoint_type }}#{{ end }}endpoint_type = {{ .clients_neutron.heat.common.config.endpoint_type | default "<None>" }}

# Optional CA cert file to use in SSL connections. (string value)
# from .clients_neutron.heat.common.config.ca_file
{{ if not .clients_neutron.heat.common.config.ca_file }}#{{ end }}ca_file = {{ .clients_neutron.heat.common.config.ca_file | default "<None>" }}

# Optional PEM-formatted certificate chain file. (string value)
# from .clients_neutron.heat.common.config.cert_file
{{ if not .clients_neutron.heat.common.config.cert_file }}#{{ end }}cert_file = {{ .clients_neutron.heat.common.config.cert_file | default "<None>" }}

# Optional PEM-formatted file that contains the private key. (string value)
# from .clients_neutron.heat.common.config.key_file
{{ if not .clients_neutron.heat.common.config.key_file }}#{{ end }}key_file = {{ .clients_neutron.heat.common.config.key_file | default "<None>" }}

# If set, then the server's certificate will not be verified. (boolean value)
# from .clients_neutron.heat.common.config.insecure
{{ if not .clients_neutron.heat.common.config.insecure }}#{{ end }}insecure = {{ .clients_neutron.heat.common.config.insecure | default "<None>" }}


[clients_nova]

#
# From heat.common.config
#

# Type of endpoint in Identity service catalog to use for communication with
# the OpenStack service. (string value)
# from .clients_nova.heat.common.config.endpoint_type
{{ if not .clients_nova.heat.common.config.endpoint_type }}#{{ end }}endpoint_type = {{ .clients_nova.heat.common.config.endpoint_type | default "<None>" }}

# Optional CA cert file to use in SSL connections. (string value)
# from .clients_nova.heat.common.config.ca_file
{{ if not .clients_nova.heat.common.config.ca_file }}#{{ end }}ca_file = {{ .clients_nova.heat.common.config.ca_file | default "<None>" }}

# Optional PEM-formatted certificate chain file. (string value)
# from .clients_nova.heat.common.config.cert_file
{{ if not .clients_nova.heat.common.config.cert_file }}#{{ end }}cert_file = {{ .clients_nova.heat.common.config.cert_file | default "<None>" }}

# Optional PEM-formatted file that contains the private key. (string value)
# from .clients_nova.heat.common.config.key_file
{{ if not .clients_nova.heat.common.config.key_file }}#{{ end }}key_file = {{ .clients_nova.heat.common.config.key_file | default "<None>" }}

# If set, then the server's certificate will not be verified. (boolean value)
# from .clients_nova.heat.common.config.insecure
{{ if not .clients_nova.heat.common.config.insecure }}#{{ end }}insecure = {{ .clients_nova.heat.common.config.insecure | default "<None>" }}

# Allow client's debug log output. (boolean value)
# from .clients_nova.heat.common.config.http_log_debug
{{ if not .clients_nova.heat.common.config.http_log_debug }}#{{ end }}http_log_debug = {{ .clients_nova.heat.common.config.http_log_debug | default "false" }}


[clients_sahara]

#
# From heat.common.config
#

# Type of endpoint in Identity service catalog to use for communication with
# the OpenStack service. (string value)
# from .clients_sahara.heat.common.config.endpoint_type
{{ if not .clients_sahara.heat.common.config.endpoint_type }}#{{ end }}endpoint_type = {{ .clients_sahara.heat.common.config.endpoint_type | default "<None>" }}

# Optional CA cert file to use in SSL connections. (string value)
# from .clients_sahara.heat.common.config.ca_file
{{ if not .clients_sahara.heat.common.config.ca_file }}#{{ end }}ca_file = {{ .clients_sahara.heat.common.config.ca_file | default "<None>" }}

# Optional PEM-formatted certificate chain file. (string value)
# from .clients_sahara.heat.common.config.cert_file
{{ if not .clients_sahara.heat.common.config.cert_file }}#{{ end }}cert_file = {{ .clients_sahara.heat.common.config.cert_file | default "<None>" }}

# Optional PEM-formatted file that contains the private key. (string value)
# from .clients_sahara.heat.common.config.key_file
{{ if not .clients_sahara.heat.common.config.key_file }}#{{ end }}key_file = {{ .clients_sahara.heat.common.config.key_file | default "<None>" }}

# If set, then the server's certificate will not be verified. (boolean value)
# from .clients_sahara.heat.common.config.insecure
{{ if not .clients_sahara.heat.common.config.insecure }}#{{ end }}insecure = {{ .clients_sahara.heat.common.config.insecure | default "<None>" }}


[clients_senlin]

#
# From heat.common.config
#

# Type of endpoint in Identity service catalog to use for communication with
# the OpenStack service. (string value)
# from .clients_senlin.heat.common.config.endpoint_type
{{ if not .clients_senlin.heat.common.config.endpoint_type }}#{{ end }}endpoint_type = {{ .clients_senlin.heat.common.config.endpoint_type | default "<None>" }}

# Optional CA cert file to use in SSL connections. (string value)
# from .clients_senlin.heat.common.config.ca_file
{{ if not .clients_senlin.heat.common.config.ca_file }}#{{ end }}ca_file = {{ .clients_senlin.heat.common.config.ca_file | default "<None>" }}

# Optional PEM-formatted certificate chain file. (string value)
# from .clients_senlin.heat.common.config.cert_file
{{ if not .clients_senlin.heat.common.config.cert_file }}#{{ end }}cert_file = {{ .clients_senlin.heat.common.config.cert_file | default "<None>" }}

# Optional PEM-formatted file that contains the private key. (string value)
# from .clients_senlin.heat.common.config.key_file
{{ if not .clients_senlin.heat.common.config.key_file }}#{{ end }}key_file = {{ .clients_senlin.heat.common.config.key_file | default "<None>" }}

# If set, then the server's certificate will not be verified. (boolean value)
# from .clients_senlin.heat.common.config.insecure
{{ if not .clients_senlin.heat.common.config.insecure }}#{{ end }}insecure = {{ .clients_senlin.heat.common.config.insecure | default "<None>" }}


[clients_swift]

#
# From heat.common.config
#

# Type of endpoint in Identity service catalog to use for communication with
# the OpenStack service. (string value)
# from .clients_swift.heat.common.config.endpoint_type
{{ if not .clients_swift.heat.common.config.endpoint_type }}#{{ end }}endpoint_type = {{ .clients_swift.heat.common.config.endpoint_type | default "<None>" }}

# Optional CA cert file to use in SSL connections. (string value)
# from .clients_swift.heat.common.config.ca_file
{{ if not .clients_swift.heat.common.config.ca_file }}#{{ end }}ca_file = {{ .clients_swift.heat.common.config.ca_file | default "<None>" }}

# Optional PEM-formatted certificate chain file. (string value)
# from .clients_swift.heat.common.config.cert_file
{{ if not .clients_swift.heat.common.config.cert_file }}#{{ end }}cert_file = {{ .clients_swift.heat.common.config.cert_file | default "<None>" }}

# Optional PEM-formatted file that contains the private key. (string value)
# from .clients_swift.heat.common.config.key_file
{{ if not .clients_swift.heat.common.config.key_file }}#{{ end }}key_file = {{ .clients_swift.heat.common.config.key_file | default "<None>" }}

# If set, then the server's certificate will not be verified. (boolean value)
# from .clients_swift.heat.common.config.insecure
{{ if not .clients_swift.heat.common.config.insecure }}#{{ end }}insecure = {{ .clients_swift.heat.common.config.insecure | default "<None>" }}


[clients_trove]

#
# From heat.common.config
#

# Type of endpoint in Identity service catalog to use for communication with
# the OpenStack service. (string value)
# from .clients_trove.heat.common.config.endpoint_type
{{ if not .clients_trove.heat.common.config.endpoint_type }}#{{ end }}endpoint_type = {{ .clients_trove.heat.common.config.endpoint_type | default "<None>" }}

# Optional CA cert file to use in SSL connections. (string value)
# from .clients_trove.heat.common.config.ca_file
{{ if not .clients_trove.heat.common.config.ca_file }}#{{ end }}ca_file = {{ .clients_trove.heat.common.config.ca_file | default "<None>" }}

# Optional PEM-formatted certificate chain file. (string value)
# from .clients_trove.heat.common.config.cert_file
{{ if not .clients_trove.heat.common.config.cert_file }}#{{ end }}cert_file = {{ .clients_trove.heat.common.config.cert_file | default "<None>" }}

# Optional PEM-formatted file that contains the private key. (string value)
# from .clients_trove.heat.common.config.key_file
{{ if not .clients_trove.heat.common.config.key_file }}#{{ end }}key_file = {{ .clients_trove.heat.common.config.key_file | default "<None>" }}

# If set, then the server's certificate will not be verified. (boolean value)
# from .clients_trove.heat.common.config.insecure
{{ if not .clients_trove.heat.common.config.insecure }}#{{ end }}insecure = {{ .clients_trove.heat.common.config.insecure | default "<None>" }}


[clients_zaqar]

#
# From heat.common.config
#

# Type of endpoint in Identity service catalog to use for communication with
# the OpenStack service. (string value)
# from .clients_zaqar.heat.common.config.endpoint_type
{{ if not .clients_zaqar.heat.common.config.endpoint_type }}#{{ end }}endpoint_type = {{ .clients_zaqar.heat.common.config.endpoint_type | default "<None>" }}

# Optional CA cert file to use in SSL connections. (string value)
# from .clients_zaqar.heat.common.config.ca_file
{{ if not .clients_zaqar.heat.common.config.ca_file }}#{{ end }}ca_file = {{ .clients_zaqar.heat.common.config.ca_file | default "<None>" }}

# Optional PEM-formatted certificate chain file. (string value)
# from .clients_zaqar.heat.common.config.cert_file
{{ if not .clients_zaqar.heat.common.config.cert_file }}#{{ end }}cert_file = {{ .clients_zaqar.heat.common.config.cert_file | default "<None>" }}

# Optional PEM-formatted file that contains the private key. (string value)
# from .clients_zaqar.heat.common.config.key_file
{{ if not .clients_zaqar.heat.common.config.key_file }}#{{ end }}key_file = {{ .clients_zaqar.heat.common.config.key_file | default "<None>" }}

# If set, then the server's certificate will not be verified. (boolean value)
# from .clients_zaqar.heat.common.config.insecure
{{ if not .clients_zaqar.heat.common.config.insecure }}#{{ end }}insecure = {{ .clients_zaqar.heat.common.config.insecure | default "<None>" }}


[cors]

#
# From oslo.middleware
#

# Indicate whether this resource may be shared with the domain received in the
# requests "origin" header. Format: "<protocol>://<host>[:<port>]", no trailing
# slash. Example: https://horizon.example.com (list value)
# from .cors.oslo.middleware.allowed_origin
{{ if not .cors.oslo.middleware.allowed_origin }}#{{ end }}allowed_origin = {{ .cors.oslo.middleware.allowed_origin | default "<None>" }}

# Indicate that the actual request can include user credentials (boolean value)
# from .cors.oslo.middleware.allow_credentials
{{ if not .cors.oslo.middleware.allow_credentials }}#{{ end }}allow_credentials = {{ .cors.oslo.middleware.allow_credentials | default "true" }}

# Indicate which headers are safe to expose to the API. Defaults to HTTP Simple
# Headers. (list value)
# from .cors.oslo.middleware.expose_headers
{{ if not .cors.oslo.middleware.expose_headers }}#{{ end }}expose_headers = {{ .cors.oslo.middleware.expose_headers | default "X-Auth-Token,X-Subject-Token,X-Service-Token,X-OpenStack-Request-ID" }}

# Maximum cache age of CORS preflight requests. (integer value)
# from .cors.oslo.middleware.max_age
{{ if not .cors.oslo.middleware.max_age }}#{{ end }}max_age = {{ .cors.oslo.middleware.max_age | default "3600" }}

# Indicate which methods can be used during the actual request. (list value)
# from .cors.oslo.middleware.allow_methods
{{ if not .cors.oslo.middleware.allow_methods }}#{{ end }}allow_methods = {{ .cors.oslo.middleware.allow_methods | default "GET,PUT,POST,DELETE,PATCH" }}

# Indicate which header field names may be used during the actual request.
# (list value)
# from .cors.oslo.middleware.allow_headers
{{ if not .cors.oslo.middleware.allow_headers }}#{{ end }}allow_headers = {{ .cors.oslo.middleware.allow_headers | default "X-Auth-Token,X-Identity-Status,X-Roles,X-Service-Catalog,X-User-Id,X-Tenant-Id,X-OpenStack-Request-ID" }}


[cors.subdomain]

#
# From oslo.middleware
#

# Indicate whether this resource may be shared with the domain received in the
# requests "origin" header. Format: "<protocol>://<host>[:<port>]", no trailing
# slash. Example: https://horizon.example.com (list value)
# from .cors.subdomain.oslo.middleware.allowed_origin
{{ if not .cors.subdomain.oslo.middleware.allowed_origin }}#{{ end }}allowed_origin = {{ .cors.subdomain.oslo.middleware.allowed_origin | default "<None>" }}

# Indicate that the actual request can include user credentials (boolean value)
# from .cors.subdomain.oslo.middleware.allow_credentials
{{ if not .cors.subdomain.oslo.middleware.allow_credentials }}#{{ end }}allow_credentials = {{ .cors.subdomain.oslo.middleware.allow_credentials | default "true" }}

# Indicate which headers are safe to expose to the API. Defaults to HTTP Simple
# Headers. (list value)
# from .cors.subdomain.oslo.middleware.expose_headers
{{ if not .cors.subdomain.oslo.middleware.expose_headers }}#{{ end }}expose_headers = {{ .cors.subdomain.oslo.middleware.expose_headers | default "X-Auth-Token,X-Subject-Token,X-Service-Token,X-OpenStack-Request-ID" }}

# Maximum cache age of CORS preflight requests. (integer value)
# from .cors.subdomain.oslo.middleware.max_age
{{ if not .cors.subdomain.oslo.middleware.max_age }}#{{ end }}max_age = {{ .cors.subdomain.oslo.middleware.max_age | default "3600" }}

# Indicate which methods can be used during the actual request. (list value)
# from .cors.subdomain.oslo.middleware.allow_methods
{{ if not .cors.subdomain.oslo.middleware.allow_methods }}#{{ end }}allow_methods = {{ .cors.subdomain.oslo.middleware.allow_methods | default "GET,PUT,POST,DELETE,PATCH" }}

# Indicate which header field names may be used during the actual request.
# (list value)
# from .cors.subdomain.oslo.middleware.allow_headers
{{ if not .cors.subdomain.oslo.middleware.allow_headers }}#{{ end }}allow_headers = {{ .cors.subdomain.oslo.middleware.allow_headers | default "X-Auth-Token,X-Identity-Status,X-Roles,X-Service-Catalog,X-User-Id,X-Tenant-Id,X-OpenStack-Request-ID" }}


[database]

#
# From oslo.db
#

# DEPRECATED: The file name to use with SQLite. (string value)
# Deprecated group/name - [DEFAULT]/sqlite_db
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# Reason: Should use config option connection or slave_connection to connect
# the database.
# from .database.oslo.db.sqlite_db
{{ if not .database.oslo.db.sqlite_db }}#{{ end }}sqlite_db = {{ .database.oslo.db.sqlite_db | default "oslo.sqlite" }}

# If True, SQLite uses synchronous mode. (boolean value)
# Deprecated group/name - [DEFAULT]/sqlite_synchronous
# from .database.oslo.db.sqlite_synchronous
{{ if not .database.oslo.db.sqlite_synchronous }}#{{ end }}sqlite_synchronous = {{ .database.oslo.db.sqlite_synchronous | default "true" }}

# The back end to use for the database. (string value)
# Deprecated group/name - [DEFAULT]/db_backend
# from .database.oslo.db.backend
{{ if not .database.oslo.db.backend }}#{{ end }}backend = {{ .database.oslo.db.backend | default "sqlalchemy" }}

# The SQLAlchemy connection string to use to connect to the database. (string
# value)
# Deprecated group/name - [DEFAULT]/sql_connection
# Deprecated group/name - [DATABASE]/sql_connection
# Deprecated group/name - [sql]/connection
# from .database.oslo.db.connection
{{ if not .database.oslo.db.connection }}#{{ end }}connection = {{ .database.oslo.db.connection | default "<None>" }}

# The SQLAlchemy connection string to use to connect to the slave database.
# (string value)
# from .database.oslo.db.slave_connection
{{ if not .database.oslo.db.slave_connection }}#{{ end }}slave_connection = {{ .database.oslo.db.slave_connection | default "<None>" }}

# The SQL mode to be used for MySQL sessions. This option, including the
# default, overrides any server-set SQL mode. To use whatever SQL mode is set
# by the server configuration, set this to no value. Example: mysql_sql_mode=
# (string value)
# from .database.oslo.db.mysql_sql_mode
{{ if not .database.oslo.db.mysql_sql_mode }}#{{ end }}mysql_sql_mode = {{ .database.oslo.db.mysql_sql_mode | default "TRADITIONAL" }}

# Timeout before idle SQL connections are reaped. (integer value)
# Deprecated group/name - [DEFAULT]/sql_idle_timeout
# Deprecated group/name - [DATABASE]/sql_idle_timeout
# Deprecated group/name - [sql]/idle_timeout
# from .database.oslo.db.idle_timeout
{{ if not .database.oslo.db.idle_timeout }}#{{ end }}idle_timeout = {{ .database.oslo.db.idle_timeout | default "3600" }}

# Minimum number of SQL connections to keep open in a pool. (integer value)
# Deprecated group/name - [DEFAULT]/sql_min_pool_size
# Deprecated group/name - [DATABASE]/sql_min_pool_size
# from .database.oslo.db.min_pool_size
{{ if not .database.oslo.db.min_pool_size }}#{{ end }}min_pool_size = {{ .database.oslo.db.min_pool_size | default "1" }}

# Maximum number of SQL connections to keep open in a pool. Setting a value of
# 0 indicates no limit. (integer value)
# Deprecated group/name - [DEFAULT]/sql_max_pool_size
# Deprecated group/name - [DATABASE]/sql_max_pool_size
# from .database.oslo.db.max_pool_size
{{ if not .database.oslo.db.max_pool_size }}#{{ end }}max_pool_size = {{ .database.oslo.db.max_pool_size | default "5" }}

# Maximum number of database connection retries during startup. Set to -1 to
# specify an infinite retry count. (integer value)
# Deprecated group/name - [DEFAULT]/sql_max_retries
# Deprecated group/name - [DATABASE]/sql_max_retries
# from .database.oslo.db.max_retries
{{ if not .database.oslo.db.max_retries }}#{{ end }}max_retries = {{ .database.oslo.db.max_retries | default "10" }}

# Interval between retries of opening a SQL connection. (integer value)
# Deprecated group/name - [DEFAULT]/sql_retry_interval
# Deprecated group/name - [DATABASE]/reconnect_interval
# from .database.oslo.db.retry_interval
{{ if not .database.oslo.db.retry_interval }}#{{ end }}retry_interval = {{ .database.oslo.db.retry_interval | default "10" }}

# If set, use this value for max_overflow with SQLAlchemy. (integer value)
# Deprecated group/name - [DEFAULT]/sql_max_overflow
# Deprecated group/name - [DATABASE]/sqlalchemy_max_overflow
# from .database.oslo.db.max_overflow
{{ if not .database.oslo.db.max_overflow }}#{{ end }}max_overflow = {{ .database.oslo.db.max_overflow | default "50" }}

# Verbosity of SQL debugging information: 0=None, 100=Everything. (integer
# value)
# Minimum value: 0
# Maximum value: 100
# Deprecated group/name - [DEFAULT]/sql_connection_debug
# from .database.oslo.db.connection_debug
{{ if not .database.oslo.db.connection_debug }}#{{ end }}connection_debug = {{ .database.oslo.db.connection_debug | default "0" }}

# Add Python stack traces to SQL as comment strings. (boolean value)
# Deprecated group/name - [DEFAULT]/sql_connection_trace
# from .database.oslo.db.connection_trace
{{ if not .database.oslo.db.connection_trace }}#{{ end }}connection_trace = {{ .database.oslo.db.connection_trace | default "false" }}

# If set, use this value for pool_timeout with SQLAlchemy. (integer value)
# Deprecated group/name - [DATABASE]/sqlalchemy_pool_timeout
# from .database.oslo.db.pool_timeout
{{ if not .database.oslo.db.pool_timeout }}#{{ end }}pool_timeout = {{ .database.oslo.db.pool_timeout | default "<None>" }}

# Enable the experimental use of database reconnect on connection lost.
# (boolean value)
# from .database.oslo.db.use_db_reconnect
{{ if not .database.oslo.db.use_db_reconnect }}#{{ end }}use_db_reconnect = {{ .database.oslo.db.use_db_reconnect | default "false" }}

# Seconds between retries of a database transaction. (integer value)
# from .database.oslo.db.db_retry_interval
{{ if not .database.oslo.db.db_retry_interval }}#{{ end }}db_retry_interval = {{ .database.oslo.db.db_retry_interval | default "1" }}

# If True, increases the interval between retries of a database operation up to
# db_max_retry_interval. (boolean value)
# from .database.oslo.db.db_inc_retry_interval
{{ if not .database.oslo.db.db_inc_retry_interval }}#{{ end }}db_inc_retry_interval = {{ .database.oslo.db.db_inc_retry_interval | default "true" }}

# If db_inc_retry_interval is set, the maximum seconds between retries of a
# database operation. (integer value)
# from .database.oslo.db.db_max_retry_interval
{{ if not .database.oslo.db.db_max_retry_interval }}#{{ end }}db_max_retry_interval = {{ .database.oslo.db.db_max_retry_interval | default "10" }}

# Maximum retries in case of connection error or deadlock error before error is
# raised. Set to -1 to specify an infinite retry count. (integer value)
# from .database.oslo.db.db_max_retries
{{ if not .database.oslo.db.db_max_retries }}#{{ end }}db_max_retries = {{ .database.oslo.db.db_max_retries | default "20" }}


[ec2authtoken]

#
# From heat.api.aws.ec2token
#

# Authentication Endpoint URI. (string value)
# from .ec2authtoken.heat.api.aws.ec2token.auth_uri
{{ if not .ec2authtoken.heat.api.aws.ec2token.auth_uri }}#{{ end }}auth_uri = {{ .ec2authtoken.heat.api.aws.ec2token.auth_uri | default "<None>" }}

# Allow orchestration of multiple clouds. (boolean value)
# from .ec2authtoken.heat.api.aws.ec2token.multi_cloud
{{ if not .ec2authtoken.heat.api.aws.ec2token.multi_cloud }}#{{ end }}multi_cloud = {{ .ec2authtoken.heat.api.aws.ec2token.multi_cloud | default "false" }}

# Allowed keystone endpoints for auth_uri when multi_cloud is enabled. At least
# one endpoint needs to be specified. (list value)
# from .ec2authtoken.heat.api.aws.ec2token.allowed_auth_uris
{{ if not .ec2authtoken.heat.api.aws.ec2token.allowed_auth_uris }}#{{ end }}allowed_auth_uris = {{ .ec2authtoken.heat.api.aws.ec2token.allowed_auth_uris | default "" }}

# Optional PEM-formatted certificate chain file. (string value)
# from .ec2authtoken.heat.api.aws.ec2token.cert_file
{{ if not .ec2authtoken.heat.api.aws.ec2token.cert_file }}#{{ end }}cert_file = {{ .ec2authtoken.heat.api.aws.ec2token.cert_file | default "<None>" }}

# Optional PEM-formatted file that contains the private key. (string value)
# from .ec2authtoken.heat.api.aws.ec2token.key_file
{{ if not .ec2authtoken.heat.api.aws.ec2token.key_file }}#{{ end }}key_file = {{ .ec2authtoken.heat.api.aws.ec2token.key_file | default "<None>" }}

# Optional CA cert file to use in SSL connections. (string value)
# from .ec2authtoken.heat.api.aws.ec2token.ca_file
{{ if not .ec2authtoken.heat.api.aws.ec2token.ca_file }}#{{ end }}ca_file = {{ .ec2authtoken.heat.api.aws.ec2token.ca_file | default "<None>" }}

# If set, then the server's certificate will not be verified. (boolean value)
# from .ec2authtoken.heat.api.aws.ec2token.insecure
{{ if not .ec2authtoken.heat.api.aws.ec2token.insecure }}#{{ end }}insecure = {{ .ec2authtoken.heat.api.aws.ec2token.insecure | default "false" }}


[eventlet_opts]

#
# From heat.common.wsgi
#

# If False, closes the client socket connection explicitly. (boolean value)
# from .eventlet_opts.heat.common.wsgi.wsgi_keep_alive
{{ if not .eventlet_opts.heat.common.wsgi.wsgi_keep_alive }}#{{ end }}wsgi_keep_alive = {{ .eventlet_opts.heat.common.wsgi.wsgi_keep_alive | default "true" }}

# Timeout for client connections' socket operations. If an incoming connection
# is idle for this number of seconds it will be closed. A value of '0' means
# wait forever. (integer value)
# from .eventlet_opts.heat.common.wsgi.client_socket_timeout
{{ if not .eventlet_opts.heat.common.wsgi.client_socket_timeout }}#{{ end }}client_socket_timeout = {{ .eventlet_opts.heat.common.wsgi.client_socket_timeout | default "900" }}


[heat_api]

#
# From heat.common.wsgi
#

# Address to bind the server. Useful when selecting a particular network
# interface. (IP address value)
# Deprecated group/name - [DEFAULT]/bind_host
# from .heat_api.heat.common.wsgi.bind_host
{{ if not .heat_api.heat.common.wsgi.bind_host }}#{{ end }}bind_host = {{ .heat_api.heat.common.wsgi.bind_host | default "0.0.0.0" }}

# The port on which the server will listen. (port value)
# Minimum value: 0
# Maximum value: 65535
# Deprecated group/name - [DEFAULT]/bind_port
# from .heat_api.heat.common.wsgi.bind_port
{{ if not .heat_api.heat.common.wsgi.bind_port }}#{{ end }}bind_port = {{ .heat_api.heat.common.wsgi.bind_port | default "8004" }}

# Number of backlog requests to configure the socket with. (integer value)
# Deprecated group/name - [DEFAULT]/backlog
# from .heat_api.heat.common.wsgi.backlog
{{ if not .heat_api.heat.common.wsgi.backlog }}#{{ end }}backlog = {{ .heat_api.heat.common.wsgi.backlog | default "4096" }}

# Location of the SSL certificate file to use for SSL mode. (string value)
# Deprecated group/name - [DEFAULT]/cert_file
# from .heat_api.heat.common.wsgi.cert_file
{{ if not .heat_api.heat.common.wsgi.cert_file }}#{{ end }}cert_file = {{ .heat_api.heat.common.wsgi.cert_file | default "<None>" }}

# Location of the SSL key file to use for enabling SSL mode. (string value)
# Deprecated group/name - [DEFAULT]/key_file
# from .heat_api.heat.common.wsgi.key_file
{{ if not .heat_api.heat.common.wsgi.key_file }}#{{ end }}key_file = {{ .heat_api.heat.common.wsgi.key_file | default "<None>" }}

# Number of workers for Heat service. Default value 0 means, that service will
# start number of workers equal number of cores on server. (integer value)
# Deprecated group/name - [DEFAULT]/workers
# from .heat_api.heat.common.wsgi.workers
{{ if not .heat_api.heat.common.wsgi.workers }}#{{ end }}workers = {{ .heat_api.heat.common.wsgi.workers | default "0" }}

# Maximum line size of message headers to be accepted. max_header_line may need
# to be increased when using large tokens (typically those generated by the
# Keystone v3 API with big service catalogs). (integer value)
# from .heat_api.heat.common.wsgi.max_header_line
{{ if not .heat_api.heat.common.wsgi.max_header_line }}#{{ end }}max_header_line = {{ .heat_api.heat.common.wsgi.max_header_line | default "16384" }}

# The value for the socket option TCP_KEEPIDLE.  This is the time in seconds
# that the connection must be idle before TCP starts sending keepalive probes.
# (integer value)
# from .heat_api.heat.common.wsgi.tcp_keepidle
{{ if not .heat_api.heat.common.wsgi.tcp_keepidle }}#{{ end }}tcp_keepidle = {{ .heat_api.heat.common.wsgi.tcp_keepidle | default "600" }}


[heat_api_cfn]

#
# From heat.common.wsgi
#

# Address to bind the server. Useful when selecting a particular network
# interface. (IP address value)
# Deprecated group/name - [DEFAULT]/bind_host
# from .heat_api_cfn.heat.common.wsgi.bind_host
{{ if not .heat_api_cfn.heat.common.wsgi.bind_host }}#{{ end }}bind_host = {{ .heat_api_cfn.heat.common.wsgi.bind_host | default "0.0.0.0" }}

# The port on which the server will listen. (port value)
# Minimum value: 0
# Maximum value: 65535
# Deprecated group/name - [DEFAULT]/bind_port
# from .heat_api_cfn.heat.common.wsgi.bind_port
{{ if not .heat_api_cfn.heat.common.wsgi.bind_port }}#{{ end }}bind_port = {{ .heat_api_cfn.heat.common.wsgi.bind_port | default "8000" }}

# Number of backlog requests to configure the socket with. (integer value)
# Deprecated group/name - [DEFAULT]/backlog
# from .heat_api_cfn.heat.common.wsgi.backlog
{{ if not .heat_api_cfn.heat.common.wsgi.backlog }}#{{ end }}backlog = {{ .heat_api_cfn.heat.common.wsgi.backlog | default "4096" }}

# Location of the SSL certificate file to use for SSL mode. (string value)
# Deprecated group/name - [DEFAULT]/cert_file
# from .heat_api_cfn.heat.common.wsgi.cert_file
{{ if not .heat_api_cfn.heat.common.wsgi.cert_file }}#{{ end }}cert_file = {{ .heat_api_cfn.heat.common.wsgi.cert_file | default "<None>" }}

# Location of the SSL key file to use for enabling SSL mode. (string value)
# Deprecated group/name - [DEFAULT]/key_file
# from .heat_api_cfn.heat.common.wsgi.key_file
{{ if not .heat_api_cfn.heat.common.wsgi.key_file }}#{{ end }}key_file = {{ .heat_api_cfn.heat.common.wsgi.key_file | default "<None>" }}

# Number of workers for Heat service. (integer value)
# Deprecated group/name - [DEFAULT]/workers
# from .heat_api_cfn.heat.common.wsgi.workers
{{ if not .heat_api_cfn.heat.common.wsgi.workers }}#{{ end }}workers = {{ .heat_api_cfn.heat.common.wsgi.workers | default "1" }}

# Maximum line size of message headers to be accepted. max_header_line may need
# to be increased when using large tokens (typically those generated by the
# Keystone v3 API with big service catalogs). (integer value)
# from .heat_api_cfn.heat.common.wsgi.max_header_line
{{ if not .heat_api_cfn.heat.common.wsgi.max_header_line }}#{{ end }}max_header_line = {{ .heat_api_cfn.heat.common.wsgi.max_header_line | default "16384" }}

# The value for the socket option TCP_KEEPIDLE.  This is the time in seconds
# that the connection must be idle before TCP starts sending keepalive probes.
# (integer value)
# from .heat_api_cfn.heat.common.wsgi.tcp_keepidle
{{ if not .heat_api_cfn.heat.common.wsgi.tcp_keepidle }}#{{ end }}tcp_keepidle = {{ .heat_api_cfn.heat.common.wsgi.tcp_keepidle | default "600" }}


[heat_api_cloudwatch]

#
# From heat.common.wsgi
#

# Address to bind the server. Useful when selecting a particular network
# interface. (IP address value)
# Deprecated group/name - [DEFAULT]/bind_host
# from .heat_api_cloudwatch.heat.common.wsgi.bind_host
{{ if not .heat_api_cloudwatch.heat.common.wsgi.bind_host }}#{{ end }}bind_host = {{ .heat_api_cloudwatch.heat.common.wsgi.bind_host | default "0.0.0.0" }}

# The port on which the server will listen. (port value)
# Minimum value: 0
# Maximum value: 65535
# Deprecated group/name - [DEFAULT]/bind_port
# from .heat_api_cloudwatch.heat.common.wsgi.bind_port
{{ if not .heat_api_cloudwatch.heat.common.wsgi.bind_port }}#{{ end }}bind_port = {{ .heat_api_cloudwatch.heat.common.wsgi.bind_port | default "8003" }}

# Number of backlog requests to configure the socket with. (integer value)
# Deprecated group/name - [DEFAULT]/backlog
# from .heat_api_cloudwatch.heat.common.wsgi.backlog
{{ if not .heat_api_cloudwatch.heat.common.wsgi.backlog }}#{{ end }}backlog = {{ .heat_api_cloudwatch.heat.common.wsgi.backlog | default "4096" }}

# Location of the SSL certificate file to use for SSL mode. (string value)
# Deprecated group/name - [DEFAULT]/cert_file
# from .heat_api_cloudwatch.heat.common.wsgi.cert_file
{{ if not .heat_api_cloudwatch.heat.common.wsgi.cert_file }}#{{ end }}cert_file = {{ .heat_api_cloudwatch.heat.common.wsgi.cert_file | default "<None>" }}

# Location of the SSL key file to use for enabling SSL mode. (string value)
# Deprecated group/name - [DEFAULT]/key_file
# from .heat_api_cloudwatch.heat.common.wsgi.key_file
{{ if not .heat_api_cloudwatch.heat.common.wsgi.key_file }}#{{ end }}key_file = {{ .heat_api_cloudwatch.heat.common.wsgi.key_file | default "<None>" }}

# Number of workers for Heat service. (integer value)
# Deprecated group/name - [DEFAULT]/workers
# from .heat_api_cloudwatch.heat.common.wsgi.workers
{{ if not .heat_api_cloudwatch.heat.common.wsgi.workers }}#{{ end }}workers = {{ .heat_api_cloudwatch.heat.common.wsgi.workers | default "1" }}

# Maximum line size of message headers to be accepted. max_header_line may need
# to be increased when using large tokens (typically those generated by the
# Keystone v3 API with big service catalogs.) (integer value)
# from .heat_api_cloudwatch.heat.common.wsgi.max_header_line
{{ if not .heat_api_cloudwatch.heat.common.wsgi.max_header_line }}#{{ end }}max_header_line = {{ .heat_api_cloudwatch.heat.common.wsgi.max_header_line | default "16384" }}

# The value for the socket option TCP_KEEPIDLE.  This is the time in seconds
# that the connection must be idle before TCP starts sending keepalive probes.
# (integer value)
# from .heat_api_cloudwatch.heat.common.wsgi.tcp_keepidle
{{ if not .heat_api_cloudwatch.heat.common.wsgi.tcp_keepidle }}#{{ end }}tcp_keepidle = {{ .heat_api_cloudwatch.heat.common.wsgi.tcp_keepidle | default "600" }}


[keystone_authtoken]

# FIXME(alanmeadows) - added the next several lines because oslo gen config refuses to generate the line items required in keystonemiddleware
# for authentication - while it does support an "auth_section" parameter to locate these elsewhere, it would be a strange divergence
# from how neutron keystone authentication is stored today - ocata and later appear to use a "service" user section which can house these details
# and does successfully generate beyond newton, so likely this whole section will be removed the next time we generate this file

{{ if not .keystone_authtoken.keystonemiddleware.auth_token.auth_url }}#{{ end }}auth_url = {{ .keystone_authtoken.keystonemiddleware.auth_token.auth_url | default "<None>" }}
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.region_name }}#{{ end }}region_name = {{ .keystone_authtoken.keystonemiddleware.auth_token.region_name | default "<None>" }}
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.project_name }}#{{ end }}project_name = {{ .keystone_authtoken.keystonemiddleware.auth_token.project_name | default "<None>" }}
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.project_domain_name }}#{{ end }}project_domain_name = {{ .keystone_authtoken.keystonemiddleware.auth_token.project_domain_name | default "<None>" }}
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.user_domain_name }}#{{ end }}user_domain_name = {{ .keystone_authtoken.keystonemiddleware.auth_token.user_domain_name | default "<None>" }}
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.username }}#{{ end }}username = {{ .keystone_authtoken.keystonemiddleware.auth_token.username | default "<None>" }}
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.password }}#{{ end }}password = {{ .keystone_authtoken.keystonemiddleware.auth_token.password | default "<None>" }}

# FIXME(alanmeadows) - added for some newton images using older keystoneauth1 libs but are still "newton"
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.auth_url }}#{{ end }}auth_url = {{ .keystone_authtoken.keystonemiddleware.auth_token.auth_url | default "<None>" }}

#
# From keystonemiddleware.auth_token
#

# Complete "public" Identity API endpoint. This endpoint should not be an
# "admin" endpoint, as it should be accessible by all end users.
# Unauthenticated clients are redirected to this endpoint to authenticate.
# Although this endpoint should  ideally be unversioned, client support in the
# wild varies.  If you're using a versioned v2 endpoint here, then this  should
# *not* be the same endpoint the service user utilizes  for validating tokens,
# because normal end users may not be  able to reach that endpoint. (string
# value)
# from .keystone_authtoken.keystonemiddleware.auth_token.auth_uri
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.auth_uri }}#{{ end }}auth_uri = {{ .keystone_authtoken.keystonemiddleware.auth_token.auth_uri | default "<None>" }}

# API version of the admin Identity API endpoint. (string value)
# from .keystone_authtoken.keystonemiddleware.auth_token.auth_version
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.auth_version }}#{{ end }}auth_version = {{ .keystone_authtoken.keystonemiddleware.auth_token.auth_version | default "<None>" }}

# Do not handle authorization requests within the middleware, but delegate the
# authorization decision to downstream WSGI components. (boolean value)
# from .keystone_authtoken.keystonemiddleware.auth_token.delay_auth_decision
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.delay_auth_decision }}#{{ end }}delay_auth_decision = {{ .keystone_authtoken.keystonemiddleware.auth_token.delay_auth_decision | default "false" }}

# Request timeout value for communicating with Identity API server. (integer
# value)
# from .keystone_authtoken.keystonemiddleware.auth_token.http_connect_timeout
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.http_connect_timeout }}#{{ end }}http_connect_timeout = {{ .keystone_authtoken.keystonemiddleware.auth_token.http_connect_timeout | default "<None>" }}

# How many times are we trying to reconnect when communicating with Identity
# API Server. (integer value)
# from .keystone_authtoken.keystonemiddleware.auth_token.http_request_max_retries
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.http_request_max_retries }}#{{ end }}http_request_max_retries = {{ .keystone_authtoken.keystonemiddleware.auth_token.http_request_max_retries | default "3" }}

# Request environment key where the Swift cache object is stored. When
# auth_token middleware is deployed with a Swift cache, use this option to have
# the middleware share a caching backend with swift. Otherwise, use the
# ``memcached_servers`` option instead. (string value)
# from .keystone_authtoken.keystonemiddleware.auth_token.cache
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.cache }}#{{ end }}cache = {{ .keystone_authtoken.keystonemiddleware.auth_token.cache | default "<None>" }}

# Required if identity server requires client certificate (string value)
# from .keystone_authtoken.keystonemiddleware.auth_token.certfile
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.certfile }}#{{ end }}certfile = {{ .keystone_authtoken.keystonemiddleware.auth_token.certfile | default "<None>" }}

# Required if identity server requires client certificate (string value)
# from .keystone_authtoken.keystonemiddleware.auth_token.keyfile
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.keyfile }}#{{ end }}keyfile = {{ .keystone_authtoken.keystonemiddleware.auth_token.keyfile | default "<None>" }}

# A PEM encoded Certificate Authority to use when verifying HTTPs connections.
# Defaults to system CAs. (string value)
# from .keystone_authtoken.keystonemiddleware.auth_token.cafile
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.cafile }}#{{ end }}cafile = {{ .keystone_authtoken.keystonemiddleware.auth_token.cafile | default "<None>" }}

# Verify HTTPS connections. (boolean value)
# from .keystone_authtoken.keystonemiddleware.auth_token.insecure
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.insecure }}#{{ end }}insecure = {{ .keystone_authtoken.keystonemiddleware.auth_token.insecure | default "false" }}

# The region in which the identity server can be found. (string value)
# from .keystone_authtoken.keystonemiddleware.auth_token.region_name
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.region_name }}#{{ end }}region_name = {{ .keystone_authtoken.keystonemiddleware.auth_token.region_name | default "<None>" }}

# Directory used to cache files related to PKI tokens. (string value)
# from .keystone_authtoken.keystonemiddleware.auth_token.signing_dir
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.signing_dir }}#{{ end }}signing_dir = {{ .keystone_authtoken.keystonemiddleware.auth_token.signing_dir | default "<None>" }}

# Optionally specify a list of memcached server(s) to use for caching. If left
# undefined, tokens will instead be cached in-process. (list value)
# Deprecated group/name - [keystone_authtoken]/memcache_servers
# from .keystone_authtoken.keystonemiddleware.auth_token.memcached_servers
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.memcached_servers }}#{{ end }}memcached_servers = {{ .keystone_authtoken.keystonemiddleware.auth_token.memcached_servers | default "<None>" }}

# In order to prevent excessive effort spent validating tokens, the middleware
# caches previously-seen tokens for a configurable duration (in seconds). Set
# to -1 to disable caching completely. (integer value)
# from .keystone_authtoken.keystonemiddleware.auth_token.token_cache_time
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.token_cache_time }}#{{ end }}token_cache_time = {{ .keystone_authtoken.keystonemiddleware.auth_token.token_cache_time | default "300" }}

# Determines the frequency at which the list of revoked tokens is retrieved
# from the Identity service (in seconds). A high number of revocation events
# combined with a low cache duration may significantly reduce performance. Only
# valid for PKI tokens. (integer value)
# from .keystone_authtoken.keystonemiddleware.auth_token.revocation_cache_time
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.revocation_cache_time }}#{{ end }}revocation_cache_time = {{ .keystone_authtoken.keystonemiddleware.auth_token.revocation_cache_time | default "10" }}

# (Optional) If defined, indicate whether token data should be authenticated or
# authenticated and encrypted. If MAC, token data is authenticated (with HMAC)
# in the cache. If ENCRYPT, token data is encrypted and authenticated in the
# cache. If the value is not one of these options or empty, auth_token will
# raise an exception on initialization. (string value)
# Allowed values: None, MAC, ENCRYPT
# from .keystone_authtoken.keystonemiddleware.auth_token.memcache_security_strategy
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.memcache_security_strategy }}#{{ end }}memcache_security_strategy = {{ .keystone_authtoken.keystonemiddleware.auth_token.memcache_security_strategy | default "None" }}

# (Optional, mandatory if memcache_security_strategy is defined) This string is
# used for key derivation. (string value)
# from .keystone_authtoken.keystonemiddleware.auth_token.memcache_secret_key
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.memcache_secret_key }}#{{ end }}memcache_secret_key = {{ .keystone_authtoken.keystonemiddleware.auth_token.memcache_secret_key | default "<None>" }}

# (Optional) Number of seconds memcached server is considered dead before it is
# tried again. (integer value)
# from .keystone_authtoken.keystonemiddleware.auth_token.memcache_pool_dead_retry
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.memcache_pool_dead_retry }}#{{ end }}memcache_pool_dead_retry = {{ .keystone_authtoken.keystonemiddleware.auth_token.memcache_pool_dead_retry | default "300" }}

# (Optional) Maximum total number of open connections to every memcached
# server. (integer value)
# from .keystone_authtoken.keystonemiddleware.auth_token.memcache_pool_maxsize
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.memcache_pool_maxsize }}#{{ end }}memcache_pool_maxsize = {{ .keystone_authtoken.keystonemiddleware.auth_token.memcache_pool_maxsize | default "10" }}

# (Optional) Socket timeout in seconds for communicating with a memcached
# server. (integer value)
# from .keystone_authtoken.keystonemiddleware.auth_token.memcache_pool_socket_timeout
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.memcache_pool_socket_timeout }}#{{ end }}memcache_pool_socket_timeout = {{ .keystone_authtoken.keystonemiddleware.auth_token.memcache_pool_socket_timeout | default "3" }}

# (Optional) Number of seconds a connection to memcached is held unused in the
# pool before it is closed. (integer value)
# from .keystone_authtoken.keystonemiddleware.auth_token.memcache_pool_unused_timeout
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.memcache_pool_unused_timeout }}#{{ end }}memcache_pool_unused_timeout = {{ .keystone_authtoken.keystonemiddleware.auth_token.memcache_pool_unused_timeout | default "60" }}

# (Optional) Number of seconds that an operation will wait to get a memcached
# client connection from the pool. (integer value)
# from .keystone_authtoken.keystonemiddleware.auth_token.memcache_pool_conn_get_timeout
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.memcache_pool_conn_get_timeout }}#{{ end }}memcache_pool_conn_get_timeout = {{ .keystone_authtoken.keystonemiddleware.auth_token.memcache_pool_conn_get_timeout | default "10" }}

# (Optional) Use the advanced (eventlet safe) memcached client pool. The
# advanced pool will only work under python 2.x. (boolean value)
# from .keystone_authtoken.keystonemiddleware.auth_token.memcache_use_advanced_pool
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.memcache_use_advanced_pool }}#{{ end }}memcache_use_advanced_pool = {{ .keystone_authtoken.keystonemiddleware.auth_token.memcache_use_advanced_pool | default "false" }}

# (Optional) Indicate whether to set the X-Service-Catalog header. If False,
# middleware will not ask for service catalog on token validation and will not
# set the X-Service-Catalog header. (boolean value)
# from .keystone_authtoken.keystonemiddleware.auth_token.include_service_catalog
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.include_service_catalog }}#{{ end }}include_service_catalog = {{ .keystone_authtoken.keystonemiddleware.auth_token.include_service_catalog | default "true" }}

# Used to control the use and type of token binding. Can be set to: "disabled"
# to not check token binding. "permissive" (default) to validate binding
# information if the bind type is of a form known to the server and ignore it
# if not. "strict" like "permissive" but if the bind type is unknown the token
# will be rejected. "required" any form of token binding is needed to be
# allowed. Finally the name of a binding method that must be present in tokens.
# (string value)
# from .keystone_authtoken.keystonemiddleware.auth_token.enforce_token_bind
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.enforce_token_bind }}#{{ end }}enforce_token_bind = {{ .keystone_authtoken.keystonemiddleware.auth_token.enforce_token_bind | default "permissive" }}

# If true, the revocation list will be checked for cached tokens. This requires
# that PKI tokens are configured on the identity server. (boolean value)
# from .keystone_authtoken.keystonemiddleware.auth_token.check_revocations_for_cached
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.check_revocations_for_cached }}#{{ end }}check_revocations_for_cached = {{ .keystone_authtoken.keystonemiddleware.auth_token.check_revocations_for_cached | default "false" }}

# Hash algorithms to use for hashing PKI tokens. This may be a single algorithm
# or multiple. The algorithms are those supported by Python standard
# hashlib.new(). The hashes will be tried in the order given, so put the
# preferred one first for performance. The result of the first hash will be
# stored in the cache. This will typically be set to multiple values only while
# migrating from a less secure algorithm to a more secure one. Once all the old
# tokens are expired this option should be set to a single value for better
# performance. (list value)
# from .keystone_authtoken.keystonemiddleware.auth_token.hash_algorithms
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.hash_algorithms }}#{{ end }}hash_algorithms = {{ .keystone_authtoken.keystonemiddleware.auth_token.hash_algorithms | default "md5" }}

# Authentication type to load (string value)
# Deprecated group/name - [keystone_authtoken]/auth_plugin
# from .keystone_authtoken.keystonemiddleware.auth_token.auth_type
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.auth_type }}#{{ end }}auth_type = {{ .keystone_authtoken.keystonemiddleware.auth_token.auth_type | default "<None>" }}

# Config Section from which to load plugin specific options (string value)
# from .keystone_authtoken.keystonemiddleware.auth_token.auth_section
{{ if not .keystone_authtoken.keystonemiddleware.auth_token.auth_section }}#{{ end }}auth_section = {{ .keystone_authtoken.keystonemiddleware.auth_token.auth_section | default "<None>" }}


[matchmaker_redis]

#
# From oslo.messaging
#

# DEPRECATED: Host to locate redis. (string value)
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# Reason: Replaced by [DEFAULT]/transport_url
# from .matchmaker_redis.oslo.messaging.host
{{ if not .matchmaker_redis.oslo.messaging.host }}#{{ end }}host = {{ .matchmaker_redis.oslo.messaging.host | default "127.0.0.1" }}

# DEPRECATED: Use this port to connect to redis host. (port value)
# Minimum value: 0
# Maximum value: 65535
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# Reason: Replaced by [DEFAULT]/transport_url
# from .matchmaker_redis.oslo.messaging.port
{{ if not .matchmaker_redis.oslo.messaging.port }}#{{ end }}port = {{ .matchmaker_redis.oslo.messaging.port | default "6379" }}

# DEPRECATED: Password for Redis server (optional). (string value)
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# Reason: Replaced by [DEFAULT]/transport_url
# from .matchmaker_redis.oslo.messaging.password
{{ if not .matchmaker_redis.oslo.messaging.password }}#{{ end }}password = {{ .matchmaker_redis.oslo.messaging.password | default "" }}

# DEPRECATED: List of Redis Sentinel hosts (fault tolerance mode) e.g.
# [host:port, host1:port ... ] (list value)
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# Reason: Replaced by [DEFAULT]/transport_url
# from .matchmaker_redis.oslo.messaging.sentinel_hosts
{{ if not .matchmaker_redis.oslo.messaging.sentinel_hosts }}#{{ end }}sentinel_hosts = {{ .matchmaker_redis.oslo.messaging.sentinel_hosts | default "" }}

# Redis replica set name. (string value)
# from .matchmaker_redis.oslo.messaging.sentinel_group_name
{{ if not .matchmaker_redis.oslo.messaging.sentinel_group_name }}#{{ end }}sentinel_group_name = {{ .matchmaker_redis.oslo.messaging.sentinel_group_name | default "oslo-messaging-zeromq" }}

# Time in ms to wait between connection attempts. (integer value)
# from .matchmaker_redis.oslo.messaging.wait_timeout
{{ if not .matchmaker_redis.oslo.messaging.wait_timeout }}#{{ end }}wait_timeout = {{ .matchmaker_redis.oslo.messaging.wait_timeout | default "2000" }}

# Time in ms to wait before the transaction is killed. (integer value)
# from .matchmaker_redis.oslo.messaging.check_timeout
{{ if not .matchmaker_redis.oslo.messaging.check_timeout }}#{{ end }}check_timeout = {{ .matchmaker_redis.oslo.messaging.check_timeout | default "20000" }}

# Timeout in ms on blocking socket operations (integer value)
# from .matchmaker_redis.oslo.messaging.socket_timeout
{{ if not .matchmaker_redis.oslo.messaging.socket_timeout }}#{{ end }}socket_timeout = {{ .matchmaker_redis.oslo.messaging.socket_timeout | default "10000" }}


[oslo_messaging_amqp]

#
# From oslo.messaging
#

# Name for the AMQP container. must be globally unique. Defaults to a generated
# UUID (string value)
# Deprecated group/name - [amqp1]/container_name
# from .oslo_messaging_amqp.oslo.messaging.container_name
{{ if not .oslo_messaging_amqp.oslo.messaging.container_name }}#{{ end }}container_name = {{ .oslo_messaging_amqp.oslo.messaging.container_name | default "<None>" }}

# Timeout for inactive connections (in seconds) (integer value)
# Deprecated group/name - [amqp1]/idle_timeout
# from .oslo_messaging_amqp.oslo.messaging.idle_timeout
{{ if not .oslo_messaging_amqp.oslo.messaging.idle_timeout }}#{{ end }}idle_timeout = {{ .oslo_messaging_amqp.oslo.messaging.idle_timeout | default "0" }}

# Debug: dump AMQP frames to stdout (boolean value)
# Deprecated group/name - [amqp1]/trace
# from .oslo_messaging_amqp.oslo.messaging.trace
{{ if not .oslo_messaging_amqp.oslo.messaging.trace }}#{{ end }}trace = {{ .oslo_messaging_amqp.oslo.messaging.trace | default "false" }}

# CA certificate PEM file to verify server certificate (string value)
# Deprecated group/name - [amqp1]/ssl_ca_file
# from .oslo_messaging_amqp.oslo.messaging.ssl_ca_file
{{ if not .oslo_messaging_amqp.oslo.messaging.ssl_ca_file }}#{{ end }}ssl_ca_file = {{ .oslo_messaging_amqp.oslo.messaging.ssl_ca_file | default "" }}

# Identifying certificate PEM file to present to clients (string value)
# Deprecated group/name - [amqp1]/ssl_cert_file
# from .oslo_messaging_amqp.oslo.messaging.ssl_cert_file
{{ if not .oslo_messaging_amqp.oslo.messaging.ssl_cert_file }}#{{ end }}ssl_cert_file = {{ .oslo_messaging_amqp.oslo.messaging.ssl_cert_file | default "" }}

# Private key PEM file used to sign cert_file certificate (string value)
# Deprecated group/name - [amqp1]/ssl_key_file
# from .oslo_messaging_amqp.oslo.messaging.ssl_key_file
{{ if not .oslo_messaging_amqp.oslo.messaging.ssl_key_file }}#{{ end }}ssl_key_file = {{ .oslo_messaging_amqp.oslo.messaging.ssl_key_file | default "" }}

# Password for decrypting ssl_key_file (if encrypted) (string value)
# Deprecated group/name - [amqp1]/ssl_key_password
# from .oslo_messaging_amqp.oslo.messaging.ssl_key_password
{{ if not .oslo_messaging_amqp.oslo.messaging.ssl_key_password }}#{{ end }}ssl_key_password = {{ .oslo_messaging_amqp.oslo.messaging.ssl_key_password | default "<None>" }}

# Accept clients using either SSL or plain TCP (boolean value)
# Deprecated group/name - [amqp1]/allow_insecure_clients
# from .oslo_messaging_amqp.oslo.messaging.allow_insecure_clients
{{ if not .oslo_messaging_amqp.oslo.messaging.allow_insecure_clients }}#{{ end }}allow_insecure_clients = {{ .oslo_messaging_amqp.oslo.messaging.allow_insecure_clients | default "false" }}

# Space separated list of acceptable SASL mechanisms (string value)
# Deprecated group/name - [amqp1]/sasl_mechanisms
# from .oslo_messaging_amqp.oslo.messaging.sasl_mechanisms
{{ if not .oslo_messaging_amqp.oslo.messaging.sasl_mechanisms }}#{{ end }}sasl_mechanisms = {{ .oslo_messaging_amqp.oslo.messaging.sasl_mechanisms | default "" }}

# Path to directory that contains the SASL configuration (string value)
# Deprecated group/name - [amqp1]/sasl_config_dir
# from .oslo_messaging_amqp.oslo.messaging.sasl_config_dir
{{ if not .oslo_messaging_amqp.oslo.messaging.sasl_config_dir }}#{{ end }}sasl_config_dir = {{ .oslo_messaging_amqp.oslo.messaging.sasl_config_dir | default "" }}

# Name of configuration file (without .conf suffix) (string value)
# Deprecated group/name - [amqp1]/sasl_config_name
# from .oslo_messaging_amqp.oslo.messaging.sasl_config_name
{{ if not .oslo_messaging_amqp.oslo.messaging.sasl_config_name }}#{{ end }}sasl_config_name = {{ .oslo_messaging_amqp.oslo.messaging.sasl_config_name | default "" }}

# User name for message broker authentication (string value)
# Deprecated group/name - [amqp1]/username
# from .oslo_messaging_amqp.oslo.messaging.username
{{ if not .oslo_messaging_amqp.oslo.messaging.username }}#{{ end }}username = {{ .oslo_messaging_amqp.oslo.messaging.username | default "" }}

# Password for message broker authentication (string value)
# Deprecated group/name - [amqp1]/password
# from .oslo_messaging_amqp.oslo.messaging.password
{{ if not .oslo_messaging_amqp.oslo.messaging.password }}#{{ end }}password = {{ .oslo_messaging_amqp.oslo.messaging.password | default "" }}

# Seconds to pause before attempting to re-connect. (integer value)
# Minimum value: 1
# from .oslo_messaging_amqp.oslo.messaging.connection_retry_interval
{{ if not .oslo_messaging_amqp.oslo.messaging.connection_retry_interval }}#{{ end }}connection_retry_interval = {{ .oslo_messaging_amqp.oslo.messaging.connection_retry_interval | default "1" }}

# Increase the connection_retry_interval by this many seconds after each
# unsuccessful failover attempt. (integer value)
# Minimum value: 0
# from .oslo_messaging_amqp.oslo.messaging.connection_retry_backoff
{{ if not .oslo_messaging_amqp.oslo.messaging.connection_retry_backoff }}#{{ end }}connection_retry_backoff = {{ .oslo_messaging_amqp.oslo.messaging.connection_retry_backoff | default "2" }}

# Maximum limit for connection_retry_interval + connection_retry_backoff
# (integer value)
# Minimum value: 1
# from .oslo_messaging_amqp.oslo.messaging.connection_retry_interval_max
{{ if not .oslo_messaging_amqp.oslo.messaging.connection_retry_interval_max }}#{{ end }}connection_retry_interval_max = {{ .oslo_messaging_amqp.oslo.messaging.connection_retry_interval_max | default "30" }}

# Time to pause between re-connecting an AMQP 1.0 link that failed due to a
# recoverable error. (integer value)
# Minimum value: 1
# from .oslo_messaging_amqp.oslo.messaging.link_retry_delay
{{ if not .oslo_messaging_amqp.oslo.messaging.link_retry_delay }}#{{ end }}link_retry_delay = {{ .oslo_messaging_amqp.oslo.messaging.link_retry_delay | default "10" }}

# The deadline for an rpc reply message delivery. Only used when caller does
# not provide a timeout expiry. (integer value)
# Minimum value: 5
# from .oslo_messaging_amqp.oslo.messaging.default_reply_timeout
{{ if not .oslo_messaging_amqp.oslo.messaging.default_reply_timeout }}#{{ end }}default_reply_timeout = {{ .oslo_messaging_amqp.oslo.messaging.default_reply_timeout | default "30" }}

# The deadline for an rpc cast or call message delivery. Only used when caller
# does not provide a timeout expiry. (integer value)
# Minimum value: 5
# from .oslo_messaging_amqp.oslo.messaging.default_send_timeout
{{ if not .oslo_messaging_amqp.oslo.messaging.default_send_timeout }}#{{ end }}default_send_timeout = {{ .oslo_messaging_amqp.oslo.messaging.default_send_timeout | default "30" }}

# The deadline for a sent notification message delivery. Only used when caller
# does not provide a timeout expiry. (integer value)
# Minimum value: 5
# from .oslo_messaging_amqp.oslo.messaging.default_notify_timeout
{{ if not .oslo_messaging_amqp.oslo.messaging.default_notify_timeout }}#{{ end }}default_notify_timeout = {{ .oslo_messaging_amqp.oslo.messaging.default_notify_timeout | default "30" }}

# Indicates the addressing mode used by the driver.
# Permitted values:
# 'legacy'   - use legacy non-routable addressing
# 'routable' - use routable addresses
# 'dynamic'  - use legacy addresses if the message bus does not support routing
# otherwise use routable addressing (string value)
# from .oslo_messaging_amqp.oslo.messaging.addressing_mode
{{ if not .oslo_messaging_amqp.oslo.messaging.addressing_mode }}#{{ end }}addressing_mode = {{ .oslo_messaging_amqp.oslo.messaging.addressing_mode | default "dynamic" }}

# address prefix used when sending to a specific server (string value)
# Deprecated group/name - [amqp1]/server_request_prefix
# from .oslo_messaging_amqp.oslo.messaging.server_request_prefix
{{ if not .oslo_messaging_amqp.oslo.messaging.server_request_prefix }}#{{ end }}server_request_prefix = {{ .oslo_messaging_amqp.oslo.messaging.server_request_prefix | default "exclusive" }}

# address prefix used when broadcasting to all servers (string value)
# Deprecated group/name - [amqp1]/broadcast_prefix
# from .oslo_messaging_amqp.oslo.messaging.broadcast_prefix
{{ if not .oslo_messaging_amqp.oslo.messaging.broadcast_prefix }}#{{ end }}broadcast_prefix = {{ .oslo_messaging_amqp.oslo.messaging.broadcast_prefix | default "broadcast" }}

# address prefix when sending to any server in group (string value)
# Deprecated group/name - [amqp1]/group_request_prefix
# from .oslo_messaging_amqp.oslo.messaging.group_request_prefix
{{ if not .oslo_messaging_amqp.oslo.messaging.group_request_prefix }}#{{ end }}group_request_prefix = {{ .oslo_messaging_amqp.oslo.messaging.group_request_prefix | default "unicast" }}

# Address prefix for all generated RPC addresses (string value)
# from .oslo_messaging_amqp.oslo.messaging.rpc_address_prefix
{{ if not .oslo_messaging_amqp.oslo.messaging.rpc_address_prefix }}#{{ end }}rpc_address_prefix = {{ .oslo_messaging_amqp.oslo.messaging.rpc_address_prefix | default "openstack.org/om/rpc" }}

# Address prefix for all generated Notification addresses (string value)
# from .oslo_messaging_amqp.oslo.messaging.notify_address_prefix
{{ if not .oslo_messaging_amqp.oslo.messaging.notify_address_prefix }}#{{ end }}notify_address_prefix = {{ .oslo_messaging_amqp.oslo.messaging.notify_address_prefix | default "openstack.org/om/notify" }}

# Appended to the address prefix when sending a fanout message. Used by the
# message bus to identify fanout messages. (string value)
# from .oslo_messaging_amqp.oslo.messaging.multicast_address
{{ if not .oslo_messaging_amqp.oslo.messaging.multicast_address }}#{{ end }}multicast_address = {{ .oslo_messaging_amqp.oslo.messaging.multicast_address | default "multicast" }}

# Appended to the address prefix when sending to a particular RPC/Notification
# server. Used by the message bus to identify messages sent to a single
# destination. (string value)
# from .oslo_messaging_amqp.oslo.messaging.unicast_address
{{ if not .oslo_messaging_amqp.oslo.messaging.unicast_address }}#{{ end }}unicast_address = {{ .oslo_messaging_amqp.oslo.messaging.unicast_address | default "unicast" }}

# Appended to the address prefix when sending to a group of consumers. Used by
# the message bus to identify messages that should be delivered in a round-
# robin fashion across consumers. (string value)
# from .oslo_messaging_amqp.oslo.messaging.anycast_address
{{ if not .oslo_messaging_amqp.oslo.messaging.anycast_address }}#{{ end }}anycast_address = {{ .oslo_messaging_amqp.oslo.messaging.anycast_address | default "anycast" }}

# Exchange name used in notification addresses.
# Exchange name resolution precedence:
# Target.exchange if set
# else default_notification_exchange if set
# else control_exchange if set
# else 'notify' (string value)
# from .oslo_messaging_amqp.oslo.messaging.default_notification_exchange
{{ if not .oslo_messaging_amqp.oslo.messaging.default_notification_exchange }}#{{ end }}default_notification_exchange = {{ .oslo_messaging_amqp.oslo.messaging.default_notification_exchange | default "<None>" }}

# Exchange name used in RPC addresses.
# Exchange name resolution precedence:
# Target.exchange if set
# else default_rpc_exchange if set
# else control_exchange if set
# else 'rpc' (string value)
# from .oslo_messaging_amqp.oslo.messaging.default_rpc_exchange
{{ if not .oslo_messaging_amqp.oslo.messaging.default_rpc_exchange }}#{{ end }}default_rpc_exchange = {{ .oslo_messaging_amqp.oslo.messaging.default_rpc_exchange | default "<None>" }}

# Window size for incoming RPC Reply messages. (integer value)
# Minimum value: 1
# from .oslo_messaging_amqp.oslo.messaging.reply_link_credit
{{ if not .oslo_messaging_amqp.oslo.messaging.reply_link_credit }}#{{ end }}reply_link_credit = {{ .oslo_messaging_amqp.oslo.messaging.reply_link_credit | default "200" }}

# Window size for incoming RPC Request messages (integer value)
# Minimum value: 1
# from .oslo_messaging_amqp.oslo.messaging.rpc_server_credit
{{ if not .oslo_messaging_amqp.oslo.messaging.rpc_server_credit }}#{{ end }}rpc_server_credit = {{ .oslo_messaging_amqp.oslo.messaging.rpc_server_credit | default "100" }}

# Window size for incoming Notification messages (integer value)
# Minimum value: 1
# from .oslo_messaging_amqp.oslo.messaging.notify_server_credit
{{ if not .oslo_messaging_amqp.oslo.messaging.notify_server_credit }}#{{ end }}notify_server_credit = {{ .oslo_messaging_amqp.oslo.messaging.notify_server_credit | default "100" }}


[oslo_messaging_notifications]

#
# From oslo.messaging
#

# The Drivers(s) to handle sending notifications. Possible values are
# messaging, messagingv2, routing, log, test, noop (multi valued)
# Deprecated group/name - [DEFAULT]/notification_driver
# from .oslo_messaging_notifications.oslo.messaging.driver (multiopt)
{{ if not .oslo_messaging_notifications.oslo.messaging.driver }}#driver = {{ .oslo_messaging_notifications.oslo.messaging.driver | default "" }}{{ else }}{{ range .oslo_messaging_notifications.oslo.messaging.driver }}driver = {{ . }}
{{ end }}{{ end }}

# A URL representing the messaging driver to use for notifications. If not set,
# we fall back to the same configuration used for RPC. (string value)
# Deprecated group/name - [DEFAULT]/notification_transport_url
# from .oslo_messaging_notifications.oslo.messaging.transport_url
{{ if not .oslo_messaging_notifications.oslo.messaging.transport_url }}#{{ end }}transport_url = {{ .oslo_messaging_notifications.oslo.messaging.transport_url | default "<None>" }}

# AMQP topic used for OpenStack notifications. (list value)
# Deprecated group/name - [rpc_notifier2]/topics
# Deprecated group/name - [DEFAULT]/notification_topics
# from .oslo_messaging_notifications.oslo.messaging.topics
{{ if not .oslo_messaging_notifications.oslo.messaging.topics }}#{{ end }}topics = {{ .oslo_messaging_notifications.oslo.messaging.topics | default "notifications" }}


[oslo_messaging_rabbit]

#
# From oslo.messaging
#

# Use durable queues in AMQP. (boolean value)
# Deprecated group/name - [DEFAULT]/amqp_durable_queues
# Deprecated group/name - [DEFAULT]/rabbit_durable_queues
# from .oslo_messaging_rabbit.oslo.messaging.amqp_durable_queues
{{ if not .oslo_messaging_rabbit.oslo.messaging.amqp_durable_queues }}#{{ end }}amqp_durable_queues = {{ .oslo_messaging_rabbit.oslo.messaging.amqp_durable_queues | default "false" }}

# Auto-delete queues in AMQP. (boolean value)
# Deprecated group/name - [DEFAULT]/amqp_auto_delete
# from .oslo_messaging_rabbit.oslo.messaging.amqp_auto_delete
{{ if not .oslo_messaging_rabbit.oslo.messaging.amqp_auto_delete }}#{{ end }}amqp_auto_delete = {{ .oslo_messaging_rabbit.oslo.messaging.amqp_auto_delete | default "false" }}

# SSL version to use (valid only if SSL enabled). Valid values are TLSv1 and
# SSLv23. SSLv2, SSLv3, TLSv1_1, and TLSv1_2 may be available on some
# distributions. (string value)
# Deprecated group/name - [DEFAULT]/kombu_ssl_version
# from .oslo_messaging_rabbit.oslo.messaging.kombu_ssl_version
{{ if not .oslo_messaging_rabbit.oslo.messaging.kombu_ssl_version }}#{{ end }}kombu_ssl_version = {{ .oslo_messaging_rabbit.oslo.messaging.kombu_ssl_version | default "" }}

# SSL key file (valid only if SSL enabled). (string value)
# Deprecated group/name - [DEFAULT]/kombu_ssl_keyfile
# from .oslo_messaging_rabbit.oslo.messaging.kombu_ssl_keyfile
{{ if not .oslo_messaging_rabbit.oslo.messaging.kombu_ssl_keyfile }}#{{ end }}kombu_ssl_keyfile = {{ .oslo_messaging_rabbit.oslo.messaging.kombu_ssl_keyfile | default "" }}

# SSL cert file (valid only if SSL enabled). (string value)
# Deprecated group/name - [DEFAULT]/kombu_ssl_certfile
# from .oslo_messaging_rabbit.oslo.messaging.kombu_ssl_certfile
{{ if not .oslo_messaging_rabbit.oslo.messaging.kombu_ssl_certfile }}#{{ end }}kombu_ssl_certfile = {{ .oslo_messaging_rabbit.oslo.messaging.kombu_ssl_certfile | default "" }}

# SSL certification authority file (valid only if SSL enabled). (string value)
# Deprecated group/name - [DEFAULT]/kombu_ssl_ca_certs
# from .oslo_messaging_rabbit.oslo.messaging.kombu_ssl_ca_certs
{{ if not .oslo_messaging_rabbit.oslo.messaging.kombu_ssl_ca_certs }}#{{ end }}kombu_ssl_ca_certs = {{ .oslo_messaging_rabbit.oslo.messaging.kombu_ssl_ca_certs | default "" }}

# How long to wait before reconnecting in response to an AMQP consumer cancel
# notification. (floating point value)
# Deprecated group/name - [DEFAULT]/kombu_reconnect_delay
# from .oslo_messaging_rabbit.oslo.messaging.kombu_reconnect_delay
{{ if not .oslo_messaging_rabbit.oslo.messaging.kombu_reconnect_delay }}#{{ end }}kombu_reconnect_delay = {{ .oslo_messaging_rabbit.oslo.messaging.kombu_reconnect_delay | default "1.0" }}

# EXPERIMENTAL: Possible values are: gzip, bz2. If not set compression will not
# be used. This option may not be available in future versions. (string value)
# from .oslo_messaging_rabbit.oslo.messaging.kombu_compression
{{ if not .oslo_messaging_rabbit.oslo.messaging.kombu_compression }}#{{ end }}kombu_compression = {{ .oslo_messaging_rabbit.oslo.messaging.kombu_compression | default "<None>" }}

# How long to wait a missing client before abandoning to send it its replies.
# This value should not be longer than rpc_response_timeout. (integer value)
# Deprecated group/name - [oslo_messaging_rabbit]/kombu_reconnect_timeout
# from .oslo_messaging_rabbit.oslo.messaging.kombu_missing_consumer_retry_timeout
{{ if not .oslo_messaging_rabbit.oslo.messaging.kombu_missing_consumer_retry_timeout }}#{{ end }}kombu_missing_consumer_retry_timeout = {{ .oslo_messaging_rabbit.oslo.messaging.kombu_missing_consumer_retry_timeout | default "60" }}

# Determines how the next RabbitMQ node is chosen in case the one we are
# currently connected to becomes unavailable. Takes effect only if more than
# one RabbitMQ node is provided in config. (string value)
# Allowed values: round-robin, shuffle
# from .oslo_messaging_rabbit.oslo.messaging.kombu_failover_strategy
{{ if not .oslo_messaging_rabbit.oslo.messaging.kombu_failover_strategy }}#{{ end }}kombu_failover_strategy = {{ .oslo_messaging_rabbit.oslo.messaging.kombu_failover_strategy | default "round-robin" }}

# DEPRECATED: The RabbitMQ broker address where a single node is used. (string
# value)
# Deprecated group/name - [DEFAULT]/rabbit_host
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# Reason: Replaced by [DEFAULT]/transport_url
# from .oslo_messaging_rabbit.oslo.messaging.rabbit_host
{{ if not .oslo_messaging_rabbit.oslo.messaging.rabbit_host }}#{{ end }}rabbit_host = {{ .oslo_messaging_rabbit.oslo.messaging.rabbit_host | default "localhost" }}

# DEPRECATED: The RabbitMQ broker port where a single node is used. (port
# value)
# Minimum value: 0
# Maximum value: 65535
# Deprecated group/name - [DEFAULT]/rabbit_port
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# Reason: Replaced by [DEFAULT]/transport_url
# from .oslo_messaging_rabbit.oslo.messaging.rabbit_port
{{ if not .oslo_messaging_rabbit.oslo.messaging.rabbit_port }}#{{ end }}rabbit_port = {{ .oslo_messaging_rabbit.oslo.messaging.rabbit_port | default "5672" }}

# DEPRECATED: RabbitMQ HA cluster host:port pairs. (list value)
# Deprecated group/name - [DEFAULT]/rabbit_hosts
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# Reason: Replaced by [DEFAULT]/transport_url
# from .oslo_messaging_rabbit.oslo.messaging.rabbit_hosts
{{ if not .oslo_messaging_rabbit.oslo.messaging.rabbit_hosts }}#{{ end }}rabbit_hosts = {{ .oslo_messaging_rabbit.oslo.messaging.rabbit_hosts | default "$rabbit_host:$rabbit_port" }}

# Connect over SSL for RabbitMQ. (boolean value)
# Deprecated group/name - [DEFAULT]/rabbit_use_ssl
# from .oslo_messaging_rabbit.oslo.messaging.rabbit_use_ssl
{{ if not .oslo_messaging_rabbit.oslo.messaging.rabbit_use_ssl }}#{{ end }}rabbit_use_ssl = {{ .oslo_messaging_rabbit.oslo.messaging.rabbit_use_ssl | default "false" }}

# DEPRECATED: The RabbitMQ userid. (string value)
# Deprecated group/name - [DEFAULT]/rabbit_userid
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# Reason: Replaced by [DEFAULT]/transport_url
# from .oslo_messaging_rabbit.oslo.messaging.rabbit_userid
{{ if not .oslo_messaging_rabbit.oslo.messaging.rabbit_userid }}#{{ end }}rabbit_userid = {{ .oslo_messaging_rabbit.oslo.messaging.rabbit_userid | default "guest" }}

# DEPRECATED: The RabbitMQ password. (string value)
# Deprecated group/name - [DEFAULT]/rabbit_password
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# Reason: Replaced by [DEFAULT]/transport_url
# from .oslo_messaging_rabbit.oslo.messaging.rabbit_password
{{ if not .oslo_messaging_rabbit.oslo.messaging.rabbit_password }}#{{ end }}rabbit_password = {{ .oslo_messaging_rabbit.oslo.messaging.rabbit_password | default "guest" }}

# The RabbitMQ login method. (string value)
# Deprecated group/name - [DEFAULT]/rabbit_login_method
# from .oslo_messaging_rabbit.oslo.messaging.rabbit_login_method
{{ if not .oslo_messaging_rabbit.oslo.messaging.rabbit_login_method }}#{{ end }}rabbit_login_method = {{ .oslo_messaging_rabbit.oslo.messaging.rabbit_login_method | default "AMQPLAIN" }}

# DEPRECATED: The RabbitMQ virtual host. (string value)
# Deprecated group/name - [DEFAULT]/rabbit_virtual_host
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# Reason: Replaced by [DEFAULT]/transport_url
# from .oslo_messaging_rabbit.oslo.messaging.rabbit_virtual_host
{{ if not .oslo_messaging_rabbit.oslo.messaging.rabbit_virtual_host }}#{{ end }}rabbit_virtual_host = {{ .oslo_messaging_rabbit.oslo.messaging.rabbit_virtual_host | default "/" }}

# How frequently to retry connecting with RabbitMQ. (integer value)
# from .oslo_messaging_rabbit.oslo.messaging.rabbit_retry_interval
{{ if not .oslo_messaging_rabbit.oslo.messaging.rabbit_retry_interval }}#{{ end }}rabbit_retry_interval = {{ .oslo_messaging_rabbit.oslo.messaging.rabbit_retry_interval | default "1" }}

# How long to backoff for between retries when connecting to RabbitMQ. (integer
# value)
# Deprecated group/name - [DEFAULT]/rabbit_retry_backoff
# from .oslo_messaging_rabbit.oslo.messaging.rabbit_retry_backoff
{{ if not .oslo_messaging_rabbit.oslo.messaging.rabbit_retry_backoff }}#{{ end }}rabbit_retry_backoff = {{ .oslo_messaging_rabbit.oslo.messaging.rabbit_retry_backoff | default "2" }}

# Maximum interval of RabbitMQ connection retries. Default is 30 seconds.
# (integer value)
# from .oslo_messaging_rabbit.oslo.messaging.rabbit_interval_max
{{ if not .oslo_messaging_rabbit.oslo.messaging.rabbit_interval_max }}#{{ end }}rabbit_interval_max = {{ .oslo_messaging_rabbit.oslo.messaging.rabbit_interval_max | default "30" }}

# DEPRECATED: Maximum number of RabbitMQ connection retries. Default is 0
# (infinite retry count). (integer value)
# Deprecated group/name - [DEFAULT]/rabbit_max_retries
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# from .oslo_messaging_rabbit.oslo.messaging.rabbit_max_retries
{{ if not .oslo_messaging_rabbit.oslo.messaging.rabbit_max_retries }}#{{ end }}rabbit_max_retries = {{ .oslo_messaging_rabbit.oslo.messaging.rabbit_max_retries | default "0" }}

# Try to use HA queues in RabbitMQ (x-ha-policy: all). If you change this
# option, you must wipe the RabbitMQ database. In RabbitMQ 3.0, queue mirroring
# is no longer controlled by the x-ha-policy argument when declaring a queue.
# If you just want to make sure that all queues (except  those with auto-
# generated names) are mirrored across all nodes, run: "rabbitmqctl set_policy
# HA '^(?!amq\.).*' '{"ha-mode": "all"}' " (boolean value)
# Deprecated group/name - [DEFAULT]/rabbit_ha_queues
# from .oslo_messaging_rabbit.oslo.messaging.rabbit_ha_queues
{{ if not .oslo_messaging_rabbit.oslo.messaging.rabbit_ha_queues }}#{{ end }}rabbit_ha_queues = {{ .oslo_messaging_rabbit.oslo.messaging.rabbit_ha_queues | default "false" }}

# Positive integer representing duration in seconds for queue TTL (x-expires).
# Queues which are unused for the duration of the TTL are automatically
# deleted. The parameter affects only reply and fanout queues. (integer value)
# Minimum value: 1
# from .oslo_messaging_rabbit.oslo.messaging.rabbit_transient_queues_ttl
{{ if not .oslo_messaging_rabbit.oslo.messaging.rabbit_transient_queues_ttl }}#{{ end }}rabbit_transient_queues_ttl = {{ .oslo_messaging_rabbit.oslo.messaging.rabbit_transient_queues_ttl | default "1800" }}

# Specifies the number of messages to prefetch. Setting to zero allows
# unlimited messages. (integer value)
# from .oslo_messaging_rabbit.oslo.messaging.rabbit_qos_prefetch_count
{{ if not .oslo_messaging_rabbit.oslo.messaging.rabbit_qos_prefetch_count }}#{{ end }}rabbit_qos_prefetch_count = {{ .oslo_messaging_rabbit.oslo.messaging.rabbit_qos_prefetch_count | default "0" }}

# Number of seconds after which the Rabbit broker is considered down if
# heartbeat's keep-alive fails (0 disable the heartbeat). EXPERIMENTAL (integer
# value)
# from .oslo_messaging_rabbit.oslo.messaging.heartbeat_timeout_threshold
{{ if not .oslo_messaging_rabbit.oslo.messaging.heartbeat_timeout_threshold }}#{{ end }}heartbeat_timeout_threshold = {{ .oslo_messaging_rabbit.oslo.messaging.heartbeat_timeout_threshold | default "60" }}

# How often times during the heartbeat_timeout_threshold we check the
# heartbeat. (integer value)
# from .oslo_messaging_rabbit.oslo.messaging.heartbeat_rate
{{ if not .oslo_messaging_rabbit.oslo.messaging.heartbeat_rate }}#{{ end }}heartbeat_rate = {{ .oslo_messaging_rabbit.oslo.messaging.heartbeat_rate | default "2" }}

# Deprecated, use rpc_backend=kombu+memory or rpc_backend=fake (boolean value)
# Deprecated group/name - [DEFAULT]/fake_rabbit
# from .oslo_messaging_rabbit.oslo.messaging.fake_rabbit
{{ if not .oslo_messaging_rabbit.oslo.messaging.fake_rabbit }}#{{ end }}fake_rabbit = {{ .oslo_messaging_rabbit.oslo.messaging.fake_rabbit | default "false" }}

# Maximum number of channels to allow (integer value)
# from .oslo_messaging_rabbit.oslo.messaging.channel_max
{{ if not .oslo_messaging_rabbit.oslo.messaging.channel_max }}#{{ end }}channel_max = {{ .oslo_messaging_rabbit.oslo.messaging.channel_max | default "<None>" }}

# The maximum byte size for an AMQP frame (integer value)
# from .oslo_messaging_rabbit.oslo.messaging.frame_max
{{ if not .oslo_messaging_rabbit.oslo.messaging.frame_max }}#{{ end }}frame_max = {{ .oslo_messaging_rabbit.oslo.messaging.frame_max | default "<None>" }}

# How often to send heartbeats for consumer's connections (integer value)
# from .oslo_messaging_rabbit.oslo.messaging.heartbeat_interval
{{ if not .oslo_messaging_rabbit.oslo.messaging.heartbeat_interval }}#{{ end }}heartbeat_interval = {{ .oslo_messaging_rabbit.oslo.messaging.heartbeat_interval | default "3" }}

# Enable SSL (boolean value)
# from .oslo_messaging_rabbit.oslo.messaging.ssl
{{ if not .oslo_messaging_rabbit.oslo.messaging.ssl }}#{{ end }}ssl = {{ .oslo_messaging_rabbit.oslo.messaging.ssl | default "<None>" }}

# Arguments passed to ssl.wrap_socket (dict value)
# from .oslo_messaging_rabbit.oslo.messaging.ssl_options
{{ if not .oslo_messaging_rabbit.oslo.messaging.ssl_options }}#{{ end }}ssl_options = {{ .oslo_messaging_rabbit.oslo.messaging.ssl_options | default "<None>" }}

# Set socket timeout in seconds for connection's socket (floating point value)
# from .oslo_messaging_rabbit.oslo.messaging.socket_timeout
{{ if not .oslo_messaging_rabbit.oslo.messaging.socket_timeout }}#{{ end }}socket_timeout = {{ .oslo_messaging_rabbit.oslo.messaging.socket_timeout | default "0.25" }}

# Set TCP_USER_TIMEOUT in seconds for connection's socket (floating point
# value)
# from .oslo_messaging_rabbit.oslo.messaging.tcp_user_timeout
{{ if not .oslo_messaging_rabbit.oslo.messaging.tcp_user_timeout }}#{{ end }}tcp_user_timeout = {{ .oslo_messaging_rabbit.oslo.messaging.tcp_user_timeout | default "0.25" }}

# Set delay for reconnection to some host which has connection error (floating
# point value)
# from .oslo_messaging_rabbit.oslo.messaging.host_connection_reconnect_delay
{{ if not .oslo_messaging_rabbit.oslo.messaging.host_connection_reconnect_delay }}#{{ end }}host_connection_reconnect_delay = {{ .oslo_messaging_rabbit.oslo.messaging.host_connection_reconnect_delay | default "0.25" }}

# Connection factory implementation (string value)
# Allowed values: new, single, read_write
# from .oslo_messaging_rabbit.oslo.messaging.connection_factory
{{ if not .oslo_messaging_rabbit.oslo.messaging.connection_factory }}#{{ end }}connection_factory = {{ .oslo_messaging_rabbit.oslo.messaging.connection_factory | default "single" }}

# Maximum number of connections to keep queued. (integer value)
# from .oslo_messaging_rabbit.oslo.messaging.pool_max_size
{{ if not .oslo_messaging_rabbit.oslo.messaging.pool_max_size }}#{{ end }}pool_max_size = {{ .oslo_messaging_rabbit.oslo.messaging.pool_max_size | default "30" }}

# Maximum number of connections to create above `pool_max_size`. (integer
# value)
# from .oslo_messaging_rabbit.oslo.messaging.pool_max_overflow
{{ if not .oslo_messaging_rabbit.oslo.messaging.pool_max_overflow }}#{{ end }}pool_max_overflow = {{ .oslo_messaging_rabbit.oslo.messaging.pool_max_overflow | default "0" }}

# Default number of seconds to wait for a connections to available (integer
# value)
# from .oslo_messaging_rabbit.oslo.messaging.pool_timeout
{{ if not .oslo_messaging_rabbit.oslo.messaging.pool_timeout }}#{{ end }}pool_timeout = {{ .oslo_messaging_rabbit.oslo.messaging.pool_timeout | default "30" }}

# Lifetime of a connection (since creation) in seconds or None for no
# recycling. Expired connections are closed on acquire. (integer value)
# from .oslo_messaging_rabbit.oslo.messaging.pool_recycle
{{ if not .oslo_messaging_rabbit.oslo.messaging.pool_recycle }}#{{ end }}pool_recycle = {{ .oslo_messaging_rabbit.oslo.messaging.pool_recycle | default "600" }}

# Threshold at which inactive (since release) connections are considered stale
# in seconds or None for no staleness. Stale connections are closed on acquire.
# (integer value)
# from .oslo_messaging_rabbit.oslo.messaging.pool_stale
{{ if not .oslo_messaging_rabbit.oslo.messaging.pool_stale }}#{{ end }}pool_stale = {{ .oslo_messaging_rabbit.oslo.messaging.pool_stale | default "60" }}

# Persist notification messages. (boolean value)
# from .oslo_messaging_rabbit.oslo.messaging.notification_persistence
{{ if not .oslo_messaging_rabbit.oslo.messaging.notification_persistence }}#{{ end }}notification_persistence = {{ .oslo_messaging_rabbit.oslo.messaging.notification_persistence | default "false" }}

# Exchange name for sending notifications (string value)
# from .oslo_messaging_rabbit.oslo.messaging.default_notification_exchange
{{ if not .oslo_messaging_rabbit.oslo.messaging.default_notification_exchange }}#{{ end }}default_notification_exchange = {{ .oslo_messaging_rabbit.oslo.messaging.default_notification_exchange | default "${control_exchange}_notification" }}

# Max number of not acknowledged message which RabbitMQ can send to
# notification listener. (integer value)
# from .oslo_messaging_rabbit.oslo.messaging.notification_listener_prefetch_count
{{ if not .oslo_messaging_rabbit.oslo.messaging.notification_listener_prefetch_count }}#{{ end }}notification_listener_prefetch_count = {{ .oslo_messaging_rabbit.oslo.messaging.notification_listener_prefetch_count | default "100" }}

# Reconnecting retry count in case of connectivity problem during sending
# notification, -1 means infinite retry. (integer value)
# from .oslo_messaging_rabbit.oslo.messaging.default_notification_retry_attempts
{{ if not .oslo_messaging_rabbit.oslo.messaging.default_notification_retry_attempts }}#{{ end }}default_notification_retry_attempts = {{ .oslo_messaging_rabbit.oslo.messaging.default_notification_retry_attempts | default "-1" }}

# Reconnecting retry delay in case of connectivity problem during sending
# notification message (floating point value)
# from .oslo_messaging_rabbit.oslo.messaging.notification_retry_delay
{{ if not .oslo_messaging_rabbit.oslo.messaging.notification_retry_delay }}#{{ end }}notification_retry_delay = {{ .oslo_messaging_rabbit.oslo.messaging.notification_retry_delay | default "0.25" }}

# Time to live for rpc queues without consumers in seconds. (integer value)
# from .oslo_messaging_rabbit.oslo.messaging.rpc_queue_expiration
{{ if not .oslo_messaging_rabbit.oslo.messaging.rpc_queue_expiration }}#{{ end }}rpc_queue_expiration = {{ .oslo_messaging_rabbit.oslo.messaging.rpc_queue_expiration | default "60" }}

# Exchange name for sending RPC messages (string value)
# from .oslo_messaging_rabbit.oslo.messaging.default_rpc_exchange
{{ if not .oslo_messaging_rabbit.oslo.messaging.default_rpc_exchange }}#{{ end }}default_rpc_exchange = {{ .oslo_messaging_rabbit.oslo.messaging.default_rpc_exchange | default "${control_exchange}_rpc" }}

# Exchange name for receiving RPC replies (string value)
# from .oslo_messaging_rabbit.oslo.messaging.rpc_reply_exchange
{{ if not .oslo_messaging_rabbit.oslo.messaging.rpc_reply_exchange }}#{{ end }}rpc_reply_exchange = {{ .oslo_messaging_rabbit.oslo.messaging.rpc_reply_exchange | default "${control_exchange}_rpc_reply" }}

# Max number of not acknowledged message which RabbitMQ can send to rpc
# listener. (integer value)
# from .oslo_messaging_rabbit.oslo.messaging.rpc_listener_prefetch_count
{{ if not .oslo_messaging_rabbit.oslo.messaging.rpc_listener_prefetch_count }}#{{ end }}rpc_listener_prefetch_count = {{ .oslo_messaging_rabbit.oslo.messaging.rpc_listener_prefetch_count | default "100" }}

# Max number of not acknowledged message which RabbitMQ can send to rpc reply
# listener. (integer value)
# from .oslo_messaging_rabbit.oslo.messaging.rpc_reply_listener_prefetch_count
{{ if not .oslo_messaging_rabbit.oslo.messaging.rpc_reply_listener_prefetch_count }}#{{ end }}rpc_reply_listener_prefetch_count = {{ .oslo_messaging_rabbit.oslo.messaging.rpc_reply_listener_prefetch_count | default "100" }}

# Reconnecting retry count in case of connectivity problem during sending
# reply. -1 means infinite retry during rpc_timeout (integer value)
# from .oslo_messaging_rabbit.oslo.messaging.rpc_reply_retry_attempts
{{ if not .oslo_messaging_rabbit.oslo.messaging.rpc_reply_retry_attempts }}#{{ end }}rpc_reply_retry_attempts = {{ .oslo_messaging_rabbit.oslo.messaging.rpc_reply_retry_attempts | default "-1" }}

# Reconnecting retry delay in case of connectivity problem during sending
# reply. (floating point value)
# from .oslo_messaging_rabbit.oslo.messaging.rpc_reply_retry_delay
{{ if not .oslo_messaging_rabbit.oslo.messaging.rpc_reply_retry_delay }}#{{ end }}rpc_reply_retry_delay = {{ .oslo_messaging_rabbit.oslo.messaging.rpc_reply_retry_delay | default "0.25" }}

# Reconnecting retry count in case of connectivity problem during sending RPC
# message, -1 means infinite retry. If actual retry attempts in not 0 the rpc
# request could be processed more then one time (integer value)
# from .oslo_messaging_rabbit.oslo.messaging.default_rpc_retry_attempts
{{ if not .oslo_messaging_rabbit.oslo.messaging.default_rpc_retry_attempts }}#{{ end }}default_rpc_retry_attempts = {{ .oslo_messaging_rabbit.oslo.messaging.default_rpc_retry_attempts | default "-1" }}

# Reconnecting retry delay in case of connectivity problem during sending RPC
# message (floating point value)
# from .oslo_messaging_rabbit.oslo.messaging.rpc_retry_delay
{{ if not .oslo_messaging_rabbit.oslo.messaging.rpc_retry_delay }}#{{ end }}rpc_retry_delay = {{ .oslo_messaging_rabbit.oslo.messaging.rpc_retry_delay | default "0.25" }}


[oslo_messaging_zmq]

#
# From oslo.messaging
#

# ZeroMQ bind address. Should be a wildcard (*), an ethernet interface, or IP.
# The "host" option should point or resolve to this address. (string value)
# Deprecated group/name - [DEFAULT]/rpc_zmq_bind_address
# from .oslo_messaging_zmq.oslo.messaging.rpc_zmq_bind_address
{{ if not .oslo_messaging_zmq.oslo.messaging.rpc_zmq_bind_address }}#{{ end }}rpc_zmq_bind_address = {{ .oslo_messaging_zmq.oslo.messaging.rpc_zmq_bind_address | default "*" }}

# MatchMaker driver. (string value)
# Allowed values: redis, dummy
# Deprecated group/name - [DEFAULT]/rpc_zmq_matchmaker
# from .oslo_messaging_zmq.oslo.messaging.rpc_zmq_matchmaker
{{ if not .oslo_messaging_zmq.oslo.messaging.rpc_zmq_matchmaker }}#{{ end }}rpc_zmq_matchmaker = {{ .oslo_messaging_zmq.oslo.messaging.rpc_zmq_matchmaker | default "redis" }}

# Number of ZeroMQ contexts, defaults to 1. (integer value)
# Deprecated group/name - [DEFAULT]/rpc_zmq_contexts
# from .oslo_messaging_zmq.oslo.messaging.rpc_zmq_contexts
{{ if not .oslo_messaging_zmq.oslo.messaging.rpc_zmq_contexts }}#{{ end }}rpc_zmq_contexts = {{ .oslo_messaging_zmq.oslo.messaging.rpc_zmq_contexts | default "1" }}

# Maximum number of ingress messages to locally buffer per topic. Default is
# unlimited. (integer value)
# Deprecated group/name - [DEFAULT]/rpc_zmq_topic_backlog
# from .oslo_messaging_zmq.oslo.messaging.rpc_zmq_topic_backlog
{{ if not .oslo_messaging_zmq.oslo.messaging.rpc_zmq_topic_backlog }}#{{ end }}rpc_zmq_topic_backlog = {{ .oslo_messaging_zmq.oslo.messaging.rpc_zmq_topic_backlog | default "<None>" }}

# Directory for holding IPC sockets. (string value)
# Deprecated group/name - [DEFAULT]/rpc_zmq_ipc_dir
# from .oslo_messaging_zmq.oslo.messaging.rpc_zmq_ipc_dir
{{ if not .oslo_messaging_zmq.oslo.messaging.rpc_zmq_ipc_dir }}#{{ end }}rpc_zmq_ipc_dir = {{ .oslo_messaging_zmq.oslo.messaging.rpc_zmq_ipc_dir | default "/var/run/openstack" }}

# Name of this node. Must be a valid hostname, FQDN, or IP address. Must match
# "host" option, if running Nova. (string value)
# Deprecated group/name - [DEFAULT]/rpc_zmq_host
# from .oslo_messaging_zmq.oslo.messaging.rpc_zmq_host
{{ if not .oslo_messaging_zmq.oslo.messaging.rpc_zmq_host }}#{{ end }}rpc_zmq_host = {{ .oslo_messaging_zmq.oslo.messaging.rpc_zmq_host | default "localhost" }}

# Seconds to wait before a cast expires (TTL). The default value of -1
# specifies an infinite linger period. The value of 0 specifies no linger
# period. Pending messages shall be discarded immediately when the socket is
# closed. Only supported by impl_zmq. (integer value)
# Deprecated group/name - [DEFAULT]/rpc_cast_timeout
# from .oslo_messaging_zmq.oslo.messaging.rpc_cast_timeout
{{ if not .oslo_messaging_zmq.oslo.messaging.rpc_cast_timeout }}#{{ end }}rpc_cast_timeout = {{ .oslo_messaging_zmq.oslo.messaging.rpc_cast_timeout | default "-1" }}

# The default number of seconds that poll should wait. Poll raises timeout
# exception when timeout expired. (integer value)
# Deprecated group/name - [DEFAULT]/rpc_poll_timeout
# from .oslo_messaging_zmq.oslo.messaging.rpc_poll_timeout
{{ if not .oslo_messaging_zmq.oslo.messaging.rpc_poll_timeout }}#{{ end }}rpc_poll_timeout = {{ .oslo_messaging_zmq.oslo.messaging.rpc_poll_timeout | default "1" }}

# Expiration timeout in seconds of a name service record about existing target
# ( < 0 means no timeout). (integer value)
# Deprecated group/name - [DEFAULT]/zmq_target_expire
# from .oslo_messaging_zmq.oslo.messaging.zmq_target_expire
{{ if not .oslo_messaging_zmq.oslo.messaging.zmq_target_expire }}#{{ end }}zmq_target_expire = {{ .oslo_messaging_zmq.oslo.messaging.zmq_target_expire | default "300" }}

# Update period in seconds of a name service record about existing target.
# (integer value)
# Deprecated group/name - [DEFAULT]/zmq_target_update
# from .oslo_messaging_zmq.oslo.messaging.zmq_target_update
{{ if not .oslo_messaging_zmq.oslo.messaging.zmq_target_update }}#{{ end }}zmq_target_update = {{ .oslo_messaging_zmq.oslo.messaging.zmq_target_update | default "180" }}

# Use PUB/SUB pattern for fanout methods. PUB/SUB always uses proxy. (boolean
# value)
# Deprecated group/name - [DEFAULT]/use_pub_sub
# from .oslo_messaging_zmq.oslo.messaging.use_pub_sub
{{ if not .oslo_messaging_zmq.oslo.messaging.use_pub_sub }}#{{ end }}use_pub_sub = {{ .oslo_messaging_zmq.oslo.messaging.use_pub_sub | default "true" }}

# Use ROUTER remote proxy. (boolean value)
# Deprecated group/name - [DEFAULT]/use_router_proxy
# from .oslo_messaging_zmq.oslo.messaging.use_router_proxy
{{ if not .oslo_messaging_zmq.oslo.messaging.use_router_proxy }}#{{ end }}use_router_proxy = {{ .oslo_messaging_zmq.oslo.messaging.use_router_proxy | default "true" }}

# Minimal port number for random ports range. (port value)
# Minimum value: 0
# Maximum value: 65535
# Deprecated group/name - [DEFAULT]/rpc_zmq_min_port
# from .oslo_messaging_zmq.oslo.messaging.rpc_zmq_min_port
{{ if not .oslo_messaging_zmq.oslo.messaging.rpc_zmq_min_port }}#{{ end }}rpc_zmq_min_port = {{ .oslo_messaging_zmq.oslo.messaging.rpc_zmq_min_port | default "49153" }}

# Maximal port number for random ports range. (integer value)
# Minimum value: 1
# Maximum value: 65536
# Deprecated group/name - [DEFAULT]/rpc_zmq_max_port
# from .oslo_messaging_zmq.oslo.messaging.rpc_zmq_max_port
{{ if not .oslo_messaging_zmq.oslo.messaging.rpc_zmq_max_port }}#{{ end }}rpc_zmq_max_port = {{ .oslo_messaging_zmq.oslo.messaging.rpc_zmq_max_port | default "65536" }}

# Number of retries to find free port number before fail with ZMQBindError.
# (integer value)
# Deprecated group/name - [DEFAULT]/rpc_zmq_bind_port_retries
# from .oslo_messaging_zmq.oslo.messaging.rpc_zmq_bind_port_retries
{{ if not .oslo_messaging_zmq.oslo.messaging.rpc_zmq_bind_port_retries }}#{{ end }}rpc_zmq_bind_port_retries = {{ .oslo_messaging_zmq.oslo.messaging.rpc_zmq_bind_port_retries | default "100" }}

# Default serialization mechanism for serializing/deserializing
# outgoing/incoming messages (string value)
# Allowed values: json, msgpack
# Deprecated group/name - [DEFAULT]/rpc_zmq_serialization
# from .oslo_messaging_zmq.oslo.messaging.rpc_zmq_serialization
{{ if not .oslo_messaging_zmq.oslo.messaging.rpc_zmq_serialization }}#{{ end }}rpc_zmq_serialization = {{ .oslo_messaging_zmq.oslo.messaging.rpc_zmq_serialization | default "json" }}

# This option configures round-robin mode in zmq socket. True means not keeping
# a queue when server side disconnects. False means to keep queue and messages
# even if server is disconnected, when the server appears we send all
# accumulated messages to it. (boolean value)
# from .oslo_messaging_zmq.oslo.messaging.zmq_immediate
{{ if not .oslo_messaging_zmq.oslo.messaging.zmq_immediate }}#{{ end }}zmq_immediate = {{ .oslo_messaging_zmq.oslo.messaging.zmq_immediate | default "false" }}


[oslo_middleware]

#
# From oslo.middleware
#

# The maximum body size for each  request, in bytes. (integer value)
# Deprecated group/name - [DEFAULT]/osapi_max_request_body_size
# Deprecated group/name - [DEFAULT]/max_request_body_size
# from .oslo_middleware.oslo.middleware.max_request_body_size
{{ if not .oslo_middleware.oslo.middleware.max_request_body_size }}#{{ end }}max_request_body_size = {{ .oslo_middleware.oslo.middleware.max_request_body_size | default "114688" }}

# DEPRECATED: The HTTP Header that will be used to determine what the original
# request protocol scheme was, even if it was hidden by a SSL termination
# proxy. (string value)
# This option is deprecated for removal.
# Its value may be silently ignored in the future.
# from .oslo_middleware.oslo.middleware.secure_proxy_ssl_header
{{ if not .oslo_middleware.oslo.middleware.secure_proxy_ssl_header }}#{{ end }}secure_proxy_ssl_header = {{ .oslo_middleware.oslo.middleware.secure_proxy_ssl_header | default "X-Forwarded-Proto" }}

# Whether the application is behind a proxy or not. This determines if the
# middleware should parse the headers or not. (boolean value)
# from .oslo_middleware.oslo.middleware.enable_proxy_headers_parsing
{{ if not .oslo_middleware.oslo.middleware.enable_proxy_headers_parsing }}#{{ end }}enable_proxy_headers_parsing = {{ .oslo_middleware.oslo.middleware.enable_proxy_headers_parsing | default "false" }}


[oslo_policy]

#
# From oslo.policy
#

# The JSON file that defines policies. (string value)
# Deprecated group/name - [DEFAULT]/policy_file
# from .oslo_policy.oslo.policy.policy_file
{{ if not .oslo_policy.oslo.policy.policy_file }}#{{ end }}policy_file = {{ .oslo_policy.oslo.policy.policy_file | default "policy.json" }}

# Default rule. Enforced when a requested rule is not found. (string value)
# Deprecated group/name - [DEFAULT]/policy_default_rule
# from .oslo_policy.oslo.policy.policy_default_rule
{{ if not .oslo_policy.oslo.policy.policy_default_rule }}#{{ end }}policy_default_rule = {{ .oslo_policy.oslo.policy.policy_default_rule | default "default" }}

# Directories where policy configuration files are stored. They can be relative
# to any directory in the search path defined by the config_dir option, or
# absolute paths. The file defined by policy_file must exist for these
# directories to be searched.  Missing or empty directories are ignored. (multi
# valued)
# Deprecated group/name - [DEFAULT]/policy_dirs
# from .oslo_policy.oslo.policy.policy_dirs (multiopt)
{{ if not .oslo_policy.oslo.policy.policy_dirs }}#policy_dirs = {{ .oslo_policy.oslo.policy.policy_dirs | default "policy.d" }}{{ else }}{{ range .oslo_policy.oslo.policy.policy_dirs }}policy_dirs = {{ . }}
{{ end }}{{ end }}


[paste_deploy]

#
# From heat.common.config
#

# The flavor to use. (string value)
# from .paste_deploy.heat.common.config.flavor
{{ if not .paste_deploy.heat.common.config.flavor }}#{{ end }}flavor = {{ .paste_deploy.heat.common.config.flavor | default "<None>" }}

# The API paste config file to use. (string value)
# from .paste_deploy.heat.common.config.api_paste_config
{{ if not .paste_deploy.heat.common.config.api_paste_config }}#{{ end }}api_paste_config = {{ .paste_deploy.heat.common.config.api_paste_config | default "api-paste.ini" }}


[profiler]

#
# From heat.common.config
#

#
# Enables the profiling for all services on this node. Default value is False
# (fully disable the profiling feature).
#
# Possible values:
#
# * True: Enables the feature
# * False: Disables the feature. The profiling cannot be started via this
# project
# operations. If the profiling is triggered by another project, this project
# part
# will be empty.
#  (boolean value)
# Deprecated group/name - [profiler]/profiler_enabled
# from .profiler.heat.common.config.enabled
{{ if not .profiler.heat.common.config.enabled }}#{{ end }}enabled = {{ .profiler.heat.common.config.enabled | default "false" }}

#
# Enables SQL requests profiling in services. Default value is False (SQL
# requests won't be traced).
#
# Possible values:
#
# * True: Enables SQL requests profiling. Each SQL query will be part of the
# trace and can the be analyzed by how much time was spent for that.
# * False: Disables SQL requests profiling. The spent time is only shown on a
# higher level of operations. Single SQL queries cannot be analyzed this
# way.
#  (boolean value)
# from .profiler.heat.common.config.trace_sqlalchemy
{{ if not .profiler.heat.common.config.trace_sqlalchemy }}#{{ end }}trace_sqlalchemy = {{ .profiler.heat.common.config.trace_sqlalchemy | default "false" }}

#
# Secret key(s) to use for encrypting context data for performance profiling.
# This string value should have the following format:
# <key1>[,<key2>,...<keyn>],
# where each key is some random string. A user who triggers the profiling via
# the REST API has to set one of these keys in the headers of the REST API call
# to include profiling results of this node for this particular project.
#
# Both "enabled" flag and "hmac_keys" config options should be set to enable
# profiling. Also, to generate correct profiling information across all
# services
# at least one key needs to be consistent between OpenStack projects. This
# ensures it can be used from client side to generate the trace, containing
# information from all possible resources. (string value)
# from .profiler.heat.common.config.hmac_keys
{{ if not .profiler.heat.common.config.hmac_keys }}#{{ end }}hmac_keys = {{ .profiler.heat.common.config.hmac_keys | default "SECRET_KEY" }}

#
# Connection string for a notifier backend. Default value is messaging:// which
# sets the notifier to oslo_messaging.
#
# Examples of possible values:
#
# * messaging://: use oslo_messaging driver for sending notifications.
#  (string value)
# from .profiler.heat.common.config.connection_string
{{ if not .profiler.heat.common.config.connection_string }}#{{ end }}connection_string = {{ .profiler.heat.common.config.connection_string | default "messaging://" }}


[revision]

#
# From heat.common.config
#

# Heat build revision. If you would prefer to manage your build revision
# separately, you can move this section to a different file and add it as
# another config option. (string value)
# from .revision.heat.common.config.heat_revision
{{ if not .revision.heat.common.config.heat_revision }}#{{ end }}heat_revision = {{ .revision.heat.common.config.heat_revision | default "unknown" }}


[ssl]

#
# From oslo.service.sslutils
#

# CA certificate file to use to verify connecting clients. (string value)
# Deprecated group/name - [DEFAULT]/ssl_ca_file
# from .ssl.oslo.service.sslutils.ca_file
{{ if not .ssl.oslo.service.sslutils.ca_file }}#{{ end }}ca_file = {{ .ssl.oslo.service.sslutils.ca_file | default "<None>" }}

# Certificate file to use when starting the server securely. (string value)
# Deprecated group/name - [DEFAULT]/ssl_cert_file
# from .ssl.oslo.service.sslutils.cert_file
{{ if not .ssl.oslo.service.sslutils.cert_file }}#{{ end }}cert_file = {{ .ssl.oslo.service.sslutils.cert_file | default "<None>" }}

# Private key file to use when starting the server securely. (string value)
# Deprecated group/name - [DEFAULT]/ssl_key_file
# from .ssl.oslo.service.sslutils.key_file
{{ if not .ssl.oslo.service.sslutils.key_file }}#{{ end }}key_file = {{ .ssl.oslo.service.sslutils.key_file | default "<None>" }}

# SSL version to use (valid only if SSL enabled). Valid values are TLSv1 and
# SSLv23. SSLv2, SSLv3, TLSv1_1, and TLSv1_2 may be available on some
# distributions. (string value)
# from .ssl.oslo.service.sslutils.version
{{ if not .ssl.oslo.service.sslutils.version }}#{{ end }}version = {{ .ssl.oslo.service.sslutils.version | default "<None>" }}

# Sets the list of available ciphers. value should be a string in the OpenSSL
# cipher list format. (string value)
# from .ssl.oslo.service.sslutils.ciphers
{{ if not .ssl.oslo.service.sslutils.ciphers }}#{{ end }}ciphers = {{ .ssl.oslo.service.sslutils.ciphers | default "<None>" }}


[trustee]

#
# From heat.common.context
#

# Authentication type to load (string value)
# Deprecated group/name - [trustee]/auth_plugin
# from .trustee.heat.common.context.auth_type
{{ if not .trustee.heat.common.context.auth_type }}#{{ end }}auth_type = {{ .trustee.heat.common.context.auth_type | default "<None>" }}

# Config Section from which to load plugin specific options (string value)
# from .trustee.heat.common.context.auth_section
{{ if not .trustee.heat.common.context.auth_section }}#{{ end }}auth_section = {{ .trustee.heat.common.context.auth_section | default "<None>" }}

# Authentication URL (string value)
# from .trustee.heat.common.context.auth_url
{{ if not .trustee.heat.common.context.auth_url }}#{{ end }}auth_url = {{ .trustee.heat.common.context.auth_url | default "<None>" }}

# Domain ID to scope to (string value)
# from .trustee.heat.common.context.domain_id
{{ if not .trustee.heat.common.context.domain_id }}#{{ end }}domain_id = {{ .trustee.heat.common.context.domain_id | default "<None>" }}

# Domain name to scope to (string value)
# from .trustee.heat.common.context.domain_name
{{ if not .trustee.heat.common.context.domain_name }}#{{ end }}domain_name = {{ .trustee.heat.common.context.domain_name | default "<None>" }}

# Project ID to scope to (string value)
# Deprecated group/name - [trustee]/tenant-id
# from .trustee.heat.common.context.project_id
{{ if not .trustee.heat.common.context.project_id }}#{{ end }}project_id = {{ .trustee.heat.common.context.project_id | default "<None>" }}

# Project name to scope to (string value)
# Deprecated group/name - [trustee]/tenant-name
# from .trustee.heat.common.context.project_name
{{ if not .trustee.heat.common.context.project_name }}#{{ end }}project_name = {{ .trustee.heat.common.context.project_name | default "<None>" }}

# Domain ID containing project (string value)
# from .trustee.heat.common.context.project_domain_id
{{ if not .trustee.heat.common.context.project_domain_id }}#{{ end }}project_domain_id = {{ .trustee.heat.common.context.project_domain_id | default "<None>" }}

# Domain name containing project (string value)
# from .trustee.heat.common.context.project_domain_name
{{ if not .trustee.heat.common.context.project_domain_name }}#{{ end }}project_domain_name = {{ .trustee.heat.common.context.project_domain_name | default "<None>" }}

# Trust ID (string value)
# from .trustee.heat.common.context.trust_id
{{ if not .trustee.heat.common.context.trust_id }}#{{ end }}trust_id = {{ .trustee.heat.common.context.trust_id | default "<None>" }}

# Optional domain ID to use with v3 and v2 parameters. It will be used for both
# the user and project domain in v3 and ignored in v2 authentication. (string
# value)
# from .trustee.heat.common.context.default_domain_id
{{ if not .trustee.heat.common.context.default_domain_id }}#{{ end }}default_domain_id = {{ .trustee.heat.common.context.default_domain_id | default "<None>" }}

# Optional domain name to use with v3 API and v2 parameters. It will be used
# for both the user and project domain in v3 and ignored in v2 authentication.
# (string value)
# from .trustee.heat.common.context.default_domain_name
{{ if not .trustee.heat.common.context.default_domain_name }}#{{ end }}default_domain_name = {{ .trustee.heat.common.context.default_domain_name | default "<None>" }}

# User id (string value)
# from .trustee.heat.common.context.user_id
{{ if not .trustee.heat.common.context.user_id }}#{{ end }}user_id = {{ .trustee.heat.common.context.user_id | default "<None>" }}

# Username (string value)
# Deprecated group/name - [trustee]/user-name
# from .trustee.heat.common.context.username
{{ if not .trustee.heat.common.context.username }}#{{ end }}username = {{ .trustee.heat.common.context.username | default "<None>" }}

# User's domain id (string value)
# from .trustee.heat.common.context.user_domain_id
{{ if not .trustee.heat.common.context.user_domain_id }}#{{ end }}user_domain_id = {{ .trustee.heat.common.context.user_domain_id | default "<None>" }}

# User's domain name (string value)
# from .trustee.heat.common.context.user_domain_name
{{ if not .trustee.heat.common.context.user_domain_name }}#{{ end }}user_domain_name = {{ .trustee.heat.common.context.user_domain_name | default "<None>" }}

# User's password (string value)
# from .trustee.heat.common.context.password
{{ if not .trustee.heat.common.context.password }}#{{ end }}password = {{ .trustee.heat.common.context.password | default "<None>" }}


[volumes]

#
# From heat.common.config
#

# Indicate if cinder-backup service is enabled. This is a temporary workaround
# until cinder-backup service becomes discoverable, see LP#1334856. (boolean
# value)
# from .volumes.heat.common.config.backups_enabled
{{ if not .volumes.heat.common.config.backups_enabled }}#{{ end }}backups_enabled = {{ .volumes.heat.common.config.backups_enabled | default "true" }}

{{- end -}}
