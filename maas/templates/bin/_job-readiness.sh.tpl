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

</dev/tcp/{{ .Values.ui_service_name }}.{{ .Release.Namespace }}/{{ .Values.network.port.service_gui }} && \
</dev/tcp/{{ .Values.db_service_name }}.{{ .Release.Namespace }}/{{ .Values.network.port.db_service }} && \
pg_isready -h {{ .Values.db_service_name }}.{{ .Release.Namespace }} && \
maas-region apikey --username={{ .Values.credentials.admin_username }} || exit 1
