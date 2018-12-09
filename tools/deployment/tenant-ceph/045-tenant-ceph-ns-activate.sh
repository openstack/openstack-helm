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
tee /tmp/tenant-ceph-openstack-config.yaml <<EOF
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
storageclass:
  rbd:
    ceph_configmap_name: tenant-ceph-etc
    provision_storage_class: false
    name: tenant-rbd
    admin_secret_name: pvc-tenant-ceph-conf-combined-storageclass
    admin_secret_namespace: tenant-ceph
    user_secret_name: pvc-tenant-ceph-client-key
  cephfs:
    provision_storage_class: false
    name: cephfs
    admin_secret_name: pvc-tenant-ceph-conf-combined-storageclass
    admin_secret_namespace: tenant-ceph
    user_secret_name: pvc-tenant-ceph-cephfs-client-key
EOF
helm upgrade --install tenant-ceph-openstack-config ./ceph-provisioners \
  --namespace=openstack \
  --values=/tmp/tenant-ceph-openstack-config.yaml \
  ${OSH_EXTRA_HELM_ARGS} \
  ${OSH_EXTRA_HELM_ARGS_CEPH_NS_ACTIVATE}

#NOTE: Wait for deploy
./tools/deployment/common/wait-for-pods.sh openstack

#NOTE: Validate Deployment info
helm status tenant-ceph-openstack-config
