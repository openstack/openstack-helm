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

{{- define "helm-toolkit.scripts.keystone_endpoints" }}
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

# Get Service ID
OS_SERVICE_ID=$( openstack service list -f csv --quote none | \
                  grep ",${OS_SERVICE_NAME},${OS_SERVICE_TYPE}$" | \
                    sed -e "s/,${OS_SERVICE_NAME},${OS_SERVICE_TYPE}//g" )

# Get Endpoint ID if it exists
OS_ENDPOINT_ID=$( openstack endpoint list  -f csv --quote none | \
                  grep "^[a-z0-9]*,${OS_REGION_NAME},${OS_SERVICE_NAME},${OS_SERVICE_TYPE},True,${OS_SVC_ENDPOINT}," | \
                  awk -F ',' '{ print $1 }' )

# Making sure only a single endpoint exists for a service within a region
if [ "$(echo $OS_ENDPOINT_ID | wc -w)" -gt "1" ]; then
  echo "More than one endpoint found, cleaning up"
  for ENDPOINT_ID in $OS_ENDPOINT_ID; do
    openstack endpoint delete ${ENDPOINT_ID}
  done
  unset OS_ENDPOINT_ID
fi

# Determine if Endpoint needs updated
if [[ ${OS_ENDPOINT_ID} ]]; then
  OS_ENDPOINT_URL_CURRENT=$(openstack endpoint show ${OS_ENDPOINT_ID} -f value -c url)
  if [ "${OS_ENDPOINT_URL_CURRENT}" == "${OS_SERVICE_ENDPOINT}" ]; then
    echo "Endpoints Match: no action required"
    OS_ENDPOINT_UPDATE="False"
  else
    echo "Endpoints Dont Match: removing existing entries"
    openstack endpoint delete ${OS_ENDPOINT_ID}
    OS_ENDPOINT_UPDATE="True"
  fi
else
  OS_ENDPOINT_UPDATE="True"
fi

# Update Endpoint if required
if [[ "${OS_ENDPOINT_UPDATE}" == "True" ]]; then
  OS_ENDPOINT_ID=$( openstack endpoint create -f value -c id \
    --region="${OS_REGION_NAME}" \
    "${OS_SERVICE_ID}" \
    ${OS_SVC_ENDPOINT} \
    "${OS_SERVICE_ENDPOINT}" )
fi

# Display the Endpoint
openstack endpoint show ${OS_ENDPOINT_ID}
{{- end }}
