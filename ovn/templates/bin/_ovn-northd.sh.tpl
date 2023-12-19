#!/bin/bash -xe

# Copyright 2023 VEXXHOST, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

COMMAND="${@:-start}"

{{- $nb_svc_name := "ovn-ovsdb-nb" -}}
{{- $nb_svc := (tuple $nb_svc_name "internal" . | include "helm-toolkit.endpoints.hostname_fqdn_endpoint_lookup") -}}
{{- $nb_port := (tuple "ovn-ovsdb-nb" "internal" "ovsdb" . | include "helm-toolkit.endpoints.endpoint_port_lookup") -}}
{{- $nb_service_list := list -}}
{{- range $i := until (.Values.pod.replicas.ovn_ovsdb_nb | int) -}}
  {{- $nb_service_list = printf "tcp:%s-%d.%s:%s" $nb_svc_name $i $nb_svc $nb_port | append $nb_service_list -}}
{{- end -}}

{{- $sb_svc_name := "ovn-ovsdb-sb" -}}
{{- $sb_svc := (tuple $sb_svc_name "internal" . | include "helm-toolkit.endpoints.hostname_fqdn_endpoint_lookup") -}}
{{- $sb_port := (tuple "ovn-ovsdb-sb" "internal" "ovsdb" . | include "helm-toolkit.endpoints.endpoint_port_lookup") -}}
{{- $sb_service_list := list -}}
{{- range $i := until (.Values.pod.replicas.ovn_ovsdb_sb | int) -}}
  {{- $sb_service_list = printf "tcp:%s-%d.%s:%s" $sb_svc_name $i $sb_svc $sb_port | append $sb_service_list -}}
{{- end }}

function start () {
  /usr/share/ovn/scripts/ovn-ctl start_northd \
    --ovn-manage-ovsdb=no \
    --ovn-northd-nb-db={{ include "helm-toolkit.utils.joinListWithComma" $nb_service_list }} \
    --ovn-northd-sb-db={{ include "helm-toolkit.utils.joinListWithComma" $sb_service_list }}

  tail --follow=name /var/log/ovn/ovn-northd.log
}

function stop () {
  /usr/share/ovn/scripts/ovn-ctl stop_northd
  pkill tail
}

function liveness () {
  ovs-appctl -t /var/run/ovn/ovn-northd.$(cat /var/run/ovn/ovn-northd.pid).ctl status
}

function readiness () {
  ovs-appctl -t /var/run/ovn/ovn-northd.$(cat /var/run/ovn/ovn-northd.pid).ctl status
}

$COMMAND
