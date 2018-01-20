#!/bin/bash
set -ex
export LC_ALL=C

function watch_mon_health {
  while [ true ]; do
    echo "checking for zombie mons"
    /tmp/moncheck-reap-zombies.py || true
    echo "sleep 30 sec"
    sleep 30
  done
}

watch_mon_health
