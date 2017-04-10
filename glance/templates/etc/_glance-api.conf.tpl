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
debug = {{ .Values.misc.debug }}
use_syslog = False
use_stderr = True

bind_port = {{ .Values.network.api.port }}
workers = {{ .Values.misc.workers }}
registry_host = glance-registry
# Enable Copy-on-Write
show_image_direct_url = True

[database]
connection = {{ tuple "oslo_db" "internal" "user" "mysql" . | include "helm-toolkit.authenticated_endpoint_uri_lookup" }}
max_retries = -1

[keystone_authtoken]
auth_version = v3
auth_url = {{ tuple "identity" "internal" "api" . | include "helm-toolkit.keystone_endpoint_uri_lookup" }}
auth_type = password
region_name = {{ .Values.keystone.glance_region_name }}
project_domain_name = {{ .Values.keystone.glance_project_domain }}
project_name = {{ .Values.keystone.glance_project_name }}
user_domain_name = {{ .Values.keystone.glance_user_domain }}
username = {{ .Values.keystone.glance_user }}
password = {{ .Values.keystone.glance_password }}

[paste_deploy]
flavor = keystone

[oslo_messaging_notifications]
driver = noop

[glance_store]
filesystem_store_datadir = /var/lib/glance/images/
{{- if .Values.development.enabled }}
stores = file, http
default_store = file
{{- else }}
stores = file, http, rbd
default_store = rbd
rbd_store_pool = {{ .Values.ceph.glance_pool }}
rbd_store_user = {{ .Values.ceph.glance_user }}
rbd_store_ceph_conf = /etc/ceph/ceph.conf
rbd_store_chunk_size = 8
{{- end }}
