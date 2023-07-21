#!/bin/bash -xe

# Copyright 2023 VEXXHOST, Inc.
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

COMMAND="${@:-start}"

OVSDB_HOST=$(hostname -f)
ARGS=(
  --db-${OVS_DATABASE}-create-insecure-remote=yes
  --db-${OVS_DATABASE}-cluster-local-proto=tcp
  --db-${OVS_DATABASE}-cluster-local-addr=$(hostname -f)
)

if [[ ! $HOSTNAME == *-0 && $OVSDB_HOST =~ (.+)-([0-9]+)\. ]]; then
  OVSDB_BOOTSTRAP_HOST="${BASH_REMATCH[1]}-0.${OVSDB_HOST#*.}"

  ARGS+=(
    --db-${OVS_DATABASE}-cluster-remote-proto=tcp
    --db-${OVS_DATABASE}-cluster-remote-addr=${OVSDB_BOOTSTRAP_HOST}
  )
fi

function start () {
  /usr/share/ovn/scripts/ovn-ctl start_${OVS_DATABASE}_ovsdb ${ARGS[@]}

  tail --follow=name /var/log/ovn/ovsdb-server-${OVS_DATABASE}.log
}

function stop () {
  /usr/share/ovn/scripts/ovn-ctl stop_${OVS_DATABASE}_ovsdb
  pkill tail
}

function liveness () {
  if [[ $OVS_DATABASE == "nb" ]]; then
    OVN_DATABASE="Northbound"
  elif [[ $OVS_DATABASE == "sb" ]]; then
    OVN_DATABASE="Southbound"
  else
    echo "OVS_DATABASE must be nb or sb"
    exit 1
  fi

  ovs-appctl -t /var/run/ovn/ovn${OVS_DATABASE}_db.ctl cluster/status OVN_${OVN_DATABASE}
}

function readiness () {
  if [[ $OVS_DATABASE == "nb" ]]; then
    OVN_DATABASE="Northbound"
  elif [[ $OVS_DATABASE == "sb" ]]; then
    OVN_DATABASE="Southbound"
  else
    echo "OVS_DATABASE must be nb or sb"
    exit 1
  fi

  ovs-appctl -t /var/run/ovn/ovn${OVS_DATABASE}_db.ctl cluster/status OVN_${OVN_DATABASE}
}

$COMMAND
