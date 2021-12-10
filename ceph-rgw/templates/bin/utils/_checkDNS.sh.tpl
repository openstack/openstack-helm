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

: "${CEPH_CONF:="/etc/ceph/${CLUSTER}.conf"}"
ENDPOINT="{$1}"

function check_mon_dns () {
  GREP_CMD=$(grep -rl 'ceph-mon' ${CEPH_CONF})

  if [[ "${ENDPOINT}" == "{up}" ]]; then
    echo "If DNS is working, we are good here"
  elif [[ "${ENDPOINT}" != "" ]]; then
    if [[ ${GREP_CMD} != "" ]]; then
      # No DNS, write CEPH MONs IPs into ${CEPH_CONF}
      sh -c -e "cat ${CEPH_CONF}.template | sed 's/mon_host.*/mon_host = ${ENDPOINT}/g' | tee ${CEPH_CONF}" > /dev/null 2>&1
    else
      echo "endpoints are already cached in ${CEPH_CONF}"
      exit
    fi
  fi
}

check_mon_dns

exit
