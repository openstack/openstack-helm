#!/bin/bash

{{/*
Copyright 2017 The Openstack-Helm Authors.

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

# Check OSD status
function check_osd_status() {
  echo "--Start: Checking OSD status--"
  ceph_osd_stat_output=$(ceph osd stat -f json)
  #
  # Extract each value needed to check correct deployment of the OSDs
  #
  num_osds=$(echo $ceph_osd_stat_output | jq '.num_osds')
  up_osds=$(echo $ceph_osd_stat_output | jq '.num_up_osds')
  in_osds=$(echo $ceph_osd_stat_output | jq '.num_in_osds')
  #
  # In a correctly deployed cluster the number of UP and IN OSDs must be the same as the total number of OSDs.
  #
  if [ "x${num_osds}" == "x${up_osds}" ] && [ "x${num_osds}" == "x${in_osds}" ] ; then
    echo "Success: Total OSDs=${num_osds} Up=${up_osds} In=${in_osds}"
  else
    echo "Failure: Total OSDs=${num_osds} Up=${up_osds} In=${in_osds}"
    exit 1
  fi
}

check_osd_status
