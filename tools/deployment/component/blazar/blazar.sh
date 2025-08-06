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

#NOTE: Define variables
: ${OSH_HELM_REPO:="../openstack-helm"}
: ${OSH_VALUES_OVERRIDES_PATH:="../openstack-helm/values_overrides"}
: ${OSH_EXTRA_HELM_ARGS_BLAZAR:="$(helm osh get-values-overrides ${DOWNLOAD_OVERRIDES:-} -p ${OSH_VALUES_OVERRIDES_PATH} -c blazar ${FEATURES})"}
: ${BLAZAR_RELEASE_NAME:="blazar"}
: ${BLAZAR_NAMESPACE:="openstack"}

#NOTE: Wait for deploy

echo "Deploying OpenStack Blazar"

helm upgrade --install ${BLAZAR_RELEASE_NAME} ${OSH_HELM_REPO}/blazar \
    --namespace ${BLAZAR_NAMESPACE} \
    ${OSH_EXTRA_HELM_ARGS:=} \
    ${OSH_EXTRA_HELM_ARGS_BLAZAR}

#NOTE: Wait for deploy
helm osh wait-for-pods ${BLAZAR_NAMESPACE}

echo "OpenStack Blazar deployment complete."

#NOTE: Validate Deployment info
export OS_CLOUD=openstack_helm
openstack service list

# Run helm test
if [ "x${RUN_HELM_TESTS}" != "xno" ]; then
    ./tools/deployment/common/run-helm-tests.sh blazar
fi
