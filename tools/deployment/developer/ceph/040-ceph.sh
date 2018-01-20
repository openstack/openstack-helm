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
make pull-images ceph

#NOTE: Deploy command
uuidgen > /tmp/ceph-fs-uuid.txt
cat > /tmp/ceph.yaml <<EOF
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
  storage_secrets: true
  ceph: true
  rbd_provisioner: true
  cephfs_provisioner: true
  client_secrets: false
  rgw_keystone_user_and_endpoints: false
bootstrap:
  enabled: true
conf:
  rgw_ks:
    enabled: true
  ceph:
    config:
      global:
        fsid: "$(cat /tmp/ceph-fs-uuid.txt)"
        osd_pool_default_size: 1
      osd:
        osd_crush_chooseleaf_type: 0
EOF
helm install ./ceph \
  --namespace=ceph \
  --name=ceph \
  --values=/tmp/ceph.yaml

#NOTE: Wait for deploy
./tools/deployment/common/wait-for-pods.sh ceph

#NOTE: Validate deploy
MON_POD=$(kubectl get pods \
  --namespace=ceph \
  --selector="application=ceph" \
  --selector="component=mon" \
  --no-headers | awk '{ print $1; exit }')
kubectl exec -n ceph ${MON_POD} -- ceph -s
