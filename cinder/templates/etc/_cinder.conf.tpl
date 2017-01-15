[DEFAULT]
debug = {{ .Values.misc.debug }}
use_syslog = False
use_stderr = True

enable_v1_api = false
volume_name_template = %s

osapi_volume_workers = {{ .Values.api.workers }}
osapi_volume_listen = 0.0.0.0
osapi_volume_listen_port = {{ .Values.service.api.port }}

api_paste_config = /etc/cinder/api-paste.ini

glance_api_servers = "{{ .Values.glance.proto }}://{{ .Values.glance.host }}:{{ .Values.glance.port }}"
glance_api_version = {{ .Values.glance.version }}

enabled_backends = {{  include "joinListWithColon" .Values.backends.enabled }}

auth_strategy = keystone
os_region_name = {{ .Values.keystone.cinder_region_name }}

# ensures that our volume worker service-list doesn't
# explode with dead agents from terminated containers
# by pinning the agent identifier
host=cinder-volume-worker

[database]
connection = mysql+pymysql://{{ .Values.database.cinder_user }}:{{ .Values.database.cinder_password }}@{{ .Values.database.address }}:{{ .Values.database.port }}/{{ .Values.database.cinder_database_name }}
max_retries = -1

[keystone_authtoken]
auth_url = {{ .Values.keystone.auth_url }}
auth_type = password
project_domain_name = {{ .Values.keystone.cinder_project_domain }}
user_domain_name = {{ .Values.keystone.cinder_user_domain }}
project_name = {{ .Values.keystone.cinder_project_name }}
username = {{ .Values.keystone.cinder_user }}
password = {{ .Values.keystone.cinder_password }}

[oslo_concurrency]
lock_path = /var/lib/cinder/tmp

[oslo_messaging_rabbit]
rabbit_userid = {{ .Values.messaging.user }}
rabbit_password = {{ .Values.messaging.password }}
rabbit_ha_queues = true
rabbit_hosts = {{ .Values.messaging.hosts }}

[rbd1]
volume_driver = cinder.volume.drivers.rbd.RBDDriver
rbd_pool = {{ .Values.backends.rbd1.pool }}
rbd_ceph_conf = /etc/ceph/ceph.conf
rbd_flatten_volume_from_snapshot = false
rbd_max_clone_depth = 5
rbd_store_chunk_size = 4
rados_connect_timeout = -1
{{- if .Values.backends.rbd1.secret }}
rbd_user = {{ .Values.backends.rbd1.user }}
{{- else }}
rbd_secret_uuid = {{- include "secrets/ceph-client-key" . -}}
{{- end }}
rbd_secret_uuid = {{ .Values.backends.rbd1.secret }}
report_discard_supported = True
