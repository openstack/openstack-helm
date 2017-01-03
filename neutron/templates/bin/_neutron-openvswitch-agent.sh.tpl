#!/bin/bash
set -x
chown neutron: /run/openvswitch/db.sock

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
