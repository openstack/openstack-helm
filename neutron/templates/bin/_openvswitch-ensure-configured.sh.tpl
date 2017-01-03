#!/bin/bash
set -x

bridge=$1
port=$2

# note that only "br-ex" is definable right now
# and br-int and br-tun are assumed and handled
# by the agent
ovs-vsctl --no-wait --may-exist add-br $bridge
ovs-vsctl --no-wait --may-exist add-port $bridge $port

# handle any bridge mappings
{{- range $bridge, $port := .Values.ml2.ovs.auto_bridge_add }}
ovs-vsctl --no-wait --may-exist add-br {{ $bridge }}
ovs-vsctl --no-wait --may-exist add-port {{ $bridge }} {{ $port }}
{{- end}}
