#!/bin/bash

set -xe
sudo df -lh
sudo lsblk
sudo mkdir -p /var/lib/openstack-helm/ceph
sudo truncate -s 10G /var/lib/openstack-helm/ceph/ceph-osd-data-loopbackfile.img
sudo truncate -s 8G /var/lib/openstack-helm/ceph/ceph-osd-db-wal-loopbackfile.img
sudo losetup /dev/loop0 /var/lib/openstack-helm/ceph/ceph-osd-data-loopbackfile.img
sudo losetup /dev/loop1 /var/lib/openstack-helm/ceph/ceph-osd-db-wal-loopbackfile.img
# lets check the devices
sudo df -lh
sudo lsblk
