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
: ${OSH_EXTRA_HELM_ARGS_OSEXPORTER:="$(./tools/deployment/common/get-values-overrides.sh prometheus-openstack-exporter)"}

#NOTE: Lint and package chart
make -C ${HELM_CHART_ROOT_PATH} prometheus-openstack-exporter

: ${OSH_EXTRA_HELM_ARGS:=""}
helm upgrade --install prometheus-openstack-exporter ${HELM_CHART_ROOT_PATH}/prometheus-openstack-exporter \
    --namespace=openstack \
    ${OSH_EXTRA_HELM_ARGS} \
    ${OSH_EXTRA_HELM_ARGS_OSEXPORTER}

#NOTE: Wait for deploy
./tools/deployment/common/wait-for-pods.sh openstack
