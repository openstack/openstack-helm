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

# configure all bridge mappings defined in config
# /tmp/auto_bridge_add is one line json file: {"br-ex1":"eth1","br-ex2":"eth2"}
for bmap in `sed 's/[{}"]//g' /tmp/auto_bridge_add | tr "," "\n"`
do
  bridge=${bmap%:*}
  iface=${bmap#*:}
  # adding existing bridge would break out the script when -e is set
  set +e
  ip link add name $bridge type bridge
  set -e
  ip link set dev $bridge up
  if [ -n "$iface" ] && [ "$iface" != "null" ]
  then
    ip link set dev $iface  master $bridge
  fi
done

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

# determine local-ip dynamically based on interface provided but only if tunnel_types is not null
LOCAL_IP=$(ip a s $tunnel_interface | grep 'inet ' | awk '{print $2}' | awk -F "/" 'NR==1 {print $1}')
if [ -z "${LOCAL_IP}" ] ; then
  echo "Var LOCAL_IP is empty"
  exit 1
fi

tee > /tmp/pod-shared/ml2-local-ip.ini << EOF
[vxlan]
local_ip = "${LOCAL_IP}"
EOF

{{- if and ( empty .Values.conf.neutron.DEFAULT.host ) ( .Values.pod.use_fqdn.neutron_agent ) }}
mkdir -p /tmp/pod-shared
tee > /tmp/pod-shared/neutron-agent.ini << EOF
[DEFAULT]
host = $(hostname --fqdn)
EOF
{{- end }}
