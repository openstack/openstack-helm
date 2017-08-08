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

[mysqld]
# Charset
character_set_server=utf8
collation_server=utf8_unicode_ci
skip-character-set-client-handshake

# Logging
slow_query_log=on
slow_query_log_file=/var/log/mysql/mariadb-slow.log
log_warnings=2

# General logging has huge performance penalty therefore is disabled by default
general_log=off
general_log_file=/var/log/mysql/mariadb-error.log

long_query_time=3
log_queries_not_using_indexes=on

# Networking
bind_address=0.0.0.0
port={{ tuple "oslo_db" "internal" "mysql" . | include "helm-toolkit.endpoints.endpoint_port_lookup" }}

# When a client connects, the server will perform hostname resolution,
# and when DNS is slow, establishing the connection will become slow as well.
# It is therefore recommended to start the server with skip-name-resolve to
# disable all DNS lookups. The only limitation is that the GRANT statements
# must then use IP addresses only.
skip_name_resolve

# Tuning
user=mysql
max_allowed_packet=256M
open_files_limit=10240
max_connections=8192
max-connect-errors=1000000

## Generally, it is unwise to set the query cache to be larger than 64-128M
## as the costs associated with maintaining the cache outweigh the performance
## gains.
## The query cache is a well known bottleneck that can be seen even when
## concurrency is moderate. The best option is to disable it from day 1
## by setting query_cache_size=0 (now the default on MySQL 5.6)
## and to use other ways to speed up read queries: good indexing, adding
## replicas to spread the read load or using an external cache.
query_cache_size=0
query_cache_type=0

sync_binlog=0
thread_cache_size=16
table_open_cache=2048
table_definition_cache=1024

#
# InnoDB
#
# The buffer pool is where data and indexes are cached: having it as large as possible
# will ensure you use memory and not disks for most read operations.
# Typical values are 50..75% of available RAM.
# TODO(tomasz.paszkowski): This needs to by dynamic based on avaliable RAM.
innodb_buffer_pool_size=1024M
innodb_doublewrite=0
innodb_file_format=Barracuda
innodb_file_per_table=1
innodb_flush_method=O_DIRECT
innodb_io_capacity=500
innodb_locks_unsafe_for_binlog=1
innodb_log_file_size=128M
innodb_old_blocks_time=1000
innodb_read_io_threads=8
innodb_write_io_threads=8

# Clustering
binlog_format=ROW
default-storage-engine=InnoDB
innodb_autoinc_lock_mode=2
innodb_flush_log_at_trx_commit=2
wsrep_cluster_name={{ tuple "oslo_db" "internal" . | include "helm-toolkit.endpoints.hostname_short_endpoint_lookup" }}
wsrep_on=1
wsrep_provider=/usr/lib/galera/libgalera_smm.so
wsrep_provider_options="gmcast.listen_addr=tcp://0.0.0.0:{{ tuple "oslo_db" "internal" "wsrep" . | include "helm-toolkit.endpoints.endpoint_port_lookup" }}"
wsrep_slave_threads=12
wsrep_sst_auth=root:{{ .Values.endpoints.oslo_db.auth.admin.password }}
wsrep_sst_method=xtrabackup-v2

[mysqldump]
max-allowed-packet=16M

[client]
default_character_set=utf8
protocol=tcp
port={{ tuple "oslo_db" "internal" "mysql" . | include "helm-toolkit.endpoints.endpoint_port_lookup" }}
connect_timeout=10
