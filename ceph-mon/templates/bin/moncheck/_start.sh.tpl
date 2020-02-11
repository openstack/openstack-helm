#!/bin/bash
set -ex
export LC_ALL=C
: "${CEPH_CONF:="/etc/ceph/${CLUSTER}.conf"}"

if [[ ! -e ${CEPH_CONF}.template ]]; then
  echo "ERROR- ${CEPH_CONF}.template must exist; get it from your existing mon"
  exit 1
else
  ENDPOINT=$(kubectl get endpoints ceph-mon -n ${NAMESPACE} -o json | awk -F'"' -v port=${MON_PORT} '/ip/{print $4":"port}' | paste -sd',')
  if [[ ${ENDPOINT} == "" ]]; then
    /bin/sh -c -e "cat ${CEPH_CONF}.template | tee ${CEPH_CONF}" || true
  else
    /bin/sh -c -e "cat ${CEPH_CONF}.template | sed 's/mon_host.*/mon_host = ${ENDPOINT}/g' | tee ${CEPH_CONF}" || true
  fi
fi

function check_mon_msgr2 {
 if [[ -z "$(ceph mon versions | grep ceph\ version | grep -v nautilus)" ]]; then
   if ceph health detail|grep -i "MON_MSGR2_NOT_ENABLED"; then
     echo "ceph-mon msgr v2 not enabled on all ceph mons so enabling"
     ceph mon enable-msgr2
   fi
 fi
}


function watch_mon_health {
  while [ true ]; do
    echo "checking for zombie mons"
    /tmp/moncheck-reap-zombies.py || true
    echo "checking for ceph-mon msgr v2"
    check_mon_msgr2
    echo "sleep 30 sec"
    sleep 30
  done
}

watch_mon_health
