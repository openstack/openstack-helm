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
: ${OSH_PATH:="../openstack-helm"}
: ${OSH_EXTRA_HELM_ARGS_HEAT:="$(helm osh get-values-overrides ${DOWNLOAD_OVERRIDES:-} -p ${OSH_PATH} heat ${FEATURES})"}

#NOTE: Deploy command
helm upgrade --install heat ${OSH_HELM_REPO}/heat \
  --namespace=openstack \
  ${OSH_EXTRA_HELM_ARGS:=} \
  ${OSH_EXTRA_HELM_ARGS_HEAT}

#NOTE: Wait for deploy
helm osh wait-for-pods openstack

#NOTE: Validate Deployment info
export OS_CLOUD=openstack_helm
openstack service list
openstack endpoint list
sleep 30 #NOTE(portdirect): Wait for ingress controller to update rules and restart Nginx

openstack orchestration service list

FEATURE_GATE="tls"; if [[ ${FEATURE_GATES//,/ } =~ (^|[[:space:]])${FEATURE_GATE}($|[[:space:]]) ]]; then
  curl --cacert /etc/openstack-helm/certs/ca/ca.pem -L https://heat.openstack.svc.cluster.local
fi
