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

PODS=$(kubectl get pods --namespace=${NAMESPACE} \
  --selector=application=ceph,component=osd --field-selector=status.phase=Running \
  '--output=jsonpath={range .items[*]}{.metadata.name}{"\n"}{end}')

for POD in ${PODS}; do
  kubectl exec -t ${POD} --namespace=${NAMESPACE} -- \
  sh -c -e "/tmp/utils-defragOSDs.sh"
done


exit 0
