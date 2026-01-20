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

#NOTE: Define variables
: ${OSH_HELM_REPO:="../openstack-helm"}
: ${OSH_VALUES_OVERRIDES_PATH:="../openstack-helm/values_overrides"}
: ${OSH_EXTRA_HELM_ARGS_SWIFT:="$(helm osh get-values-overrides ${DOWNLOAD_OVERRIDES:-} -p ${OSH_VALUES_OVERRIDES_PATH} -c swift ${FEATURES})"}

tee /tmp/swift.yaml << EOF
ring:
  replicas: 1
  devices:
    - name: loop100
      weight: 100
EOF

#NOTE: Deploy command
helm upgrade --install swift ${OSH_HELM_REPO}/swift \
  --namespace=openstack \
  --values=/tmp/swift.yaml \
  ${OSH_EXTRA_HELM_ARGS:=} \
  ${OSH_EXTRA_HELM_ARGS_SWIFT}

#NOTE: Wait for deploy
helm osh wait-for-pods openstack 1200

openstack service list
openstack endpoint list

# Testing Swift
openstack container list
openstack container create test-container
openstack container list

echo "Hello World" > hello-world.txt
export OPENSTACK_CLIENT_CONTAINER_EXTRA_ARGS="-v $(pwd):/mnt"
openstack object create test-container /mnt/hello-world.txt
openstack object list test-container
openstack object delete test-container /mnt/hello-world.txt
openstack container delete test-container
openstack container list
