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

{{ include "ceph-client.snippets.mon_host_from_k8s_ep" . }}

ENDPOINT=$(mon_host_from_k8s_ep "${DEPLOYMENT_NAMESPACE}" ceph-mon-discovery)

if [[ -z "${ENDPOINT}" ]]; then
  echo "Ceph Mon endpoint is empty"
  exit 1
else
  echo "${ENDPOINT}"
fi

# Update the ceph-client-etc configmap
kubectl get cm "${CEPH_CONF_ETC}" -n "${DEPLOYMENT_NAMESPACE}" -o json |
  jq '.data."ceph.conf" |= sub("mon_host = .*";"mon_host = '"${ENDPOINT}"'")' |
  kubectl apply -n "${DEPLOYMENT_NAMESPACE}" -f -

kubectl get cm "${CEPH_CONF_ETC}" -n "${DEPLOYMENT_NAMESPACE}" -o yaml
