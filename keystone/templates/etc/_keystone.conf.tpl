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
debug = {{ .Values.api.default.debug }}
use_syslog = False
use_stderr = True

[database]
connection = mysql+pymysql://{{ .Values.database.keystone_user }}:{{ .Values.database.keystone_password }}@{{ include "helm-toolkit.mariadb_host" . }}/{{ .Values.database.keystone_database_name }}
max_retries = -1

[memcache]
servers = {{ include "helm-toolkit.rabbitmq_host" . }}:11211

[token]
provider = {{ .Values.api.token.provider }}

[cache]
backend = dogpile.cache.memcached
memcache_servers = {{ include "helm-toolkit.rabbitmq_host" . }}:11211
config_prefix = cache.keystone
enabled = True

