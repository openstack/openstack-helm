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

source ./tools/deployment/armada/generate-passwords.sh
: ${OSH_INFRA_PATH:="../openstack-helm-infra"}
: ${OSH_PATH:="./"}

export CEPH_NETWORK=$(./tools/deployment/multinode/kube-node-subnet.sh)
export TUNNEL_DEVICE=$(ip -4 route list 0/0 | awk '{ print $5; exit }')
export OSH_INFRA_PATH
export OSH_PATH

manifests="armada-cluster-ingress armada-ceph armada-lma armada-osh"
for manifest in $manifests; do
  echo "Rendering $manifest manifest"
  envsubst < ./tools/deployment/armada/multinode/$manifest.yaml > /tmp/$manifest.yaml
done
