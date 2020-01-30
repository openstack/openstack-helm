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

set -ex

source /tmp/osd-common-ceph-volume.sh

: "${OSD_FORCE_REPAIR:=1}"
# We do not want to zap journal disk. Tracking this option seperatly.
: "${JOURNAL_FORCE_ZAP:=0}"

if [ "x${STORAGE_TYPE%-*}" == "xbluestore" ]; then
  export OSD_BLUESTORE=1
fi

if [ "x${STORAGE_TYPE%-*}" == "xdirectory" ]; then
  export OSD_DEVICE="/var/lib/ceph/osd"
else
  export OSD_DEVICE=$(readlink -f ${STORAGE_LOCATION})
fi

if [ "x$JOURNAL_TYPE" == "xdirectory" ]; then
  export OSD_JOURNAL="/var/lib/ceph/journal"
else
  export OSD_JOURNAL=$(readlink -f ${JOURNAL_LOCATION})
fi

function osd_disk_prepare {
  if [[ -z "${OSD_DEVICE}" ]];then
    echo "ERROR- You must provide a device to build your OSD ie: /dev/sdb"
    exit 1
  fi

  if [[ ! -b "${OSD_DEVICE}" ]]; then
    echo "ERROR- The device pointed by OSD_DEVICE ($OSD_DEVICE) doesn't exist !"
    exit 1
  fi

  if [ ! -e $OSD_BOOTSTRAP_KEYRING ]; then
    echo "ERROR- $OSD_BOOTSTRAP_KEYRING must exist. You can extract it from your current monitor by running 'ceph auth get client.bootstrap-osd -o $OSD_BOOTSTRAP_KEYRING'"
    exit 1
  fi
  timeout 10 ceph ${CLI_OPTS} --name client.bootstrap-osd --keyring $OSD_BOOTSTRAP_KEYRING health || exit 1

  #search for some ceph metadata on the disk based on the status of the disk/lvm in filestore
  CEPH_DISK_USED=0
  CEPH_LVM_PREPARE=1
  osd_dev_string=$(echo ${OSD_DEVICE} | awk -F "/" '{print $2}{print $3}' | paste -s -d'-')
  udev_settle
  OSD_ID=$(ceph-volume inventory ${OSD_DEVICE} | grep "osd id" | awk '{print $3}')
  if [ "${OSD_BLUESTORE:-0}" -ne 1 ]; then
    if [[ ! -z ${OSD_ID} ]]; then
      DM_NUM=$(dmsetup ls | grep $(lsblk -J ${OSD_DEVICE} | jq -r '.blockdevices[].children[].name') | awk '{print $2}' | cut -d':' -f2 | cut -d')' -f1)
      DM_DEV="/dev/dm-"${DM_NUM}
    elif [[ $(sgdisk --print ${OSD_DEVICE} | grep "F800") ]]; then
      DM_DEV=${OSD_DEVICE}$(sgdisk --print ${OSD_DEVICE} | grep "F800" | awk '{print $1}')
      CEPH_DISK_USED=1
    else
      if [[ ${OSD_FORCE_REPAIR} -eq 1 ]]; then
        echo "It looks like ${OSD_DEVICE} isn't consistent, however OSD_FORCE_REPAIR is enabled so we are zapping the device anyway"
        disk_zap ${OSD_DEVICE}
      else
        echo "Regarding parted, device ${OSD_DEVICE} is inconsistent/broken/weird."
        echo "It would be too dangerous to destroy it without any notification."
        echo "Please set OSD_FORCE_REPAIR to '1' if you really want to zap this disk."
        exit 1
      fi
    fi
  else
    if [[ ! -z ${OSD_ID} ]]; then
      if ceph --name client.bootstrap-osd --keyring $OSD_BOOTSTRAP_KEYRING osd ls |grep -w ${OSD_ID}; then
        echo "Running bluestore mode and ${OSD_DEVICE} already bootstrapped"
      else
        echo "found the wrong osd id which does not belong to current ceph cluster"
        exit 1
      fi
    elif [[ $(sgdisk --print ${OSD_DEVICE} | grep "F800") ]]; then
      DM_DEV=${OSD_DEVICE}$(sgdisk --print ${OSD_DEVICE} | grep "F800" | awk '{print $1}')
      CEPH_DISK_USED=1
    else
      osd_dev_split=$(basename ${OSD_DEVICE})
      if dmsetup ls |grep -i ${osd_dev_split}|grep -v "db--wal"; then
        CEPH_DISK_USED=1
      fi
      if [[ ${OSD_FORCE_REPAIR} -eq 1 ]] && [ ${CEPH_DISK_USED} -ne 1 ]; then
        echo "It looks like ${OSD_DEVICE} isn't consistent, however OSD_FORCE_REPAIR is enabled so we are zapping the device anyway"
        disk_zap ${OSD_DEVICE}
      else
        echo "Regarding parted, device ${OSD_DEVICE} is inconsistent/broken/weird."
        echo "It would be too dangerous to destroy it without any notification."
        echo "Please set OSD_FORCE_REPAIR to '1' if you really want to zap this disk."
        exit 1
      fi
    fi
  fi
  if [ ${OSD_FORCE_REPAIR} -eq 1 ] && [ ! -z ${DM_DEV} ]; then
    if [ -b $DM_DEV ]; then
      local cephFSID=$(ceph-conf --lookup fsid)
      if [ ! -z "${cephFSID}"  ]; then
        local tmpmnt=$(mktemp -d)
        mount ${DM_DEV} ${tmpmnt}
        if [ "${OSD_BLUESTORE:-0}" -ne 1 ] && [ "x$JOURNAL_TYPE" != "xdirectory" ]; then
          # we only care about journals for filestore.
          if [  -f "${tmpmnt}/whoami" ]; then
            OSD_JOURNAL_DISK=$(readlink -f "${tmpmnt}/journal")
            local osd_id=$(cat "${tmpmnt}/whoami")
            if [ ! -b "${OSD_JOURNAL_DISK}" ]; then
              OSD_JOURNAL=$(readlink -f ${OSD_JOURNAL})
              local jdev=$(echo ${OSD_JOURNAL} | sed 's/[0-9]//g')
              if [ ${jdev} == ${OSD_JOURNAL} ]; then
                echo "It appears that ${OSD_DEVICE} is missing the journal at ${OSD_JOURNAL}."
                echo "Because OSD_FORCE_REPAIR is set, we will wipe the metadata of the OSD and zap it."
                rm -rf ${tmpmnt}/ceph_fsid
              else
                echo "It appears that ${OSD_DEVICE} is missing the journal at ${OSD_JOURNAL_DISK}."
                echo "Because OSD_FORCE_REPAIR is set and paritions are manually defined, we will"
                echo "attempt to recreate the missing journal device partitions."
                osd_journal_create ${OSD_JOURNAL}
                ln -sf /dev/disk/by-partuuid/${OSD_JOURNAL_UUID} ${tmpmnt}/journal
                echo ${OSD_JOURNAL_UUID} | tee ${tmpmnt}/journal_uuid
                chown ceph. ${OSD_JOURNAL}
                # During OSD start we will format the journal and set the fsid
                touch ${tmpmnt}/run_mkjournal
              fi
            fi
          else
            echo "It looks like ${OSD_DEVICE} has a ceph data partition but is missing it's metadata."
            echo "The device may contain inconsistent metadata or be corrupted."
            echo "Because OSD_FORCE_REPAIR is set, we will wipe the metadata of the OSD and zap it."
            rm -rf ${tmpmnt}/ceph_fsid
          fi
        fi
        if [ -f "${tmpmnt}/ceph_fsid" ]; then
          osdFSID=$(cat "${tmpmnt}/ceph_fsid")
          if [ ${osdFSID} != ${cephFSID} ]; then
            echo "It looks like ${OSD_DEVICE} is an OSD belonging to a different (or old) ceph cluster."
            echo "The OSD FSID is ${osdFSID} while this cluster is ${cephFSID}"
            echo "Because OSD_FORCE_REPAIR was set, we will zap this device."
            zap_extra_partitions ${tmpmnt}
            umount ${tmpmnt}
            disk_zap ${OSD_DEVICE}
          else
            umount ${tmpmnt}
            echo "It looks like ${OSD_DEVICE} is an OSD belonging to a this ceph cluster."
            echo "OSD_FORCE_REPAIR is set, but will be ignored and the device will not be zapped."
            echo "Moving on, trying to activate the OSD now."
          fi
        else
          echo "It looks like ${OSD_DEVICE} has a ceph data partition but no FSID."
          echo "Because OSD_FORCE_REPAIR was set, we will zap this device."
          zap_extra_partitions ${tmpmnt}
          umount ${tmpmnt}
          disk_zap ${OSD_DEVICE}
        fi
      else
        echo "Unable to determine the FSID of the current cluster."
        echo "OSD_FORCE_REPAIR is set, but this OSD will not be zapped."
        echo "Moving on, trying to activate the OSD now."
        return
      fi
    else
      echo "parted says ${DM_DEV} should exist, but we do not see it."
      echo "We will ignore OSD_FORCE_REPAIR and try to use the device as-is"
      echo "Moving on, trying to activate the OSD now."
      return
    fi
  else
    echo "INFO- It looks like ${OSD_DEVICE} is an OSD LVM"
    echo "Moving on, trying to prepare and activate the OSD LVM now."
  fi

  if [ "${OSD_BLUESTORE:-0}" -eq 1 ] && [ ${CEPH_DISK_USED} -eq 0 ] ; then
    if [[ ${BLOCK_DB} ]]; then
      block_db_string=$(echo ${BLOCK_DB} | awk -F "/" '{print $2}{print $3}' | paste -s -d'-')
    fi
    if [[ ${BLOCK_WAL} ]]; then
      block_wal_string=$(echo ${BLOCK_WAL} | awk -F "/" '{print $2}{print $3}' | paste -s -d'-')
    fi
    exec {lock_fd}>/var/lib/ceph/tmp/init-osd.lock || exit 1
    flock -w 60 --verbose "${lock_fd}"
    if [[ ${BLOCK_DB} && ${BLOCK_WAL} ]]; then
       if [[ ${block_db_string} == ${block_wal_string} ]]; then
         if [[ $(vgdisplay  | grep "VG Name" | awk '{print $3}' | grep "${block_db_string}") ]]; then
           VG=$(vgdisplay  | grep "VG Name" | awk '{print $3}' | grep "${block_db_string}")
           WAL_OSD_ID=$(ceph-volume lvm list /dev/ceph-db-wal-${block_wal_string}/ceph-wal-${osd_dev_string} | grep "osd id" | awk '{print $3}')
           DB_OSD_ID=$(ceph-volume lvm list /dev/ceph-db-wal-${block_db_string}/ceph-db-${osd_dev_string} | grep "osd id" | awk '{print $3}')
           if [ ! -z ${OSD_ID} ] && ([ ${WAL_OSD_ID} != ${OSD_ID} ] || [ ${DB_OSD_ID} != ${OSD_ID} ]); then
             echo "Found VG, but corresponding DB || WAL are not, zapping the ${OSD_DEVICE}"
             disk_zap ${OSD_DEVICE}
             CEPH_LVM_PREPARE=1
           elif [ ! -z ${OSD_ID} ] && ([ -z ${WAL_OSD_ID} ] || [ -z ${DB_OSD_ID} ]); then
             disk_zap ${OSD_DEVICE}
             CEPH_LVM_PREPARE=1
           elif [ -z ${OSD_ID} ]; then
             CEPH_LVM_PREPARE=1
           else
             CEPH_LVM_PREPARE=0
           fi
         else
           osd_dev_split=$(echo ${OSD_DEVICE} | awk -F "/" '{print $3}')
           if [[ ! -z $(lsblk ${BLOCK_DB} -o name,type -l | grep "lvm" | grep "ceph"| awk '{print $1}' | grep ${osd_dev_split}) ]]; then
             echo "dmsetup reference found but disks mismatch, removing all dmsetup references for ${BLOCK_DB}"
             for item in $(lsblk ${BLOCK_DB} -o name,type -l | grep "lvm" | grep "ceph"| awk '{print $1}');
             do
               dmsetup remove ${item}
             done
             disk_zap ${OSD_DEVICE}
             CEPH_LVM_PREPARE=1
           fi
           vgcreate ceph-db-wal-${block_db_string} ${BLOCK_DB}
           VG=ceph-db-wal-${block_db_string}
         fi
         if [[ $(lvdisplay  | grep "LV Name" | awk '{print $3}' | grep "ceph-db-${osd_dev_string}") != "ceph-db-${osd_dev_string}" ]]; then
           lvcreate -L ${BLOCK_DB_SIZE} -n ceph-db-${osd_dev_string} ${VG}
         fi
         BLOCK_DB=${VG}/ceph-db-${osd_dev_string}
         if [[ $(lvdisplay  | grep "LV Name" | awk '{print $3}' | grep "ceph-wal-${osd_dev_string}") != "ceph-wal-${osd_dev_string}" ]]; then
           lvcreate -L ${BLOCK_WAL_SIZE} -n ceph-wal-${osd_dev_string} ${VG}
         fi
         BLOCK_WAL=${VG}/ceph-wal-${osd_dev_string}
       else
         if [[ $(vgdisplay  | grep "VG Name" | awk '{print $3}' | grep "${block_db_string}") ]]; then
           VG=$(vgdisplay  | grep "VG Name" | awk '{print $3}' | grep "${block_db_string}")
           DB_OSD_ID=$(ceph-volume lvm list /dev/ceph-db-wal-${block_db_string}/ceph-db-${block_db_string} | grep "osd id" | awk '{print $3}')
           if [ ! -z ${OSD_ID} ] && [ ${DB_OSD_ID} != ${OSD_ID} ]; then
             echo "Found VG, but corresponding DB is not, zapping the ${OSD_DEVICE}"
             disk_zap ${OSD_DEVICE}
             CEPH_LVM_PREPARE=1
           elif [ ! -z ${OSD_ID} ] && [ -z ${DB_OSD_ID} ]; then
             disk_zap ${OSD_DEVICE}
             CEPH_LVM_PREPARE=1
           elif [ -z ${OSD_ID} ]; then
             CEPH_LVM_PREPARE=1
           else
             CEPH_LVM_PREPARE=0
           fi
         else
           osd_dev_split=$(echo ${OSD_DEVICE} | awk -F "/" '{print $3}')
           if [[ ! -z $(lsblk ${BLOCK_DB} -o name,type -l | grep "lvm" | grep "ceph"| awk '{print $1}' | grep ${osd_dev_split}) ]]; then
             echo "dmsetup reference found but disks mismatch"
             dmsetup remove $(lsblk ${BLOCK_DB} -o name,type -l | grep "lvm" | grep "ceph"| awk '{print $1}' | grep ${osd_dev_split})
             disk_zap ${OSD_DEVICE}
             CEPH_LVM_PREPARE=1
           fi
           vgcreate ceph-db-wal-${block_db_string} ${BLOCK_DB}
           VG=ceph-db-wal-${block_db_string}
         fi
         if [[ $(vgdisplay  | grep "VG Name" | awk '{print $3}' | grep "${block_wal_string}") ]]; then
           VG=$(vgdisplay  | grep "VG Name" | awk '{print $3}' | grep "${block_wal_string}")
           WAL_OSD_ID=$(ceph-volume lvm list /dev/ceph-db-wal-${block_wal_string}/ceph-wal-${block_wal_string} | grep "osd id" | awk '{print $3}')
           if [ ! -z ${OSD_ID} ] && [ ${WAL_OSD_ID} != ${OSD_ID} ]; then
             echo "Found VG, but corresponding WAL is not, zapping the ${OSD_DEVICE}"
             disk_zap ${OSD_DEVICE}
             CEPH_LVM_PREPARE=1
           elif [ ! -z ${OSD_ID} ] && [ -z ${WAL_OSD_ID} ]; then
             disk_zap ${OSD_DEVICE}
             CEPH_LVM_PREPARE=1
           elif [ -z ${OSD_ID} ]; then
             CEPH_LVM_PREPARE=1
           else
             CEPH_LVM_PREPARE=0
           fi
         else
           osd_dev_split=$(echo ${OSD_DEVICE} | awk -F "/" '{print $3}')
           if [[ ! -z $(lsblk ${BLOCK_WAL} -o name,type -l | grep "lvm" | grep "ceph"| awk '{print $1}' | grep ${osd_dev_split}) ]]; then
             echo "dmsetup reference found but disks mismatch"
             dmsetup remove $(lsblk ${BLOCK_WAL} -o name,type -l | grep "lvm" | grep "ceph"| awk '{print $1}' | grep ${osd_dev_split})
             disk_zap ${OSD_DEVICE}
             CEPH_LVM_PREPARE=1
           fi
           vgcreate ceph-db-wal-${block_wal_string} ${BLOCK_WAL}
           VG=ceph-db-wal-${block_wal_string}
         fi
         if [[ $(lvdisplay  | grep "LV Name" | awk '{print $3}' | grep "ceph-db-${block_db_string}") != "ceph-db-${block_db_string}" ]]; then
           lvcreate -L ${BLOCK_DB_SIZE} -n ceph-db-${block_db_string} ${VG}
         fi
         BLOCK_DB=${VG}/ceph-db-${block_db_string}
         if [[ $(lvdisplay  | grep "LV Name" | awk '{print $3}' | grep "ceph-db-${block_wal_string}") != "ceph-db-${block_wal_string}" ]]; then
           lvcreate -L ${BLOCK_WAL_SIZE} -n ceph-wal-${block_wal_string} ${VG}
         fi
         BLOCK_WAL=${VG}/ceph-wal-${block_wal_string}
       fi
    elif [[ -z ${BLOCK_DB} && ${BLOCK_WAL} ]]; then
       if [[ $(vgdisplay  | grep "VG Name" | awk '{print $3}' | grep "${block_wal_string}") ]]; then
         VG=$(vgdisplay  | grep "VG Name" | awk '{print $3}' | grep "${block_wal_string}")
         WAL_OSD_ID=$(ceph-volume lvm list /dev/ceph-wal-${block_wal_string}/ceph-wal-${osd_dev_string} | grep "osd id" | awk '{print $3}')
         if [ ! -z ${OSD_ID} ] && [ ${WAL_OSD_ID} != ${OSD_ID} ]; then
           echo "Found VG, but corresponding WAL is not, zapping the ${OSD_DEVICE}"
           disk_zap ${OSD_DEVICE}
           CEPH_LVM_PREPARE=1
         elif [ ! -z ${OSD_ID} ] && [ -z ${WAL_OSD_ID} ]; then
           disk_zap ${OSD_DEVICE}
           CEPH_LVM_PREPARE=1
         elif [ -z ${OSD_ID} ]; then
           CEPH_LVM_PREPARE=1
         else
           CEPH_LVM_PREPARE=0
         fi
       else
         osd_dev_split=$(echo ${OSD_DEVICE} | awk -F "/" '{print $3}')
         if [[ ! -z $(lsblk ${BLOCK_WAL} -o name,type -l | grep "lvm" | grep "ceph"| awk '{print $1}' | grep ${osd_dev_split}) ]]; then
           echo "dmsetup reference found but disks mismatch"
           dmsetup remove $(lsblk ${BLOCK_WAL} -o name,type -l | grep "lvm" | grep "ceph"| awk '{print $1}' | grep ${osd_dev_split})
           disk_zap ${OSD_DEVICE}
           CEPH_LVM_PREPARE=1
         fi
         vgcreate ceph-wal-${block_wal_string} ${BLOCK_WAL}
         VG=ceph-wal-${block_wal_string}
       fi
       if [[ $(lvdisplay  | grep "LV Name" | awk '{print $3}' | grep "ceph-wal-${osd_dev_string}") != "ceph-wal-${osd_dev_string}" ]]; then
         lvcreate -L ${BLOCK_WAL_SIZE} -n ceph-wal-${osd_dev_string} ${VG}
       fi
       BLOCK_WAL=${VG}/ceph-wal-${osd_dev_string}
    elif [[ ${BLOCK_DB} && -z ${BLOCK_WAL} ]]; then
       if [[ $(vgdisplay  | grep "VG Name" | awk '{print $3}' | grep "${block_db_string}") ]]; then
         VG=$(vgdisplay  | grep "VG Name" | awk '{print $3}' | grep "${block_db_string}")
         DB_OSD_ID=$(ceph-volume lvm list /dev/ceph-db-${block_db_string}/ceph-db-${osd_dev_string} | grep "osd id" | awk '{print $3}')
         if [ ! -z ${OSD_ID} ] && [ ${DB_OSD_ID} != ${OSD_ID} ]; then
           echo "Found VG, but corresponding DB is not, zapping the ${OSD_DEVICE}"
           disk_zap ${OSD_DEVICE}
           CEPH_LVM_PREPARE=1
         elif [ ! -z ${OSD_ID} ] && [ -z ${DB_OSD_ID} ]; then
           disk_zap ${OSD_DEVICE}
           CEPH_LVM_PREPARE=1
         elif [ -z ${OSD_ID} ]; then
           CEPH_LVM_PREPARE=1
         else
           CEPH_LVM_PREPARE=0
         fi
       else
         osd_dev_split=$(echo ${OSD_DEVICE} | awk -F "/" '{print $3}')
         if [[ ! -z $(lsblk ${BLOCK_DB} -o name,type -l | grep "lvm" | grep "ceph"| awk '{print $1}' | grep ${osd_dev_split}) ]]; then
           echo "dmsetup reference found but disks mismatch"
           dmsetup remove $(lsblk ${BLOCK_WAL} -o name,type -l | grep "lvm" | grep "ceph"| awk '{print $1}' | grep ${osd_dev_split})
           disk_zap ${OSD_DEVICE}
           CEPH_LVM_PREPARE=1
         fi
         vgcreate ceph-db-${block_db_string} ${BLOCK_DB}
         VG=ceph-db-${block_db_string}
       fi
       if [[ $(lvdisplay  | grep "LV Name" | awk '{print $3}' | grep "ceph-db-${osd_dev_string}") != "ceph-db-${osd_dev_string}" ]]; then
         lvcreate -L ${BLOCK_DB_SIZE} -n ceph-db-${osd_dev_string} ${VG}
       fi
       BLOCK_DB=${VG}/ceph-db-${osd_dev_string}
    flock -u "${lock_fd}"
    fi
    if [ -z ${BLOCK_DB} ] && [ -z ${BLOCK_WAL} ]; then
      if pvdisplay ${OSD_DEVICE} | grep "VG Name" | awk '{print $3}' | grep "ceph"; then
        CEPH_LVM_PREPARE=0
      fi
    fi
  else
    if pvdisplay ${OSD_DEVICE} | grep "VG Name" | awk '{print $3}' | grep "ceph"; then
      CEPH_LVM_PREPARE=0
    fi
  fi

  if [ "${OSD_BLUESTORE:-0}" -eq 1 ]; then
    CLI_OPTS="${CLI_OPTS} --bluestore"

    if [ ! -z "$BLOCK_DB" ]; then
      CLI_OPTS="${CLI_OPTS} --block.db ${BLOCK_DB}"
    fi

    if [ ! -z "$BLOCK_WAL" ]; then
      CLI_OPTS="${CLI_OPTS} --block.wal ${BLOCK_WAL}"
    fi
  else
    # we only care about journals for filestore.
    osd_journal_prepare
    CLI_OPTS="${CLI_OPTS} --data ${OSD_DEVICE} --journal ${OSD_JOURNAL}"
    udev_settle
  fi
  if [[ ${CEPH_DISK_USED} -eq 1 ]]; then
    CLI_OPTS="${CLI_OPTS} --data ${OSD_DEVICE}"
    ceph-volume simple scan --force ${OSD_DEVICE}$(sgdisk --print ${OSD_DEVICE} | grep "F800" | awk '{print $1}')
  elif [[ ${CEPH_LVM_PREPARE} == 1 ]]; then
    if [[ $(vgdisplay  | grep "VG Name" | awk '{print $3}' | grep "ceph-vg-${osd_dev_string}") ]]; then
      OSD_VG=$(vgdisplay  | grep "VG Name" | awk '{print $3}' | grep "ceph-vg-${osd_dev_string}")
    else
      vgcreate ceph-vg-${osd_dev_string} ${OSD_DEVICE}
      OSD_VG=ceph-vg-${osd_dev_string}
    fi
    if [[ $(lvdisplay  | grep "LV Name" | awk '{print $3}' | grep "ceph-lv-${osd_dev_string}") != "ceph-lv-${osd_dev_string}" ]]; then
      lvcreate --yes -l 100%FREE -n ceph-lv-${osd_dev_string} ${OSD_VG}
    fi
    OSD_LV=${OSD_VG}/ceph-lv-${osd_dev_string}
    CLI_OPTS="${CLI_OPTS} --data ${OSD_LV}"
    ceph-volume lvm -v prepare ${CLI_OPTS}
  fi
}

function osd_journal_create {
  local osd_journal=${1}
  local osd_journal_partition=$(echo ${osd_journal} | sed 's/[^0-9]//g')
  local jdev=$(echo ${osd_journal} | sed 's/[0-9]//g')
  if [ -b "${jdev}" ]; then
    sgdisk --new=${osd_journal_partition}:0:+${OSD_JOURNAL_SIZE}M \
      --change-name='${osd_journal_partition}:ceph journal' \
      --partition-guid=${osd_journal_partition}:${OSD_JOURNAL_UUID} \
      --typecode=${osd_journal_partition}:45b0969e-9b03-4f30-b4c6-b4b80ceff106 --mbrtogpt -- ${jdev}
    OSD_JOURNAL=$(dev_part ${jdev} ${osd_journal_partition})
    udev_settle
  else
    echo "The backing device ${jdev} for ${OSD_JOURNAL} does not exist on this system."
    exit 1
  fi
}

function osd_journal_prepare {
  if [ -n "${OSD_JOURNAL}" ]; then
    if [ -b ${OSD_JOURNAL} ]; then
      OSD_JOURNAL=$(readlink -f ${OSD_JOURNAL})
      OSD_JOURNAL_PARTITION=$(echo ${OSD_JOURNAL} | sed 's/[^0-9]//g')
      local jdev=$(echo ${OSD_JOURNAL} | sed 's/[0-9]//g')
      if [ -z "${OSD_JOURNAL_PARTITION}" ]; then
        OSD_JOURNAL=$(dev_part ${jdev} ${OSD_JOURNAL_PARTITION})
      else
        OSD_JOURNAL=${OSD_JOURNAL}
      fi
    elif [ "x$JOURNAL_TYPE" != "xdirectory" ]; then
      # The block device exists but doesn't appear to be paritioned, we will proceed with parititioning the device.
      OSD_JOURNAL=$(readlink -f ${OSD_JOURNAL})
      until [ -b ${OSD_JOURNAL} ]; do
        osd_journal_create ${OSD_JOURNAL}
      done
    fi
    chown ceph. ${OSD_JOURNAL};
  elif [ "x$JOURNAL_TYPE" != "xdirectory" ]; then
    echo "No journal device specified. OSD and journal will share ${OSD_DEVICE}"
    echo "For better performance on HDD, consider moving your journal to a separate device"
  fi
  CLI_OPTS="${CLI_OPTS} --filestore"
}

if ! [ "x${STORAGE_TYPE%-*}" == "xdirectory" ]; then
  osd_disk_prepare
fi
