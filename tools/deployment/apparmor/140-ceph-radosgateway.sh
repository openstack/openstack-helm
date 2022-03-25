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
: ${OSH_INFRA_EXTRA_HELM_ARGS_CEPH_RGW:="$(./tools/deployment/common/get-values-overrides.sh ceph-rgw)"}

#NOTE: Lint and package chart
: ${OSH_INFRA_PATH:="../openstack-helm-infra"}
make -C ${OSH_INFRA_PATH} ceph-rgw

#NOTE: Deploy command
: ${OSH_INFRA_EXTRA_HELM_ARGS:=""}
tee /tmp/radosgw-openstack.yaml <<EOF
endpoints:
  identity:
    namespace: openstack
  object_store:
    namespace: openstack
  ceph_mon:
    namespace: ceph
network:
  public: 172.17.0.1/16
  cluster: 172.17.0.1/16
deployment:
  ceph: true
  rgw_keystone_user_and_endpoints: true
bootstrap:
  enabled: false
conf:
  rgw_ks:
    enabled: true
pod:
  replicas:
    rgw: 1
EOF
helm upgrade --install radosgw-openstack ${OSH_INFRA_PATH}/ceph-rgw \
  --namespace=openstack \
  --values=/tmp/radosgw-openstack.yaml \
  ${OSH_INFRA_EXTRA_HELM_ARGS} \
  ${OSH_INFRA_EXTRA_HELM_ARGS_CEPH_RGW}

#NOTE: Wait for deploy
./tools/deployment/common/wait-for-pods.sh openstack

#NOTE: Validate Deployment info
export OS_CLOUD=openstack_helm
sleep 60 #NOTE(portdirect): Wait for ingress controller to update rules and restart Nginx

openstack service list
openstack endpoint list

# Delete the test pod if it still exists
kubectl delete pods -l application=ceph,release_group=radosgw-openstack,component=rgw-test --namespace=openstack --ignore-not-found
helm test radosgw-openstack --namespace openstack --timeout 900s
