#!/bin/bash

{{/*
Copyright 2019 The Openstack-Helm Authors.

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

# This script creates the patroni replication user if it doesn't exist.
# This is only needed for brownfield upgrade scenarios, on top of sites that
# were greenfield-deployed with a pre-patroni version of postgres.
#
# For greenfield deployments, the patroni-enabled postgresql chart will
# create this user automatically.
#
# If any additional conversion steps are found to be needed, they can go here.

set -e

function patroni_started() {
    HOST=$1
    PORT=$2
    STATUS=$(timeout 10 bash -c "exec 3<>/dev/tcp/${HOST}/${PORT};
      echo -e \"GET / HTTP/1.1\r\nConnection: close\r\n\" >&3;
      cat <&3 | tail -n1 | grep -o \"running\"")

    [[ x${STATUS} == "xrunning" ]]
}

PGDATABASE=${PGDATABASE:-'postgres'}
PGHOST=${PGHOST:-'127.0.0.1'}
PGPORT={{- tuple "postgresql" "internal" "postgresql" . | include "helm-toolkit.endpoints.endpoint_port_lookup" }}
PSQL="psql -h ${PGHOST} -p ${PGPORT} -d ${PGDATABASE}"

PVC_MNT={{- .Values.storage.mount.path }}
FILE_MADE_BY_POSTGRES=${PVC_MNT}/pgdata/pg_xlog
FILE_MADE_BY_PATRONI=${PVC_MNT}/pgdata/patroni.dynamic.json

TIMEOUT=0

# Only need to add the user once, on the first replica
if [ "x${POD_NAME}" != "xpostgresql-0" ]; then
  echo "Nothing to do on ${POD_NAME}"
  exit 0
fi

# Look for a file-based clue that we're migrating from vanilla pg to patroni.
# This is lighter-weight than checking in the database for the user, since
# we have to fire up the database at this point to do the check.
if [[ -e "${FILE_MADE_BY_POSTGRES}" && ! -e "${FILE_MADE_BY_PATRONI}" ]]
then
  echo "We are upgrading to Patroni -- checking for replication user"

  # Fire up a temporary postgres
  /docker-entrypoint.sh postgres &
  while ! $PSQL -c "select 1;"; do
    sleep 1
    if [[ $TIMEOUT -gt 120 ]]; then
      exit 1
    fi
    TIMEOUT=$((TIMEOUT+1))
  done
  TIMEOUT=0

  # Add the replication user if it doesn't exist
  USER_COUNT=$(${PSQL} -qt -c \
                  "SELECT COUNT(*) FROM pg_roles \
                   WHERE rolname='${PATRONI_REPLICATION_USERNAME}'")

  if [ ${USER_COUNT} -eq 0 ]; then
    echo "The patroni replication user ${PATRONI_REPLICATION_USERNAME} doesn't exist yet; creating:"
    ${PSQL} -c "CREATE USER ${PATRONI_REPLICATION_USERNAME} \
                WITH REPLICATION ENCRYPTED PASSWORD '${PATRONI_REPLICATION_PASSWORD}';"
    echo "done."
  else
    echo "The patroni replication user ${PATRONI_REPLICATION_USERNAME} already exists: nothing to do."
  fi

  # Start Patroni to assimilate the postgres
  sed "s/POD_IP_PATTERN/${PATRONI_KUBERNETES_POD_IP}/g" \
      /tmp/patroni-templated.yaml > /tmp/patroni.yaml

  READY_FLAG="i am the leader with the lock"
  PATRONI_LOG=/tmp/patroni_conversion.log
  /usr/bin/python3 /usr/local/bin/patroni /tmp/patroni-templated.yaml &> ${PATRONI_LOG} &

  # Sleep until patroni is running
  while ! grep -q "${READY_FLAG}" ${PATRONI_LOG}; do
    sleep 5
    if [[ $TIMEOUT -gt 24 ]]; then
      echo "A timeout occurred.  Patroni logs:"
      cat ${PATRONI_LOG}
      exit 1
    fi
    TIMEOUT=$((TIMEOUT+1))
  done
  TIMEOUT=0

  # Gracefully stop postgres and patroni
  while pkill INT --uid postgres; do
    sleep 5
    if [[ $TIMEOUT -gt 24 ]]; then
      echo "A timeout occurred.  Patroni logs:"
      cat ${PATRONI_LOG}
      exit 1
    fi
    TIMEOUT=$((TIMEOUT+1))
  done
else
  echo "Patroni is already in place: nothing to do."
fi
