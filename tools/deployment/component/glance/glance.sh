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
: ${GLANCE_BACKEND:="pvc"}
tee /tmp/glance.yaml <<EOF
storage: ${GLANCE_BACKEND}
volume:
  class_name: standard
bootstrap:
  structured:
    images:
      cirros:
        name: "Cirros 0.6.2 64-bit"
        source_url: "http://download.cirros-cloud.net/0.6.2/"
        image_file: "cirros-0.6.2-x86_64-disk.img"
EOF
helm upgrade --install glance ./glance \
  --namespace=openstack \
  --values=/tmp/glance.yaml \
  ${OSH_EXTRA_HELM_ARGS:=} \
  ${OSH_EXTRA_HELM_ARGS_GLANCE}

#NOTE: Wait for deploy
./tools/deployment/common/wait-for-pods.sh openstack

export OS_CLOUD=openstack_helm
openstack service list
sleep 30 #NOTE(portdirect): Wait for ingress controller to update rules and restart Nginx
openstack image list
openstack image show 'Cirros 0.6.2 64-bit'

if [ "x${RUN_HELM_TESTS}" == "xno" ]; then
    exit 0
fi

./tools/deployment/common/run-helm-tests.sh glance
