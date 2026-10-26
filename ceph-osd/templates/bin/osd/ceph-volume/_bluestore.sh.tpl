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

source /tmp/osd-common-ceph-volume.sh

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

ACTIVATE_OPTIONS=""
CEPH_OSD_OPTIONS=""

udev_settle

OSD_ID=$(get_osd_id_from_device ${OSD_DEVICE})
if [[ -z ${OSD_ID} ]]; then
  echo "OSD_ID not found from device ${OSD_DEVICE}"
  exit 1
fi
OSD_FSID=$(get_osd_fsid_from_device ${OSD_DEVICE})
if [[ -z ${OSD_FSID} ]]; then
  echo "OSD_FSID not found from device ${OSD_DEVICE}"
  exit 1
fi
OSD_PATH="${OSD_PATH_BASE}-${OSD_ID}"
OSD_KEYRING="${OSD_PATH}/keyring"

mkdir -p ${OSD_PATH}

ceph-volume lvm -v \
  --setuser ceph \
  --setgroup disk \
  activate ${ACTIVATE_OPTIONS} \
  --auto-detect-objectstore \
  --no-systemd ${OSD_ID} ${OSD_FSID}
# Cross check the db and wal symlinks if missed
DB_DEV=$(get_osd_db_device_from_device ${OSD_DEVICE})
if [[ ! -z ${DB_DEV} ]]; then
  if [[ ! -h /var/lib/ceph/osd/ceph-${OSD_ID}/block.db ]]; then
    ln -snf ${DB_DEV} /var/lib/ceph/osd/ceph-${OSD_ID}/block.db
    chown -h ceph:ceph ${DB_DEV}
    chown -h ceph:ceph /var/lib/ceph/osd/ceph-${OSD_ID}/block.db
  fi
fi
WAL_DEV=$(get_osd_wal_device_from_device ${OSD_DEVICE})
if [[ ! -z ${WAL_DEV} ]]; then
  if [[ ! -h /var/lib/ceph/osd/ceph-${OSD_ID}/block.wal ]]; then
    ln -snf ${WAL_DEV} /var/lib/ceph/osd/ceph-${OSD_ID}/block.wal
    chown -h ceph:ceph ${WAL_DEV}
    chown -h ceph:ceph /var/lib/ceph/osd/ceph-${OSD_ID}/block.wal
  fi
fi

# NOTE(stevetaylor): Set the OSD's crush weight (use noin flag to prevent rebalancing if necessary)
OSD_WEIGHT=$(get_osd_crush_weight_from_device ${OSD_DEVICE})

# NOTE(stevetaylor): The key check/repair must run before any command that
# authenticates as osd.${OSD_ID}, the first of which is the CRUSH update in
# crush_location() below. Rotate the OSD key to match the desired key type when
# it does not already match (best effort), then validate the local keyring
# against the monitor auth DB, repairing it from the cluster when it has
# drifted. A keyring that cannot be repaired aborts startup with a specific
# error instead of crash-looping on the first CRUSH update.
check_osd_key_type "${OSD_ID}" "${OSD_KEYRING}" || \
  echo "WARNING- osd.${OSD_ID} key type check failed, continuing"
if ! ensure_osd_keyring "${OSD_ID}" "${OSD_KEYRING}"; then
  echo "ERROR- osd.${OSD_ID} keyring ${OSD_KEYRING} could not be verified against the monitor auth DB"
  exit 1
fi

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

# Clean up resources held by the common script
common_cleanup
