#!/bin/bash -x

# Copyright 2017 The Openstack-Helm Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# this helps create a qemu client (not using kvm acceleration
# so it doesn't conflict with virtualbox users) that can be
# used to test that maas is working

cat <<EOF>/tmp/maas-net.xml
<!-- Network Management VLAN -->
<network>
  <name>maas</name>
  <bridge name="maas"/>
  <forward mode="bridge"/>
</network>
EOF

virsh net-create /tmp/maas-net.xml

# purge an existing image if one exists
if [ -e /tmp/maas-node-test.qcow2 ]; then
  sudo rm /tmp/maas-node-test.qcow2
  sudo qemu-img create -f qcow2 -o preallocation=metadata /tmp/maas-node-test.qcow2 32G
fi;

virt-install \
    --name=maas-node-test \
    --connect=qemu:///system --ram=1024 --vcpus=1 --virt-type=qemu\
    --pxe --boot network,hd \
    --os-variant=ubuntutrusty --graphics vnc --noautoconsole --os-type=linux --accelerate \
    --disk=/tmp/maas-node-test.qcow2,bus=virtio,cache=none,sparse=true,size=32 \
    --network=network=maas,model=e1000 \
    --force
