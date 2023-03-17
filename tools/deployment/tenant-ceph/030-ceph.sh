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
./tools/deployment/common/setup-ceph-loopback-device.sh \
    --ceph-osd-data ${CEPH_OSD_DATA_DEVICE:=${free_loop_devices[0]}} \
    --ceph-osd-dbwal ${CEPH_OSD_DB_WAL_DEVICE:=${free_loop_devices[1]}}

#NOTE: Deploy command
[ -s /tmp/ceph-fs-uuid.txt ] || uuidgen > /tmp/ceph-fs-uuid.txt
CEPH_PUBLIC_NETWORK="$(./tools/deployment/multinode/kube-node-subnet.sh)"
CEPH_CLUSTER_NETWORK="$(./tools/deployment/multinode/kube-node-subnet.sh)"
CEPH_FS_ID="$(cat /tmp/ceph-fs-uuid.txt)"
#NOTE(portdirect): to use RBD devices with Ubuntu kernels < 4.5 this
# should be set to 'hammer'
. /etc/os-release
if [ "x${ID}" == "xcentos" ] || \
   ([ "x${ID}" == "xubuntu" ] && \
   dpkg --compare-versions "$(uname -r)" "lt" "4.5"); then
  CRUSH_TUNABLES=hammer
else
  CRUSH_TUNABLES=null
fi
if [ "x${ID}" == "xcentos" ]; then
  CRUSH_TUNABLES=hammer
fi
tee /tmp/ceph.yaml << EOF
endpoints:
  ceph_mon:
    namespace: ceph
    port:
      mon:
        default: 6789
  ceph_mgr:
    namespace: ceph
    port:
      mgr:
        default: 7000
      metrics:
        default: 9283
network:
  public: ${CEPH_PUBLIC_NETWORK}
  cluster: ${CEPH_CLUSTER_NETWORK}
deployment:
  storage_secrets: true
  ceph: true
  csi_rbd_provisioner: true
  client_secrets: false
  rgw_keystone_user_and_endpoints: false
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
bootstrap:
  enabled: true
conf:
  ceph:
    global:
      fsid: ${CEPH_FS_ID}
      mon_allow_pool_size_one: true
    mon:
      mon_clock_drift_allowed: 2.0
  rgw_ks:
    enabled: true
  pool:
    crush:
      tunables: ${CRUSH_TUNABLES}
    target:
      # NOTE(portdirect): 5 nodes, with one osd per node
      osd: 3
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
storageclass:
  csi_rbd:
    ceph_configmap_name: ceph-etc
  rbd:
    provision_storage_class: false
  cephfs:
    provision_storage_class: false
ceph_mgr_modules_config:
  prometheus:
    server_port: 9283
monitoring:
  prometheus:
    enabled: true
    ceph_mgr:
      port: 9283
EOF

for CHART in ceph-mon ceph-osd ceph-client ceph-provisioners; do
  helm upgrade --install ${CHART} ./${CHART} \
    --namespace=ceph \
    --values=/tmp/ceph.yaml \
    ${OSH_INFRA_EXTRA_HELM_ARGS} \
    ${OSH_INFRA_EXTRA_HELM_ARGS_CEPH_DEPLOY:-$(./tools/deployment/common/get-values-overrides.sh ${CHART})}

  #NOTE: Wait for deploy
  ./tools/deployment/common/wait-for-pods.sh ceph 1200

  #NOTE: Validate deploy
  MON_POD=$(kubectl get pods \
    --namespace=ceph \
    --selector="application=ceph" \
    --selector="component=mon" \
    --no-headers | awk '{ print $1; exit }')
  kubectl exec -n ceph ${MON_POD} -- ceph -s
done

# Delete the test pod if it still exists
kubectl delete pods -l application=ceph-osd,release_group=ceph-osd,component=test --namespace=ceph --ignore-not-found
helm test ceph-osd --namespace ceph --timeout 900s
# Delete the test pod if it still exists
kubectl delete pods -l application=ceph-client,release_group=ceph-client,component=test --namespace=ceph --ignore-not-found
helm test ceph-client --namespace ceph --timeout 900s
