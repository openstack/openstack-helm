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

function check_osd_count() {
  echo "#### Start: Checking OSD count ####"
  noup_flag=$(ceph osd stat | awk '/noup/ {print $2}')
  osd_stat=$(ceph osd stat -f json-pretty)
  num_osd=$(awk '/"num_osds"/{print $2}' <<< "$osd_stat" | cut -d, -f1)
  num_in_osds=$(awk '/"num_in_osds"/{print $2}' <<< "$osd_stat" | cut -d, -f1)
  num_up_osds=$(awk '/"num_up_osds"/{print $2}' <<< "$osd_stat" | cut -d, -f1)

  MIN_OSDS=$((${num_osd}*$REQUIRED_PERCENT_OF_OSDS/100))
  if [ ${MIN_OSDS} -lt 1 ]; then
    MIN_OSDS=1
  fi

  if [ "${noup_flag}" ]; then
    osd_status=$(ceph osd dump -f json | jq -c '.osds[] | .state')
    count=0
    for osd in $osd_status; do
      if [[ "$osd" == *"up"* || "$osd" == *"new"* ]]; then
        ((count=count+1))
      fi
    done
    echo "Caution: noup flag is set. ${count} OSDs in up/new state. Required number of OSDs: ${MIN_OSDS}."
    ceph -s
    exit 0
  else
    if [ "${num_osd}" -eq 0 ]; then
      echo "There are no osds in the cluster"
    elif [ "${num_in_osds}" -ge "${MIN_OSDS}" ] && [ "${num_up_osds}" -ge "${MIN_OSDS}"  ]; then
      echo "Required number of OSDs (${MIN_OSDS}) are UP and IN status"
      ceph -s
      exit 0
    else
      echo "Required number of OSDs (${MIN_OSDS}) are NOT UP and IN status. Cluster shows OSD count=${num_osd}, UP=${num_up_osds}, IN=${num_in_osds}"
    fi
  fi
}

# in case the chart has been re-installed in order to make changes to daemonset
# we do not need rack_by_rack restarts
# but we need to wait until all re-installed ceph-osd pods are healthy
# and there is degraded objects
while true; do
  check_osd_count
  sleep 60
done

