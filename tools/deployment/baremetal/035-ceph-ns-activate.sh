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

#NOTE: Pull images and lint chart
make pull-images ceph-client

#NOTE: Deploy command
tee /tmp/ceph-openstack-config.yaml <<EOF
labels:
  jobs:
    node_selector_key: openstack-helm-node-class
    node_selector_value: primary
endpoints:
  identity:
    namespace: openstack
  object_store:
    namespace: ceph
  ceph_mon:
    namespace: ceph
network:
  public: 172.17.0.1/16
  cluster: 172.17.0.1/16
deployment:
  storage_secrets: false
  ceph: false
  rbd_provisioner: false
  cephfs_provisioner: false
  client_secrets: true
  rgw_keystone_user_and_endpoints: false
bootstrap:
  enabled: false
conf:
  rgw_ks:
    enabled: true
  ceph:
    global:
      fsid: "$(cat /tmp/ceph-fs-uuid.txt)"
EOF
helm install ./ceph-client \
  --namespace=openstack \
  --name=ceph-openstack-config \
  --values=/tmp/ceph-openstack-config.yaml

#NOTE: Wait for deploy
./tools/deployment/common/wait-for-pods.sh openstack

#NOTE: Validate Deployment info
kubectl get -n openstack jobs --show-all
kubectl get -n openstack secrets
kubectl get -n openstack configmaps
