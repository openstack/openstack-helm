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

#NOTE: Get the over-rides to use
export HELM_CHART_ROOT_PATH="${HELM_CHART_ROOT_PATH:="${OSH_INFRA_PATH:="../openstack-helm-infra"}"}"
: ${OSH_EXTRA_HELM_ARGS_CEPH_RGW:="$(./tools/deployment/common/get-values-overrides.sh ceph-rgw)"}

#NOTE: Lint and package chart
make -C ${HELM_CHART_ROOT_PATH} ceph-rgw

#NOTE: Deploy command
: ${OSH_EXTRA_HELM_ARGS:=""}
CEPH_PUBLIC_NETWORK="$(./tools/deployment/multinode/kube-node-subnet.sh)"
CEPH_CLUSTER_NETWORK="$(./tools/deployment/multinode/kube-node-subnet.sh)"
tee /tmp/radosgw-openstack.yaml <<EOF
endpoints:
  identity:
    namespace: openstack
  object_store:
    namespace: openstack
  ceph_mon:
    namespace: ceph
network:
  public: ${CEPH_PUBLIC_NETWORK}
  cluster: ${CEPH_CLUSTER_NETWORK}
deployment:
  ceph: true
bootstrap:
  enabled: false
conf:
  rgw_ks:
    enabled: true
pod:
  replicas:
    rgw: 1
EOF

: ${OSH_INFRA_PATH:="../openstack-helm-infra"}
helm upgrade --install radosgw-openstack ${OSH_INFRA_PATH}/ceph-rgw \
  --namespace=openstack \
  --values=/tmp/radosgw-openstack.yaml \
  ${OSH_EXTRA_HELM_ARGS} \
  ${OSH_EXTRA_HELM_ARGS_CEPH_RGW}

#NOTE: Wait for deploy
./tools/deployment/common/wait-for-pods.sh openstack

#NOTE: Validate Deployment info
helm status radosgw-openstack

#NOTE: Run Tests
export OS_CLOUD=openstack_helm
# Delete the test pod if it still exists
kubectl delete pods -l application=radosgw-openstack,release_group=radosgw-openstack,component=test --namespace=openstack --ignore-not-found
helm test radosgw-openstack
