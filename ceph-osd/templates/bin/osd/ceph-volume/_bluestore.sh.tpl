#!/bin/bash

{{/*
Copyright 2017 The Openstack-Helm Authors.

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

CEPH_DISK_OPTIONS=""
CEPH_OSD_OPTIONS=""

udev_settle

OSD_ID=$(ceph-volume inventory ${OSD_DEVICE} | grep "osd id" | awk '{print $3}')
simple_activate=0
if [[ -z ${OSD_ID} ]]; then
  echo "Looks like ceph-disk has been used earlier to activate the OSD."
  tmpmnt=$(mktemp -d)
  mount ${OSD_DEVICE}1 ${tmpmnt}
  OSD_ID=$(cat ${tmpmnt}/whoami)
  umount ${tmpmnt}
  simple_activate=1
fi
OSD_FSID=$(ceph-volume inventory ${OSD_DEVICE} | grep "osd fsid" | awk '{print $3}')
if [[ -z ${OSD_FSID} ]]; then
  echo "Looks like ceph-disk has been used earlier to activate the OSD."
  tmpmnt=$(mktemp -d)
  mount ${OSD_DEVICE}1 ${tmpmnt}
  OSD_FSID=$(cat ${tmpmnt}/fsid)
  umount ${tmpmnt}
  simple_activate=1
fi
OSD_PATH="${OSD_PATH_BASE}-${OSD_ID}"
OSD_KEYRING="${OSD_PATH}/keyring"

mkdir -p ${OSD_PATH}

if [[ ${simple_activate} -eq 1 ]]; then
  ceph-volume simple activate --no-systemd ${OSD_ID} ${OSD_FSID}
else
  ceph-volume lvm -v \
    --setuser ceph \
    --setgroup disk \
    activate ${CEPH_DISK_OPTIONS} \
    --auto-detect-objectstore \
    --no-systemd ${OSD_ID} ${OSD_FSID}
  # Cross check the db and wal symlinks if missed
  DB_DEV=$(ceph-volume lvm list ${OSD_DEVICE} | grep "db device" | awk '{print $3}')
  if [[ ! -z ${DB_DEV} ]]; then
    if [[ ! -h /var/lib/ceph/osd/ceph-${OSD_ID}/block.db ]]; then
      ln -snf ${DB_DEV} /var/lib/ceph/osd/ceph-${OSD_ID}/block.db
      chown -h ceph:ceph ${DB_DEV}
      chown -h ceph:ceph /var/lib/ceph/osd/ceph-${OSD_ID}/block.db
    fi
  fi
  WAL_DEV=$(ceph-volume lvm list ${OSD_DEVICE} | grep "wal device" | awk '{print $3}')
  if [[ ! -z ${WAL_DEV} ]]; then
    if [[ ! -h /var/lib/ceph/osd/ceph-${OSD_ID}/block.wal ]]; then
      ln -snf ${WAL_DEV} /var/lib/ceph/osd/ceph-${OSD_ID}/block.wal
      chown -h ceph:ceph ${WAL_DEV}
      chown -h ceph:ceph /var/lib/ceph/osd/ceph-${OSD_ID}/block.wal
    fi
  fi
fi

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
