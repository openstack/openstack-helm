#!/bin/bash

# Copyright 2017 The Openstack-Helm Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

{{- if not .Values.ml2 -}}{{- set . "Values.ml2" dict -}}{{- end -}}
{{- if not .Values.ml2.ovs -}}{{- set . "Values.ml2.ovs" dict -}}{{- end -}}
{{- if not .Values.ml2.ovs.auto_bridge_add -}}{{- set . "Values.ml2.ovs.auto_bridge_add" dict -}}{{- end -}}

set -x

bridge=$1
port=$2

# note that only "br-ex" is definable right now
# and br-int and br-tun are assumed and handled
# by the agent
ovs-vsctl --no-wait --may-exist add-br $bridge
if [ $port] ; then
  ovs-vsctl --no-wait --may-exist add-port $bridge $port
  ip link set dev $port up
fi

# handle any bridge mappings
{{- range $bridge, $port := .Values.ml2.ovs.auto_bridge_add }}
ovs-vsctl --no-wait --may-exist add-br {{ $bridge }}
if [ {{  $port }} ] ; then
    ovs-vsctl --no-wait --may-exist add-port {{ $bridge }} {{ $port }}
    ip link set dev {{ $port }} up
fi
{{- end}}
