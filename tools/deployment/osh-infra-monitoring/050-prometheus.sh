#!/bin/bash

# Copyright 2017 The Openstack-Helm Authors.
#
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

#NOTE: Lint and package chart
make prometheus

rules_overrides=""
for rules_file in $(ls ./prometheus/values_overrides); do
  rules_overrides="$rules_overrides --values=./prometheus/values_overrides/$rules_file"
done

#NOTE: Deploy command
helm upgrade --install prometheus ./prometheus \
    --namespace=osh-infra \
    $rules_overrides

#NOTE: Wait for deploy
./tools/deployment/common/wait-for-pods.sh osh-infra

#NOTE: Validate Deployment info
helm status prometheus

helm test prometheus
