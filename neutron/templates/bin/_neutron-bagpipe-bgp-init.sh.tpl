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

{{- if (has "openvswitch" .Values.network.backend) }}
chown neutron: /run/openvswitch/db.sock
{{- end }}

# handle any bridge mappings
for bmap in `sed 's/[{}"]//g' /tmp/auto_bridge_add | tr "," "\n"`; do
  bridge=${bmap%:*}
  iface=${bmap#*:}
{{- if (has "openvswitch" .Values.network.backend) }}
  ovs-vsctl --no-wait --may-exist add-br $bridge
  if [ -n "$iface" -a "$iface" != "null" ]; then
    ovs-vsctl --no-wait --may-exist add-port $bridge $iface
    ip link set dev $iface up
  fi
{{- else if (has "linuxbridge" .Values.network.backend) }}
  set +e; ip link add name $bridge type bridge; set -e
  ip link set dev $bridge up
  [ -n "$iface" -a "$iface" != "null" ] && ip link set dev $iface master $bridge
{{- end }}
done
