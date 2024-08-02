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
: ${OSH_PATH:="../openstack-helm"}
: ${OSH_EXTRA_HELM_ARGS_GLANCE:="$(helm osh get-values-overrides ${DOWNLOAD_OVERRIDES:-} -p ${OSH_PATH} -c glance ${FEATURES})"}
: ${RUN_HELM_TESTS:="yes"}
: ${GLANCE_BACKEND:="pvc"}

#NOTE: Deploy command
tee /tmp/glance.yaml <<EOF
storage: ${GLANCE_BACKEND}
bootstrap:
  structured:
    images:
      ubuntu_miniaml:
        name: "Ubuntu Jammy Minimal"
        source_url: "https://cloud-images.ubuntu.com/minimal/releases/jammy/release/"
        image_file: "ubuntu-22.04-minimal-cloudimg-amd64.img"
        id: null
        min_disk: 3
        image_type: qcow2
        container_format: bare
EOF

helm upgrade --install glance ${OSH_HELM_REPO}/glance \
  --namespace=openstack \
  --values=/tmp/glance.yaml \
  --timeout=800s \
  ${OSH_EXTRA_HELM_ARGS:=} \
  ${OSH_EXTRA_HELM_ARGS_GLANCE}

#NOTE: Wait for deploy
helm osh wait-for-pods openstack

export OS_CLOUD=openstack_helm
openstack service list
sleep 30 #NOTE(portdirect): Wait for ingress controller to update rules and restart Nginx
openstack image list
for image_id in $(openstack image list -f value -c ID); do
  openstack image show ${image_id}
done

if [ "x${RUN_HELM_TESTS}" == "xno" ]; then
    exit 0
fi

./tools/deployment/common/run-helm-tests.sh glance
