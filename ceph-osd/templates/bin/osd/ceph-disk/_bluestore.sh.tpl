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

source /tmp/osd-common-ceph-disk.sh

set -ex

: "${OSD_SOFT_FORCE_ZAP:=1}"

export OSD_DEVICE=$(readlink -f ${STORAGE_LOCATION})

if [[ -z "${OSD_DEVICE}" ]];then
  echo "ERROR- You must provide a device to build your OSD ie: /dev/sdb"
  exit 1
fi

if [[ ! -b "${OSD_DEVICE}" ]]; then
  echo "ERROR- The device pointed by OSD_DEVICE ${OSD_DEVICE} doesn't exist !"
  exit 1
fi

CEPH_DISK_OPTIONS=""
CEPH_OSD_OPTIONS=""
DATA_UUID=$(blkid -o value -s PARTUUID ${OSD_DEVICE}*1)

udev_settle

DATA_PART=$(dev_part ${OSD_DEVICE} 1)
MOUNTED_PART=${DATA_PART}

ceph-disk -v \
  --setuser ceph \
  --setgroup disk \
  activate ${CEPH_DISK_OPTIONS} \
    --no-start-daemon ${DATA_PART}

OSD_ID=$(grep "${MOUNTED_PART}" /proc/mounts | awk '{print $2}' | grep -oh '[0-9]*')

OSD_PATH="${OSD_PATH_BASE}-${OSD_ID}"
OSD_KEYRING="${OSD_PATH}/keyring"
# NOTE(supamatt): set the initial crush weight of the OSD to 0 to prevent automatic rebalancing
OSD_WEIGHT=0
# NOTE(supamatt): add or move the OSD's CRUSH location
crush_location


# NOTE(supamatt): Just in case permissions do not align up, we recursively set them correctly.
if [ $(stat -c%U ${OSD_PATH}) != ceph ]; then
  chown -R ceph. ${OSD_PATH};
fi

# NOTE(gagehugo): Writing the OSD_ID to tmp for logging
echo "${OSD_ID}" > /tmp/osd-id

exec /usr/bin/ceph-osd \
    --cluster ${CLUSTER} \
    ${CEPH_OSD_OPTIONS} \
    -f \
    -i ${OSD_ID} \
    --setuser ceph \
    --setgroup disk & echo $! > /run/ceph-osd.pid
wait
