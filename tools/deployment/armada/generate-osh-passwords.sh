#!/bin/bash

# Copyright 2017 The Openstack-Helm Authors.
#
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.

set -xe

passwords="BARBICAN_DB_PASSWORD \
    BARBICAN_RABBITMQ_USER_PASSWORD \
    BARBICAN_USER_PASSWORD \
    CINDER_DB_PASSWORD \
    CINDER_RABBITMQ_USER_PASSWORD \
    CINDER_TEST_USER_PASSWORD \
    CINDER_USER_PASSWORD \
    GLANCE_DB_PASSWORD \
    GLANCE_RABBITMQ_USER_PASSWORD \
    GLANCE_TEST_USER_PASSWORD \
    GLANCE_USER_PASSWORD \
    HEAT_DB_PASSWORD \
    HEAT_RABBITMQ_USER_PASSWORD \
    HEAT_STACK_PASSWORD \
    HEAT_TEST_USER_PASSWORD \
    HEAT_TRUSTEE_PASSWORD \
    HEAT_USER_PASSWORD \
    KEYSTONE_ADMIN_PASSWORD \
    KEYSTONE_AUTHTOKEN_MEMCACHED_SECRET_KEY \
    KEYSTONE_DB_PASSWORD \
    KEYSTONE_RABBITMQ_USER_PASSWORD \
    KEYSTONE_TEST_USER_PASSWORD \
    METADATA_PROXY_SHARED_SECRET \
    NEUTRON_DB_PASSWORD \
    NEUTRON_RABBITMQ_USER_PASSWORD \
    NEUTRON_TEST_USER_PASSWORD \
    NEUTRON_USER_PASSWORD \
    NOVA_DB_PASSWORD \
    NOVA_PLACEMENT_USER_PASSWORD \
    NOVA_RABBITMQ_USER_PASSWORD \
    NOVA_TEST_USER_PASSWORD \
    NOVA_USER_PASSWORD \
    OPENSTACK_EXPORTER_USER_PASSWORD \
    OSH_MARIADB_ADMIN_PASSWORD \
    OSH_MARIADB_EXPORTER_PASSWORD \
    OSH_MARIADB_SST_PASSWORD \
    RABBITMQ_ADMIN_PASSWORD \
    SWIFT_USER_PASSWORD"

for password in $passwords
do
  value=$(tr -dc A-Za-z0-9 < /dev/urandom 2>/dev/null | head -c 20)
  export $password=$value
  echo "export $password=$value" >> /tmp/osh-passwords.env
done
