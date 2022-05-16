[DEFAULT]
allow_resize_to_same_host = true
block_device_allocate_retries = 600
block_device_allocate_retries_interval = 10
compute_driver = libvirt.LibvirtDriver
cpu_allocation_ratio = 8
default_ephemeral_format = ext4
default_schedule_zone = nova
disk_allocation_ratio = 1.6
firewall_driver = nova.virt.firewall.NoopFirewallDriver
instance_usage_audit = true
instance_usage_audit_period = hour
linuxnet_interface_driver = openvswitch
log_config_append = /etc/nova/logging.conf
metadata_host = metadata.setup1.triliodata.demo
metadata_port = 443
metadata_workers = 1
my_ip = 0.0.0.0
notify_on_state_change = vm_and_task_state
osapi_compute_listen = 0.0.0.0
osapi_compute_listen_port = 8774
osapi_compute_workers = 1
ram_allocation_ratio = 1.1
report_interval = 30
resume_guests_state_on_host_boot = true
rpc_response_timeout = 60
service_down_time = 180
state_path = /var/lib/nova
transport_url = rabbit://novagD3Q:LDA4DP41yRX3UNjFimFvb4dHIDWpPtZc@openstack-rabbitmq-rabbitmq-0.rabbitmq.openstack.svc.cluster.local:5672/nova
use_neutron = true
[api]
vendordata_jsonfile_path = /etc/nova/vendordata.json
vendordata_providers = StaticJSON
[cache]
backend = oslo_cache.memcache_pool
enabled = true
memcache_servers = openstack-memcached-memcached-0.memcached.openstack.svc.cluster.local:11211,openstack-memcached-memcached-1.memcached.openstack.svc.cluster.local:11211,openstack-memcached-memcached-2.memcached.openstack.svc.cluster.local:11211
[cinder]
catalog_info = volumev3:cinderv3:internalURL
[conductor]
workers = 1
[filter_scheduler]
enabled_filters = AvailabilityZoneFilter,ComputeFilter,ComputeCapabilitiesFilter,ImagePropertiesFilter,ServerGroupAntiAffinityFilter,ServerGroupAffinityFilter,NUMATopologyFilter,PciPassthroughFilter
host_subset_size = 3
[glance]
api_servers = http://glance-api.openstack.svc.cluster.local:9292
num_retries = 3
[ironic]
api_endpoint = http://ironic-api.openstack.svc.cluster.local:6385
auth_type = password
auth_url = http://keystone-api.openstack.svc.cluster.local:5000/v3
auth_version = v3
memcache_secret_key = MiNbzW1PYEKC51Ci
memcache_security_strategy = ENCRYPT
memcache_servers = openstack-memcached-memcached-0.memcached.openstack.svc.cluster.local:11211,openstack-memcached-memcached-1.memcached.openstack.svc.cluster.local:11211,openstack-memcached-memcached-2.memcached.openstack.svc.cluster.local:11211
password = password
project_domain_name = service
project_name = service
region_name = RegionOne
user_domain_name = service
username = ironic
[keystone_authtoken]
auth_type = password
auth_uri = http://keystone-api.openstack.svc.cluster.local:5000/v3
auth_url = http://keystone-api.openstack.svc.cluster.local:5000/v3
auth_version = v3
memcache_secret_key = MiNbzW1PYEKC51Ci
memcache_security_strategy = ENCRYPT
memcached_servers = openstack-memcached-memcached-0.memcached.openstack.svc.cluster.local:11211,openstack-memcached-memcached-1.memcached.openstack.svc.cluster.local:11211,openstack-memcached-memcached-2.memcached.openstack.svc.cluster.local:11211
password = dV5EXhQqs4nB4VnTzLgGuUzAYNBIvegh
project_domain_name = service
project_name = service
region_name = RegionOne
user_domain_name = service
username = novaejbz
[libvirt]
connection_uri = qemu+tcp://127.0.0.1/system
cpu_mode = host-model
disk_cachemodes = network=writeback
hw_disk_discard = unmap
images_rbd_ceph_conf = /etc/ceph/ceph.conf
images_rbd_pool = vms-hdd
images_type = rbd
live_migration_use_ip_to_scp_configdrive = true
rbd_secret_uuid = 457eb676-33da-42ec-9a8c-9293d545c337
rbd_user = nova
virt_type = kvm
[neutron]
auth_type = password
auth_url = http://keystone-api.openstack.svc.cluster.local:5000/v3
auth_version = v3
metadata_proxy_shared_secret = zbqbHPMY6iD8jQyz59eFnS7jxTjvUX6y
password = n5dC8ulWUX7NDKwvHyhyh8SnB5SF2w1e
project_domain_name = service
project_name = service
region_name = RegionOne
service_metadata_proxy = true
timeout = 300
url = http://neutron-server.openstack.svc.cluster.local:9696
user_domain_name = service
username = neutronCpA587s
[os_vif_ovs]
isolate_vif = true
[oslo_concurrency]
lock_path = /var/lib/openstack/lock
[oslo_messaging_notifications]
driver = messagingv2
topics = notifications,stacklight_notifications
transport_url = rabbit://novauZgh:BkQ1ZAKKFxXUKCJbzGPDMN4Wi3bSffRf@openstack-rabbitmq-rabbitmq-0.rabbitmq.openstack.svc.cluster.local:5672/openstack
[oslo_messaging_rabbit]
rabbit_ha_queues = true
rabbit_qos_prefetch_count = 64
[oslo_middleware]
enable_proxy_headers_parsing = true
[oslo_policy]
policy_dirs = /etc/nova/policy.d/
policy_file = /etc/nova/policy.yaml
[pci]
[placement]
auth_type = password
auth_url = http://keystone-api.openstack.svc.cluster.local:5000/v3
auth_version = v3
os_region_name = RegionOne
password = aCB2uYXlnH0zbcjq6T0KHEk8RZTYx7MT
project_domain_name = service
project_name = service
user_domain_name = service
username = placementC7d8sw9tB
[placement_database]
connection_recycle_time = 300
max_overflow = 30
max_pool_size = 10
max_retries = -1
[scheduler]
workers = 1
[service_user]
auth_type = password
auth_url = http://keystone-api.openstack.svc.cluster.local:5000/v3
password = dV5EXhQqs4nB4VnTzLgGuUzAYNBIvegh
project_domain_name = service
project_name = service
region_name = RegionOne
send_service_user_token = true
user_domain_name = service
username = novaejbz
[spice]
html5proxy_host = 0.0.0.0
server_listen = 0.0.0.0
[upgrade_levels]
compute = auto
[vnc]
enabled = true
novncproxy_base_url = https://novncproxy.setup1.triliodata.demo/vnc_auto.html
novncproxy_host = 0.0.0.0
novncproxy_port = 6080
vncserver_listen = 0.0.0.0
[wsgi]
api_paste_config = /etc/nova/api-paste.ini
