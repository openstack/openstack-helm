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
make grafana

#NOTE: Deploy command
tee /tmp/grafana.yaml << EOF
dependencies:
  static:
    grafana:
      jobs: null
      services: null
manifests:
  job_db_init: false
  job_db_init_session: false
  job_db_session_sync: false
  secret_db: false
  secret_db_session: false
conf:
  grafana:
    database:
      type: sqlite3
    session:
      provider: file
      provider_config: sessions
pod:
  replicas:
    grafana: 2
EOF
helm upgrade --install grafana ./grafana \
    --namespace=openstack \
    --values=/tmp/grafana.yaml

#NOTE: Wait for deploy
./tools/deployment/common/wait-for-pods.sh openstack

#NOTE: Validate Deployment info
helm status grafana

#NOTE: Run helm tests
helm test grafana
