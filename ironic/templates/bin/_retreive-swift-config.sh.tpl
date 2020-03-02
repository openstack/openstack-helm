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

OS_SWIFT_ENDPOINT="$(openstack endpoint list \
    --service swift \
    --interface public \
    -f value \
    -c URL | head -1 )"
OS_SWIFT_HOST_AND_PATH_PREFIX="$(echo "${OS_SWIFT_ENDPOINT}" | awk -F "/${OS_SWIFT_API_VERSION}" '{ print $1 }')"
OS_SWIFT_ACCOUNT_PREFIX="$(echo "${OS_SWIFT_ENDPOINT}" | awk -F "/${OS_SWIFT_API_VERSION}/" '{ print $NF }' | awk -F '$' '{ print $1 }')"
OS_PROJECT_ID="$(openstack project show ${OS_PROJECT_NAME} -f value -c id)"
OS_SWIFT_ACCOUNT="$(echo "${OS_SWIFT_ACCOUNT_PREFIX}${OS_PROJECT_ID}")"

tee /tmp/pod-shared/swift.conf <<EOF
[glance]
swift_endpoint_url: "${OS_SWIFT_HOST_AND_PATH_PREFIX}"
swift_account: "${OS_SWIFT_ACCOUNT}"
EOF
