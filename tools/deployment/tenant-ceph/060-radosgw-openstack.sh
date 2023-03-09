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
tee /tmp/radosgw-openstack.yaml <<EOF
endpoints:
  identity:
    namespace: openstack
  object_store:
    namespace: openstack
  ceph_mon:
    namespace: tenant-ceph
    port:
      mon:
        default: 6790
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
secrets:
  keyrings:
    admin: pvc-tenant-ceph-client-key
    rgw: os-ceph-bootstrap-rgw-keyring
  identity:
    admin: ceph-keystone-admin
    swift: ceph-keystone-user
    user_rgw: ceph-keystone-user-rgw
ceph_client:
  configmap: tenant-ceph-etc
EOF
helm upgrade --install radosgw-openstack ./ceph-rgw \
  --namespace=openstack \
  --values=/tmp/radosgw-openstack.yaml

#NOTE: Wait for deploy
./tools/deployment/common/wait-for-pods.sh openstack

# Delete the test pod if it still exists
kubectl delete pods -l application=ceph,release_group=radosgw-openstack,component=rgw-test --namespace=openstack --ignore-not-found
helm test radosgw-openstack --namespace openstack --timeout 900s
