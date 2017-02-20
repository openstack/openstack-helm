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

if ! find "/etc/postgresql" -mindepth 1 -print -quit | grep -q .; then
    pg_createcluster 9.5 main

    #allow external connections to postgresql
    sed -i '/#listen_addresses/s/^#//g' /etc/postgresql/9.5/main/postgresql.conf
    sed -i '/^listen_addresses/ s/localhost/*/' /etc/postgresql/9.5/main/postgresql.conf
    sed -i '$ a host all all 0.0.0.0/0 md5' /etc/postgresql/9.5/main/pg_hba.conf
    sed -i '$ a host all all ::/0 md5' /etc/postgresql/9.5/main/pg_hba.conf
fi

cp -r /etc/postgresql/9.5/main/*.conf /var/lib/postgresql/9.5/main/
pg_ctlcluster 9.5 main start

echo 'running postinst'

chmod 755 /var/lib/dpkg/info/maas-region-controller.postinst
/bin/sh /var/lib/dpkg/info/maas-region-controller.postinst configure

maas-region createadmin --username={{ .Values.credentials.admin_username }} --password={{ .Values.credentials.admin_password }} --email={{ .Values.credentials.admin_email }} || true
