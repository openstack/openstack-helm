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
  num_osd=$(ceph osd stat | tr ' ' '\n' | grep -x -E '[0-9]+' | head -n1)
  num_in_osds=$(ceph osd stat | tr ' ' '\n' | grep -x -E '[0-9]+' | tail -n1)
  num_up_osds=$(ceph osd stat | tr ' ' '\n' | grep -x -E '[0-9]+' | head -n2 | tail -n1)

  if [ ${num_osd} -eq 1 ]; then
    MIN_OSDS=${num_osd}
  else
    MIN_OSDS=$((${num_osd}*$REQUIRED_PERCENT_OF_OSDS/100))
  fi

  if [ "${num_osd}" -eq 0 ]; then
    echo "There are no osds in the cluster"
    exit 1
  elif [ "${num_in_osds}" -ge "${MIN_OSDS}" ] && [ "${num_up_osds}" -ge "${MIN_OSDS}"  ]; then
    echo "Required number of OSDs (${MIN_OSDS}) are UP and IN status"
  else
    echo "Required number of OSDs (${MIN_OSDS}) are NOT UP and IN status. Cluster shows OSD count=${num_osd}, UP=${num_up_osds}, IN=${num_in_osds}"
    exit 1
  fi
}

check_osd_count
