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

#NOTE: Deploy command
CEPH_PUBLIC_NETWORK="$(./tools/deployment/multinode/kube-node-subnet.sh)"
CEPH_CLUSTER_NETWORK="${CEPH_PUBLIC_NETWORK}"
tee /tmp/ceph-osh-infra-config.yaml <<EOF
endpoints:
  ceph_mon:
    namespace: ceph
network:
  public: ${CEPH_PUBLIC_NETWORK}
  cluster: ${CEPH_CLUSTER_NETWORK}
deployment:
  storage_secrets: false
  ceph: false
  csi_rbd_provisioner: false
  client_secrets: true
  rgw_keystone_user_and_endpoints: false
storageclass:
  cephfs:
    provision_storage_class: false
bootstrap:
  enabled: false
conf:
  rgw_ks:
    enabled: false
EOF

: ${OSH_INFRA_EXTRA_HELM_ARGS_CEPH_NS_ACTIVATE:="$(./tools/deployment/common/get-values-overrides.sh ceph-provisioners)"}

helm upgrade --install ceph-osh-infra-config ./ceph-provisioners \
  --namespace=osh-infra \
  --values=/tmp/ceph-osh-infra-config.yaml \
  ${OSH_INFRA_EXTRA_HELM_ARGS} \
  ${OSH_INFRA_EXTRA_HELM_ARGS_CEPH_NS_ACTIVATE}

#NOTE: Wait for deploy
./tools/deployment/common/wait-for-pods.sh osh-infra

# Delete the test pod if it still exists
kubectl delete pods -l application=ceph,release_group=ceph-osh-infra-config,component=provisioner-test --namespace=osh-infra --ignore-not-found
helm test ceph-osh-infra-config --namespace osh-infra --timeout 600s
