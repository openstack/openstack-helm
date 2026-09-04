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

function create_kube_key () {
  CEPH_KEYRING=$1
  CEPH_KEYRING_NAME=$2
  CEPH_KEYRING_TEMPLATE=$3
  KUBE_SECRET_NAME=$4
  local desired_value="$( kube_ceph_keyring_gen ${CEPH_KEYRING} ${CEPH_KEYRING_TEMPLATE} )"
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
{{ tuple $envAll "ceph" "bootstrap" | include "helm-toolkit.snippets.kubernetes_metadata_labels" | indent 4 }}
type: Opaque
data:
  ${CEPH_KEYRING_NAME}: ${desired_value}
EOF
  } | kubectl apply --namespace ${DEPLOYMENT_NAMESPACE} -f -
}

# Retained monitor/bootstrap credentials must survive a Helm reinstall too.
# The post-apply job reconciles their key types against the running cluster.
# Only NotFound permits generation; API errors or invalid keyrings fail closed.
existing_secret=$(kubectl --namespace "${DEPLOYMENT_NAMESPACE}" get secret \
  "${KUBE_SECRET_NAME}" --ignore-not-found -o name)
if [[ -n "${existing_secret}" ]]; then
  secret_data_key="${CEPH_KEYRING_NAME//./\\.}"
  existing_value=$(kubectl --namespace "${DEPLOYMENT_NAMESPACE}" get secret \
    "${KUBE_SECRET_NAME}" -o "jsonpath={.data.${secret_data_key}}")
  if [[ -z "${existing_value}" ]]; then
    echo "ERROR- existing Secret has no ${CEPH_KEYRING_NAME}; refusing to replace it" >&2
    exit 1
  fi
  existing_keyring=$(mktemp)
  if ! printf '%s' "${existing_value}" | base64 -d > "${existing_keyring}"; then
    rm -f "${existing_keyring}"
    echo "ERROR- unable to decode the existing keyring; refusing to replace it" >&2
    exit 1
  fi
  if [[ -n "$(tail -c 1 "${existing_keyring}")" ]]; then
    printf '\n' >> "${existing_keyring}"
  fi
  if ! ceph-authtool "${existing_keyring}" --list >/dev/null; then
    rm -f "${existing_keyring}"
    echo "ERROR- existing keyring is invalid; refusing to replace it" >&2
    exit 1
  fi
  rm -f "${existing_keyring}"
  exit 0
fi

#create_kube_key <ceph_key> <ceph_keyring_name> <ceph_keyring_template> <kube_secret_name>
create_kube_key $(ceph_gen_key) ${CEPH_KEYRING_NAME} ${CEPH_KEYRING_TEMPLATE} ${KUBE_SECRET_NAME}

{{ else }}

echo "Not touching ${KUBE_SECRET_NAME} as this is not the initial deployment"

{{- end -}}
