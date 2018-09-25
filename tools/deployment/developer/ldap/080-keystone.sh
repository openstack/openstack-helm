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

#NOTE: Deploy command
: ${OSH_INFRA_PATH:="../openstack-helm-infra"}
: ${OSH_EXTRA_HELM_ARGS:=""}

tee /tmp/ldap.yaml <<EOF
manifests:
  network_policy: true
network_policy:
  ldap:
    ingress:
      - from:
        - podSelector:
            matchLabels:
              application: keystone
        - podSelector:
            matchLabels:
              application: ldap
        - podSelector:
            matchLabels:
              application: ingress
        ports:
        - protocol: TCP
          port: 389
EOF

helm upgrade --install ldap ${OSH_INFRA_PATH}/ldap \
    --namespace=openstack \
    --set pod.replicas.server=1 \
    --set bootstrap.enabled=true \
    --values=/tmp/ldap.yaml \
    ${OSH_EXTRA_HELM_ARGS} \
    ${OSH_EXTRA_HELM_ARGS_LDAP}

#NOTE: Wait for deploy
./tools/deployment/common/wait-for-pods.sh openstack

#NOTE: Validate Deployment info
helm status ldap

#NOTE: Handle Keystone
make pull-images keystone

#NOTE: Deploy command
: ${OSH_EXTRA_HELM_ARGS:=""}
helm upgrade --install keystone ./keystone \
    --namespace=openstack \
    --values=./tools/overrides/keystone/ldap_domain_config.yaml \
    --set manifests.network_policy=true \
    ${OSH_EXTRA_HELM_ARGS} \
    ${OSH_EXTRA_HELM_ARGS_KEYSTONE}

#NOTE: Wait for deploy
./tools/deployment/common/wait-for-pods.sh openstack

#NOTE: Validate Deployment info
helm status keystone
export OS_CLOUD=openstack_helm
sleep 30 #NOTE(portdirect): Wait for ingress controller to update rules and restart Nginx
openstack endpoint list

#NOTE: Do some additional queries here for LDAP
openstack domain list
openstack user list
openstack user list --domain ldapdomain

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
