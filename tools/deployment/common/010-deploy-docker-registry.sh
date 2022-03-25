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

#NOTE: Lint and package charts for deploying a local docker registry
make nfs-provisioner
make redis
make registry

for NAMESPACE in docker-nfs docker-registry; do
tee /tmp/${NAMESPACE}-ns.yaml << EOF
apiVersion: v1
kind: Namespace
metadata:
  labels:
    kubernetes.io/metadata.name: ${NAMESPACE}
    name: ${NAMESPACE}
  name: ${NAMESPACE}
EOF

kubectl create -f /tmp/${NAMESPACE}-ns.yaml
done

#NOTE: Deploy nfs for the docker registry
tee /tmp/docker-registry-nfs-provisioner.yaml << EOF
labels:
  node_selector_key: openstack-helm-node-class
  node_selector_value: primary
storageclass:
  name: openstack-helm-bootstrap
EOF
helm upgrade --install docker-registry-nfs-provisioner \
    ./nfs-provisioner --namespace=docker-nfs \
    --values=/tmp/docker-registry-nfs-provisioner.yaml

#NOTE: Deploy redis for the docker registry
helm upgrade --install docker-registry-redis ./redis \
    --namespace=docker-registry \
    --set labels.node_selector_key=openstack-helm-node-class \
    --set labels.node_selector_value=primary

#NOTE: Deploy the docker registry
tee /tmp/docker-registry.yaml << EOF
labels:
  node_selector_key: openstack-helm-node-class
  node_selector_value: primary
volume:
  class_name: openstack-helm-bootstrap
EOF
helm upgrade --install docker-registry ./registry \
    --namespace=docker-registry \
    --values=/tmp/docker-registry.yaml

#NOTE: Wait for deployments
./tools/deployment/common/wait-for-pods.sh docker-registry

# Delete the test pod if it still exists
kubectl delete pods -l application=redis,release_group=docker-registry-redis,component=test --namespace=docker-registry --ignore-not-found
#NOTE: Run helm tests
helm test docker-registry-redis --namespace docker-registry
