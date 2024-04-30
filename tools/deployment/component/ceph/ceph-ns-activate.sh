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

#NOTE: Define variables
: ${OSH_INFRA_HELM_REPO:="../openstack-helm-infra"}
: ${OSH_INFRA_PATH:="../openstack-helm-infra"}
: ${OSH_EXTRA_HELM_ARGS_CEPH_NS_ACTIVATE:="$(helm osh get-values-overrides ${DOWNLOAD_OVERRIDES:-} -p ${OSH_INFRA_PATH} -c ceph-provisioners ${FEATURES})"}

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
helm upgrade --install ceph-openstack-config ${OSH_INFRA_HELM_REPO}/ceph-provisioners \
    --namespace=openstack \
    --values=/tmp/ceph-openstack-config.yaml \
    ${OSH_EXTRA_HELM_ARGS:=} \
    ${OSH_EXTRA_HELM_ARGS_CEPH_NS_ACTIVATE}

#NOTE: Wait for deploy
helm osh wait-for-pods openstack

#NOTE: Validate Deployment info
kubectl get -n openstack jobs
kubectl get -n openstack secrets
kubectl get -n openstack configmaps
