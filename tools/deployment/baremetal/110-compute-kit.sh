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

#NOTE: Lint and package chart
make neutron
make ironic
make nova

#NOTE: Deploy neutron
#NOTE(portdirect): for simplicity we will assume the default route device
# should be used for tunnels
NETWORK_TUNNEL_DEV="$(sudo ip -4 route list 0/0 | awk '{ print $5; exit }')"
OSH_IRONIC_PXE_DEV="ironic-pxe"
OSH_IRONIC_PXE_PYSNET="ironic"
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
      max_l3_agents_per_router: 1
      l3_ha_network_type: vxlan
      dhcp_agents_per_network: 1
  plugins:
    ml2_conf:
      ml2_type_flat:
        flat_networks: public,${OSH_IRONIC_PXE_PYSNET}
    openvswitch_agent:
      agent:
        tunnel_types: vxlan
      ovs:
        bridge_mappings: "external:br-ex,${OSH_IRONIC_PXE_PYSNET}:${OSH_IRONIC_PXE_DEV}"
EOF
helm upgrade --install neutron ./neutron \
    --namespace=openstack \
    --values=/tmp/neutron.yaml \
    --set manifests.network_policy=true \
    ${OSH_EXTRA_HELM_ARGS} \
    ${OSH_EXTRA_HELM_ARGS_NEUTRON}

tee /tmp/ironic.yaml << EOF
labels:
  node_selector_key: openstack-helm-node-class
  node_selector_value: primary
network:
  pxe:
    device: "${OSH_IRONIC_PXE_DEV}"
    neutron_provider_network: "${OSH_IRONIC_PXE_PYSNET}"
conf:
  ironic:
    DEFAULT:
      debug: true
    conductor:
      automated_clean: "false"
    deploy:
      shred_final_overwrite_with_zeros: "false"
EOF
helm upgrade --install ironic ./ironic \
    --namespace=openstack \
    --values=/tmp/ironic.yaml \
    ${OSH_EXTRA_HELM_ARGS} \
    ${OSH_EXTRA_HELM_ARGS_IRONIC}

tee /tmp/nova.yaml << EOF
labels:
  agent:
    compute_ironic:
      node_selector_key: openstack-helm-node-class
      node_selector_value: primary
conf:
  nova:
    DEFAULT:
      debug: true
      #force_config_drive: false
      scheduler_host_manager: ironic_host_manager
      compute_driver: ironic.IronicDriver
      firewall_driver: nova.virt.firewall.NoopFirewallDriver
      #ram_allocation_ratio: 1.0
      reserved_host_memory_mb: 0
      scheduler_use_baremetal_filters: true
      baremetal_scheduler_default_filters: "RetryFilter,AvailabilityZoneFilter,ComputeFilter,ComputeCapabilitiesFilter"
    filter_scheduler:
      scheduler_tracks_instance_changes: false
      #scheduler_host_subset_size: 9999
    scheduler:
      discover_hosts_in_cells_interval: 120
manifests:
  cron_job_cell_setup: true
  daemonset_compute: false
  daemonset_libvirt: false
  statefulset_compute_ironic: true
  job_cell_setup: true
EOF
# Deploy Nova
helm upgrade --install nova ./nova \
    --namespace=openstack \
    --values=/tmp/nova.yaml \
    ${OSH_EXTRA_HELM_ARGS} \
    ${OSH_EXTRA_HELM_ARGS_NOVA}

#NOTE: Wait for deploy
./tools/deployment/common/wait-for-pods.sh openstack

#NOTE: Validate Deployment info
export OS_CLOUD=openstack_helm
openstack service list
sleep 30
openstack network agent list
openstack baremetal driver list
openstack compute service list
