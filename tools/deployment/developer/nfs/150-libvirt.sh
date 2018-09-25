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

#NOTE: Lint and package chart
: ${OSH_INFRA_PATH:="../openstack-helm-infra"}
make -C ${OSH_INFRA_PATH} libvirt

tee /tmp/libvirt.yaml <<EOF
manifests:
  network_policy: true
network_policy:
  libvirt:
    ingress:
      - {}
EOF

#NOTE: Deploy command
: ${OSH_EXTRA_HELM_ARGS:=""}
helm upgrade --install libvirt ${OSH_INFRA_PATH}/libvirt \
  --namespace=openstack \
  --set conf.ceph.enabled=false \
  --values=/tmp/libvirt.yaml \
  ${OSH_EXTRA_HELM_ARGS} \
  ${OSH_EXTRA_HELM_ARGS_LIBVIRT}

#NOTE(portdirect): We don't wait for libvirt pods to come up, as they depend
# on the neutron agents being up.

#NOTE: Validate Deployment info
helm status libvirt
