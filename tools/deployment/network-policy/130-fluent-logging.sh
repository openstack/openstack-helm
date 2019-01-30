#!/bin/bash

# Copyright 2017 The Openstack-Helm Authors.
#
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
make fluent-logging

if [ ! -d "/var/log/journal" ]; then
tee /tmp/fluent-logging.yaml << EOF
pod:
  replicas:
    fluentd: 1
monitoring:
  prometheus:
    enabled: true
manifests:
  network_policy: true
  monitoring:
    prometheus:
      network_policy_exporter: true
mounts:
  fluentbit:
    fluentbit:
      volumes:
        - name: runlog
          hostPath:
            path: /run/log
      volumeMounts:
        - name: runlog
          mountPath: /run/log
network_policy:
  prometheus-fluentd-exporter:
    ingress:
      - from:
        - podSelector:
            matchLabels:
              application: prometheus
        ports:
        - protocol: TCP
          port: 9309
  fluentd:
    ingress:
      - from:
        - podSelector:
            matchLabels:
              application: fluentbit
        - podSelector:
            matchLabels:
              application: prometheus-fluentd-exporter
        - podSelector:
            matchLabels:
              application: keystone
        - podSelector:
            matchLabels:
              application: heat
        - podSelector:
            matchLabels:
              application: glance
        - podSelector:
            matchLabels:
              application: cinder
        - podSelector:
            matchLabels:
              application: barbican
        - podSelector:
            matchLabels:
              application: ironic
        - podSelector:
            matchLabels:
              application: nova
        - podSelector:
            matchLabels:
              application: neutron
        - podSelector:
            matchLabels:
              application: placement
        ports:
        - protocol: TCP
          port: 24224
        - protocol: TCP
          port: 24220
EOF
helm upgrade --install fluent-logging ./fluent-logging \
    --namespace=osh-infra \
    --values=/tmp/fluent-logging.yaml
else
tee /tmp/fluent-logging.yaml << EOF
pod:
  replicas:
    fluentd: 1
monitoring:
  prometheus:
    enabled: true
manifests:
  network_policy: true
  monitoring:
    prometheus:
      network_policy_exporter: true
network_policy:
  prometheus-fluentd-exporter:
    ingress:
      - from:
        - podSelector:
            matchLabels:
              application: prometheus
        ports:
        - protocol: TCP
          port: 9309
  fluentd:
    ingress:
      - from:
        - podSelector:
            matchLabels:
              application: fluentbit
        - podSelector:
            matchLabels:
              application: prometheus-fluentd-exporter
        - podSelector:
            matchLabels:
              application: keystone
        - podSelector:
            matchLabels:
              application: heat
        - podSelector:
            matchLabels:
              application: glance
        - podSelector:
            matchLabels:
              application: cinder
        - podSelector:
            matchLabels:
              application: barbican
        - podSelector:
            matchLabels:
              application: ironic
        - podSelector:
            matchLabels:
              application: nova
        - podSelector:
            matchLabels:
              application: neutron
        - podSelector:
            matchLabels:
              application: placement
        ports:
        - protocol: TCP
          port: 24224
        - protocol: TCP
          port: 24220
EOF
helm upgrade --install fluent-logging ./fluent-logging \
    --namespace=osh-infra \
    --values=/tmp/fluent-logging.yaml
fi

#NOTE: Wait for deploy
./tools/deployment/common/wait-for-pods.sh osh-infra

#NOTE: Validate Deployment info
helm status fluent-logging
