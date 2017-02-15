#!/bin/bash
set -ex
export HOME=/tmp

ansible localhost -vvv -m mysql_db -a "login_host='{{ include "helm-toolkit.mariadb_host" . }}' \
login_port='{{ .Values.database.port }}' \
login_user='{{ .Values.database.root_user }}' \
login_password='{{ .Values.database.root_password }}' \
name='{{ .Values.database.neutron_database_name }}'"

ansible localhost -vvv -m mysql_user -a "login_host='{{ include "helm-toolkit.mariadb_host" . }}' \
login_port='{{ .Values.database.port }}' \
login_user='{{ .Values.database.root_user }}' \
login_password='{{ .Values.database.root_password }}' \
name='{{ .Values.database.neutron_user }}' \
password='{{ .Values.database.neutron_password }}' \
host='%' \
priv='{{ .Values.database.neutron_database_name }}.*:ALL' append_privs='yes'"
