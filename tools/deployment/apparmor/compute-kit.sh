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

#NOTE: Lint and package chart
make nova
make neutron

#NOTE: Deploy nova
: ${OSH_EXTRA_HELM_ARGS:=""}
tee /tmp/nova.yaml << EOF
conf:
  ceph:
    enabled: false
pod:
  mandatory_access_control:
    type: apparmor
    nova-compute-default:
      nova-compute-default: localhost/docker-default
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
      --set conf.nova.libvirt.virt_type=qemu \
      --set conf.nova.libvirt.cpu_mode=none \
      --values=/tmp/nova.yaml
      ${OSH_EXTRA_HELM_ARGS} \
      ${OSH_EXTRA_HELM_ARGS_NOVA}
fi

#NOTE: Deploy neutron
tee /tmp/neutron.yaml << EOF
pod:
  mandatory_access_control:
    type: apparmor
    neutron-dhcp-agent-default:
      neutron-dhcp-agent-default: localhost/docker-default
    neutron-l3-agent-default:
      neutron-l3-agent-default: localhost/docker-default
    neutron-lb-agent-default:
      neutron-lb-agent-default: localhost/docker-default
    neutron-metadata-agent-default:
      neutron-metadata-agent-default: localhost/docker-default
    neutron-ovs-agent-default:
      neutron-ovs-agent-default: localhost/docker-default
    neutron-sriov-agent-default:
      neutron-sriov-agent-default: localhost/docker-default
network:
  interface:
    tunnel: docker0
conf:
  neutron:
    DEFAULT:
      l3_ha: False
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
    linuxbridge_agent:
      linux_bridge:
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
