#!/bin/bash
set -ex

osd_id_file="/tmp/osd-id"

function wait_for_file() {
  local file="$1"; shift
  local wait_seconds="${1:-30}"; shift

  until test $((wait_seconds--)) -eq 0 -o -f "$file" ; do
    sleep 1
  done

  ((++wait_seconds))
}
wait_for_file "${osd_id_file}" "${WAIT_FOR_OSD_ID_TIMEOUT}"

log_file="/var/log/ceph/${DAEMON_NAME}.$(cat "${osd_id_file}").log"
wait_for_file "${log_file}" "${WAIT_FOR_OSD_ID_TIMEOUT}"

trap "exit" SIGTERM SIGINT
keep_running=true

function tail_file () {
  while $keep_running; do
    tail --retry -f "${log_file}" &
    tail_pid=$!
    echo $tail_pid > /tmp/ceph-log-runner-tail.pid
    wait $tail_pid
    if [ -f /tmp/ceph-log-runner.stop ]; then
      keep_running=false
    fi
    sleep 30
  done
}

function truncate_log () {
  while $keep_running; do
    sleep ${TRUNCATE_PERIOD}
    sleep_pid=$!
    echo $sleep_pid > /tmp/ceph-log-runner-sleep.pid
    if [[ -f ${log_file} ]] ; then
      truncate -s "${TRUNCATE_SIZE}" "${log_file}"
    fi
  done
}

tail_file &
truncate_log &

wait -n
keep_running=false
wait
