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

#NOTE: Define variables
: ${OSH_HELM_REPO:="../openstack-helm"}
: ${OSH_PATH:="../openstack-helm"}
: ${OSH_EXTRA_HELM_ARGS_PLACEMENT:="$(helm osh get-values-overrides ${DOWNLOAD_OVERRIDES:-} -p ${OSH_PATH} placement ${FEATURES})"}
: ${OSH_EXTRA_HELM_ARGS_NOVA:="$(helm osh get-values-overrides ${DOWNLOAD_OVERRIDES:-} -p ${OSH_PATH} nova ${FEATURES})"}
: ${OSH_EXTRA_HELM_ARGS_NEUTRON:="$(helm osh get-values-overrides ${DOWNLOAD_OVERRIDES:-} -p ${OSH_PATH} neutron ${FEATURES})"}
: ${RUN_HELM_TESTS:="yes"}

export OS_CLOUD=openstack_helm
CEPH_ENABLED=false
if openstack service list -f value -c Type | grep -q "^volume" && \
    openstack volume type list -f value -c Name | grep -q "rbd"; then
  CEPH_ENABLED=true
fi

#NOTE: Deploy placement
helm upgrade --install placement ${OSH_HELM_REPO}/placement --namespace=openstack \
    ${OSH_EXTRA_HELM_ARGS:=} \
    ${OSH_EXTRA_HELM_ARGS_PLACEMENT}

#NOTE: Deploy nova
: ${OSH_EXTRA_HELM_ARGS:=""}
if [ "x$(systemd-detect-virt)" == "xnone" ] || [ "x$(systemd-detect-virt)" == "xkvm" ]; then
  echo 'OSH is not being deployed in virtualized environment'
  helm upgrade --install nova ${OSH_HELM_REPO}/nova \
      --namespace=openstack \
      --set bootstrap.wait_for_computes.enabled=true \
      --set conf.ceph.enabled=${CEPH_ENABLED} \
      ${OSH_EXTRA_HELM_ARGS:=} \
      ${OSH_EXTRA_HELM_ARGS_NOVA}
else
  echo 'OSH is being deployed in virtualized environment, using qemu for nova'
  helm upgrade --install nova ${OSH_HELM_REPO}/nova \
      --namespace=openstack \
      --set bootstrap.wait_for_computes.enabled=true \
      --set conf.ceph.enabled=${CEPH_ENABLED} \
      --set conf.nova.libvirt.virt_type=qemu \
      --set conf.nova.libvirt.cpu_mode=none \
      ${OSH_EXTRA_HELM_ARGS:=} \
      ${OSH_EXTRA_HELM_ARGS_NOVA}
fi

#NOTE: Deploy neutron
tee /tmp/neutron.yaml << EOF
network:
  interface:
    tunnel: null
conf:
  neutron:
    DEFAULT:
      l3_ha: False
      max_l3_agents_per_router: 1
      l3_ha_network_type: vxlan
      dhcp_agents_per_network: 1
  # provider1 is a tap interface used by default in the test env
  # we create this interface while setting up the test env
  auto_bridge_add:
    br-ex: provider1
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
labels:
  agent:
    l3:
      node_selector_key: l3-agent
      node_selector_value: enabled
EOF

helm upgrade --install neutron ${OSH_HELM_REPO}/neutron \
    --namespace=openstack \
    --values=/tmp/neutron.yaml \
    ${OSH_EXTRA_HELM_ARGS:=} \
    ${OSH_EXTRA_HELM_ARGS_NEUTRON}

# If compute kit installed using Tungsten Fubric, it will be alive when Tunsten Fabric become active.
if [[ "$FEATURE_GATES" =~ (,|^)tf(,|$) ]]; then
  exit 0
fi
#NOTE: Wait for deploy
helm osh wait-for-pods openstack

#NOTE: Validate Deployment info
export OS_CLOUD=openstack_helm
openstack service list
sleep 30 #NOTE(portdirect): Wait for ingress controller to update rules and restart Nginx
openstack compute service list
openstack network agent list
openstack hypervisor list

if [ "x${RUN_HELM_TESTS}" == "xno" ]; then
    exit 0
fi

./tools/deployment/common/run-helm-tests.sh nova
./tools/deployment/common/run-helm-tests.sh neutron
