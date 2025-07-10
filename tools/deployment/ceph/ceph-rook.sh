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

# Specify the Rook release tag to use for the Rook operator here
ROOK_RELEASE=v1.17.3

: ${CEPH_OSD_DATA_DEVICE:="/dev/loop100"}

#NOTE: Deploy command
: ${OSH_EXTRA_HELM_ARGS:=""}
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
tee /tmp/rook.yaml <<EOF
image:
  repository: rook/ceph
  tag: ${ROOK_RELEASE}
  pullPolicy: IfNotPresent
crds:
  enabled: true
nodeSelector: {}
tolerations: []
unreachableNodeTolerationSeconds: 5
currentNamespaceOnly: false
annotations: {}
logLevel: INFO
rbacEnable: true
pspEnable: false
priorityClassName:
allowLoopDevices: true
csi:
  enableRbdDriver: true
  enableCephfsDriver: false
  enableGrpcMetrics: false
  enableCSIHostNetwork: true
  enableCephfsSnapshotter: true
  enableNFSSnapshotter: true
  enableRBDSnapshotter: true
  enablePluginSelinuxHostMount: false
  enableCSIEncryption: false
  pluginPriorityClassName: system-node-critical
  provisionerPriorityClassName: system-cluster-critical
  rbdFSGroupPolicy: "File"
  cephFSFSGroupPolicy: "File"
  nfsFSGroupPolicy: "File"
  enableOMAPGenerator: false
  cephFSKernelMountOptions:
  enableMetadata: false
  provisionerReplicas: 1
  clusterName: ceph
  logLevel: 0
  sidecarLogLevel:
  rbdPluginUpdateStrategy:
  rbdPluginUpdateStrategyMaxUnavailable:
  cephFSPluginUpdateStrategy:
  nfsPluginUpdateStrategy:
  grpcTimeoutInSeconds: 150
  allowUnsupportedVersion: false
  csiRBDPluginVolume:
  csiRBDPluginVolumeMount:
  csiCephFSPluginVolume:
  csiCephFSPluginVolumeMount:
  provisionerTolerations:
  provisionerNodeAffinity: #key1=value1,value2; key2=value3
  pluginTolerations:
  pluginNodeAffinity: # key1=value1,value2; key2=value3
  enableLiveness: false
  cephfsGrpcMetricsPort:
  cephfsLivenessMetricsPort:
  rbdGrpcMetricsPort:
  csiAddonsPort:
  forceCephFSKernelClient: true
  rbdLivenessMetricsPort:
  kubeletDirPath:
  cephcsi:
    image:
  registrar:
    image:
  provisioner:
    image:
  snapshotter:
    image:
  attacher:
    image:
  resizer:
    image:
  imagePullPolicy: IfNotPresent
  cephfsPodLabels: #"key1=value1,key2=value2"
  nfsPodLabels: #"key1=value1,key2=value2"
  rbdPodLabels: #"key1=value1,key2=value2"
  csiAddons:
    enabled: false
    image: "quay.io/csiaddons/k8s-sidecar:v0.5.0"
  nfs:
    enabled: false
  topology:
    enabled: false
    domainLabels:
  readAffinity:
    enabled: false
    crushLocationLabels:
  cephFSAttachRequired: true
  rbdAttachRequired: true
  nfsAttachRequired: true
enableDiscoveryDaemon: false
cephCommandsTimeoutSeconds: "15"
useOperatorHostNetwork:
discover:
  toleration:
  tolerationKey:
  tolerations:
  nodeAffinity: # key1=value1,value2; key2=value3
  podLabels: # "key1=value1,key2=value2"
  resources:
disableAdmissionController: true
hostpathRequiresPrivileged: false
disableDeviceHotplug: false
discoverDaemonUdev:
imagePullSecrets:
enableOBCWatchOperatorNamespace: true
admissionController:
EOF

helm repo add rook-release https://charts.rook.io/release
helm install --create-namespace --namespace rook-ceph rook-ceph rook-release/rook-ceph --version ${ROOK_RELEASE} -f /tmp/rook.yaml
helm osh wait-for-pods rook-ceph

tee /tmp/ceph.yaml <<EOF
operatorNamespace: rook-ceph
clusterName: ceph
kubeVersion:
configOverride: |
  [global]
  mon_allow_pool_delete = true
  mon_allow_pool_size_one = true
  osd_pool_default_size = 1
  osd_pool_default_min_size = 1
  mon_warn_on_pool_no_redundancy = false
  auth_allow_insecure_global_id_reclaim = false
toolbox:
  enabled: true
  tolerations: []
  affinity: {}
  resources:
    limits:
      cpu: "100m"
      memory: "64Mi"
    requests:
      cpu: "100m"
      memory: "64Mi"
  priorityClassName:
monitoring:
  enabled: false
  metricsDisabled: true
  createPrometheusRules: false
  rulesNamespaceOverride:
  prometheusRule:
    labels: {}
    annotations: {}
pspEnable: false
cephClusterSpec:
  cephVersion:
    image: quay.io/ceph/ceph:v19.2.2
    allowUnsupported: false
  dataDirHostPath: /var/lib/rook
  skipUpgradeChecks: false
  continueUpgradeAfterChecksEvenIfNotHealthy: false
  waitTimeoutForHealthyOSDInMinutes: 10
  mon:
    count: 3
    allowMultiplePerNode: false
  mgr:
    count: 3
    allowMultiplePerNode: false
    modules:
      - name: pg_autoscaler
        enabled: true
      - name: dashboard
        enabled: false
      - name: nfs
        enabled: false
  dashboard:
    enabled: true
    ssl: true
  network:
    connections:
      encryption:
        enabled: false
      compression:
        enabled: false
      requireMsgr2: false
    provider: host
  crashCollector:
    disable: true
  logCollector:
    enabled: true
    periodicity: daily # one of: hourly, daily, weekly, monthly
    maxLogSize: 500M # SUFFIX may be 'M' or 'G'. Must be at least 1M.
  cleanupPolicy:
    confirmation: ""
    sanitizeDisks:
      method: quick
      dataSource: zero
      iteration: 1
    allowUninstallWithVolumes: false
  monitoring:
    enabled: false
    metricsDisabled: true

  removeOSDsIfOutAndSafeToRemove: false
  priorityClassNames:
    mon: system-node-critical
    osd: system-node-critical
    mgr: system-cluster-critical
  storage: # cluster level storage configuration and selection
    useAllNodes: true
    useAllDevices: false
    devices:
      - name: "${CEPH_OSD_DATA_DEVICE}"
        config:
          databaseSizeMB: "5120"
          walSizeMB: "2048"
  disruptionManagement:
    managePodBudgets: true
    osdMaintenanceTimeout: 30
    pgHealthCheckTimeout: 0
  healthCheck:
    daemonHealth:
      mon:
        disabled: false
        interval: 45s
      osd:
        disabled: false
        interval: 60s
      status:
        disabled: false
        interval: 60s
    livenessProbe:
      mon:
        disabled: false
      mgr:
        disabled: false
      osd:
        disabled: false
ingress:
  dashboard:
    {}
cephBlockPools:
  - name: rbd
    namespace: ceph
    spec:
      failureDomain: host
      replicated:
        size: 1
    storageClass:
      enabled: true
      name: general
      isDefault: true
      reclaimPolicy: Delete
      allowVolumeExpansion: true
      volumeBindingMode: "Immediate"
      mountOptions: []
      allowedTopologies: []
      parameters:
        imageFormat: "2"
        imageFeatures: layering
        csi.storage.k8s.io/provisioner-secret-name: rook-csi-rbd-provisioner
        csi.storage.k8s.io/provisioner-secret-namespace: "{{ .Release.Namespace }}"
        csi.storage.k8s.io/controller-expand-secret-name: rook-csi-rbd-provisioner
        csi.storage.k8s.io/controller-expand-secret-namespace: "{{ .Release.Namespace }}"
        csi.storage.k8s.io/node-stage-secret-name: rook-csi-rbd-node
        csi.storage.k8s.io/node-stage-secret-namespace: "{{ .Release.Namespace }}"
        csi.storage.k8s.io/fstype: ext4
cephFileSystems: []
# Not needed in general for openstack-helm. Uncomment if needed.
# cephFileSystems:
#   - name: cephfs
#     namespace: ceph
#     spec:
#       metadataPool:
#         replicated:
#           size: 1
#       dataPools:
#         - failureDomain: host
#           replicated:
#             size: 1
#           name: data
#       metadataServer:
#         activeCount: 1
#         activeStandby: false
#         priorityClassName: system-cluster-critical
#     storageClass:
#       enabled: true
#       isDefault: false
#       name: ceph-filesystem
#       pool: data0
#       reclaimPolicy: Delete
#       allowVolumeExpansion: true
#       volumeBindingMode: "Immediate"
#       mountOptions: []
#       parameters:
#         csi.storage.k8s.io/provisioner-secret-name: rook-csi-cephfs-provisioner
#         csi.storage.k8s.io/provisioner-secret-namespace: "{{ .Release.Namespace }}"
#         csi.storage.k8s.io/controller-expand-secret-name: rook-csi-cephfs-provisioner
#         csi.storage.k8s.io/controller-expand-secret-namespace: "{{ .Release.Namespace }}"
#         csi.storage.k8s.io/node-stage-secret-name: rook-csi-cephfs-node
#         csi.storage.k8s.io/node-stage-secret-namespace: "{{ .Release.Namespace }}"
#         csi.storage.k8s.io/fstype: ext4
cephBlockPoolsVolumeSnapshotClass:
  enabled: false
  name: general
  isDefault: false
  deletionPolicy: Delete
  annotations: {}
  labels: {}
  parameters: {}
cephObjectStores:
  - name: default
    namespace: ceph
    spec:
      allowUsersInNamespaces:
        - "*"
      metadataPool:
        failureDomain: host
        replicated:
          size: 1
      dataPool:
        failureDomain: host
        replicated:
          size: 1
      preservePoolsOnDelete: true
      gateway:
        port: 8080
        instances: 1
        priorityClassName: system-cluster-critical
    storageClass:
      enabled: true
      name: ceph-bucket
      reclaimPolicy: Delete
      volumeBindingMode: "Immediate"
      parameters:
        region: us-east-1
EOF

helm upgrade --install --create-namespace --namespace ceph rook-ceph-cluster --set operatorNamespace=rook-ceph rook-release/rook-ceph-cluster --version ${ROOK_RELEASE} -f /tmp/ceph.yaml

helm osh wait-for-pods rook-ceph

kubectl wait --namespace=ceph --for=condition=ready pod --selector=app=rook-ceph-tools --timeout=600s

# Wait for all monitor pods to be ready
wait_start_time=$(date +%s)
while [[ $(($(date +%s) - $wait_start_time)) -lt 1800 ]]; do
    sleep 30
    MON_PODS=$(kubectl get pods --namespace=ceph --selector=app=rook-ceph-mon --no-headers | awk '{ print $1 }')
    MON_PODS_NUM=$(echo $MON_PODS | wc -w)
    MON_PODS_READY=0
    for MON_POD in $MON_PODS; do
        if kubectl get pod --namespace=ceph "$MON_POD" > /dev/null 2>&1; then
            kubectl wait --namespace=ceph --for=condition=ready "pod/$MON_POD" --timeout=60s && \
                { MON_PODS_READY=$(($MON_PODS_READY+1)); } || \
                echo "Pod $MON_POD not ready, skipping..."
        else
            echo "Pod $MON_POD not found, skipping..."
        fi
    done
    if [[ ${MON_PODS_READY} == ${MON_PODS_NUM} ]]; then
        echo "Monitor pods are ready. Moving on."
        break;
    fi
done

echo "=========== CEPH K8S PODS LIST ============"
kubectl get pods -n rook-ceph -o wide
kubectl get pods -n ceph -o wide
#NOTE: Wait for deploy
RGW_POD=$(kubectl get pods \
  --namespace=ceph \
  --selector="app=rook-ceph-rgw" \
  --no-headers | awk '{print $1; exit}')
wait_start_time=$(date +%s)
while [[ -z "${RGW_POD}" && $(($(date +%s) - $wait_start_time)) -lt 1800 ]]
do
  sleep 30
  date +'%Y-%m-%d %H:%M:%S'
  TOOLS_POD=$(kubectl get pods \
    --namespace=ceph \
    --selector="app=rook-ceph-tools" \
    --no-headers | grep Running | awk '{ print $1; exit }')
  if [[ -z "${TOOLS_POD}" ]]; then
    echo "No running rook-ceph-tools pod found. Waiting..."
    continue
  fi
  echo "=========== CEPH STATUS ============"
  kubectl exec -n ceph ${TOOLS_POD} -- ceph -s || echo "Could not get cluster status. Might be a temporary network issue."
  echo "=========== CEPH OSD POOL LIST ============"
  kubectl exec -n ceph ${TOOLS_POD} -- ceph osd pool ls || echo "Could not get list of pools. Might be a temporary network issue."
  echo "=========== CEPH K8S PODS LIST ============"
  kubectl get pods -n ceph -o wide
  RGW_POD=$(kubectl get pods \
    --namespace=ceph \
    --selector="app=rook-ceph-rgw" \
    --no-headers | awk '{print $1; exit}')
done
helm osh wait-for-pods ceph

#NOTE: Validate deploy
TOOLS_POD=$(kubectl get pods \
    --namespace=ceph \
    --selector="app=rook-ceph-tools" \
    --no-headers | grep Running | awk '{ print $1; exit }')
kubectl exec -n ceph ${TOOLS_POD} -- ceph -s
