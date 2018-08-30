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
make ceph-provisioners

#NOTE: Deploy command
: ${OSH_EXTRA_HELM_ARGS:=""}
tee /tmp/ceph-osh-infra-config.yaml <<EOF
endpoints:
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
    enabled: false
EOF
helm upgrade --install ceph-osh-infra-config ./ceph-provisioners \
  --namespace=osh-infra \
  --values=/tmp/ceph-osh-infra-config.yaml \
  ${OSH_EXTRA_HELM_ARGS} \
  ${OSH_EXTRA_HELM_ARGS_CEPH_NS_ACTIVATE}

#NOTE: Wait for deploy
./tools/deployment/common/wait-for-pods.sh osh-infra

#NOTE: Validate Deployment info
kubectl get -n osh-infra jobs --show-all
kubectl get -n osh-infra secrets
kubectl get -n osh-infra configmaps
