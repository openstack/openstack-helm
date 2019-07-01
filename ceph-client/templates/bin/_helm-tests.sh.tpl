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

function check_cluster_status() {
  echo "#### Start: Checking Ceph cluster status ####"
  ceph_status_output=$(ceph -s -f json | jq -r '.health')
  ceph_health_status=$(echo $ceph_status_output | jq -r '.status')

  if [ "x${ceph_health_status}" == "xHEALTH_OK" ]; then
    echo "Ceph status is HEALTH_OK"
  else
    echo "Ceph cluster status is NOT HEALTH_OK."
    exit 1
  fi
}

function check_osd_count() {
  echo "#### Start: Checking OSD count ####"
  osd_stat_output=$(ceph osd stat -f json-pretty)

  num_osd=$(echo $osd_stat_output | jq .num_osds)
  num_in_osds=$(echo $osd_stat_output | jq .num_in_osds)
  num_up_osds=$(echo $osd_stat_output | jq .num_up_osds)
  if [ $EXPECTED_OSDS == 1 ]; then
    MIN_EXPECTED_OSDS=$EXPECTED_OSDS
  else
    MIN_EXPECTED_OSDS=$(($EXPECTED_OSDS*$REQUIRED_PERCENT_OF_OSDS/100))
  fi

  if [ "${num_osd}" -ge "${MIN_EXPECTED_OSDS}" ] && [ "${num_in_osds}" -ge "${MIN_EXPECTED_OSDS}" ] && [ "${num_up_osds}" -ge "${MIN_EXPECTED_OSDS}"  ]; then
    echo "Required number of OSDs (${MIN_EXPECTED_OSDS}) are UP and IN status"
  else
    echo "Required number of OSDs (${MIN_EXPECTED_OSDS}) are NOT UP and IN status. Cluster shows OSD count=${num_osd}, UP=${num_up_osds}, IN=${num_in_osds}"
    exit 1
  fi
}

function mgr_validation() {
  echo "#### Start: MGR validation ####"
  mgr_dump=$(ceph mgr dump -f json-pretty)
  echo "Checking for ${MGR_COUNT} MGRs"

  mgr_avl=$(echo ${mgr_dump} | jq -r '.["available"]')

  if [ "x${mgr_avl}" == "xtrue" ]; then
    mgr_active=$(echo ${mgr_dump} | jq -r '.["active_name"]')
    echo "Out of ${MGR_COUNT}, 1 MGR is active"

    # Now lets check for standby managers
    mgr_stdby_count=$(echo ${mgr_dump} | jq -r '.["standbys"]' | jq length)

    #Total MGR Count - 1 Active = Expected MGRs
    expected_standbys=$(( MGR_COUNT -1 ))

    if [ $mgr_stdby_count -eq $expected_standbys ]
    then
      echo "Cluster has 1 Active MGR, $mgr_stdby_count Standbys MGR"
    else
      echo "Cluster Standbys MGR: Expected count= $expected_standbys Available=$mgr_stdby_count"
      retcode=1
    fi

  else
    echo "No Active Manager found, Expected 1 MGR to be active out of ${MGR_COUNT}"
    retcode=1
  fi

  if [ "x${retcode}" == "x1" ]
  then
    exit 1
  fi
}

function pool_validation() {

  echo "#### Start: Checking Ceph pools ####"

  echo "From env variables, RBD pool replication count is: ${RBD}"

  # Assuming all pools have same replication count as RBD
  # If RBD replication count is greater then 1, POOLMINSIZE should be 1 less then replication count
  # If RBD replication count is not greate then 1, then POOLMINSIZE should be 1

  if [ ${RBD} -gt 1 ]; then
    EXPECTED_POOLMINSIZE=$[${RBD}-1]
  else
    EXPECTED_POOLMINSIZE=1
  fi

  echo "EXPECTED_POOLMINSIZE: ${EXPECTED_POOLMINSIZE}"

  expectedCrushRuleId=""
  nrules=$(echo ${OSD_CRUSH_RULE_DUMP} | jq length)
  c=$[nrules-1]
  for n in $(seq 0 ${c})
  do
    osd_crush_rule_obj=$(echo ${OSD_CRUSH_RULE_DUMP} | jq -r .[${n}])

    name=$(echo ${osd_crush_rule_obj} | jq -r .rule_name)
    echo "Expected Crushrule: ${EXPECTED_CRUSHRULE}, Pool Crushmap: ${name}"

    if [ "x${EXPECTED_CRUSHRULE}" == "x${name}" ]; then
      expectedCrushRuleId=$(echo ${osd_crush_rule_obj} | jq .rule_id)
      echo "Checking against rule: id: ${expectedCrushRuleId}, name:${name}"
    else
      echo "Didn't match"
    fi
  done
  echo "Checking cluster for size:${RBD}, min_size:${EXPECTED_POOLMINSIZE}, crush_rule:${EXPECTED_CRUSHRULE}, crush_rule_id:${expectedCrushRuleId}"

  npools=$(echo ${OSD_POOLS_DETAILS} | jq length)
  i=$[npools - 1]
  for n in $(seq 0 ${i})
  do
    pool_obj=$(echo ${OSD_POOLS_DETAILS} | jq -r ".[${n}]")

    size=$(echo ${pool_obj} | jq -r .size)
    min_size=$(echo ${pool_obj} | jq -r .min_size)
    pg_num=$(echo ${pool_obj} | jq -r .pg_num)
    pg_placement_num=$(echo ${pool_obj} | jq -r .pg_placement_num)
    crush_rule=$(echo ${pool_obj} | jq -r .crush_rule)
    name=$(echo ${pool_obj} | jq -r .pool_name)

    if [ "x${size}" != "x${RBD}" ] || [ "x${min_size}" != "x${EXPECTED_POOLMINSIZE}" ] \
      || [ "x${pg_num}" != "x${pg_placement_num}" ] || [ "x${crush_rule}" != "x${expectedCrushRuleId}" ]; then
      echo "Pool ${name} has incorrect parameters!!! Size=${size}, Min_Size=${min_size}, PG=${pg_num}, PGP=${pg_placement_num}, Rule=${crush_rule}"
      exit 1
    else
      echo "Pool ${name} seems configured properly. Size=${size}, Min_Size=${min_size}, PG=${pg_num}, PGP=${pg_placement_num}, Rule=${crush_rule}"
    fi
  done
}

function pool_failuredomain_validation() {
  echo "#### Start: Checking Pools are configured with specific failure domain ####"

  expectedCrushRuleId=""
  nrules=$(echo ${OSD_CRUSH_RULE_DUMP} | jq length)
  c=$[nrules-1]
  for n in $(seq 0 ${c})
  do
    osd_crush_rule_obj=$(echo ${OSD_CRUSH_RULE_DUMP} | jq -r .[${n}])

    name=$(echo ${osd_crush_rule_obj} | jq -r .rule_name)

    if [ "x${EXPECTED_CRUSHRULE}" == "x${name}" ]; then
      expectedCrushRuleId=$(echo ${osd_crush_rule_obj} | jq .rule_id)
      echo "Checking against rule: id: ${expectedCrushRuleId}, name:${name}"
    fi
  done

  echo "Checking OSD pools are configured with Crush rule name:${EXPECTED_CRUSHRULE}, id:${expectedCrushRuleId}"

  npools=$(echo ${OSD_POOLS_DETAILS} | jq length)
  i=$[npools-1]
  for p in $(seq 0 ${i})
  do
    pool_obj=$(echo ${OSD_POOLS_DETAILS} | jq -r ".[${p}]")

    pool_crush_rule_id=$(echo $pool_obj | jq -r .crush_rule)
    pool_name=$(echo $pool_obj | jq -r .pool_name)

    if [ "x${pool_crush_rule_id}" == "x${expectedCrushRuleId}" ]; then
      echo "--> Info: Pool ${pool_name} is configured with the correct rule ${pool_crush_rule_id}"
    else
      echo "--> Error : Pool ${pool_name} is NOT configured with the correct rule ${pool_crush_rule_id}"
      exit 1
    fi
  done
}

function pg_validation() {
  echo "#### Start: Checking placement groups active+clean ####"

  num_pgs=$(echo ${PG_STAT} | jq -r .num_pgs)
  npoolls=$(echo ${PG_STAT} | jq -r .num_pg_by_state | jq length)
  i=$[npoolls-1]
  for n in $(seq 0 ${i})
  do
    pg_state=$(echo ${PG_STAT} | jq -r .num_pg_by_state[${n}].name)
    if [ "xactive+clean" == "x${pg_state}" ]; then
      active_clean_pg_num=$(echo ${PG_STAT} | jq -r .num_pg_by_state[${n}].num)
      if [ $num_pgs -eq $active_clean_pg_num ]; then
        echo "Success: All PGs configured (${num_pgs}) are in active+clean status"
      else
        echo "Error: All PGs configured (${num_pgs}) are NOT in active+clean status"
        exit 1
      fi
    else
      echo "Error: PG state not in active+clean status"
      exit 1
    fi
  done
}


check_cluster_status
check_osd_count
mgr_validation

OSD_POOLS_DETAILS=$(ceph osd pool ls detail -f json-pretty)
OSD_CRUSH_RULE_DUMP=$(ceph osd crush rule dump -f json-pretty)
PG_STAT=$(ceph pg stat -f json-pretty)

pg_validation
pool_validation
pool_failuredomain_validation
