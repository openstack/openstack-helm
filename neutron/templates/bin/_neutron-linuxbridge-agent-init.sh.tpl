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

modprobe ebtables

# configure external bridge
external_bridge="{{- .Values.network.external_bridge -}}"
external_interface="{{- .Values.network.interface.external -}}"
if [ -n "${external_bridge}" ] ; then
    # adding existing bridge would break out the script when -e is set
    set +e
    ip link add name $external_bridge type bridge
    set -e
    ip link set dev $external_bridge up
    if [ -n "$external_interface" ] ; then
        ip link set dev $external_interface master $external_bridge
    fi
fi


# configure all bridge mappings defined in config
{{- range $br, $phys := .Values.network.auto_bridge_add }}
if [ -n "{{- $br -}}" ] ; then
    # adding existing bridge would break out the script when -e is set
    set +e
    ip link add name {{ $br }} type bridge
    set -e
    ip link set dev {{ $br }} up
    if [ -n "{{- $phys -}}" ] ; then
        ip link set dev {{ $phys }}  master {{ $br }}
    fi
fi
{{- end }}


tunnel_interface="{{- .Values.network.interface.tunnel -}}"
if [ -z "${tunnel_interface}" ] ; then
    # search for interface with default routing
    # If there is not default gateway, exit
    tunnel_interface=$(ip -4 route list 0/0 | awk -F 'dev' '{ print $2; exit }' | awk '{ print $1 }') || exit 1
fi

# determine local-ip dynamically based on interface provided but only if tunnel_types is not null
IP=$(ip a s $tunnel_interface | grep 'inet ' | awk '{print $2}' | awk -F "/" '{print $1}')
cat <<EOF>/tmp/pod-shared/ml2-local-ip.ini
[vxlan]
local_ip = $IP
EOF
