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

{{- if .Values.manifests.wait_for_kibana_pods_readiness }}
echo "Waiting for all Kibana pods to become Ready"
count=1
# Wait up to 30 minutes for all Kibana pods to become Ready.  This does not necessarily mean
# Kibana pods will take up to 30 minutes to come up.  This script will wait up to 30 minutes
# instead of going into an infinite loop to wait.  This timed out value should be reduced once
# Kibana startup is enhanced.
while [[ $(kubectl get pods -n {{ .Release.Namespace }} -l application=kibana,component=dashboard -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') =~ "False" ]]; do
  sleep 30
  if [[ $count -eq 60 ]]; then
    echo "Timed out waiting for all Kibana pods to become Ready, proceed to create index patterns."
    break
  fi
  ((count++))
done
{{- end }}

{{- range $objectType, $indices := .Values.conf.create_kibana_indexes.indexes }}
{{- range $indices }}
curl -K- <<< "--user ${ELASTICSEARCH_USERNAME}:${ELASTICSEARCH_PASSWORD}" \
  -XPOST "${KIBANA_ENDPOINT}/api/saved_objects/index-pattern/{{ . }}*" -H 'kbn-xsrf: true' \
  -H 'Content-Type: application/json' -d \
  '{"attributes":{"title":"{{ . }}-*","timeFieldName":"@timestamp"}}'
{{- end }}
{{- end }}

curl -K- <<< "--user ${ELASTICSEARCH_USERNAME}:${ELASTICSEARCH_PASSWORD}" \
  -XPOST "${KIBANA_ENDPOINT}/api/kibana/settings/defaultIndex" -H 'kbn-xsrf: true' \
  -H 'Content-Type: application/json' -d \
  '{"value" : "{{ .Values.conf.create_kibana_indexes.default_index }}*"}'
