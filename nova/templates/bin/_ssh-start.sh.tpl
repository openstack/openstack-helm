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

IFS=','
for KEY_TYPE in $KEY_TYPES; do
    KEY_PATH=/etc/ssh/ssh_host_${KEY_TYPE}_key
    if [[ ! -f "${KEY_PATH}" ]]; then
        ssh-keygen -q -t ${KEY_TYPE} -f ${KEY_PATH} -N ""
    fi
done
IFS=''

subnet_address="{{- .Values.network.ssh.from_subnet -}}"
cat > /tmp/sshd_config_extend <<EOF
PasswordAuthentication no
Match Address $subnet_address
    PermitRootLogin without-password
EOF
cat /tmp/sshd_config_extend >> /etc/ssh/sshd_config

rm /tmp/sshd_config_extend

mkdir -p /run/sshd

exec /usr/sbin/sshd -D -e -o Port=$SSH_PORT
