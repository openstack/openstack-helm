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
gnocchi metric create --archive-policy-name low
METRIC_UUID=$(gnocchi metric list -c id -f value | head -1)
sleep 5

echo "Test: show metric"
gnocchi metric show ${METRIC_UUID}

sleep 5

echo "Test: add measures"
gnocchi measures add -m 2017-06-27T12:00:00@31 \
  -m 2017-06-27T12:03:27@20 \
  -m 2017-06-27T12:06:51@41 \
  ${METRIC_UUID}

sleep 15

echo "Test: show measures"
gnocchi measures show ${METRIC_UUID}
gnocchi measures show --aggregation min ${METRIC_UUID}

echo "Test: delete metric"
gnocchi metric delete ${METRIC_UUID}

RESOURCE_UUID={{ uuidv4 }}

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
