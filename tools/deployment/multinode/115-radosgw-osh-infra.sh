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
CEPH_PUBLIC_NETWORK="$(./tools/deployment/multinode/kube-node-subnet.sh)"
CEPH_CLUSTER_NETWORK="$(./tools/deployment/multinode/kube-node-subnet.sh)"
tee /tmp/radosgw-osh-infra.yaml <<EOF
endpoints:
  ceph_object_store:
    namespace: osh-infra
  ceph_mon:
    namespace: ceph
network:
  public: ${CEPH_PUBLIC_NETWORK}
  cluster: ${CEPH_CLUSTER_NETWORK}
deployment:
  storage_secrets: false
  ceph: true
  csi_rbd_provisioner: false
  client_secrets: false
  rgw_keystone_user_and_endpoints: false
bootstrap:
  enabled: false
conf:
  rgw_ks:
    enabled: false
  rgw_s3:
    enabled: true
network_policy:
  ceph:
    ingress:
      - from:
        - podSelector:
            matchLabels:
              application: elasticsearch
        - podSelector:
            matchLabels:
              application: ceph
        ports:
        - protocol: TCP
          port: 8088
manifests:
  network_policy: true
EOF
helm upgrade --install radosgw-osh-infra ./ceph-rgw \
  --namespace=osh-infra \
  --values=/tmp/radosgw-osh-infra.yaml

#NOTE: Wait for deploy
./tools/deployment/common/wait-for-pods.sh osh-infra

# Delete the test pod if it still exists
kubectl delete pods -l application=ceph,release_group=radosgw-osh-infra,component=rgw-test --namespace=osh-infra --ignore-not-found
helm test radosgw-osh-infra --namespace osh-infra --timeout 900s
