#!/bin/bash

{{/*
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/}}

set -ex

touch /tmp/pod-shared-triliovault-datamover-api/triliovault-datamover-api-my-ip.conf

host_interface="{{- .Values.conf.my_ip.host_interface -}}"
if [[ -z $host_interface ]]; then
    # search for interface with default routing
    # If there is not default gateway, exit
    host_interface=$(ip -4 route list 0/0 | awk -F 'dev' '{ print $2; exit }' | awk '{ print $1 }') || exit 1
fi

datamover_api_ip_address=$(ip a s $host_interface | grep 'inet ' | awk '{print $2}' | awk -F "/" '{print $1}' | head -1)

if [ -z "${datamover_api_ip_address}" ] ; then
  echo "Var my_ip is empty"
  exit 1
fi

tee > /tmp/pod-shared-triliovault-datamover-api/triliovault-datamover-api-my-ip.conf << EOF
[DEFAULT]
dmapi_link_prefix = http://${datamover_api_ip_address}:8784
dmapi_listen = $datamover_api_ip_address
my_ip = $datamover_api_ip_address
EOF




