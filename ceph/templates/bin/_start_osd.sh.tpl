#!/bin/bash
set -ex
export LC_ALL=C

source variables_entrypoint.sh
source common_functions.sh

if is_available rpm; then
  OS_VENDOR=redhat
  source /etc/sysconfig/ceph
elif is_available dpkg; then
  OS_VENDOR=ubuntu
  source /etc/default/ceph
fi

function osd_trying_to_determine_scenario {
  if [ -z "${OSD_DEVICE}" ]; then
    log "Bootstrapped OSD(s) found; using OSD directory"
    source osd_directory.sh
    osd_directory
  elif $(parted --script ${OSD_DEVICE} print | egrep -sq '^ 1.*ceph data'); then
    log "Bootstrapped OSD found; activating ${OSD_DEVICE}"
    source osd_disk_activate.sh
    osd_activate
  else
    log "Device detected, assuming ceph-disk scenario is desired"
    log "Preparing and activating ${OSD_DEVICE}"
    osd_disk
  fi
}

function start_osd {
  if [[ ! -e /etc/ceph/${CLUSTER}.conf ]]; then
    log "ERROR- /etc/ceph/${CLUSTER}.conf must exist; get it from your existing mon"
    exit 1
  fi

  if [ ${CEPH_GET_ADMIN_KEY} -eq 1 ]; then
    if [[ ! -e $ADMIN_KEYRING ]]; then
        log "ERROR- $ADMIN_KEYRING must exist; get it from your existing mon"
        exit 1
    fi
  fi

  case "$OSD_TYPE" in
    directory)
      source osd_directory.sh
      source osd_common.sh
      osd_directory
      ;;
    directory_single)
      source osd_directory_single.sh
      osd_directory_single
      ;;
    disk)
      osd_disk
      ;;
    prepare)
      source osd_disk_prepare.sh
      osd_disk_prepare
      ;;
    activate)
      source osd_disk_activate.sh
      osd_activate
      ;;
    devices)
      source osd_disks.sh
      source osd_common.sh
      osd_disks
      ;;
    activate_journal)
      source osd_activate_journal.sh
      source osd_common.sh
      osd_activate_journal
      ;;
    *)
      osd_trying_to_determine_scenario
      ;;
  esac
}

function osd_disk {
  source osd_disk_prepare.sh
  source osd_disk_activate.sh
  osd_disk_prepare
  osd_activate
}

function valid_scenarios {
  log "Valid values for CEPH_DAEMON are $ALL_SCENARIOS."
  log "Valid values for the daemon parameter are $ALL_SCENARIOS"
}

function invalid_ceph_daemon {
  if [ -z "$CEPH_DAEMON" ]; then
    log "ERROR- One of CEPH_DAEMON or a daemon parameter must be defined as the name of the daemon you want to deploy."
    valid_scenarios
    exit 1
  else
    log "ERROR- unrecognized scenario."
    valid_scenarios
  fi
}

###############
# CEPH_DAEMON #
###############

# If we are given a valid first argument, set the
# CEPH_DAEMON variable from it
case "$CEPH_DAEMON" in
  osd)
    # TAG: osd
    start_osd
    ;;
  osd_directory)
    # TAG: osd_directory
    OSD_TYPE="directory"
    start_osd
    ;;
  osd_directory_single)
    # TAG: osd_directory_single
    OSD_TYPE="directory_single"
    start_osd
    ;;
  osd_ceph_disk)
    # TAG: osd_ceph_disk
    OSD_TYPE="disk"
    start_osd
    ;;
  osd_ceph_disk_prepare)
    # TAG: osd_ceph_disk_prepare
    OSD_TYPE="prepare"
    start_osd
    ;;
  osd_ceph_disk_activate)
    # TAG: osd_ceph_disk_activate
    OSD_TYPE="activate"
    start_osd
    ;;
  osd_ceph_activate_journal)
    # TAG: osd_ceph_activate_journal
    OSD_TYPE="activate_journal"
    start_osd
    ;;
  *)
    invalid_ceph_daemon
  ;;
esac
