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
  ODEV=$(echo ${OSD_DEVICE} | sed 's/[0-9]//g' | cut -f 3 -d '/')
  OSD_PATH=$(cat /proc/mounts | awk '/ceph-/{print $2}')
  OSD_STORE=$(cat ${OSD_PATH}/type)
  DATA_PART=$(cat /proc/mounts | awk '/ceph-/{print $1}')

  ODEV_ROTATIONAL=$(cat /sys/block/${ODEV}/queue/rotational)
  ODEV_SCHEDULER=$(cat /sys/block/${ODEV}/queue/scheduler | tr -d '[]')

  # NOTE(supamatt): TODO implement bluestore defrag options once it's available upstream
  if [ "${ODEV_ROTATIONAL}" -eq "1" ] && [ "x${OSD_STORE}" == "xfilestore" ]; then
    # NOTE(supamatt): Switch to CFQ in order to not block I/O
    echo "cfq" | tee /sys/block/${ODEV}/queue/scheduler || true
    ionice -c 3 xfs_fsr "${OSD_DEVICE}" 2>/dev/null
    # NOTE(supamatt): Switch back to previous IO scheduler
    echo ${ODEV_SCHEDULER} | tee /sys/block/${ODEV}/queue/scheduler || true
  fi
fi

exit 0
