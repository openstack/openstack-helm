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

{{- define "helm-toolkit.scripts.keystone_service" }}
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

# Service boilerplate description
OS_SERVICE_DESC="${OS_REGION_NAME}: ${OS_SERVICE_NAME} (${OS_SERVICE_TYPE}) service"

# Get Service ID if it exists
unset OS_SERVICE_ID

# FIXME - There seems to be an issue once in a while where the
# openstack service list fails and encounters an error message such as:
#   Unable to establish connection to
#   https://keystone-api.openstack.svc.cluster.local:5000/v3/auth/tokens:
#   ('Connection aborted.', OSError("(104, 'ECONNRESET')",))
# During an upgrade scenario, this would cause the OS_SERVICE_ID to be blank
# and it would attempt to create a new service when it was not needed.
# This duplciate service would sometimes be used by other services such as
# Horizon and would give an 'Invalid Service Catalog' error.
# This loop allows for a 'retry' of the openstack service list in an
# attempt to get the service list as expected if it does ecounter an error.
# This loop and recheck can be reverted once the underlying issue is addressed.

# If OS_SERVICE_ID is blank then wait a few seconds to give it
# additional time and try again
for i in $(seq 3)
do
  OS_SERVICE_ID=$( openstack service list -f csv --quote none | \
                   grep ",${OS_SERVICE_NAME},${OS_SERVICE_TYPE}$" | \
                   sed -e "s/,${OS_SERVICE_NAME},${OS_SERVICE_TYPE}//g" )

  # If the service was found, go ahead and exit successfully.
  if [[ -n "${OS_SERVICE_ID}" ]]; then
    exit 0
  fi

  sleep 2
done

# If we've reached this point and a Service ID was not found,
# then create the service
OS_SERVICE_ID=$(openstack service create -f value -c id \
                --name="${OS_SERVICE_NAME}" \
                --description "${OS_SERVICE_DESC}" \
                --enable \
                "${OS_SERVICE_TYPE}")
{{- end }}
