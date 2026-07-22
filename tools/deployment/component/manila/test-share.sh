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
#
# End-to-end test for the manila chart:
#   1. Stand up public net / subnetpool / SSH keypair (Heat).
#   2. Ensure an Ubuntu cloud image is registered in Glance.
#   3. Create the manila-nfs-vms stack: NFS share + 2 VMs that mount it.
#   4. SSH into VM1, write a file on the share.
#   5. SSH into VM2, read the file, verify content.

set -xe

export OS_CLOUD=openstack_helm

: ${HEAT_DIR:="$(readlink -f ./tools/deployment/common)"}
: ${SSH_DIR:="${HOME}/.ssh"}

# Run the openstack client container with HEAT_DIR, SSH_DIR and /tmp
# mounted so that `openstack stack create -t ...`, `ssh -i ...`, and
# `openstack image create --file /tmp/...` all work inside it.
OPENSTACK_CLIENT_CONTAINER_EXTRA_ARGS="${OPENSTACK_CLIENT_CONTAINER_EXTRA_ARGS:-} \
  -v ${HEAT_DIR}:${HEAT_DIR} -v ${SSH_DIR}:${SSH_DIR} -v /tmp:/tmp"
export OPENSTACK_CLIENT_CONTAINER_EXTRA_ARGS

# --- 1. Public network, subnet pool, keypair (reuse existing templates) ---
: ${OSH_EXT_NET_NAME:="public"}
: ${OSH_EXT_SUBNET_NAME:="public-subnet"}
: ${OSH_EXT_SUBNET:="172.24.4.0/24"}
: ${OSH_BR_EX_ADDR:="172.24.4.1/24"}
: ${OSH_ALLOCATION_POOL_START:="172.24.4.10"}
: ${OSH_ALLOCATION_POOL_END:="172.24.4.254"}
openstack stack show "heat-public-net-deployment" || \
  openstack stack create --wait \
    --parameter network_name=${OSH_EXT_NET_NAME} \
    --parameter physical_network_name=public \
    --parameter subnet_name=${OSH_EXT_SUBNET_NAME} \
    --parameter subnet_cidr=${OSH_EXT_SUBNET} \
    --parameter subnet_gateway=${OSH_BR_EX_ADDR%/*} \
    --parameter allocation_pool_start=${OSH_ALLOCATION_POOL_START} \
    --parameter allocation_pool_end=${OSH_ALLOCATION_POOL_END} \
    -t ${HEAT_DIR}/heat-public-net-deployment.yaml \
    heat-public-net-deployment

: ${OSH_PRIVATE_SUBNET_POOL:="192.168.128.0/20"}
: ${OSH_PRIVATE_SUBNET_POOL_NAME:="shared-default-subnetpool"}
: ${OSH_PRIVATE_SUBNET_POOL_DEF_PREFIX:="24"}
openstack stack show "heat-subnet-pool-deployment" || \
  openstack stack create --wait \
    --parameter subnet_pool_name=${OSH_PRIVATE_SUBNET_POOL_NAME} \
    --parameter subnet_pool_prefixes=${OSH_PRIVATE_SUBNET_POOL} \
    --parameter subnet_pool_default_prefix_length=${OSH_PRIVATE_SUBNET_POOL_DEF_PREFIX} \
    -t ${HEAT_DIR}/heat-subnet-pool-deployment.yaml \
    heat-subnet-pool-deployment

: ${OSH_VM_KEY_STACK:="heat-vm-key"}
mkdir -p ${SSH_DIR}
openstack keypair show "${OSH_VM_KEY_STACK}" || \
  openstack keypair create --private-key ${SSH_DIR}/osh_key ${OSH_VM_KEY_STACK}
sudo chown $(id -un) ${SSH_DIR}/osh_key
chmod 600 ${SSH_DIR}/osh_key

# --- 2. Register the prebuilt VM image with NFS client baked in ---
# The image is published as an OCI container artifact at
#   quay.io/airshipit/osh-vm-images:ubuntu_noble_nfs
# with the qcow2 file at /disk/disk.img inside the image (same layout
# KubeVirt's containerDisk uses). Built from the upstream Ubuntu Noble
# cloud image with `virt-customize --install nfs-common`. Using a
# prebuilt image skips per-VM `apt-get update` and `apt-get install
# nfs-common` at first boot, which was the slowest step in this test.
: ${OSH_MANILA_IMAGE_NAME:="ubuntu-noble-nfs"}
: ${OSH_MANILA_IMAGE_OCI:="quay.io/airshipit/osh-vm-images:ubuntu_noble_nfs"}
: ${OSH_MANILA_IMAGE_FILE:="ubuntu_noble_nfs.qcow2"}
if ! openstack image show ${OSH_MANILA_IMAGE_NAME} >/dev/null 2>&1; then
  if [ ! -f "/tmp/${OSH_MANILA_IMAGE_FILE}" ]; then
    sudo docker pull ${OSH_MANILA_IMAGE_OCI}
    CID=$(sudo docker create ${OSH_MANILA_IMAGE_OCI})
    sudo docker cp "${CID}:/disk/disk.img" "/tmp/${OSH_MANILA_IMAGE_FILE}"
    sudo docker rm "${CID}" >/dev/null
    sudo chown "$(id -un)" "/tmp/${OSH_MANILA_IMAGE_FILE}"
  fi
  openstack image create -f value -c id \
    --public \
    --container-format=bare \
    --disk-format qcow2 \
    --min-disk 5 \
    --file /tmp/${OSH_MANILA_IMAGE_FILE} \
    ${OSH_MANILA_IMAGE_NAME}
fi

# --- 3. Create the manila-nfs-vms stack ---
# We deliberately do NOT use `openstack stack create --wait`, because the
# openstack-client wait code path crashes with "maximum recursion depth
# exceeded" on stacks with many resources. Create the stack and poll its
# status ourselves.
: ${OSH_MANILA_STACK:="manila-nfs-vms"}
: ${OSH_MANILA_PRIVATE_SUBNET:="192.168.130.0/24"}
: ${OSH_MANILA_STACK_TIMEOUT:=1800}
if ! openstack stack show "${OSH_MANILA_STACK}" >/dev/null 2>&1; then
  openstack stack create \
    --parameter public_net=${OSH_EXT_NET_NAME} \
    --parameter image=${OSH_MANILA_IMAGE_NAME} \
    --parameter ssh_key=${OSH_VM_KEY_STACK} \
    --parameter cidr=${OSH_MANILA_PRIVATE_SUBNET} \
    --parameter dns_nameserver=${OSH_BR_EX_ADDR%/*} \
    -t ${HEAT_DIR}/heat-manila-nfs-vms.yaml \
    ${OSH_MANILA_STACK}
fi

stack_deadline=$(date -d "+${OSH_MANILA_STACK_TIMEOUT} sec" +%s)
while true; do
  STATUS=$(openstack stack show "${OSH_MANILA_STACK}" -c stack_status -f value 2>/dev/null || true)
  case "${STATUS}" in
    CREATE_COMPLETE)
      echo "stack ${OSH_MANILA_STACK}: ${STATUS}"
      break
      ;;
    CREATE_IN_PROGRESS)
      echo "stack ${OSH_MANILA_STACK}: ${STATUS}, waiting..."
      ;;
    CREATE_FAILED|*FAILED*)
      echo "stack ${OSH_MANILA_STACK}: ${STATUS}"
      openstack stack failures list "${OSH_MANILA_STACK}" || true
      exit 1
      ;;
    *)
      echo "stack ${OSH_MANILA_STACK}: status=${STATUS:-unknown}, waiting..."
      ;;
  esac
  if [ "$(date +%s)" -gt "${stack_deadline}" ]; then
    echo "Timed out waiting for ${OSH_MANILA_STACK} to reach CREATE_COMPLETE"
    openstack stack failures list "${OSH_MANILA_STACK}" || true
    exit 1
  fi
  sleep 20
done

VM1_FIP=$(openstack stack output show ${OSH_MANILA_STACK} vm1_floating_ip -f value -c output_value)
VM2_FIP=$(openstack stack output show ${OSH_MANILA_STACK} vm2_floating_ip -f value -c output_value)
VM1_PORT_IP=$(openstack stack output show ${OSH_MANILA_STACK} vm1_port_ip -f value -c output_value)
VM2_PORT_IP=$(openstack stack output show ${OSH_MANILA_STACK} vm2_port_ip -f value -c output_value)
SHARE_ID=$(openstack stack output show ${OSH_MANILA_STACK} share_id -f value -c output_value)
SHARE_EXPORT=$(openstack stack output show ${OSH_MANILA_STACK} share_export -f value -c output_value)

echo "VM1 FIP=${VM1_FIP} (port ${VM1_PORT_IP})"
echo "VM2 FIP=${VM2_FIP} (port ${VM2_PORT_IP})"
echo "share id=${SHARE_ID} export=${SHARE_EXPORT}"

# All tenant traffic to the NFS export goes through the host's nginx tcp
# proxy (roles/deploy-env, tcpproxy_manila_cidr). nginx connects to the
# Ganesha pod without TPROXY, so Ganesha sees connections coming from the
# host's overlay (brvxlan) IP -- never the VM IPs. A single CIDR-wide
# access rule for the K8s overlay subnet covers all VMs that mount via
# the proxy.
: ${OSH_MANILA_NFS_ACCESS_CIDR:="10.248.0.0/24"}
openstack share access create "${SHARE_ID}" ip "${OSH_MANILA_NFS_ACCESS_CIDR}" --access-level rw

# --- 4. Accept older SSH algos for compatibility, then wait for both VMs ---
sudo tee -a /etc/ssh/ssh_config <<EOF
    KexAlgorithms +diffie-hellman-group1-sha1
    HostKeyAlgorithms +ssh-rsa
    PubkeyAcceptedKeyTypes +ssh-rsa
EOF

SSH_OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=30 -o ServerAliveInterval=15 -o ServerAliveCountMax=4 -i ${SSH_DIR}/osh_key"
# Default login user differs per cloud image: ubuntu/debian/cirros/alpine/...
: ${IMAGE_USER:="ubuntu"}

# Retry an SSH command to ride out transient connectivity blips to the test
# VMs. The two VMs share heavily loaded gate nodes (rook-ceph + NFS-Ganesha +
# nova), so a floating IP can briefly stop answering ("connect ... timed out")
# even after the VM was reachable moments earlier. Retries up to ~10 minutes;
# stdout is captured and re-emitted so callers can use the command output.
retry_ssh() {
  local deadline out rc
  deadline=$(( $(date +%s) + 600 ))
  while true; do
    out=$(ssh ${SSH_OPTS} "$@")
    rc=$?
    if [ "${rc}" -eq 0 ]; then
      printf '%s' "${out}"
      return 0
    fi
    if [ "$(date +%s)" -ge "${deadline}" ]; then
      echo "retry_ssh: giving up after 600s (rc=${rc}): ssh $*" >&2
      return 1
    fi
    sleep 10
  done
}

wait_for_cloud_init() {
  local fip="$1"
  local timeout="$(date -d '+1500 sec' +%s)"
  while true; do
    nmap -Pn -p22 "${fip}" | awk '$1 ~ /22/ {print $2}' | grep -q open && \
      ssh ${SSH_OPTS} ${IMAGE_USER}@${fip} true && \
      ssh ${SSH_OPTS} ${IMAGE_USER}@${fip} 'cloud-init status --wait' | grep -q 'done' && \
      ssh ${SSH_OPTS} ${IMAGE_USER}@${fip} 'mountpoint -q /mnt/manila' && \
      break || true
    sleep 20
    if [ "$(date +%s)" -gt "${timeout}" ]; then
      echo "Timed out waiting for ${fip} to be ready (cloud-init + nfs mount)"
      ssh ${SSH_OPTS} ${IMAGE_USER}@${fip} 'sudo cloud-init status --long; sudo journalctl -u cloud-final --no-pager | tail -200; mount' || true
      exit 1
    fi
  done
}

wait_for_cloud_init "${VM1_FIP}"
wait_for_cloud_init "${VM2_FIP}"

# --- 5. Cross-VM read/write through the NFS share ---
TEST_PAYLOAD="manila-cephfsnfs-ok-$(date +%s)-${RANDOM}"
retry_ssh ${IMAGE_USER}@${VM1_FIP} \
  "echo '${TEST_PAYLOAD}' | sudo tee /mnt/manila/test.txt > /dev/null && sync"

READ_BACK=$(retry_ssh ${IMAGE_USER}@${VM2_FIP} 'cat /mnt/manila/test.txt')

if [ "${READ_BACK}" != "${TEST_PAYLOAD}" ]; then
  echo "FAIL: content mismatch"
  echo "  wrote:  ${TEST_PAYLOAD}"
  echo "  read:   ${READ_BACK}"
  exit 1
fi

echo "PASS: VM2 read '${READ_BACK}' from share written by VM1"
