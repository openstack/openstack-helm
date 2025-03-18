#!/bin/bash

{{/*
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

set -ex
COMMAND="${@:-liveness}"
: ${K8S_HOST_NETWORK:=0}

function heath_check () {
  SOCKDIR=${CEPH_SOCKET_DIR:-/run/ceph}
  SBASE=${CEPH_OSD_SOCKET_BASE:-ceph-mon}
  SSUFFIX=${CEPH_SOCKET_SUFFIX:-asok}

  MON_ID=$(ps auwwx | grep ceph-mon | grep -v "$1" | grep -v grep | sed 's/.*-i\ //;s/\ .*//'|awk '{print $1}')

  if [ -z "${MON_ID}" ]; then
    if [[ ${K8S_HOST_NETWORK} -eq 0 ]]; then
        MON_NAME=${POD_NAME}
    else
        MON_NAME=${NODE_NAME}
    fi
  fi

  if [ -S "${SOCKDIR}/${SBASE}.${MON_NAME}.${SSUFFIX}" ]; then
   MON_STATE=$(ceph -f json-pretty --connect-timeout 1 --admin-daemon "${SOCKDIR}/${SBASE}.${MON_NAME}.${SSUFFIX}" mon_status|grep state|sed 's/.*://;s/[^a-z]//g')
   echo "MON ${MON_ID} ${MON_STATE}";
   # this might be a stricter check than we actually want.  what are the
   # other values for the "state" field?
   for S in ${MON_LIVE_STATE}; do
    if [ "x${MON_STATE}x" = "x${S}x" ]; then
     exit 0
    fi
   done
  fi
  # if we made it this far, things are not running
  exit 1
}

function liveness () {
  MON_LIVE_STATE="probing electing synchronizing leader peon"
  heath_check
}

function readiness () {
  MON_LIVE_STATE="leader peon"
  heath_check
}

$COMMAND
