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

: "${OSD_FORCE_REPAIR:=0}"

source /tmp/osd-common-ceph-volume.sh

source /tmp/init-ceph-volume-helper-${STORAGE_TYPE}.sh


# Set up aliases for functions that require disk synchronization
alias rename_vg='locked rename_vg'
alias rename_lvs='locked rename_lvs'
alias update_lv_tags='locked update_lv_tags'

# Renames a single VG if necessary
function rename_vg {
  local physical_disk=$1
  local old_vg_name=$(pvdisplay -ddd -v ${physical_disk} | awk '/VG Name/{print $3}')
  local vg_name=$(get_vg_name_from_device ${physical_disk})

  if [[ "${old_vg_name}" ]] && [[ "${vg_name}" != "${old_vg_name}" ]]; then
    vgrename ${old_vg_name} ${vg_name}
    echo "OSD Init: Renamed volume group ${old_vg_name} to ${vg_name}."
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
      echo "OSD Init: Renamed logical volume ${old_lv_name} (from group ${vg_name}) to ${lv_name}."
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
          echo "OSD Init: Renamed DB logical volume ${old_lv_name} (from group ${db_vg}) to ${db_name}."
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
          echo "OSD Init: Renamed WAL logical volume ${old_lv_name} (from group ${wal_vg}) to ${wal_name}."
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
        echo "OSD Init: Updated lv tags for data volume ${block_device}."
      fi
      if [[ "${db_device}" ]]; then
        if [[ "${old_db_device}" ]]; then
          lvchange --deltag "ceph.db_device=${old_db_device}" /dev/${vg}/${lv}
        fi
        lvchange --addtag "ceph.db_device=${db_device}" /dev/${vg}/${lv}
        echo "OSD Init: Updated lv tags for DB volume ${db_device}."
      fi
      if [[ "${wal_device}" ]]; then
        if [[ "${old_wal_device}" ]]; then
          lvchange --deltag "ceph.wal_device=${old_wal_device}" /dev/${vg}/${lv}
        fi
        lvchange --addtag "ceph.wal_device=${wal_device}" /dev/${vg}/${lv}
        echo "OSD Init: Updated lv tags for WAL volume ${wal_device}."
      fi
    done <<< ${volumes}
  fi
}

function create_vg_if_needed {
  local bl_device=$1
  local vg_name=$(get_vg_name_from_device ${bl_device})
  if [[ -z "${vg_name}" ]]; then
    local random_uuid=$(uuidgen)
    vgcreate ceph-vg-${random_uuid} ${bl_device}
    vg_name=$(get_vg_name_from_device ${bl_device})
    vgrename ceph-vg-${random_uuid} ${vg_name}
    echo "OSD Init: Created volume group ${vg_name} for device ${bl_device}."
  fi
  RESULTING_VG=${vg_name}
}

function create_lv_if_needed {
  local bl_device=$1
  local vg_name=$2
  local options=$3
  local lv_name=${4:-$(get_lv_name_from_device ${bl_device} lv)}

  if [[ ! "$(lvdisplay | awk '/LV Name/{print $3}' | grep ${lv_name})" ]]; then
    lvcreate ${options} -n ${lv_name} ${vg_name}
    echo "OSD Init: Created logical volume ${lv_name} in group ${vg_name} for device ${bl_device}."
  fi
  RESULTING_LV=${vg_name}/${lv_name}
}

function osd_disk_prechecks {
  if [[ -z "${OSD_DEVICE}" ]]; then
    echo "ERROR- You must provide a device to build your OSD ie: /dev/sdb"
    exit 1
  fi

  if [[ ! -b "${OSD_DEVICE}" ]]; then
    echo "ERROR- The device pointed by OSD_DEVICE (${OSD_DEVICE}) doesn't exist !"
    exit 1
  fi

  if [ ! -e ${OSD_BOOTSTRAP_KEYRING} ]; then
    echo "ERROR- ${OSD_BOOTSTRAP_KEYRING} must exist. You can extract it from your current monitor by running 'ceph auth get client.bootstrap-osd -o ${OSD_BOOTSTRAP_KEYRING}'"
    exit 1
  fi

  timeout 10 ceph --name client.bootstrap-osd --keyring ${OSD_BOOTSTRAP_KEYRING} health || exit 1
}

function perform_zap {
  if [[ ${ZAP_EXTRA_PARTITIONS} != "" ]]; then
    # This used for filestore/blockstore only
    echo "OSD Init: Zapping extra partitions ${ZAP_EXTRA_PARTITIONS}"
    zap_extra_partitions "${ZAP_EXTRA_PARTITIONS}"
  fi
  echo "OSD Init: Zapping device ${OSD_DEVICE}..."
  disk_zap ${OSD_DEVICE}
  DISK_ZAPPED=1
  udev_settle
}


#######################################################################
# Main program
#######################################################################

if [[ "${STORAGE_TYPE}" != "directory" ]]; then

  # Check to make sure we have what we need to continue
  osd_disk_prechecks

  # Settle LVM changes before inspecting volumes
  udev_settle

  # Rename VGs first
  if [[ "${OSD_DEVICE}" ]]; then
    OSD_DEVICE=$(readlink -f ${OSD_DEVICE})
    rename_vg ${OSD_DEVICE}
  fi

  # Rename block DB device VG next
  if [[ "${BLOCK_DB}" ]]; then
    BLOCK_DB=$(readlink -f ${BLOCK_DB})
    rename_vg ${BLOCK_DB}
  fi

  # Rename block WAL device VG next
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

  # Initialize some important global variables
  CEPH_LVM_PREPARE=1
  OSD_ID=$(get_osd_id_from_device ${OSD_DEVICE})
  DISK_ZAPPED=0
  ZAP_DEVICE=0
  ZAP_EXTRA_PARTITIONS=""

  # The disk may need to be zapped or some LVs may need to be deleted before
  # moving on with the disk preparation.
  determine_what_needs_zapping

  if [[ ${ZAP_DEVICE} -eq 1 ]]; then
    perform_zap
  fi

  # Prepare the disk for use
  osd_disk_prepare

  # Clean up resources held by the common script
  common_cleanup
fi
