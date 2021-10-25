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
jobs:
  verify_repositories:
    cron: "*/3 * * * *"
monitoring:
  prometheus:
    enabled: true
pod:
  replicas:
    client: 1
    data: 1
    master: 2
conf:
  elasticsearch:
    snapshots:
      enabled: true
  api_objects:
    snapshot_repo:
      endpoint: _snapshot/ceph-rgw
      body:
        type: s3
        settings:
          client: default
          bucket: elasticsearch-bucket
    slm_policy:
      endpoint: _slm/policy/snapshots
      body:
        schedule: "0 */3 * * * ?"
        name: "<snapshot-{now/d}>"
        repository: ceph-rgw
        config:
          indices:
            - "<*-{now/d}>"
        retention:
          expire_after: 30d
    ilm_policy:
      endpoint: _ilm/policy/cleanup
      body:
        policy:
          phases:
            delete:
              min_age: 5d
              actions:
                delete: {}
    test_empty: {}
storage:
  s3:
    clients:
      # These values configure the s3 clients section of elasticsearch.yml, with access_key and secret_key being saved to the keystore
      default:
        auth:
          username: elasticsearch
          access_key: "elastic_access_key"
          secret_key: "elastic_secret_key"
        settings:
          # endpoint: Defaults to the ceph-rgw endpoint
          # protocol: Defaults to http
          path_style_access: true # Required for ceph-rgw S3 API
        create_user: true # Attempt to create the user at the ceph_object_store endpoint, authenticating using the secret named at .Values.secrets.rgw.admin
      backup: # Change this as you'd like
        auth:
          username: backup
          access_key: "backup_access_key"
          secret_key: "backup_secret_key"
        settings:
          endpoint: radosgw.osh-infra.svc.cluster.local # Using the ingress here to test the endpoint override
          path_style_access: true
        create_user: true
    buckets: # List of buckets to create (if required).
      - name: elasticsearch-bucket
        client: default
        options: # list of extra options for s3cmd
          - --region="default:osh-infra"
      - name: backup-bucket
        client: backup
        options: # list of extra options for s3cmd
          - --region="default:backup"

EOF

: ${OSH_INFRA_EXTRA_HELM_ARGS_ELASTICSEARCH:="$(./tools/deployment/common/get-values-overrides.sh elasticsearch)"}

helm upgrade --install elasticsearch ./elasticsearch \
  --namespace=osh-infra \
  --values=/tmp/elasticsearch.yaml\
  ${OSH_INFRA_EXTRA_HELM_ARGS} \
  ${OSH_INFRA_EXTRA_HELM_ARGS_ELASTICSEARCH}

#NOTE: Wait for deploy
./tools/deployment/common/wait-for-pods.sh osh-infra

# Delete the test pod if it still exists
kubectl delete pods -l application=elasticsearch,release_group=elasticsearch,component=test --namespace=osh-infra --ignore-not-found
helm test elasticsearch --namespace osh-infra
