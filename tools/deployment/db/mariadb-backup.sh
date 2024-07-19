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

: ${OSH_INFRA_HELM_REPO:="../openstack-helm-infra"}
: ${OSH_INFRA_PATH:="../openstack-helm-infra"}
: ${OSH_INFRA_EXTRA_HELM_ARGS_MARIADB_BACKUP:="$(helm osh get-values-overrides -c mariadb-backup ${FEATURES})"}

#NOTE: Deploy command
helm upgrade --install mariadb-backup ${OSH_INFRA_HELM_REPO}/mariadb-backup \
    --namespace=openstack \
    --wait \
    --timeout 900s \
    ${OSH_INFRA_EXTRA_HELM_ARGS:=} \
    ${OSH_INFRA_EXTRA_HELM_ARGS_MARIADB_BACKUP}

helm osh wait-for-pods openstack

kubectl create job --from=cronjob/mariadb-backup mariadb-backup-manual-001 -n openstack

helm osh wait-for-pods openstack

kubectl logs jobs/mariadb-backup-manual-001 -n openstack
