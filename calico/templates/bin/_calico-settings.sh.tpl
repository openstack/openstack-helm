#!/bin/sh

set -eux

{{ if empty .Values.conf.node.CALICO_IPV4POOL_CIDR }}
{{ set .Values.conf.node "CALICO_IPV4POOL_CIDR" .Values.networking.podSubnet | quote | trunc 0 }}
{{ end }}

# An idempotent script for interacting with calicoctl to instantiate
# peers, and manipulate calico settings that we must perform
# post-deployment.

CALICOCTL=/calicoctl

#####################################################
### process mesh and other cluster wide settings  ###
#####################################################

# get nodeToNodeMesh value
MESH_VALUE=$(${CALICOCTL} config get nodeToNodeMesh)

# update if necessary
if [ "$MESH_VALUE" != "{{.Values.networking.settings.mesh}}" ];
then
    $CALICOCTL config set nodeToNodeMesh {{.Values.networking.settings.mesh}}
fi;

# get asnumber value
AS_VALUE=$(${CALICOCTL} config get asNumber)

# update if necessary
if [ "$AS_VALUE" != "{{.Values.networking.bgp.asnumber}}" ];
then
    $CALICOCTL config set asnumber {{.Values.networking.bgp.asnumber}}
fi;


#######################################################
### process ippools                                 ###
#######################################################

# for posterity and logging
${CALICOCTL} get ipPool -o yaml

# ideally, we would support more then one pool
# and this would be a simple toYaml, but we want to
# avoid them having to spell out the podSubnet again
# or do any hackish replacement
#
# the downside here is that this embedded template
# will likely break when applied against calico v3
cat <<EOF | ${CALICOCTL} apply -f -
# process nat/ipip settings
apiVersion: v1
kind: ipPool
metadata:
  cidr: {{.Values.conf.node.CALICO_IPV4POOL_CIDR}}
spec:
  ipip:
    enabled: {{.Values.networking.settings.ippool.ipip.enabled}}
    mode: {{.Values.networking.settings.ippool.ipip.mode}}
  nat-outgoing: {{.Values.networking.settings.ippool.nat_outgoing}}
  disabled: {{.Values.networking.settings.ippool.disabled}}
EOF

#######################################################
### bgp peers                                       ###
#######################################################

# for posterity and logging
${CALICOCTL} get bgpPeer -o yaml

# process IPv4 peers
{{ if .Values.networking.bgp.ipv4.peers }}
cat << EOF | ${CALICOCTL} apply -f -
{{ .Values.networking.bgp.ipv4.peers | toYaml }}
EOF
{{ end }}

# process IPv6 peers
{{ if .Values.networking.bgp.ipv6.peers }}
cat << EOF | ${CALICOCTL} apply -f -
{{ .Values.networking.bgp.ipv4.peers | toYaml }}
EOF
{{ end }}
