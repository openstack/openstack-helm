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
  local ip=$(ip -4 -o addr s "${interface}" | awk '{ print $4; exit }' | awk -F '/' 'NR==1 {print $1}')
  if [ -z "${ip}" ] ; then
    exit 1
  fi
  echo ${ip}
}

function get_ip_prefix_from_interface {
  local interface=$1
  local prefix=$(ip -4 -o addr s "${interface}" | awk '{ print $4; exit }' | awk -F '/' 'NR==1 {print $2}')
  if [ -z "${prefix}" ] ; then
    exit 1
  fi
  echo ${prefix}
}

function migrate_ip_from_nic {
  src_nic=$1
  bridge_name=$2

  # Enabling explicit error handling: We must avoid to lose the IP
  # address in the migration process. Hence, on every error, we
  # attempt to assign the IP back to the original NIC and exit.
  set +e

  ip=$(get_ip_address_from_interface ${src_nic})
  prefix=$(get_ip_prefix_from_interface ${src_nic})

  bridge_ip=$(get_ip_address_from_interface "${bridge_name}")
  bridge_prefix=$(get_ip_prefix_from_interface "${bridge_name}")

  ip link set ${bridge_name} up

  if [[ -n "${ip}" && -n "${prefix}" ]]; then
    ip addr flush dev ${src_nic}
    if [ $? -ne 0 ] ; then
      ip addr add ${ip}/${prefix} dev ${src_nic}
      echo "Error while flushing IP from ${src_nic}."
      exit 1
    fi

    ip addr add ${ip}/${prefix} dev "${bridge_name}"
    if [ $? -ne 0 ] ; then
      echo "Error assigning IP to bridge "${bridge_name}"."
      ip addr add ${ip}/${prefix} dev ${src_nic}
      exit 1
    fi
  elif [[ -n "${bridge_ip}" && -n "${bridge_prefix}" ]]; then
    echo "Bridge '${bridge_name}' already has IP assigned. Keeping the same:: IP:[${bridge_ip}]; Prefix:[${bridge_prefix}]..."
  elif [[ -z "${bridge_ip}" && -z "${ip}" ]]; then
    echo "Interface and bridge have no ips configured. Leaving as is."
  else
    echo "Interface ${src_nic} has invalid IP address. IP:[${ip}]; Prefix:[${prefix}]..."
    exit 1
  fi

  set -e
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

GW_ENABLED=$(cat /tmp/gw-enabled/gw-enabled)
if [[ ${GW_ENABLED} == enabled ]]; then
  ovs-vsctl set open . external-ids:ovn-cms-options={{ .Values.conf.ovn_cms_options_gw_enabled }}
else
  ovs-vsctl set open . external-ids:ovn-cms-options={{ .Values.conf.ovn_cms_options }}
fi

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
  if [ -n "$iface" ] && [ "$iface" != "null" ] && ( ip link show $iface 1>/dev/null 2>&1 );
  then
    ovs-vsctl --may-exist add-port $bridge $iface
    migrate_ip_from_nic $iface $bridge
  fi
done
