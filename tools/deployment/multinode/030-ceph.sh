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

#NOTE: Deploy command
[ -s /tmp/ceph-fs-uuid.txt ] || uuidgen > /tmp/ceph-fs-uuid.txt
CEPH_PUBLIC_NETWORK="$(./tools/deployment/multinode/kube-node-subnet.sh)"
CEPH_CLUSTER_NETWORK="${CEPH_PUBLIC_NETWORK}"
CEPH_FS_ID="$(cat /tmp/ceph-fs-uuid.txt)"
#NOTE(portdirect): to use RBD devices with kernels < 4.5 this should be set to 'hammer'
LOWEST_CLUSTER_KERNEL_VERSION=$(kubectl get node  -o go-template='{{range .items}}{{.status.nodeInfo.kernelVersion}}{{"\n"}}{{ end }}' | sort -V | tail -1)
if [ "$(echo ${LOWEST_CLUSTER_KERNEL_VERSION} | awk -F "." '{ print $1 }')" -lt "4" ] || [ "$(echo ${LOWEST_CLUSTER_KERNEL_VERSION} | awk -F "." '{ print $2 }')" -lt "15" ]; then
  echo "Using hammer crush tunables"
  CRUSH_TUNABLES=hammer
else
  CRUSH_TUNABLES=null
fi
NUMBER_OF_OSDS="$(kubectl get nodes -l ceph-osd=enabled --no-headers | wc -l)"
tee /tmp/ceph.yaml << EOF
endpoints:
  ceph_mon:
    namespace: ceph
network:
  public: ${CEPH_PUBLIC_NETWORK}
  cluster: ${CEPH_CLUSTER_NETWORK}
deployment:
  storage_secrets: true
  ceph: true
  rbd_provisioner: true
  cephfs_provisioner: false
  client_secrets: false
bootstrap:
  enabled: true
conf:
  ceph:
    global:
      fsid: ${CEPH_FS_ID}
  pool:
    crush:
      tunables: ${CRUSH_TUNABLES}
    target:
      osd: ${NUMBER_OF_OSDS}
      pg_per_osd: 100
  storage:
    osd:
      - data:
          type: bluestore
          location: /dev/loop0
        block_db:
          location: /dev/loop1
          size: "5GB"
        block_wal:
          location: /dev/loop1
          size: "2GB"
storageclass:
  cephfs:
    provision_storage_class: false
manifests:
  deployment_cephfs_provisioner: false
  job_cephfs_client_key: false
EOF

: ${OSH_INFRA_PATH:="../openstack-helm-infra"}
for CHART in ceph-mon ceph-osd ceph-client ceph-provisioners; do
  make -C ${OSH_INFRA_PATH} ${CHART}
  helm upgrade --install ${CHART} ${OSH_INFRA_PATH}/${CHART} \
    --namespace=ceph \
    --values=/tmp/ceph.yaml \
    ${OSH_EXTRA_HELM_ARGS} \
    ${OSH_EXTRA_HELM_ARGS_CEPH_DEPLOY}

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
