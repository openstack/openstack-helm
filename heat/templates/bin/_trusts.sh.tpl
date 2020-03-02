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

#!/bin/bash

set -ex

# Get IDs for filtering
OS_PROJECT_ID=$(openstack project show -f value -c id ${OS_PROJECT_NAME})
OS_USER_ID=$(openstack user show -f value -c id ${OS_USERNAME})
SERVICE_OS_TRUSTEE_ID=$(openstack user show -f value -c id --domain ${SERVICE_OS_TRUSTEE_DOMAIN} ${SERVICE_OS_TRUSTEE})

# Check if trust doesn't already exist
openstack trust list -f value -c "Project ID" \
          -c "Trustee User ID" -c "Trustor User ID" | \
          grep "^${OS_PROJECT_ID} ${SERVICE_OS_TRUSTEE_ID} ${OS_USER_ID}$" && \
          exit 0

# If there are no roles specified...
if [ -z "${SERVICE_OS_ROLES}" ]; then
    # ...Heat will try to delegate all of the roles that user has in the
    # project. Let's fetch them all and use that.
    readarray -t roles < <(openstack role assignment list -f value \
            -c "Role" --user="${OS_USERNAME}" --project="${OS_PROJECT_ID}")
else
    # Split roles into an array
    IFS=',' read -r -a roles <<< "${SERVICE_OS_ROLES}"
fi

# Create trust between trustor and trustee
SERVICE_OS_TRUST_ID=$(openstack trust create -f value -c id \
          --project="${OS_PROJECT_NAME}" \
          ${roles[@]/#/--role=} \
          --trustee-domain="${SERVICE_OS_TRUSTEE_DOMAIN}" \
          "${OS_USERNAME}" \
          "${SERVICE_OS_TRUSTEE}")

# Display trust
openstack trust show "${SERVICE_OS_TRUST_ID}"
