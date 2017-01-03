#!/bin/bash
set -ex

# load tunnel kernel modules we may use and gre/vxlan
modprobe openvswitch

{{- if .Values.ml2.agent.tunnel_types }}
modprobe gre
modprobe vxlan
{{- end }}

ovs-vsctl --no-wait show
bash /tmp/openvswitch-ensure-configured.sh {{ .Values.network.external_bridge }} {{ .Values.network.interface.external | default .Values.network.interface.default }}
exec /usr/sbin/ovs-vswitchd unix:/run/openvswitch/db.sock --mlockall -vconsole:emer -vconsole:err -vconsole:info
