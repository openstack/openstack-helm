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
export HELM_CHART_ROOT_PATH="${HELM_CHART_ROOT_PATH:="${OSH_INFRA_PATH:="../openstack-helm-infra"}"}"

#NOTE: Lint and package chart
make -C ${HELM_CHART_ROOT_PATH} ingress

#NOTE: Deploy command
: ${OSH_EXTRA_HELM_ARGS:=""}
cd ${HELM_CHART_ROOT_PATH}

export HELM_CHART_ROOT_PATH="${HELM_CHART_ROOT_PATH:="${OSH_INFRA_PATH:="../openstack-helm-infra"}"}"

: ${OSH_INFRA_EXTRA_HELM_ARGS_KUBE_SYSTEM:="$(./tools/deployment/common/get-values-overrides.sh ingress)"}
: ${OSH_INFRA_EXTRA_HELM_ARGS_OPENSTACK:="$(./tools/deployment/common/get-values-overrides.sh ingress)"}
: ${OSH_INFRA_EXTRA_HELM_ARGS_CEPH:="$(./tools/deployment/common/get-values-overrides.sh ingress)"}

#NOTE: Deploy global ingress
tee /tmp/ingress-kube-system.yaml << EOF
deployment:
  mode: cluster
  type: DaemonSet
network:
  host_namespace: true
EOF
helm upgrade --install ingress-kube-system ${HELM_CHART_ROOT_PATH}/ingress \
  --namespace=kube-system \
  --values=/tmp/ingress-kube-system.yaml \
  ${OSH_INFRA_EXTRA_HELM_ARGS} \
  ${OSH_INFRA_EXTRA_HELM_ARGS_INGRESS_KUBE_SYSTEM}

#NOTE: Wait for deploy
./tools/deployment/common/wait-for-pods.sh kube-system

#NOTE: Deploy namespace ingress
helm upgrade --install ingress-osh-infra ${HELM_CHART_ROOT_PATH}/ingress \
  --namespace=osh-infra \
  ${OSH_INFRA_EXTRA_HELM_ARGS} \
  ${OSH_INFRA_EXTRA_HELM_ARGS_INGRESS_OPENSTACK}

#NOTE: Wait for deploy
./tools/deployment/common/wait-for-pods.sh osh-infra

helm upgrade --install ingress-ceph ${HELM_CHART_ROOT_PATH}/ingress \
  --namespace=ceph \
  ${OSH_INFRA_EXTRA_HELM_ARGS} \
  ${OSH_INFRA_EXTRA_HELM_ARGS_INGRESS_CEPH}

#NOTE: Wait for deploy
./tools/deployment/common/wait-for-pods.sh ceph
