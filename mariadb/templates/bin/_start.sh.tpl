#!/bin/bash
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

set -xe

# Bootstrap database
CLUSTER_INIT_ARGS=""
if [ ! -d /var/lib/mysql/mysql ]; then
    if [ "x${POD_NAME}" = "x${SERVICE_NAME}-0" ]; then
        echo No data found for pod 0
        if [ "x${FORCE_BOOTSTRAP}" = "xtrue" ]; then
            echo 'force_bootstrap set, so will force-initialize node 0.'
            CLUSTER_INIT_ARGS=--wsrep-new-cluster
            CLUSTER_BOOTSTRAP=true
        elif ! mysql --defaults-file=/etc/mysql/admin_user.cnf \
                     --connect-timeout 2 \
                     -e 'select 1'; then
            echo 'No other nodes found, so will initialize cluster.'
            CLUSTER_INIT_ARGS=--wsrep-new-cluster
            CLUSTER_BOOTSTRAP=true
        else
            echo 'Found other live nodes, will attempt to join them.'
            mkdir /var/lib/mysql/mysql
        fi
    else
        echo 'Not pod 0, so will avoid upstream database initialization.'
        mkdir /var/lib/mysql/mysql
    fi
    chown -R mysql:mysql /var/lib/mysql
fi

# Construct cluster config
CLUSTER_CONFIG_PATH=/etc/mysql/conf.d/10-cluster-config.cnf

MEMBERS=""
for i in $(seq 1 ${MARIADB_REPLICAS}); do
    if [ "$i" -eq "1" ]; then
      NUM="0"
    else
      NUM="$(expr $i - 1)"
    fi
    CANDIDATE_POD="${SERVICE_NAME}-$NUM.$(hostname -d)"
    if [ "x${CANDIDATE_POD}" != "x${POD_NAME}.$(hostname -d)" ]; then
        if [ -n "${MEMBERS}" ]; then
            MEMBERS+=,
        fi
        MEMBERS+="${CANDIDATE_POD}:${WSREP_PORT}"
    fi
done

echo "Writing cluster config for ${POD_NAME} to ${CLUSTER_CONFIG_PATH}"
cat >> ${CLUSTER_CONFIG_PATH} << EOF
[mysqld]
wsrep_cluster_address="gcomm://${MEMBERS}"
wsrep_node_address=${POD_IP}
wsrep_node_name=${POD_NAME}.$(hostname -d)
EOF

if [ "x${CLUSTER_BOOTSTRAP}" = "xtrue" ]; then
  mysql_install_db --user=mysql --datadir=/var/lib/mysql

  cat > "${BOOTSTRAP_FILE}" << EOF
DELETE FROM mysql.user ;
CREATE OR REPLACE USER 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}' ;
GRANT ALL ON *.* TO 'root'@'%' WITH GRANT OPTION ;
DROP DATABASE IF EXISTS test ;
FLUSH PRIVILEGES ;
EOF

  CLUSTER_INIT_ARGS="${CLUSTER_INIT_ARGS} --init-file=${BOOTSTRAP_FILE}"
fi

exec mysqld ${CLUSTER_INIT_ARGS}
