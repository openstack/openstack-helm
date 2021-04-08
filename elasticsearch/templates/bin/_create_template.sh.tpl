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

set -e

NUM_ERRORS=0

{{ range $name, $object := .Values.conf.api_objects }}
{{ if not (empty $object) }}

echo "creating {{$name}}"
error=$(curl ${CACERT_OPTION} -K- <<< "--user ${ELASTICSEARCH_USERNAME}:${ELASTICSEARCH_PASSWORD}" \
   -X{{ $object.method | default "PUT" | upper }} \
   "${ELASTICSEARCH_ENDPOINT}/{{ $object.endpoint }}" \
   -H 'Content-Type: application/json' -d '{{ $object.body | toJson }}' | jq -r '.error')

if [ $error == "null" ]; then
   echo "Object {{$name}} was created."
else
   echo "Error when creating object {{$name}}: $(echo $error | jq -r)"
   NUM_ERRORS=$(($NUM_ERRORS+1))
fi

{{ end }}
{{ end }}

if [ $NUM_ERRORS -gt 0 ]; then
   exit 1
else
   echo "leaving normally"
fi
