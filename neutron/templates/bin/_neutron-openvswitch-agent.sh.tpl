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

set -x
chown neutron: /run/openvswitch/db.sock

# ensure we can talk to openvswitch or bail early
# this is until we can setup a proper dependency
# on deaemonsets - note that a show is not sufficient
# here, we need to communicate with both the db and vswitchd
# which means we need to do a create action
# 
# see https://github.com/att-comdev/openstack-helm/issues/88
timeout 3m neutron-sanity-check --config-file /etc/neutron/neutron.conf --ovsdb_native --nokeepalived_ipv6_support


# determine local-ip dynamically based on interface provided but only if tunnel_types is not null
{{- if .Values.ml2.agent.tunnel_types }}
IP=$(ip a s {{ .Values.network.interface.tunnel | default .Values.network.interface.default}} | grep 'inet ' | awk '{print $2}' | awk -F "/" '{print $1}')
cat <<EOF>/tmp/ml2-local-ip.ini
[ovs]
local_ip = $IP
EOF
{{- else }}
touch /tmp/ml2-local-ip.ini
{{- end }}

exec sudo -E -u neutron neutron-openvswitch-agent --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugins/ml2/ml2-conf.ini --config-file /tmp/ml2-local-ip.ini
