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

#NOTE: Deploy command
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
  storage_secrets: false
  ceph: true
  rbd_provisioner: false
  cephfs_provisioner: false
  client_secrets: false
  rgw_keystone_user_and_endpoints: true
bootstrap:
  enabled: false
conf:
  rgw_ks:
    enabled: true
EOF

: ${OSH_INFRA_PATH:="../openstack-helm-infra"}
helm upgrade --install radosgw-openstack ${OSH_INFRA_PATH}/ceph-rgw \
  --namespace=openstack \
  --values=/tmp/radosgw-openstack.yaml \
  ${OSH_EXTRA_HELM_ARGS} \
  ${OSH_EXTRA_HELM_ARGS_HEAT}

#NOTE: Wait for deploy
./tools/deployment/common/wait-for-pods.sh openstack

#NOTE: Validate Deployment info
helm status radosgw-openstack
export OS_CLOUD=openstack_helm
openstack service list
openstack container create 'mygreatcontainer'
curl -L -o /tmp/important-file.jpg https://imgflip.com/s/meme/Cute-Cat.jpg
openstack object create --name 'superimportantfile.jpg' 'mygreatcontainer' /tmp/important-file.jpg
