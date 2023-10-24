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

#NOTE: We only want to run ceph and control plane components on the primary node
for LABEL in openstack-control-plane ceph-osd ceph-mon ceph-mds ceph-rgw ceph-mgr; do
  kubectl label nodes ${LABEL}- --all --overwrite
  PRIMARY_NODE="$(kubectl get nodes -l openstack-helm-node-class=primary -o name | awk -F '/' '{ print $NF; exit }')"
  kubectl label node "${PRIMARY_NODE}" ${LABEL}=enabled
done

#NOTE: Build charts
make all

#NOTE: Deploy libvirt with vbmc then define domains to use as baremetal nodes
: "${OSH_INFRA_PATH:="../openstack-helm-infra"}"
make -C ${OSH_INFRA_PATH} libvirt
helm install ${OSH_INFRA_PATH}/libvirt \
  --namespace=libvirt \
  --name=libvirt \
  --set network.backend=null \
  --set conf.ceph.enabled=false \
  --set images.tags.libvirt=docker.io/openstackhelm/vbmc:centos-0.1

#NOTE: Wait for deploy
sleep 5 #NOTE(portdirect): work around k8s not immedately assigning pods to nodes
./tools/deployment/common/wait-for-pods.sh libvirt

#NOTE: Create domains and start vbmc for ironic to manage as baremetal nodes
LIBVIRT_PODS=$(kubectl get --namespace libvirt pods \
  -l application=libvirt,component=libvirt \
  --no-headers -o name | awk -F '/' '{ print $NF }')
rm -f /tmp/bm-hosts.txt || true
for LIBVIRT_POD in ${LIBVIRT_PODS}; do
  TEMPLATE_MAC_ADDR="00:01:DE:AD:BE:EF"
  MAC_ADDR=$(printf '00:01:DE:%02X:%02X:%02X\n' $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256)))
  LIBVIRT_POD_NODE=$(kubectl get -n libvirt pod "${LIBVIRT_POD}" -o json | jq -r '.spec.nodeName')
  LIBVIRT_NODE_IP=$(kubectl get node "${LIBVIRT_POD_NODE}" -o json |  jq -r '.status.addresses[] | select(.type=="InternalIP").address')
  kubectl exec -n libvirt "${LIBVIRT_POD}" -- mkdir -p /var/lib/libvirt/images
  kubectl exec -n libvirt "${LIBVIRT_POD}" -- rm -f /var/lib/libvirt/images/vm-1.qcow2 || true
  kubectl exec -n libvirt "${LIBVIRT_POD}" -- qemu-img create -f qcow2 /var/lib/libvirt/images/vm-1.qcow2 5G
  kubectl exec -n libvirt "${LIBVIRT_POD}" -- chown -R qemu: /var/lib/libvirt/images/vm-1.qcow2
  VM_DEF="$(sed "s|${TEMPLATE_MAC_ADDR}|${MAC_ADDR}|g" ./tools/deployment/baremetal/fake-baremetal-1.xml | base64 -w0)"
  kubectl exec -n libvirt "${LIBVIRT_POD}" -- sh -c "echo ${VM_DEF} | base64 -d > /tmp/fake-baremetal-1.xml"
  kubectl exec -n libvirt "${LIBVIRT_POD}" -- sh -c "virsh undefine fake-baremetal-1 || true"
  kubectl exec -n libvirt "${LIBVIRT_POD}" -- virsh define /tmp/fake-baremetal-1.xml
  kubectl exec -n libvirt "${LIBVIRT_POD}" -- sh -c "vbmc delete fake-baremetal-1 || true"
  kubectl exec -n libvirt "${LIBVIRT_POD}" -- vbmc add fake-baremetal-1 --address "${LIBVIRT_NODE_IP}"
  kubectl exec -n libvirt "${LIBVIRT_POD}" -- sh -c "nohup vbmc start fake-baremetal-1 &>/dev/null &"
  kubectl exec -n libvirt "${LIBVIRT_POD}" -- virsh list --all
  kubectl exec -n libvirt "${LIBVIRT_POD}" -- vbmc show fake-baremetal-1
  echo "${LIBVIRT_NODE_IP} ${MAC_ADDR}" >> /tmp/bm-hosts.txt
done

#NOTE: Deploy OvS to connect nodes to the deployment host
: ${OSH_INFRA_PATH:="../openstack-helm-infra"}
make -C ${OSH_INFRA_PATH} openvswitch

helm install ${OSH_INFRA_PATH}/openvswitch \
  --namespace=openstack \
  --name=openvswitch

#NOTE: Wait for deploy
./tools/deployment/common/wait-for-pods.sh openstack

#NOTE: Setup GRE tunnels between deployment node and libvirt hosts
OSH_IRONIC_PXE_DEV="${OSH_IRONIC_PXE_DEV:="ironic-pxe"}"
OSH_IRONIC_PXE_ADDR="${OSH_IRONIC_PXE_ADDR:="172.24.6.1/24"}"
MASTER_IP=$(kubectl get node "$(hostname -f)" -o json |  jq -r '.status.addresses[] | select(.type=="InternalIP").address')
NODE_IPS=$(kubectl get nodes -o json | jq -r '.items[].status.addresses[] | select(.type=="InternalIP").address' | sort -V)
OVS_VSWITCHD_PODS=$(kubectl get --namespace openstack pods \
  -l application=openvswitch,component=openvswitch-vswitchd \
  --no-headers -o name  | awk -F '/' '{ print $NF }')
for OVS_VSWITCHD_POD in ${OVS_VSWITCHD_PODS}; do
  kubectl exec --namespace openstack "${OVS_VSWITCHD_POD}" \
    -- ovs-vsctl add-br "${OSH_IRONIC_PXE_DEV}"
  if [ "x$(kubectl --namespace openstack get pod "${OVS_VSWITCHD_POD}" -o json | jq -r '.spec.nodeName')" == "x$(hostname -f)" ] ; then
    COUNTER=0
    for NODE_IP in ${NODE_IPS}; do
      if ! [ "x${MASTER_IP}" == "x${NODE_IP}" ]; then
        kubectl exec --namespace openstack "${OVS_VSWITCHD_POD}" \
          -- ovs-vsctl add-port "${OSH_IRONIC_PXE_DEV}" "gre${COUNTER}" \
            -- set interface "gre${COUNTER}" type=gre options:remote_ip="${NODE_IP}"
        let COUNTER=COUNTER+1
      fi
    done
    kubectl exec --namespace openstack "${OVS_VSWITCHD_POD}" \
      -- ip addr add "${OSH_IRONIC_PXE_ADDR}" dev "${OSH_IRONIC_PXE_DEV}"
    #NOTE(portdirect): for simplity assume we are using the default dev
    # for tunnels, and a MTU overhead of 50
    MASTER_NODE_DEV="$(kubectl exec --namespace openstack "${OVS_VSWITCHD_POD}" \
      -- ip -4 route list 0/0 | awk '{ print $5; exit }')"
    MASTER_NODE_MTU="$(kubectl exec --namespace openstack "${OVS_VSWITCHD_POD}" \
      -- cat "/sys/class/net/${MASTER_NODE_DEV}/mtu")"
    kubectl exec --namespace openstack "${OVS_VSWITCHD_POD}" \
      -- ip link set dev ${OSH_IRONIC_PXE_DEV} mtu $((MASTER_NODE_MTU - 50))
    kubectl exec --namespace openstack "${OVS_VSWITCHD_POD}" \
      -- ip link set "${OSH_IRONIC_PXE_DEV}" up
  else
    kubectl exec --namespace openstack "${OVS_VSWITCHD_POD}" \
      -- ovs-vsctl add-port "${OSH_IRONIC_PXE_DEV}" gre0 \
        -- set interface gre0 type=gre options:remote_ip="${MASTER_IP}"
  fi
done

#NOTE: Set up the ${OSH_IRONIC_PXE_DEV} to forward traffic
DEFAULT_ROUTE_DEV="$(sudo ip -4 route list 0/0 | awk '{ print $5; exit }')"
sudo iptables -t nat -A POSTROUTING -o "${DEFAULT_ROUTE_DEV}" -j MASQUERADE
sudo iptables -A FORWARD -i "${DEFAULT_ROUTE_DEV}" -o "${OSH_IRONIC_PXE_DEV}" -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -i "${OSH_IRONIC_PXE_DEV}" -o "${DEFAULT_ROUTE_DEV}" -j ACCEPT
