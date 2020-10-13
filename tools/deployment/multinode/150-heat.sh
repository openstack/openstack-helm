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
: ${OSH_EXTRA_HELM_ARGS_HEAT:="$(./tools/deployment/common/get-values-overrides.sh heat)"}

#NOTE: Lint and package chart
make heat

tee /tmp/heat.yaml << EOF
pod:
  replicas:
    api: 2
    cfn: 2
    cloudwatch: 2
    engine: 2
EOF

#NOTE: Deploy command
: ${OSH_EXTRA_HELM_ARGS:=""}
helm upgrade --install heat ./heat \
  --namespace=openstack \
  --values=/tmp/heat.yaml \
  ${OSH_EXTRA_HELM_ARGS} \
  ${OSH_EXTRA_HELM_ARGS_HEAT}

#NOTE: Wait for deploy
./tools/deployment/common/wait-for-pods.sh openstack

#NOTE: Validate Deployment info
export OS_CLOUD=openstack_helm
openstack service list
openstack endpoint list
sleep 30 #NOTE(portdirect): Wait for ingress controller to update rules and restart Nginx

openstack --os-interface internal orchestration service list
