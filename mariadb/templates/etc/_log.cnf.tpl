[mysqld]
slow_query_log=off
slow_query_log_file=/var/log/mysql/mariadb-slow.log
log_warnings=2

# General logging has huge performance penalty therefore is disabled by default
general_log=off
general_log_file=/var/log/mysql/mariadb-error.log

long_query_time=3
log_queries_not_using_indexes=on
