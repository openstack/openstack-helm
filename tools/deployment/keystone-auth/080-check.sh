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
# This issues token with admin role
TOKEN=$(keystone_token)
kubectl --kubeconfig /tmp/kubeconfig.yaml --token $TOKEN get pods
kubectl --kubeconfig /tmp/kubeconfig.yaml --token $TOKEN get pods -n openstack
kubectl --kubeconfig /tmp/kubeconfig.yaml --token $TOKEN get secrets -n openstack

# create users
openstack user create --or-show --password demoPassword demoUser
openstack user create --or-show --password demoPassword kube-system-admin

# create project
openstack project create --or-show openstack-system
openstack project create --or-show demoProject

# create roles
openstack role create --or-show openstackRole
openstack role create --or-show kube-system-admin

# assign user role to project
openstack role add --project openstack-system --user demoUser --project-domain default --user-domain default openstackRole
openstack role add --project demoProject --user kube-system-admin --project-domain default --user-domain default kube-system-admin

unset OS_CLOUD
export OS_AUTH_URL="http://keystone.openstack.svc.cluster.local/v3"
export OS_IDENTITY_API_VERSION="3"
export OS_PROJECT_NAME="openstack-system"
export OS_PASSWORD="demoPassword"
export OS_USERNAME="demoUser"

# See this does fail as the policy does not allow for a non-admin user

# Issue a member user token
TOKEN=$(keystone_token)
kubectl --kubeconfig /tmp/kubeconfig.yaml --token $TOKEN get ingress -n openstack
if ! kubectl --kubeconfig /tmp/kubeconfig.yaml --token $TOKEN get pods ; then
  echo "Denied, as expected by policy"
else
  exit 1
fi

export OS_USERNAME="kube-system-admin"
export OS_PROJECT_NAME="demoProject"
TOKEN=$(keystone_token)
kubectl --kubeconfig /tmp/kubeconfig.yaml --token $TOKEN get ingress -n kube-system
if ! kubectl --kubeconfig /tmp/kubeconfig.yaml --token $TOKEN get pods -n openstack ; then
  echo "Denied, as expected by policy"
else
  exit 1
fi
