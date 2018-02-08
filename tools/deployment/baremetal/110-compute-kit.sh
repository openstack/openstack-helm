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

#NOTE: Pull images and lint chart
make pull-images neutron
make pull-images ironic
make pull-images nova

#NOTE: Deploy neutron
#NOTE(portdirect): for simplicity we will assume the default route device
# should be used for tunnels
NETWORK_TUNNEL_DEV="$(sudo ip -4 route list 0/0 | awk '{ print $5; exit }')"
tee /tmp/neutron.yaml << EOF
network:
  interface:
    tunnel: "${NETWORK_TUNNEL_DEV}"
labels:
  ovs:
      node_selector_key: openstack-helm-node-class
      node_selector_value: primary
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
    server: 1
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
        flat_networks: public,physnet2
    openvswitch_agent:
      agent:
        tunnel_types: vxlan
      ovs:
        bridge_mappings: "external:br-ex,physnet2:ironic-pxe"
manifests:
  daemonset_dhcp_agent: false
  daemonset_metadata_agent: false
  daemonset_l3_agent: false
EOF
helm install ./neutron \
    --namespace=openstack \
    --name=neutron \
    --values=/tmp/neutron.yaml

#NOTE: Wait for deploy
./tools/deployment/common/wait-for-pods.sh openstack

#NOTE: Validate Deployment info
export OS_CLOUD=openstack_helm
openstack service list
sleep 30 #NOTE(portdirect): Wait for ingress controller to update rules and restart Nginx

export OSH_IRONIC_PXE_NET_NAME="${OSH_IRONIC_PXE_NET_NAME:="baremetal"}"
IRONIC_NEUTRON_CLEANING_NET_ID=$(openstack network create -f value -c id --share --provider-network-type flat \
  --provider-physical-network physnet2 ${OSH_IRONIC_PXE_NET_NAME})

export OSH_IRONIC_PXE_DEV=${OSH_IRONIC_PXE_DEV:="ironic-pxe"}
export OSH_IRONIC_PXE_ADDR="${OSH_IRONIC_PXE_ADDR:="172.24.6.1/24"}"
export OSH_IRONIC_PXE_SUBNET="${OSH_IRONIC_PXE_SUBNET:="172.24.6.0/24"}"
export OSH_IRONIC_PXE_ALOC_START="${OSH_IRONIC_PXE_ALOC_START:="172.24.6.100"}"
export OSH_IRONIC_PXE_ALOC_END="${OSH_IRONIC_PXE_ALOC_END:="172.24.6.200"}"
export OSH_IRONIC_PXE_SUBNET_NAME="${OSH_IRONIC_PXE_SUBNET_NAME:="baremetal"}"
openstack subnet create \
  --gateway ${OSH_IRONIC_PXE_ADDR%/*} \
  --allocation-pool start=${OSH_IRONIC_PXE_ALOC_START},end=${OSH_IRONIC_PXE_ALOC_END} \
  --dns-nameserver $(kubectl get -n kube-system svc kube-dns -o json | jq -r '.spec.clusterIP') \
  --subnet-range ${OSH_IRONIC_PXE_SUBNET} \
  --network ${OSH_IRONIC_PXE_NET_NAME} \
  ${OSH_IRONIC_PXE_SUBNET_NAME}

tee /tmp/ironic.yaml << EOF
labels:
  node_selector_key: openstack-helm-node-class
  node_selector_value: primary
network:
  interface:
    provisioner: "${OSH_IRONIC_PXE_DEV}"
conf:
  ironic:
    conductor:
      automated_clean: "false"
    deploy:
      shred_final_overwrite_with_zeros: "false"
    neutron:
      cleaning_network_uuid: "${IRONIC_NEUTRON_CLEANING_NET_ID}"
EOF
helm install ./ironic \
    --namespace=openstack \
    --name=ironic \
    --values=/tmp/ironic.yaml

#NOTE: Wait for deploy
./tools/deployment/common/wait-for-pods.sh openstack

tee /tmp/nova.yaml << EOF
labels:
  agent:
    compute_ironic:
      node_selector_key: openstack-helm-node-class
      node_selector_value: primary
conf:
  nova:
    DEFAULT:
      force_config_drive: false
      scheduler_host_manager: ironic_host_manager
      compute_driver: ironic.IronicDriver
      ram_allocation_ratio: 1.0
      reserved_host_memory_mb: 0
      scheduler_use_baremetal_filters: true
      baremetal_scheduler_default_filters: "RetryFilter,AvailabilityZoneFilter,ComputeFilter,ComputeCapabilitiesFilter"
      scheduler_tracks_instance_changes: false
      scheduler_host_subset_size: 9999
manifests:
  daemonset_compute: false
  daemonset_libvirt: false
  statefulset_compute_ironic: true
  job_cell_setup: false
EOF
# Deploy Nova and enable the neutron agents
helm install ./nova \
    --namespace=openstack \
    --name=nova \
    --values=/tmp/nova.yaml

helm upgrade neutron ./neutron \
  --values=/tmp/neutron.yaml \
  --set=manifests.daemonset_dhcp_agent=true \
  --set=manifests.daemonset_metadata_agent=true \
  --set=manifests.daemonset_l3_agent=true

#NOTE: Wait for deploy
./tools/deployment/common/wait-for-pods.sh openstack

#NOTE: Validate Deployment info
export OS_CLOUD=openstack_helm
openstack service list
sleep 30
openstack network agent list
openstack baremetal driver list
openstack compute service list
