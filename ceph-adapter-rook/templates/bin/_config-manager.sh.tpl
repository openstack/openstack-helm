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
  if RAW_ENDPOINTS=$(kubectl --namespace "${CEPH_CLUSTER_NAMESPACE}" get configmap rook-ceph-mon-endpoints -o jsonpath='{.data.data}' 2>/dev/null); then
    ENDPOINTS=$(echo "${RAW_ENDPOINTS}" | sed 's/.=//g')
    break
  fi
  RETRY=$((RETRY+1))
  if [ "${RETRY}" -ge "${MAX_RETRIES}" ]; then
    echo "Error: rook-ceph-mon-endpoints ConfigMap not found after 30 minutes" >&2
    exit 1
  fi
  sleep 5
done

kubectl get cm ${CEPH_CONF_ETC} -n  ${DEPLOYMENT_NAMESPACE}  -o yaml | \
  sed "s#mon_host.*#mon_host = ${ENDPOINTS}#g" | \
  kubectl apply -f -

kubectl get cm ${CEPH_CONF_ETC} -n  ${DEPLOYMENT_NAMESPACE}  -o yaml
