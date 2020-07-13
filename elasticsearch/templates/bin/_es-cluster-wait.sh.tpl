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

function check_cluster_health() {
  RESPONSE=$(curl -s -K- <<< "--user ${ELASTICSEARCH_USERNAME}:${ELASTICSEARCH_PASSWORD}" \
    "${ELASTICSEARCH_HOST}/_cat/health?format=json&pretty" )
  echo "Response: $RESPONSE"
  STATUS=$(echo $RESPONSE | jq -r .[].status)
  echo "Status: $STATUS"
}

check_cluster_health
while [[ $STATUS != "yellow" ]] && [[ $STATUS != "green" ]]; do
  echo "Waiting for cluster to become ready."
  sleep 30
  check_cluster_health
done
echo "Cluster is ready."
