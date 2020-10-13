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

#NOTE: Get the over-rides to use
: ${OSH_EXTRA_HELM_ARGS_CINDER:="$(./tools/deployment/common/get-values-overrides.sh cinder)"}

#NOTE: Lint and package chart
make cinder

#NOTE: Deploy command
tee /tmp/cinder.yaml << EOF
conf:
  ceph:
    pools:
      backup:
        replication: 1
        crush_rule: same_host
        chunk_size: 8
        app_name: cinder-backup
      # default pool used by rbd1 backend
      cinder.volumes:
        replication: 1
        crush_rule: same_host
        chunk_size: 8
        app_name: cinder-volume
      # secondary pool used by rbd2 backend
      cinder.volumes.gold:
        replication: 1
        crush_rule: same_host
        chunk_size: 8
        app_name: cinder-volume
  backends:
    # add an extra storage backend same values as rbd1 (see
    # cinder/values.yaml) except for volume_backend_name and rbd_pool
    rbd2:
      volume_driver: cinder.volume.drivers.rbd.RBDDriver
      volume_backend_name: rbd2
      rbd_pool: cinder.volumes.gold
      rbd_ceph_conf: "/etc/ceph/ceph.conf"
      rbd_flatten_volume_from_snapshot: false
      report_discard_supported: true
      rbd_max_clone_depth: 5
      rbd_store_chunk_size: 4
      rados_connect_timeout: -1
      rbd_user: cinder
      rbd_secret_uuid: 457eb676-33da-42ec-9a8c-9293d545c337
pod:
  replicas:
    api: 2
    volume: 1
    scheduler: 1
    backup: 1
EOF
helm upgrade --install cinder ./cinder \
  --namespace=openstack \
  --values=/tmp/cinder.yaml \
  ${OSH_EXTRA_HELM_ARGS} \
  ${OSH_EXTRA_HELM_ARGS_CINDER}

#NOTE: Wait for deploy
./tools/deployment/common/wait-for-pods.sh openstack

#NOTE: Validate Deployment info
export OS_CLOUD=openstack_helm
openstack service list
sleep 30 #NOTE(portdirect): Wait for ingress controller to update rules and restart Nginx
openstack volume type list
openstack volume type list --default

# Delete the test pod if it still exists
kubectl delete pods -l application=cinder,release_group=cinder,component=test --namespace=openstack --ignore-not-found
helm test cinder --timeout 900
