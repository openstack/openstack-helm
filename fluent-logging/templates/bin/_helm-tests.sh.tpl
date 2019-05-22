#!/bin/bash

{{/*
Copyright 2017 The Openstack-Helm Authors.

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

{{ if and (.Values.manifests.job_elasticsearch_template) (not (empty .Values.conf.templates)) }}
# Tests whether fluent-logging has successfully generated the elasticsearch index mapping
# templates defined by values.yaml
function check_templates () {
  {{ range $template, $fields := .Values.conf.templates }}
  {{$template}}_total_hits=$(curl -K- <<< "--user ${ELASTICSEARCH_USERNAME}:${ELASTICSEARCH_PASSWORD}" \
              -XGET "${ELASTICSEARCH_ENDPOINT}/_template/{{$template}}" -H 'Content-Type: application/json' \
              | python -c "import sys, json; print len(json.load(sys.stdin))")
  if [ "${{$template}}_total_hits" -gt 0 ]; then
     echo "PASS: Successful hits on {{$template}} template, provided by fluent-logging!"
  else
     echo "FAIL: No hits on query for {{$template}} template! Exiting";
     exit 1;
  fi
  {{ end }}
}
{{ end }}

{{ if and (.Values.manifests.job_elasticsearch_template) (not (empty .Values.conf.templates)) }}
check_templates
{{ end }}
