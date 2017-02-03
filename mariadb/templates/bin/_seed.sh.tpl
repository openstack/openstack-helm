#!/bin/sh
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

set -ex

SLEEP_TIMEOUT=5

function wait_for_cluster {

    # Wait for the mariadb server to be "Ready" before starting the security reset with a max timeout
    TIMEOUT=600
    while [[ ! -f /var/lib/mysql/mariadb.pid ]]; do
        if [[ ${TIMEOUT} -gt 0 ]]; then
            let TIMEOUT-=1
            sleep 1
        else
            exit 1
        fi
    done

    REPLICAS={{ .Values.replicas }}
    # We need to count seed instance here.
    MINIMUM_CLUSTER_SIZE=$(( $REPLICAS  + 1 ))

    # wait until we have at least two more members in a cluster.
    while true ; do
        CLUSTER_SIZE=`mysql -uroot -h ${POD_IP} -p"{{ .Values.database.root_password }}" --port="{{ .Values.network.port.mariadb }}" -e'show status' | grep wsrep_cluster_size | awk ' { if($2 ~ /[0-9]/){ print $2 } else { print 0 } } '`
        if [ "${CLUSTER_SIZE}" -lt ${MINIMUM_CLUSTER_SIZE} ] ; then
            echo "Cluster seed not finished, waiting."
            sleep ${SLEEP_TIMEOUT}
            continue
        fi
        CLUSTER_STATUS=`mysql -uroot -h ${POD_IP} -p"{{ .Values.database.root_password }}" --port="{{ .Values.network.port.mariadb }}" -e'show status' | grep wsrep_local_state_comment | awk ' { print $2 } '`
        if [ "${CLUSTER_STATUS}" != "Synced" ] ; then
            echo "Cluster not synced, waiting."
            sleep ${SLEEP_TIMEOUT}
            continue
        fi
        # Count number of endpoint separators.
        ENDPOINTS_CNT=`python /tmp/peer-finder.py mariadb 1 | grep -o ',' | wc -l`
        # TODO(tomasz.paszkowski): Fix a corner case when only one endpoint is on the list.
        # Add +1 for seed node and +1 as first item does not have a separator
        ENDPOINTS_CNT=$(($ENDPOINTS_CNT+2))
        if [ "${ENDPOINTS_CNT}" != "${CLUSTER_SIZE}" ] ; then
            echo "Cluster not synced, waiting."
            sleep ${SLEEP_TIMEOUT}
            continue
        fi
        echo "Cluster ready, exiting seed."
        kill -- -$$
        break
    done
}

# With the DaemonSet implementation, there may be a difference
# in the number of replicas and actual number of nodes matching
# mariadb node selector label. Problem will be solved when
# the implementation will be switched to Deployment
# (using anti-affinity feature).

{{- if .Values.development.enabled }}
REPLICAS=1
{{- else }}
REPLICAS={{ .Values.replicas }}
{{- end }}

if [ "$REPLICAS" -eq 1 ] ; then
    echo "Requested to build one-instance MariaDB cluster. There is no need to run seed. Exiting."
    exit 0
elif [ "$REPLICAS" -eq 2 ] ; then
    echo "2-instance cluster is not a valid MariaDB configuration."
    exit 1
fi

. /tmp/bootstrap-db.sh
mysqld_safe --defaults-file=/etc/my.cnf \
            --console \
            --wsrep-new-cluster \
            --wsrep_cluster_address='gcomm://' \
            --bind-address="0.0.0.0" \
            --wsrep_node_address="${POD_IP}:{{ .Values.network.port.wsrep }}" \
            --wsrep_provider_options="gcache.size=512M; gmcast.listen_addr=tcp://${POD_IP}:{{ .Values.network.port.wsrep }}" &
wait_for_cluster
exit 0
