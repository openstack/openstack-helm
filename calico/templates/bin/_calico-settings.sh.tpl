#!/bin/sh

set -eux


{{/* Robustness, Calico 3.x wants things as Titlecase; this causes pain */}}
{{- $_ := set .Values.conf.node "CALICO_IPV4POOL_IPIP" (title .Values.conf.node.CALICO_IPV4POOL_IPIP ) -}}
{{- $_ := set .Values.conf.node "CALICO_STARTUP_LOGLEVEL" (title .Values.conf.node.CALICO_STARTUP_LOGLEVEL ) -}}
{{- $_ := set .Values.conf.node "FELIX_LOGSEVERITYSCREEN" (title .Values.conf.node.FELIX_LOGSEVERITYSCREEN ) -}}


{{- $envAll := . }}

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
  asNumber: {{ .Values.networking.bgp.asnumber }}
  logSeverityScreen: {{ .Values.conf.node.FELIX_LOGSEVERITYSCREEN }}
  nodeToNodeMeshEnabled: {{ .Values.networking.settings.mesh }}
EOF

# FelixConfiguration: ipipEnabled
$CTL apply -f - <<EOF
apiVersion: projectcalico.org/v3
kind: FelixConfiguration
metadata:
  name: default
spec:
  ipipEnabled: {{ .Values.networking.settings.ippool.ipip.enabled }}
  logSeverityScreen: {{ .Values.conf.node.FELIX_LOGSEVERITYSCREEN }}
EOF

# ipPool - https://docs.projectcalico.org/v3.4/reference/calicoctl/resources/ippool
$CTL apply -f - <<EOF
apiVersion: projectcalico.org/v3
kind: IPPool
metadata:
  name: default-ipv4-ippool
spec:
  cidr: {{ .Values.conf.node.CALICO_IPV4POOL_CIDR }}
{{- if .Values.conf.node.CALICO_IPV4POOL_BLOCKSIZE }}
  blockSize: {{ .Values.conf.node.CALICO_IPV4POOL_BLOCKSIZE }}
{{- end }}
  ipipMode: {{ .Values.conf.node.CALICO_IPV4POOL_IPIP }}
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

{{/* gotpl quirks mean it is easier to loop from 0 to 9 looking for a match in an inner loop than trying to extract and sort */}}
{{ if .Values.networking.policy }}
# Policy and Endpoint rules
{{ range $n, $data := tuple 0 1 2 3 4 5 6 7 8 9 }}
# Priority: {{ $n }} objects
{{- range $section, $data := $envAll.Values.networking.policy }}
{{- if eq (toString $data.priority) (toString $n) }}
{{/* add a safety check so we don't attempt to run calicoctl with an empty resource set */}}
{{- if gt (len $data.rules) 0 }}
# Section: {{ $section }} Priority: {{ $data.priority }} {{ $n }}
$CTL apply -f - <<EOF
{{ $data.rules | toYaml }}
EOF
{{- else }}
echo "Skipping empty rules list."
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{ end }}

exit 0
