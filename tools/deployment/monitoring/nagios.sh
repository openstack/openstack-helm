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
: ${OSH_EXTRA_HELM_ARGS_NAGIOS:="$(helm osh get-values-overrides -p ${OSH_VALUES_OVERRIDES_PATH} -c nagios ${FEATURES})"}

#NOTE: Deploy command
helm upgrade --install nagios ${OSH_HELM_REPO}/nagios \
  --namespace=osh-infra \
  --set network.nagios.ingress.classes.namespace=ingress-osh-infra \
  ${OSH_EXTRA_HELM_ARGS:=} \
  ${OSH_EXTRA_HELM_ARGS_NAGIOS}

#NOTE: Wait for deploy
helm osh wait-for-pods osh-infra

# Delete the test pod if it still exists
kubectl delete pods -l application=nagios,release_group=nagios,component=test --namespace=osh-infra --ignore-not-found
helm test nagios --namespace osh-infra
