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

WLM_PROJECT_DOMAIN_NAME="{{- .Values.endpoints.identity.auth.triliovault_wlm.project_domain_name -}}"


CLOUD_ADMIN_USER_ID=$(openstack user show --domain "${CLOUD_ADMIN_DOMAIN_NAME}" -f value -c id \
                "${CLOUD_ADMIN_USER_NAME}")

CLOUD_ADMIN_DOMAIN_ID=$(openstack domain show -f value -c id \
                "${CLOUD_ADMIN_DOMAIN_NAME}")

CLOUD_ADMIN_PROJECT_ID=$(openstack project show -f value -c id \
                "${CLOUD_ADMIN_PROJECT_NAME}")

WLM_PROJECT_DOMAIN_ID=$(openstack project show -f value -c domain_id \
                "${WLM_PROJECT_DOMAIN_NAME}")

WLM_USER_ID=$(openstack user show --domain "${WLM_PROJECT_DOMAIN_NAME}" -f value -c id \
                "${WLM_USER_NAME}")

WLM_USER_DOMAIN_ID=$(openstack user show --domain "${WLM_PROJECT_DOMAIN_NAME}" -f value -c domain_id \
                "${WLM_USER_NAME}")


host_interface=$(ip -4 route list 0/0 | awk -F 'dev' '{ print $2; exit }' | awk '{ print $1 }') || exit 1

POD_IP=$(ip a s $host_interface | grep 'inet ' | awk '{print $2}' | awk -F "/" '{print $1}' | head -1)

tee > /tmp/pod-shared-${POD_NAME}/triliovault-wlm-ids.conf << EOF
[DEFAULT]
triliovault_hostnames = ${POD_IP}
cloud_admin_user_id = $CLOUD_ADMIN_USER_ID
cloud_admin_domain = $CLOUD_ADMIN_DOMAIN_ID
cloud_admin_project_id = $CLOUD_ADMIN_PROJECT_ID
cloud_unique_id = $WLM_USER_ID
triliovault_user_domain_id = $WLM_USER_DOMAIN_ID
domain_name = $CLOUD_ADMIN_DOMAIN_ID

[keystone_authtoken]
project_domain_id = $WLM_PROJECT_DOMAIN_ID
user_domain_id = $WLM_USER_DOMAIN_ID

EOF

chown nova:nova /tmp/pod-shared-${POD_NAME}/triliovault-wlm-ids.conf
mkdir -p /var/log/triliovault/wlm-api /var/log/triliovault/wlm-workloads /var/log/triliovault/wlm-scheduler
chown -R nova:nova /var/log/triliovault/
