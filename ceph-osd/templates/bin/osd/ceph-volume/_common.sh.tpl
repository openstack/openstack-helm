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
shopt -s expand_aliases
export lock_fd=''
export ALREADY_LOCKED=0
export PS4='+${BASH_SOURCE:+$(basename ${BASH_SOURCE}):${LINENO}:}${FUNCNAME:+${FUNCNAME}():} '

source /tmp/utils-resolveLocations.sh

: "${CRUSH_LOCATION:=root=default host=${HOSTNAME}}"
: "${OSD_PATH_BASE:=/var/lib/ceph/osd/${CLUSTER}}"
: "${CEPH_CONF:="/etc/ceph/${CLUSTER}.conf"}"
: "${OSD_BOOTSTRAP_KEYRING:=/var/lib/ceph/bootstrap-osd/${CLUSTER}.keyring}"
: "${OSD_JOURNAL_UUID:=$(uuidgen)}"
: "${OSD_JOURNAL_SIZE:=$(awk '/^osd_journal_size/{print $3}' ${CEPH_CONF}.template)}"
: "${OSD_WEIGHT:=1.0}"

{{ include "helm-toolkit.snippets.mon_host_from_k8s_ep" . }}

# Obtain a global lock on /var/lib/ceph/tmp/init-osd.lock
function lock() {
  # Open a file descriptor for the lock file if there isn't one already
  if [[ -z "${lock_fd}" ]]; then
    exec {lock_fd}>/var/lib/ceph/tmp/init-osd.lock || exit 1
  fi
  flock -w 600 "${lock_fd}" &> /dev/null
  ALREADY_LOCKED=1
}

# Release the global lock on /var/lib/ceph/tmp/init-osd.lock
function unlock() {
  flock -u "${lock_fd}" &> /dev/null
  ALREADY_LOCKED=0
}

# "Destructor" for common.sh, must be called by scripts that source this one
function common_cleanup() {
  # Close the file descriptor for the lock file
  if [[ ! -z "${lock_fd}" ]]; then
    if [[ ${ALREADY_LOCKED} -ne 0 ]]; then
      unlock
    fi
    eval "exec ${lock_fd}>&-"
  fi
}

# Run a command within the global synchronization lock
function locked() {
  # Don't log every command inside locked() to keep logs cleaner
  { set +x; } 2>/dev/null

  local LOCK_SCOPE=0

  # Allow locks to be re-entrant to avoid deadlocks
  if [[ ${ALREADY_LOCKED} -eq 0 ]]; then
    lock
    LOCK_SCOPE=1
  fi

  # Execute the synchronized command
  set -x
  "$@"
  { set +x; } 2>/dev/null

  # Only unlock if the lock was obtained in this scope
  if [[ ${LOCK_SCOPE} -ne 0 ]]; then
    unlock
  fi

  # Re-enable command logging
  set -x
}

# Alias commands that interact with disks so they are always synchronized
alias dmsetup='locked dmsetup'
alias pvs='locked pvs'
alias vgs='locked vgs'
alias lvs='locked lvs'
alias pvdisplay='locked pvdisplay'
alias vgdisplay='locked vgdisplay'
alias lvdisplay='locked lvdisplay'
alias pvcreate='locked pvcreate'
alias vgcreate='locked vgcreate'
alias lvcreate='locked lvcreate'
alias pvremove='locked pvremove'
alias vgremove='locked vgremove'
alias lvremove='locked lvremove'
alias pvrename='locked pvrename'
alias vgrename='locked vgrename'
alias lvrename='locked lvrename'
alias pvchange='locked pvchange'
alias vgchange='locked vgchange'
alias lvchange='locked lvchange'
alias pvscan='locked pvscan'
alias vgscan='locked vgscan'
alias lvscan='locked lvscan'
alias lvm_scan='locked lvm_scan'
alias partprobe='locked partprobe'
alias ceph-volume='locked ceph-volume'
alias disk_zap='locked disk_zap'
alias zap_extra_partitions='locked zap_extra_partitions'
alias udev_settle='locked udev_settle'
alias wipefs='locked wipefs'
alias sgdisk='locked sgdisk'
alias dd='locked dd'

eval CRUSH_FAILURE_DOMAIN_TYPE=$(cat /etc/ceph/storage.json | python3 -c 'import sys, json; data = json.load(sys.stdin); print(json.dumps(data["failure_domain"]))')
eval CRUSH_FAILURE_DOMAIN_NAME=$(cat /etc/ceph/storage.json | python3 -c 'import sys, json; data = json.load(sys.stdin); print(json.dumps(data["failure_domain_name"]))')
eval CRUSH_FAILURE_DOMAIN_NAME=$(cat /etc/ceph/storage.json | python3 -c 'import sys, json; data = json.load(sys.stdin); print(json.dumps(data["failure_domain_name"]))')
eval CRUSH_FAILURE_DOMAIN_BY_HOSTNAME=$(cat /etc/ceph/storage.json | python3 -c 'import sys, json; data = json.load(sys.stdin); print(json.dumps(data["failure_domain_by_hostname"]))')
eval CRUSH_FAILURE_DOMAIN_FROM_HOSTNAME_MAP=$(cat /etc/ceph/storage.json | jq '.failure_domain_by_hostname_map."'$HOSTNAME'"')
eval DEVICE_CLASS=$(cat /etc/ceph/storage.json | python3 -c 'import sys, json; data = json.load(sys.stdin); print(json.dumps(data["device_class"]))')

if [[ $(ceph -v | awk '/version/{print $3}' | cut -d. -f1) -lt 12 ]]; then
    echo "ERROR - The minimum Ceph version supported is Luminous 12.x.x"
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
  ENDPOINT=$(mon_host_from_k8s_ep "${NAMESPACE}" ceph-mon-discovery)
  if [[ -z "${ENDPOINT}" ]]; then
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

    echo "Lets check this host is registered in k8s"
    if kubectl get node  ${HOSTNAME}; then
      CRUSH_FAILURE_DOMAIN_NAME_FROM_NODE_LABEL=$(kubectl get node  ${HOSTNAME} -o json| jq -r '.metadata.labels.rack')
    else
      echo "It seems there is some issue with setting the hostname on this node hence we didnt found this node in k8s"
      kubectl get nodes
      echo ${HOSTNAME}
      exit 1
    fi

    if [ ${CRUSH_FAILURE_DOMAIN_NAME_FROM_NODE_LABEL} != "null" ]; then
      CRUSH_FAILURE_DOMAIN_NAME=${CRUSH_FAILURE_DOMAIN_NAME_FROM_NODE_LABEL}
    fi

    if [ "x${CRUSH_FAILURE_DOMAIN_NAME}" != "xfalse" ]; then
      crush_add_and_move "${CRUSH_FAILURE_DOMAIN_TYPE}" "${CRUSH_FAILURE_DOMAIN_NAME}"
    elif [ "x${CRUSH_FAILURE_DOMAIN_BY_HOSTNAME}" != "xfalse" ]; then
      crush_add_and_move "${CRUSH_FAILURE_DOMAIN_TYPE}" "$(echo ${CRUSH_FAILURE_DOMAIN_TYPE}_$(echo ${HOSTNAME} | cut -c ${CRUSH_FAILURE_DOMAIN_BY_HOSTNAME}))"
    elif [ "x${CRUSH_FAILURE_DOMAIN_FROM_HOSTNAME_MAP}" != "xnull" ]; then
      crush_add_and_move "${CRUSH_FAILURE_DOMAIN_TYPE}" "${CRUSH_FAILURE_DOMAIN_FROM_HOSTNAME_MAP}"
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
    /usr/bin/flock -s ${journal_disk} /sbin/partprobe ${journal_disk}
  fi
  if [ ! -z "${block_db_disk}" ]; then
    sgdisk -d ${block_db_part} ${block_db_disk}
    /usr/bin/flock -s ${block_db_disk} /sbin/partprobe ${block_db_disk}
  fi
  if [ ! -z "${block_wal_disk}" ]; then
    sgdisk -d ${block_wal_part} ${block_wal_disk}
    /usr/bin/flock -s ${block_wal_disk} /sbin/partprobe ${block_wal_disk}
  fi
}

function disk_zap {
  # Run all the commands to clear a disk
  local device=${1}
  local dm_devices=$(get_dm_devices_from_osd_device "${device}" | xargs)
  for dm_device in ${dm_devices}; do
    if [[ "$(dmsetup ls | grep ${dm_device})" ]]; then
      dmsetup remove ${dm_device}
    fi
  done
  local logical_volumes=$(get_lv_paths_from_osd_device "${device}" | xargs)
  if [[ "${logical_volumes}" ]]; then
    lvremove -y ${logical_volumes}
  fi
  local volume_group=$(pvdisplay -ddd -v ${device} | grep "VG Name" | awk '/ceph/{print $3}' | grep "ceph")
  if [[ ${volume_group} ]]; then
    vgremove -y ${volume_group}
    pvremove -y ${device}
    ceph-volume lvm zap ${device} --destroy
  fi
  wipefs --all ${device}
  sgdisk --zap-all -- ${device}
  # Wipe the first 200MB boundary, as Bluestore redeployments will not work otherwise
  dd if=/dev/zero of=${device} bs=1M count=200
}

# This should be run atomically to prevent unexpected cache states
function lvm_scan {
  pvscan --cache
  vgscan --cache
  lvscan --cache
  pvscan
  vgscan
  lvscan
}

function wait_for_device {
  local device="$1"

  echo "Waiting for block device ${device} to appear"
  for countdown in {1..600}; do
    test -b "${device}" && break
    sleep 1
  done
  test -b "${device}" || exit 1
}

function udev_settle {
  osd_devices="${OSD_DEVICE}"
  partprobe "${OSD_DEVICE}"
  lvm_scan
  if [ "${OSD_BLUESTORE:-0}" -eq 1 ]; then
    if [ ! -z "$BLOCK_DB" ]; then
      osd_devices="${osd_devices}\|${BLOCK_DB}"
      # BLOCK_DB could be a physical or logical device here
      local block_db="$BLOCK_DB"
      local db_vg="$(echo $block_db | cut -d'/' -f1)"
      if [ ! -z "$db_vg" ]; then
        block_db=$(pvdisplay -ddd -v | grep -B1 "$db_vg" | awk '/PV Name/{print $3}')
      fi
      partprobe "${block_db}"
    fi
    if [ ! -z "$BLOCK_WAL" ] && [ "$BLOCK_WAL" != "$BLOCK_DB" ]; then
      osd_devices="${osd_devices}\|${BLOCK_WAL}"
      # BLOCK_WAL could be a physical or logical device here
      local block_wal="$BLOCK_WAL"
      local wal_vg="$(echo $block_wal | cut -d'/' -f1)"
      if [ ! -z "$wal_vg" ]; then
        block_wal=$(pvdisplay -ddd -v | grep -B1 "$wal_vg" | awk '/PV Name/{print $3}')
      fi
      partprobe "${block_wal}"
    fi
  else
    if [ "x$JOURNAL_TYPE" == "xblock-logical" ] && [ ! -z "$OSD_JOURNAL" ]; then
      OSD_JOURNAL=$(readlink -f ${OSD_JOURNAL})
      if [ ! -z "$OSD_JOURNAL" ]; then
        local JDEV=$(echo ${OSD_JOURNAL} | sed 's/[0-9]//g')
        osd_devices="${osd_devices}\|${JDEV}"
        partprobe "${JDEV}"
        wait_for_device "${JDEV}"
      fi
    fi
  fi

  # On occassion udev may not make the correct device symlinks for Ceph, just in case we make them manually
  mkdir -p /dev/disk/by-partuuid
  for dev in $(awk '!/rbd/{print $4}' /proc/partitions | grep "${osd_devices}" | grep "[0-9]"); do
    diskdev=$(echo "${dev//[!a-z]/}")
    partnum=$(echo "${dev//[!0-9]/}")
    symlink="/dev/disk/by-partuuid/$(sgdisk -i ${partnum} /dev/${diskdev} | awk '/Partition unique GUID/{print tolower($4)}')"
    if [ ! -e "${symlink}" ]; then
      ln -s "../../${dev}" "${symlink}"
    fi
  done
}

# Helper function to get a logical volume from a physical volume
function get_lv_from_device {
  device="$1"

  pvdisplay -ddd -v -m ${device} | awk '/Logical volume/{print $3}'
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
  logical_volume="$(get_lv_from_device ${device})"

  # Use get_lvm_tag_from_volume to get the specified tag from the logical volume
  get_lvm_tag_from_volume ${logical_volume} ${tag}
}

# Helper function to get the size of a logical volume
function get_lv_size_from_device {
  device="$1"
  logical_volume="$(get_lv_from_device ${device})"

  lvs ${logical_volume} -o LV_SIZE --noheadings --units k --nosuffix | xargs | cut -d'.' -f1
}

# Helper function to get the crush weight for an osd device
function get_osd_crush_weight_from_device {
  device="$1"
  lv_size="$(get_lv_size_from_device ${device})" # KiB

  if [[ ! -z "${BLOCK_DB_SIZE}" ]]; then
    db_size=$(echo "${BLOCK_DB_SIZE}" | cut -d'B' -f1 | numfmt --from=iec | awk '{print $1/1024}') # KiB
    lv_size=$((lv_size+db_size)) # KiB
  fi

  echo ${lv_size} | awk '{printf("%.2f\n", $1/1073741824)}' # KiB to TiB
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

function get_block_uuid_from_device {
  device="$1"

  get_lvm_tag_from_device ${device} ceph.block_uuid
}

function get_dm_devices_from_osd_device {
  device="$1"
  pv_uuid=$(pvdisplay -ddd -v ${device} | awk '/PV UUID/{print $3}')

  # Return the list of dm devices that belong to the osd
  if [[ "${pv_uuid}" ]]; then
    dmsetup ls | grep "$(echo "${pv_uuid}" | sed 's/-/--/g')" | awk '{print $1}'
  fi
}

function get_lv_paths_from_osd_device {
  device="$1"
  pv_uuid=$(pvdisplay -ddd -v ${device} | awk '/PV UUID/{print $3}')

  # Return the list of lvs that belong to the osd
  if [[ "${pv_uuid}" ]]; then
    lvdisplay | grep "LV Path" | grep "${pv_uuid}" | awk '{print $3}'
  fi
}

function get_vg_name_from_device {
  device="$1"
  pv_uuid=$(pvdisplay -ddd -v ${device} | awk '/PV UUID/{print $3}')

  if [[ "${pv_uuid}" ]]; then
    echo "ceph-vg-${pv_uuid}"
  fi
}

function get_lv_name_from_device {
  device="$1"
  device_type="$2"
  pv_uuid=$(pvdisplay -ddd -v ${device} | awk '/PV UUID/{print $3}')

  if [[ "${pv_uuid}" ]]; then
    echo "ceph-${device_type}-${pv_uuid}"
  fi
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
