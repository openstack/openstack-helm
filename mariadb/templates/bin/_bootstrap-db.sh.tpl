#!/bin/sh

set -ex

SLEEP_TIMEOUT=5

# Initialize system .Values.database.
mysql_install_db --datadir=/var/lib/mysql

# Start mariadb and wait for it to be ready.
#
# note that we bind to 127.0.0.1 here because we want
# to interact with the database but we dont want to expose it
# yet for other cluster members to accidently connect yet
mysqld_safe --defaults-file=/etc/my.cnf \
            --console \
            --wsrep-new-cluster \
            --wsrep_cluster_address='gcomm://' \
            --bind-address='127.0.0.1' \
            --wsrep_node_address="127.0.0.1:{{ .Values.network.port.wsrep }}" \
            --wsrep_provider_options="gcache.size=512M; gmcast.listen_addr=tcp://127.0.0.1:{{ .Values.network.port.wsrep }}" &

TIMEOUT=120
while [[ ! -f /var/lib/mysql/mariadb.pid ]]; do
if [[ ${TIMEOUT} -gt 0 ]]; then
    let TIMEOUT-=1
    sleep 1
else
    exit 1
fi
done

# Reset permissions.
# kolla_security_reset requires to be run from home directory
cd /var/lib/mysql ; DB_ROOT_PASSWORD="{{ .Values.database.root_password }}" kolla_security_reset

mysql -u root --password="{{ .Values.database.root_password }}" --port="{{ .Values.network.port.mariadb }}" -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' IDENTIFIED BY '{{ .Values.database.root_password }}' WITH GRANT OPTION;"
mysql -u root --password="{{ .Values.database.root_password }}" --port="{{ .Values.network.port.mariadb }}" -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '{{ .Values.database.root_password }}' WITH GRANT OPTION;"

# Restart .Values.database.
mysqladmin -uroot -p"{{ .Values.database.root_password }}" --port="{{ .Values.network.port.mariadb }}" shutdown

# Wait for the mariadb server to shut down
SHUTDOWN_TIMEOUT=60
while [[ -f /var/lib/mysql/mariadb.pid ]]; do
    if [[ ${SHUTDOWN_TIMEOUT} -gt 0 ]]; then
        let SHUTDOWN_TIMEOUT-=1
        sleep 1
    else
        echo "MariaDB instance couldn't be properly shut down"
        exit 1
    fi
done
