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

  ovs-vsctl --no-wait show

  # handle any bridge mappings
  {{- range $br, $phys := .Values.network.auto_bridge_add }}
  if [ -n "{{- $br -}}" ] ; then
      # create {{ $br }}{{ if $phys }} and add port {{ $phys }}{{ end }}
      ovs-vsctl --no-wait --may-exist add-br "{{ $br }}"
      if [ -n "{{- $phys -}}" ] ; then
          ovs-vsctl --no-wait --may-exist add-port "{{ $br }}" "{{ $phys }}"
          ip link set dev "{{ $phys }}" up
      fi
  fi
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
