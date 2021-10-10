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

#NOTE: Lint and package chart
: ${OSH_INFRA_PATH:="../openstack-helm-infra"}
make -C ${OSH_INFRA_PATH} ingress

#NOTE: Deploy global ingress
helm install ${OSH_INFRA_PATH}/ingress \
  --namespace=kube-system \
  --name=ingress-kube-system \
  --set deployment.mode=cluster \
  --set deployment.type=DaemonSet \
  --set network.host_namespace=true \
  --set network.vip.manage=false \
  --set network.vip.addr=172.18.0.1/32 \
  --set conf.services.udp.53='kube-system/kube-dns:53'

#NOTE: Deploy namespace ingress
helm install ${OSH_INFRA_PATH}/ingress \
  --namespace=ceph \
  --name=ingress-ceph
helm install ${OSH_INFRA_PATH}/ingress \
  --namespace=openstack \
  --name=ingress-openstack

#NOTE: Wait for deploy
./tools/deployment/common/wait-for-pods.sh kube-system
./tools/deployment/common/wait-for-pods.sh ceph
./tools/deployment/common/wait-for-pods.sh openstack
