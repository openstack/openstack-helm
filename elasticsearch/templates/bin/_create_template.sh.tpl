#!/bin/bash

set -ex

{{ range $object := .Values.conf.api_objects }}
curl -K- <<< "--user ${ELASTICSEARCH_USERNAME}:${ELASTICSEARCH_PASSWORD}" \
   -X{{ $object.method | default "PUT" | upper }} \
   "${ELASTICSEARCH_HOST}:${ELASTICSEARCH_PORT}/{{ $object.endpoint }}" \
   -H 'Content-Type: application/json' -d '{{ $object.body | toJson }}'
{{ end }}
