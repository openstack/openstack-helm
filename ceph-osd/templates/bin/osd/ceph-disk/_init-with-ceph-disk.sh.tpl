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

source /tmp/osd-common-ceph-disk.sh

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

  # check device status first
  if ! parted --script ${OSD_DEVICE} print > /dev/null 2>&1; then
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

  # then search for some ceph metadata on the disk
  if [[ "$(parted --script ${OSD_DEVICE} print | egrep '^ 1.*ceph data')" ]]; then
    if [[ ${OSD_FORCE_REPAIR} -eq 1 ]]; then
      if [ -b "${OSD_DEVICE}1" ]; then
        local cephFSID=$(ceph-conf --lookup fsid)
        if [ ! -z "${cephFSID}"  ]; then
          local tmpmnt=$(mktemp -d)
          mount ${OSD_DEVICE}1 ${tmpmnt}
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
              return
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
        echo "parted says ${OSD_DEVICE}1 should exist, but we do not see it."
        echo "We will ignore OSD_FORCE_REPAIR and try to use the device as-is"
        echo "Moving on, trying to activate the OSD now."
        return
      fi
    else
      echo "INFO- It looks like ${OSD_DEVICE} is an OSD, set OSD_FORCE_REPAIR=1 to use this device anyway and zap its content"
      echo "You can also use the disk_zap scenario on the appropriate device to zap it"
      echo "Moving on, trying to activate the OSD now."
      return
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

    CLI_OPTS="${CLI_OPTS} ${OSD_DEVICE}"
  else
    # we only care about journals for filestore.
    osd_journal_prepare

    CLI_OPTS="${CLI_OPTS} --journal-uuid ${OSD_JOURNAL_UUID} ${OSD_DEVICE}"

    if [ "x$JOURNAL_TYPE" == "xdirectory" ]; then
      CLI_OPTS="${CLI_OPTS} --journal-file"
    else
      CLI_OPTS="${CLI_OPTS} ${OSD_JOURNAL}"
    fi
  fi

  udev_settle
  ceph-disk -v prepare ${CLI_OPTS}

  if [ ! -z "$DEVICE_CLASS" ]; then
    local osd_id=$(cat "/var/lib/ceph/osd/*/whoami")
    ceph osd crush rm-device-class osd."${osd_id}"
    ceph osd crush set-device-class "${DEVICE_CLASS}" osd."${osd_id}"
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
      osd_journal_create ${OSD_JOURNAL}
    fi
    chown ceph. ${OSD_JOURNAL}
  elif [ "x$JOURNAL_TYPE" != "xdirectory" ]; then
    echo "No journal device specified. OSD and journal will share ${OSD_DEVICE}"
    echo "For better performance on HDD, consider moving your journal to a separate device"
  fi
  CLI_OPTS="${CLI_OPTS} --filestore"
}

if ! [ "x${STORAGE_TYPE%-*}" == "xdirectory" ]; then
  osd_disk_prepare
fi
