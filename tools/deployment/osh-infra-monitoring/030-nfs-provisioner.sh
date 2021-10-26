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

make nfs-provisioner

#NOTE: Deploy nfs instance for logging, monitoring and alerting components
tee /tmp/nfs-provisioner.yaml << EOF
labels:
  node_selector_key: openstack-control-plane
  node_selector_value: enabled
storageclass:
  name: general
EOF
helm upgrade --install nfs-provisioner \
    ./nfs-provisioner --namespace=nfs \
    --values=/tmp/nfs-provisioner.yaml

#NOTE: Wait for deployment
./tools/deployment/common/wait-for-pods.sh nfs
