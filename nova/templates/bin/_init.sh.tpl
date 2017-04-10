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

# standard database

ansible localhost -vvv \
  -m mysql_db -a "login_host='{{ .Values.endpoints.oslo_db.hosts.internal | default .Values.endpoints.oslo_db.hosts.default }}' \
                  login_port='{{ .Values.endpoints.oslo_db.port.mysql }}' \
                  login_user='{{ .Values.endpoints.oslo_db.auth.admin.username }}' \
                  login_password='{{ .Values.endpoints.oslo_db.auth.admin.password }}' \
                  name='{{ .Values.endpoints.oslo_db.path | trimAll "/" }}'"

ansible localhost -vvv \
  -m mysql_user -a "login_host='{{ .Values.endpoints.oslo_db.hosts.internal | default .Values.endpoints.oslo_db.hosts.default }}' \
                    login_port='{{ .Values.endpoints.oslo_db.port.mysql }}' \
                    login_user='{{ .Values.endpoints.oslo_db.auth.admin.username }}' \
                    login_password='{{ .Values.endpoints.oslo_db.auth.admin.password }}' \
                    name='{{ .Values.endpoints.oslo_db.auth.user.username }}' \
                    password='{{ .Values.endpoints.oslo_db.auth.user.password }}' \
                    host='%' \
                    priv='{{ .Values.endpoints.oslo_db.path | trimAll "/" }}.*:ALL' \
                    append_privs='yes'"

# api database

ansible localhost -vvv \
  -m mysql_db -a "login_host='{{ .Values.endpoints.oslo_db_api.hosts.internal | default .Values.endpoints.oslo_db_api.hosts.default }}' \
                  login_port='{{ .Values.endpoints.oslo_db_api.port.mysql }}' \
                  login_user='{{ .Values.endpoints.oslo_db_api.auth.admin.username }}' \
                  login_password='{{ .Values.endpoints.oslo_db_api.auth.admin.password }}' \
                  name='{{ .Values.endpoints.oslo_db_api.path | trimAll "/" }}'"

ansible localhost -vvv \
  -m mysql_user -a "login_host='{{ .Values.endpoints.oslo_db_api.hosts.internal | default .Values.endpoints.oslo_db_api.hosts.default }}' \
                    login_port='{{ .Values.endpoints.oslo_db_api.port.mysql }}' \
                    login_user='{{ .Values.endpoints.oslo_db_api.auth.admin.username }}' \
                    login_password='{{ .Values.endpoints.oslo_db_api.auth.admin.password }}' \
                    name='{{ .Values.endpoints.oslo_db_api.auth.user.username }}' \
                    password='{{ .Values.endpoints.oslo_db_api.auth.user.password }}' \
                    host='%' \
                    priv='{{ .Values.endpoints.oslo_db_api.path | trimAll "/" }}.*:ALL' \
                    append_privs='yes'"
