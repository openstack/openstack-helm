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
bind_port = {{ .Values.network.port.registry }}
workers = {{ .Values.misc.workers }}
    
[database]
connection = mysql+pymysql://{{ .Values.database.glance_user }}:{{ .Values.database.glance_password }}@{{ .Values.database.address }}/{{ .Values.database.glance_database_name }}
max_retries = -1
    
[keystone_authtoken]
auth_uri = {{ .Values.keystone.auth_uri }}
auth_url = {{ .Values.keystone.auth_url }}
auth_type = password
project_domain_id = default
user_domain_id = default
project_name = service
username = {{ .Values.keystone.glance_user }}
password = {{ .Values.keystone.glance_password }}
    
[paste_deploy]
flavor = keystone
    
[oslo_messaging_notifications]
driver = noop
