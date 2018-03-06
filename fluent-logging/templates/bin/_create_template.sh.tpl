#!/bin/bash

set -ex

sed 's/ ,//' /tmp/template.xml.raw > /tmp/template.xml
result=$(curl -K- <<< "--user ${ELASTICSEARCH_USERNAME}:${ELASTICSEARCH_PASSWORD}" \
-XPUT "${ELASTICSEARCH_HOST}:${ELASTICSEARCH_PORT}/_template/template_fluent_logging" \
-H 'Content-Type: application/json' -d @/tmp/template.xml \
| python -c "import sys, json; print json.load(sys.stdin)['acknowledged']")
if [ "$result" == "True" ]; then
   echo "template created!"
else
   echo "template not created!"
fi
