#!/bin/bash

{{/*
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/}}

set -ex

if ! openstack network show ${neutron_network_name}; then
  IRONIC_NEUTRON_CLEANING_NET_ID=$(openstack network create -f value -c id \
    --share \
    --provider-network-type flat \
    --provider-physical-network ${neutron_provider_network} \
    ${neutron_network_name})
else
  IRONIC_NEUTRON_CLEANING_NET_ID=$(openstack network show ${neutron_network_name} -f value -c id)
fi

SUBNET_ID=$(openstack subnet list -f value -c ID \
  --network ${IRONIC_NEUTRON_CLEANING_NET_ID} \
  --name ${neutron_subnet_name})

if [ -n "${SUBNET_ID}" ]; then
  openstack subnet show ${SUBNET_ID}
else
  openstack subnet create \
    --gateway ${neutron_subnet_gateway%/*} \
    --allocation-pool start=${neutron_subnet_alloc_start},end=${neutron_subnet_alloc_end} \
    --dns-nameserver ${neutron_subnet_dns_nameserver} \
    --subnet-range ${neutron_subnet_cidr} \
    --network ${neutron_network_name} \
    ${neutron_subnet_name}
fi
