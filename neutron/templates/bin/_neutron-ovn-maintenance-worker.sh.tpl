#!/bin/bash

{{/*
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
  exec neutron-ovn-maintenance-worker \
        --config-file /etc/neutron/neutron.conf \
        --config-file /tmp/pod-shared/ovn.ini \
{{- if contains "vpnaas" .Values.conf.neutron.DEFAULT.service_plugins }}
        --config-file /etc/neutron/neutron_vpnaas.conf \
{{- end }}
{{- if contains "ovn-vpnaas" .Values.conf.neutron.DEFAULT.service_plugins }}
        --config-file /etc/neutron/neutron_ovn_vpn_agent.ini \
{{- end }}
{{- if .Values.conf.plugins.taas.taas.enabled }}
        --config-file /etc/neutron/taas_plugin.ini \
{{- end }}
{{- if ( has "sriov" .Values.network.backend ) }}
        --config-file /etc/neutron/plugins/ml2/sriov_agent.ini \
{{- end }}
{{- if .Values.conf.plugins.l2gateway }}
        --config-file /etc/neutron/l2gw_plugin.ini \
{{- end }}
        --config-file /etc/neutron/plugins/ml2/ml2_conf.ini \
        --config-dir /etc/neutron/neutron.conf.d
}

function stop () {
  kill -TERM 1
}

$COMMAND
