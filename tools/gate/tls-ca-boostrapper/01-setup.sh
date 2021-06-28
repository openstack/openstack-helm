#!/bin/bash

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

OSH_CONFIG_ROOT="/etc/openstack-helm"
OSH_CA_ROOT="${OSH_CONFIG_ROOT}/certs/ca"

sudo mkdir -p ${OSH_CONFIG_ROOT}
sudo chown $(whoami): -R ${OSH_CONFIG_ROOT}

mkdir -p "${OSH_CA_ROOT}"
openssl req -x509 -nodes -sha256 -days 1 -newkey rsa:2048 \
  -keyout ${OSH_CA_ROOT}/ca-key.pem -out ${OSH_CA_ROOT}/ca.pem \
  -subj "/C=US/L=SomeState/ST=SomeCity/O=SomeOrg/OU=SomeUnit/CN=ACME Company"

function check_cert_and_key () {
  TLS_CERT=$1
  TLS_KEY=$2
  openssl x509 -inform pem -in ${TLS_CERT} -noout -text
  CERT_MOD="$(openssl x509 -noout -modulus -in ${TLS_CERT})"
  KEY_MOD="$(openssl rsa -noout -modulus -in ${TLS_KEY})"
  if ! [ "${CERT_MOD}" = "${KEY_MOD}" ]; then
    echo "Failure: TLS private key does not match this certificate."
    exit 1
  else
    CERT_MOD=""
    KEY_MOD=""
    echo "Pass: ${TLS_CERT} is valid with ${TLS_KEY}"
  fi
}

check_cert_and_key ${OSH_CA_ROOT}/ca.pem ${OSH_CA_ROOT}/ca-key.pem
