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

sudo -H -E pip3 install \
-c${UPPER_CONSTRAINTS_FILE:=https://releases.openstack.org/constraints/upper/master} \
python-openstackclient python-heatclient python-ironicclient

sudo -H mkdir -p /etc/openstack
cat << EOF | sudo -H tee -a /etc/openstack/clouds.yaml
clouds:
  openstack_helm:
    region_name: RegionOne
    identity_api_version: 3
    auth:
      username: 'admin'
      password: 'password'
      project_name: 'admin'
      project_domain_name: 'default'
      user_domain_name: 'default'
      auth_url: 'http://keystone.openstack.svc.cluster.local/v3'
EOF
sudo -H chown -R $(id -un): /etc/openstack

#NOTE: Build charts
make all
