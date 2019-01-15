#!/bin/bash

{{/*
Copyright 2019 Samsung Electronics Co., Ltd.

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

HM_PORT_ID=$(cat /tmp/pod-shared/HM_PORT_ID)
HM_PORT_MAC=$(cat /tmp/pod-shared/HM_PORT_MAC)

ovs-vsctl --no-wait show

ovs-vsctl --may-exist add-port br-int o-hm0 \
        -- set Interface o-hm0 type=internal \
        -- set Interface o-hm0 external-ids:iface-status=active \
        -- set Interface o-hm0 external-ids:attached-mac=$HM_PORT_MAC \
        -- set Interface o-hm0 external-ids:iface-id=$HM_PORT_ID \
        -- set Interface o-hm0 external-ids:skip_cleanup=true

ip link set dev o-hm0 address $HM_PORT_MAC

iptables -I INPUT -i o-hm0 -p udp --dport {{ .Values.conf.octavia.health_manager.bind_port }} -j ACCEPT
