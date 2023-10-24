#!/bin/bash

# Copyright 2019 Samsung Electronics Co., Ltd.
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

function trim_data() {
  local data_path=$1
  cat $data_path | base64 -w0 | tr -d '\n'
}

function create_secret() {
  {
  cat <<EOF
---
apiVersion: v1
kind: Secret
metadata:
  name: octavia-certs
type: Opaque
data:
   ca_01.pem: $(trim_data /tmp/octavia_certs/ca_01.pem)
   cakey.pem: $(trim_data /tmp/octavia_certs/private/cakey.pem)
   client.pem: $(trim_data /tmp/octavia_certs/client.pem)
EOF
  }| kubectl apply --namespace openstack -f -
}

rm -rf /tmp/octavia
git clone -b stable/stein https://github.com/openstack/octavia.git /tmp/octavia
cd /tmp/octavia/bin

rm -rf /tmp/octavia_certs
./create_certificates.sh /tmp/octavia_certs /tmp/octavia/etc/certificates/openssl.cnf

create_secret
