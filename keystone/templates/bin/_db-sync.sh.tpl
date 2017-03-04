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

keystone-manage --config-file=/etc/keystone/keystone.conf db_sync

keystone-manage --config-file=/etc/keystone/keystone.conf bootstrap \
    --bootstrap-username {{ .Values.keystone.admin_user }} \
    --bootstrap-password {{ .Values.keystone.admin_password }} \
    --bootstrap-project-name {{ .Values.keystone.admin_project_name }} \
    --bootstrap-admin-url {{ tuple "identity" "admin" "admin" . | include "helm-toolkit.keystone_endpoint_uri_lookup" }} \
    --bootstrap-public-url {{ tuple "identity" "public" "api" . | include "helm-toolkit.keystone_endpoint_uri_lookup" }} \
    --bootstrap-internal-url {{ tuple "identity" "internal" "api" . | include "helm-toolkit.keystone_endpoint_uri_lookup" }} \
    --bootstrap-region-id {{ .Values.keystone.admin_region_name }}
