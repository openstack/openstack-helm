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
{{ if .Release.IsInstall }}
{{- $envAll := . }}

function ceph_gen_key () {
  ceph-authtool \
    --gen-print-key
}

function kube_ceph_keyring_gen () {
  CEPH_KEY=$1
  CEPH_KEY_TEMPLATE=$2
  sed "s|{{"{{"}} key {{"}}"}}|${CEPH_KEY}|" ${CEPH_TEMPLATES_DIR}/${CEPH_KEY_TEMPLATE} | base64 -w0 | tr -d '\n'
}

CEPH_CLIENT_KEY=""
CEPH_CLIENT_KEYRING=""
# A reinstall is an install to Helm, but the job-created Secrets can outlive
# the release. Reuse the retained credential before considering a new key;
# key-type changes remain the responsibility of the rotation jobs.
# --ignore-not-found suppresses only NotFound: API/RBAC errors must not cause
# us to generate and publish a replacement credential.
EXISTING_ADMIN_SECRET=$(kubectl --namespace "${DEPLOYMENT_NAMESPACE}" get secret \
  "${CEPH_KEYRING_ADMIN_NAME}" --ignore-not-found -o name)
if [[ -n "${EXISTING_ADMIN_SECRET}" ]]; then
  secret_data_key="${CEPH_KEYRING_NAME//./\\.}"
  CEPH_CLIENT_KEYRING=$(kubectl --namespace "${DEPLOYMENT_NAMESPACE}" get secret \
    "${CEPH_KEYRING_ADMIN_NAME}" -o "jsonpath={.data.${secret_data_key}}")
  if [[ -z "${CEPH_CLIENT_KEYRING}" ]]; then
    echo "ERROR- existing admin Secret has no ${CEPH_KEYRING_NAME}; refusing to replace it" >&2
    exit 1
  fi
  existing_keyring=$(mktemp)
  if ! printf '%s' "${CEPH_CLIENT_KEYRING}" | base64 -d > "${existing_keyring}"; then
    rm -f "${existing_keyring}"
    echo "ERROR- unable to decode the existing admin keyring; refusing to replace it" >&2
    exit 1
  fi
  # ceph-authtool requires a final newline; do not change the stored keyring.
  if [[ -n "$(tail -c 1 "${existing_keyring}")" ]]; then
    printf '\n' >> "${existing_keyring}"
  fi
  if ! CEPH_CLIENT_KEY=$(ceph-authtool "${existing_keyring}" --name client.admin --print-key) || \
      [[ -z "${CEPH_CLIENT_KEY}" ]]; then
    rm -f "${existing_keyring}"
    echo "ERROR- existing admin keyring is invalid; refusing to replace it" >&2
    exit 1
  fi
  rm -f "${existing_keyring}"
fi

if [[ -z "${CEPH_CLIENT_KEY}" ]]; then
  ROOK_CEPH_TOOLS_POD=$(kubectl -n ${DEPLOYMENT_NAMESPACE} get pods --no-headers | awk '/rook-ceph-tools/{print $1}')
  if [[ -n "${ROOK_CEPH_TOOLS_POD}" ]]; then
    CEPH_AUTH_KEY_NAME=$(echo "${CEPH_KEYRING_NAME}" | awk -F. '{print $2 "." $3}')
    CEPH_CLIENT_KEY=$(kubectl -n ${DEPLOYMENT_NAMESPACE} exec ${ROOK_CEPH_TOOLS_POD} -- ceph auth ls | grep -A1 "${CEPH_AUTH_KEY_NAME}" | awk '/key:/{print $2}')
  fi
fi

if [[ -z "${CEPH_CLIENT_KEY}" ]]; then
  CEPH_CLIENT_KEY=$(ceph_gen_key)
fi

function create_kube_key () {
  CEPH_KEYRING=$1
  CEPH_KEYRING_NAME=$2
  CEPH_KEYRING_TEMPLATE=$3
  KUBE_SECRET_NAME=$4
  # Keep the retained keyring byte-for-byte, including its caps and formatting.
  local desired_value="${CEPH_CLIENT_KEYRING}"
  if [[ -z "${desired_value}" ]]; then
    desired_value=$( kube_ceph_keyring_gen ${CEPH_KEYRING} ${CEPH_KEYRING_TEMPLATE} )
  fi
  local secret_data_key="${CEPH_KEYRING_NAME//./\\.}"
  local current_value=""

  if kubectl get --namespace ${DEPLOYMENT_NAMESPACE} secret ${KUBE_SECRET_NAME} >/dev/null 2>&1; then
    current_value=$(kubectl --namespace ${DEPLOYMENT_NAMESPACE} get secret ${KUBE_SECRET_NAME} \
      -o "jsonpath={.data.${secret_data_key}}" 2>/dev/null || true)
    if [[ -n "${current_value}" && "${current_value}" == "${desired_value}" ]]; then
      return 0
    fi
    kubectl --namespace ${DEPLOYMENT_NAMESPACE} patch secret ${KUBE_SECRET_NAME} \
      --type merge \
      -p "{\"data\":{\"${CEPH_KEYRING_NAME}\":\"${desired_value}\"}}"
    return 0
  fi

  {
    cat <<EOF
---
apiVersion: v1
kind: Secret
metadata:
  name: ${KUBE_SECRET_NAME}
  labels:
{{ tuple $envAll "ceph" "admin" | include "helm-toolkit.snippets.kubernetes_metadata_labels" | indent 4 }}
type: Opaque
data:
  ${CEPH_KEYRING_NAME}: ${desired_value}
EOF
  } | kubectl apply --namespace ${DEPLOYMENT_NAMESPACE} -f -
}
create_kube_key ${CEPH_CLIENT_KEY} ${CEPH_KEYRING_NAME} ${CEPH_KEYRING_TEMPLATE} ${CEPH_KEYRING_ADMIN_NAME}

function create_kube_storage_key () {
  CEPH_KEYRING=$1
  KUBE_SECRET_NAME=$2
  local desired_key="$( echo ${CEPH_KEYRING} | base64 | tr -d '\n' )"
  local desired_user_id="$( echo -n "admin" | base64 | tr -d '\n' )"
  local desired_user_key="$( echo -n ${CEPH_KEYRING} | base64 | tr -d '\n' )"
  local current_key="" current_user_id="" current_user_key=""

  if kubectl get --namespace ${DEPLOYMENT_NAMESPACE} secret ${KUBE_SECRET_NAME} >/dev/null 2>&1; then
    current_key=$(kubectl --namespace ${DEPLOYMENT_NAMESPACE} get secret ${KUBE_SECRET_NAME} -o 'jsonpath={.data.key}' 2>/dev/null || true)
    current_user_id=$(kubectl --namespace ${DEPLOYMENT_NAMESPACE} get secret ${KUBE_SECRET_NAME} -o 'jsonpath={.data.userID}' 2>/dev/null || true)
    current_user_key=$(kubectl --namespace ${DEPLOYMENT_NAMESPACE} get secret ${KUBE_SECRET_NAME} -o 'jsonpath={.data.userKey}' 2>/dev/null || true)
    if [[ "${current_key}" == "${desired_key}" && "${current_user_id}" == "${desired_user_id}" && "${current_user_key}" == "${desired_user_key}" ]]; then
      return 0
    fi
    kubectl --namespace ${DEPLOYMENT_NAMESPACE} patch secret ${KUBE_SECRET_NAME} \
      --type merge \
      -p "{\"data\":{\"key\":\"${desired_key}\",\"userID\":\"${desired_user_id}\",\"userKey\":\"${desired_user_key}\"}}"
    return 0
  fi

  {
    cat <<EOF
---
apiVersion: v1
kind: Secret
metadata:
  name: ${KUBE_SECRET_NAME}
  labels:
{{ tuple $envAll "ceph" "admin" | include "helm-toolkit.snippets.kubernetes_metadata_labels" | indent 4 }}
type: kubernetes.io/rbd
data:
  key: ${desired_key}
  userID: ${desired_user_id}
  userKey: ${desired_user_key}
EOF
  } | kubectl apply --namespace ${DEPLOYMENT_NAMESPACE} -f -
}
#create_kube_storage_key <ceph_key> <kube_secret_name>
create_kube_storage_key ${CEPH_CLIENT_KEY} ${CEPH_STORAGECLASS_ADMIN_SECRET_NAME}
create_kube_storage_key ${CEPH_CLIENT_KEY} ${CEPH_STORAGECLASS_ADMIN_SECRET_NAME_NODE}

{{ else }}

echo "Not touching ${KUBE_SECRET_NAME} as this is not the initial deployment"

{{ end }}
