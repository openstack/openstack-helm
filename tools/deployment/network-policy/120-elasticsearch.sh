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
network_policy:
  prometheus-elasticsearch-exporter:
    ingress:
      - from:
        - podSelector:
            matchLabels:
              application: prometheus
        ports:
        - protocol: TCP
          port: 9108
  elasticsearch:
    ingress:
      - from:
        - podSelector:
            matchLabels:
              application: elasticsearch
        - podSelector:
            matchLabels:
              application: prometheus-elasticsearch-exporter
        - podSelector:
            matchLabels:
              application: fluentd
        - podSelector:
            matchLabels:
              application: ingress
        - podSelector:
            matchLabels:
              application: kibana
        - podSelector:
            matchLabels:
              application: nagios
        ports:
        - protocol: TCP
          port: 80
        - protocol: TCP
          port: 443
        - protocol: TCP
          port: 9200
        - protocol: TCP
          port: 9300
pod:
  replicas:
    data: 1
    master: 2
conf:
  elasticsearch:
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
monitoring:
  prometheus:
    enabled: true
manifests:
  network_policy: true
  monitoring:
    prometheus:
      network_policy_exporter: true
EOF

helm upgrade --install elasticsearch ./elasticsearch \
    --namespace=osh-infra \
    --values=/tmp/elasticsearch.yaml

#NOTE: Wait for deploy
./tools/deployment/common/wait-for-pods.sh osh-infra
