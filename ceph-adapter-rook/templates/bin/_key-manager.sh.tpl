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

MAX_RETRIES=$((30*60/5))
RETRY=0
while true; do
  # We expect rook-ceph-tools pod to be up and running
  if ROOK_CEPH_TOOLS_POD=$(kubectl -n ${CEPH_CLUSTER_NAMESPACE} get pods --no-headers | awk '/rook-ceph-tools/{print $1}' | head -n 1) && [ -n "${ROOK_CEPH_TOOLS_POD}" ]; then
    if CEPH_ADMIN_KEY=$(kubectl -n ${CEPH_CLUSTER_NAMESPACE} exec ${ROOK_CEPH_TOOLS_POD} -- ceph auth ls 2>/dev/null | grep -A1 "client.admin" | awk '/key:/{print $2}') && [ -n "${CEPH_ADMIN_KEY}" ]; then
      break
    fi
  fi

  RETRY=$((RETRY+1))
  if [ "${RETRY}" -ge "${MAX_RETRIES}" ]; then
    echo "Error: Ceph admin key not found after 30 minutes" >&2
    exit 1
  fi
  echo "Waiting for Ceph admin key..." >&2
  sleep 5
done

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
  key: $( echo ${ceph_key} | base64 | tr -d '\n' )
EOF
  } | kubectl apply --namespace ${kube_namespace} -f -
}

ceph_activate_namespace ${DEPLOYMENT_NAMESPACE} "kubernetes.io/rbd" ${SECRET_NAME} "${CEPH_ADMIN_KEY}"
