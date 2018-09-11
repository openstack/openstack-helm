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
COMMAND="${@:-start}"

function start () {
  exec neutron-server \
        --config-file /etc/neutron/neutron.conf \
        --config-file /etc/neutron/plugins/ml2/ml2_conf.ini
{{- if .Values.conf.plugins.taas.taas.enabled }} \
        --config-file /etc/neutron/taas_plugin.ini
{{- end }}
{{- if ( has "sriov" .Values.network.backend ) }} \
        --config-file /etc/neutron/plugins/ml2/sriov_agent.ini
{{- end }}
}

function stop () {
  kill -TERM 1
}

$COMMAND
