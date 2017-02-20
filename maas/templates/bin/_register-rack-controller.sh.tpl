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

# show env
env > /tmp/env

echo "register-rack-controller URL: "{{ .Values.ui_service_name }}.{{ .Release.Namespace }}

# note the secret must be a valid hex value

# register forever
while [ 1 ];
do
	if maas-rack register --url=http://{{ .Values.ui_service_name }}.{{ .Release.Namespace }}/MAAS --secret={{ .Values.secret | quote }};
	then
		echo "Successfully registered with MaaS Region Controller"
		break
	else
		echo "Unable to register with http://{{ .Values.ui_service_name }}.{{ .Release.Namespace }}/MAAS... will try again"
		sleep 10
	fi;

done;
