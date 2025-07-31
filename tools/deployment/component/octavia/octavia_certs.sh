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
  server_ca.cert.pem: $(trim_data dual_ca/etc/octavia/certs/server_ca.cert.pem)
  server_ca-chain.cert.pem: $(trim_data dual_ca/etc/octavia/certs/server_ca-chain.cert.pem)
  server_ca.key.pem: $(trim_data dual_ca/etc/octavia/certs/server_ca.key.pem)
  client_ca.cert.pem: $(trim_data dual_ca/etc/octavia/certs/client_ca.cert.pem)
  client.cert-and-key.pem: $(trim_data dual_ca/etc/octavia/certs/client.cert-and-key.pem)
EOF
  }| kubectl apply --namespace openstack -f -
}

(
    cd "$(dirname "$0")";
    ./create_dual_intermediate_CA.sh
    create_secret
)
