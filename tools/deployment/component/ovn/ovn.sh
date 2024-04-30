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

export FEATURE_GATES="ovn"

#NOTE: Get the over-rides to use
export HELM_CHART_ROOT_PATH="${HELM_CHART_ROOT_PATH:="${OSH_INFRA_PATH:="../openstack-helm-infra"}"}"
: ${OSH_EXTRA_HELM_ARGS_OVN:="$(helm osh get-values-overrides ${DOWNLOAD_OVERRIDES:-} -p ${HELM_CHART_ROOT_PATH} -c ovn ${FEATURES})"}

tee /tmp/ovn.yaml << EOF
volume:
  ovn_ovsdb_nb:
    enabled: false
  ovn_ovsdb_sb:
    enabled: false
network:
  interface:
    tunnel: null
conf:
  ovn_bridge_mappings: public:br-ex
  auto_bridge_add:
    br-ex: provider1
EOF

#NOTE: Deploy command
: ${OSH_EXTRA_HELM_ARGS:=""}
helm upgrade --install ovn ${HELM_CHART_ROOT_PATH}/ovn \
  --namespace=openstack \
  --values=/tmp/ovn.yaml \
  ${OSH_EXTRA_HELM_ARGS} \
  ${OSH_EXTRA_HELM_ARGS_OVN}

#NOTE: Wait for deploy
helm osh wait-for-pods openstack
