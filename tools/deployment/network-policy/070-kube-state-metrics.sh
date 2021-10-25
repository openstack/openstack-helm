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
make prometheus-kube-state-metrics

tee /tmp/kube-state-metrics.yaml << EOF
manifests:
  network_policy: true
network_policy:
  kube-state-metrics:
    ingress:
      - from:
        - podSelector:
            matchLabels:
              application: kube-state-metrics
        - namespaceSelector:
            matchLabels:
              name: osh-infra
          podSelector:
            matchLabels:
              application: prometheus
        ports:
        - protocol: TCP
          port: 80
        - protocol: TCP
          port: 8080
        - protocol: TCP
          port: 443
EOF

#NOTE: Deploy command
helm upgrade --install prometheus-kube-state-metrics \
    ./prometheus-kube-state-metrics --namespace=kube-system \
    --values=/tmp/kube-state-metrics.yaml

#NOTE: Wait for deploy
./tools/deployment/common/wait-for-pods.sh kube-system
