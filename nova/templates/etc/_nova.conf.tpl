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
debug = {{ .Values.nova.default.debug }}
default_ephemeral_format = ext4
host_subset_size = 30
ram_allocation_ratio=1.0
disk_allocation_ratio=1.0
cpu_allocation_ratio=3.0
force_config_drive = {{ .Values.nova.default.force_config_drive }}
state_path = /var/lib/nova

osapi_compute_listen = {{ .Values.network.ip_address }}
osapi_compute_listen_port = {{ .Values.network.port.osapi }}
osapi_compute_workers = {{ .Values.nova.default.osapi_workers }}

workers = {{ .Values.nova.default.osapi_workers }}
metadata_workers = {{ .Values.nova.default.metadata_workers }}

use_neutron = True
firewall_driver = nova.virt.firewall.NoopFirewallDriver
linuxnet_interface_driver = openvswitch

allow_resize_to_same_host = True

compute_driver = libvirt.LibvirtDriver

# Though my_ip is not used directly, lots of other variables use $my_ip
my_ip = {{ .Values.network.ip_address }}

transport_url = rabbit://{{ .Values.rabbitmq.admin_user }}:{{ .Values.rabbitmq.admin_password }}@{{ .Values.rabbitmq.address }}:{{ .Values.rabbitmq.port }}

[vnc]
novncproxy_host = {{ .Values.network.ip_address }}
novncproxy_port = {{ .Values.network.port.novncproxy }}
vncserver_listen = 0.0.0.0
vncserver_proxyclient_address = {{ .Values.network.ip_address }}

novncproxy_base_url = http://{{ .Values.network.external_ips }}:{{ .Values.network.port.novncproxy }}/vnc_auto.html

[oslo_concurrency]
lock_path = /var/lib/nova/tmp

[conductor]
workers = {{ .Values.nova.default.conductor_workers }}

[glance]
api_servers = {{ tuple "image" "internal" "api" . | include "helm-toolkit.keystone_endpoint_uri_lookup" }}
num_retries = 3

[cinder]
catalog_info = volume:cinder:internalURL

[neutron]
url = {{ tuple "network" "internal" "api" . | include "helm-toolkit.keystone_endpoint_uri_lookup" }}

metadata_proxy_shared_secret = {{ .Values.neutron.metadata_secret }}
service_metadata_proxy = True

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

[database]
connection = mysql+pymysql://{{ .Values.database.nova_user }}:{{ .Values.database.nova_password }}@{{ .Values.database.address }}/{{ .Values.database.nova_database_name }}
max_retries = -1

[api_database]
connection = mysql+pymysql://{{ .Values.database.nova_user }}:{{ .Values.database.nova_password }}@{{ .Values.database.address }}/{{ .Values.database.nova_api_database_name }}
max_retries = -1

[keystone_authtoken]
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

[libvirt]
connection_uri = "qemu+tcp://127.0.0.1/system"
images_type = qcow2
# Enabling live-migration without hostname resolution
# live_migration_inbound_addr = {{ .Values.network.ip_address }}

{{- if .Values.ceph.enabled }}
images_rbd_pool = {{ .Values.ceph.nova_pool }}
images_rbd_ceph_conf = /etc/ceph/ceph.conf
rbd_user = {{ .Values.ceph.cinder_user }}
rbd_secret_uuid = {{ .Values.ceph.secret_uuid }}
{{- end }}
disk_cachemodes="network=writeback"
hw_disk_discard = unmap

[upgrade_levels]
compute = auto

[cache]
enabled = True
backend = oslo_cache.memcache_pool
memcache_servers = "{{ .Values.memcached.host }}:{{ .Values.memcached.port }}"

[wsgi]
api_paste_config = /etc/nova/api-paste.ini
