#!/bin/bash

set -e

function setup_loopback_devices() {
  osd_data_device="$1"
  osd_wal_db_device="$2"
  namespace=${CEPH_NAMESPACE}
  sudo mkdir -p /var/lib/openstack-helm/$namespace
  sudo truncate -s 10G /var/lib/openstack-helm/$namespace/ceph-osd-data-loopbackfile.img
  sudo truncate -s 8G /var/lib/openstack-helm/$namespace/ceph-osd-db-wal-loopbackfile.img
  sudo -E bash -c "cat <<EOF > /etc/systemd/system/loops-setup.service
[Unit]
Description=Setup loop devices
DefaultDependencies=no
Conflicts=umount.target
Before=local-fs.target
After=systemd-udevd.service
Requires=systemd-udevd.service

[Service]
Type=oneshot
ExecStart=/sbin/losetup $osd_data_device '/var/lib/openstack-helm/$namespace/ceph-osd-data-loopbackfile.img'
ExecStart=/sbin/losetup $osd_wal_db_device '/var/lib/openstack-helm/$namespace/ceph-osd-db-wal-loopbackfile.img'
ExecStop=/sbin/losetup -d $osd_data_device
ExecStop=/sbin/losetup -d $osd_wal_db_device
TimeoutSec=60
RemainAfterExit=yes

[Install]
WantedBy=local-fs.target
Also=systemd-udevd.service
EOF"

  sudo systemctl daemon-reload
  sudo systemctl start loops-setup
  sudo systemctl status loops-setup
  sudo systemctl enable loops-setup
  # let's verify the devices
  sudo losetup -a
  if losetup |grep -i $osd_data_device; then
    echo "ceph osd data disk got created successfully"
  else
    echo "could not find ceph osd data disk so exiting"
    exit 1
  fi
  if losetup |grep -i $osd_wal_db_device; then
    echo "ceph osd wal/db disk got created successfully"
  else
    echo "could not find ceph osd wal/db  disk so exiting"
    exit 1
  fi
}

while [[ "$#" > 0 ]]; do case $1 in
  -d|--ceph-osd-data) OSD_DATA_DEVICE="$2"; shift;shift;;
  -w|--ceph-osd-dbwal) OSD_DB_WAL_DEVICE="$2";shift;shift;;
  -v|--verbose) VERBOSE=1;shift;;
  *) echo "Unknown parameter passed: $1"; shift;;
esac; done

# verify params
if [ -z "$OSD_DATA_DEVICE" ]; then
  OSD_DATA_DEVICE=/dev/loop0
  echo "Ceph osd data device is not set so using ${OSD_DATA_DEVICE}"
else
  ceph_osd_disk_name=`basename "$OSD_DATA_DEVICE"`
  if losetup -a|grep $ceph_osd_disk_name; then
     echo "Ceph osd data device is already in use, please double check and correct the device name"
     exit 1
  fi
fi

if [ -z "$OSD_DB_WAL_DEVICE" ]; then
  OSD_DB_WAL_DEVICE=/dev/loop1
  echo "Ceph osd db/wal device is not set so using ${OSD_DB_WAL_DEVICE}"
else
  ceph_dbwal_disk_name=`basename "$OSD_DB_WAL_DEVICE"`
  if losetup -a|grep $ceph_dbwal_disk_name; then
     echo "Ceph osd dbwal device is already in use, please double check and correct the device name"
     exit 1
  fi
fi

: "${CEPH_NAMESPACE:="ceph"}"
# setup loopback devices for ceph osds
setup_loopback_devices $OSD_DATA_DEVICE $OSD_DB_WAL_DEVICE
