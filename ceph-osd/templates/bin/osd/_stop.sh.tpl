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

source /tmp/utils-resolveLocations.sh

if [ "x${STORAGE_TYPE%-*}" == "xblock" ]; then
  OSD_DEVICE=$(readlink -f ${STORAGE_LOCATION})
  OSD_JOURNAL=$(readlink -f ${JOURNAL_LOCATION})
  if [ "x${STORAGE_TYPE#*-}" == "xlogical" ]; then
    CEPH_OSD_PID="$(cat /run/ceph-osd.pid)"
    while kill -0 ${CEPH_OSD_PID} >/dev/null 2>&1; do
        kill -SIGTERM ${CEPH_OSD_PID}
        sleep 1
    done
    umount "$(findmnt -S "${OSD_DEVICE}1" | tail -n +2 | awk '{ print $1 }')"
  fi
fi
