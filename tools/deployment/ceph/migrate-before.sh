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

: ${NAMESPACE:=openstack}

# Before migration we have to scale down all the stateful applications
# so PVs provisioned by Ceph are not attached to any pods
kubectl -n ${NAMESPACE} scale statefulset mariadb-server --replicas=0
kubectl -n ${NAMESPACE} scale statefulset rabbitmq-rabbitmq --replicas=0

sleep 30
helm osh wait-for-pods ${NAMESPACE}

kubectl -n ${NAMESPACE} get po
kubectl -n ${NAMESPACE} get pvc
kubectl get pv -o yaml

# Delete CSI secrets so Rook can deploy them from scratch
kubectl -n ceph delete secret rook-csi-rbd-provisioner
kubectl -n ceph delete secret rook-csi-rbd-node
kubectl -n ceph get secret
