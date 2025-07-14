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

set -ex

#NOTE: Install freezer client and check if it works
(
    cd ${HOME}
    rm -rf freezer
    git clone https://opendev.org/openstack/freezer.git -b stable/${OPENSTACK_RELEASE}
    cd freezer
    sudo pip install -r requirements.txt
    sudo python3 setup.py install
)

unset OS_DOMAIN_NAME
export OS_AUTH_URL=http://keystone.openstack.svc.cluster.local/v3
export OS_PROJECT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=password
export OS_PROJECT_DOMAIN_NAME=default
export OS_USER_DOMAIN_NAME=default
export OS_IDENTITY_API_VERSION=3
export OS_AUTH_VERSION=3

freezer job-list
