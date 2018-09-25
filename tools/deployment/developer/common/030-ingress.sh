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
: ${OSH_INFRA_PATH:="../openstack-helm-infra"}
make -C ${OSH_INFRA_PATH} ingress

tee /tmp/ingress.yaml <<EOF
manifests:
  network_policy: true
network_policy:
  ingress:
    ingress:
      - from:
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
              application: congress
        - podSelector:
            matchLabels:
              application: barbican
        - podSelector:
            matchLabels:
              application: ceilometer
        - podSelector:
            matchLabels:
              application: horizon
        - podSelector:
            matchLabels:
              application: ironic
        - podSelector:
            matchLabels:
              application: magnum
        - podSelector:
            matchLabels:
              application: mistral
        - podSelector:
            matchLabels:
              application: nova
        - podSelector:
            matchLabels:
              application: neutron
        - podSelector:
            matchLabels:
              application: senlin
EOF

#NOTE: Deploy command
: ${OSH_INFRA_PATH:="../openstack-helm-infra"}
: ${OSH_EXTRA_HELM_ARGS:=""}
tee /tmp/ingress-kube-system.yaml << EOF
deployment:
  mode: cluster
  type: DaemonSet
network:
  host_namespace: true
EOF
helm upgrade --install ingress-kube-system ${OSH_INFRA_PATH}/ingress \
  --namespace=kube-system \
  --values=/tmp/ingress-kube-system.yaml \
  ${OSH_EXTRA_HELM_ARGS} \
  ${OSH_EXTRA_HELM_ARGS_INGRESS_KUBE_SYSTEM}

#NOTE: Wait for deploy
./tools/deployment/common/wait-for-pods.sh kube-system

#NOTE: Display info
helm status ingress-kube-system

#NOTE: Deploy namespace ingress
helm upgrade --install ingress-openstack ${OSH_INFRA_PATH}/ingress \
  --namespace=openstack \
  --values=/tmp/ingress.yaml \
  ${OSH_EXTRA_HELM_ARGS} \
  ${OSH_EXTRA_HELM_ARGS_INGRESS_OPENSTACK}

#NOTE: Wait for deploy
./tools/deployment/common/wait-for-pods.sh openstack

#NOTE: Display info
helm status ingress-openstack


helm upgrade --install ingress-ceph ${OSH_INFRA_PATH}/ingress \
  --namespace=ceph \
  ${OSH_EXTRA_HELM_ARGS} \
  ${OSH_EXTRA_HELM_ARGS_INGRESS_OPENSTACK}

#NOTE: Wait for deploy
./tools/deployment/common/wait-for-pods.sh ceph

#NOTE: Display info
helm status ingress-ceph
