#!/bin/sh

set -eux

{{ if empty .Values.conf.node.CALICO_IPV4POOL_CIDR }}
{{ $_ := set .Values.conf.node "CALICO_IPV4POOL_CIDR" .Values.networking.podSubnet }}
{{ end }}

# An idempotent script for interacting with calicoctl to instantiate
# peers, and manipulate calico settings that we must perform
# post-deployment.

CTL=/calicoctl

# Generate configuration the way we want it to be, it doesn't matter
# if it's already set, in that case Calico will no nothing.

# BGPConfiguration: nodeToNodeMeshEnabled & asNumber
$CTL apply -f - <<EOF
apiVersion: projectcalico.org/v3
kind: BGPConfiguration
metadata:
  name: default
spec:
  logSeverityScreen: Info
  nodeToNodeMeshEnabled: {{ .Values.networking.settings.mesh }}
  asNumber: {{ .Values.networking.bgp.asnumber }}
EOF

# FelixConfiguration: ipipEnabled
$CTL apply -f - <<EOF
apiVersion: projectcalico.org/v3
kind: FelixConfiguration
metadata:
  name: default
spec:
  ipipEnabled: {{ .Values.networking.settings.ippool.ipip.enabled }}
  logSeverityScreen: Info
EOF

# ipPool - https://docs.projectcalico.org/v3.2/reference/calicoctl/resources/ippool
$CTL apply -f - <<EOF
apiVersion: projectcalico.org/v3
kind: IPPool
metadata:
  name: default-ipv4-ippool
spec:
  cidr: {{ .Values.conf.node.CALICO_IPV4POOL_CIDR }}
  ipipMode: {{ .Values.networking.settings.ippool.ipip.mode }}
  natOutgoing: {{ .Values.networking.settings.ippool.nat_outgoing }}
  disabled: {{ .Values.networking.settings.ippool.disabled }}
EOF


# IPv4 peers
{{ if .Values.networking.bgp.ipv4.peers }}
$CTL apply -f - <<EOF
{{ .Values.networking.bgp.ipv4.peers | toYaml }}
EOF
{{ end }}

# IPv6 peers
{{ if .Values.networking.bgp.ipv6.peers }}
$CTL apply -f - <<EOF
{{ .Values.networking.bgp.ipv6.peers | toYaml }}
EOF
{{ end }}

exit 0

