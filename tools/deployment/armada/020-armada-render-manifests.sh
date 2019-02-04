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

: ${OSH_INFRA_PATH:="../openstack-helm-infra"}
: ${OSH_PATH:="./"}

source ./tools/deployment/armada/generate-osh-passwords.sh

[ -s /tmp/ceph-fs-uuid.txt ] || uuidgen > /tmp/ceph-fs-uuid.txt
#NOTE(portdirect): to use RBD devices with Ubuntu kernels < 4.5 this
# should be set to 'hammer'
. /etc/os-release
if [ "x${ID}" == "xubuntu" ] && \
   [ "$(uname -r | awk -F "." '{ print $2 }')" -lt "5" ]; then
  export CRUSH_TUNABLES=hammer
else
  export CRUSH_TUNABLES=null
fi

export CEPH_NETWORK=$(./tools/deployment/multinode/kube-node-subnet.sh)
export CEPH_FS_ID="$(cat /tmp/ceph-fs-uuid.txt)"
export RELEASE_UUID=$(uuidgen)
export TUNNEL_DEVICE=$(ip -4 route list 0/0 | awk '{ print $5; exit }')
export OSH_INFRA_PATH
export OSH_PATH

# NOTE(srwilkers): We add this here due to envsubst expanding the ${tag} placeholder in
# fluentd's configuration. This ensures the placeholder value gets rendered appropriately
export tag='${tag}'

for manifest in armada-cluster-ingress armada-ceph; do
  echo "Rendering $manifest manifest"
  envsubst < ${OSH_INFRA_PATH}/tools/deployment/armada/manifests/$manifest.yaml > /tmp/$manifest.yaml
done

echo "Rendering armada-osh manifest"
envsubst < ./tools/deployment/armada/manifests/armada-osh.yaml > /tmp/armada-osh.yaml
