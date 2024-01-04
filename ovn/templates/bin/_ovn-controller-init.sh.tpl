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

function get_ip_address_from_interface {
  local interface=$1
  local ip=$(ip -4 -o addr s "${interface}" | awk '{ print $4; exit }' | awk -F '/' '{print $1}')
  if [ -z "${ip}" ] ; then
    exit 1
  fi
  echo ${ip}
}

# Detect tunnel interface
tunnel_interface="{{- .Values.network.interface.tunnel -}}"
if [ -z "${tunnel_interface}" ] ; then
    # search for interface with tunnel network routing
    tunnel_network_cidr="{{- .Values.network.interface.tunnel_network_cidr -}}"
    if [ -z "${tunnel_network_cidr}" ] ; then
        tunnel_network_cidr="0/0"
    fi
    # If there is not tunnel network gateway, exit
    tunnel_interface=$(ip -4 route list ${tunnel_network_cidr} | awk -F 'dev' '{ print $2; exit }' \
        | awk '{ print $1 }') || exit 1
fi
ovs-vsctl set open . external_ids:ovn-encap-ip="$(get_ip_address_from_interface ${tunnel_interface})"

# Configure system ID
set +e
ovs-vsctl get open . external-ids:system-id
if [ $? -eq 1 ]; then
  ovs-vsctl set open . external-ids:system-id="$(uuidgen)"
fi
set -e

# Configure OVN remote
{{- if empty .Values.conf.ovn_remote -}}
{{- $sb_svc_name := "ovn-ovsdb-sb" -}}
{{- $sb_svc := (tuple $sb_svc_name "internal" . | include "helm-toolkit.endpoints.hostname_fqdn_endpoint_lookup") -}}
{{- $sb_port := (tuple "ovn-ovsdb-sb" "internal" "ovsdb" . | include "helm-toolkit.endpoints.endpoint_port_lookup") -}}
{{- $sb_service_list := list -}}
{{- range $i := until (.Values.pod.replicas.ovn_ovsdb_sb | int) -}}
  {{- $sb_service_list = printf "tcp:%s-%d.%s:%s" $sb_svc_name $i $sb_svc $sb_port | append $sb_service_list -}}
{{- end }}

ovs-vsctl set open . external-ids:ovn-remote="{{ include "helm-toolkit.utils.joinListWithComma" $sb_service_list }}"
{{- else -}}
ovs-vsctl set open . external-ids:ovn-remote="{{ .Values.conf.ovn_remote }}"
{{- end }}

# Configure OVN values
ovs-vsctl set open . external-ids:rundir="/var/run/openvswitch"
ovs-vsctl set open . external-ids:ovn-encap-type="{{ .Values.conf.ovn_encap_type }}"
ovs-vsctl set open . external-ids:ovn-bridge="{{ .Values.conf.ovn_bridge }}"
ovs-vsctl set open . external-ids:ovn-bridge-mappings="{{ .Values.conf.ovn_bridge_mappings }}"
ovs-vsctl set open . external-ids:ovn-cms-options="{{ .Values.conf.ovn_cms_options }}"

# Configure hostname
{{- if .Values.pod.use_fqdn.compute }}
  ovs-vsctl set open . external-ids:hostname="$(hostname -f)"
{{- else }}
  ovs-vsctl set open . external-ids:hostname="$(hostname)"
{{- end }}

# Create bridges and create ports
# handle any bridge mappings
# /tmp/auto_bridge_add is one line json file: {"br-ex1":"eth1","br-ex2":"eth2"}
for bmap in `sed 's/[{}"]//g' /tmp/auto_bridge_add | tr "," "\n"`
do
  bridge=${bmap%:*}
  iface=${bmap#*:}
  ovs-vsctl --may-exist add-br $bridge -- set bridge $bridge protocols=OpenFlow13
  if [ -n "$iface" ] && [ "$iface" != "null" ]
  then
    ovs-vsctl --may-exist add-port $bridge $iface
  fi
done
