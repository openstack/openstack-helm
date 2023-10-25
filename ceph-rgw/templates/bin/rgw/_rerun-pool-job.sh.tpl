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

# Get the Ceph cluster namespace, assuming "ceph" if not defined
{{- if empty .Values.endpoints.ceph_mon.namespace -}}
CEPH_NS=ceph
{{ else }}
CEPH_NS={{ .Values.endpoints.ceph_mon.namespace }}
{{- end }}

# If the ceph-rbd pool job exists, delete it and re-create it
# NOTE: This check is currently required to handle the Rook case properly.
#       Other charts still deploy ceph-rgw outside of Rook, and Rook does not
#       have a ceph-rbd-pool job to re-run.
if [[ -n "$(kubectl -n ${CEPH_NS} get jobs | grep ceph-rbd-pool)" ]]
then
  kubectl -n ${CEPH_NS} get job ceph-rbd-pool -o json > /tmp/ceph-rbd-pool.json
  kubectl -n ${CEPH_NS} delete job ceph-rbd-pool
  jq 'del(.spec.selector) |
      del(.spec.template.metadata.creationTimestamp) |
      del(.spec.template.metadata.labels) |
      del(.metadata.creationTimestamp) |
      del(.metadata.uid) |
      del(.status)' /tmp/ceph-rbd-pool.json | \
  kubectl create -f -

  while [[ -z "$(kubectl -n ${CEPH_NS} get pods | grep ceph-rbd-pool | grep Completed)" ]]
  do
    sleep 5
  done
fi
