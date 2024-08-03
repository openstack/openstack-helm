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

create_data_view() {
  local index_name=$1
  curl -u "${ELASTICSEARCH_USERNAME}:${ELASTICSEARCH_PASSWORD}" \
    --max-time 30 \
    -X POST "${KIBANA_ENDPOINT}/api/data_views/data_view" \
    -H "kbn-xsrf: true" \
    -H "Content-Type: application/json" \
    -d "{
      \"data_view\": {
        \"title\": \"${index_name}-*\",
        \"timeFieldName\": \"@timestamp\"
      }
    }"
}

data_view_exists() {
  local index_name=$1
  local response=$(curl -s -u "${ELASTICSEARCH_USERNAME}:${ELASTICSEARCH_PASSWORD}" \
    --max-time 30 \
    -X GET "${KIBANA_ENDPOINT}/api/data_views" \
    -H "kbn-xsrf: true" \
    -H "Content-Type: application/json")

  if echo "$response" | grep -q "\"title\":\"${index_name}-[*]\""; then
    return 0
  fi
  return 1
}

set_default_data_view() {
  local index_name=$1
  curl -u "${ELASTICSEARCH_USERNAME}:${ELASTICSEARCH_PASSWORD}" \
    --max-time 30 \
    -X POST "${KIBANA_ENDPOINT}/api/data_views/default" \
    -H "kbn-xsrf: true" \
    -H "Content-Type: application/json" \
    -d "{
      \"value\": \"${index_name}-*\"
    }"
}

# Create data views
{{- range $objectType, $indices := .Values.conf.create_kibana_indexes.indexes }}
{{- range $indices }}
if ! data_view_exists "{{ . }}"; then
  create_data_view "{{ . }}"
  echo "Data view '{{ . }}' created successfully."
else
  echo "Data view '{{ . }}' already exists."
fi
{{- end }}
{{- end }}

# Ensure default data view exists and set it
default_index="{{ .Values.conf.create_kibana_indexes.default_index }}"
if ! data_view_exists "$default_index"; then
  create_data_view "$default_index"
  echo "Default data view '${default_index}' created successfully."
fi

set_default_data_view "$default_index"
echo "Default data view set to '${default_index}'."
