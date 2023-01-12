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

CURRENT_DIR=$(pwd)
CFSSLURL=https://pkg.cfssl.org/R1.2

TDIR=/tmp/certs
rm -rf $TDIR
mkdir -p $TDIR/bin

cd $TDIR
curl -sSL -o bin/cfssl $CFSSLURL/cfssl_linux-amd64
curl -sSL -o bin/cfssljson $CFSSLURL/cfssljson_linux-amd64
chmod +x bin/{cfssl,cfssljson}
export PATH=$PATH:./bin

OSH_CONFIG_ROOT="/etc/openstack-helm"
OSH_CA_ROOT="${OSH_CONFIG_ROOT}/certs/ca"
OSH_SERVER_TLS_ROOT="${OSH_CONFIG_ROOT}/certs/server"

sudo mkdir -p ${OSH_CONFIG_ROOT}
sudo chown $(whoami): -R ${OSH_CONFIG_ROOT}

mkdir -p "${OSH_CA_ROOT}"
tee ${OSH_CA_ROOT}/ca-config.json << EOF
{
    "signing": {
        "default": {
            "expiry": "24h"
        },
        "profiles": {
            "server": {
                "expiry": "24h",
                "usages": [
                    "signing",
                    "key encipherment",
                    "server auth"
                ]
            }
        }
    }
}
EOF

tee ${OSH_CA_ROOT}/ca-csr.json << EOF
{
  "CN": "ACME Company",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "SomeState",
      "ST": "SomeCity",
      "O": "SomeOrg",
      "OU": "SomeUnit"
    }
  ]
}
EOF

cfssl gencert -initca ${OSH_CA_ROOT}/ca-csr.json | cfssljson -bare ${OSH_CA_ROOT}/ca -

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

DOMAIN=openstackhelm.test
for HOSTNAME in "swift" "keystone" "heat" "cloudformation" "horizon" "glance" "cinder" "nova" "placement" "novnc" "metadata" "neutron" "barbican"; do
  FQDN="${HOSTNAME}.${DOMAIN}"

  OSH_SERVER_CERTS="${OSH_SERVER_TLS_ROOT}/${HOSTNAME}"
  mkdir -p "${OSH_SERVER_CERTS}"

  tee ${OSH_SERVER_CERTS}/server-csr-${HOSTNAME}.json <<EOF
{
  "CN": "${FQDN}",
  "hosts": [
    "${FQDN}"
  ],
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "SomeState",
      "ST": "SomeCity",
      "O": "SomeOrg",
      "OU": "SomeUnit"
    }
  ]
}
EOF
  cfssl gencert \
    -hostname="${FQDN}" \
    -ca=${OSH_CA_ROOT}/ca.pem \
    -ca-key=${OSH_CA_ROOT}/ca-key.pem \
    -config=${OSH_CA_ROOT}/ca-config.json \
    -profile=server \
    ${OSH_SERVER_CERTS}/server-csr-${HOSTNAME}.json | cfssljson -bare ${OSH_SERVER_CERTS}/server

  check_cert_and_key ${OSH_SERVER_CERTS}/server.pem ${OSH_SERVER_CERTS}/server-key.pem
done

cd $CURRENT_DIR

KEYSTONE_CRT=${OSH_SERVER_TLS_ROOT}/keystone/server.pem
KEYSTONE_KEY=${OSH_SERVER_TLS_ROOT}/keystone/server-key.pem
KEYSTONE_CSR=${OSH_SERVER_TLS_ROOT}/keystone/server-csr-keystone.json

SWIFT_CRT=${OSH_SERVER_TLS_ROOT}/swift/server.pem
SWIFT_KEY=${OSH_SERVER_TLS_ROOT}/swift/server-key.pem
SWIFT_CSR=${OSH_SERVER_TLS_ROOT}/swift/server-csr-swift.json

BARBICAN_CRT=${OSH_SERVER_TLS_ROOT}/barbican/server.pem
BARBICAN_KEY=${OSH_SERVER_TLS_ROOT}/barbican/server-key.pem
BARBICAN_CSR=${OSH_SERVER_TLS_ROOT}/barbican/server-csr-barbican.json

HEAT_API_CRT=${OSH_SERVER_TLS_ROOT}/heat/server.pem
HEAT_API_KEY=${OSH_SERVER_TLS_ROOT}/heat/server-key.pem
HEAT_API_CSR=${OSH_SERVER_TLS_ROOT}/heat/server-csr-heat.json
HEAT_CFN_CRT=${OSH_SERVER_TLS_ROOT}/cloudformation/server.pem
HEAT_CFN_KEY=${OSH_SERVER_TLS_ROOT}/cloudformation/server-key.pem
HEAT_CFN_CSR=${OSH_SERVER_TLS_ROOT}/cloudformation/server-csr-cloudformation.json

HORIZON_CRT=${OSH_SERVER_TLS_ROOT}/horizon/server.pem
HORIZON_KEY=${OSH_SERVER_TLS_ROOT}/horizon/server-key.pem
HORIZON_CSR=${OSH_SERVER_TLS_ROOT}/horizon/server-csr-horizon.json

GLANCE_API_CRT=${OSH_SERVER_TLS_ROOT}/glance/server.pem
GLANCE_API_KEY=${OSH_SERVER_TLS_ROOT}/glance/server-key.pem
GLANCE_API_CSR=${OSH_SERVER_TLS_ROOT}/glance/server-csr-glance.json

CINDER_CRT=${OSH_SERVER_TLS_ROOT}/cinder/server.pem
CINDER_KEY=${OSH_SERVER_TLS_ROOT}/cinder/server-key.pem
CINDER_CSR=${OSH_SERVER_TLS_ROOT}/cinder/server-csr-cinder.json

NOVA_API_CRT=${OSH_SERVER_TLS_ROOT}/nova/server.pem
NOVA_API_KEY=${OSH_SERVER_TLS_ROOT}/nova/server-key.pem
NOVA_API_CSR=${OSH_SERVER_TLS_ROOT}/nova/server-csr-nova.json

NOVA_NOVNC_CRT=${OSH_SERVER_TLS_ROOT}/novnc/server.pem
NOVA_NOVNC_KEY=${OSH_SERVER_TLS_ROOT}/novnc/server-key.pem
NOVA_NOVNC_CSR=${OSH_SERVER_TLS_ROOT}/novnc/server-csr-novnc.json

PLACEMENT_CRT=${OSH_SERVER_TLS_ROOT}/placement/server.pem
PLACEMENT_KEY=${OSH_SERVER_TLS_ROOT}/placement/server-key.pem
PLACEMENT_CSR=${OSH_SERVER_TLS_ROOT}/placement/server-csr-placement.json

NEUTRON_SERVER_CRT=${OSH_SERVER_TLS_ROOT}/neutron/server.pem
NEUTRON_SERVER_KEY=${OSH_SERVER_TLS_ROOT}/neutron/server-key.pem
NEUTRON_SERVER_CSR=${OSH_SERVER_TLS_ROOT}/neutron/server-csr-neutron.json

BARBICAN_API_CRT=${OSH_SERVER_TLS_ROOT}/barbican/server.pem
BARBICAN_API_KEY=${OSH_SERVER_TLS_ROOT}/barbican/server-key.pem
BARBICAN_API_CSR=${OSH_SERVER_TLS_ROOT}/barbican/server-csr-barbican.json

tee /tmp/tls-endpoints.yaml << EOF
endpoints:
  object_store:
    scheme:
      public: https
    port:
      api:
        public: 443
    host_fqdn_override:
      public:
        host: "$(cat "${SWIFT_CSR}" | jq -r '.CN')"
        tls:
          crt: |
$(cat ${SWIFT_CRT} | sed 's/^/            /')
          key: |
$(cat ${SWIFT_KEY} | sed 's/^/            /')
          ca: |
$(cat ${OSH_CA_ROOT}/ca.pem | sed 's/^/            /')
  identity:
    scheme:
      public: https
    port:
      api:
        public: 443
    host_fqdn_override:
      public:
        host: "$(cat "${KEYSTONE_CSR}" | jq -r '.CN')"
        tls:
          crt: |
$(cat ${KEYSTONE_CRT} | sed 's/^/            /')
          key: |
$(cat ${KEYSTONE_KEY} | sed 's/^/            /')
          ca: |
$(cat ${OSH_CA_ROOT}/ca.pem | sed 's/^/            /')
  orchestration:
    scheme:
      public: https
    port:
      api:
        public: 443
    host_fqdn_override:
      public:
        host: "$(cat "${HEAT_API_CSR}" | jq -r '.CN')"
        tls:
          crt: |
$(cat ${HEAT_API_CRT} | sed 's/^/            /')
          key: |
$(cat ${HEAT_API_KEY} | sed 's/^/            /')
          ca: |
$(cat ${OSH_CA_ROOT}/ca.pem | sed 's/^/            /')
  cloudformation:
    scheme:
      public: https
    port:
      cfn:
        public: 443
    host_fqdn_override:
      public:
        host: "$(cat "${HEAT_CFN_CSR}" | jq -r '.CN')"
        tls:
          crt: |
$(cat ${HEAT_CFN_CRT} | sed 's/^/            /')
          key: |
$(cat ${HEAT_CFN_KEY} | sed 's/^/            /')
          ca: |
$(cat ${OSH_CA_ROOT}/ca.pem | sed 's/^/            /')
  dashboard:
    scheme:
      public: https
    port:
      web:
        public: 443
    host_fqdn_override:
      public:
        host: "$(cat "${HORIZON_CSR}" | jq -r '.CN')"
        tls:
          crt: |
$(cat ${HORIZON_CRT} | sed 's/^/            /')
          key: |
$(cat ${HORIZON_KEY} | sed 's/^/            /')
          ca: |
$(cat ${OSH_CA_ROOT}/ca.pem | sed 's/^/            /')
  image:
    scheme:
      public: https
    port:
      api:
        public: 443
    host_fqdn_override:
      public:
        host: "$(cat "${GLANCE_API_CSR}" | jq -r '.CN')"
        tls:
          crt: |
$(cat ${GLANCE_API_CRT} | sed 's/^/            /')
          key: |
$(cat ${GLANCE_API_KEY} | sed 's/^/            /')
          ca: |
$(cat ${OSH_CA_ROOT}/ca.pem | sed 's/^/            /')
  volume:
    scheme:
      public: https
    port:
      api:
        public: 443
    host_fqdn_override:
      public:
        host: "$(cat "${CINDER_CSR}" | jq -r '.CN')"
        tls:
          crt: |
$(cat ${CINDER_CRT} | sed 's/^/            /')
          key: |
$(cat ${CINDER_KEY} | sed 's/^/            /')
          ca: |
$(cat ${OSH_CA_ROOT}/ca.pem | sed 's/^/            /')
  volumev2:
    scheme:
      public: https
    port:
      api:
        public: 443
    host_fqdn_override:
      public:
        host: "$(cat "${CINDER_CSR}" | jq -r '.CN')"
        tls:
          crt: |
$(cat ${CINDER_CRT} | sed 's/^/            /')
          key: |
$(cat ${CINDER_KEY} | sed 's/^/            /')
          ca: |
$(cat ${OSH_CA_ROOT}/ca.pem | sed 's/^/            /')
  volumev3:
    scheme:
      public: https
    port:
      api:
        public: 443
    host_fqdn_override:
      public:
        host: "$(cat "${CINDER_CSR}" | jq -r '.CN')"
        tls:
          crt: |
$(cat ${CINDER_CRT} | sed 's/^/            /')
          key: |
$(cat ${CINDER_KEY} | sed 's/^/            /')
          ca: |
$(cat ${OSH_CA_ROOT}/ca.pem | sed 's/^/            /')
  compute:
    scheme:
      public: https
    port:
      api:
        public: 443
    host_fqdn_override:
      public:
        host: "$(cat "${NOVA_API_CSR}" | jq -r '.CN')"
        tls:
          crt: |
$(cat ${NOVA_API_CRT} | sed 's/^/            /')
          key: |
$(cat ${NOVA_API_KEY} | sed 's/^/            /')
          ca: |
$(cat ${OSH_CA_ROOT}/ca.pem | sed 's/^/            /')
  compute_novnc_proxy:
    scheme:
      public: https
    port:
      novnc_proxy:
        public: 443
    host_fqdn_override:
      public:
        host: "$(cat "${NOVA_NOVNC_CSR}" | jq -r '.CN')"
        tls:
          crt: |
$(cat ${NOVA_NOVNC_CRT} | sed 's/^/            /')
          key: |
$(cat ${NOVA_NOVNC_KEY} | sed 's/^/            /')
          ca: |
$(cat ${OSH_CA_ROOT}/ca.pem | sed 's/^/            /')
  placement:
    scheme:
      public: https
    port:
      api:
        public: 443
    host_fqdn_override:
      public:
        host: "$(cat "${PLACEMENT_CSR}" | jq -r '.CN')"
        tls:
          crt: |
$(cat ${PLACEMENT_CRT} | sed 's/^/            /')
          key: |
$(cat ${PLACEMENT_KEY} | sed 's/^/            /')
          ca: |
$(cat ${PLACEMENT_ROOT}/ca.pem | sed 's/^/            /')
  network:
    scheme:
      public: https
    port:
      api:
        public: 443
    host_fqdn_override:
      public:
        host: "$(cat "${NEUTRON_SERVER_CSR}" | jq -r '.CN')"
        tls:
          crt: |
$(cat ${NEUTRON_SERVER_CRT} | sed 's/^/            /')
          key: |
$(cat ${NEUTRON_SERVER_KEY} | sed 's/^/            /')
          ca: |
$(cat ${OSH_CA_ROOT}/ca.pem | sed 's/^/            /')
  key_manager:
    scheme:
      public: https
    port:
      api:
        public: 443
    host_fqdn_override:
      public:
        host: "$(cat "${BARBICAN_API_CSR}" | jq -r '.CN')"
        tls:
          crt: |
$(cat ${BARBICAN_API_CRT} | sed 's/^/            /')
          key: |
$(cat ${BARBICAN_API_KEY} | sed 's/^/            /')
          ca: |
$(cat ${OSH_CA_ROOT}/ca.pem | sed 's/^/            /')
EOF

export OSH_EXTRA_HELM_ARGS="--values=/tmp/tls-endpoints.yaml"
