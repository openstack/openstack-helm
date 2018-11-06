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

#NOTE: Lint and package chart
: ${OSH_INFRA_PATH:="../openstack-helm-infra"}
for CHART in ceph-mon ceph-osd ceph-client ceph-provisioners; do
  make -C ${OSH_INFRA_PATH} "${CHART}"
done

#NOTE: Deploy command

: ${OSH_EXTRA_HELM_ARGS:=""}
[ -s /tmp/ceph-fs-uuid.txt ] || uuidgen > /tmp/ceph-fs-uuid.txt
CEPH_FS_ID="$(cat /tmp/ceph-fs-uuid.txt)"
#NOTE(portdirect): to use RBD devices with Ubuntu kernels < 4.5 this
# should be set to 'hammer'
. /etc/os-release
if [ "x${ID}" == "xubuntu" ] && \
   [ "$(uname -r | awk -F "." '{ print $2 }')" -lt "5" ]; then
  CRUSH_TUNABLES=hammer
else
  CRUSH_TUNABLES=null
fi
tee /tmp/ceph.yaml <<EOF
endpoints:
  identity:
    namespace: openstack
  object_store:
    namespace: ceph
    port:
      api:
        default: 8088
        public: 80
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
  public: 172.17.0.1/16
  cluster: 172.17.0.1/16
  port:
    mon: 6789
    rgw: 8088
    mgr: 7000
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
    global:
      fsid: ${CEPH_FS_ID}
      mon_addr: :6789
      osd_pool_default_size: 1
    osd:
      osd_crush_chooseleaf_type: 0
  pool:
    crush:
      tunables: ${CRUSH_TUNABLES}
    target:
      osd: 1
      pg_per_osd: 100
    default:
      crush_rule: same_host
    spec:
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
          type: directory
          location: /var/lib/openstack-helm/ceph/osd/osd-one
        journal:
          type: directory
          location: /var/lib/openstack-helm/ceph/osd/journal-one

pod:
  replicas:
    mds: 1
    mgr: 1
    rgw: 1

manifests:
  cronjob_checkPGs: true
EOF

for CHART in ceph-mon ceph-osd ceph-client ceph-provisioners; do
  helm upgrade --install ${CHART} ${OSH_INFRA_PATH}/${CHART} \
    --namespace=ceph \
    --values=/tmp/ceph.yaml \
    ${OSH_EXTRA_HELM_ARGS} \
    ${OSH_EXTRA_HELM_ARGS_CEPH_DEPLOY}

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
