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

: ${OSH_PATH:="../openstack-helm"}
: ${OSH_INFRA_EXTRA_HELM_ARGS:=""}
: ${OSH_EXTRA_HELM_ARGS:=""}
: ${OSH_EXTRA_HELM_ARGS_KEYSTONE:="$(./tools/deployment/common/get-values-overrides.sh keystone)"}

# Install LDAP
make ldap
helm upgrade --install ldap ./ldap \
    --namespace=openstack \
    --set pod.replicas.server=1 \
    --set bootstrap.enabled=true \
    ${OSH_INFRA_EXTRA_HELM_ARGS} \
    ${OSH_INFRA_EXTRA_HELM_ARGS_LDAP}

# Install Keystone
cd ${OSH_PATH}
make keystone
cd -
helm upgrade --install keystone ${OSH_PATH}/keystone \
    --namespace=openstack \
    --values=${OSH_PATH}/keystone/values_overrides/ldap.yaml \
    --set network.api.ingress.classes.namespace=nginx \
    --set endpoints.oslo_db.hosts.default=mariadb-server-primary \
    ${OSH_EXTRA_HELM_ARGS} \
    ${OSH_EXTRA_HELM_ARGS_KEYSTONE}

./tools/deployment/common/wait-for-pods.sh openstack

# Testing basic functionality
export OS_CLOUD=openstack_helm
sleep 30 #NOTE(portdirect): Wait for ingress controller to update rules and restart Nginx
openstack endpoint list
