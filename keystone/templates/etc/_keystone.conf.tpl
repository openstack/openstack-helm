[DEFAULT]
debug = {{ .Values.misc.debug }}
use_syslog = False
use_stderr = True

[database]
connection = mysql+pymysql://{{ .Values.database.keystone_user }}:{{ .Values.database.keystone_password }}@{{ include "keystone_db_host" . }}/{{ .Values.database.keystone_database_name }}
max_retries = -1

[memcache]
servers = {{ include "memcached_host" . }}:11211

[cache]
backend = dogpile.cache.memcached
memcache_servers = {{ include "memcached_host" . }}:11211
config_prefix = cache.keystone
enabled = True

