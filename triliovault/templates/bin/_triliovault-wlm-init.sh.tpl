#!/bin/bash

{{/*
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/}}

set -ex

# Service boilerplate description
OS_SERVICE_DESC="${OS_REGION_NAME}: ${OS_SERVICE_NAME} (${OS_SERVICE_TYPE}) service"

# Get Service ID if it exists
unset OS_SERVICE_ID

# If OS_SERVICE_ID is blank then wait a few seconds to give it
# additional time and try again

## INPUT:
# CLOUD_ADMIN_USER_NAME
# CLOUD_ADMIN_PROJECT_NAME
# CLOUD_ADMIN_DOMAIN_NAME


CLOUD_ADMIN_USER_NAME="{{- .Values.conf.triliovault.cloud_admin_user_name -}}"
CLOUD_ADMIN_PROJECT_NAME="{{- .Values.conf.triliovault.cloud_admin_project_name -}}"
CLOUD_ADMIN_DOMAIN_NAME="{{- .Values.conf.triliovault.cloud_admin_domain_name -}}"
WLM_USER_NAME="{{- .Values.endpoints.identity.auth.triliovault_wlm.username -}}"

# If we have reached this point and a Service ID was not found,
# then create the service
OS_SERVICE_ID=$(openstack service create -f value -c id \
                --name="${OS_SERVICE_NAME}" \
                --description "${OS_SERVICE_DESC}" \
                --enable \
                "${OS_SERVICE_TYPE}")

CLOUD_ADMIN_USER_ID=$(openstack user show -f value -c id \
                "${CLOUD_ADMIN_USER_NAME}")

CLOUD_ADMIN_DOMAIN_ID=$(openstack domain show -f value -c id \
                "${CLOUD_ADMIN_DOMAIN_NAME}")

CLOUD_ADMIN_PROJECT_ID=$(openstack project show -f value -c id \
                "${CLOUD_ADMIN_PROJECT_NAME}")

WLM_USER_ID=$(openstack user show -f value -c id \
                "${WLM_USER_NAME}")

WLM_USER_DOMAIN_ID=$(openstack user show -f value -c domain_id \
                "${CLOUD_ADMIN_USER_NAME}")




tee > /tmp/pod-shared-${POD_NAME}/triliovault-wlm-ids.conf << EOF
[DEFAULT]
cloud_admin_user_id = $CLOUD_ADMIN_USER_ID
cloud_admin_domain = $CLOUD_ADMIN_DOMAIN_ID
cloud_admin_project_id = $CLOUD_ADMIN_PROJECT_ID
cloud_unique_id = $WLM_USER_ID
triliovault_user_domain_id = $WLM_USER_DOMAIN_ID
EOF
