#!/bin/bash

# Copyright 2017 The Openstack-Helm Authors.
#
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
function keystone_token () {
  openstack token issue -f value -c id
}
sudo cp -va $HOME/.kube/config /tmp/kubeconfig.yaml
sudo kubectl --kubeconfig /tmp/kubeconfig.yaml config unset users.kubernetes-admin

# Test
if ! kubectl --kubeconfig /tmp/kubeconfig.yaml --token "$(keystone_token)" get pods ; then
  echo "Denied, as expected by policy"
else
  exit 1
fi
kubectl --kubeconfig /tmp/kubeconfig.yaml --token "$(keystone_token)" get pods -n openstack

# create a demoUser
openstack user create --or-show --password demoPassword demoUser
unset OS_CLOUD
export OS_AUTH_URL="http://keystone.openstack.svc.cluster.local/v3"
export OS_IDENTITY_API_VERSION="3"
export OS_PASSWORD="demoPassword"
export OS_USERNAME="demoUser"

# See this does fail as the policy does not allow for a non-admin user
TOKEN=$(openstack token issue -f value -c id)
if ! kubectl --kubeconfig /tmp/kubeconfig.yaml --token "$(keystone_token)" get pods -n openstack ; then
  echo "Denied, as expected by policy"
else
  exit 1
fi
