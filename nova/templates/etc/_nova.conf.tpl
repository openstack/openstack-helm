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
api_servers = {{ include "endpoint_glance_api_internal" . }}
num_retries = 3

[cinder]
catalog_info = volume:cinder:internalURL

[neutron]
url = {{ include "endpoint_neutron_api_internal" . }}

metadata_proxy_shared_secret = {{ .Values.neutron.metadata_secret }}
service_metadata_proxy = True

auth_url = {{ include "endpoint_keystone_admin" . }}
auth_type = password
project_domain_name = default
user_domain_id = default
project_name = service
username = {{ .Values.keystone.neutron_user }}
password = {{ .Values.keystone.neutron_password }}

[database]
connection = mysql+pymysql://{{ .Values.database.nova_user }}:{{ .Values.database.nova_password }}@{{ .Values.database.address }}/{{ .Values.database.nova_database_name }}
max_retries = -1

[api_database]
connection = mysql+pymysql://{{ .Values.database.nova_user }}:{{ .Values.database.nova_password }}@{{ .Values.database.address }}/{{ .Values.database.nova_api_database_name }}
max_retries = -1

[keystone_authtoken]
auth_uri = {{ include "endpoint_keystone_internal" . }}
auth_url = {{ include "endpoint_keystone_admin" . }}
auth_type = password
project_domain_id = default
user_domain_id = default
project_name = service
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
memcache_servers = {{ .Values.memcached.address }}

[wsgi]
api_paste_config = /etc/nova/api-paste.ini
