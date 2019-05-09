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

passwords="ELASTICSEARCH_ADMIN_PASSWORD \
    GRAFANA_ADMIN_PASSWORD \
    GRAFANA_DB_PASSWORD \
    GRAFANA_SESSION_DB_PASSWORD \
    MARIADB_ADMIN_PASSWORD \
    MARIADB_EXPORTER_PASSWORD \
    MARIADB_SST_PASSWORD \
    NAGIOS_ADMIN_PASSWORD \
    PROMETHEUS_ADMIN_PASSWORD \
    RADOSGW_S3_ADMIN_ACCESS_KEY \
    RADOSGW_S3_ADMIN_SECRET_KEY \
    RADOSGW_S3_ELASTICSEARCH_ACCESS_KEY \
    RADOSGW_S3_ELASTICSEARCH_SECRET_KEY"

for password in $passwords
do
  value=$(tr -dc A-Za-z0-9 < /dev/urandom 2>/dev/null | head -c 20)
  export $password=$value
  echo "export $password=$value" >> /tmp/osh-infra-passwords.env
done
