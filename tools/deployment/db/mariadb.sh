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

: ${OSH_INFRA_HELM_REPO:="../openstack-helm-infra"}
: ${OSH_INFRA_PATH:="../openstack-helm-infra"}
: ${OSH_INFRA_EXTRA_HELM_ARGS_MARIADB:="$(helm osh get-values-overrides ${DOWNLOAD_OVERRIDES:-} -p ${OSH_INFRA_PATH} -c mariadb ${FEATURES})"}
: ${NAMESPACE:="osh-infra"}
: ${RUN_HELM_TESTS:="yes"}

#NOTE: Deploy command
helm upgrade --install mariadb ${OSH_INFRA_HELM_REPO}/mariadb \
    --namespace=${NAMESPACE} \
    ${MONITORING_HELM_ARGS:="--set monitoring.prometheus.enabled=true"} \
    --timeout=600s \
    ${OSH_INFRA_EXTRA_HELM_ARGS:=} \
    ${OSH_INFRA_EXTRA_HELM_ARGS_MARIADB}

#NOTE: Wait for deploy
helm osh wait-for-pods ${NAMESPACE}

if [ "x${RUN_HELM_TESTS}" != "xno" ]; then
    # Delete the test pod if it still exists
    kubectl delete pods -l application=mariadb,release_group=mariadb,component=test --namespace=${NAMESPACE} --ignore-not-found
    #NOTE: Validate the deployment
    helm test mariadb --namespace ${NAMESPACE}
fi
