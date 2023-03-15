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
: ${OSH_EXTRA_HELM_ARGS_CEPH_NS_ACTIVATE:="$(./tools/deployment/common/get-values-overrides.sh ceph-provisioners)"}

#NOTE: Lint and package chart
make -C ${HELM_CHART_ROOT_PATH} ceph-provisioners

#NOTE: Deploy command
tee /tmp/ceph-openstack-config.yaml <<EOF
endpoints:
  ceph_mon:
    namespace: ceph
network:
  public: 172.17.0.1/16
  cluster: 172.17.0.1/16
deployment:
  ceph: false
  rbd_provisioner: false
  csi_rbd_provisioner: false
  cephfs_provisioner: false
  client_secrets: true
bootstrap:
  enabled: false
conf:
  ceph:
    global:
      mon_host: ceph-mon-discovery.ceph.svc.cluster.local:6789
      mon_allow_pool_size_one: true
EOF
helm upgrade --install ceph-openstack-config ${HELM_CHART_ROOT_PATH}/ceph-provisioners \
  --namespace=openstack \
  --values=/tmp/ceph-openstack-config.yaml \
  ${OSH_EXTRA_HELM_ARGS:=} \
  ${OSH_EXTRA_HELM_ARGS_CEPH_NS_ACTIVATE}

#NOTE: Wait for deploy
./tools/deployment/common/wait-for-pods.sh openstack

#NOTE: Validate Deployment info
kubectl get -n openstack jobs
kubectl get -n openstack secrets
kubectl get -n openstack configmaps
