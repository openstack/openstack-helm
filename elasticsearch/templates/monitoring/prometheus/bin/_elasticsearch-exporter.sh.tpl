#!/bin/sh

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

COMMAND="${@:-start}"

function start () {
  exec /bin/elasticsearch_exporter \
        -es.uri=$ELASTICSEARCH_URI \
        -es.all={{ .Values.conf.prometheus_elasticsearch_exporter.es.all | quote }} \
        -es.timeout={{ .Values.conf.prometheus_elasticsearch_exporter.es.timeout }} \
        -web.telemetry-path={{ .Values.endpoints.prometheus_elasticsearch_exporter.path.default }}
}

function stop () {
  kill -TERM 1
}

$COMMAND
