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

# Now we have are ready to scale up stateful applications
# and use same PVs provisioned earlier by legacy Ceph
kubectl -n ${NAMESPACE} scale statefulset mariadb-server --replicas=1
kubectl -n ${NAMESPACE} scale statefulset rabbitmq-rabbitmq --replicas=1

sleep 30
helm osh wait-for-pods ${NAMESPACE}

kubectl -n ${NAMESPACE} get po
kubectl -n ${NAMESPACE} get pvc
kubectl get pv -o yaml
