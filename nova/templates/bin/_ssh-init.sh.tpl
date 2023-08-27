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

export NOVA_USERNAME=$(id -u ${NOVA_USER_UID} -n)
export NOVA_USER_HOME=$(eval echo ~${NOVA_USERNAME})

mkdir -p ${NOVA_USER_HOME}/.ssh

cat > ${NOVA_USER_HOME}/.ssh/config <<EOF
Host *
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null
  port $SSH_PORT
  IdentitiesOnly yes
EOF

cp /tmp/nova-ssh/* ${NOVA_USER_HOME}/.ssh/
chmod 600 ${NOVA_USER_HOME}/.ssh/id_rsa
chown -R ${NOVA_USERNAME}:${NOVA_USERNAME} ${NOVA_USER_HOME}/.ssh
