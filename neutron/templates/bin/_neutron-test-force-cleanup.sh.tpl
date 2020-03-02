#!/bin/bash

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

set -ex


if openstack project show "${OS_TEST_PROJECT_NAME}" --domain="${OS_TEST_PROJECT_DOMAIN_NAME}" ; then
  OS_TEST_PROJECT_ID=$(openstack project show "${OS_TEST_PROJECT_NAME}" -f value -c id --domain="${OS_TEST_PROJECT_DOMAIN_NAME}")
  ospurge --purge-project "${OS_TEST_PROJECT_ID}"
  openstack quota set "${OS_TEST_PROJECT_ID}" --networks "${NETWORK_QUOTA}" --ports "${PORT_QUOTA}" --routers "${ROUTER_QUOTA}" --subnets "${SUBNET_QUOTA}" --secgroups "${SEC_GROUP_QUOTA}"
fi
