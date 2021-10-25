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

#NOTE: Lint and package chart
make prometheus

tee /tmp/prometheus-one.yaml << EOF
endpoints:
  monitoring:
    hosts:
      default: prom-metrics-one
      public: prometheus-one
manifests:
  network_policy: false
EOF

tee /tmp/prometheus-two.yaml << EOF
endpoints:
  monitoring:
    hosts:
      default: prom-metrics-two
      public: prometheus-two
manifests:
  network_policy: false
EOF

tee /tmp/prometheus-three.yaml << EOF
endpoints:
  monitoring:
    hosts:
      default: prom-metrics-three
      public: prometheus-three
manifests:
  network_policy: false
EOF
#NOTE: Deploy command
for release in prometheus-one prometheus-two prometheus-three; do
  rules_overrides=""
  for rules_file in $(ls ./prometheus/values_overrides); do
    rules_overrides="$rules_overrides --values=./prometheus/values_overrides/$rules_file"
  done
  helm upgrade --install prometheus-$release ./prometheus \
      --namespace=osh-infra \
      --values=/tmp/$release.yaml \
      $rules_overrides
      #NOTE: Wait for deploy
      ./tools/deployment/common/wait-for-pods.sh osh-infra

      # Delete the test pod if it still exists
      kubectl delete pods -l application=prometheus,release_group=prometheus-$release,component=test --namespace=osh-infra --ignore-not-found
      helm test prometheus-$release --namespace osh-infra
done
