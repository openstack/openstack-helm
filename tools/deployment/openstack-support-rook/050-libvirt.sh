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

: ${OSH_INFRA_EXTRA_HELM_ARGS_LIBVIRT:="$(./tools/deployment/common/get-values-overrides.sh libvirt)"}

#NOTE: Lint and package chart
make libvirt

#NOTE: Deploy command
helm upgrade --install libvirt ./libvirt \
  --namespace=openstack \
  --set network.backend="null" \
  ${OSH_INFRA_EXTRA_HELM_ARGS} \
  ${OSH_INFRA_EXTRA_HELM_ARGS_LIBVIRT}

#NOTE: Please be aware that a network backend might affect
#The loadability of this, as some need to be asynchronously
#loaded. See also:
#https://github.com/openstack/openstack-helm-infra/blob/b69584bd658ae5cb6744e499975f9c5a505774e5/libvirt/values.yaml#L151-L172
if [[ "${WAIT_FOR_PODS:=True}" == "True" ]]; then
    ./tools/deployment/common/wait-for-pods.sh openstack
fi
