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

chown neutron: /run/openvswitch/db.sock

# FIXME(portdirect): There is a neutron bug in Queens that needs resolved
# for now, if we cannot even get the version of neutron-sanity-check, skip
# this validation.
# see: https://bugs.launchpad.net/neutron/+bug/1769868
if neutron-sanity-check --version >/dev/null 2>/dev/null; then
  # ensure we can talk to openvswitch or bail early
  # this is until we can setup a proper dependency
  # on deaemonsets - note that a show is not sufficient
  # here, we need to communicate with both the db and vswitchd
  # which means we need to do a create action
  #
  # see https://github.com/att-comdev/openstack-helm/issues/88
  timeout 3m neutron-sanity-check --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugins/ml2/openvswitch_agent.ini --ovsdb_native --nokeepalived_ipv6_support
fi

# handle any bridge mappings
{{- range $bridge, $port := .Values.network.auto_bridge_add }}
ovs-vsctl --no-wait --may-exist add-br {{ $bridge }}
{{ if $port }}
ovs-vsctl --no-wait --may-exist add-port {{ $bridge }} {{ $port }}
ip link set dev {{ $port }} up
{{ end }}
{{- end }}

tunnel_interface="{{- .Values.network.interface.tunnel -}}"
if [ -z "${tunnel_interface}" ] ; then
    # search for interface with default routing
    # If there is not default gateway, exit
    tunnel_interface=$(ip -4 route list 0/0 | awk -F 'dev' '{ print $2; exit }' | awk '{ print $1 }') || exit 1
fi

# determine local-ip dynamically based on interface provided but only if tunnel_types is not null
LOCAL_IP=$(ip a s $tunnel_interface | grep 'inet ' | awk '{print $2}' | awk -F "/" '{print $1}')
if [ -z "${LOCAL_IP}" ] ; then
  echo "Var LOCAL_IP is empty"
  exit 1
fi

tee > /tmp/pod-shared/ml2-local-ip.ini << EOF
[ovs]
local_ip = "${LOCAL_IP}"
EOF
