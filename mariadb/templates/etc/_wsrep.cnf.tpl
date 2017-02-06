# Copyright 2017 The Openstack-Helm Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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
