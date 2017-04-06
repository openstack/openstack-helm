# Copyright 2017 The Openstack-Helm Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

[DEFAULT]
debug = {{ .Values.neutron.default.debug }}
use_syslog = False
use_stderr = True

bind_host = {{ .Values.network.ip_address }}
bind_port = {{ .Values.network.server.port }}

#lock_path = /var/lock/neutron
api_paste_config = /usr/share/neutron/api-paste.ini

api_workers = {{ .Values.neutron.workers }}

allow_overlapping_ips = True
core_plugin = ml2
service_plugins = router

interface_driver = openvswitch

metadata_proxy_socket = /var/lib/neutron/openstack-helm/metadata_proxy

allow_automatic_l3agent_failover = True
l3_ha = true
min_l3_agents_per_router = 1
max_l3_agents_per_router = 2
l3_ha_network_type = {{ .Values.neutron.default.l3_ha_network_type }}

dhcp_agents_per_network = 3

network_auto_schedule = True
router_auto_schedule = True

transport_url = rabbit://{{ .Values.rabbitmq.admin_user }}:{{ .Values.rabbitmq.admin_password }}@{{ .Values.rabbitmq.address }}:{{ .Values.rabbitmq.port }}

[nova]
memcached_servers = "{{ .Values.memcached.host }}:{{ .Values.memcached.port }}"
auth_version = v3
auth_url = {{ tuple "identity" "internal" "api" . | include "helm-toolkit.keystone_endpoint_uri_lookup" }}
auth_type = password
region_name = {{ .Values.keystone.nova_region_name }}
project_domain_name = {{ .Values.keystone.nova_project_domain }}
project_name = {{ .Values.keystone.nova_project_name }}
user_domain_name = {{ .Values.keystone.nova_user_domain }}
username = {{ .Values.keystone.nova_user }}
password = {{ .Values.keystone.nova_password }}

[oslo_concurrency]
lock_path = /var/lib/neutron/tmp

[ovs]
ovsdb_connection = unix:/var/run/openvswitch/db.sock

[agent]
root_helper = sudo /var/lib/kolla/venv/bin/neutron-rootwrap /etc/neutron/rootwrap.conf
l2_population = true
arp_responder = true

[database]
connection = {{ tuple "oslo_db" "internal" "user" "mysql" . | include "helm-toolkit.authenticated_endpoint_uri_lookup" }}
max_retries = -1

[keystone_authtoken]
memcached_servers = "{{ .Values.memcached.host }}:{{ .Values.memcached.port }}"
auth_version = v3
auth_url = {{ tuple "identity" "internal" "api" . | include "helm-toolkit.keystone_endpoint_uri_lookup" }}
auth_type = password
region_name = {{ .Values.keystone.neutron_region_name }}
project_domain_name = {{ .Values.keystone.neutron_project_domain }}
project_name = {{ .Values.keystone.neutron_project_name }}
user_domain_name = {{ .Values.keystone.neutron_user_domain }}
username = {{ .Values.keystone.neutron_user }}
password = {{ .Values.keystone.neutron_password }}

[oslo_messaging_notifications]
driver = noop
