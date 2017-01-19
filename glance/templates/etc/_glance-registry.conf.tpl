[DEFAULT]
debug = {{ .Values.misc.debug }}
use_syslog = False
use_stderr = True
bind_port = {{ .Values.network.port.registry }}
workers = {{ .Values.misc.workers }}
    
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
