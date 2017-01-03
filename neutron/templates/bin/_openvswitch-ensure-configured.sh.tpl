#!/bin/bash
set -x

bridge=$1
port=$2

# one time deal
ovs-vsctl --no-wait --if-exists del-port physnet1 enp11s0f0
ovs-vsctl --no-wait --if-exists del-br physnet1

# note that only "br-ex" is definable right now

ovs-vsctl --no-wait --may-exist add-br $bridge
ovs-vsctl --no-wait --may-exist add-port $bridge $port

# handle any bridge mappings
{{- range $bridge, $port := .Values.ml2.ovs.auto_bridge_add }}
ovs-vsctl --no-wait --may-exist add-br {{ $bridge }}
ovs-vsctl --no-wait --may-exist add-port {{ $bridge }} {{ $port }}
{{- end}}
