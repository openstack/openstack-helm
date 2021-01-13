#!/bin/bash

set -ex

{{ range $template, $fields := .Values.conf.templates }}

result=$(curl -K- <<< "--user ${ELASTICSEARCH_USERNAME}:${ELASTICSEARCH_PASSWORD}" \
-XPUT "${ELASTICSEARCH_HOST}:${ELASTICSEARCH_PORT}/_template/{{$template}}" \
-H 'Content-Type: application/json' -d @/tmp/{{$template}}.json \
| python -c "import sys, json; print(json.load(sys.stdin)['acknowledged'])")
if [ "$result" == "True" ]; then
   echo "{{$template}} template created!"
else
   echo "{{$template}} template not created!"
fi

{{ end }}

{{ range $policy_name, $fields := .Values.conf.snapshot_policies }}

result=$(curl -K- <<< "--user ${ELASTICSEARCH_USERNAME}:${ELASTICSEARCH_PASSWORD}" \
-XPUT "${ELASTICSEARCH_HOST}:${ELASTICSEARCH_PORT}/_slm/policy/{{$policy_name}}" \
-H 'Content-Type: application/json' -d @/tmp/{{$policy_name}}.json \
| python -c "import sys, json; print(json.load(sys.stdin)['acknowledged'])")
if [ "$result" == "True" ]; then
   echo "Policy {{$policy_name}} created!"
else
   echo "Policy {{$policy_name}} not created!"
fi

{{ end }}

{{ range $policy_name, $fields := .Values.conf.index_policies }}

result=$(curl -K- <<< "--user ${ELASTICSEARCH_USERNAME}:${ELASTICSEARCH_PASSWORD}" \
-XPUT "${ELASTICSEARCH_HOST}:${ELASTICSEARCH_PORT}/_ilm/policy/{{$policy_name}}" \
-H 'Content-Type: application/json' -d @/tmp/{{$policy_name}}.json \
| python -c "import sys, json; print(json.load(sys.stdin)['acknowledged'])")
if [ "$result" == "True" ]; then
   echo "Policy {{$policy_name}} created!"
else
   echo "Policy {{$policy_name}} not created!"
fi

{{ end }}