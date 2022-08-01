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

{{- range $objectType, $indices := .Values.conf.create_kibana_indexes.indexes }}
{{- range $indices }}
curl -K- <<< "--user ${ELASTICSEARCH_USERNAME}:${ELASTICSEARCH_PASSWORD}" \
  -XPOST "${KIBANA_ENDPOINT}/api/saved_objects/index-pattern/{{ . }}*" -H 'kbn-xsrf: true' \
  -H 'Content-Type: application/json' -d \
  '{"attributes":{"title":"{{ . }}-*","timeFieldName":"@timestamp"}}'
while true
do
if [[ $(curl -s -o /dev/null -K- <<< "--user ${ELASTICSEARCH_USERNAME}:${ELASTICSEARCH_PASSWORD}" \
  -w "%{http_code}" -XGET "${KIBANA_ENDPOINT}/api/saved_objects/index-pattern/{{ . }}*") == '200' ]]
then
break
else
curl -K- <<< "--user ${ELASTICSEARCH_USERNAME}:${ELASTICSEARCH_PASSWORD}" \
  -XPOST "${KIBANA_ENDPOINT}/api/saved_objects/index-pattern/{{ . }}*" -H 'kbn-xsrf: true' \
  -H 'Content-Type: application/json' -d \
  '{"attributes":{"title":"{{ . }}-*","timeFieldName":"@timestamp"}}'
sleep 30
fi
done
{{- end }}
{{- end }}

curl -K- <<< "--user ${ELASTICSEARCH_USERNAME}:${ELASTICSEARCH_PASSWORD}" \
  -XPOST "${KIBANA_ENDPOINT}/api/kibana/settings/defaultIndex" -H 'kbn-xsrf: true' \
  -H 'Content-Type: application/json' -d \
  '{"value" : "{{ .Values.conf.create_kibana_indexes.default_index }}*"}'
