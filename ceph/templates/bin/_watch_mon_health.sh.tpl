#!/bin/bash
set -ex
export LC_ALL=C

source variables_entrypoint.sh
source common_functions.sh

function watch_mon_health {

  while [ true ]
  do
    log "checking for zombie mons"
    /check_zombie_mons.py || true
    log "sleep 30 sec"
    sleep 30
  done
}

watch_mon_health
