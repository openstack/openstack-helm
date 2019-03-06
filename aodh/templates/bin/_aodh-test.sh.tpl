#!/bin/bash

{{/*
Copyright 2019 Wind River Systems, Inc.

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

echo "Test: create an alarm"
aodh alarm create \
    --name test_cpu_aggregation \
    --type gnocchi_aggregation_by_resources_threshold \
    --metric cpu --threshold 214106115 \
    --comparison-operator lt \
    --aggregation-method mean \
    --granularity 300  \
    --evaluation-periods 1 \
    --alarm-action 'http://localhost:8776/alarm' \
    --resource-type instance \
    --query '{"=": {"flavor_name": "small"}}'
sleep 5

echo "Test: list alarms"
aodh alarm list
sleep 5

echo "Test: show an alarm"
ALARM_UUID=$(aodh alarm list -c alarm_id -f value | head -1)
aodh alarm show ${ALARM_UUID}
sleep 5

echo "Test: update an alarm"
aodh alarm update ${ALARM_UUID} --comparison-operator gt
sleep 5

echo "Test: delete an alarm"
aodh alarm delete ${ALARM_UUID}

exit 0

