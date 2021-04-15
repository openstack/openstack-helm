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

export OSD_DEVICE=$(readlink -f ${STORAGE_LOCATION})
export OSD_BLUESTORE=1

function osd_disk_prepare {
  if [[ -z "${OSD_DEVICE}" ]]; then
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
  udev_settle
  OSD_ID=$(get_osd_id_from_device ${OSD_DEVICE})
  OSD_FSID=$(get_cluster_fsid_from_device ${OSD_DEVICE})
  CLUSTER_FSID=$(ceph-conf --lookup fsid)
  DISK_ZAPPED=0

  if [[ ! -z "${OSD_FSID}" ]]; then
    if [[ "${OSD_FSID}" == "${CLUSTER_FSID}" ]]; then
      if [[ ! -z "${OSD_ID}" ]]; then
        if ceph --name client.bootstrap-osd --keyring $OSD_BOOTSTRAP_KEYRING osd ls |grep -w ${OSD_ID}; then
          echo "Running bluestore mode and ${OSD_DEVICE} already bootstrapped"
          CEPH_LVM_PREPARE=0
        elif [[ $OSD_FORCE_REPAIR -eq 1 ]]; then
          echo "OSD initialized for this cluster, but OSD ID not found in the cluster, reinitializing"
        else
          echo "OSD initialized for this cluster, but OSD ID not found in the cluster"
        fi
      fi
    else
      echo "OSD initialized for a different cluster, zapping it"
      disk_zap ${OSD_DEVICE}
      udev_settle
    fi
  elif [[ $(sgdisk --print ${OSD_DEVICE} | grep "F800") ]]; then
    DM_DEV=${OSD_DEVICE}$(sgdisk --print ${OSD_DEVICE} | grep "F800" | awk '{print $1}')
    CEPH_DISK_USED=1
  else
    if [[ ${CEPH_DISK_USED} -eq 1 ]]; then
      if [[ ${OSD_FORCE_REPAIR} -eq 1 ]]; then
        echo "${OSD_DEVICE} isn't clean, zapping it because OSD_FORCE_REPAIR is enabled"
        disk_zap ${OSD_DEVICE}
      else
        echo "${OSD_DEVICE} isn't clean, but OSD_FORCE_REPAIR isn't enabled."
        echo "Please set OSD_FORCE_REPAIR to '1' if you want to zap this disk."
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

  if [[ ${CEPH_DISK_USED} -eq 1 ]]; then
    udev_settle
    CLI_OPTS="${CLI_OPTS} --data ${OSD_DEVICE}"
    ceph-volume simple scan --force ${OSD_DEVICE}$(sgdisk --print ${OSD_DEVICE} | grep "F800" | awk '{print $1}')
  elif [[ ${CEPH_LVM_PREPARE} -eq 1 ]] || [[ ${DISK_ZAPPED} -eq 1 ]]; then
    udev_settle
    vg_name=$(get_vg_name_from_device ${OSD_DEVICE})
    if [[ "${vg_name}" ]]; then
      OSD_VG=${vg_name}
    else
      random_uuid=$(uuidgen)
      vgcreate ceph-vg-${random_uuid} ${OSD_DEVICE}
      vg_name=$(get_vg_name_from_device ${OSD_DEVICE})
      vgrename ceph-vg-${random_uuid} ${vg_name}
      OSD_VG=${vg_name}
    fi
    lv_name=$(get_lv_name_from_device ${OSD_DEVICE} lv)
    if [[ ! "$(lvdisplay | awk '/LV Name/{print $3}' | grep ${lv_name})" ]]; then
      lvcreate --yes -l 100%FREE -n ${lv_name} ${OSD_VG}
    fi
    OSD_LV=${OSD_VG}/${lv_name}
    CLI_OPTS="${CLI_OPTS} --data ${OSD_LV}"
    CEPH_LVM_PREPARE=1
    udev_settle
  fi

  if [ ${CEPH_DISK_USED} -eq 0 ]; then
    if [[ ${BLOCK_DB} ]]; then
      block_db_string=$(echo ${BLOCK_DB} | awk -F "/" '{print $2 "-" $3}')
    fi
    if [[ ${BLOCK_WAL} ]]; then
      block_wal_string=$(echo ${BLOCK_WAL} | awk -F "/" '{print $2 "-" $3}')
    fi
    if [[ ${BLOCK_DB} && ${BLOCK_WAL} ]]; then
      prep_device "${BLOCK_DB}" "${BLOCK_DB_SIZE}" "db" "${OSD_DEVICE}"
      prep_device "${BLOCK_WAL}" "${BLOCK_WAL_SIZE}" "wal" "${OSD_DEVICE}"
    elif [[ -z ${BLOCK_DB} && ${BLOCK_WAL} ]]; then
      prep_device "${BLOCK_WAL}" "${BLOCK_WAL_SIZE}" "wal" "${OSD_DEVICE}"
    elif [[ ${BLOCK_DB} && -z ${BLOCK_WAL} ]]; then
      prep_device "${BLOCK_DB}" "${BLOCK_DB_SIZE}" "db" "${OSD_DEVICE}"
    fi
  else
    if pvdisplay -ddd -v ${OSD_DEVICE} | awk '/VG Name/{print $3}' | grep "ceph"; then
      CEPH_LVM_PREPARE=0
    fi
  fi

  CLI_OPTS="${CLI_OPTS} --bluestore"

  if [ ! -z "$BLOCK_DB" ]; then
    CLI_OPTS="${CLI_OPTS} --block.db ${BLOCK_DB}"
  fi

  if [ ! -z "$BLOCK_WAL" ]; then
    CLI_OPTS="${CLI_OPTS} --block.wal ${BLOCK_WAL}"
  fi

  if [ ! -z "$DEVICE_CLASS" ]; then
    CLI_OPTS="${CLI_OPTS} --crush-device-class ${DEVICE_CLASS}"
  fi

  if [[ ${CEPH_LVM_PREPARE} -eq 1 ]]; then
    ceph-volume lvm -v prepare ${CLI_OPTS}
    udev_settle
  fi
}
