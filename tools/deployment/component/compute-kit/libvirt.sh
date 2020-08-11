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

export OS_CLOUD=openstack_helm
CEPH_ENABLED=false
if openstack service list -f value -c Type | grep -q "^volume" && \
    openstack volume type list -f value -c Name | grep -q "rbd"; then
  CEPH_ENABLED=true
fi

#NOTE: Get the over-rides to use
export HELM_CHART_ROOT_PATH="${HELM_CHART_ROOT_PATH:="${OSH_INFRA_PATH:="../openstack-helm-infra"}"}"
: ${OSH_EXTRA_HELM_ARGS_LIBVIRT:="$(./tools/deployment/common/get-values-overrides.sh libvirt)"}

#NOTE: Lint and package chart
make -C ${HELM_CHART_ROOT_PATH} libvirt

#NOTE: Deploy command
: ${OSH_EXTRA_HELM_ARGS:=""}
helm upgrade --install libvirt ${HELM_CHART_ROOT_PATH}/libvirt \
  --namespace=openstack \
  --set conf.ceph.enabled=${CEPH_ENABLED} \
  ${OSH_EXTRA_HELM_ARGS:=} \
  ${OSH_EXTRA_HELM_ARGS_LIBVIRT}

#NOTE(portdirect): We don't wait for libvirt pods to come up, as they depend
# on the neutron agents being up.

#NOTE: Validate Deployment info
helm status libvirt
