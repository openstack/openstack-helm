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

ansible localhost -vvv \
    -m mysql_db -a "login_host='{{ .Values.database.address }}' \
                    login_port='{{ .Values.database.port }}' \
                    login_user='{{ .Values.database.root_user }}' \
                    login_password='{{ .Values.database.root_password }}' \
                    name='{{ .Values.database.cinder_database_name }}'"

ansible localhost -vvv \
    -m mysql_user -a "login_host='{{ .Values.database.address }}' \
                      login_port='{{ .Values.database.port }}' \
                      login_user='{{ .Values.database.root_user }}' \
                      login_password='{{ .Values.database.root_password }}' \
                      name='{{ .Values.database.cinder_user }}' \
                      password='{{ .Values.database.cinder_password }}' \
                      host='%' \
                      priv='{{ .Values.database.cinder_database_name }}.*:ALL' \
                      append_privs='yes'"
