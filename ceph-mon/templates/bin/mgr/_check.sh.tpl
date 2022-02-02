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
export LC_ALL=C

COMMAND="${@:-liveness}"

function heath_check () {
   ASOK=$(ls /var/run/ceph/${CLUSTER}-mgr*)
   MGR_NAME=$(basename ${ASOK} | sed -e 's/.asok//' | cut -f 1 -d '.' --complement)
   MGR_STATE=$(ceph --cluster ${CLUSTER} --connect-timeout 1 daemon mgr.${MGR_NAME} status|grep "osd_epoch")
   if [ $? = 0 ]; then
     exit 0
   else
     echo $MGR_STATE
     exit 1
   fi
}

function liveness () {
  heath_check
}

function readiness () {
  heath_check
}

$COMMAND
