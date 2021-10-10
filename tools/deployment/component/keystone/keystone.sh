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

#NOTE: Get the over-rides to use
: ${OSH_EXTRA_HELM_ARGS_KEYSTONE:="$(./tools/deployment/common/get-values-overrides.sh keystone)"}
: ${RUN_HELM_TESTS:="yes"}

#NOTE: Lint and package chart
make keystone

#NOTE: Deploy command
helm upgrade --install keystone ./keystone \
    --namespace=openstack \
    ${OSH_EXTRA_HELM_ARGS:=} \
    ${OSH_EXTRA_HELM_ARGS_KEYSTONE:=}

#NOTE: Wait for deploy
./tools/deployment/common/wait-for-pods.sh openstack

export OS_CLOUD=openstack_helm
sleep 30 #NOTE(portdirect): Wait for ingress controller to update rules and restart Nginx
openstack endpoint list

#NOTE: Validate feature gate options if required
FEATURE_GATE="ldap"; if [[ ${FEATURE_GATES//,/ } =~ (^|[[:space:]])${FEATURE_GATE}($|[[:space:]]) ]]; then
  #NOTE: Do some additional queries here for LDAP
  openstack domain list
  openstack user list
  openstack user list --domain ldapdomain

  openstack group list --domain ldapdomain

  openstack role add --user bob --project admin --user-domain ldapdomain --project-domain default admin

  domain="ldapdomain"
  domainId=$(openstack domain show ${domain} -f value -c id)
  token=$(openstack token issue -f value -c id)

  #NOTE: Testing we can auth against the LDAP user
  unset OS_CLOUD
  openstack --os-auth-url http://keystone.openstack.svc.cluster.local/v3 --os-username bob --os-password password --os-user-domain-name ${domain} --os-identity-api-version 3 token issue

  #NOTE: Test the domain specific thing works
  curl --verbose -X GET \
    -H "Content-Type: application/json" \
    -H "X-Auth-Token: $token" \
    http://keystone.openstack.svc.cluster.local/v3/domains/${domainId}/config
fi

if [ "x${RUN_HELM_TESTS}" != "xno" ]; then
    ./tools/deployment/common/run-helm-tests.sh keystone
fi

FEATURE_GATE="tls"; if [[ ${FEATURE_GATES//,/ } =~ (^|[[:space:]])${FEATURE_GATE}($|[[:space:]]) ]]; then
  curl --cacert /etc/openstack-helm/certs/ca/ca.pem -L https://keystone.openstack.svc.cluster.local
  curl --cacert /etc/openstack-helm/certs/ca/ca.pem -L https://keystone-api.openstack.svc.cluster.local:5000
fi
