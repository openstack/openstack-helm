[DEFAULT]
debug = {{ .Values.misc.debug }}
use_syslog = False
use_stderr = True

bind_port = {{ .Values.network.port.api }}
workers = {{ .Values.misc.workers }}
registry_host = glance-registry
# Enable Copy-on-Write
show_image_direct_url = True
    
[database]
connection = mysql+pymysql://{{ .Values.database.glance_user }}:{{ .Values.database.glance_password }}@{{ .Values.database.address }}/{{ .Values.database.glance_database_name }}
max_retries = -1
    
[keystone_authtoken]
auth_uri = {{ .Values.keystone.auth_uri }}
auth_url = {{ .Values.keystone.auth_url }}
auth_type = password
project_domain_id = default
user_domain_id = default
project_name = service
username = {{ .Values.keystone.glance_user }}
password = {{ .Values.keystone.glance_password }}
    
[paste_deploy]
flavor = keystone
    
[oslo_messaging_notifications]
driver = noop
    
[glance_store]
filesystem_store_datadir = /var/lib/glance/images/
{{- if .Values.development.enabled }}
stores = file, http
default_store = file
{{- else }}
stores = file, http, rbd
default_store = rbd
rbd_store_pool = {{ .Values.ceph.glance_pool }}
rbd_store_user = {{ .Values.ceph.glance_user }}
rbd_store_ceph_conf = /etc/ceph/ceph.conf
rbd_store_chunk_size = 8
{{- end }}
