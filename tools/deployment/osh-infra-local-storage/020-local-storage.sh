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

for i in {0..5}; do
  sudo mkdir /srv/local-volume-$i;
done

#NOTE: Lint and package chart
make local-storage

#NOTE: Deploy command
: ${OSH_INFRA_EXTRA_HELM_ARGS:=""}
: ${OSH_INFRA_EXTRA_HELM_ARGS_LOCAL_STORAGE:="$(./tools/deployment/common/get-values-overrides.sh local-storage)"}

helm upgrade --install local-storage ./local-storage \
    --namespace=osh-infra \
    ${OSH_INFRA_EXTRA_HELM_ARGS} \
    ${OSH_INFRA_EXTRA_HELM_ARGS_LOCAL_STORAGE}

#NOTE: Wait for deploy
./tools/deployment/common/wait-for-pods.sh osh-infra

# Simple object validation
kubectl describe sc local-storage
kubectl get pv
