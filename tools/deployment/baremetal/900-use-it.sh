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

#NOTE: Validate Deployment info
export OS_CLOUD=openstack_helm

export OSH_VM_KEY_STACK="heat-vm-key"
# Setup SSH Keypair in Nova
mkdir -p ${HOME}/.ssh
openstack keypair create --private-key ${HOME}/.ssh/osh_key ${OSH_VM_KEY_STACK}
chmod 600 ${HOME}/.ssh/osh_key

# Deploy heat stack to provision node
openstack stack create --wait --timeout 15 \
    -t ./tools/deployment/baremetal/heat-basic-bm-deployment.yaml \
    heat-basic-bm-deployment

FLOATING_IP=$(openstack stack output show \
    heat-basic-bm-deployment \
    ip \
    -f value -c output_value)

# Wait for the nodes SSH port to come up
function wait_for_ssh_port {
  # Default wait timeout is 300 seconds
  set +x
  end=$(date +%s)
  if ! [ -z $2 ]; then
   end=$((end + $2))
  else
   end=$((end + 300))
  fi
  while true; do
      # Use Nmap as its the same on Ubuntu and RHEL family distros
      nmap -Pn -p22 $1 | awk '$1 ~ /22/ {print $2}' | grep -q 'open' && \
          break || true
      sleep 1
      now=$(date +%s)
      [ $now -gt $end ] && echo "Could not connect to $1 port 22 in time" && exit -1
  done
  set -x
}
wait_for_ssh_port $FLOATING_IP

# SSH into the VM and check it can reach the outside world
ssh-keyscan "$FLOATING_IP" >> ~/.ssh/known_hosts
BM_GATEWAY="$(ssh -i ${HOME}/.ssh/osh_key cirros@${FLOATING_IP} ip -4 route list 0/0 | awk '{ print $3; exit }')"
ssh -i ${HOME}/.ssh/osh_key cirros@${FLOATING_IP} ping -q -c 1 -W 2 ${BM_GATEWAY}

# Check the VM can reach the metadata server
ssh -i ${HOME}/.ssh/osh_key cirros@${FLOATING_IP} curl --verbose --connect-timeout 5 169.254.169.254
