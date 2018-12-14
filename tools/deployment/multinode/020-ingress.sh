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

#NOTE: Deploy global ingress
: ${OSH_INFRA_PATH:="../openstack-helm-infra"}
tee /tmp/ingress-kube-system.yaml << EOF
pod:
  replicas:
    error_page: 2
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

#NOTE: Deploy namespaced ingress controllers
for NAMESPACE in openstack ceph; do
  # Allow $OSH_EXTRA_HELM_ARGS_INGRESS_ceph and $OSH_EXTRA_HELM_ARGS_INGRESS_openstack overrides
  OSH_EXTRA_HELM_ARGS_INGRESS_NAMESPACE="OSH_EXTRA_HELM_ARGS_INGRESS_${NAMESPACE}"
  #NOTE: Deploy namespace ingress
  tee /tmp/ingress-${NAMESPACE}.yaml << EOF
pod:
  replicas:
    ingress: 2
    error_page: 2
EOF
  helm upgrade --install ingress-${NAMESPACE} ${OSH_INFRA_PATH}/ingress \
    --namespace=${NAMESPACE} \
    --values=/tmp/ingress-${NAMESPACE}.yaml \
  ${OSH_EXTRA_HELM_ARGS} \
  ${!OSH_EXTRA_HELM_ARGS_INGRESS_NAMESPACE}

  #NOTE: Wait for deploy
  ./tools/deployment/common/wait-for-pods.sh ${NAMESPACE}

  #NOTE: Display info
  helm status ingress-${NAMESPACE}
done
