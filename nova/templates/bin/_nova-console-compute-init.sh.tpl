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

console_kind="{{- .Values.console.console_kind -}}"

if [ "${console_kind}" == "novnc" ] ; then
    client_address="{{- .Values.conf.nova.vnc.server_proxyclient_address -}}"
    client_interface="{{- .Values.console.novnc.compute.vncserver_proxyclient_interface -}}"
    client_network_cidr="{{- .Values.console.novnc.compute.vncserver_proxyclient_network_cidr -}}"
    listen_ip="{{- .Values.conf.nova.vnc.server_listen -}}"
elif [ "${console_kind}" == "spice" ] ; then
    client_address="{{- .Values.conf.nova.spice.server_proxyclient_address -}}"
    client_interface="{{- .Values.console.spice.compute.server_proxyclient_interface -}}"
    client_network_cidr="{{- .Values.console.spice.compute.server_proxyclient_network_cidr -}}"
    listen_ip="{{- .Values.conf.nova.spice.server_listen -}}"
fi

if [ -z "${client_address}" ] ; then
    if [ -z "${client_interface}" ] ; then
        if [ -z "${client_network_cidr}" ] ; then
            client_network_cidr="0/0"
        fi
        client_interface=$(ip -4 route list ${client_network_cidr} | awk -F 'dev' '{ print $2; exit }' | awk '{ print $1 }') || exit 1
    fi

    # determine client ip dynamically based on interface provided
    client_address=$(ip a s $client_interface | grep 'inet ' | awk '{print $2}' | awk -F "/" '{print $1}' | head -1)
fi

if [ -z "${listen_ip}" ] ; then
    # The server component listens on all IP addresses and the proxy component
    # only listens on the management interface IP address of the compute node.
    listen_ip=0.0.0.0
fi

touch /tmp/pod-shared/nova-console.conf
if [ "${console_kind}" == "novnc" ] ; then
  cat > /tmp/pod-shared/nova-console.conf <<EOF
[vnc]
server_proxyclient_address = $client_address
server_listen = $listen_ip
EOF
elif [ "${console_kind}" == "spice" ] ; then
  cat > /tmp/pod-shared/nova-console.conf <<EOF
[spice]
server_proxyclient_address = $client_address
server_listen = $listen_ip
EOF
fi
