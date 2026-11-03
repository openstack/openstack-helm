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

# See: https://bugs.launchpad.net/neutron/+bug/2028442
mkdir -p /tmp/pod-shared
tee > /tmp/pod-shared/ovn.ini << EOF
[ovn]
{{- if .Values.endpoints.ovn_ovsdb_nb.statefulset }}
{{- $nb := tuple "ovn_ovsdb_nb" "internal" "ovsdb" . | include "helm-toolkit.endpoints.host_and_port_endpoint_uri_lookup" | splitList "," }}
ovn_nb_connection={{ coalesce .Values.conf.plugins.ml2_conf.ovn.ovn_nb_connection (printf "tcp:%s" (join ",tcp:" $nb)) }}
{{- else }}
ovn_nb_connection={{ coalesce .Values.conf.plugins.ml2_conf.ovn.ovn_nb_connection "tcp:$OVN_OVSDB_NB_SERVICE_HOST:$OVN_OVSDB_NB_SERVICE_PORT_OVSDB" }}
{{- end }}
{{- if .Values.endpoints.ovn_ovsdb_sb.statefulset }}
{{- $sb := tuple "ovn_ovsdb_sb" "internal" "ovsdb" . | include "helm-toolkit.endpoints.host_and_port_endpoint_uri_lookup" | splitList "," }}
ovn_sb_connection={{ coalesce .Values.conf.plugins.ml2_conf.ovn.ovn_sb_connection (printf "tcp:%s" (join ",tcp:" $sb)) }}
{{- else }}
ovn_sb_connection={{ coalesce .Values.conf.plugins.ml2_conf.ovn.ovn_sb_connection "tcp:$OVN_OVSDB_SB_SERVICE_HOST:$OVN_OVSDB_SB_SERVICE_PORT_OVSDB" }}
{{- end }}
EOF
