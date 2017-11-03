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

set -ex
COMMAND="${@:-start}"

function start () {
  exec /bin/prometheus \
    -config.file=/etc/config/prometheus.yml \
    -alertmanager.url={{ tuple "alerts" "internal" "api" . | include "helm-toolkit.endpoints.host_and_port_endpoint_uri_lookup" }} \
    -storage.local.path={{ .Values.conf.prometheus.storage.local.path }} \
    -storage.local.retention={{ .Values.conf.prometheus.storage.local.retention }} \
    -log.format={{ .Values.conf.prometheus.log.format | quote }} \
    -log.level={{ .Values.conf.prometheus.log.level | quote }} \
    -query.max-concurrency={{ .Values.conf.prometheus.query.max_concurrency }} \
    -query.timeout={{ .Values.conf.prometheus.query.timeout }}
}

function stop () {
  kill -TERM 1
}

$COMMAND
