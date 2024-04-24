#!/bin/bash
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -ex

: ${OSH_INFRA_PATH:="../openstack-helm-infra"}
(
    cd ${OSH_INFRA_PATH} &&
    helm repo index ./
)

helm repo index ./

docker run -d --name nginx_charts \
    -v $(pwd):/usr/share/nginx/html/openstack-helm:ro \
    -v $(readlink -f ${OSH_INFRA_PATH}):/usr/share/nginx/html/openstack-helm-infra:ro \
    -p 80:80 \
    nginx

helm repo add ${OSH_HELM_REPO:-"openstack-helm"} http://localhost/openstack-helm
helm repo add ${OSH_INFRA_HELM_REPO:-"openstack-helm-infra"} http://localhost/openstack-helm-infra
