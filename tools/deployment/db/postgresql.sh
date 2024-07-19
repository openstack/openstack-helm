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

#NOTE: Deploy command
: ${OSH_INFRA_HELM_REPO:="../openstack-helm-infra"}
: ${OSH_INFRA_PATH:="../openstack-helm-infra"}
: ${OSH_INFRA_EXTRA_HELM_ARGS:=""}
: ${OSH_INFRA_EXTRA_HELM_ARGS_POSTGRESQL:="$(helm osh get-values-overrides -p ${OSH_INFRA_PATH} -c postgresql ${FEATURES})"}

helm upgrade --install postgresql ${OSH_INFRA_HELM_REPO}/postgresql \
    --namespace=osh-infra \
    --set monitoring.prometheus.enabled=true \
    --set storage.pvc.size=1Gi \
    --set storage.pvc.enabled=true \
    --set pod.replicas.server=1 \
    ${OSH_INFRA_EXTRA_HELM_ARGS} \
    ${OSH_INFRA_EXTRA_HELM_ARGS_POSTGRESQL}

#NOTE: Wait for deploy
helm osh wait-for-pods osh-infra
