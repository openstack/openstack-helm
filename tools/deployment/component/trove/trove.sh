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
: ${OSH_EXTRA_HELM_ARGS_TROVE:="$(helm osh get-values-overrides ${DOWNLOAD_OVERRIDES:-} -p ${OSH_VALUES_OVERRIDES_PATH} -c trove ${FEATURES})"}
: ${RUN_HELM_TESTS:="yes"}

#NOTE: Deploy command
tee /tmp/trove.yaml <<EOF
conf:
  trove:
    DEFAULT:
      default_datastore: mysql
EOF
helm upgrade --install trove ${OSH_HELM_REPO}/trove \
  --namespace=openstack \
  --values=/tmp/trove.yaml \
  --timeout=600s \
  ${OSH_EXTRA_HELM_ARGS:=} \
  ${OSH_EXTRA_HELM_ARGS_TROVE}

#NOTE: Wait for deploy
helm osh wait-for-pods openstack

#NOTE: Validate Deployment info
export OS_CLOUD=openstack_helm
openstack service list
sleep 30 #NOTE(portdirect): Wait for ingress controller to update rules and restart Nginx
openstack database instance list

# Delete the test pod if it still exists
kubectl delete pods -l application=trove,release_group=trove,component=test --namespace=openstack --ignore-not-found

if [ "x${RUN_HELM_TESTS}" != "xno" ]; then
    ./tools/deployment/common/run-helm-tests.sh trove
fi
