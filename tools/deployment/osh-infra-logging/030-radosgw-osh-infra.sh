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
deployment:
  storage_secrets: false
  ceph: true
  rbd_provisioner: false
  cephfs_provisioner: false
  client_secrets: false
  rgw_keystone_user_and_endpoints: false
bootstrap:
  enabled: false
conf:
  rgw_ks:
    enabled: false
  rgw_s3:
    enabled: true
pod:
  replicas:
    rgw: 1
EOF
helm upgrade --install radosgw-osh-infra ./ceph-rgw \
  --namespace=osh-infra \
  --values=/tmp/radosgw-osh-infra.yaml

#NOTE: Wait for deploy
./tools/deployment/common/wait-for-pods.sh osh-infra

#NOTE: Validate Deployment info
helm status radosgw-osh-infra
