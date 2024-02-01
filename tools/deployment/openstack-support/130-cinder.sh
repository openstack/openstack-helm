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
#NOTE: Get the over-rides to use
: ${OSH_EXTRA_HELM_ARGS_CINDER:="$(./tools/deployment/common/get-values-overrides.sh cinder)"}

#NOTE: Lint and package chart
cd ${OSH_PATH}
make cinder
cd -

#NOTE: Deploy command
: ${OSH_EXTRA_HELM_ARGS:=""}
tee /tmp/cinder.yaml <<EOF
conf:
  ceph:
    pools:
      backup:
        replication: 1
        crush_rule: same_host
        chunk_size: 8
        app_name: cinder-backup
      cinder.volumes:
        replication: 1
        crush_rule: same_host
        chunk_size: 8
        app_name: cinder-volume
EOF

helm upgrade --install cinder ${OSH_PATH}/cinder \
  --namespace=openstack \
  --values=/tmp/cinder.yaml \
  --set network.api.ingress.classes.namespace=nginx \
  ${OSH_EXTRA_HELM_ARGS} \
  ${OSH_EXTRA_HELM_ARGS_CINDER}

#NOTE: Wait for deploy
./tools/deployment/common/wait-for-pods.sh openstack

#NOTE: Validate Deployment info
export OS_CLOUD=openstack_helm
openstack service list
sleep 30 #NOTE(portdirect): Wait for ingress controller to update rules and restart Nginx
openstack volume type list

kubectl delete pods -l application=cinder,release_group=cinder,component=test --namespace=openstack --ignore-not-found
helm test cinder --namespace openstack --timeout 900s
