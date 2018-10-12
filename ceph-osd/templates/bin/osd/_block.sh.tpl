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
: "${CRUSH_LOCATION:=root=default host=${HOSTNAME}}"
: "${OSD_PATH_BASE:=/var/lib/ceph/osd/${CLUSTER}}"
: "${OSD_SOFT_FORCE_ZAP:=1}"
: "${OSD_JOURNAL_PARTITION:=}"

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

if [[ ! -e /etc/ceph/${CLUSTER}.conf ]]; then
  echo "ERROR- /etc/ceph/${CLUSTER}.conf must exist; get it from your existing mon"
  exit 1
fi

if [[ -z "${OSD_DEVICE}" ]];then
  echo "ERROR- You must provide a device to build your OSD ie: /dev/sdb"
  exit 1
fi

if [[ ! -b "${OSD_DEVICE}" ]]; then
  echo "ERROR- The device pointed by OSD_DEVICE ($OSD_DEVICE) doesn't exist !"
  exit 1
fi

# Calculate proper device names, given a device and partition number
function dev_part {
  local osd_device=${1}
  local osd_partition=${2}

  if [[ -L ${osd_device} ]]; then
    # This device is a symlink. Work out it's actual device
    local actual_device
    actual_device=$(readlink -f "${osd_device}")
    if [[ "${actual_device:0-1:1}" == [0-9] ]]; then
      local desired_partition="${actual_device}p${osd_partition}"
    else
      local desired_partition="${actual_device}${osd_partition}"
    fi
    # Now search for a symlink in the directory of $osd_device
    # that has the correct desired partition, and the longest
    # shared prefix with the original symlink
    local symdir
    symdir=$(dirname "${osd_device}")
    local link=""
    local pfxlen=0
    for option in ${symdir}/*; do
      [[ -e $option ]] || break
      if [[ $(readlink -f "$option") == "$desired_partition" ]]; then
        local optprefixlen
        optprefixlen=$(prefix_length "$option" "$osd_device")
        if [[ $optprefixlen > $pfxlen ]]; then
          link=$option
          pfxlen=$optprefixlen
        fi
      fi
    done
    if [[ $pfxlen -eq 0 ]]; then
      >&2 echo "Could not locate appropriate symlink for partition ${osd_partition} of ${osd_device}"
      exit 1
    fi
    echo "$link"
  elif [[ "${osd_device:0-1:1}" == [0-9] ]]; then
    echo "${osd_device}p${osd_partition}"
  else
    echo "${osd_device}${osd_partition}"
  fi
}

CEPH_DISK_OPTIONS=""
CEPH_OSD_OPTIONS=""

DATA_UUID=$(blkid -o value -s PARTUUID ${OSD_DEVICE}*1)
LOCKBOX_UUID=$(blkid -o value -s PARTUUID ${OSD_DEVICE}3 || true)
JOURNAL_PART=$(dev_part ${OSD_DEVICE} 2)

# watch the udev event queue, and exit if all current events are handled
udevadm settle --timeout=600

# Wait for a file to exist, regardless of the type
function wait_for_file {
  timeout 10 bash -c "while [ ! -e ${1} ]; do echo 'Waiting for ${1} to show up' && sleep 1 ; done"
}

DATA_PART=$(dev_part ${OSD_DEVICE} 1)
MOUNTED_PART=${DATA_PART}

ceph-disk -v \
  --setuser ceph \
  --setgroup disk \
  activate ${CEPH_DISK_OPTIONS} \
    --no-start-daemon ${DATA_PART}

OSD_ID=$(grep "${MOUNTED_PART}" /proc/mounts | awk '{print $2}' | grep -oh '[0-9]*')

OSD_PATH="${OSD_PATH_BASE}-${OSD_ID}"
OSD_KEYRING="${OSD_PATH}/keyring"
# NOTE(supamatt): set the initial crush weight of the OSD to 0 to prevent automatic rebalancing
OSD_WEIGHT=0
ceph \
  --cluster "${CLUSTER}" \
  --name="osd.${OSD_ID}" \
  --keyring="${OSD_KEYRING}" \
  osd \
  crush \
  create-or-move -- "${OSD_ID}" "${OSD_WEIGHT}" ${CRUSH_LOCATION}

if [ "${OSD_BLUESTORE:-0}" -ne 1 ]; then
  if [ -n "${OSD_JOURNAL}" ]; then
    if [ -b "${OSD_JOURNAL}" ]; then
      OSD_JOURNAL_PARTITION="$(echo "${OSD_JOURNAL_PARTITION}" | sed 's/[^0-9]//g')"
      if [ -z "${OSD_JOURNAL_PARTITION}" ]; then
        # maybe they specified the journal as a /dev path like '/dev/sdc12':
        JDEV="$(echo "${OSD_JOURNAL}" | sed 's/\(.*[^0-9]\)[0-9]*$/\1/')"
        if [ -d "/sys/block/$(basename "${JDEV}")/$(basename "${OSD_JOURNAL}")" ]; then
          OSD_JOURNAL="$(dev_part "${JDEV}" "$(echo "${OSD_JOURNAL}" | sed 's/.*[^0-9]\([0-9]*\)$/\1/')")"
        else
          # they likely supplied a bare device and prepare created partition 1.
          OSD_JOURNAL="$(dev_part "${OSD_JOURNAL}" 1)"
        fi
      else
        OSD_JOURNAL="$(dev_part "${OSD_JOURNAL}" "${OSD_JOURNAL_PARTITION}")"
      fi
    fi
    if [ "x${JOURNAL_TYPE}" == "xdirectory" ]; then
      OSD_JOURNAL="${OSD_JOURNAL}/journal.${OSD_ID}"
    else
      if [ ! -b "${OSD_JOURNAL}" ]; then
        echo "ERROR: Unable to find journal device ${OSD_JOURNAL}"
        exit 1
      else
        wait_for_file "${OSD_JOURNAL}"
        chown ceph. "${OSD_JOURNAL}"
      fi
    fi
  else
    wait_for_file "${JOURNAL_PART}"
    chown ceph. "${JOURNAL_PART}"
    OSD_JOURNAL="${JOURNAL_PART}"
  fi
  CEPH_OSD_OPTIONS="${CEPH_OSD_OPTIONS} --osd-journal ${OSD_JOURNAL}"
fi

if [ "x${JOURNAL_TYPE}" == "xdirectory" ]; then
  touch ${OSD_JOURNAL}
  chown -R ceph. /var/lib/ceph/journal
  ceph-osd \
    --cluster ceph \
    --osd-data ${OSD_PATH} \
    --osd-journal ${OSD_JOURNAL} \
    -f \
    -i 0 \
    --setuser ceph \
    --setgroup disk \
    --mkjournal
fi

exec /usr/bin/ceph-osd \
    --cluster ${CLUSTER} \
    ${CEPH_OSD_OPTIONS} \
    -f \
    -i ${OSD_ID} \
    --setuser ceph \
    --setgroup disk & echo $! > /run/ceph-osd.pid
wait
