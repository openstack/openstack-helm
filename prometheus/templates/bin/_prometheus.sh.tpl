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
    --config.file=/etc/config/prometheus.yml \
    --log.level={{ .Values.conf.prometheus.log.level | quote }} \
    --query.max-concurrency={{ .Values.conf.prometheus.query.max_concurrency }} \
    --storage.tsdb.path={{ .Values.conf.prometheus.storage.tsdb.path }} \
    --storage.tsdb.retention={{ .Values.conf.prometheus.storage.tsdb.retention }} \
    --storage.tsdb.min-block-duration={{ .Values.conf.prometheus.storage.tsdb.min_block_duration }} \
    --storage.tsdb.max-block-duration={{ .Values.conf.prometheus.storage.tsdb.max_block_duration }} \
    {{ if .Values.conf.prometheus.web_admin_api.enabled }}
    --web.enable-admin-api \
    {{ end }}
    --query.timeout={{ .Values.conf.prometheus.query.timeout }}
}

function stop () {
  kill -TERM 1
}

$COMMAND
