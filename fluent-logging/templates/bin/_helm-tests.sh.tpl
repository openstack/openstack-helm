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

# Test whether indexes have been created for each Elasticsearch output defined
function check_output_indexes_exist () {
  {{/*
    First, determine the sum of Fluentbit and Fluentd's flush intervals. This
    ensures we wait long enough for recorded events to be indexed
  */}}
  {{ $fluentBitConf := first .Values.conf.fluentbit }}
  {{ $fluentBitServiceConf := index $fluentBitConf "service" }}
  {{ $fluentBitFlush := index $fluentBitServiceConf "Flush" }}
  fluentBitFlush={{$fluentBitFlush}}

  {{/*
    The generic Elasticsearch output should always be last, and intervals for all
    Elasticsearch outputs should match. This means we can safely use the last item
    in fluentd's configuration to get the Fluentd flush output interval
  */}}
  {{- $fluentdConf := last .Values.conf.fluentd -}}
  {{- $fluentdElasticsearchConf := index $fluentdConf "elasticsearch" -}}
  {{- $fluentdFlush := index $fluentdElasticsearchConf "flush_interval" -}}
  fluentdFlush={{$fluentdFlush}}

  totalFlush=$(($fluentBitFlush + $fluentdFlush))
  sleep $totalFlush

  {{/*
    Iterate over Fluentd's config and for each Elasticsearch output, determine
    the logstash index prefix and check Elasticsearch for that index
  */}}
  {{ range $key, $config := .Values.conf.td_agent -}}

  {{/* Get list of keys to determine config header to index on */}}
  {{- $keyList := keys $config -}}
  {{- $configSection := first $keyList -}}

  {{/* Index config section dictionary */}}
  {{- $configEntry := index $config $configSection -}}

  {{- if hasKey $configEntry "type" -}}
  {{- $type := index $configEntry "type" -}}
  {{- if eq $type "elasticsearch" -}}
  {{- if hasKey $configEntry "logstash_prefix" -}}
  {{- $logstashPrefix := index $configEntry "logstash_prefix" }}
  {{$logstashPrefix}}_total_hits=$(curl -K- <<< "--user ${ELASTICSEARCH_USERNAME}:${ELASTICSEARCH_PASSWORD}" \
              -XGET "${ELASTICSEARCH_ENDPOINT}/{{$logstashPrefix}}-*/_search?pretty" -H 'Content-Type: application/json' \
              | python -c "import sys, json; print json.load(sys.stdin)['hits']['total']")
  if [ "${{$logstashPrefix}}_total_hits" -gt 0 ]; then
     echo "PASS: Successful hits on {{$logstashPrefix}}-* index!"
  else
     echo "FAIL: No hits on query for {{$logstashPrefix}}-* index! Exiting";
     exit 1;
  fi
  {{ else }}
  logstash_total_hits=$(curl -K- <<< "--user ${ELASTICSEARCH_USERNAME}:${ELASTICSEARCH_PASSWORD}" \
              -XGET "${ELASTICSEARCH_ENDPOINT}/logstash-*/_search?pretty" -H 'Content-Type: application/json' \
              | python -c "import sys, json; print json.load(sys.stdin)['hits']['total']")
  if [ "$logstash_total_hits" -gt 0 ]; then
     echo "PASS: Successful hits on logstash-* index!"
  else
     echo "FAIL: No hits on query for logstash-* index! Exiting";
     exit 1;
  fi
  {{ end }}
  {{- end }}
  {{- end }}
  {{- end -}}
}

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
check_output_indexes_exist
