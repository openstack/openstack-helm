[mysqld]
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
query_cache_size =0
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
innodb_buffer_pool_size=4096M
innodb_log_file_size=2000M
innodb_flush_method=O_DIRECT
innodb_flush_log_at_trx_commit=2
innodb_old_blocks_time=1000
innodb_autoinc_lock_mode=2
innodb_doublewrite=0
innodb_file_format=Barracuda
innodb_file_per_table=1
innodb_io_capacity=500
innodb_locks_unsafe_for_binlog=1
innodb_read_io_threads=8
innodb_write_io_threads=8


[mysqldump]
max-allowed-packet=16M
