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

# Make the Nova Instances Dir as this is not autocreated.
mkdir -p /var/lib/nova/instances

# Set Ownership of nova dirs to the nova user
chown ${NOVA_USER_UID} /var/lib/nova /var/lib/nova/instances

migration_interface="{{- .Values.conf.libvirt.live_migration_interface -}}"
if [[ -n $migration_interface ]]; then
    # determine ip dynamically based on interface provided
    migration_address=$(ip a s $migration_interface | grep 'inet ' | awk '{print $2}' | awk -F "/" '{print $1}')
fi

touch /tmp/pod-shared/nova-libvirt.conf
if [[ -n $migration_address ]]; then
cat <<EOF>/tmp/pod-shared/nova-libvirt.conf
[libvirt]
live_migration_inbound_addr = $migration_address
EOF
fi
