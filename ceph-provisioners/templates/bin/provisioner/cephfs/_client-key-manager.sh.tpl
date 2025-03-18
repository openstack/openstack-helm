#!/bin/bash

{{/*
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/}}

set -ex
{{- $envAll := . }}

CEPH_CEPHFS_KEY=$(kubectl get secret ${PVC_CEPH_CEPHFS_STORAGECLASS_ADMIN_SECRET_NAME} \
    --namespace=${PVC_CEPH_CEPHFS_STORAGECLASS_DEPLOYED_NAMESPACE} \
    -o json )

ceph_activate_namespace() {
  kube_namespace=$1
  secret_type=$2
  secret_name=$3
  ceph_key=$4
  {
  cat <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: "${secret_name}"
  labels:
{{ tuple $envAll "ceph" "cephfs" | include "helm-toolkit.snippets.kubernetes_metadata_labels" | indent 4 }}
type: "${secret_type}"
data:
  key: $( echo ${ceph_key} )
EOF
  } | kubectl apply --namespace ${kube_namespace} -f -
}

if ! kubectl get --namespace ${DEPLOYMENT_NAMESPACE} secrets ${PVC_CEPH_CEPHFS_STORAGECLASS_USER_SECRET_NAME}; then
  ceph_activate_namespace \
    ${DEPLOYMENT_NAMESPACE} \
    "kubernetes.io/cephfs" \
    ${PVC_CEPH_CEPHFS_STORAGECLASS_USER_SECRET_NAME} \
    "$(echo ${CEPH_CEPHFS_KEY} | jq -r '.data.key')"
fi
