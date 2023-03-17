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

# setup loopback devices for ceph
free_loop_devices=( $(ls -1 /dev/loop[0-7] | while read loopdev; do losetup | grep -q $loopdev || echo $loopdev; done) )
export CEPH_NAMESPACE="tenant-ceph"
./tools/deployment/common/setup-ceph-loopback-device.sh \
    --ceph-osd-data ${CEPH_OSD_DATA_DEVICE:=${free_loop_devices[0]}} \
    --ceph-osd-dbwal ${CEPH_OSD_DB_WAL_DEVICE:=${free_loop_devices[1]}}

# setup loopback devices for ceph osds
setup_loopback_devices $OSD_DATA_DEVICE $OSD_DB_WAL_DEVICE

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
  csi_rbd_provisioner: false
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
    metadata:
      name: tenant-rbd
    parameters:
      adminSecretName: pvc-tenant-ceph-conf-combined-storageclass
      adminSecretNamespace: tenant-ceph
      userSecretName: pvc-tenant-ceph-client-key
  cephfs:
    provision_storage_class: false
    metadata:
      name: cephfs
    parameters:
      adminSecretName: pvc-tenant-ceph-conf-combined-storageclass
      adminSecretNamespace: tenant-ceph
      userSecretName: pvc-tenant-ceph-cephfs-client-key
bootstrap:
  enabled: true
jobs:
  ceph_defragosds:
    # Execute every 15 minutes for gates
    cron: "*/15 * * * *"
    history:
      # Number of successful job to keep
      successJob: 1
      # Number of failed job to keep
      failJob: 1
    concurrency:
      # Skip new job if previous job still active
      execPolicy: Forbid
    startingDeadlineSecs: 60
manifests:
  deployment_mds: false
  cronjob_defragosds: true
  job_cephfs_client_key: false
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
      mon_allow_pool_size_one: true
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
          type: bluestore
          location: ${CEPH_OSD_DATA_DEVICE}
        block_db:
          location: ${CEPH_OSD_DB_WAL_DEVICE}
          size: "5GB"
        block_wal:
          location: ${CEPH_OSD_DB_WAL_DEVICE}
          size: "2GB"
    mon:
      directory: /var/lib/openstack-helm/tenant-ceph/mon
deploy:
  tool: "ceph-volume"
EOF

for CHART in ceph-mon ceph-osd ceph-client; do
  helm upgrade --install tenant-${CHART} ./${CHART} \
    --namespace=tenant-ceph \
    --values=/tmp/tenant-ceph.yaml \
    ${OSH_INFRA_EXTRA_HELM_ARGS} \
    ${OSH_INFRA_EXTRA_HELM_ARGS_CEPH_DEPLOY:-$(./tools/deployment/common/get-values-overrides.sh ${CHART})}

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

helm test tenant-ceph-osd --namespace tenant-ceph --timeout 900s
helm test tenant-ceph-client --namespace tenant-ceph --timeout 900s
