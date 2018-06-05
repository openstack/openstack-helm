#!/bin/bash

set -ex

{{ range $template, $fields := .Values.conf.templates }}

result=$(curl -K- <<< "--user ${ELASTICSEARCH_USERNAME}:${ELASTICSEARCH_PASSWORD}" \
-XPUT "${ELASTICSEARCH_HOST}:${ELASTICSEARCH_PORT}/_template/{{$template}}" \
-H 'Content-Type: application/json' -d @/tmp/{{$template}}.json \
| python -c "import sys, json; print json.load(sys.stdin)['acknowledged']")
if [ "$result" == "True" ]; then
   echo "{{$template}} template created!"
else
   echo "{{$template}} template not created!"
fi

{{ end }}
