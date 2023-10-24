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

export FEATURE_GATES="ovn"

: ${RUN_HELM_TESTS:="yes"}

#NOTE: Get the over-rides to use
: ${OSH_EXTRA_HELM_ARGS_NOVA:="$(./tools/deployment/common/get-values-overrides.sh nova)"}

tee /tmp/pvc-ceph-client-key.yaml << EOF
AQAk//BhgQMXDxAAPwH86gbDjEEpmXC4s2ontw==
EOF
kubectl -n openstack create secret generic pvc-ceph-client-key --from-file=key=/tmp/pvc-ceph-client-key.yaml || true
rm -f /tmp/pvc-ceph-client-key.yaml


#NOTE: Lint and package chart
make nova

helm upgrade --install nova ./nova \
    --namespace=openstack \
    ${OSH_EXTRA_HELM_ARGS:=} \
    ${OSH_EXTRA_HELM_ARGS_NOVA}

# Get overrides
: ${OSH_EXTRA_HELM_ARGS_PLACEMENT:="$(./tools/deployment/common/get-values-overrides.sh placement)"}

# Lint and package
make placement

# Deploy
helm upgrade --install placement ./placement \
    --namespace=openstack \
    ${OSH_EXTRA_HELM_ARGS:=} \
    ${OSH_EXTRA_HELM_ARGS_PLACEMENT}

#NOTE: Get the over-rides to use
: ${OSH_EXTRA_HELM_ARGS_NEUTRON:="$(./tools/deployment/common/get-values-overrides.sh neutron)"}

#NOTE: Lint and package chart
make neutron

helm upgrade --install neutron ./neutron \
    --namespace=openstack \
    ${OSH_RELEASE_OVERRIDES_NEUTRON} \
    ${OSH_EXTRA_HELM_ARGS} \
    ${OSH_EXTRA_HELM_ARGS_NEUTRON}

#NOTE: Wait for deploy
./tools/deployment/common/wait-for-pods.sh openstack

./tools/deployment/common/run-helm-tests.sh nova
./tools/deployment/common/run-helm-tests.sh neutron
