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
export OSH_IRONIC_NODE_ARCH=${OSH_IRONIC_NODE_ARCH:="x86_64"}

#NOTE: setup a host aggregate for baremetal nodes to use
openstack aggregate create \
  --property baremetal=true \
  --property cpu_arch=${OSH_IRONIC_NODE_ARCH} \
  baremetal-hosts
IRONIC_COMPUTES=$(openstack compute service list | grep compute | grep $(hostname) | grep -v down | awk '{print $6}')
for COMPUTE in $IRONIC_COMPUTES; do
  openstack aggregate add host baremetal-hosts ${COMPUTE}
done
