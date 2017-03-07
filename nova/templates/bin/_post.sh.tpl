#!/bin/bash

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

set -ex
export HOME=/tmp

ansible localhost -vvv -m kolla_keystone_service -a "service_name=nova \
service_type=compute \
description='Openstack Compute' \
endpoint_region={{ .Values.keystone.nova_region_name }} \
url='{{ tuple "compute" "admin" "api" . | include "helm-toolkit.keystone_endpoint_uri_lookup" }}' \
interface=admin \
region_name={{ .Values.keystone.admin_region_name }} \
auth='{{ include "helm-toolkit.keystone_auth" .}}'" \
-e "{'openstack_nova_auth':{{ include "helm-toolkit.keystone_auth" .}}}"

ansible localhost -vvv -m kolla_keystone_service -a "service_name=nova \
service_type=compute \
description='Openstack Compute' \
endpoint_region={{ .Values.keystone.nova_region_name }} \
url='{{ tuple "compute" "internal" "api" . | include "helm-toolkit.keystone_endpoint_uri_lookup" }}' \
interface=internal \
region_name={{ .Values.keystone.admin_region_name }} \
auth='{{ include "helm-toolkit.keystone_auth" .}}'" \
-e "{'openstack_nova_auth':{{ include "helm-toolkit.keystone_auth" .}}}"

ansible localhost -vvv -m kolla_keystone_service -a "service_name=nova \
service_type=compute \
description='Openstack Compute' \
endpoint_region={{ .Values.keystone.nova_region_name }} \
url='{{ tuple "compute" "public" "api" . | include "helm-toolkit.keystone_endpoint_uri_lookup" }}' \
interface=public \
region_name={{ .Values.keystone.admin_region_name }} \
auth='{{ include "helm-toolkit.keystone_auth" .}}'" \
-e "{'openstack_nova_auth':{{ include "helm-toolkit.keystone_auth" .}}}"

ansible localhost -vvv -m kolla_keystone_user -a "project=service \
user={{ .Values.keystone.nova_user }} \
password={{ .Values.keystone.nova_password }} \
role=admin \
region_name={{ .Values.keystone.nova_region_name }} \
auth='{{ include "helm-toolkit.keystone_auth" .}}'" \
-e "{'openstack_nova_auth':{{ include "helm-toolkit.keystone_auth" .}}}"

cat <<EOF>/tmp/openrc
export OS_USERNAME={{.Values.keystone.admin_user}}
export OS_PASSWORD={{.Values.keystone.admin_password}}
export OS_PROJECT_DOMAIN_NAME={{.Values.keystone.domain_name}}
export OS_USER_DOMAIN_NAME={{.Values.keystone.domain_name}}
export OS_PROJECT_NAME={{.Values.keystone.admin_project_name}}
export OS_AUTH_URL={{include "helm-toolkit.endpoint_keystone_internal" .}}
export OS_AUTH_STRATEGY=keystone
export OS_REGION_NAME={{.Values.keystone.admin_region_name}}
export OS_INSECURE=1
EOF

. /tmp/openrc
openstack --debug role create --or-show _member_
