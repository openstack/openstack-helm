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
export HOME=/tmp

echo "Test: list archive policies"
gnocchi archive-policy list

echo "Test: create metric"
# Take the id from the create call. "metric list | head -1" is the first
# metric of the whole deployment, so on a live cloud the test wrote its
# measures into, and then deleted, a real metric.
METRIC_UUID=$(gnocchi metric create --archive-policy-name low -c id -f value)
sleep 5

echo "Test: show metric"
gnocchi metric show ${METRIC_UUID}

sleep 5

echo "Test: add measures"
# Recent timestamps: the low policy keeps 30 days, older measures are
# dropped and the measures shown below would be empty.
gnocchi measures add -m "$(date -u -d '-10 minutes' +%Y-%m-%dT%H:%M:%S)@31" \
  -m "$(date -u -d '-7 minutes' +%Y-%m-%dT%H:%M:%S)@20" \
  -m "$(date -u -d '-4 minutes' +%Y-%m-%dT%H:%M:%S)@41" \
  ${METRIC_UUID}

sleep 15

echo "Test: show measures"
gnocchi measures show ${METRIC_UUID}
gnocchi measures show --aggregation min ${METRIC_UUID}

echo "Test: delete metric"
gnocchi metric delete ${METRIC_UUID}

# Generated when the test runs: a uuidv4 rendered into this ConfigMap changed
# gnocchi-bin, and with it the pods' configmap-bin-hash, on every upgrade.
RESOURCE_UUID=$(cat /proc/sys/kernel/random/uuid)

echo "Test: create resource type"
gnocchi resource-type create --attribute name:string --attribute host:string test

echo "Test: list resource types"
gnocchi resource-type list

echo "Test: create resource"
gnocchi resource create --attribute name:test --attribute host:testnode1 --create-metric cpu:medium --create-metric memory:low --type test ${RESOURCE_UUID}

echo "Test: show resource history"
gnocchi resource history --format json --details ${RESOURCE_UUID}
echo "Test: delete resource"
gnocchi resource delete ${RESOURCE_UUID}
echo "Test: delete resource type"
gnocchi resource-type delete test

exit 0
