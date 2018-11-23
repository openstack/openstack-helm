#!/bin/bash

{{/*
Copyright 2018 The Openstack-Helm Authors.

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
export LC_ALL=C

: "${ADMIN_KEYRING:=/etc/ceph/${CLUSTER}.client.admin.keyring}"

if [[ ! -e /etc/ceph/${CLUSTER}.conf ]]; then
  echo "ERROR- /etc/ceph/${CLUSTER}.conf must exist; get it from your existing mon"
  exit 1
fi

if [[ ! -e ${ADMIN_KEYRING} ]]; then
   echo "ERROR- ${ADMIN_KEYRING} must exist; get it from your existing mon"
   exit 1
fi

function create_crushrule () {
  CRUSH_NAME=$1
  CRUSH_RULE=$2
  CRUSH_FAILURE_DOMAIN=$3
  CRUSH_DEVICE_CLASS=$4
  if ! ceph --cluster "${CLUSTER}" osd crush rule ls | grep -q "^\$CRUSH_NAME$"; then
    ceph --cluster "${CLUSTER}" osd crush rule $CRUSH_RULE $CRUSH_NAME default $CRUSH_FAILURE_DOMAIN $CRUSH_DEVICE_CLASS || true
  fi
}

{{- range $crush_rule := .Values.conf.pool.crush_rules -}}
{{- with $crush_rule }}
create_crushrule {{ .name }} {{ .crush_rule }} {{ .failure_domain }} {{ .device_class }}
{{- end }}
{{- end }}

function reweight_osds () {
  for OSD_ID in $(ceph --cluster "${CLUSTER}" osd df | awk '$3 == "0" {print $1}'); do
    OSD_WEIGHT=$(ceph --cluster "${CLUSTER}" osd df --format json-pretty| grep -A7 "\bosd.${OSD_ID}\b" | awk '/"kb"/{ gsub(",",""); d= $2/1073741824 ; r = sprintf("%.2f", d); print r }');
    ceph --cluster "${CLUSTER}" osd crush reweight osd.${OSD_ID} ${OSD_WEIGHT};
  done
}

function create_pool () {
  POOL_APPLICATION=$1
  POOL_NAME=$2
  POOL_REPLICATION=$3
  POOL_PLACEMENT_GROUPS=$4
  POOL_CRUSH_RULE=$5
  POOL_PROTECTION=$6
  if ! ceph --cluster "${CLUSTER}" osd pool stats "${POOL_NAME}" > /dev/null 2>&1; then
    ceph --cluster "${CLUSTER}" osd pool create "${POOL_NAME}" ${POOL_PLACEMENT_GROUPS}
    while [ $(ceph --cluster "${CLUSTER}" -s | grep creating -c) -gt 0 ]; do echo -n .;sleep 1; done
    if [ "x${POOL_NAME}" == "xrbd" ]; then
      rbd --cluster "${CLUSTER}" pool init ${POOL_NAME}
    fi
    ceph --cluster "${CLUSTER}" osd pool application enable "${POOL_NAME}" "${POOL_APPLICATION}"
  fi
#
# Make sure pool is not protected after creation AND expansion so we can manipulate its settings.
# Final protection settings are applied once parameters (size, pg) have been adjusted.
#
  ceph --cluster "${CLUSTER}" osd pool set "${POOL_NAME}" nosizechange false
  ceph --cluster "${CLUSTER}" osd pool set "${POOL_NAME}" nopgchange false
  ceph --cluster "${CLUSTER}" osd pool set "${POOL_NAME}" nodelete false
#
  ceph --cluster "${CLUSTER}" osd pool set "${POOL_NAME}" size ${POOL_REPLICATION}
  ceph --cluster "${CLUSTER}" osd pool set "${POOL_NAME}" crush_rule "${POOL_CRUSH_RULE}"
  for PG_PARAM in pg_num pgp_num; do
    CURRENT_PG_VALUE=$(ceph --cluster ceph osd pool get "${POOL_NAME}" "${PG_PARAM}" | awk "/^${PG_PARAM}:/ { print \$NF }")
    if [ "${POOL_PLACEMENT_GROUPS}" -gt "${CURRENT_PG_VALUE}" ]; then
      ceph --cluster ceph osd pool set "${POOL_NAME}" "${PG_PARAM}" "${POOL_PLACEMENT_GROUPS}"
    fi
  done
#
# Handling of .Values.conf.pool.target.protected:
# Possible settings
# - true  | 1 = Protect the pools after they get created
# - false | 0 = Do not protect the pools once they get created and let Ceph defaults apply
# - Absent    = Do not protect the pools once they get created and let Ceph defaults apply
#
# If protection is not requested through values.yaml, just use the Ceph defaults. With Luminous we do not
# apply any protection to the pools when they get created.
#
# Note: If the /etc/ceph/ceph.conf file modifies the defaults the deployment will fail on pool creation
# - nosizechange = Do not allow size and min_size changes on the pool
# - nopgchange   = Do not allow pg_num and pgp_num changes on the pool
# - nodelete     = Do not allow deletion of the pool
#
  if [ "x${POOL_PROTECTION}" == "xtrue" ] ||  [ "x${POOL_PROTECTION}" == "x1" ]; then
    ceph --cluster "${CLUSTER}" osd pool set "${POOL_NAME}" nosizechange true
    ceph --cluster "${CLUSTER}" osd pool set "${POOL_NAME}" nopgchange true
    ceph --cluster "${CLUSTER}" osd pool set "${POOL_NAME}" nodelete true
  fi
}

function manage_pool () {
  POOL_APPLICATION=$1
  POOL_NAME=$2
  POOL_REPLICATION=$3
  TOTAL_DATA_PERCENT=$4
  TARGET_PG_PER_OSD=$5
  POOL_CRUSH_RULE=$6
  POOL_PROTECTION=$7
  TOTAL_OSDS=$(ceph --cluster "${CLUSTER}" osd ls | wc -l)
  if (ceph --cluster "${CLUSTER}" osd crush rule dump "${POOL_CRUSH_RULE}" | awk '/item_name/' | grep -q ssd); then
    TOTAL_OSDS=$(ceph --cluster "${CLUSTER}" osd tree | grep "ssd" | wc -l)
  elif (ceph --cluster "${CLUSTER}" osd crush rule dump "${POOL_CRUSH_RULE}" | awk '/item_name/' | grep -q hdd); then
    TOTAL_OSDS=$(ceph --cluster "${CLUSTER}" osd tree | grep "hdd" | wc -l)
  fi
  POOL_PLACEMENT_GROUPS=$(/tmp/pool-calc.py ${POOL_REPLICATION} ${TOTAL_OSDS} ${TOTAL_DATA_PERCENT} ${TARGET_PG_PER_OSD})
  create_pool "${POOL_APPLICATION}" "${POOL_NAME}" "${POOL_REPLICATION}" "${POOL_PLACEMENT_GROUPS}" "${POOL_CRUSH_RULE}" "${POOL_PROTECTION}"
}

reweight_osds

{{ $targetPGperOSD := .Values.conf.pool.target.pg_per_osd }}
{{ $crushRuleDefault := .Values.conf.pool.default.crush_rule }}
{{ $targetProtection := .Values.conf.pool.target.protected | default "false" | quote | lower }}
{{- range $pool := .Values.conf.pool.spec -}}
{{- with $pool }}
{{- if .crush_rule }}
manage_pool {{ .application }} {{ .name }} {{ .replication }} {{ .percent_total_data }} {{ $targetPGperOSD }} {{ .crush_rule }} {{ $targetProtection }}
{{ else }}
manage_pool {{ .application }} {{ .name }} {{ .replication }} {{ .percent_total_data }} {{ $targetPGperOSD }} {{ $crushRuleDefault }} {{ $targetProtection }}
{{- end }}
{{- end }}
{{- end }}

{{- if .Values.conf.pool.crush.tunables }}
ceph --cluster "${CLUSTER}" osd crush tunables {{ .Values.conf.pool.crush.tunables }}
{{- end }}
