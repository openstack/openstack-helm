#!/bin/bash

#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.

set -xe

#NOTE: Lint and package chart
make elasticsearch

#NOTE: Deploy command
tee /tmp/elasticsearch.yaml << EOF
dependencies:
  static:
    tests:
      jobs: null
storage:
  data:
    enabled: false
  master:
    enabled: false
pod:
  mandatory_access_control:
    type: apparmor
    elasticsearch-master:
      elasticsearch-master: runtime/default
    elasticsearch-data:
      elasticsearch-data: runtime/default
    elasticsearch-client:
      elasticsearch-client: runtime/default
  replicas:
    client: 1
    data: 1
    master: 2
conf:
  curator:
    schedule:  "0 */6 * * *"
    action_file:
      actions:
        1:
          action: delete_indices
          description: >-
            "Delete indices older than 365 days"
          options:
            timeout_override:
            continue_if_exception: False
            ignore_empty_list: True
            disable_action: True
          filters:
          - filtertype: pattern
            kind: prefix
            value: logstash-
          - filtertype: age
            source: name
            direction: older
            timestring: '%Y.%m.%d'
            unit: days
            unit_count: 365

EOF
helm upgrade --install elasticsearch ./elasticsearch \
    --namespace=osh-infra \
    --values=/tmp/elasticsearch.yaml

#NOTE: Wait for deploy
./tools/deployment/common/wait-for-pods.sh osh-infra

# Delete the test pod if it still exists
kubectl delete pods -l application=elasticsearch,release_group=elasticsearch,component=test --namespace=osh-infra --ignore-not-found
helm test elasticsearch --namespace osh-infra
