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

function wait_for_pgs () {
  echo "#### Start: Checking pgs ####"

  pgs_ready=0
  query='map({state: .state}) | group_by(.state) | map({state: .[0].state, count: length}) | .[] | select(.state | contains("active") or contains("premerge") | not)'

  if [[ $(ceph mon versions | awk '/version/{print $3}' | cut -d. -f1) -ge 14 ]]; then
    query=".pg_stats | ${query}"
  fi

  # Loop until all pgs are active
  while [[ $pgs_ready -lt 3 ]]; do
    pgs_state=$(ceph --cluster ${CLUSTER} pg ls -f json | jq -c "${query}")
    if [[ $(jq -c '. | select(.state | contains("peer") or contains("activating") or contains("recover") or contains("unknown") or contains("creating") | not)' <<< "${pgs_state}") ]]; then
      # If inactive PGs aren't in the allowed set of states above, fail
      echo "Failure, found inactive PGs that aren't in the allowed set of states"
      exit 1
    fi
    if [[ "${pgs_state}" ]]; then
      pgs_ready=0
    else
      (( pgs_ready+=1 ))
    fi
    sleep 3
  done
}

function check_recovery_flags () {
  echo "### Start: Checking for flags that will prevent recovery"

  # Ensure there are no flags set that will prevent recovery of degraded PGs
  if [[ $(ceph osd stat | grep "norecover\|nobackfill\|norebalance") ]]; then
    ceph osd stat
    echo "Flags are set that prevent recovery of degraded PGs"
    exit 1
  fi
}

function check_osd_count() {
  echo "#### Start: Checking OSD count ####"
  noup_flag=$(ceph osd stat | awk '/noup/ {print $2}')
  osd_stat=$(ceph osd stat -f json-pretty)
  num_osd=$(awk '/"num_osds"/{print $2}' <<< "$osd_stat" | cut -d, -f1)
  num_in_osds=$(awk '/"num_in_osds"/{print $2}' <<< "$osd_stat" | cut -d, -f1)
  num_up_osds=$(awk '/"num_up_osds"/{print $2}' <<< "$osd_stat" | cut -d, -f1)

  EXPECTED_OSDS={{.Values.conf.pool.target.osd}}
  REQUIRED_PERCENT_OF_OSDS={{.Values.conf.pool.target.required_percent_of_osds}}

  if [ ${num_up_osds} -gt ${EXPECTED_OSDS} ]; then
    echo "The expected amount of OSDs (${EXPECTED_OSDS}) is less than available OSDs (${num_up_osds}). Please, correct the value (.Values.conf.pool.target.osd)."
    exit 1
  fi

  MIN_OSDS=$(($EXPECTED_OSDS*$REQUIRED_PERCENT_OF_OSDS/100))
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
    if [ $MIN_OSDS -gt $count ]; then
      exit 1
    fi
  else
    if [ "${num_osd}" -eq 0 ]; then
      echo "There are no osds in the cluster"
      exit 1
    elif [ "${num_in_osds}" -ge "${MIN_OSDS}" ] && [ "${num_up_osds}" -ge "${MIN_OSDS}"  ]; then
      echo "Required number of OSDs (${MIN_OSDS}) are UP and IN status"
    else
      echo "Required number of OSDs (${MIN_OSDS}) are NOT UP and IN status. Cluster shows OSD count=${num_osd}, UP=${num_up_osds}, IN=${num_in_osds}"
      exit 1
    fi
  fi
}

function create_crushrule () {
  CRUSH_NAME=$1
  CRUSH_RULE=$2
  CRUSH_FAILURE_DOMAIN=$3
  CRUSH_DEVICE_CLASS=$4
  if ! ceph --cluster "${CLUSTER}" osd crush rule ls | grep -q "^\$CRUSH_NAME$"; then
    ceph --cluster "${CLUSTER}" osd crush rule $CRUSH_RULE $CRUSH_NAME default $CRUSH_FAILURE_DOMAIN $CRUSH_DEVICE_CLASS || true
  fi
}

# Set mons to use the msgr2 protocol on nautilus
if [[ $(ceph mon versions | awk '/version/{print $3}' | cut -d. -f1) -ge 14 ]]; then
  ceph --cluster "${CLUSTER}" mon enable-msgr2
fi

check_osd_count
{{- range $crush_rule := .Values.conf.pool.crush_rules -}}
{{- with $crush_rule }}
create_crushrule {{ .name }} {{ .crush_rule }} {{ .failure_domain }} {{ .device_class }}
{{- end }}
{{- end }}

function reweight_osds () {
  OSD_DF_OUTPUT=$(ceph --cluster "${CLUSTER}" osd df --format json-pretty)
  for OSD_ID in $(ceph --cluster "${CLUSTER}" osd ls); do
    OSD_EXPECTED_WEIGHT=$(echo "${OSD_DF_OUTPUT}" | grep -A7 "\bosd.${OSD_ID}\b" | awk '/"kb"/{ gsub(",",""); d= $2/1073741824 ; r = sprintf("%.2f", d); print r }');
    OSD_WEIGHT=$(echo "${OSD_DF_OUTPUT}" | grep -A3 "\bosd.${OSD_ID}\b" | awk '/crush_weight/{print $2}' | cut -d',' -f1)
    if [[ "${OSD_EXPECTED_WEIGHT}" != "0.00" ]] && [[ "${OSD_WEIGHT}" != "${OSD_EXPECTED_WEIGHT}" ]]; then
      ceph --cluster "${CLUSTER}" osd crush reweight osd.${OSD_ID} ${OSD_EXPECTED_WEIGHT};
    fi
  done
}

function enable_autoscaling () {
  if [[ $(ceph mgr versions | awk '/version/{print $3}' | cut -d. -f1) -eq 14 ]]; then
    ceph mgr module enable pg_autoscaler # only required for nautilus
  fi
  ceph config set global osd_pool_default_pg_autoscale_mode on
}

function disable_autoscaling () {
  if [[ $(ceph mgr versions | awk '/version/{print $3}' | cut -d. -f1) -eq 14 ]]; then
    ceph mgr module disable pg_autoscaler # only required for nautilus
  fi
  ceph config set global osd_pool_default_pg_autoscale_mode off
}

function set_cluster_flags () {
  if [[ ! -z "${CLUSTER_SET_FLAGS}" ]]; then
    for flag in ${CLUSTER_SET_FLAGS}; do
      ceph osd set ${flag}
    done
  fi
}

function unset_cluster_flags () {
  if [[ ! -z "${CLUSTER_UNSET_FLAGS}" ]]; then
    for flag in ${CLUSTER_UNSET_FLAGS}; do
      ceph osd unset ${flag}
    done
  fi
}

function create_pool () {
  POOL_APPLICATION=$1
  POOL_NAME=$2
  POOL_REPLICATION=$3
  POOL_PLACEMENT_GROUPS=$4
  POOL_CRUSH_RULE=$5
  POOL_PROTECTION=$6
  PG_NUM_MIN={{.Values.conf.pool.target.pg_num_min}}
  if ! ceph --cluster "${CLUSTER}" osd pool stats "${POOL_NAME}" > /dev/null 2>&1; then
    if [[ ${POOL_PLACEMENT_GROUPS} -gt 0 ]]; then
      ceph --cluster "${CLUSTER}" osd pool create "${POOL_NAME}" ${POOL_PLACEMENT_GROUPS}
    else
      ceph --cluster "${CLUSTER}" osd pool create "${POOL_NAME}" ${PG_NUM_MIN} --pg-num-min ${PG_NUM_MIN}
    fi
    while [ $(ceph --cluster "${CLUSTER}" -s | grep creating -c) -gt 0 ]; do echo -n .;sleep 1; done
    ceph --cluster "${CLUSTER}" osd pool application enable "${POOL_NAME}" "${POOL_APPLICATION}"
  fi

  if [[ $(ceph mgr versions | awk '/version/{print $3}' | cut -d. -f1) -ge 14 ]]; then
    if [[ "${ENABLE_AUTOSCALER}" == "true" ]]; then
      pool_values=$(ceph --cluster "${CLUSTER}" osd pool get "${POOL_NAME}" all -f json)
      pg_num=$(jq '.pg_num' <<< "${pool_values}")
      pg_num_min=$(jq '.pg_num_min' <<< "${pool_values}")
      # set pg_num_min to PG_NUM_MIN before enabling autoscaler
      if [[ ${pg_num_min} -gt ${PG_NUM_MIN} ]] || [[ ${pg_num} -gt ${PG_NUM_MIN} ]]; then
        ceph --cluster "${CLUSTER}" osd pool set "${POOL_NAME}" pg_num_min ${PG_NUM_MIN}
      fi
      ceph --cluster "${CLUSTER}" osd pool set "${POOL_NAME}" pg_autoscale_mode on
    else
      ceph --cluster "${CLUSTER}" osd pool set "${POOL_NAME}" pg_autoscale_mode off
    fi
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
# set pg_num to pool
  if [[ ${POOL_PLACEMENT_GROUPS} -gt 0 ]]; then
    for PG_PARAM in pg_num pgp_num; do
      CURRENT_PG_VALUE=$(ceph --cluster "${CLUSTER}" osd pool get "${POOL_NAME}" "${PG_PARAM}" | awk "/^${PG_PARAM}:/ { print \$NF }")
      if [ "${POOL_PLACEMENT_GROUPS}" -gt "${CURRENT_PG_VALUE}" ]; then
        ceph --cluster "${CLUSTER}" osd pool set "${POOL_NAME}" "${PG_PARAM}" "${POOL_PLACEMENT_GROUPS}"
      fi
    done
  fi

#This is to handle cluster expansion case where replication may change from intilization
  if [ ${POOL_REPLICATION} -gt 1 ]; then
    EXPECTED_POOLMINSIZE=$[${POOL_REPLICATION}-1]
    ceph --cluster "${CLUSTER}" osd pool set "${POOL_NAME}" min_size ${EXPECTED_POOLMINSIZE}
  fi
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
# - nodelete     = Do not allow deletion of the pool
#
  if [ "x${POOL_PROTECTION}" == "xtrue" ] ||  [ "x${POOL_PROTECTION}" == "x1" ]; then
    ceph --cluster "${CLUSTER}" osd pool set "${POOL_NAME}" nosizechange true
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
  POOL_QUOTA=$7
  POOL_PROTECTION=$8
  CLUSTER_CAPACITY=$9
  TOTAL_OSDS={{.Values.conf.pool.target.osd}}
  POOL_PLACEMENT_GROUPS=0
  if [[ -n "${TOTAL_DATA_PERCENT}" ]]; then
    if [[ "${ENABLE_AUTOSCALER}" == "false" ]] || [[ $(ceph mgr versions | awk '/version/{print $3}' | cut -d. -f1) -lt 14 ]]; then
      POOL_PLACEMENT_GROUPS=$(python3 /tmp/pool-calc.py ${POOL_REPLICATION} ${TOTAL_OSDS} ${TOTAL_DATA_PERCENT} ${TARGET_PG_PER_OSD})
    fi
  fi
  create_pool "${POOL_APPLICATION}" "${POOL_NAME}" "${POOL_REPLICATION}" "${POOL_PLACEMENT_GROUPS}" "${POOL_CRUSH_RULE}" "${POOL_PROTECTION}"
  POOL_REPLICAS=$(ceph --cluster "${CLUSTER}" osd pool get "${POOL_NAME}" size | awk '{print $2}')
  ceph --cluster "${CLUSTER}" osd pool set-quota "${POOL_NAME}" max_bytes $POOL_QUOTA
}

# Helper to convert TiB, TB, GiB, GB, MiB, MB, KiB, KB, or bytes to bytes
function convert_to_bytes() {
  value=${1}
  value="$(echo "${value}" | sed 's/TiB/ \* 1024GiB/g')"
  value="$(echo "${value}" | sed 's/TB/ \* 1000GB/g')"
  value="$(echo "${value}" | sed 's/GiB/ \* 1024MiB/g')"
  value="$(echo "${value}" | sed 's/GB/ \* 1000MB/g')"
  value="$(echo "${value}" | sed 's/MiB/ \* 1024KiB/g')"
  value="$(echo "${value}" | sed 's/MB/ \* 1000KB/g')"
  value="$(echo "${value}" | sed 's/KiB/ \* 1024/g')"
  value="$(echo "${value}" | sed 's/KB/ \* 1000/g')"
  python3 -c "print(int(${value}))"
}

set_cluster_flags
unset_cluster_flags
reweight_osds

{{ $targetOSDCount := .Values.conf.pool.target.osd }}
{{ $targetFinalOSDCount := .Values.conf.pool.target.final_osd }}
{{ $targetPGperOSD := .Values.conf.pool.target.pg_per_osd }}
{{ $crushRuleDefault := .Values.conf.pool.default.crush_rule }}
{{ $targetQuota := .Values.conf.pool.target.quota | default 100 }}
{{ $targetProtection := .Values.conf.pool.target.protected | default "false" | quote | lower }}
cluster_capacity=$(ceph --cluster "${CLUSTER}" df -f json-pretty | grep '"total_bytes":' | head -n1 | awk '{print $2}' | tr -d ',')

# Check to make sure pool quotas don't exceed the expected cluster capacity in its final state
target_quota=$(python3 -c "print(int(${cluster_capacity} * {{ $targetFinalOSDCount }} / {{ $targetOSDCount }} * {{ $targetQuota }} / 100))")
quota_sum=0

{{- range $pool := .Values.conf.pool.spec -}}
{{- with $pool }}
# Read the pool quota from the pool spec (no quota if absent)
# Set pool_quota to 0 if target_quota is 0
[[ ${target_quota} -eq 0 ]] && pool_quota=0 || pool_quota="$(convert_to_bytes {{ .pool_quota | default 0 }})"
quota_sum=$(python3 -c "print(int(${quota_sum} + (${pool_quota} * {{ .replication }})))")
{{- end }}
{{- end }}

if [[ ${quota_sum} -gt ${target_quota} ]]; then
  echo "The sum of all pool quotas exceeds the target quota for the cluster"
  exit 1
fi

if [[ $(ceph mgr versions | awk '/version/{print $3}' | cut -d. -f1) -ge 14 ]] && [[ "${ENABLE_AUTOSCALER}" != "true" ]]; then
  disable_autoscaling
fi

{{- range $pool := .Values.conf.pool.spec -}}
{{- with $pool }}
pool_name="{{ .name }}"
{{- if .rename }}
# If a renamed pool exists, that name should be used for idempotence
if [[ -n "$(ceph --cluster ${CLUSTER} osd pool ls | grep ^{{ .rename }}$)" ]]; then
  pool_name="{{ .rename }}"
fi
{{- end }}
# Read the pool quota from the pool spec (no quota if absent)
# Set pool_quota to 0 if target_quota is 0
[[ ${target_quota} -eq 0 ]] && pool_quota=0 || pool_quota="$(convert_to_bytes {{ .pool_quota | default 0 }})"
{{- if .crush_rule }}
manage_pool {{ .application }} ${pool_name} {{ .replication }} {{ .percent_total_data }} {{ $targetPGperOSD }} {{ .crush_rule }} $pool_quota {{ $targetProtection }} ${cluster_capacity}
{{ else }}
manage_pool {{ .application }} ${pool_name} {{ .replication }} {{ .percent_total_data }} {{ $targetPGperOSD }} {{ $crushRuleDefault }} $pool_quota {{ $targetProtection }} ${cluster_capacity}
{{- end }}
{{- if .rename }}
# If a rename value exists, the pool exists, and a pool with the rename value doesn't exist, rename the pool
if [[ -n "$(ceph --cluster ${CLUSTER} osd pool ls | grep ^{{ .name }}$)" ]] &&
   [[ -z "$(ceph --cluster ${CLUSTER} osd pool ls | grep ^{{ .rename }}$)" ]]; then
  ceph --cluster "${CLUSTER}" osd pool rename "{{ .name }}" "{{ .rename }}"
  pool_name="{{ .rename }}"
fi
{{- end }}
{{- if and .delete .delete_all_pool_data }}
# If delete is set to true and delete_all_pool_data is also true, delete the pool
if [[ "true" == "{{ .delete }}" ]] &&
   [[ "true" == "{{ .delete_all_pool_data }}" ]]; then
  ceph --cluster "${CLUSTER}" tell mon.* injectargs '--mon-allow-pool-delete=true'
  ceph --cluster "${CLUSTER}" osd pool set "${pool_name}" nodelete false
  ceph --cluster "${CLUSTER}" osd pool delete "${pool_name}" "${pool_name}" --yes-i-really-really-mean-it
  ceph --cluster "${CLUSTER}" tell mon.* injectargs '--mon-allow-pool-delete=false'
fi
{{- end }}
{{- end }}
{{- end }}

if [[ $(ceph mgr versions | awk '/version/{print $3}' | cut -d. -f1) -ge 14 ]] && [[ "${ENABLE_AUTOSCALER}" == "true" ]]; then
  enable_autoscaling
fi

{{- if .Values.conf.pool.crush.tunables }}
ceph --cluster "${CLUSTER}" osd crush tunables {{ .Values.conf.pool.crush.tunables }}
{{- end }}

wait_for_pgs
check_recovery_flags
