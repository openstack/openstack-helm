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
make prometheus-alertmanager

tee /tmp/prometheus-alertmanager.yaml <<EOF
manifests:
  network_policy: true
network_policy:
  alertmanager:
    ingress:
      - from:
        - podSelector:
            matchLabels:
              application: prometheus-alertmanager
        ports:
        - protocol: TCP
          port: 9093
        - protocol: TCP
          port: 9094
        - protocol: TCP
          port: 80
EOF

#NOTE: Deploy command
helm upgrade --install prometheus-alertmanager ./prometheus-alertmanager \
    --namespace=osh-infra \
    --values=/tmp/prometheus-alertmanager.yaml \
    --set pod.replicas.alertmanager=1

#NOTE: Wait for deploy
./tools/deployment/common/wait-for-pods.sh osh-infra
