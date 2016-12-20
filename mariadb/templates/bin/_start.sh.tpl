#!/bin/bash
set -ex
trap "trap - SIGTERM && kill -- -$$" SIGINT SIGTERM EXIT

sudo chown mysql: /var/lib/mysql
rm -rf /var/lib/mysql/lost+found

REPLICAS={{ .Values.replicas }}
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
