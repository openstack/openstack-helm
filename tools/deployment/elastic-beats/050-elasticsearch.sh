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
make elasticsearch

#NOTE: Deploy command
tee /tmp/elasticsearch.yaml << EOF
manifests:
  cron_curator: false
  configmap_bin_curator: false
  configmap_etc_curator: false
images:
  tags:
    elasticsearch: docker.io/openstackhelm/elasticsearch-s3:7_1_0-20191115
storage:
  data:
    requests:
      storage: 20Gi
  master:
    requests:
      storage: 5Gi
jobs:
  verify_repositories:
    cron: "*/10 * * * *"
monitoring:
  prometheus:
    enabled: false
pod:
  replicas:
    client: 1
    data: 1
    master: 2
conf:
  elasticsearch:
    config:
      xpack:
        security:
          enabled: false
        ilm:
          enabled: false

EOF
helm upgrade --install elasticsearch ./elasticsearch \
    --namespace=osh-infra \
    --values=/tmp/elasticsearch.yaml

#NOTE: Wait for deploy
./tools/deployment/common/wait-for-pods.sh osh-infra
