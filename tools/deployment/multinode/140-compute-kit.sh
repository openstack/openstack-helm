#!/bin/bash

# Copyright 2017 The Openstack-Helm Authors.
#
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

#NOTE: Deploy nova
tee /tmp/nova.yaml << EOF
labels:
  api_metadata:
    node_selector_key: openstack-helm-node-class
    node_selector_value: primary
pod:
  replicas:
    api_metadata: 1
    placement: 2
    osapi: 2
    conductor: 2
    consoleauth: 2
    scheduler: 1
    novncproxy: 1
EOF
if [ "x$(systemd-detect-virt)" == "xnone" ]; then
  echo 'OSH is not being deployed in virtualized environment'
  helm upgrade --install nova ./nova \
      --namespace=openstack \
      --values=/tmp/nova.yaml \
      ${OSH_EXTRA_HELM_ARGS} \
      ${OSH_EXTRA_HELM_ARGS_NOVA}
else
  echo 'OSH is being deployed in virtualized environment, using qemu for nova'
  helm upgrade --install nova ./nova \
      --namespace=openstack \
      --values=/tmp/nova.yaml \
      --set conf.nova.libvirt.virt_type=qemu \
      --set conf.nova.libvirt.cpu_mode=none \
      ${OSH_EXTRA_HELM_ARGS} \
      ${OSH_EXTRA_HELM_ARGS_NOVA}
fi

#NOTE: Deploy neutron
#NOTE(portdirect): for simplicity we will assume the default route device
# should be used for tunnels
NETWORK_TUNNEL_DEV="$(sudo ip -4 route list 0/0 | awk '{ print $5; exit }')"
tee /tmp/neutron.yaml << EOF
network:
  interface:
    tunnel: "${NETWORK_TUNNEL_DEV}"
labels:
  agent:
    dhcp:
      node_selector_key: openstack-helm-node-class
      node_selector_value: primary
    l3:
      node_selector_key: openstack-helm-node-class
      node_selector_value: primary
    metadata:
      node_selector_key: openstack-helm-node-class
      node_selector_value: primary
pod:
  replicas:
    server: 2
conf:
  neutron:
    DEFAULT:
      l3_ha: False
      min_l3_agents_per_router: 1
      max_l3_agents_per_router: 1
      l3_ha_network_type: vxlan
      dhcp_agents_per_network: 1
  plugins:
    ml2_conf:
      ml2_type_flat:
        flat_networks: public
    openvswitch_agent:
      agent:
        tunnel_types: vxlan
      ovs:
        bridge_mappings: public:br-ex
EOF
helm upgrade --install neutron ./neutron \
    --namespace=openstack \
    --values=/tmp/neutron.yaml \
    ${OSH_EXTRA_HELM_ARGS} \
    ${OSH_EXTRA_HELM_ARGS_NEUTRON}

#NOTE: Wait for deploy
./tools/deployment/common/wait-for-pods.sh openstack

#NOTE: Validate Deployment info
export OS_CLOUD=openstack_helm
openstack service list
sleep 30 #NOTE(portdirect): Wait for ingress controller to update rules and restart Nginx
openstack compute service list
openstack network agent list
helm test nova --timeout 900
helm test neutron --timeout 900
