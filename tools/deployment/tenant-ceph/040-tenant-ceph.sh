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
[ -s /tmp/tenant-ceph-fs-uuid.txt ] || uuidgen > /tmp/tenant-ceph-fs-uuid.txt
CEPH_PUBLIC_NETWORK="$(./tools/deployment/multinode/kube-node-subnet.sh)"
CEPH_CLUSTER_NETWORK="$(./tools/deployment/multinode/kube-node-subnet.sh)"
TENANT_CEPH_FS_ID="$(cat /tmp/tenant-ceph-fs-uuid.txt)"
#NOTE(portdirect): to use RBD devices with Ubuntu kernels < 4.5 this
# should be set to 'hammer'
. /etc/os-release
if [ "x${ID}" == "xubuntu" ] && \
   [ "$(uname -r | awk -F "." '{ print $2 }')" -lt "5" ]; then
  CRUSH_TUNABLES=hammer
else
  CRUSH_TUNABLES=null
fi
if [ "x${ID}" == "xcentos" ]; then
  CRUSH_TUNABLES=hammer
fi
tee /tmp/tenant-ceph.yaml << EOF
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
  ceph_mgr:
    namespace: tenant-ceph
    port:
      mgr:
        default: 7001
      metrics:
        default: 9284
network:
  public: ${CEPH_PUBLIC_NETWORK}
  cluster: ${CEPH_CLUSTER_NETWORK}
deployment:
  storage_secrets: true
  ceph: true
  rbd_provisioner: false
  cephfs_provisioner: false
  client_secrets: false
  rgw_keystone_user_and_endpoints: false
labels:
  mon:
    node_selector_key: ceph-mon-tenant
  osd:
    node_selector_key: ceph-osd-tenant
  rgw:
    node_selector_key: ceph-rgw-tenant
  mgr:
    node_selector_key: ceph-mgr-tenant
  job:
    node_selector_key: tenant-ceph-control-plane
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
    user_secret_name: pvc-tenant-ceph-cephfs-client-key
    admin_secret_name: pvc-tenant-ceph-conf-combined-storageclass
    admin_secret_namespace: tenant-ceph
bootstrap:
  enabled: true
manifests:
  deployment_mds: false
ceph_mgr_modules_config:
  prometheus:
    server_port: 9284
monitoring:
  prometheus:
    enabled: true
    ceph_mgr:
      port: 9284
conf:
  ceph:
    global:
      fsid: ${TENANT_CEPH_FS_ID}
  rgw_ks:
    enabled: true
  pool:
    crush:
      tunables: ${CRUSH_TUNABLES}
    target:
      osd: 2
      pg_per_osd: 100
  storage:
    osd:
      - data:
          type: directory
          location: /var/lib/openstack-helm/tenant-ceph/osd/osd-one
        journal:
          type: directory
          location: /var/lib/openstack-helm/tenant-ceph/osd/journal-one
    mon:
      directory: /var/lib/openstack-helm/tenant-ceph/mon
EOF

for CHART in ceph-mon ceph-osd ceph-client; do
  helm upgrade --install tenant-${CHART} ./${CHART} \
    --namespace=tenant-ceph \
    --values=/tmp/tenant-ceph.yaml \
    ${OSH_INFRA_EXTRA_HELM_ARGS} \
    ${OSH_INFRA_EXTRA_HELM_ARGS_CEPH_DEPLOY}

  #NOTE: Wait for deploy
  ./tools/deployment/common/wait-for-pods.sh tenant-ceph 1200

  #NOTE: Validate deploy
  MON_POD=$(kubectl get pods \
    --namespace=tenant-ceph \
    --selector="application=ceph" \
    --selector="component=mon" \
    --no-headers | awk '{ print $1; exit }')
  kubectl exec -n tenant-ceph ${MON_POD} -- ceph -s
done
