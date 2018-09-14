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

function rgw_replicas_validation()
{
  available_rgw_count=$(ceph -s -f json-pretty | jq '.servicemap.services.rgw.daemons | del(.["summary"]) | length')

  if [ "x${available_rgw_count}" == "x${CEPH_RGW_REPLICAS}" ]; then
    echo "Correct number of RGWs available: ${available_rgw_count}"
  else
    echo "Incorrect number of RGWs. Expected count: ${CEPH_RGW_REPLICAS}, Available count: ${available_rgw_count}"
    exit 1
  fi
}

rgw_replicas_validation
