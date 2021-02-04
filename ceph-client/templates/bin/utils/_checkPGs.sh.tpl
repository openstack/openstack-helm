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

mgrPod=$(kubectl get pods --namespace=${DEPLOYMENT_NAMESPACE} --selector=application=ceph --selector=component=mgr --output=jsonpath={.items[0].metadata.name} 2>/dev/null)

kubectl exec -t ${mgrPod} --namespace=${DEPLOYMENT_NAMESPACE} -- python3 /tmp/utils-checkPGs.py All 2>/dev/null
