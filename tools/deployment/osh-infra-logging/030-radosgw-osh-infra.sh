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
make ceph-rgw

#NOTE: Deploy command
tee /tmp/radosgw-osh-infra.yaml <<EOF
endpoints:
  ceph_object_store:
    namespace: osh-infra
  ceph_mon:
    namespace: ceph
network:
  public: 172.17.0.1/16
  cluster: 172.17.0.1/16
  api:
    ingress:
      classes:
        namespace: nginx-osh-infra
deployment:
  storage_secrets: false
  ceph: true
  csi_rbd_provisioner: false
  client_secrets: false
  rgw_keystone_user_and_endpoints: false
bootstrap:
  enabled: true
conf:
  rgw_ks:
    enabled: false
  rgw_s3:
    enabled: true
    config:
      rgw_relaxed_s3_bucket_names: false
  rgw_placement_targets:
    - name: osh-infra
      index_pool: default.rgw.osh-infra.index
      data_pool: default.rgw.osh-infra.data
      data-extra-pool: default.rgw.osh-infra.non-ec
    - name: backup
      index_pool: default.rgw.backup.index
      data_pool: default.rgw.backup.data
      data-extra-pool: default.rgw.backup.non-ec
pod:
  replicas:
    rgw: 1
manifests:
  job_bootstrap: true
  job_rgw_placement_targets: true

EOF
helm upgrade --install radosgw-osh-infra ./ceph-rgw \
  --namespace=osh-infra \
  --values=/tmp/radosgw-osh-infra.yaml

#NOTE: Wait for deploy
./tools/deployment/common/wait-for-pods.sh osh-infra

# Delete the test pod if it still exists
kubectl delete pods -l application=ceph,release_group=radosgw-osh-infra,component=rgw-test --namespace=osh-infra --ignore-not-found
#NOTE: Test Deployment
helm test radosgw-osh-infra --namespace osh-infra --timeout 900s

#NOTE: RGW needs to be restarted for placement-targets to become accessible
kubectl delete pods -l application=ceph,component=rgw -n osh-infra
