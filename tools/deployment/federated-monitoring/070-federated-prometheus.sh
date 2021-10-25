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

tee /tmp/federated-prometheus.yaml << EOF
endpoints:
  monitoring:
    hosts:
      default: prom-metrics-federate
      public: prometheus-federate
manifests:
  network_policy: false
conf:
  prometheus:
    scrape_configs:
      template: |
        global:
          scrape_interval: 60s
          evaluation_interval: 60s
        scrape_configs:
        - job_name: 'federate'
          scrape_interval: 15s

          honor_labels: true
          metrics_path: '/federate'

          params:
            'match[]':
              - '{__name__=~".+"}'

          static_configs:
            - targets:
              - 'prometheus-one.osh-infra.svc.cluster.local:80'
              - 'prometheus-two.osh-infra.svc.cluster.local:80'
              - 'prometheus-three.osh-infra.svc.cluster.local:80'
EOF

#NOTE: Lint and package chart
make prometheus

#NOTE: Deploy command
helm upgrade --install federated-prometheus ./prometheus \
    --namespace=osh-infra \
    --values=/tmp/federated-prometheus.yaml

#NOTE: Wait for deploy
./tools/deployment/common/wait-for-pods.sh osh-infra

# Delete the test pod if it still exists
kubectl delete pods -l application=prometheus,release_group=federated-prometheus,component=test --namespace=osh-infra --ignore-not-found
helm test federated-prometheus --namespace osh-infra
