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
        schedule: "0 */15 * * * ?"
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
        # not needed when using Rook Ceph CRDs
        # auth:
        #   username: elasticsearch
        #   access_key: "elastic_access_key"
        #   secret_key: "elastic_secret_key"
        settings:
          # endpoint: Defaults to the ceph-rgw endpoint
          # protocol: Defaults to http
          path_style_access: true # Required for ceph-rgw S3 API
        create_user: true # Attempt to create the user at the ceph_object_store endpoint, authenticating using the secret named at .Values.secrets.rgw.admin
      backup: # Change this as you'd like
        # not needed when using Rook Ceph CRDs
        # auth:
        #   username: backup
        #   access_key: "backup_access_key"
        #   secret_key: "backup_secret_key"
        settings:
          # endpoint: rook-ceph-rgw-default.ceph.svc.cluster.local # Using the ingress here to test the endpoint override
          path_style_access: true
        create_user: true
    buckets: # List of buckets to create (if required).
      - name: elasticsearch-bucket
        client: default
        storage_class: ceph-bucket # this is valid when using Rook CRDs
        # not needed when using Rook Ceph CRDs
        # options: # list of extra options for s3cmd
        #   - --region="default:osh-infra"
      - name: backup-bucket
        client: backup
        storage_class: ceph-bucket # this is valid when using Rook CRDs
        # not needed when using Rook Ceph CRDs
        # options: # list of extra options for s3cmd
        #   - --region="default:backup"
endpoints:
  ceph_object_store:
    name: radosgw
    namespace: ceph
    hosts:
      default: rook-ceph-rgw-default
      public: radosgw
    host_fqdn_override:
      default: null
    path:
      default: null
    scheme:
      default: http
    port:
      api:
        default: 8080
        public: 80
network:
  elasticsearch:
    ingress:
      classes:
        namespace: nginx-osh-infra
dependencies:
  static:
    elasticsearch_templates:
      services:
        - endpoint: internal
          service: elasticsearch
      jobs: null
      custom_resources:
        - apiVersion: objectbucket.io/v1alpha1
          kind: ObjectBucket
          name: obc-osh-infra-elasticsearch-bucket
          fields:
            - key: "status.phase"
              value: "Bound"
        - apiVersion: objectbucket.io/v1alpha1
          kind: ObjectBucket
          name: obc-osh-infra-backup-bucket
          fields:
            - key: "status.phase"
              value: "Bound"
    snapshot_repository:
      services:
        - endpoint: internal
          service: elasticsearch
      jobs: null
      custom_resources:
        - apiVersion: objectbucket.io/v1alpha1
          kind: ObjectBucket
          name: obc-osh-infra-elasticsearch-bucket
          fields:
            - key: "status.phase"
              value: "Bound"
        - apiVersion: objectbucket.io/v1alpha1
          kind: ObjectBucket
          name: obc-osh-infra-backup-bucket
          fields:
            - key: "status.phase"
              value: "Bound"
manifests:
  job_s3_user: false
  job_s3_bucket: false
  object_bucket_claim: true
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
