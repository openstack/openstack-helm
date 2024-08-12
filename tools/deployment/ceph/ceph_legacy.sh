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

: ${CEPH_OSD_DATA_DEVICE:="/dev/loop100"}
: ${POD_NETWORK_CIDR:="10.244.0.0/16"}
: ${OSH_INFRA_HELM_REPO:="../openstack-helm-infra"}
: ${OSH_INFRA_PATH:="../openstack-helm-infra"}

NUMBER_OF_OSDS="$(kubectl get nodes -l ceph-osd=enabled --no-headers | wc -l)"

#NOTE: Deploy command
[ -s /tmp/ceph-fs-uuid.txt ] || uuidgen > /tmp/ceph-fs-uuid.txt
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

# Most of PV fields are immutable and in case of CSI RBD plugin they refer
# to secrets which were used for RBD provisioner and RBD attacher. These fields
# can not be updated later.
# So for testing purposes we assume legacy Ceph cluster is deployed with
# the following secret names for the CSI plugin
# - rook-csi-rbd-provisioner
# - rook-csi-rbd-node
# These exact secret names are used by Rook by default for CSI plugin and
# and after migration PVs will be adopted by the new Rook Ceph cluster.
#
# Alternatively if we deploy legacy Ceph cluster with the default values
# then we could later force Rook to use same CSI secret names as used for
# legacy cluster. For example pvc-ceph-conf-combined-storageclass secret
# name is used by default in legacy charts.
#
# Same is for CSI provisioner drivername option. For testing we deploy
# legacy cluster with the drivername set to rook-ceph.rbd.csi.ceph.com
# while default value is ceph.rbd.csi.ceph.com.
# This is also for the sake of smooth adoption of PVs.

tee /tmp/ceph.yaml <<EOF
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
  public: "${POD_NETWORK_CIDR}"
  cluster: "${POD_NETWORK_CIDR}"
  port:
    mon: 6789
    rgw: 8088
    mgr: 7000
deployment:
  storage_secrets: true
  ceph: true
  csi_rbd_provisioner: true
  client_secrets: false
  rgw_keystone_user_and_endpoints: false
bootstrap:
  enabled: true
conf:
  rgw_ks:
    enabled: false
  ceph:
    global:
      fsid: ${CEPH_FS_ID}
      mon_addr: :6789
      mon_allow_pool_size_one: true
      osd_pool_default_size: 1
    osd:
      osd_crush_chooseleaf_type: 0
  pool:
    crush:
      tunables: ${CRUSH_TUNABLES}
    target:
      osd: ${NUMBER_OF_OSDS}
      final_osd: ${NUMBER_OF_OSDS}
      pg_per_osd: 100
    default:
      crush_rule: same_host
    spec:
      # Health metrics pool
      - name: .mgr
        application: mgr_devicehealth
        replication: 1
        percent_total_data: 5
      # RBD pool
      - name: rbd
        application: rbd
        replication: 1
        percent_total_data: 40
  storage:
    osd:
      - data:
          type: bluestore
          location: ${CEPH_OSD_DATA_DEVICE}
        # block_db:
        #   location: ${CEPH_OSD_DB_WAL_DEVICE}
        #   size: "5GB"
        # block_wal:
        #   location: ${CEPH_OSD_DB_WAL_DEVICE}
        #   size: "2GB"

storageclass:
  rbd:
    parameters:
      adminSecretName: rook-csi-rbd-provisioner
      adminSecretNameNode: rook-csi-rbd-node
  csi_rbd:
    provisioner: rook-ceph.rbd.csi.ceph.com
    parameters:
      clusterID: ceph
      csi.storage.k8s.io/controller-expand-secret-name: rook-csi-rbd-provisioner
      csi.storage.k8s.io/controller-expand-secret-namespace: ceph
      csi.storage.k8s.io/fstype: ext4
      csi.storage.k8s.io/node-stage-secret-name: rook-csi-rbd-node
      csi.storage.k8s.io/node-stage-secret-namespace: ceph
      csi.storage.k8s.io/provisioner-secret-name: rook-csi-rbd-provisioner
      csi.storage.k8s.io/provisioner-secret-namespace: ceph
      pool: rbd
      imageFeatures: layering
      imageFormat: "2"
      adminId: null
      adminSecretName: rook-csi-rbd-provisioner
      adminSecretNamespace: ceph
      userId: null
      userSecretName: null

pod:
  replicas:
    mds: 1
    mgr: 1
    rgw: 1
    csi_rbd_provisioner: 1

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
  job_bootstrap: false
EOF

for CHART in ceph-mon ceph-osd ceph-client ceph-provisioners; do
  helm upgrade --install --create-namespace ${CHART} ${OSH_INFRA_HELM_REPO}/${CHART} \
    --namespace=ceph \
    --values=/tmp/ceph.yaml \
    ${OSH_INFRA_EXTRA_HELM_ARGS} \
    ${OSH_INFRA_EXTRA_HELM_ARGS_CEPH_DEPLOY:-$(helm osh get-values-overrides ${DOWNLOAD_OVERRIDES:-} -p ${OSH_INFRA_PATH} -c ${CHART} ${FEATURES})}

  #NOTE: Wait for deploy
  helm osh wait-for-pods ceph

  #NOTE: Validate deploy
  MON_POD=$(kubectl get pods \
    --namespace=ceph \
    --selector="application=ceph" \
    --selector="component=mon" \
    --no-headers | awk '{ print $1; exit }')
  kubectl exec -n ceph ${MON_POD} -- ceph -s
done
