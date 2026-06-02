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
    --description="Domain for ${SERVICE_OS_PROJECT_DOMAIN_NAME}" \
    "${SERVICE_OS_PROJECT_DOMAIN_NAME}")
fi

if [[ "${SERVICE_OS_USER_DOMAIN_NAME}" == "Default" ]]
then
  USER_DOMAIN_ID="default"
else
  # Manage user domain
  USER_DOMAIN_ID=$(openstack domain create --or-show --enable -f value -c id \
    --description="Domain for ${SERVICE_OS_USER_DOMAIN_NAME}" \
    "${SERVICE_OS_USER_DOMAIN_NAME}")
fi

shopt -u nocasematch

# Manage user project
USER_PROJECT_DESC="Service Project for ${SERVICE_OS_PROJECT_DOMAIN_NAME}"
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

# Manage user password in a separate step so the password can be conditionally updated.
# Keystone invalidates all active tokens for a user on every password update, even if the value
# is unchanged. To avoid disrupting long-lived service tokens on every reconciliation, we first
# probe authentication with the candidate password and skip the update if it succeeds.
# The probe forces password auth and clears any ambient auth-plugin env vars to avoid false positives.
# NOTE: if Keystone's [security_compliance] lockout_failure_attempts is configured, each failed probe
# counts as a failed login attempt. During initial deployment or after a password rotation the probe
# will fail once before the password is applied, so lockout_failure_attempts must be set high enough
# to tolerate at least one failure per reconciliation cycle.
probe_user_password () {
  OS_AUTH_TYPE="password" \
  OS_USERNAME="${SERVICE_OS_USERNAME}" \
  OS_PASSWORD="${SERVICE_OS_PASSWORD}" \
  OS_USER_DOMAIN_NAME="" \
  OS_USER_DOMAIN_ID="${USER_DOMAIN_ID}" \
  OS_PROJECT_NAME="" \
  OS_PROJECT_DOMAIN_NAME="" \
  OS_PROJECT_ID="" \
  OS_PROTOCOL="" \
  OS_IDENTITY_PROVIDER="" \
  OS_ACCESS_TOKEN="" \
  openstack token issue > /dev/null
}

set +ex
probe_stderr=$(probe_user_password 2>&1)
probe_exit=$?
set -e
if [[ $probe_exit -eq 0 ]]; then
  echo "Password for ${USER_ID} is already correct, skipping update."
elif echo "${probe_stderr}" | grep -q "HTTP 401"; then
  echo "Setting user password via: openstack user set --password=xxxxxxx ${USER_ID}"
  openstack user set --password="${SERVICE_OS_PASSWORD}" "${USER_ID}"
else
  echo "Password probe failed with unexpected error: ${probe_stderr}" >&2
  exit 1
fi
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
