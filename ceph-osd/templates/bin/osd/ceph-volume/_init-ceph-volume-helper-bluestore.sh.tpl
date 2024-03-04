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
alias prep_device='locked prep_device'

function check_block_device_for_zap {
  local block_device=$1
  local device_type=$2

  if [[ ${block_device} ]]; then
    local vg_name=$(get_vg_name_from_device ${block_device})
    local lv_name=$(get_lv_name_from_device ${OSD_DEVICE} ${device_type})
    local vg=$(vgs --noheadings -o vg_name -S "vg_name=${vg_name}" | tr -d '[:space:]')
    if [[ "${vg}" ]]; then
      local device_osd_id=$(get_osd_id_from_volume "/dev/${vg_name}/${lv_name}")
      CEPH_LVM_PREPARE=1
      if [[ -n "${device_osd_id}" ]] && [[ -n "${OSD_ID}" ]]; then
        if [[ "${device_osd_id}" == "${OSD_ID}" ]]; then
          echo "OSD Init: OSD ID matches the OSD ID already on the data volume. LVM prepare does not need to be called."
          CEPH_LVM_PREPARE=0
        else
          echo "OSD Init: OSD ID does match the OSD ID on the data volume. Device needs to be zapped."
          ZAP_DEVICE=1
        fi
      fi

      # Check if this device (db or wal) has no associated data volume
      local logical_volumes="$(lvs --noheadings -o lv_name ${vg} | xargs)"
      for volume in ${logical_volumes}; do
        local data_volume=$(echo ${volume} | sed -E -e 's/-db-|-wal-/-lv-/g')
        if [[ -z $(lvs --noheadings -o lv_name -S "lv_name=${data_volume}") ]]; then
          # DB or WAL volume without a corresponding data volume, remove it
          lvremove -y /dev/${vg}/${volume}
          echo "OSD Init: LV /dev/${vg}/${volume} was removed as it did not have a data volume."
        fi
      done
    else
      if [[ "${vg_name}" ]]; then
        local logical_devices=$(get_dm_devices_from_osd_device "${OSD_DEVICE}")
        local device_filter=$(echo "${vg_name}" | sed 's/-/--/g')
        local logical_devices=$(echo "${logical_devices}" | grep "${device_filter}" | xargs)
        if [[ "$logical_devices" ]]; then
          echo "OSD Init: No VG resources found with name ${vg_name}. Device needs to be zapped."
          ZAP_DEVICE=1
        fi
      fi
    fi
  fi
}

function determine_what_needs_zapping {

  local osd_fsid=$(get_cluster_fsid_from_device ${OSD_DEVICE})
  local cluster_fsid=$(ceph-conf --lookup fsid)

  # If the OSD FSID is defined within the device, check if we're already bootstrapped.
  if [[ ! -z "${osd_fsid}" ]]; then
    # Check if the OSD FSID is the same as the cluster FSID. If so, then we're
    # already bootstrapped; otherwise, this is an old disk and needs to
    # be zapped.
    if [[ "${osd_fsid}" == "${cluster_fsid}" ]]; then
      if [[ ! -z "${OSD_ID}" ]]; then
        # Check to see what needs to be done to prepare the disk. If the OSD
        # ID is in the Ceph OSD list, then LVM prepare does not need to be done.
        if ceph --name client.bootstrap-osd --keyring $OSD_BOOTSTRAP_KEYRING osd ls |grep -w ${OSD_ID}; then
          echo "OSD Init: Running bluestore mode and ${OSD_DEVICE} already bootstrapped. LVM prepare does not need to be called."
          CEPH_LVM_PREPARE=0
        elif [[ ${OSD_FORCE_REPAIR} -eq 1 ]]; then
          echo "OSD initialized for this cluster, but OSD ID not found in the cluster, reinitializing"
          ZAP_DEVICE=1
        else
          echo "OSD initialized for this cluster, but OSD ID not found in the cluster, repair manually"
        fi
      fi
    else
      echo "OSD Init: OSD FSID ${osd_fsid} initialized for a different cluster. It needs to be zapped."
      ZAP_DEVICE=1
    fi
  elif [[ $(sgdisk --print ${OSD_DEVICE} | grep "F800") ]]; then
    # Ceph-disk was used to initialize the disk, but this is not supported
    echo "ceph-disk was used to initialize the disk, but this is no longer supported"
    exit 1
  fi

  check_block_device_for_zap "${BLOCK_DB}" db
  check_block_device_for_zap "${BLOCK_WAL}" wal

  # Zapping extra partitions isn't done for bluestore
  ZAP_EXTRA_PARTITIONS=0
}

function prep_device {
  local block_device=$1
  local block_device_size=$2
  local device_type=$3
  local vg_name lv_name vg device_osd_id logical_devices logical_volume
  RESULTING_VG=""; RESULTING_LV="";

  udev_settle
  vg_name=$(get_vg_name_from_device ${block_device})
  lv_name=$(get_lv_name_from_device ${OSD_DEVICE} ${device_type})
  vg=$(vgs --noheadings -o vg_name -S "vg_name=${vg_name}" | tr -d '[:space:]')
  if [[ -z "${vg}" ]]; then
    create_vg_if_needed "${block_device}"
    vg=${RESULTING_VG}
  fi
  udev_settle

  create_lv_if_needed "${block_device}" "${vg}" "--yes -L ${block_device_size}" "${lv_name}"
  if [[ "${device_type}" == "db" ]]; then
    BLOCK_DB=${RESULTING_LV}
  elif [[ "${device_type}" == "wal" ]]; then
    BLOCK_WAL=${RESULTING_LV}
  fi
  udev_settle
}

function osd_disk_prepare {

  if [[ ${CEPH_LVM_PREPARE} -eq 1 ]] || [[ ${DISK_ZAPPED} -eq 1 ]]; then
    udev_settle
    RESULTING_VG=""; RESULTING_LV="";
    create_vg_if_needed "${OSD_DEVICE}"
    create_lv_if_needed "${OSD_DEVICE}" "${RESULTING_VG}" "--yes -l 100%FREE"

    CLI_OPTS="${CLI_OPTS} --data ${RESULTING_LV}"
    CEPH_LVM_PREPARE=1
    udev_settle
  fi

  if [[ ${BLOCK_DB} && ${BLOCK_WAL} ]]; then
    prep_device "${BLOCK_DB}" "${BLOCK_DB_SIZE}" "db" "${OSD_DEVICE}"
    prep_device "${BLOCK_WAL}" "${BLOCK_WAL_SIZE}" "wal" "${OSD_DEVICE}"
  elif [[ -z ${BLOCK_DB} && ${BLOCK_WAL} ]]; then
    prep_device "${BLOCK_WAL}" "${BLOCK_WAL_SIZE}" "wal" "${OSD_DEVICE}"
  elif [[ ${BLOCK_DB} && -z ${BLOCK_WAL} ]]; then
    prep_device "${BLOCK_DB}" "${BLOCK_DB_SIZE}" "db" "${OSD_DEVICE}"
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
    echo "OSD Init: Calling ceph-volume lvm-v prepare ${CLI_OPTS}"
    ceph-volume lvm -v prepare ${CLI_OPTS}
    udev_settle
  fi
}
