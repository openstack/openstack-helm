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
: ${OSH_EXTRA_HELM_ARGS_MEMCACHED:="$(helm osh get-values-overrides ${DOWNLOAD_OVERRIDES:-} -p ${OSH_VALUES_OVERRIDES_PATH} -c memcached ${FEATURES})"}
: ${NAMESPACE:=openstack}

#NOTE: Deploy command
helm upgrade --install memcached ${OSH_HELM_REPO}/memcached \
    --namespace=${NAMESPACE} \
    ${OSH_EXTRA_HELM_ARGS:=} \
    ${OSH_EXTRA_HELM_ARGS_MEMCACHED}

#NOTE: Wait for deploy
helm osh wait-for-pods ${NAMESPACE}
