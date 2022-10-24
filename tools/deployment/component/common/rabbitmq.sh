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
: ${OSH_EXTRA_HELM_ARGS_RABBITMQ:="$(./tools/deployment/common/get-values-overrides.sh rabbitmq)"}

#NOTE: Lint and package chart
make -C ${HELM_CHART_ROOT_PATH} rabbitmq

#NOTE: Deploy command
helm upgrade --install rabbitmq ${HELM_CHART_ROOT_PATH}/rabbitmq \
    --namespace=openstack \
    --set volume.enabled=false \
    --set pod.replicas.server=1 \
    ${OSH_EXTRA_HELM_ARGS:=} \
    ${OSH_EXTRA_HELM_ARGS_RABBITMQ}

#NOTE: Wait for deploy
./tools/deployment/common/wait-for-pods.sh openstack
