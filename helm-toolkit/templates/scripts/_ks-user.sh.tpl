# Copyright 2017 The Openstack-Helm Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

{{- define "helm-toolkit.keystone_user" }}
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

# Manage user project
USER_PROJECT_DESC="Service Project for ${SERVICE_OS_REGION_NAME}/${SERVICE_OS_PROJECT_DOMAIN_NAME}"
USER_PROJECT_ID=$(openstack project create --or-show --enable -f value -c id \
    --domain="${SERVICE_OS_PROJECT_DOMAIN_NAME}" \
    --description="${USER_PROJECT_DESC}" \
    "${SERVICE_OS_PROJECT_NAME}");

# Display project
openstack project show "${USER_PROJECT_ID}"

# Manage user
USER_DESC="Service User for ${SERVICE_OS_REGION_NAME}/${SERVICE_OS_USER_DOMAIN_NAME}/${SERVICE_OS_SERVICE_NAME}"
USER_ID=$(openstack user create --or-show --enable -f value -c id \
    --domain="${SERVICE_OS_USER_DOMAIN_NAME}" \
    --project-domain="${SERVICE_OS_PROJECT_DOMAIN_NAME}" \
    --project="${USER_PROJECT_ID}" \
    --description="${USER_DESC}" \
    --password="${SERVICE_OS_PASSWORD}" \
    "${SERVICE_OS_USERNAME}");

# Display user
openstack user show "${USER_ID}"

# Manage user role
USER_ROLE_ID=$(openstack role create --or-show -f value -c id \
    "${SERVICE_OS_ROLE}");

# Manage user role assignment
openstack role add \
    --user="${USER_ID}" \
    --user-domain="${SERVICE_OS_USER_DOMAIN_NAME}" \
    --project-domain="${SERVICE_OS_PROJECT_DOMAIN_NAME}" \
    --project="${USER_PROJECT_ID}" \
    "${USER_ROLE_ID}"

# Display user role assignment
openstack role assignment list \
    --role="${SERVICE_OS_ROLE}" \
    --user-domain="${SERVICE_OS_USER_DOMAIN_NAME}" \
    --user="${USER_ID}"
{{- end }}
