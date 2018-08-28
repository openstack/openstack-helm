#!/bin/bash
{{/*
Copyright 2017-2018 OpenStack Foundation.

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

# MariaDB 10.2.13 has a regression which breaks clustering, patch
# around this for now
if /usr/sbin/mysqld --version | grep --silent 10.2.13 ; then
    sed -i 's^LSOF_OUT=.*^LSOF_OUT=$(lsof -sTCP:LISTEN -i TCP:${PORT} -a -c nc -c socat -F c 2> /dev/null || :)^' /usr/bin/wsrep_sst_xtrabackup-v2
fi

# Bootstrap database
CLUSTER_INIT_ARGS=""
CLUSTER_CONFIG_PATH=/etc/mysql/conf.d/10-cluster-config.cnf

function exitWithManualRecovery() {

    UUID=$(sed -e 's/^.*uuid:[\ ,\t]*//' -e 'tx' -e 'd' -e ':x' /var/lib/mysql/grastate.dat)
    SEQNO=$(sed -e 's/^.*seqno:[\ ,\t]*//' -e 'tx' -e 'd' -e ':x' /var/lib/mysql/grastate.dat)

    cat >/dev/stderr <<EOF
   **********************************************************
   *            MANUAL RECOVERY ACTION REQUIRED             *
   **********************************************************

All cluster members are down and grastate.dat indicates that it's not
safe to start the cluster from this node. If you see this message on
all nodes, you have to do a manual recovery by following these steps:

    a) Find the node with the highest WSREP seq#:

	POD ${PODNAME} uuid: ${UUID} seq: ${SEQNO}

   	If you see uuid 00000000-0000-0000-0000-000000000000 with
   	seq -1, the node crashed during DDL.

   	If seq is -1 you will find a DETECTED CRASH message
   	on your log. Check the output from InnoDB for the last
   	transaction id available.

    b) Set environment variable FORCE_RECOVERY=<NAME OF POD>
       to force bootstrapping from the specified node.

        Remember to remove FORCE_RECOVERY after your nodes
        are fully recovered! You may lose data otherwise.

You can ignore this message and wait for the next restart if at
least one node started without errors.
EOF

    exit 1
}

# Construct cluster config
MEMBERS=""
for i in $(seq 1 ${MARIADB_REPLICAS}); do
    if [ "$i" -eq "1" ]; then
      NUM="0"
    else
      NUM="$(expr $i - 1)"
    fi
    CANDIDATE_POD="${POD_NAME_PREFIX}-$NUM.$(hostname -d)"
    if [ "x${CANDIDATE_POD}" != "x${POD_NAME}.$(hostname -d)" ]; then
        if [ -n "${MEMBERS}" ]; then
            MEMBERS+=,
        fi
        MEMBERS+="${CANDIDATE_POD}:${WSREP_PORT}"
    fi
done

echo "Writing cluster config for ${POD_NAME} to ${CLUSTER_CONFIG_PATH}"
cat > ${CLUSTER_CONFIG_PATH} <<EOF
[mysqld]
wsrep_cluster_address="gcomm://${MEMBERS}"
wsrep_node_address=${POD_IP}
wsrep_node_name=${POD_NAME}.$(hostname -d)
EOF

if [ ! -z "${FORCE_RECOVERY// }" ]; then
    	cat >/dev/stderr <<EOF
   **********************************************************
   *    !!!        FORCE_RECOVERY WARNING       !!!         *
   **********************************************************

POD is starting with FORCE_RECOVERY defined. Remember to unset this
variable after recovery! You may end up in recovering from a node
with old data on a crash!

You have been warned ;-)

   **********************************************************
   *               FORCE_RECOVERY WARNING                   *
   **********************************************************
EOF

fi

if [ -d /var/lib/mysql/mysql -a -f /var/lib/mysql/grastate.dat ]; then

    # Node already initialized

    if [ "$(sed -e 's/^.*seqno:[\ ,\t]*//' -e 'tx' -e 'd' -e ':x' /var/lib/mysql/grastate.dat)" = "-1" ]; then
    	cat >/dev/stderr <<EOF
   **********************************************************
   *                   DETECTED CRASH                       *
   **********************************************************

Trying to recover from a previous crash by running with wsrep-recover...
EOF
	mysqld --wsrep_cluster_address=gcomm:// --wsrep-recover
    fi

    echo "Check if we can find a cluster memeber."
    if ! mysql --defaults-file=/etc/mysql/admin_user.cnf \
        --connect-timeout 2 \
         -e 'select 1'; then
	# No other nodes are running
    	if [ -z "${FORCE_RECOVERY// }" -a "$(sed -e 's/^.*safe_to_bootstrap:[\ ,\t]*//' -e 'tx' -e 'd' -e ':x' /var/lib/mysql/grastate.dat)" = "1" ]; then
            echo 'Bootstrapping from this node.'
            CLUSTER_INIT_ARGS=--wsrep-new-cluster
        elif [ "x${FORCE_RECOVERY}x" = "x${POD_NAME}x" ]; then
            echo 'Forced recovery bootstrap from this node.'
            CLUSTER_INIT_ARGS=--wsrep-new-cluster
            cp -f /var/lib/mysql/grastate.dat /var/lib/mysql/grastate.bak
    	    cat >/var/lib/mysql/grastate.dat <<EOF
`grep -v 'safe_to_bootstrap:' /var/lib/mysql/grastate.bak`
safe_to_bootstrap: 1
EOF
	    chown -R mysql:mysql /var/lib/mysql/grastate.dat
        else
    	    exitWithManualRecovery
    	fi
    fi

elif [ ! -d /var/lib/mysql/mysql -o "x${FORCE_BOOTSTRAP}" = "xtrue" ]; then
    if [ "x${POD_NAME}" = "x${POD_NAME_PREFIX}-0" ]; then
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
