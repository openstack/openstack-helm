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

#NOTE: Get the over-rides to use
export HELM_CHART_ROOT_PATH="${HELM_CHART_ROOT_PATH:="${OSH_INFRA_PATH:="../openstack-helm-infra"}"}"
: ${OSH_EXTRA_HELM_ARGS_INGRESS:="$(./tools/deployment/common/get-values-overrides.sh ingress)"}

#NOTE: Lint and package chart
make -C ${HELM_CHART_ROOT_PATH} ingress

#NOTE: Deploy command
: ${OSH_EXTRA_HELM_ARGS:=""}
tee /tmp/ingress-kube-system.yaml << EOF
deployment:
  mode: cluster
  type: DaemonSet
network:
  host_namespace: true
EOF

touch /tmp/ingress-component.yaml

if [ -n "${OSH_DEPLOY_MULTINODE}" ]; then
  tee --append /tmp/ingress-kube-system.yaml << EOF
pod:
  replicas:
    error_page: 2
EOF

  tee /tmp/ingress-component.yaml << EOF
pod:
  replicas:
    ingress: 2
    error_page: 2
EOF
fi

helm upgrade --install ingress-kube-system ${HELM_CHART_ROOT_PATH}/ingress \
  --namespace=kube-system \
  --values=/tmp/ingress-kube-system.yaml \
  ${OSH_EXTRA_HELM_ARGS} \
  ${OSH_EXTRA_HELM_ARGS_INGRESS} \
  ${OSH_EXTRA_HELM_ARGS_INGRESS_KUBE_SYSTEM}

#NOTE: Wait for deploy
./tools/deployment/common/wait-for-pods.sh kube-system

#NOTE: Deploy namespace ingress
helm upgrade --install ingress-openstack ${HELM_CHART_ROOT_PATH}/ingress \
  --namespace=openstack \
  --values=/tmp/ingress-component.yaml \
  --set deployment.cluster.class=nginx \
  ${OSH_EXTRA_HELM_ARGS} \
  ${OSH_EXTRA_HELM_ARGS_INGRESS} \
  ${OSH_EXTRA_HELM_ARGS_INGRESS_OPENSTACK}

#NOTE: Wait for deploy
./tools/deployment/common/wait-for-pods.sh openstack

helm upgrade --install ingress-ceph ${HELM_CHART_ROOT_PATH}/ingress \
  --namespace=ceph \
  --values=/tmp/ingress-component.yaml \
  --set deployment.cluster.class=nginx-ceph \
  ${OSH_EXTRA_HELM_ARGS} \
  ${OSH_EXTRA_HELM_ARGS_INGRESS} \
  ${OSH_EXTRA_HELM_ARGS_INGRESS_CEPH}

#NOTE: Wait for deploy
./tools/deployment/common/wait-for-pods.sh ceph
