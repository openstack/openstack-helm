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
: ${OSH_INFRA_PATH:="../openstack-helm-infra"}
: ${OSH_EXTRA_HELM_ARGS_OPENVSWITCH:="$(./tools/deployment/common/get-values-overrides.sh openvswitch)"}

#NOTE: Lint and package chart
make -C ${OSH_INFRA_PATH} openvswitch

#NOTE: Deploy command
helm upgrade --install openvswitch ${OSH_INFRA_PATH}/openvswitch \
  --namespace=openstack \
  ${OSH_EXTRA_HELM_ARGS} \
  ${OSH_EXTRA_HELM_ARGS_OPENVSWITCH}

#NOTE: Wait for deploy
./tools/deployment/common/wait-for-pods.sh openstack

#NOTE: Validate Deployment info
helm status openvswitch
