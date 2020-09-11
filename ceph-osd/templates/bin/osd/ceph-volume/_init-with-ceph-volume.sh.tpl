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

# Renames a single VG if necessary
function rename_vg {
  local physical_disk=$1
  local old_vg_name=$(locked pvdisplay ${physical_disk} | awk '/VG Name/{print $3}')
  local vg_name=$(get_vg_name_from_device ${physical_disk})

  if [[ "${old_vg_name}" ]] && [[ "${vg_name}" != "${old_vg_name}" ]]; then
    locked vgrename ${old_vg_name} ${vg_name}
  fi
}

# Renames all LVs associated with an OSD as necesasry
function rename_lvs {
  local data_disk=$1
  local vg_name=$(locked pvdisplay ${data_disk} | awk '/VG Name/{print $3}')

  if [[ "${vg_name}" ]]; then
    # Rename the OSD volume if necessary
    local old_lv_name=$(locked lvdisplay ${vg_name} | awk '/LV Name/{print $3}')
    local lv_name=$(get_lv_name_from_device ${data_disk} lv)

    if [[ "${old_lv_name}" ]] && [[ "${lv_name}" != "${old_lv_name}" ]]; then
      locked lvrename ${vg_name} ${old_lv_name} ${lv_name}
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
          locked lvrename ${db_vg} ${old_lv_name} ${db_name}
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
          locked lvrename ${wal_vg} ${old_lv_name} ${wal_name}
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
  local pv_uuid=$(pvdisplay ${data_disk} | awk '/PV UUID/{print $3}')

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
          locked lvchange --deltag "ceph.block_device=${old_block_device}" /dev/${vg}/${lv}
        fi
        locked lvchange --addtag "ceph.block_device=${block_device}" /dev/${vg}/${lv}
      fi
      if [[ "${db_device}" ]]; then
        if [[ "${old_db_device}" ]]; then
          locked lvchange --deltag "ceph.db_device=${old_db_device}" /dev/${vg}/${lv}
        fi
        locked lvchange --addtag "ceph.db_device=${db_device}" /dev/${vg}/${lv}
      fi
      if [[ "${wal_device}" ]]; then
        if [[ "${old_wal_device}" ]]; then
          locked lvchange --deltag "ceph.wal_device=${old_wal_device}" /dev/${vg}/${lv}
        fi
        locked lvchange --addtag "ceph.wal_device=${wal_device}" /dev/${vg}/${lv}
      fi
    done <<< ${volumes}
  fi
}

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

function prep_device {
  local BLOCK_DEVICE=$1
  local BLOCK_DEVICE_SIZE=$2
  local device_type=$3
  local data_disk=$4
  local vg_name lv_name VG DEVICE_OSD_ID logical_devices logical_volume
  vg_name=$(get_vg_name_from_device ${BLOCK_DEVICE})
  lv_name=$(get_lv_name_from_device ${data_disk} ${device_type})
  VG=$(vgs --noheadings -o vg_name -S "vg_name=${vg_name}" | tr -d '[:space:]')
  if [[ $VG ]]; then
    DEVICE_OSD_ID=$(get_osd_id_from_volume "/dev/${vg_name}/${lv_name}")
    CEPH_LVM_PREPARE=1
    if [ -n "${OSD_ID}" ]; then
      if [ "${DEVICE_OSD_ID}" == "${OSD_ID}" ]; then
        CEPH_LVM_PREPARE=0
      else
        disk_zap "${OSD_DEVICE}"
      fi
    fi
  else
    logical_devices=$(get_lvm_path_from_device "pv_name=~${BLOCK_DEVICE},lv_name=~dev-${osd_dev_split}")
    if [[ -n "$logical_devices" ]]; then
      dmsetup remove $logical_devices
      disk_zap "${OSD_DEVICE}"
      CEPH_LVM_PREPARE=1
    fi
    random_uuid=$(uuidgen)
    locked vgcreate "ceph-vg-${random_uuid}" "${BLOCK_DEVICE}"
    VG=$(get_vg_name_from_device ${BLOCK_DEVICE})
    locked vgrename "ceph-vg-${random_uuid}" "${VG}"
  fi
  logical_volume=$(lvs --noheadings -o lv_name -S "lv_name=${lv_name}" | tr -d '[:space:]')
  if [[ $logical_volume != "${lv_name}" ]]; then
    locked lvcreate -L "${BLOCK_DEVICE_SIZE}" -n "${lv_name}" "${VG}"
  fi
  if [[ "${device_type}" == "db" ]]; then
    BLOCK_DB="${VG}/${lv_name}"
  elif [[ "${device_type}" == "wal" ]]; then
    BLOCK_WAL="${VG}/${lv_name}"
  fi
}

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
  osd_dev_split=$(basename "${OSD_DEVICE}")
  udev_settle
  OSD_ID=$(get_osd_id_from_device ${OSD_DEVICE})
  OSD_FSID=$(get_cluster_fsid_from_device ${OSD_DEVICE})
  CLUSTER_FSID=$(ceph-conf --lookup fsid)
  DISK_ZAPPED=0

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
        DISK_ZAPPED=1
      else
        echo "Regarding parted, device ${OSD_DEVICE} is inconsistent/broken/weird."
        echo "It would be too dangerous to destroy it without any notification."
        echo "Please set OSD_FORCE_REPAIR to '1' if you really want to zap this disk."
        exit 1
      fi
    fi
  else
    if [[ ! -z "${OSD_FSID}" ]]; then
      if [[ "${OSD_FSID}" == "${CLUSTER_FSID}" ]]; then
        if [[ ! -z "${OSD_ID}" ]]; then
          if ceph --name client.bootstrap-osd --keyring $OSD_BOOTSTRAP_KEYRING osd ls |grep -w ${OSD_ID}; then
            echo "Running bluestore mode and ${OSD_DEVICE} already bootstrapped"
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
      if dmsetup ls |grep -i ${osd_dev_split}|grep -v "db--dev\|wal--dev"; then
        CEPH_DISK_USED=1
      fi
      if [[ ${OSD_FORCE_REPAIR} -eq 1 ]] && [ ${CEPH_DISK_USED} -ne 1 ]; then
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

  if [[ ${CEPH_DISK_USED} -eq 1 ]]; then
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

  if [ "${OSD_BLUESTORE:-0}" -eq 1 ] && [ ${CEPH_DISK_USED} -eq 0 ] ; then
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
    if pvdisplay ${OSD_DEVICE} | awk '/VG Name/{print $3}' | grep "ceph"; then
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

  if [ ! -z "$DEVICE_CLASS" ]; then
    CLI_OPTS="${CLI_OPTS} --crush-device-class ${DEVICE_CLASS}"
  fi

  if [[ CEPH_LVM_PREPARE -eq 1 ]]; then
    locked ceph-volume lvm -v prepare ${CLI_OPTS}
    udev_settle
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
