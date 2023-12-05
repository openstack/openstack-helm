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

CEPH_RBD_KEY=$(kubectl get secret ${PVC_CEPH_RBD_STORAGECLASS_ADMIN_SECRET_NAME} \
    --namespace=${PVC_CEPH_RBD_STORAGECLASS_DEPLOYED_NAMESPACE} \
    -o json )

# CONNECT_TO_ROOK_CEPH_CLUSTER is unset by default
if [[ ${CONNECT_TO_ROOK_CEPH_CLUSTER} == "true" ]] ; then
  CEPH_CLUSTER_KEY=$(echo "${CEPH_RBD_KEY}" | jq -r '.data["ceph-secret"]')
else
  CEPH_CLUSTER_KEY=$(echo "${CEPH_RBD_KEY}" | jq -r '.data.key')
fi

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
{{ tuple $envAll "ceph" "rbd" | include "helm-toolkit.snippets.kubernetes_metadata_labels" | indent 4 }}
type: "${secret_type}"
data:
  key: $( echo ${ceph_key} )
EOF
  } | kubectl apply --namespace ${kube_namespace} -f -
}

ceph_activate_namespace ${DEPLOYMENT_NAMESPACE} "kubernetes.io/rbd" ${PVC_CEPH_RBD_STORAGECLASS_USER_SECRET_NAME} "${CEPH_CLUSTER_KEY}"
