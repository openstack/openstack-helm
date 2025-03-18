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

set -xe

{{ include "helm-toolkit.snippets.mon_host_from_k8s_ep" . }}

{{- $rgwNameSpaces := "" }}
{{- $sep := "" }}
{{- range $_, $ns := .Values.endpoints.ceph_object_store.endpoint_namespaces }}
  {{- $rgwNameSpaces = printf "%s%s%s" $rgwNameSpaces $sep $ns }}
  {{- $sep = " " }}
{{- end }}

rgwNameSpaces={{- printf "\"%s\"" $rgwNameSpaces }}

function check_mon_dns {
  NS=${1}
  # RGWs and the rgw namespace could not exist. Let's check this and prevent this script from failing
  if [[ $(kubectl get ns ${NS} -o json | jq -r '.status.phase') == "Active" ]]; then
    DNS_CHECK=$(getent hosts ceph-mon | head -n1)
    PODS=$(kubectl get pods --namespace=${NS} --selector=application=ceph --field-selector=status.phase=Running \
          --output=jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' | grep -E 'ceph-mon|ceph-osd|ceph-mgr|ceph-mds|ceph-rgw')
    ENDPOINT=$(mon_host_from_k8s_ep "${NAMESPACE}" ceph-mon-discovery)

    if [[ ${PODS} == "" || "${ENDPOINT}" == "" ]]; then
      echo "Something went wrong, no PODS or ENDPOINTS are available!"
    elif [[ ${DNS_CHECK} == "" ]]; then
      for POD in ${PODS}; do
        kubectl exec -t ${POD} --namespace=${NS} -- \
        sh -c -e "/tmp/utils-checkDNS.sh "${ENDPOINT}""
      done
    else
      for POD in ${PODS}; do
        kubectl exec -t ${POD} --namespace=${NS} -- \
        sh -c -e "/tmp/utils-checkDNS.sh up"
      done
    fi
  else
    echo "The namespace ${NS} is not ready, yet"
  fi
}

function watch_mon_dns {
  while [ true ]; do
    echo "checking DNS health"
    for myNS in ${NAMESPACE} ${rgwNameSpaces}; do
      check_mon_dns ${myNS} || true
    done
    echo "sleep 300 sec"
    sleep 300
  done
}

watch_mon_dns

exit
