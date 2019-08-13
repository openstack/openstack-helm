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
COMMAND="${@:-start}"

OVS_SOCKET=/run/openvswitch/db.sock
OVS_PID=/run/openvswitch/ovs-vswitchd.pid

# Create vhostuser directory and grant nova user (default UID 42424) access
# permissions.
{{- if .Values.conf.ovs_dpdk.enabled }}
mkdir -p /run/openvswitch/{{ .Values.conf.ovs_dpdk.vhostuser_socket_dir }}
chown {{ .Values.pod.user.nova.uid }}.{{ .Values.pod.user.nova.uid }} /run/openvswitch/{{ .Values.conf.ovs_dpdk.vhostuser_socket_dir }}
{{- end }}

function start () {
  t=0
  while [ ! -e "${OVS_SOCKET}" ] ; do
      echo "waiting for ovs socket $sock"
      sleep 1
      t=$(($t+1))
      if [ $t -ge 10 ] ; then
          echo "no ovs socket, giving up"
          exit 1
      fi
  done

  ovs-vsctl --db=unix:${OVS_SOCKET} --no-wait show

{{- if .Values.conf.ovs_dpdk.enabled }}
    ovs-vsctl --db=unix:${OVS_SOCKET} --no-wait set Open_vSwitch . other_config:dpdk-hugepage-dir={{ .Values.conf.ovs_dpdk.hugepages_mountpath | quote }}
    ovs-vsctl --db=unix:${OVS_SOCKET} --no-wait set Open_vSwitch . other_config:dpdk-socket-mem={{ .Values.conf.ovs_dpdk.socket_memory | quote }}

{{- if .Values.conf.ovs_dpdk.mem_channels }}
    ovs-vsctl --db=unix:${OVS_SOCKET} --no-wait set Open_vSwitch . other_config:dpdk-mem-channels={{ .Values.conf.ovs_dpdk.mem_channels | quote }}
{{- end }}

{{- if .Values.conf.ovs_dpdk.pmd_cpu_mask }}
    ovs-vsctl --db=unix:${OVS_SOCKET} --no-wait set Open_vSwitch . other_config:pmd-cpu-mask={{ .Values.conf.ovs_dpdk.pmd_cpu_mask | quote }}
{{- end }}

{{- if .Values.conf.ovs_dpdk.lcore_mask }}
    ovs-vsctl --db=unix:${OVS_SOCKET} --no-wait set Open_vSwitch . other_config:dpdk-lcore-mask={{ .Values.conf.ovs_dpdk.lcore_mask | quote }}
{{- end }}

    ovs-vsctl --db=unix:${OVS_SOCKET} --no-wait set Open_vSwitch . other_config:vhost-sock-dir={{ .Values.conf.ovs_dpdk.vhostuser_socket_dir | quote }}
    ovs-vsctl --db=unix:${OVS_SOCKET} --no-wait set Open_vSwitch . other_config:dpdk-init=true
{{- end }}

  exec /usr/sbin/ovs-vswitchd unix:${OVS_SOCKET} \
          -vconsole:emer \
          -vconsole:err \
          -vconsole:info \
          --pidfile=${OVS_PID} \
          --mlockall
}

function stop () {
  PID=$(cat $OVS_PID)
  ovs-appctl -T1 -t /run/openvswitch/ovs-vswitchd.${PID}.ctl exit
}

$COMMAND
