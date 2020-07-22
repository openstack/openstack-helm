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
: ${OSH_EXTRA_HELM_ARGS_GLANCE:="$(./tools/deployment/common/get-values-overrides.sh glance)"}
: ${RUN_HELM_TESTS:="yes"}

#NOTE: Lint and package chart
make glance

#NOTE: Deploy command
: ${OSH_EXTRA_HELM_ARGS:=""}
: ${OSH_OPENSTACK_RELEASE:="ocata"}
: ${GLANCE_BACKEND:="pvc"}
tee /tmp/glance.yaml <<EOF
storage: ${GLANCE_BACKEND}
EOF
if [ "x${OSH_OPENSTACK_RELEASE}" == "xnewton" ]; then
# NOTE(portdirect): glance APIv1 is required for heat in Newton
  tee -a /tmp/glance.yaml <<EOF
conf:
  glance:
    DEFAULT:
      enable_v1_api: true
      enable_v2_registry: true
manifests:
  deployment_registry: true
  ingress_registry: true
  pdb_registry: true
  service_ingress_registry: true
  service_registry: true
EOF
fi
helm upgrade --install glance ./glance \
  --namespace=openstack \
  --values=/tmp/glance.yaml \
  ${OSH_EXTRA_HELM_ARGS:=} \
  ${OSH_EXTRA_HELM_ARGS_GLANCE}

#NOTE: Wait for deploy
./tools/deployment/common/wait-for-pods.sh openstack

#NOTE: Validate Deployment info
helm status glance
export OS_CLOUD=openstack_helm
openstack service list
sleep 30 #NOTE(portdirect): Wait for ingress controller to update rules and restart Nginx
openstack image list
openstack image show 'Cirros 0.3.5 64-bit'

if [ "x${RUN_HELM_TESTS}" == "xno" ]; then
    exit 0
fi

./tools/deployment/common/run-helm-tests.sh glance
