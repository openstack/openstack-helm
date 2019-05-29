#!/bin/bash
{{/*
Copyright 2019 The Openstack-Helm Authors.

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

function check_master_nodes() {
  numMasterNodes=0
  expectedMasterNodes={{ .Values.pod.replicas.master | int64 }}
  while [ "$numMasterNodes" -ne "$expectedMasterNodes" ]
  do
    currentMasterNodes=$(curl -K- <<< "--user ${ELASTICSEARCH_USERNAME}:${ELASTICSEARCH_PASSWORD}" \
      "${ELASTICSEARCH_HOST}/_cat/nodes?format=json&pretty" | jq -r '.[] | select(.name|test("elasticsearch-master.")) | .name')
    numMasterNodes=$(echo $currentMasterNodes | wc -w)
    if [ "$numMasterNodes" -ne "$expectedMasterNodes" ]
    then
      if [ "$numMasterNodes" -eq 0 ]
      then
        echo "No Elasticsearch master nodes accounted for: 0/${expectedMasterNodes}"
      else
        echo "Not all Elasticsearch master nodes accounted for and ready: (${numMasterNodes} / ${expectedMasterNodes})"
        echo "$currentMasterNodes"
        echo "Sleeping for 10 seconds before next check"
        echo ""
        sleep 10
      fi
    fi
  done
  echo "All Elasticsearch master nodes accounted for and ready: (${numMasterNodes} / ${expectedMasterNodes})"
  echo "$currentMasterNodes"
  echo ""
}

function check_data_nodes() {
  numDataNodes=0
  expectedDataNodes={{ .Values.pod.replicas.data | int64 }}
  while [ "$numDataNodes" -ne "$expectedDataNodes" ]
  do
    currentDataNodes=$(curl -K- <<< "--user ${ELASTICSEARCH_USERNAME}:${ELASTICSEARCH_PASSWORD}" \
      "${ELASTICSEARCH_HOST}/_cat/nodes?format=json&pretty" | jq -r '.[] | select(.name|test("elasticsearch-data.")) | .name')
    numDataNodes=$(echo $currentDataNodes | wc -w)
    if [ "$numDataNodes" -ne "$expectedDataNodes" ]
    then
      if [ "$numDataNodes" -eq 0 ]
      then
        echo "No Elasticsearch data nodes accounted for: 0/${expectedDataNodes}"
      else
        echo "Not all Elasticsearch data nodes accounted for and ready: (${numDataNodes} / ${expectedDataNodes})"
        echo "$currentDataNodes"
        echo "Sleeping for 10 seconds before next check"
        echo ""
        sleep 10
      fi
    fi
  done
  echo "All Elasticsearch data nodes accounted for and ready: (${numDataNodes} / ${expectedDataNodes})"
  echo "$currentDataNodes"
  echo ""
}

function check_client_nodes() {
  numClientNodes=0
  expectedClientNodes={{ .Values.pod.replicas.client | int64 }}
  while [ "$numClientNodes" -ne "$expectedClientNodes" ]
  do
    currentClientNodes=$(curl -K- <<< "--user ${ELASTICSEARCH_USERNAME}:${ELASTICSEARCH_PASSWORD}" \
      "${ELASTICSEARCH_HOST}/_cat/nodes?format=json&pretty" | jq -r '.[] | select(.name|test("elasticsearch-client.")) | .name')
    numClientNodes=$(echo $currentClientNodes | wc -w)
    if [ "$numClientNodes" -ne "$expectedClientNodes" ]
    then
      if [ "$numClientNodes" -eq 0 ]
      then
        echo "No Elasticsearch client nodes accounted for: 0/${expectedClientNodes}"
      else
        echo "Not all Elasticsearch client nodes accounted for and ready: (${numClientNodes} / ${expectedClientNodes})"
        echo "$currentClientNodes"
        echo "Sleeping for 10 seconds before next check"
        echo ""
        sleep 10
      fi
    fi
  done
  echo "All Elasticsearch client nodes accounted for and ready: (${numClientNodes} / ${expectedClientNodes})"
  echo "$currentClientNodes"
  echo ""
}

function check_cluster_health() {
  clusterHealth=$(curl -K- <<< "--user ${ELASTICSEARCH_USERNAME}:${ELASTICSEARCH_PASSWORD}" \
    "${ELASTICSEARCH_HOST}/_cat/health?format=json&pretty")
  echo "Elasticsearch cluster health is:"
  echo "$clusterHealth"
}

sleep 10
check_data_nodes
check_client_nodes
check_master_nodes
check_cluster_health
