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

export CEPH_ENABLED=true

: ${CEPH_OSD_DATA_DEVICE:="/dev/loop100"}
: ${POD_NETWORK_CIDR:="10.244.0.0/24"}

#NOTE: Lint and package chart
export HELM_CHART_ROOT_PATH="${HELM_CHART_ROOT_PATH:="${OSH_INFRA_PATH:="../openstack-helm-infra"}"}"
for CHART in ceph-mon ceph-osd ceph-client ceph-provisioners; do
  make -C ${HELM_CHART_ROOT_PATH} "${CHART}"
done

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
tee /tmp/ceph.yaml <<EOF
endpoints:
  ceph_mon:
    namespace: ceph
  ceph_mgr:
    namespace: ceph
network:
  public: "${POD_NETWORK_CIDR}"
  cluster: "${POD_NETWORK_CIDR}"
deployment:
  storage_secrets: true
  ceph: true
  rbd_provisioner: true
  csi_rbd_provisioner: true
  cephfs_provisioner: true
  client_secrets: false
manifests:
  deployment_rbd_provisioner: true
  deployment_csi_rbd_provisioner: true
  deployment_cephfs_provisioner: true
bootstrap:
  enabled: true
conf:
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
      # CephFS pools
      - name: cephfs_metadata
        application: cephfs
        replication: 1
        percent_total_data: 5
      - name: cephfs_data
        application: cephfs
        replication: 1
        percent_total_data: 10
      # RadosGW pools
      - name: .rgw.root
        application: rgw
        replication: 1
        percent_total_data: 0.1
      - name: default.rgw.control
        application: rgw
        replication: 1
        percent_total_data: 0.1
      - name: default.rgw.data.root
        application: rgw
        replication: 1
        percent_total_data: 0.1
      - name: default.rgw.gc
        application: rgw
        replication: 1
        percent_total_data: 0.1
      - name: default.rgw.log
        application: rgw
        replication: 1
        percent_total_data: 0.1
      - name: default.rgw.intent-log
        application: rgw
        replication: 1
        percent_total_data: 0.1
      - name: default.rgw.meta
        application: rgw
        replication: 1
        percent_total_data: 0.1
      - name: default.rgw.usage
        application: rgw
        replication: 1
        percent_total_data: 0.1
      - name: default.rgw.users.keys
        application: rgw
        replication: 1
        percent_total_data: 0.1
      - name: default.rgw.users.email
        application: rgw
        replication: 1
        percent_total_data: 0.1
      - name: default.rgw.users.swift
        application: rgw
        replication: 1
        percent_total_data: 0.1
      - name: default.rgw.users.uid
        application: rgw
        replication: 1
        percent_total_data: 0.1
      - name: default.rgw.buckets.extra
        application: rgw
        replication: 1
        percent_total_data: 0.1
      - name: default.rgw.buckets.index
        application: rgw
        replication: 1
        percent_total_data: 3
      - name: default.rgw.buckets.data
        application: rgw
        replication: 1
        percent_total_data: 34.8
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
pod:
  replicas:
    mds: 1
    mgr: 1

EOF

for CHART in ceph-mon ceph-osd ceph-client ceph-provisioners; do

  helm upgrade --install ${CHART} ${HELM_CHART_ROOT_PATH}/${CHART} \
    --namespace=ceph \
    --values=/tmp/ceph.yaml \
    ${OSH_EXTRA_HELM_ARGS} \
    ${OSH_EXTRA_HELM_ARGS_CEPH:-$(./tools/deployment/common/get-values-overrides.sh ${CHART})}

  #NOTE: Wait for deploy
  ./tools/deployment/common/wait-for-pods.sh ceph

  #NOTE: Validate deploy
  MON_POD=$(kubectl get pods \
    --namespace=ceph \
    --selector="application=ceph" \
    --selector="component=mon" \
    --no-headers | awk '{ print $1; exit }')
  kubectl exec -n ceph ${MON_POD} -- ceph -s
done
