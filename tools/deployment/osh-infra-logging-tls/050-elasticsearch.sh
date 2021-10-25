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
jobs:
  verify_repositories:
    cron: "*/3 * * * *"
  curator:
    cron: "*/10 * * * *"
monitoring:
  prometheus:
    enabled: true
pod:
  replicas:
    client: 1
    data: 1
    master: 2
conf:
  elasticsearch:
    snapshots:
      enabled: true
  curator:
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
            disable_action: False
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
        2:
          action: snapshot
          description: >-
            "Snapshot all indices older than 365 days"
          options:
            repository: logstash_snapshots
            name: "snapshot-%Y-.%m.%d"
            wait_for_completion: True
            max_wait: 36000
            wait_interval: 30
            ignore_empty_list: True
            continue_if_exception: False
            disable_action: False
          filters:
          - filtertype: age
            source: name
            direction: older
            timestring: '%Y.%m.%d'
            unit: days
            unit_count: 365
        3:
          action: delete_snapshots
          description: >-
            "Delete index snapshots older than 365 days"
          options:
            repository: logstash_snapshots
            timeout_override: 1200
            retry_interval: 120
            retry_count: 5
            ignore_empty_list: True
            continue_if_exception: False
            disable_action: False
          filters:
          - filtertype: pattern
            kind: prefix
            value: snapshot-
          - filtertype: age
            source: name
            direction: older
            timestring: '%Y.%m.%d'
            unit: days
            unit_count: 365

EOF

: ${OSH_INFRA_EXTRA_HELM_ARGS_ELASTICSEARCH:="$(./tools/deployment/common/get-values-overrides.sh elasticsearch)"}

helm upgrade --install elasticsearch ./elasticsearch \
  --namespace=osh-infra \
  --values=/tmp/elasticsearch.yaml\
  ${OSH_INFRA_EXTRA_HELM_ARGS} \
  ${OSH_INFRA_EXTRA_HELM_ARGS_ELASTICSEARCH}

#NOTE: Wait for deploy
./tools/deployment/common/wait-for-pods.sh osh-infra

# Delete the test pod if it still exists
kubectl delete pods -l application=elasticsearch,release_group=elasticsearch,component=test --namespace=osh-infra --ignore-not-found
helm test elasticsearch --namespace osh-infra
