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

{{- define "helm-toolkit.scripts.keystone_user" }}
#!/bin/bash

# Copyright 2017 Pete Birley
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -ex

shopt -s nocasematch

if [[ "${SERVICE_OS_PROJECT_DOMAIN_NAME}" == "Default" ]]
then
  PROJECT_DOMAIN_ID="default"
else
  # Manage project domain
  PROJECT_DOMAIN_ID=$(openstack domain create --or-show --enable -f value -c id \
    --description="Domain for ${SERVICE_OS_REGION_NAME}/${SERVICE_OS_PROJECT_DOMAIN_NAME}" \
    "${SERVICE_OS_PROJECT_DOMAIN_NAME}")
fi

if [[ "${SERVICE_OS_USER_DOMAIN_NAME}" == "Default" ]]
then
  USER_DOMAIN_ID="default"
else
  # Manage user domain
  USER_DOMAIN_ID=$(openstack domain create --or-show --enable -f value -c id \
    --description="Domain for ${SERVICE_OS_REGION_NAME}/${SERVICE_OS_USER_DOMAIN_NAME}" \
    "${SERVICE_OS_USER_DOMAIN_NAME}")
fi

shopt -u nocasematch

# Manage user project
USER_PROJECT_DESC="Service Project for ${SERVICE_OS_REGION_NAME}/${SERVICE_OS_PROJECT_DOMAIN_NAME}"
USER_PROJECT_ID=$(openstack project create --or-show --enable -f value -c id \
    --domain="${PROJECT_DOMAIN_ID}" \
    --description="${USER_PROJECT_DESC}" \
    "${SERVICE_OS_PROJECT_NAME}");

# Manage user
USER_DESC="Service User for ${SERVICE_OS_REGION_NAME}/${SERVICE_OS_USER_DOMAIN_NAME}/${SERVICE_OS_SERVICE_NAME}"
USER_ID=$(openstack user create --or-show --enable -f value -c id \
    --domain="${USER_DOMAIN_ID}" \
    --project-domain="${PROJECT_DOMAIN_ID}" \
    --project="${USER_PROJECT_ID}" \
    --description="${USER_DESC}" \
    "${SERVICE_OS_USERNAME}");

# Manage user password (we do this in a seperate step to ensure the password is updated if required)
set +x
echo "Setting user password via: openstack user set --password=xxxxxxx ${USER_ID}"
openstack user set --password="${SERVICE_OS_PASSWORD}" "${USER_ID}"
set -x

function ks_assign_user_role () {
  if [[ "$SERVICE_OS_ROLE" == "admin" ]]
  then
    USER_ROLE_ID="$SERVICE_OS_ROLE"
  else
    USER_ROLE_ID=$(openstack role create --or-show -f value -c id "${SERVICE_OS_ROLE}");
  fi

  # Manage user role assignment
  openstack role add \
      --user="${USER_ID}" \
      --user-domain="${USER_DOMAIN_ID}" \
      --project-domain="${PROJECT_DOMAIN_ID}" \
      --project="${USER_PROJECT_ID}" \
      "${USER_ROLE_ID}"
}

# Manage user service role
IFS=','
for SERVICE_OS_ROLE in ${SERVICE_OS_ROLES}; do
  ks_assign_user_role
done

# Manage user member role
: ${MEMBER_OS_ROLE:="member"}
export USER_ROLE_ID=$(openstack role create --or-show -f value -c id \
    "${MEMBER_OS_ROLE}");
ks_assign_user_role
{{- end }}
