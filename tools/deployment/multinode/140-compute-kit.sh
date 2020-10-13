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

: ${RUN_HELM_TESTS:="yes"}

export OS_CLOUD=openstack_helm
CEPH_ENABLED=false
if openstack service list -f value -c Type | grep -q "^volume" && \
    openstack volume type list -f value -c Name | grep -q "rbd"; then
  CEPH_ENABLED=true
fi

#NOTE: Get the overrides to use for placement, should placement be deployed.
case "${OPENSTACK_RELEASE}" in
  "queens")
    DEPLOY_SEPARATE_PLACEMENT="no"
    ;;
  "rocky")
    DEPLOY_SEPARATE_PLACEMENT="no"
    ;;
  "stein")
    DEPLOY_SEPARATE_PLACEMENT="yes"
    ;;
  *)
    DEPLOY_SEPARATE_PLACEMENT="yes"
    ;;
esac

if [[ "${DEPLOY_SEPARATE_PLACEMENT}" == "yes" ]]; then
    # Get overrides
    : ${OSH_EXTRA_HELM_ARGS_PLACEMENT:="$(./tools/deployment/common/get-values-overrides.sh placement)"}

    # Lint and package
    make placement

    tee /tmp/placement.yaml << EOF
pod:
  replicas:
    api: 2
EOF
    # Deploy
    helm upgrade --install placement ./placement \
        --namespace=openstack \
	--values=/tmp/placement.yaml \
        ${OSH_EXTRA_HELM_ARGS:=} \
       	${OSH_EXTRA_HELM_ARGS_PLACEMENT}
fi

#NOTE: Get the over-rides to use
: ${OSH_EXTRA_HELM_ARGS_NOVA:="$(./tools/deployment/common/get-values-overrides.sh nova)"}

# TODO: Revert this reasoning when gates are pointing to more up to
# date openstack release. When doing so, we should revert the default
# values of the nova chart to NOT use placement by default, and
# have a ocata/pike/queens/rocky/stein override to enable placement in the nova chart deploy

if [[ "${DEPLOY_SEPARATE_PLACEMENT}" == "yes" ]]; then
  OSH_EXTRA_HELM_ARGS_NOVA="${OSH_EXTRA_HELM_ARGS_NOVA} --values=./nova/values_overrides/train-disable-nova-placement.yaml"
fi

#NOTE: Lint and package chart
make nova

#NOTE: Deploy nova
tee /tmp/nova.yaml << EOF
pod:
  replicas:
    osapi: 2
    conductor: 2
    consoleauth: 2
EOF
if [[ "${DEPLOY_SEPARATE_PLACEMENT}" == "no" ]]; then
  echo "    placement: 2" >> /tmp/nova.yaml
fi

#NOTE: Deploy nova
: ${OSH_EXTRA_HELM_ARGS:=""}
if [ "x$(systemd-detect-virt)" == "xnone" ]; then
  echo 'OSH is not being deployed in virtualized environment'
  helm upgrade --install nova ./nova \
      --namespace=openstack \
      --values=/tmp/nova.yaml \
      --set bootstrap.wait_for_computes.enabled=true \
      --set conf.ceph.enabled=${CEPH_ENABLED} \
      ${OSH_EXTRA_HELM_ARGS:=} \
      ${OSH_EXTRA_HELM_ARGS_NOVA}
else
  echo 'OSH is being deployed in virtualized environment, using qemu for nova'
  helm upgrade --install nova ./nova \
      --namespace=openstack \
      --values=/tmp/nova.yaml \
      --set bootstrap.wait_for_computes.enabled=true \
      --set conf.ceph.enabled=${CEPH_ENABLED} \
      --set conf.nova.libvirt.virt_type=qemu \
      --set conf.nova.libvirt.cpu_mode=none \
      ${OSH_EXTRA_HELM_ARGS:=} \
      ${OSH_EXTRA_HELM_ARGS_NOVA}
fi

#NOTE: Get the over-rides to use
: ${OSH_EXTRA_HELM_ARGS_NEUTRON:="$(./tools/deployment/common/get-values-overrides.sh neutron)"}

#NOTE: Lint and package chart
make neutron

tee /tmp/neutron.yaml << EOF
network:
  interface:
    tunnel: docker0
pod:
  replicas:
    server: 2
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
    ${OSH_RELEASE_OVERRIDES_NEUTRON} \
    ${OSH_EXTRA_HELM_ARGS} \
    ${OSH_EXTRA_HELM_ARGS_NEUTRON}

# If compute kit installed using Tungsten Fubric, it will be alive when Tunsten Fabric become active.
if [[ "$FEATURE_GATES" =~ (,|^)tf(,|$) ]]; then
  exit 0
fi
#NOTE: Wait for deploy
./tools/deployment/common/wait-for-pods.sh openstack

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
