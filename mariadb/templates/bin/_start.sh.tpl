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

set -ex
trap "trap - SIGTERM && kill -- -$$" SIGINT SIGTERM EXIT

sudo chown mysql: /var/lib/mysql
rm -rf /var/lib/mysql/lost+found

{{- if .Values.development.enabled }}
REPLICAS=1
{{- else }}
REPLICAS={{ .Values.replicas }}
{{- end }}
PETSET_NAME={{ printf "%s" .Values.service_name }}
INIT_MARKER="/var/lib/mysql/init_done"

function join_by { local IFS="$1"; shift; echo "$*"; }

# Remove mariadb.pid if exists
if [[ -f /var/lib/mysql/mariadb.pid ]]; then
    if [[ `pgrep -c $(cat /var/lib/mysql/mariadb.pid)` -eq 0 ]]; then
        rm -vf /var/lib/mysql/mariadb.pid
    fi
fi

if [ "$REPLICAS" -eq 1 ] ; then
    if [[ ! -f ${INIT_MARKER} ]]; then
        cd /var/lib/mysql
        echo "Creating one-instance MariaDB."
        bash /tmp/bootstrap-db.sh
        touch ${INIT_MARKER}
    fi
    exec mysqld_safe --defaults-file=/etc/my.cnf \
                --console \
                --wsrep-new-cluster \
                --wsrep_cluster_address='gcomm://'
else

    # give the seed more of a chance to be ready by the time
    # we start the first pet so we succeed on the first pass
    # a little hacky, but prevents restarts as we aren't waiting
    # for job completion here so I'm not sure what else
    # to look for
    sleep 30

    export WSREP_OPTIONS=`python /tmp/peer-finder.py mariadb 0`
    exec mysqld --defaults-file=/etc/my.cnf \
    --console \
    --bind-address="0.0.0.0" \
    --wsrep_node_address="${POD_IP}:{{ .Values.network.port.wsrep }}" \
    --wsrep_provider_options="gcache.size=512M; gmcast.listen_addr=tcp://${POD_IP}:{{ .Values.network.port.wsrep }}" \
    $WSREP_OPTIONS
fi
