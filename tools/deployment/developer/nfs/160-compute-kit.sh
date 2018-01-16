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

#NOTE: Pull images and lint chart
make pull-images nova
make pull-images neutron

#NOTE: Deploy nova
if [ "x$(systemd-detect-virt)" == "xnone" ]; then
  echo 'OSH is not being deployed in virtualized environment'
  helm install ./nova \
      --namespace=openstack \
      --name=nova \
      --set ceph.enabled=false
else
  echo 'OSH is being deployed in virtualized environment, using qemu for nova'
  helm install ./nova \
      --namespace=openstack \
      --name=nova \
      --set conf.nova.libvirt.virt_type=qemu \
      --set ceph.enabled=false
fi

#NOTE: Deploy neutron
helm install ./neutron \
    --namespace=openstack \
    --name=neutron \
    --values=./tools/overrides/mvp/neutron-ovs.yaml

#NOTE: Wait for deploy
./tools/deployment/common/wait-for-pods.sh openstack

#NOTE: Validate Deployment info
export OS_CLOUD=openstack_helm
openstack service list
sleep 30 #NOTE(portdirect): Wait for ingress controller to update rules and restart Nginx
openstack hypervisor list
openstack network agent list
