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
set -o noglob

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

  if echo "$response" | grep -Fq "\"title\":\"${index_name}-*\""; then
    return 0
  fi
  return 1
}

set_default_data_view() {
  local view_id=$1
  curl -u "${ELASTICSEARCH_USERNAME}:${ELASTICSEARCH_PASSWORD}" \
    --max-time 30 \
    -X POST "${KIBANA_ENDPOINT}/api/data_views/default" \
    -H "kbn-xsrf: true" \
    -H "Content-Type: application/json" \
    -d "{
      \"data_view_id\": \"${view_id}\",
      \"force\": true
    }"
}

find_and_set_python() {
  pythons="python3 python python2"
  for p in ${pythons[@]}; do
    python=$(which ${p})
    if [[ $? -eq 0 ]]; then
      echo found python: ${python}
      break
    fi
  done
}

get_view_id() {
  local index_name=$1
  local response=$(curl -s -u "${ELASTICSEARCH_USERNAME}:${ELASTICSEARCH_PASSWORD}" \
    --max-time 30 \
    -X GET "${KIBANA_ENDPOINT}/api/data_views" \
    -H "kbn-xsrf: true" \
    -H "Content-Type: application/json" |
    $python -c "import sys,json; j=json.load(sys.stdin); t=[x['id'] for x in j['data_view'] if x['title'] == '${index_name}-*']; print(t[0] if len(t) else '')"
    )
  echo $response
}

# Create data views
{{- range $objectType, $indices := .Values.conf.create_kibana_indexes.indexes }}
{{- range $indices }}
while true; do
  create_data_view "{{ . }}"
  if data_view_exists "{{ . }}"; then
    echo "Data view '{{ . }}-*' exists"
    break
  else
    echo "Retrying creation of data view '{{ . }}-*' ..."
    create_data_view "{{ . }}"
    sleep 30
  fi
done

{{- end }}
{{- end }}

# Lookup default view id.  The new Kibana view API requires the id
# instead of simply the name like the previous index API did.
find_and_set_python

default_index="{{ .Values.conf.create_kibana_indexes.default_index }}"
default_index_id=$(get_view_id $default_index)

set_default_data_view "$default_index_id"
echo "Default data view set to '${default_index}'."
