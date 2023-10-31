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

set -e

OVS_PID=$(cat /run/openvswitch/ovs-vswitchd.pid)
OVS_CTL=/run/openvswitch/ovs-vswitchd.${OVS_PID}.ctl

ovs-vsctl list-br | grep -q br-int

[ -z "$(/usr/bin/ovs-vsctl show | grep error:)" ]

{{ if .Values.conf.ovs_dpdk.enabled }}
  {{- if hasKey .Values.conf.ovs_dpdk "nics"}}
    # Check if port(s) and bridge(s) are configured.
    {{- range .Values.conf.ovs_dpdk.nics }}
      ovs-vsctl list-br | grep -q {{ .bridge }}
      ovs-vsctl list-ports {{ .bridge }} | grep -q {{ .name }}
    {{- end }}
  {{- end }}

  {{- if hasKey .Values.conf.ovs_dpdk "bonds"}}
    # Check if bond(s) and slave(s) are configured.
    {{- range .Values.conf.ovs_dpdk.bonds }}
      bond={{ .name }}
      ovs-appctl -t ${OVS_CTL} bond/list | grep -q  ${bond}
      {{- range .nics }}
        ovs-appctl -t ${OVS_CTL} bond/show ${bond} | grep -q "slave {{ .name }}\|member {{ .name }}"
      {{- end }}
    {{- end }}
  {{- end }}
{{ end }}
