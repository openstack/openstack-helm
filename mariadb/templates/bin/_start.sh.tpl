#!/bin/bash
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

#
# Bootstrap database
#
CLUSTER_INIT_ARGS=

if [ ! -d /var/lib/mysql/mysql ]; then
    if [ "x${POD_NAME}" = "x${SERVICE_NAME}-0" ]; then
        echo No data found for pod 0
        if [ "xtrue" = "x{{ .Values.force_bootstrap }}" ]; then
            echo force_bootstrap set, so will force-initialize node 0.
            CLUSTER_INIT_ARGS=--wsrep-new-cluster
        elif ! mysql -h ${SERVICE_NAME} -u root --password=${MYSQL_ROOT_PASSWORD} -e 'select 1'; then
            echo No other nodes found, so will initialize cluster.
            CLUSTER_INIT_ARGS=--wsrep-new-cluster
        else
            echo Found other live nodes, will attempt to join them.
            mkdir /var/lib/mysql/mysql
        fi
    else
        echo Not pod 0, so will avoid upstream database initialization.
        mkdir /var/lib/mysql/mysql
    fi
fi

#
# Construct cluster config
#
CLUSTER_CONFIG_PATH=/etc/mysql/conf.d/10-cluster-config.cnf

MEMBERS=
for i in $(seq 1 {{ .Values.pod.replicas.server }}); do
    NUM=$(expr $i - 1)
    CANDIDATE_POD="${SERVICE_NAME}-$NUM.${DISCOVERY_SERVICE_NAME}"
    if [ "x${CANDIDATE_POD}" != "x${POD_NAME}.${DISCOVERY_SERVICE_NAME}" ]; then
        if [ -n "${MEMBERS}" ]; then
            MEMBERS+=,
        fi
        MEMBERS+="${CANDIDATE_POD}:${WSREP_PORT}"
    fi
done

echo
echo Writing cluster config for ${POD_NAME} to ${CLUSTER_CONFIG_PATH}
echo vvv

cat <<EOS | tee ${CLUSTER_CONFIG_PATH}
[mysqld]
wsrep_cluster_address="gcomm://${MEMBERS}"
wsrep_node_address=${POD_IP}
wsrep_node_name=${POD_NAME}.${DISCOVERY_SERVICE_NAME}
EOS

echo ^^^
echo Executing upstream docker-entrypoint.
echo

#
# Start server
#
exec /usr/local/bin/docker-entrypoint.sh mysqld ${CLUSTER_INIT_ARGS}
