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

[DEFAULT]
debug = {{ .Values.metadata_agent.default.debug }}

# Neutron credentials for API access
auth_url = {{ tuple "identity" "admin" "admin" . | include "helm-toolkit.keystone_endpoint_uri_lookup" }}
auth_plugin = password
auth_region = {{ .Values.keystone.neutron_region_name }}
project_domain_name = {{ .Values.keystone.neutron_project_domain }}
project_name = {{ .Values.keystone.neutron_project_name }}
user_domain_name = {{ .Values.keystone.neutron_user_domain }}
username = {{ .Values.keystone.neutron_user }}
password = {{ .Values.keystone.neutron_password }}
endpoint_type = adminURL

# Nova metadata service IP and port
nova_metadata_ip = {{ include "helm-toolkit.nova_metadata_host" . }}
nova_metadata_port = {{ .Values.network.port.metadata }}
nova_metadata_protocol = http

# Metadata proxy shared secret
metadata_proxy_shared_secret = {{ .Values.neutron.metadata_secret }}

metadata_port = {{ .Values.network.port.metadata }}

# Workers and backlog requests
metadata_workers = {{ .Values.metadata.workers }}

# Caching
cache_url = memory://?default_ttl=5
