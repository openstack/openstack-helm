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
make kubernetes-node-problem-detector

#NOTE: Deploy command
tee /tmp/kubernetes-node-problem-detector.yaml << EOF
monitoring:
  prometheus:
    pod:
      enabled: false
    service:
      enabled: true
manifests:
  service: true
EOF
helm upgrade --install kubernetes-node-problem-detector \
    ./kubernetes-node-problem-detector --namespace=kube-system \
    --values=/tmp/kubernetes-node-problem-detector.yaml

#NOTE: Wait for deploy
./tools/deployment/common/wait-for-pods.sh kube-system
