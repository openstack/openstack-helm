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
make pull-images ceph

#NOTE: Deploy command
WORK_DIR=$(pwd)
helm install --namespace=openstack ${WORK_DIR}/ceph --name=radosgw-openstack \
   --set endpoints.identity.namespace=openstack \
   --set endpoints.object_store.namespace=ceph \
   --set endpoints.ceph_mon.namespace=ceph \
   --set ceph.rgw_keystone_auth=true \
   --set network.public=172.17.0.1/16 \
   --set network.cluster=172.17.0.1/16 \
   --set deployment.storage_secrets=false \
   --set deployment.ceph=false \
   --set deployment.rbd_provisioner=false \
   --set deployment.cephfs_provisioner=false \
   --set deployment.client_secrets=false \
   --set deployment.rgw_keystone_user_and_endpoints=true \
   --values=${WORK_DIR}/tools/overrides/mvp/ceph.yaml

#NOTE: Wait for deploy
./tools/deployment/developer/wait-for-pods.sh openstack

#NOTE: Validate Deployment info
helm status radosgw-openstack
export OS_CLOUD=openstack_helm
openstack service list
openstack container create 'mygreatcontainer'
curl -L -o /tmp/important-file.jpg https://imgflip.com/s/meme/Cute-Cat.jpg
openstack object create --name 'superimportantfile.jpg' 'mygreatcontainer' /tmp/important-file.jpg
