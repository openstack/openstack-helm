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

: "${CRUSH_LOCATION:=root=default host=${HOSTNAME}}"
: "${OSD_PATH_BASE:=/var/lib/ceph/osd/${CLUSTER}}"
: "${CEPH_CONF:="/etc/ceph/${CLUSTER}.conf"}"
: "${OSD_BOOTSTRAP_KEYRING:=/var/lib/ceph/bootstrap-osd/${CLUSTER}.keyring}"
: "${OSD_JOURNAL_UUID:=$(uuidgen)}"
: "${OSD_JOURNAL_SIZE:=$(awk '/^osd_journal_size/{print $3}' ${CEPH_CONF}.template)}"
: "${OSD_WEIGHT:=1.0}"

eval CRUSH_FAILURE_DOMAIN_TYPE=$(cat /etc/ceph/storage.json | python -c 'import sys, json; data = json.load(sys.stdin); print(json.dumps(data["failure_domain"]))')
eval CRUSH_FAILURE_DOMAIN_NAME=$(cat /etc/ceph/storage.json | python -c 'import sys, json; data = json.load(sys.stdin); print(json.dumps(data["failure_domain_name"]))')
eval CRUSH_FAILURE_DOMAIN_BY_HOSTNAME=$(cat /etc/ceph/storage.json | python -c 'import sys, json; data = json.load(sys.stdin); print(json.dumps(data["failure_domain_by_hostname"]))')
eval DEVICE_CLASS=$(cat /etc/ceph/storage.json | python -c 'import sys, json; data = json.load(sys.stdin); print(json.dumps(data["device_class"]))')

if [[ $(ceph -v | egrep -q "nautilus|mimic|luminous"; echo $?) -ne 0 ]]; then
    echo "ERROR- need Luminous/Mimic/Nautilus release"
    exit 1
fi

if [ -z "${HOSTNAME}" ]; then
  echo "HOSTNAME not set; This will prevent to add an OSD into the CRUSH map"
  exit 1
fi

if [[ ! -e ${CEPH_CONF}.template ]]; then
  echo "ERROR- ${CEPH_CONF}.template must exist; get it from your existing mon"
  exit 1
else
  ENDPOINT=$(kubectl get endpoints ceph-mon-discovery -n ${NAMESPACE} -o json | awk -F'"' -v port=${MON_PORT} \
             -v version=v1 -v msgr_version=v2 \
             -v msgr2_port=${MON_PORT_V2} \
             '/"ip"/{print "["version":"$4":"port"/"0","msgr_version":"$4":"msgr2_port"/"0"]"}' | paste -sd',')
  if [[ "${ENDPOINT}" == "" ]]; then
    /bin/sh -c -e "cat ${CEPH_CONF}.template | tee ${CEPH_CONF}" || true
  else
    /bin/sh -c -e "cat ${CEPH_CONF}.template | sed 's#mon_host.*#mon_host = ${ENDPOINT}#g' | tee ${CEPH_CONF}" || true
  fi
fi

# Wait for a file to exist, regardless of the type
function wait_for_file {
  timeout 10 bash -c "while [ ! -e ${1} ]; do echo 'Waiting for ${1} to show up' && sleep 1 ; done"
}

function is_available {
  command -v $@ &>/dev/null
}

function ceph_cmd_retry() {
  cnt=0
  until "ceph" "$@" || [ $cnt -ge 6 ]; do
    sleep 10
    ((cnt++))
  done
}

function crush_create_or_move {
  local crush_location=${1}
  ceph_cmd_retry --cluster "${CLUSTER}" --name="osd.${OSD_ID}" --keyring="${OSD_KEYRING}" \
    osd crush create-or-move -- "${OSD_ID}" "${OSD_WEIGHT}" ${crush_location}
}

function crush_add_and_move {
  local crush_failure_domain_type=${1}
  local crush_failure_domain_name=${2}
  local crush_location=$(echo "root=default ${crush_failure_domain_type}=${crush_failure_domain_name} host=${HOSTNAME}")
  crush_create_or_move "${crush_location}"
  local crush_failure_domain_location_check=$(ceph_cmd_retry --cluster "${CLUSTER}" --name="osd.${OSD_ID}" --keyring="${OSD_KEYRING}" osd find ${OSD_ID} | grep "${crush_failure_domain_type}" | awk -F '"' '{print $4}')
  if [ "x${crush_failure_domain_location_check}" != "x${crush_failure_domain_name}" ];  then
    # NOTE(supamatt): Manually move the buckets for previously configured CRUSH configurations
    # as create-or-move may not appropiately move them.
    ceph_cmd_retry --cluster "${CLUSTER}" --name="osd.${OSD_ID}" --keyring="${OSD_KEYRING}" \
      osd crush add-bucket "${crush_failure_domain_name}" "${crush_failure_domain_type}" || true
    ceph_cmd_retry --cluster "${CLUSTER}" --name="osd.${OSD_ID}" --keyring="${OSD_KEYRING}" \
      osd crush move "${crush_failure_domain_name}" root=default || true
    ceph_cmd_retry --cluster "${CLUSTER}" --name="osd.${OSD_ID}" --keyring="${OSD_KEYRING}" \
      osd crush move "${HOSTNAME}" "${crush_failure_domain_type}=${crush_failure_domain_name}" || true
  fi
}

function crush_location {
  set_device_class
  if [ "x${CRUSH_FAILURE_DOMAIN_TYPE}" != "xhost" ]; then
    if [ "x${CRUSH_FAILURE_DOMAIN_NAME}" != "xfalse" ]; then
      crush_add_and_move "${CRUSH_FAILURE_DOMAIN_TYPE}" "${CRUSH_FAILURE_DOMAIN_NAME}"
    elif [ "x${CRUSH_FAILURE_DOMAIN_BY_HOSTNAME}" != "xfalse" ]; then
      crush_add_and_move "${CRUSH_FAILURE_DOMAIN_TYPE}" "$(echo ${CRUSH_FAILURE_DOMAIN_TYPE}_$(echo ${HOSTNAME} | cut -c ${CRUSH_FAILURE_DOMAIN_BY_HOSTNAME}))"
    else
      # NOTE(supamatt): neither variables are defined then we fall back to default behavior
      crush_create_or_move "${CRUSH_LOCATION}"
    fi
  else
    crush_create_or_move "${CRUSH_LOCATION}"
  fi
}

# Calculate proper device names, given a device and partition number
function dev_part {
  local osd_device=${1}
  local osd_partition=${2}

  if [[ -L ${osd_device} ]]; then
    # This device is a symlink. Work out it's actual device
    local actual_device=$(readlink -f "${osd_device}")
    local bn=$(basename "${osd_device}")
    if [[ "${actual_device:0-1:1}" == [0-9] ]]; then
      local desired_partition="${actual_device}p${osd_partition}"
    else
      local desired_partition="${actual_device}${osd_partition}"
    fi
    # Now search for a symlink in the directory of $osd_device
    # that has the correct desired partition, and the longest
    # shared prefix with the original symlink
    local symdir=$(dirname "${osd_device}")
    local link=""
    local pfxlen=0
    for option in ${symdir}/*; do
      [[ -e $option ]] || break
      if [[ $(readlink -f "${option}") == "${desired_partition}" ]]; then
        local optprefixlen=$(prefix_length "${option}" "${bn}")
        if [[ ${optprefixlen} > ${pfxlen} ]]; then
          link=${symdir}/${option}
          pfxlen=${optprefixlen}
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

function zap_extra_partitions {
  # Examine temp mount and delete any block.db and block.wal partitions
  mountpoint=${1}
  journal_disk=""
  journal_part=""
  block_db_disk=""
  block_db_part=""
  block_wal_disk=""
  block_wal_part=""

  # Discover journal, block.db, and block.wal partitions first before deleting anything
  # If the partitions are on the same disk, deleting one can affect discovery of the other(s)
  if [ -L "${mountpoint}/journal" ]; then
    journal_disk=$(readlink -m ${mountpoint}/journal | sed 's/[0-9]*//g')
    journal_part=$(readlink -m ${mountpoint}/journal | sed 's/[^0-9]*//g')
  fi
  if [ -L "${mountpoint}/block.db" ]; then
    block_db_disk=$(readlink -m ${mountpoint}/block.db | sed 's/[0-9]*//g')
    block_db_part=$(readlink -m ${mountpoint}/block.db | sed 's/[^0-9]*//g')
  fi
  if [ -L "${mountpoint}/block.wal" ]; then
    block_wal_disk=$(readlink -m ${mountpoint}/block.wal | sed 's/[0-9]*//g')
    block_wal_part=$(readlink -m ${mountpoint}/block.wal | sed 's/[^0-9]*//g')
  fi

  # Delete any discovered journal, block.db, and block.wal partitions
  if [ ! -z "${journal_disk}" ]; then
    sgdisk -d ${journal_part} ${journal_disk}
    /sbin/udevadm settle --timeout=600
    /usr/bin/flock -s ${journal_disk} /sbin/partprobe ${journal_disk}
    /sbin/udevadm settle --timeout=600
  fi
  if [ ! -z "${block_db_disk}" ]; then
    sgdisk -d ${block_db_part} ${block_db_disk}
    /sbin/udevadm settle --timeout=600
    /usr/bin/flock -s ${block_db_disk} /sbin/partprobe ${block_db_disk}
    /sbin/udevadm settle --timeout=600
  fi
  if [ ! -z "${block_wal_disk}" ]; then
    sgdisk -d ${block_wal_part} ${block_wal_disk}
    /sbin/udevadm settle --timeout=600
    /usr/bin/flock -s ${block_wal_disk} /sbin/partprobe ${block_wal_disk}
    /sbin/udevadm settle --timeout=600
  fi
}

function disk_zap {
  # Run all the commands that ceph-disk zap uses to clear a disk
  local device=${1}
  local osd_device_lvm=$(lsblk ${device} -o name,type -l | grep "lvm" | grep "ceph"| awk '{print $1}')
  if [[ ! -z ${osd_device_lvm} ]]; then
    dmsetup remove ${osd_device_lvm}
  fi
  if [[ $(pvdisplay ${OSD_DEVICE} | grep "VG Name" | awk '{print $3}' | grep "ceph") ]]; then
    local LOCAL_VG=$(pvdisplay ${OSD_DEVICE} | grep "VG Name" | awk '{print $3}' | grep "ceph")
    if [[ $(lvdisplay | grep ${LOCAL_VG} | grep "LV Path" | awk '{print $3}') ]]; then
      echo "y" | lvremove $(lvdisplay | grep ${LOCAL_VG} | grep "LV Path" | awk '{print $3}')
    fi
    vgremove ${LOCAL_VG}
    pvremove ${OSD_DEVICE}
    ceph-volume lvm zap ${device} --destroy
  fi
  wipefs --all ${device}
  # Wipe the first 200MB boundary, as Bluestore redeployments will not work otherwise
  dd if=/dev/zero of=${device} bs=1M count=200
  sgdisk --zap-all -- ${device}
}

function udev_settle {
  partprobe "${OSD_DEVICE}"
  if [ "${OSD_BLUESTORE:-0}" -eq 1 ]; then
    if [ ! -z "$BLOCK_DB" ]; then
      partprobe "${BLOCK_DB}"
    fi
    if [ ! -z "$BLOCK_WAL" ] && [ "$BLOCK_WAL" != "$BLOCK_DB" ]; then
      partprobe "${BLOCK_WAL}"
    fi
  else
    if [ "x$JOURNAL_TYPE" == "xblock-logical" ] && [ ! -z "$OSD_JOURNAL" ]; then
      OSD_JOURNAL=$(readlink -f ${OSD_JOURNAL})
      if [ ! -z "$OSD_JOURNAL" ]; then
        local JDEV=$(echo ${OSD_JOURNAL} | sed 's/[0-9]//g')
        partprobe "${JDEV}"
      fi
    fi
  fi
  # watch the udev event queue, and exit if all current events are handled
  udevadm settle --timeout=600

  # On occassion udev may not make the correct device symlinks for Ceph, just in case we make them manually
  mkdir -p /dev/disk/by-partuuid
  for dev in $(awk '!/rbd/{print $4}' /proc/partitions | grep "[0-9]"); do
    diskdev=$(echo "${dev//[!a-z]/}")
    partnum=$(echo "${dev//[!0-9]/}")
    ln -s "../../${dev}" "/dev/disk/by-partuuid/$(sgdisk -i ${partnum} /dev/${diskdev} | awk '/Partition unique GUID/{print tolower($4)}')" || true
  done
}

# Helper function to get an lvm tag from a logical volume
function get_lvm_tag_from_volume {
  logical_volume="$1"
  tag="$2"

  if [[ "$#" -lt 2 ]] || [[ -z "${logical_volume}" ]]; then
    # Return an empty string if the logical volume doesn't exist
    echo
  else
    # Get and return the specified tag from the logical volume
    lvs -o lv_tags ${logical_volume} | tr ',' '\n' | grep ${tag} | cut -d'=' -f2
  fi
}

# Helper function to get an lvm tag from a physical device
function get_lvm_tag_from_device {
  device="$1"
  tag="$2"
  # Attempt to get a logical volume for the physical device
  logical_volume="$(pvdisplay -m ${device} | awk '/Logical volume/{print $3}')"

  # Use get_lvm_tag_from_volume to get the specified tag from the logical volume
  get_lvm_tag_from_volume ${logical_volume} ${tag}
}

# Helper function to get a cluster FSID from a physical device
function get_cluster_fsid_from_device {
  device="$1"

  # Use get_lvm_tag_from_device to get the cluster FSID from the device
  get_lvm_tag_from_device ${device} ceph.cluster_fsid
}

# Helper function to get an OSD ID from a logical volume
function get_osd_id_from_volume {
  logical_volume="$1"

  # Use get_lvm_tag_from_volume to get the OSD ID from the logical volume
  get_lvm_tag_from_volume ${logical_volume} ceph.osd_id
}

# Helper function get an OSD ID from a physical device
function get_osd_id_from_device {
  device="$1"

  # Use get_lvm_tag_from_device to get the OSD ID from the device
  get_lvm_tag_from_device ${device} ceph.osd_id
}

# Helper function get an OSD FSID from a physical device
function get_osd_fsid_from_device {
  device="$1"

  # Use get_lvm_tag_from_device to get the OSD FSID from the device
  get_lvm_tag_from_device ${device} ceph.osd_fsid
}

# Helper function get an OSD DB device from a physical device
function get_osd_db_device_from_device {
  device="$1"

  # Use get_lvm_tag_from_device to get the OSD DB device from the device
  get_lvm_tag_from_device ${device} ceph.db_device
}

# Helper function get an OSD WAL device from a physical device
function get_osd_wal_device_from_device {
  device="$1"

  # Use get_lvm_tag_from_device to get the OSD WAL device from the device
  get_lvm_tag_from_device ${device} ceph.wal_device
}

function set_device_class {
  if [ ! -z "$DEVICE_CLASS" ]; then
    if [ "x$DEVICE_CLASS" != "x$(get_device_class)" ]; then
      ceph_cmd_retry --cluster "${CLUSTER}" --name="osd.${OSD_ID}" --keyring="${OSD_KEYRING}" \
        osd crush rm-device-class "osd.${OSD_ID}"
      ceph_cmd_retry --cluster "${CLUSTER}" --name="osd.${OSD_ID}" --keyring="${OSD_KEYRING}" \
        osd crush set-device-class "${DEVICE_CLASS}" "osd.${OSD_ID}"
    fi
  fi
}

function get_device_class {
  echo $(ceph_cmd_retry --cluster "${CLUSTER}" --name="osd.${OSD_ID}" --keyring="${OSD_KEYRING}" \
    osd crush get-device-class "osd.${OSD_ID}")
}
