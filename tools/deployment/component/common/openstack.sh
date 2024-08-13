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
export OS_CLOUD=openstack_helm
: "${RUN_HELM_TESTS:="no"}"
: "${CEPH_ENABLED:="false"}"
: "${OSH_EXTRA_HELM_ARGS:=""}"
release=openstack
namespace=$release


: ${GLANCE_BACKEND:="pvc"}

#NOTE: Deploy neutron
tee /tmp/neutron.yaml << EOF
neutron:
  release_group: neutron
  enabled: true
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
## includes second argument 'subchart' to indicate a different path
: ${OSH_EXTRA_HELM_ARGS_MARIADB:="$(helm osh get-values-overrides ${DOWNLOAD_OVERRIDES:-} -p ${OSH_PATH} -c openstack -s mariadb ${FEATURES})"}
: ${OSH_EXTRA_HELM_ARGS_RABBITMQ:="$(helm osh get-values-overrides ${DOWNLOAD_OVERRIDES:-} -p ${OSH_PATH} -c openstack -s rabbitmq ${FEATURES})"}
: ${OSH_EXTRA_HELM_ARGS_MEMCACHED:="$(helm osh get-values-overrides ${DOWNLOAD_OVERRIDES:-} -p ${OSH_PATH} -c openstack -s memcached ${FEATURES})"}
: ${OSH_EXTRA_HELM_ARGS_KEYSTONE:="$(helm osh get-values-overrides ${DOWNLOAD_OVERRIDES:-} -p ${OSH_PATH} -c openstack -s keystone ${FEATURES})"}
: ${OSH_EXTRA_HELM_ARGS_HEAT:="$(helm osh get-values-overrides ${DOWNLOAD_OVERRIDES:-} -p ${OSH_PATH} -c openstack -s heat ${FEATURES})"}
: ${OSH_EXTRA_HELM_ARGS_GLANCE:="$(helm osh get-values-overrides ${DOWNLOAD_OVERRIDES:-} -p ${OSH_PATH} -c openstack -s glance ${FEATURES})"}
: ${OSH_EXTRA_HELM_ARGS_OPENVSWITCH:="$(helm osh get-values-overrides ${DOWNLOAD_OVERRIDES:-} -p ${OSH_PATH} -c openstack -s openvswitch ${FEATURES})"}
: ${OSH_EXTRA_HELM_ARGS_LIBVIRT:="$(helm osh get-values-overrides ${DOWNLOAD_OVERRIDES:-} -p ${OSH_PATH} -c openstack -s libvirt ${FEATURES})"}
: ${OSH_EXTRA_HELM_ARGS_NOVA:="$(helm osh get-values-overrides ${DOWNLOAD_OVERRIDES:-} -p ${OSH_PATH} -c openstack -s nova ${FEATURES})"}
: ${OSH_EXTRA_HELM_ARGS_PLACEMENT:="$(helm osh get-values-overrides ${DOWNLOAD_OVERRIDES:-} -p ${OSH_PATH} -c openstack -s placement ${FEATURES})"}
: ${OSH_EXTRA_HELM_ARGS_NEUTRON:="$(helm osh get-values-overrides ${DOWNLOAD_OVERRIDES:-} -p ${OSH_PATH} -c openstack -s neutron ${FEATURES})"}
: ${OSH_EXTRA_HELM_ARGS_HORIZON:="$(helm osh get-values-overrides ${DOWNLOAD_OVERRIDES:-} -p ${OSH_PATH} -c openstack -s horizon ${FEATURES})"}

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
helm upgrade --install $release ${OSH_HELM_REPO}/openstack \
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
  --set glance.storage=${GLANCE_BACKEND} \
  --set nova.bootstrap.wait_for_computes.enabled=true \
  --set libvirt.conf.ceph.enabled=${CEPH_ENABLED} \
  --set nova.conf.ceph.enabled=${CEPH_ENABLED} \
  --values=/tmp/neutron.yaml \
  --set mariadb.pod.replicas.server=1 \
  --set mariadb.volume.enabled=false \
  --set mariadb.volume.use_local_path_for_single_pod_cluster.enabled=true \
  --set rabbitmq.pod.replicas.server=1 \
  --set rabbitmq.volume.enabled=false \
  --set rabbitmq.volume.use_local_path.enabled=true \
  --namespace=$namespace \
  --timeout=1200s

#NOTE: Wait for deploy
helm osh wait-for-pods $namespace 1800

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
