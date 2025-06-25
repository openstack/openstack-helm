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

#NOTE: Deploy command
: ${OSH_HELM_REPO:="../openstack-helm"}
: ${OSH_VALUES_OVERRIDES_PATH:="../openstack-helm/values_overrides"}
: ${OSH_EXTRA_HELM_ARGS:=""}
: ${OSH_EXTRA_HELM_ARGS_POSTGRESQL:="$(helm osh get-values-overrides -p ${OSH_VALUES_OVERRIDES_PATH} -c postgresql ${FEATURES})"}
: ${NAMESPACE:=openstack}

helm upgrade --install postgresql ${OSH_HELM_REPO}/postgresql \
    --namespace=${NAMESPACE} \
    ${MONITORING_HELM_ARGS:="--set monitoring.prometheus.enabled=true"} \
    --set pod.replicas.server=1 \
    ${VOLUME_HELM_ARGS:="--set storage.pvc.enabled=false --set storage.host.host_path=/tmp/postgresql-data --set conf.postgresql.archive_mode=off"} \
    ${OSH_EXTRA_HELM_ARGS} \
    ${OSH_EXTRA_HELM_ARGS_POSTGRESQL}

#NOTE: Wait for deploy
helm osh wait-for-pods ${NAMESPACE}
