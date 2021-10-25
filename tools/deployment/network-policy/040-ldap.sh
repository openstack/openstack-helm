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

#NOTE: Pull images and lint chart
make ldap

tee /tmp/ldap.yaml <<EOF
manifests:
  network_policy: true
network_policy:
  ingress:
    - from:
      - podSelector:
          matchLabels:
            application: ldap
      - podSelector:
          matchLabels:
            application: grafana
      - podSelector:
          matchLabels:
            application: nagios
      - podSelector:
          matchLabels:
            application: elasticsearch
      - podSelector:
          matchLabels:
            application: kibana
      - podSelector:
          matchLabels:
            application: prometheus
      ports:
      - protocol: TCP
        port: 389
      - protocol: TCP
        port: 80
EOF

#NOTE: Deploy command
helm upgrade --install ldap ./ldap \
    --namespace=osh-infra \
    --values=/tmp/ldap.yaml \
    --set bootstrap.enabled=true

#NOTE: Wait for deploy
./tools/deployment/common/wait-for-pods.sh osh-infra
