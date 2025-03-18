#!/bin/bash
set -ex
export LC_ALL=C
: "${CEPH_CONF:="/etc/ceph/${CLUSTER}.conf"}"

{{ include "helm-toolkit.snippets.mon_host_from_k8s_ep" . }}

if [[ ! -e ${CEPH_CONF}.template ]]; then
  echo "ERROR- ${CEPH_CONF}.template must exist; get it from your existing mon"
  exit 1
else
  ENDPOINT=$(mon_host_from_k8s_ep ${NAMESPACE} ceph-mon-discovery)
  if [[ "${ENDPOINT}" == "" ]]; then
    /bin/sh -c -e "cat ${CEPH_CONF}.template | tee ${CEPH_CONF}" || true
  else
    /bin/sh -c -e "cat ${CEPH_CONF}.template | sed 's#mon_host.*#mon_host = ${ENDPOINT}#g' | tee ${CEPH_CONF}" || true
  fi
fi

function check_mon_msgr2 {
 if [[ $(ceph mon versions | awk '/version/{print $3}' | cut -d. -f1) -ge 14 ]]; then
   if ceph health detail|grep -i "MON_MSGR2_NOT_ENABLED"; then
     echo "ceph-mon msgr v2 not enabled on all ceph mons so enabling"
     ceph mon enable-msgr2
   fi
 fi
}

function get_mon_count {
  ceph mon count-metadata hostname | jq '. | length'
}

function check_mon_addrs {
  local mon_dump=$(ceph mon dump)
  local mon_hostnames=$(echo "${mon_dump}" | awk '/mon\./{print $3}' | sed 's/mon\.//g')
  local mon_endpoints=$(kubectl get endpoints ceph-mon-discovery -n ${NAMESPACE} -o json)
  local v1_port=$(jq '.subsets[0].ports[] | select(.name == "mon") | .port' <<< ${mon_endpoints})
  local v2_port=$(jq '.subsets[0].ports[] | select(.name == "mon-msgr2") | .port' <<< ${mon_endpoints})

  for mon in ${mon_hostnames}; do
    local mon_endpoint=$(echo "${mon_dump}" | awk "/${mon}/{print \$2}")
    local mon_ip=$(jq -r ".subsets[0].addresses[] | select(.nodeName == \"${mon}\") | .ip" <<< ${mon_endpoints})

    # Skip this mon if it doesn't appear in the list of kubernetes endpoints
    if [[ -n "${mon_ip}" ]]; then
      local desired_endpoint=$(printf '[v1:%s:%s/0,v2:%s:%s/0]' ${mon_ip} ${v1_port} ${mon_ip} ${v2_port})

      if [[ "${mon_endpoint}" != "${desired_endpoint}" ]]; then
        echo "endpoint for ${mon} is ${mon_endpoint}, setting it to ${desired_endpoint}"
        ceph mon set-addrs ${mon} ${desired_endpoint}
      fi
    fi
  done
}

function watch_mon_health {
  previous_mon_count=$(get_mon_count)
  while [ true ]; do
    mon_count=$(get_mon_count)
    if [[ ${mon_count} -ne ${previous_mon_count} ]]; then
      echo "checking for zombie mons"
      python3 /tmp/moncheck-reap-zombies.py || true
    fi
    previous_mon_count=${mon_count}
    echo "checking for ceph-mon msgr v2"
    check_mon_msgr2
    echo "checking mon endpoints in monmap"
    check_mon_addrs
    echo "sleep 30 sec"
    sleep 30
  done
}

watch_mon_health
