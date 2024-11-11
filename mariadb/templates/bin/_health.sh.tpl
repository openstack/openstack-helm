#!/usr/bin/env bash

###########################################################################
# Copyright 2017 The Openstack-Helm Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#########################################################################

set -e

MYSQL="mysql \
  --defaults-file=/etc/mysql/admin_user.cnf \
  --host=localhost \
{{- if .Values.manifests.certificates }}
  --ssl-verify-server-cert=false \
  --ssl-ca=/etc/mysql/certs/ca.crt \
  --ssl-key=/etc/mysql/certs/tls.key \
  --ssl-cert=/etc/mysql/certs/tls.crt \
{{- end }}
  --connect-timeout 2"

mysql_query () {
  TABLE=$1
  KEY=$2
  $MYSQL -e "show ${TABLE} like \"${KEY}\"" | \
    awk "/${KEY}/ { print \$NF; exit }"
}

function usage {
    echo "Usage: $0 [-t <liveness|readiness>] [-d <percent>]" 1>&2
    exit 1
}

PROBE_TYPE=''

while getopts ":t:d:" opt; do
  case $opt in
    t)
        PROBE_TYPE=$OPTARG
        ;;
    d)
        DISK_ALARM_LIMIT=$OPTARG
        ;;
    *)
        usage
        ;;
  esac
done
shift $((OPTIND-1))

check_readiness () {
  if ! $MYSQL -e 'select 1' > /dev/null 2>&1 ; then
      echo "Select from mysql failed"
      exit 1
  fi

  DATADIR=$(mysql_query variables datadir)
  TMPDIR=$(mysql_query variables tmpdir)
  for partition in ${DATADIR} ${TMPDIR}; do
      if [ "$(df --output=pcent ${partition} | grep -Po '\d+')" -ge "${DISK_ALARM_LIMIT:-100}" ]; then
          echo "[ALARM] Critical high disk space utilization of ${partition}"
          exit 1
      fi
  done

  if [ "x$(mysql_query status wsrep_ready)" != "xON" ]; then
      echo "WSREP says the node can not receive queries"
      exit 1
  fi
  if [ "x$(mysql_query status wsrep_connected)" != "xON" ]; then
      echo "WSREP not connected"
      exit 1
  fi
  if [ "x$(mysql_query status wsrep_cluster_status)" != "xPrimary" ]; then
      echo "Not in primary cluster"
      exit 1
  fi
  if [ "x$(mysql_query status wsrep_local_state_comment)" != "xSynced" ]; then
      echo "WSREP not synced"
      exit 1
  fi
}

check_liveness () {
  if pidof mysql_upgrade > /dev/null 2>&1 ; then
    echo "The process mysql_upgrade is active. Skip rest checks"
    exit 0
  fi
  if ! pidof mysqld > /dev/null 2>&1 ; then
    echo "The mysqld pid not found"
    exit 1
  fi
  # NOTE(mkarpin): SST process may take significant time in case of large databases,
  # killing mysqld during SST may destroy all data on the node.
  local datadir="/var/lib/mysql"
  if [ -f ${datadir}/sst_in_progress ]; then
      echo "SST is still in progress, skip further checks as mysql won't respond"
  else
      # NOTE(vsaienko): in some cases maria might stuck during IST, or when neighbours
      # IPs are changed. Here we check that we can connect to mysql socket to ensure
      # process is alive.
      if ! $MYSQL -e "show status like 'wsrep_cluster_status'" > /dev/null 2>&1 ; then
          echo "Can't connect to mysql socket"
          exit 1
      fi
      # Detect node that is not connected to wsrep provider
      if [ "x$(mysql_query status wsrep_ready)" != "xON" ]; then
          echo "WSREP says the node can not receive queries"
          exit 1
      fi
      if [ "x$(mysql_query status wsrep_connected)" != "xON" ]; then
          echo "WSREP not connected"
          exit 1
      fi
  fi
}

case $PROBE_TYPE in
  liveness)
      check_liveness
      ;;
  readiness)
      check_readiness
      ;;
  *)
      echo "Unknown probe type: ${PROBE_TYPE}"
      usage
      ;;
esac
