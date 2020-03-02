#!/bin/bash

#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.
set -xe

# Assign IP address to br-ex
: ${OSH_EXT_SUBNET:="172.24.4.0/24"}
: ${OSH_BR_EX_ADDR:="172.24.4.1/24"}
sudo ip addr add ${OSH_BR_EX_ADDR} dev br-ex
sudo ip link set br-ex up

: ${DNSMASQ_IMAGE:=docker.io/openstackhelm/neutron:ocata}

# NOTE(portdirect): With Docker >= 1.13.1 the default FORWARD chain policy is
# configured to DROP, for the l3 agent to function as expected and for
# VMs to reach the outside world correctly this needs to be set to ACCEPT.
sudo iptables -P FORWARD ACCEPT

# Setup masquerading on default route dev to public subnet by searching for the
# interface with default routing, if multiple default routes exist then select
# the one with the lowest metric.
DEFAULT_ROUTE_DEV=$(route -n | awk '/^0.0.0.0/ { print $5 " " $NF }' | sort | awk '{ print $NF; exit }')
sudo iptables -t nat -A POSTROUTING -o ${DEFAULT_ROUTE_DEV} -s ${OSH_EXT_SUBNET} -j MASQUERADE

# NOTE(portdirect): Setup DNS for public endpoints
sudo docker run -d \
  --name br-ex-dns-server \
  --net host \
  --cap-add=NET_ADMIN \
  --volume /etc/kubernetes/kubelet-resolv.conf:/etc/kubernetes/kubelet-resolv.conf:ro \
  --entrypoint dnsmasq \
  ${DNSMASQ_IMAGE} \
    --keep-in-foreground \
    --no-hosts \
    --bind-interfaces \
    --resolv-file=/etc/kubernetes/kubelet-resolv.conf \
    --address="/svc.cluster.local/${OSH_BR_EX_ADDR%/*}" \
    --listen-address="${OSH_BR_EX_ADDR%/*}"
sleep 1
sudo docker top br-ex-dns-server
