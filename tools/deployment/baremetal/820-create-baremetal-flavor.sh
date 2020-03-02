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

export OS_CLOUD=openstack_helm
export OSH_IRONIC_NODE_DISC=${OSH_IRONIC_NODE_DISC:="5"}
export OSH_IRONIC_NODE_RAM=${OSH_IRONIC_NODE_RAM:="4096"}
export OSH_IRONIC_NODE_CPU=${OSH_IRONIC_NODE_CPU:="2"}
export OSH_IRONIC_NODE_ARCH=${OSH_IRONIC_NODE_ARCH:="x86_64"}

#NOTE: Create a flavor assocated with our baremetal nodes
openstack flavor create \
  --disk ${OSH_IRONIC_NODE_DISC} \
  --ram ${OSH_IRONIC_NODE_RAM} \
  --vcpus ${OSH_IRONIC_NODE_CPU} \
  --property cpu_arch=${OSH_IRONIC_NODE_ARCH} \
  --property baremetal=true \
  baremetal
