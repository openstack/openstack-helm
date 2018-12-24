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

: "${OSD_BOOTSTRAP_KEYRING:=/var/lib/ceph/bootstrap-osd/${CLUSTER}.keyring}"
: "${OSD_JOURNAL_UUID:=$(uuidgen)}"
: "${OSD_FORCE_ZAP:=1}"
: "${CEPH_CONF:="/etc/ceph/${CLUSTER}.conf"}"
# We do not want to zap journal disk. Tracking this option seperatly.
: "${JOURNAL_FORCE_ZAP:=0}"

if [[ ! -e ${CEPH_CONF}.template ]]; then
  echo "ERROR- ${CEPH_CONF}.template must exist; get it from your existing mon"
  exit 1
else
  ENDPOINT=$(kubectl get endpoints ceph-mon -n ${NAMESPACE} -o json | awk -F'"' -v port=${MON_PORT} '/ip/{print $4":"port}' | paste -sd',')
  if [[ ${ENDPOINT} == "" ]]; then
    # No endpoints are available, just copy ceph.conf as-is
    /bin/sh -c -e "cat ${CEPH_CONF}.template | tee ${CEPH_CONF}" || true
  else
    /bin/sh -c -e "cat ${CEPH_CONF}.template | sed 's/mon_host.*/mon_host = ${ENDPOINT}/g' | tee ${CEPH_CONF}" || true
  fi
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


function udev_settle {
  partprobe "${OSD_DEVICE}"
  # watch the udev event queue, and exit if all current events are handled
  udevadm settle --timeout=600
}

# Calculate proper device names, given a device and partition number
function dev_part {
  local OSD_DEVICE=${1}
  local OSD_PARTITION=${2}

  if [[ -L ${OSD_DEVICE} ]]; then
    # This device is a symlink. Work out it's actual device
    local ACTUAL_DEVICE=$(readlink -f ${OSD_DEVICE})
    local BN=$(basename ${OSD_DEVICE})
    if [[ "${ACTUAL_DEVICE:0-1:1}" == [0-9] ]]; then
      local DESIRED_PARTITION="${ACTUAL_DEVICE}p${OSD_PARTITION}"
    else
      local DESIRED_PARTITION="${ACTUAL_DEVICE}${OSD_PARTITION}"
    fi
    # Now search for a symlink in the directory of $OSD_DEVICE
    # that has the correct desired partition, and the longest
    # shared prefix with the original symlink
    local SYMDIR=$(dirname ${OSD_DEVICE})
    local LINK=""
    local PFXLEN=0
    for OPTION in $(ls $SYMDIR); do
    if [[ $(readlink -f $SYMDIR/$OPTION) == $DESIRED_PARTITION ]]; then
      local OPT_PREFIX_LEN=$(prefix_length $OPTION $BN)
      if [[ $OPT_PREFIX_LEN > $PFXLEN ]]; then
        LINK=$SYMDIR/$OPTION
        PFXLEN=$OPT_PREFIX_LEN
      fi
    fi
    done
    if [[ $PFXLEN -eq 0 ]]; then
      >&2 log "Could not locate appropriate symlink for partition ${OSD_PARTITION} of ${OSD_DEVICE}"
      exit 1
    fi
    echo "$LINK"
  elif [[ "${OSD_DEVICE:0-1:1}" == [0-9] ]]; then
    echo "${OSD_DEVICE}p${OSD_PARTITION}"
  else
    echo "${OSD_DEVICE}${OSD_PARTITION}"
  fi
}

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
    if [[ ${OSD_FORCE_ZAP} -eq 1 ]]; then
      echo "It looks like ${OSD_DEVICE} isn't consistent, however OSD_FORCE_ZAP is enabled so we are zapping the device anyway"
      ceph-disk -v zap ${OSD_DEVICE}
    else
      echo "Regarding parted, device ${OSD_DEVICE} is inconsistent/broken/weird."
      echo "It would be too dangerous to destroy it without any notification."
      echo "Please set OSD_FORCE_ZAP to '1' if you really want to zap this disk."
      exit 1
    fi
  fi

  udev_settle

  # then search for some ceph metadata on the disk
  if [[ "$(parted --script ${OSD_DEVICE} print | egrep '^ 1.*ceph data')" ]]; then
    if [[ ${OSD_FORCE_ZAP} -eq 1 ]]; then
      if [ -b "${OSD_DEVICE}1" ]; then
        local cephFSID=`ceph-conf --lookup fsid`
        if [ ! -z "${cephFSID}" ]; then
          local tmpmnt=`mktemp -d`
          mount ${OSD_DEVICE}1 ${tmpmnt}
          if [ -f "${tmpmnt}/ceph_fsid" ]; then
            osdFSID=`cat "${tmpmnt}/ceph_fsid"`
            umount ${tmpmnt}
            if [ ${osdFSID} != ${cephFSID} ]; then
              echo "It looks like ${OSD_DEVICE} is an OSD belonging to a different (or old) ceph cluster."
              echo "The OSD FSID is ${osdFSID} while this cluster is ${cephFSID}"
              echo "Because OSD_FORCE_ZAP was set, we will zap this device."
              ceph-disk -v zap ${OSD_DEVICE}
            else
              echo "It looks like ${OSD_DEVICE} is an OSD belonging to a this ceph cluster."
              echo "OSD_FORCE_ZAP is set, but will be ignored and the device will not be zapped."
              echo "Moving on, trying to activate the OSD now."
              return
            fi
          else
            umount ${tmpmnt}
            echo "It looks like ${OSD_DEVICE} has a ceph data partition but no FSID."
            echo "Because OSD_FORCE_ZAP was set, we will zap this device."
            ceph-disk -v zap ${OSD_DEVICE}
          fi
        else
          echo "Unable to determine the FSID of the current cluster."
          echo "OSD_FORCE_ZAP is set, but this OSD will not be zapped."
          echo "Moving on, trying to activate the OSD now."
          return
        fi
      else
        echo "parted says ${OSD_DEVICE}1 should exist, but we do not see it."
        echo "We will ignore OSD_FORCE_ZAP and try to use the device as-is"
        echo "Moving on, trying to activate the OSD now."
        return
      fi
    else
      echo "INFO- It looks like ${OSD_DEVICE} is an OSD, set OSD_FORCE_ZAP=1 to use this device anyway and zap its content"
      echo "You can also use the zap_device scenario on the appropriate device to zap it"
      echo "Moving on, trying to activate the OSD now."
      return
    fi
  fi

  if [ "${OSD_BLUESTORE:-0}" -ne 1 ]; then
    # we only care about journals for filestore.
    if [ -n "${OSD_JOURNAL}" ]; then
      if [ -b $OSD_JOURNAL ]; then
        OSD_JOURNAL=`readlink -f ${OSD_JOURNAL}`
        OSD_JOURNAL_PARTITION=`echo $OSD_JOURNAL_PARTITION | sed 's/[^0-9]//g'`
        if [ -z "${OSD_JOURNAL_PARTITION}" ]; then
          # maybe they specified the journal as a /dev path like '/dev/sdc12':
          local JDEV=`echo ${OSD_JOURNAL} | sed 's/\(.*[^0-9]\)[0-9]*$/\1/'`
          if [ -d /sys/block/`basename $JDEV`/`basename $OSD_JOURNAL` ]; then
            OSD_JOURNAL=$(dev_part ${JDEV} `echo ${OSD_JOURNAL} |\
              sed 's/.*[^0-9]\([0-9]*\)$/\1/'`)
            OSD_JOURNAL_PARTITION=${JDEV}
          fi
        else
          OSD_JOURNAL=$(dev_part ${OSD_JOURNAL} ${OSD_JOURNAL_PARTITION})
        fi
      fi
      chown ceph. ${OSD_JOURNAL}
    else
      echo "No journal device specified.  OSD and journal will share ${OSD_DEVICE}"
      echo "For better performance, consider moving your journal to a separate device"
    fi
    CLI_OPTS="${CLI_OPTS} --filestore"
  else
    OSD_JOURNAL=''
    CLI_OPTS="${CLI_OPTS} --bluestore"
  fi

  if [ -b "${OSD_JOURNAL}" -a "${JOURNAL_FORCE_ZAP:-0}" -eq 1 ]; then
    # if we got here and zap is set, it's ok to wipe the journal.
    echo "OSD_FORCE_ZAP is set, so we will erase the journal device ${OSD_JOURNAL}"
    if [ -z "${OSD_JOURNAL_PARTITION}" ]; then
      # it's a raw block device.  nuke any existing partition table.
      parted -s ${OSD_JOURNAL} mklabel msdos
    else
      # we are likely working on a partition. Just make a filesystem on
      # the device, as other partitions may be in use so nuking the whole
      # disk isn't safe.
      mkfs -t xfs -f ${OSD_JOURNAL}
    fi
  fi

  if [ "x$JOURNAL_TYPE" == "xdirectory" ]; then
    export OSD_JOURNAL="--journal-file"
  fi

  ceph-disk -v prepare ${CLI_OPTS} --journal-uuid ${OSD_JOURNAL_UUID} ${OSD_DEVICE} ${OSD_JOURNAL}

  udev_settle
}

if ! [ "x${STORAGE_TYPE%-*}" == "xdirectory" ]; then
  osd_disk_prepare
fi
