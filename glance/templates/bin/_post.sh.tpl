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

ansible localhost -vvv -m kolla_keystone_service -a "service_name=glance \
service_type=image \
description='Openstack Image' \
endpoint_region='{{ .Values.keystone.glance_region_name }}' \
url='{{ include "helm-toolkit.endpoint_glance_api_internal" . }}' \
interface=admin \
region_name='{{ .Values.keystone.admin_region_name }}' \
auth='{{ include "helm-toolkit.keystone_auth" . }}'" \
-e "{'openstack_glance_auth': {{ include "helm-toolkit.keystone_auth" . }}}"

ansible localhost -vvv -m kolla_keystone_service -a "service_name=glance \
service_type=image \
description='Openstack Image' \
endpoint_region='{{ .Values.keystone.glance_region_name }}' \
url='{{ include "helm-toolkit.endpoint_glance_api_internal" . }}' \
interface=internal \
region_name='{{ .Values.keystone.admin_region_name }}' \
auth='{{ include "helm-toolkit.keystone_auth" . }}'" \
-e "{ 'openstack_glance_auth': {{ include "helm-toolkit.keystone_auth" . }} }"

ansible localhost -vvv -m kolla_keystone_service -a "service_name=glance \
service_type=image \
description='Openstack Image' \
endpoint_region='{{ .Values.keystone.glance_region_name }}' \
url='{{ include "helm-toolkit.endpoint_glance_api_internal" . }}' \
interface=public \
region_name='{{ .Values.keystone.admin_region_name }}' \
auth='{{ include "helm-toolkit.keystone_auth" . }}'" \
-e "{ 'openstack_glance_auth': {{ include "helm-toolkit.keystone_auth" . }} }"

ansible localhost -vvv -m kolla_keystone_user -a "project=service \
user={{ .Values.keystone.glance_user }} \
password={{ .Values.keystone.glance_password }} \
role=admin \
region_name={{ .Values.keystone.admin_region_name }} \
auth='{{ include "helm-toolkit.keystone_auth" . }}'" \
-e "{ 'openstack_glance_auth': {{ include "helm-toolkit.keystone_auth" . }} }"
