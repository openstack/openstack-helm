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

ENDPOINTS=$(kubectl get endpoints ceph-mon-discovery -n ${DEPLOYMENT_NAMESPACE} -o json)
MON_IPS=$(jq -r '.subsets[0].addresses[].ip?' <<< ${ENDPOINTS})
V1_PORT=$(jq '.subsets[0].ports[] | select(.name == "mon") | .port' <<< ${ENDPOINTS})
V2_PORT=$(jq '.subsets[0].ports[] | select(.name == "mon-msgr2") | .port' <<< ${ENDPOINTS})
ENDPOINT=$(for ip in $MON_IPS; do printf '[v1:%s:%s/0,v2:%s:%s/0]\n' ${ip} ${V1_PORT} ${ip} ${V2_PORT}; done | paste -sd',')

if [[ -z "${V1_PORT}" ]] || [[ -z "${V2_PORT}" ]] || [[ -z "${ENDPOINT}" ]]; then
  echo "Ceph Mon endpoint is empty"
  exit 1
else
  echo ${ENDPOINT}
fi

kubectl get cm ${CEPH_CONF_ETC} -n  ${DEPLOYMENT_NAMESPACE}  -o yaml | \
  sed "s#mon_host.*#mon_host = ${ENDPOINT}#g" | \
  kubectl apply -f -

kubectl get cm ${CEPH_CONF_ETC} -n  ${DEPLOYMENT_NAMESPACE}  -o yaml
