#!/bin/bash

function setup_loopback_devices() {
  osd_data_device="$1"
  osd_wal_db_device="$2"
  sudo df -lh
  sudo lsblk
  sudo mkdir -p /var/lib/openstack-helm/ceph
  sudo truncate -s 10G /var/lib/openstack-helm/ceph/ceph-osd-data-loopbackfile.img
  sudo truncate -s 8G /var/lib/openstack-helm/ceph/ceph-osd-db-wal-loopbackfile.img
  sudo losetup $osd_data_device /var/lib/openstack-helm/ceph/ceph-osd-data-loopbackfile.img
  sudo losetup $osd_wal_db_device /var/lib/openstack-helm/ceph/ceph-osd-db-wal-loopbackfile.img
  #lets verify the devices
  sudo df -lh
  sudo lsblk
}

while [[ "$#" > 0 ]]; do case $1 in
  -d|--ceph-osd-data) OSD_DATA_DEVICE="$2"; shift;shift;;
  -w|--ceph-osd-dbwal) OSD_DB_WAL_DEVICE="$2";shift;shift;;
  -v|--verbose) VERBOSE=1;shift;;
  *) echo "Unknown parameter passed: $1"; shift; shift;;
esac; done

# verify params
if [ -z "$OSD_DATA_DEVICE" ]; then OSD_DATA_DEVICE=/dev/loop0; echo "Ceph osd data device is not set so using ${OSD_DATA_DEVICE}"; fi
if [ -z "$OSD_DB_WAL_DEVICE" ]; then OSD_DB_WAL_DEVICE=/dev/loop1; echo "Ceph osd db/wal device is not set so using ${OSD_DB_WAL_DEVICE}"; fi


setup_loopback_devices $OSD_DATA_DEVICE $OSD_DB_WAL_DEVICE
