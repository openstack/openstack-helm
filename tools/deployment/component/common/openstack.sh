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
namespace=openstack
chart=$namespace
export HELM_CHART_ROOT_PATH="${HELM_CHART_ROOT_PATH:="${OSH_INFRA_PATH:="../openstack-helm/openstack"}"}"
: ${OSH_EXTRA_HELM_ARGS_MARIADB:="$(./tools/deployment/common/get-values-overrides.sh mariadb subchart)"}
: ${OSH_EXTRA_HELM_ARGS_RABBITMQ:="$(./tools/deployment/common/get-values-overrides.sh rabbitmq subchart)"}
: ${OSH_EXTRA_HELM_ARGS_MEMCACHED:="$(./tools/deployment/common/get-values-overrides.sh memcached subchart)"}
: ${OSH_EXTRA_HELM_ARGS_KEYSTONE:="$(./tools/deployment/common/get-values-overrides.sh keystone subchart)"}
: ${OSH_EXTRA_HELM_ARGS_HEAT:="$(./tools/deployment/common/get-values-overrides.sh heat subchart)"}
: ${OSH_EXTRA_HELM_ARGS_GLANCE:="$(./tools/deployment/common/get-values-overrides.sh glance subchart)"}

#NOTE: Lint and package chart
make -C ${HELM_CHART_ROOT_PATH} .

echo "helm installing ..."
helm upgrade --install $chart $chart/ \
    ${OSH_EXTRA_HELM_ARGS_MARIADB} \
    ${OSH_EXTRA_HELM_ARGS_RABBITMQ} \
    ${OSH_EXTRA_HELM_ARGS_MEMCACHED} \
    ${OSH_EXTRA_HELM_ARGS_KEYSTONE} \
    ${OSH_EXTRA_HELM_ARGS_HEAT} \
    ${OSH_EXTRA_HELM_ARGS_GLANCE} \
    ${OSH_EXTRA_HELM_ARGS:=} \
    --namespace=$namespace
#NOTE: Wait for deploy
./tools/deployment/common/wait-for-pods.sh $namespace 1800
