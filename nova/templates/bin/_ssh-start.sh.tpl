#!/bin/bash

{{/*
Copyright 2017 The Openstack-Helm Authors.

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

mkdir -p ~nova/.ssh

if [[ $(stat -c %U:%G ~nova/.ssh) != "nova:nova" ]]; then
    chown nova: ~nova/.ssh
fi

chmod 0600 ~root/.ssh/authorized_keys
chmod 0600 ~root/.ssh/id_rsa
chmod 0600 ~root/.ssh/id_rsa.pub

exec /usr/sbin/sshd -D -e -o Port=$SSH_PORT
