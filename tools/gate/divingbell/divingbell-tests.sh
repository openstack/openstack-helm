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

git clone https://opendev.org/airship/divingbell
cd divingbell
mkdir build
ln -s ../openstack-helm-infra build/openstack-helm-infra
export HELM_ARTIFACT_URL=https://storage.googleapis.com/kubernetes-helm/helm-v2.16.9-linux-amd64.tar.gz
./tools/gate/scripts/010-build-charts.sh
sudo SKIP_BASE_TESTS=true ./tools/gate/scripts/020-test-divingbell.sh
