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

: ${OSH_HELM_REPO:="../openstack-helm"}
: ${OSH_VALUES_OVERRIDES_PATH:="../openstack-helm/values_overrides"}
: ${OSH_EXTRA_HELM_ARGS_KUBE_STATE_METRICS:="$(helm osh get-values-overrides -p ${OSH_VALUES_OVERRIDES_PATH} -c prometheus-kube-state-metrics ${FEATURES})"}

#NOTE: Deploy command
helm upgrade --install prometheus-kube-state-metrics \
    ${OSH_HELM_REPO}/prometheus-kube-state-metrics --namespace=kube-system \
    ${OSH_EXTRA_HELM_ARGS_KUBE_STATE_METRICS}

#NOTE: Wait for deploy
helm osh wait-for-pods kube-system
