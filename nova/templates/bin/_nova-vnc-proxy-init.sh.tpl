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

client_address="{{- .Values.conf.nova.vnc.vncproxy.conf.vncserver_proxyclient_address -}}"
if [ -z "${client_address}" ] ; then
    client_interface="{{- .Values.console.novnc.vncproxy.vncserver_proxyclient_interface -}}"
    if [ -z "${client_interface}" ] ; then
        # search for interface with default routing
        client_interface=$(ip r | grep default | awk '{print $5}')
    fi

    # determine client ip dynamically based on interface provided
    client_address=$(ip a s $client_interface | grep 'inet ' | awk '{print $2}' | awk -F "/" '{print $1}')
fi

listen_ip="{{- .Values.conf.nova.vnc.vncproxy.conf.vncserver_listen -}}"
if [ -z "${listen_ip}" ] ; then
    listen_ip=$client_address
fi

cat <<EOF>/tmp/pod-shared/nova-vnc.ini
[vnc]
vncserver_proxyclient_address = $client_address
vncserver_listen = $listen_ip
EOF
