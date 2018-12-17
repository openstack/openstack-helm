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

  if [ "x${EXPECTED_OSDS}" == "x${num_osd}" ] && [ "x${EXPECTED_OSDS}" == "x${num_in_osds}" ] && [ "x${EXPECTED_OSDS}" == "x${num_up_osds}"  ]; then
    echo "All OSDs (${EXPECTED_OSDS}) are in UP and IN status"
  else
    echo "All expected OSDs (${EXPECTED_OSDS}) are NOT in UP and IN status. Cluster shows OSD count=${num_osd}, UP=${num_up_osds}, IN=${num_in_osds}"
    exit 1
  fi
}

function pool_validation() {
  echo "#### Start: Checking Ceph pools ####"
  pool_dump=$(ceph osd pool ls detail -f json-pretty)
  osd_crush_rule_dump=$(ceph osd crush rule dump -f json-pretty)

  expectedCrushRuleId=""
  nrules=$(echo ${osd_crush_rule_dump} | jq length)
  c=$[nrules-1]
  for n in $(seq 0 ${c})
  do
    name=$(echo ${osd_crush_rule_dump} | jq -r .[${n}].rule_name)
    if [ "x${EXPECTED_CRUSHRULE}" == "x${name}" ]; then
      expectedCrushRuleId=$(echo ${osd_crush_rule_dump} | jq .[${n}].rule_id)
      echo "Checking against rule: id: ${expectedCrushRuleId}, name:${name}"
    fi
  done
  echo "Checking cluster for size:${RBD}, min_size:${EXPECTED_POOLMINSIZE}, crush_rule:${EXPECTED_CRUSHRULE}, crush_rule_id:${expectedCrushRuleId}"

  npools=$(echo ${pool_dump} | jq length)
  i=$[npools - 1]
  for n in $(seq 0 ${i})
  do
    size=$(echo ${pool_dump} | jq -r ".[${n}][\"size\"]")
    min_size=$(echo ${pool_dump} | jq -r ".[${n}][\"min_size\"]")
    pg_num=$(echo ${pool_dump} | jq -r ".[${n}][\"pg_num\"]")
    pg_placement_num=$(echo ${pool_dump} | jq -r ".[${n}][\"pg_placement_num\"]")
    crush_rule=$(echo ${pool_dump} | jq -r ".[${n}][\"crush_rule\"]")
    name=$(echo ${pool_dump} | jq -r ".[${n}][\"pool_name\"]")

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
  osd_pool_ls_details=$(ceph osd pool ls detail -f json-pretty)
  osd_crush_rule_dump=$(ceph osd crush rule dump -f json-pretty)

  expectedCrushRuleId=""
  nrules=$(echo ${osd_crush_rule_dump} | jq length)
  c=$[nrules-1]
  for n in $(seq 0 ${c})
  do
    name=$(echo ${osd_crush_rule_dump} | jq -r .[${n}].rule_name)

    if [ "x${EXPECTED_CRUSHRULE}" == "x${name}" ]; then
      expectedCrushRuleId=$(echo ${osd_crush_rule_dump} | jq .[${n}].rule_id)
      echo "Checking against rule: id: ${expectedCrushRuleId}, name:${name}"
    fi
  done

  echo "Checking OSD pools are configured with Crush rule name:${EXPECTED_CRUSHRULE}, id:${expectedCrushRuleId}"

  npools=$(echo ${osd_pool_ls_details} | jq length)
  i=$[npools-1]
  for p in $(seq 0 ${i})
  do
    pool_crush_rule_id=$(echo $osd_pool_ls_details | jq -r ".[${p}][\"crush_rule\"]")
    pool_name=$(echo $osd_pool_ls_details | jq -r ".[${p}][\"pool_name\"]")
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
  osd_pool_ls_details=$(ceph pg stat -f json-pretty)
  num_pgs=$(echo ${osd_pool_ls_details} | jq -r .num_pgs)
  npoolls=$(echo ${osd_pool_ls_details} | jq -r .num_pg_by_state | jq length)
  i=${npoolls-1}
  for n in $(seq 0 ${i})
  do
    pg_state=$(echo ${osd_pool_ls_details} | jq -r .num_pg_by_state[${n}].name)
    if [ "xactive+clean" == "x${pg_state}" ]; then
      active_clean_pg_num=$(echo ${osd_pool_ls_details} | jq -r .num_pg_by_state[${n}].num)
      if [ $num_pgs -eq $active_clean_pg_num ]; then
        echo "Success: All PGs configured (${num_pgs}) are in active+clean status"
      else
        echo "Error: All PGs configured (${num_pgs}) are NOT in active+clean status"
        exit 1
      fi
    fi
  done
}


function mgr_validation() {
  echo "#### Start: MGR validation ####"
  mgr_dump=$(ceph mgr dump -f json-pretty)
  echo "Checking for ${MGR_COUNT} MGRs"

  mgr_avl=$(echo ${mgr_dump} | jq -r '.["available"]')

  if [ "x${mgr_avl}" == "xtrue" ]; then
    mgr_active=$(echo ${mgr_dump} | jq -r '.["active_name"]')

    # Now test to check is we have at least one valid standby
    mgr_stdby_count=$(echo ${mgr_dump} | jq -r '.["standbys"]' | jq length)
    if [ $mgr_stdby_count -ge 1 ]
    then
      echo "Active manager ${mgr_active} is up and running. ${mgr_stdby_count} standby managers available"
    else
      echo "No standby Manager available"
      retcode=1
    fi
  else
    echo "Manager is not active"
    retcode=1
  fi

  if [ "x${retcode}" == "x1" ]
  then
    exit 1
  fi
}

check_cluster_status
check_osd_count
mgr_validation
pg_validation
pool_validation
pool_failuredomain_validation
