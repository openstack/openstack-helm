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


ENDPOINT=$(kubectl get endpoints ceph-mon-discovery -n ${PVC_CEPH_RBD_STORAGECLASS_DEPLOYED_NAMESPACE} -o json | awk -F'"' -v port=${MON_PORT} \
           -v version=v1 -v msgr_version=v2 \
           -v msgr2_port=${MON_PORT_V2} \
           '/"ip"/{print "["version":"$4":"port"/"0","msgr_version":"$4":"msgr2_port"/"0"]"}' | paste -sd',')

echo $ENDPOINT

kubectl get cm ${CEPH_CONF_ETC} -n  ${DEPLOYMENT_NAMESPACE}  -o yaml | \
  sed "s#mon_host.*#mon_host = ${ENDPOINT}#g" | \
  kubectl apply -f -

kubectl get cm ${CEPH_CONF_ETC} -n  ${DEPLOYMENT_NAMESPACE}  -o yaml
