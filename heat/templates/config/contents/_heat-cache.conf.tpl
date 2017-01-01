[cache]
enabled = "True"
backend = oslo_cache.memcache_pool
memcache_servers = "{{ .Values.memcached.host }}:{{ .Values.memcached.port }}"
