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
FEATURE_GATES="calico ceph containers coredns elasticsearch kubernetes nginx nodes openstack prometheus home_dashboard persistentvolume apparmor"
: ${OSH_INFRA_EXTRA_HELM_ARGS_GRAFANA:=$(helm osh get-values-overrides -p ${OSH_INFRA_PATH} -c grafana ${FEATURE_GATES} ${FEATURES} 2>/dev/null)}

#NOTE: Deploy command
helm upgrade --install grafana ${OSH_INFRA_HELM_REPO}/grafana \
  --namespace=osh-infra \
  ${OSH_INFRA_EXTRA_HELM_ARGS:=} \
  ${OSH_INFRA_EXTRA_HELM_ARGS_GRAFANA}

#NOTE: Wait for deploy
helm osh wait-for-pods osh-infra

# Delete the test pod if it still exists
kubectl delete pods -l application=grafana,release_group=grafana,component=test --namespace=osh-infra --ignore-not-found
helm test grafana --namespace osh-infra
