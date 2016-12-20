[mysqld]
wsrep_cluster_name="{{ .Values.database.cluster_name }}"
wsrep_provider=/usr/lib/galera/libgalera_smm.so
wsrep_provider_options="gcache.size=512M"
wsrep_slave_threads=12
wsrep_sst_auth=root:{{ .Values.database.root_password }}
# xtrabackup-v2 would be more desirable here, but its
# not in the upstream stackanetes images
# ()[mysql@mariadb-seed-gdqr8 /]$ xtrabackup --version
# xtrabackup version 2.2.13 based on MySQL server 5.6.24 Linux (x86_64) (revision id: 70f4be3)
wsrep_sst_method=xtrabackup-v2
wsrep_node_name={{ .Values.database.node_name }}
datadir=/var/lib/mysql
tmpdir=/tmp
user=mysql
