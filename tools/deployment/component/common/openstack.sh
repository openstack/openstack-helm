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

export OSH_TEST_TIMEOUT=1200
export OS_CLOUD=openstack_helm
: "${RUN_HELM_TESTS:="no"}"
: "${CEPH_ENABLED:="false"}"
: "${OSH_EXTRA_HELM_ARGS:=""}"
release=openstack
namespace=$release

: ${GLANCE_BACKEND:="pvc"}
tee /tmp/glance.yaml <<EOF
glance:
  storage: ${GLANCE_BACKEND}
  volume:
    class_name: standard
EOF
#NOTE: Deploy neutron
tee /tmp/neutron.yaml << EOF
neutron:
  release_group: neutron
  enabled: true
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
## includes second argument 'subchart' to indicate a different path
export HELM_CHART_ROOT_PATH="../openstack-helm/openstack"
: ${OSH_EXTRA_HELM_ARGS_MARIADB:="$(./tools/deployment/common/get-values-overrides.sh mariadb subchart)"}
: ${OSH_EXTRA_HELM_ARGS_RABBITMQ:="$(./tools/deployment/common/get-values-overrides.sh rabbitmq subchart)"}
: ${OSH_EXTRA_HELM_ARGS_MEMCACHED:="$(./tools/deployment/common/get-values-overrides.sh memcached subchart)"}
: ${OSH_EXTRA_HELM_ARGS_KEYSTONE:="$(./tools/deployment/common/get-values-overrides.sh keystone subchart)"}
: ${OSH_EXTRA_HELM_ARGS_HEAT:="$(./tools/deployment/common/get-values-overrides.sh heat subchart)"}
: ${OSH_EXTRA_HELM_ARGS_GLANCE:="$(./tools/deployment/common/get-values-overrides.sh glance subchart)"}
: ${OSH_EXTRA_HELM_ARGS_OPENVSWITCH:="$(./tools/deployment/common/get-values-overrides.sh openvswitch subchart)"}
: ${OSH_EXTRA_HELM_ARGS_LIBVIRT:="$(./tools/deployment/common/get-values-overrides.sh libvirt subchart)"}
: ${OSH_EXTRA_HELM_ARGS_NOVA:="$(./tools/deployment/common/get-values-overrides.sh nova subchart)"}
: ${OSH_EXTRA_HELM_ARGS_PLACEMENT:="$(./tools/deployment/common/get-values-overrides.sh placement subchart)"}
: ${OSH_EXTRA_HELM_ARGS_NEUTRON:="$(./tools/deployment/common/get-values-overrides.sh neutron subchart)"}
: ${OSH_EXTRA_HELM_ARGS_HORIZON:="$(./tools/deployment/common/get-values-overrides.sh horizon subchart)"}

#NOTE: Lint and package chart
make -C ${HELM_CHART_ROOT_PATH} .

if [ "x$(systemd-detect-virt)" != "xnone" ]; then
  echo 'OSH is being deployed in virtualized environment, using qemu for nova'
  OSH_EXTRA_HELM_VIRT_ARGS=( "--set nova.conf.nova.libvirt.virt_type=qemu" \
                        "--set nova.conf.nova.libvirt.cpu_mode=none" )
fi

# Check if Hugepages is enabled
hgpgs_available="$(awk '/HugePages_Total/{print $2}' /proc/meminfo)"
if [ "x$hgpgs_available" != "x0" ]; then
  OSH_EXTRA_HELM_ARGS_LIBVIRT_CGROUP="--set libvirt.conf.kubernetes.cgroup=."
fi

helm dependency update openstack

echo "helm installing openstack..."
helm upgrade --install $release openstack/ \
  ${OSH_EXTRA_HELM_ARGS_MARIADB} \
  ${OSH_EXTRA_HELM_ARGS_RABBITMQ} \
  ${OSH_EXTRA_HELM_ARGS_MEMCACHED} \
  ${OSH_EXTRA_HELM_ARGS_KEYSTONE} \
  ${OSH_EXTRA_HELM_ARGS_HEAT} \
  ${OSH_EXTRA_HELM_ARGS_HORIZON} \
  ${OSH_EXTRA_HELM_ARGS_GLANCE} \
  ${OSH_EXTRA_HELM_ARGS_OPENVSWITCH} \
  ${OSH_EXTRA_HELM_ARGS_LIBVIRT} \
  ${OSH_EXTRA_HELM_ARGS_NOVA} \
  ${OSH_EXTRA_HELM_ARGS_PLACEMENT} \
  ${OSH_EXTRA_HELM_ARGS_NEUTRON} \
  ${OSH_EXTRA_HELM_ARGS_LIBVIRT_CGROUP} \
  ${OSH_EXTRA_HELM_VIRT_ARGS} \
  ${OSH_EXTRA_HELM_ARGS} \
  --set glance.conf.glance.keystone_authtoken.memcache_secret_key="$(openssl rand -hex 64)" \
  --set nova.bootstrap.wait_for_computes.enabled=true \
  --set libvirt.conf.ceph.enabled=${CEPH_ENABLED} \
  --set nova.conf.ceph.enabled=${CEPH_ENABLED} \
  --values=/tmp/neutron.yaml \
  --values=/tmp/glance.yaml \
  --namespace=$namespace

# If compute kit installed using Tungsten Fubric, it will be alive when Tunsten Fabric become active.
if [[ "$FEATURE_GATES" =~ (,|^)tf(,|$) ]]; then
  exit 0
fi

#NOTE: Wait for deploy
./tools/deployment/common/wait-for-pods.sh $namespace 1800

# list pods and services
echo "------------------ List kube-system pods and servics ------------"
kubectl -n kube-system get pods
kubectl -n kube-system get services

echo
echo "----------------- List openstack pods and services ---------------"
kubectl -n openstack get pods
kubectl -n openstack get services

#NOTE: Validate Deployment info
openstack service list
sleep 30 #NOTE(portdirect): Wait for ingress controller to update rules and restart Nginx
openstack compute service list
openstack network agent list
openstack hypervisor list

if [ "${RUN_HELM_TESTS}" == "no" ]; then
    exit 0
fi

./tools/deployment/common/run-helm-tests.sh $chart $release
