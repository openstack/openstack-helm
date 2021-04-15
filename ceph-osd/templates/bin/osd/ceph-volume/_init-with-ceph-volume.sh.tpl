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

source /tmp/osd-common-ceph-volume.sh

source /tmp/init-ceph-volume-helper-${STORAGE_TYPE}.sh

: "${OSD_FORCE_REPAIR:=0}"

# Set up aliases for functions that require disk synchronization
alias rename_vg='locked rename_vg'
alias rename_lvs='locked rename_lvs'
alias update_lv_tags='locked update_lv_tags'
alias prep_device='locked prep_device'

# Renames a single VG if necessary
function rename_vg {
  local physical_disk=$1
  local old_vg_name=$(pvdisplay -ddd -v ${physical_disk} | awk '/VG Name/{print $3}')
  local vg_name=$(get_vg_name_from_device ${physical_disk})

  if [[ "${old_vg_name}" ]] && [[ "${vg_name}" != "${old_vg_name}" ]]; then
    vgrename ${old_vg_name} ${vg_name}
  fi
}

# Renames all LVs associated with an OSD as necesasry
function rename_lvs {
  local data_disk=$1
  local vg_name=$(pvdisplay -ddd -v ${data_disk} | awk '/VG Name/{print $3}')

  if [[ "${vg_name}" ]]; then
    # Rename the OSD volume if necessary
    local old_lv_name=$(lvdisplay ${vg_name} | awk '/LV Name/{print $3}')
    local lv_name=$(get_lv_name_from_device ${data_disk} lv)

    if [[ "${old_lv_name}" ]] && [[ "${lv_name}" != "${old_lv_name}" ]]; then
      lvrename ${vg_name} ${old_lv_name} ${lv_name}
    fi

    # Rename the OSD's block.db volume if necessary, referenced by UUID
    local lv_tag=$(get_lvm_tag_from_device ${data_disk} ceph.db_uuid)

    if [[ "${lv_tag}" ]]; then
      local lv_device=$(lvdisplay | grep -B4 "${lv_tag}" | awk '/LV Path/{print $3}')

      if [[ "${lv_device}" ]]; then
        local db_vg=$(echo ${lv_device} | awk -F "/" '{print $3}')
        old_lv_name=$(echo ${lv_device} | awk -F "/" '{print $4}')
        local db_name=$(get_lv_name_from_device ${data_disk} db)

        if [[ "${old_lv_name}" ]] && [[ "${db_name}" != "${old_lv_name}" ]]; then
          lvrename ${db_vg} ${old_lv_name} ${db_name}
        fi
      fi
    fi

    # Rename the OSD's WAL volume if necessary, referenced by UUID
    lv_tag=$(get_lvm_tag_from_device ${data_disk} ceph.wal_uuid)

    if [[ "${lv_tag}" ]]; then
      local lv_device=$(lvdisplay | grep -B4 "${lv_tag}" | awk '/LV Path/{print $3}')

      if [[ "${lv_device}" ]]; then
        local wal_vg=$(echo ${lv_device} | awk -F "/" '{print $3}')
        old_lv_name=$(echo ${lv_device} | awk -F "/" '{print $4}')
        local wal_name=$(get_lv_name_from_device ${data_disk} wal)

        if [[ "${old_lv_name}" ]] && [[ "${wal_name}" != "${old_lv_name}" ]]; then
          lvrename ${wal_vg} ${old_lv_name} ${wal_name}
        fi
      fi
    fi
  fi
}

# Fixes up the tags that reference block, db, and wal logical_volumes
# NOTE: This updates tags based on current VG and LV names, so any necessary
#       renaming should be completed prior to calling this
function update_lv_tags {
  local data_disk=$1
  local pv_uuid=$(pvdisplay -ddd -v ${data_disk} | awk '/PV UUID/{print $3}')

  if [[ "${pv_uuid}" ]]; then
    local volumes="$(lvs --no-headings | grep -e "${pv_uuid}")"
    local block_device db_device wal_device vg_name
    local old_block_device old_db_device old_wal_device

    # Build OSD device paths from current VG and LV names
    while read lv vg other_stuff; do
      if [[ "${lv}" == "$(get_lv_name_from_device ${data_disk} lv)" ]]; then
        block_device="/dev/${vg}/${lv}"
        old_block_device=$(get_lvm_tag_from_volume ${block_device} ceph.block_device)
      fi
      if [[ "${lv}" == "$(get_lv_name_from_device ${data_disk} db)" ]]; then
        db_device="/dev/${vg}/${lv}"
        old_db_device=$(get_lvm_tag_from_volume ${block_device} ceph.db_device)
      fi
      if [[ "${lv}" == "$(get_lv_name_from_device ${data_disk} wal)" ]]; then
        wal_device="/dev/${vg}/${lv}"
        old_wal_device=$(get_lvm_tag_from_volume ${block_device} ceph.wal_device)
      fi
    done <<< ${volumes}

    # Set new tags on all of the volumes using paths built above
    while read lv vg other_stuff; do
      if [[ "${block_device}" ]]; then
        if [[ "${old_block_device}" ]]; then
          lvchange --deltag "ceph.block_device=${old_block_device}" /dev/${vg}/${lv}
        fi
        lvchange --addtag "ceph.block_device=${block_device}" /dev/${vg}/${lv}
      fi
      if [[ "${db_device}" ]]; then
        if [[ "${old_db_device}" ]]; then
          lvchange --deltag "ceph.db_device=${old_db_device}" /dev/${vg}/${lv}
        fi
        lvchange --addtag "ceph.db_device=${db_device}" /dev/${vg}/${lv}
      fi
      if [[ "${wal_device}" ]]; then
        if [[ "${old_wal_device}" ]]; then
          lvchange --deltag "ceph.wal_device=${old_wal_device}" /dev/${vg}/${lv}
        fi
        lvchange --addtag "ceph.wal_device=${wal_device}" /dev/${vg}/${lv}
      fi
    done <<< ${volumes}
  fi
}

function prep_device {
  local BLOCK_DEVICE=$1
  local BLOCK_DEVICE_SIZE=$2
  local device_type=$3
  local data_disk=$4
  local vg_name lv_name VG DEVICE_OSD_ID logical_devices logical_volume
  udev_settle
  vg_name=$(get_vg_name_from_device ${BLOCK_DEVICE})
  lv_name=$(get_lv_name_from_device ${data_disk} ${device_type})
  VG=$(vgs --noheadings -o vg_name -S "vg_name=${vg_name}" | tr -d '[:space:]')
  if [[ "${VG}" ]]; then
    DEVICE_OSD_ID=$(get_osd_id_from_volume "/dev/${vg_name}/${lv_name}")
    CEPH_LVM_PREPARE=1
    if [[ -n "${DEVICE_OSD_ID}" ]] && [[ -n "${OSD_ID}" ]]; then
      if [[ "${DEVICE_OSD_ID}" == "${OSD_ID}" ]]; then
        CEPH_LVM_PREPARE=0
      else
        disk_zap "${OSD_DEVICE}"
      fi
    fi
    logical_volumes="$(lvs --noheadings -o lv_name ${VG} | xargs)"
    for volume in ${logical_volumes}; do
      data_volume=$(echo ${volume} | sed -E -e 's/-db-|-wal-/-lv-/g')
      if [[ -z $(lvs --noheadings -o lv_name -S "lv_name=${data_volume}") ]]; then
        # DB or WAL volume without a corresponding data volume, remove it
        lvremove -y /dev/${VG}/${volume}
      fi
    done
  else
    if [[ "${vg_name}" ]]; then
      logical_devices=$(get_dm_devices_from_osd_device "${data_disk}")
      device_filter=$(echo "${vg_name}" | sed 's/-/--/g')
      logical_devices=$(echo "${logical_devices}" | grep "${device_filter}" | xargs)
      if [[ "$logical_devices" ]]; then
        dmsetup remove $logical_devices
        disk_zap "${OSD_DEVICE}"
        CEPH_LVM_PREPARE=1
      fi
    fi
    random_uuid=$(uuidgen)
    vgcreate "ceph-vg-${random_uuid}" "${BLOCK_DEVICE}"
    VG=$(get_vg_name_from_device ${BLOCK_DEVICE})
    vgrename "ceph-vg-${random_uuid}" "${VG}"
  fi
  udev_settle
  logical_volume=$(lvs --noheadings -o lv_name -S "lv_name=${lv_name}" | tr -d '[:space:]')
  if [[ $logical_volume != "${lv_name}" ]]; then
    lvcreate -L "${BLOCK_DEVICE_SIZE}" -n "${lv_name}" "${VG}"
  fi
  if [[ "${device_type}" == "db" ]]; then
    BLOCK_DB="${VG}/${lv_name}"
  elif [[ "${device_type}" == "wal" ]]; then
    BLOCK_WAL="${VG}/${lv_name}"
  fi
  udev_settle
}

#######################################################################
# Main program
#######################################################################

if [[ "${STORAGE_TYPE}" != "directory" ]]; then

  # Settle LVM changes before inspecting volumes
  udev_settle

  # Rename VGs first
  if [[ "${OSD_DEVICE}" ]]; then
    OSD_DEVICE=$(readlink -f ${OSD_DEVICE})
    rename_vg ${OSD_DEVICE}
  fi

  if [[ "${BLOCK_DB}" ]]; then
    BLOCK_DB=$(readlink -f ${BLOCK_DB})
    rename_vg ${BLOCK_DB}
  fi

  if [[ "${BLOCK_WAL}" ]]; then
    BLOCK_WAL=$(readlink -f ${BLOCK_WAL})
    rename_vg ${BLOCK_WAL}
  fi

  # Rename LVs after VGs are correct
  rename_lvs ${OSD_DEVICE}

  # Update tags (all VG and LV names should be correct before calling this)
  update_lv_tags ${OSD_DEVICE}

  # Settle LVM changes again after any changes have been made
  udev_settle

  osd_disk_prepare

  # Clean up resources held by the common script
  common_cleanup
fi
