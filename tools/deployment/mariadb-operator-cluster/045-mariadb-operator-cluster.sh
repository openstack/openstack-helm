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

# Specify the Rook release tag to use for the Rook operator here
: ${MARIADB_OPERATOR_RELEASE:="0.22.0"}

# install mariadb-operator
helm repo add mariadb-operator https://mariadb-operator.github.io/mariadb-operator
helm install mariadb-operator mariadb-operator/mariadb-operator --version ${MARIADB_OPERATOR_RELEASE} -n mariadb-operator

#NOTE: Wait for deploy
./tools/deployment/common/wait-for-pods.sh mariadb-operator


#NOTE: Lint and package chart
make mariadb-cluster

: ${OSH_INFRA_EXTRA_HELM_ARGS_MARIADB_CLUSTER:="$(./tools/deployment/common/get-values-overrides.sh mariadb-cluster)"}

#NOTE: Deploy command
# Deploying downscaled cluster
: ${OSH_INFRA_EXTRA_HELM_ARGS:=""}
helm upgrade --install mariadb-cluster ./mariadb-cluster \
    --namespace=openstack \
    --wait \
    --timeout 900s \
    --values mariadb-cluster/values_overrides/downscaled.yaml \
    ${OSH_INFRA_EXTRA_HELM_ARGS} \
    ${OSH_INFRA_EXTRA_HELM_ARGS_MARIADB_CLUSTER}


#NOTE: Wait for deploy
./tools/deployment/common/wait-for-pods.sh openstack

kubectl get pods --namespace=openstack -o wide

#NOTE: Deploy command
# Upscaling the cluster to 3 instances
# mariadb-operator is not handinling changes in appropriate statefulset
# so a special job has to delete the statefulset in order
# to let mariadb-operator to re-create the sts with new params
helm upgrade --install mariadb-cluster ./mariadb-cluster \
    --namespace=openstack \
    --wait \
    --timeout 900s \
    --values mariadb-cluster/values_overrides/upscaled.yaml \
    ${OSH_INFRA_EXTRA_HELM_ARGS} \
    ${OSH_INFRA_EXTRA_HELM_ARGS_MARIADB_CLUSTER}

#NOTE: Wait for deploy
./tools/deployment/common/wait-for-pods.sh openstack

kubectl get pods --namespace=openstack -o wide

# Delete the test pod if it still exists
kubectl delete pods -l application=mariadb,release_group=mariadb-cluster,component=test --namespace=openstack --ignore-not-found
#NOTE: Validate the deployment
helm test mariadb-cluster --namespace openstack
