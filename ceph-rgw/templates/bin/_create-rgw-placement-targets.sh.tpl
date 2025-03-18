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

set -e

function create_rgw_placement_target () {
  echo "Creating rgw placement target $2"
  radosgw-admin zonegroup placement add \
    --rgw-zonegroup "$1" \
    --placement-id "$2"
}

function delete_rgw_placement_target () {
  echo "Deleting rgw placement target $1"
  radosgw-admin zonegroup placement rm --rgw-zonegroup "$1" --placement-id "$2"
}

function add_rgw_zone_placement () {
  echo "Adding rgw zone placement for placement target $2 data pool $3"
  radosgw-admin zone placement add \
    --rgw-zone "$1" \
    --placement-id "$2" \
    --data-pool "$3" \
    --index-pool "$4" \
    --data-extra-pool "$5"
}

function rm_rgw_zone_placement () {
  echo "Removing rgw zone placement for placement target $1"
  radosgw-admin zone placement rm --rgw-zone "$1" --placement-id "$2"
}

{{- range $i, $placement_target := .Values.conf.rgw_placement_targets }}
RGW_PLACEMENT_TARGET={{ $placement_target.name | quote }}
RGW_PLACEMENT_TARGET_DATA_POOL={{ $placement_target.data_pool | quote }}
RGW_PLACEMENT_TARGET_INDEX_POOL={{ $placement_target.index_pool | default "default.rgw.buckets.index" | quote }}
RGW_PLACEMENT_TARGET_DATA_EXTRA_POOL={{ $placement_target.data_extra_pool | default "default.rgw.buckets.non-ec" | quote }}
RGW_ZONEGROUP={{ $placement_target.zonegroup | default "default" | quote }}
RGW_ZONE={{ $placement_target.zone | default "default" | quote }}
RGW_DELETE_PLACEMENT_TARGET={{ $placement_target.delete | default "false" | quote }}
RGW_PLACEMENT_TARGET_EXISTS=$(radosgw-admin zonegroup placement get --placement-id "$RGW_PLACEMENT_TARGET" 2>/dev/null || true)
if [[ -z "$RGW_PLACEMENT_TARGET_EXISTS" ]]; then
  create_rgw_placement_target "$RGW_ZONEGROUP" "$RGW_PLACEMENT_TARGET"
  add_rgw_zone_placement "$RGW_ZONE" "$RGW_PLACEMENT_TARGET" "$RGW_PLACEMENT_TARGET_DATA_POOL" "$RGW_PLACEMENT_TARGET_INDEX_POOL" "$RGW_PLACEMENT_TARGET_DATA_EXTRA_POOL"
  RGW_PLACEMENT_TARGET_EXISTS=$(radosgw-admin zonegroup placement get --placement-id "$RGW_PLACEMENT_TARGET" 2>/dev/null || true)
fi
if [[ -n "$RGW_PLACEMENT_TARGET_EXISTS" ]] &&
   [[ "true" == "$RGW_DELETE_PLACEMENT_TARGET" ]]; then
  rm_rgw_zone_placement "$RGW_ZONE" "$RGW_PLACEMENT_TARGET"
  delete_rgw_placement_target "$RGW_ZONEGROUP" "$RGW_PLACEMENT_TARGET"
fi
{{- end }}
