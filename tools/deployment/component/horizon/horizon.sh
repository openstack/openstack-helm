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
: ${OSH_EXTRA_HELM_ARGS_HORIZON:="$(./tools/deployment/common/get-values-overrides.sh horizon)"}
: ${RUN_HELM_TESTS:="yes"}

#NOTE: Lint and package chart
make horizon

#NOTE: Deploy command
helm upgrade --install horizon ./horizon \
    --namespace=openstack \
    ${OSH_EXTRA_HELM_ARGS:=} \
    ${OSH_EXTRA_HELM_ARGS_HORIZON}

#NOTE: Wait for deploy
./tools/deployment/common/wait-for-pods.sh openstack

if [ "x${RUN_HELM_TESTS}" != "xno" ]; then
    ./tools/deployment/common/run-helm-tests.sh horizon
fi

FEATURE_GATE="tls"; if [[ ${FEATURE_GATES//,/ } =~ (^|[[:space:]])${FEATURE_GATE}($|[[:space:]]) ]]; then
  curl --cacert /etc/openstack-helm/certs/ca/ca.pem -L https://horizon.openstack.svc.cluster.local
  curl --cacert /etc/openstack-helm/certs/ca/ca.pem -L https://horizon-int.openstack.svc.cluster.local
fi
