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

# We do not want to zap journal disk. Tracking this option seperatly.
: "${JOURNAL_FORCE_ZAP:=0}"

export OSD_DEVICE=$(readlink -f ${STORAGE_LOCATION})
export OSD_BLUESTORE=0

if [ "x$JOURNAL_TYPE" == "xdirectory" ]; then
  export OSD_JOURNAL="/var/lib/ceph/journal"
else
  export OSD_JOURNAL=$(readlink -f ${JOURNAL_LOCATION})
fi

# Check OSD FSID and journalling metadata
# Returns 1 if the disk should be zapped; 0 otherwise.
function check_osd_metadata {
  local ceph_fsid=$1
  retcode=0
  local tmpmnt=$(mktemp -d)
  mount ${DM_DEV} ${tmpmnt}

  if [ "x${JOURNAL_TYPE}" != "xdirectory" ]; then
    if [  -f "${tmpmnt}/whoami" ]; then
      OSD_JOURNAL_DISK=$(readlink -f "${tmpmnt}/journal")
      local osd_id=$(cat "${tmpmnt}/whoami")
      if [ ! -b "${OSD_JOURNAL_DISK}" ]; then
        OSD_JOURNAL=$(readlink -f ${OSD_JOURNAL})
        local jdev=$(echo ${OSD_JOURNAL} | sed 's/[0-9]//g')
        if [ ${jdev} == ${OSD_JOURNAL} ]; then
          echo "OSD Init: It appears that ${OSD_DEVICE} is missing the journal at ${OSD_JOURNAL}."
          echo "OSD Init: Because OSD_FORCE_REPAIR is set, we will wipe the metadata of the OSD and zap it."
          rm -rf ${tmpmnt}/ceph_fsid
        else
          echo "OSD Init: It appears that ${OSD_DEVICE} is missing the journal at ${OSD_JOURNAL_DISK}."
          echo "OSD Init: Because OSD_FORCE_REPAIR is set and paritions are manually defined, we will"
          echo "OSD Init: attempt to recreate the missing journal device partitions."
          osd_journal_create ${OSD_JOURNAL}
          ln -sf /dev/disk/by-partuuid/${OSD_JOURNAL_UUID} ${tmpmnt}/journal
          echo ${OSD_JOURNAL_UUID} | tee ${tmpmnt}/journal_uuid
          chown ceph. ${OSD_JOURNAL}
          # During OSD start we will format the journal and set the fsid
          touch ${tmpmnt}/run_mkjournal
        fi
      fi
    else
      echo "OSD Init: It looks like ${OSD_DEVICE} has a ceph data partition but is missing it's metadata."
      echo "OSD Init: The device may contain inconsistent metadata or be corrupted."
      echo "OSD Init: Because OSD_FORCE_REPAIR is set, we will wipe the metadata of the OSD and zap it."
      rm -rf ${tmpmnt}/ceph_fsid
    fi
  fi

  if [ -f "${tmpmnt}/ceph_fsid" ]; then
    local osd_fsid=$(cat "${tmpmnt}/ceph_fsid")

    if [ ${osd_fsid} != ${ceph_fsid} ]; then
      echo "OSD Init: ${OSD_DEVICE} is an OSD belonging to a different (or old) ceph cluster."
      echo "OSD Init: The OSD FSID is ${osd_fsid} while this cluster is ${ceph_fsid}"
      echo "OSD Init: Because OSD_FORCE_REPAIR was set, we will zap this device."
      ZAP_EXTRA_PARTITIONS=${tmpmnt}
      retcode=1
    else
      echo "It looks like ${OSD_DEVICE} is an OSD belonging to a this ceph cluster."
      echo "OSD_FORCE_REPAIR is set, but will be ignored and the device will not be zapped."
      echo "Moving on, trying to activate the OSD now."
    fi
  else
    echo "OSD Init: ${OSD_DEVICE} has a ceph data partition but no FSID."
    echo "OSD Init: Because OSD_FORCE_REPAIR was set, we will zap this device."
    ZAP_EXTRA_PARTITIONS=${tmpmnt}
    retcode=1
  fi
  umount ${tmpmnt}
  return ${retcode}
}

function determine_what_needs_zapping {

  if [[ ! -z ${OSD_ID} ]]; then
    local dm_num=$(dmsetup ls | grep $(lsblk -J ${OSD_DEVICE} | jq -r '.blockdevices[].children[].name') | awk '{print $2}' | cut -d':' -f2 | cut -d')' -f1)
    DM_DEV="/dev/dm-"${dm_num}
  elif [[ $(sgdisk --print ${OSD_DEVICE} | grep "F800") ]]; then
    # Ceph-disk was used to initialize the disk, but this is not supported
    echo "OSD Init: ceph-disk was used to initialize the disk, but this is no longer supported"
    exit 1
  else
    if [[ ${OSD_FORCE_REPAIR} -eq 1 ]]; then
      echo "OSD Init: It looks like ${OSD_DEVICE} isn't consistent, however OSD_FORCE_REPAIR is enabled so we are zapping the device anyway"
      ZAP_DEVICE=1
    else
      echo "OSD Init: Regarding parted, device ${OSD_DEVICE} is inconsistent/broken/weird."
      echo "OSD Init: It would be too dangerous to destroy it without any notification."
      echo "OSD Init: Please set OSD_FORCE_REPAIR to '1' if you really want to zap this disk."
      exit 1
    fi
  fi

  if [ ${OSD_FORCE_REPAIR} -eq 1 ] && [ ! -z ${DM_DEV} ]; then
    if [ -b ${DM_DEV} ]; then
      local ceph_fsid=$(ceph-conf --lookup fsid)
      if [ ! -z "${ceph_fsid}"  ]; then
        # Check the OSD metadata and zap the disk if necessary
        if [[ $(check_osd_metadata ${ceph_fsid}) -eq 1 ]]; then
          echo "OSD Init: ${OSD_DEVICE} needs to be zapped..."
          ZAP_DEVICE=1
        fi
      else
        echo "Unable to determine the FSID of the current cluster."
        echo "OSD_FORCE_REPAIR is set, but this OSD will not be zapped."
        echo "Moving on, trying to activate the OSD now."
      fi
    else
      echo "parted says ${DM_DEV} should exist, but we do not see it."
      echo "We will ignore OSD_FORCE_REPAIR and try to use the device as-is"
      echo "Moving on, trying to activate the OSD now."
    fi
  else
    echo "INFO- It looks like ${OSD_DEVICE} is an OSD LVM"
    echo "Moving on, trying to prepare and activate the OSD LVM now."
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
    echo "OSD Init: The backing device ${jdev} for ${OSD_JOURNAL} does not exist on this system."
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
    elif [ "x${JOURNAL_TYPE}" != "xdirectory" ]; then
      # The block device exists but doesn't appear to be paritioned, we will proceed with parititioning the device.
      OSD_JOURNAL=$(readlink -f ${OSD_JOURNAL})
      until [ -b ${OSD_JOURNAL} ]; do
        osd_journal_create ${OSD_JOURNAL}
      done
    fi
    chown ceph. ${OSD_JOURNAL};
  elif [ "x${JOURNAL_TYPE}" != "xdirectory" ]; then
    echo "No journal device specified. OSD and journal will share ${OSD_DEVICE}"
    echo "For better performance on HDD, consider moving your journal to a separate device"
  fi
  CLI_OPTS="${CLI_OPTS} --filestore"
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
  if pvdisplay -ddd -v ${OSD_DEVICE} | awk '/VG Name/{print $3}' | grep "ceph"; then
    echo "OSD Init: Device is already set up. LVM prepare does not need to be called."
    CEPH_LVM_PREPARE=0
  fi

  osd_journal_prepare
  CLI_OPTS="${CLI_OPTS} --data ${OSD_DEVICE} --journal ${OSD_JOURNAL}"
  udev_settle

  if [ ! -z "$DEVICE_CLASS" ]; then
    CLI_OPTS="${CLI_OPTS} --crush-device-class ${DEVICE_CLASS}"
  fi

  if [[ ${CEPH_LVM_PREPARE} -eq 1 ]]; then
    echo "OSD Init: Calling ceph-volume lvm-v prepare ${CLI_OPTS}"
    ceph-volume lvm -v prepare ${CLI_OPTS}
    udev_settle
  fi
}

