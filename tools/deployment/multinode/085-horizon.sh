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

# This is updated copy of openstack-helm/tools/deployment/developer/common/100-horizon.sh
# Change is to remove nodeport values which are available in upstream version.

set -xe

#NOTE: Get the over-rides to use
: ${OSH_EXTRA_HELM_ARGS_HORIZON:="$(./tools/deployment/common/get-values-overrides.sh horizon)"}

#NOTE: Lint and package chart
make horizon

#NOTE: Deploy command
tee /tmp/horizon.yaml <<EOF
pod:
  replicas:
    server: 2
EOF
: ${OSH_EXTRA_HELM_ARGS:=""}
helm upgrade --install horizon ./horizon \
    --namespace=openstack \
    --values=/tmp/horizon.yaml \
    ${OSH_EXTRA_HELM_ARGS} \
    ${OSH_EXTRA_HELM_ARGS_HORIZON}

#NOTE: Wait for deploy
./tools/deployment/common/wait-for-pods.sh openstack

#NOTE: Validate Deployment info
helm status horizon

helm test horizon
