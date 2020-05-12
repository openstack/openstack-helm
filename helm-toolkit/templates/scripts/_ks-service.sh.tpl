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
OS_SERVICE_ID=$( openstack service list -f csv --quote none | \
                 grep ",${OS_SERVICE_NAME},${OS_SERVICE_TYPE}$" | \
                 sed -e "s/,${OS_SERVICE_NAME},${OS_SERVICE_TYPE}//g" )

# If a Service ID was not found, then create the service
if [[ -z ${OS_SERVICE_ID} ]]; then
  OS_SERVICE_ID=$(openstack service create -f value -c id \
                  --name="${OS_SERVICE_NAME}" \
                  --description "${OS_SERVICE_DESC}" \
                  --enable \
                  "${OS_SERVICE_TYPE}")
fi
{{- end }}
