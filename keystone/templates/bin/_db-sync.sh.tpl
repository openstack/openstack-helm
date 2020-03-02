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

keystone-manage --config-file=/etc/keystone/keystone.conf db_sync
keystone-manage --config-file=/etc/keystone/keystone.conf bootstrap \
    --bootstrap-username ${OS_USERNAME} \
    --bootstrap-password ${OS_PASSWORD} \
    --bootstrap-project-name ${OS_PROJECT_NAME} \
    --bootstrap-admin-url ${OS_BOOTSTRAP_ADMIN_URL} \
    --bootstrap-public-url ${OS_BOOTSTRAP_PUBLIC_URL} \
    --bootstrap-internal-url ${OS_BOOTSTRAP_INTERNAL_URL} \
    --bootstrap-region-id ${OS_REGION_NAME}

exec python /tmp/endpoint-update.py
