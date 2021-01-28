#!/bin/bash

set -eux

: ${CERT_MANAGER_VERSION:="v1.2.0"}

cert_path="/etc/openstack-helm"
ca_cert_root="$cert_path/certs/ca"

function check_cert {
  # $1: the certificate file, e.g. ca.pem
  # $2: the key file, e.g. ca-key.pem
  local cert="$(openssl x509 -noout -modulus -in $1)"
  local key="$(openssl rsa -noout -modulus -in $2)"
  if ! [ "$cert" = "$key" ]; then
    echo "Failure: tls private key does not match cert"
    exit 1
  else
    echo "Pass: $cert is valid with $key"
  fi
}

# Download cfssl and cfssljson if they are not available on the system
if type cfssl && type cfssljson; then
  echo "cfssl and cfssljson found - skipping installation"
else
  echo "installing cfssl and cfssljson"
  temp_bin=$(mktemp --directory)
  cd $temp_bin
  CFSSLURL=https://pkg.cfssl.org/R1.2
  curl --retry 3 --retry-connrefused -sSL -o cfssl $CFSSLURL/cfssl_linux-amd64
  curl --retry 3 --retry-connrefused -sSL -o cfssljson $CFSSLURL/cfssljson_linux-amd64
  chmod +x {cfssl,cfssljson}
  export PATH=$PATH:$temp_bin
fi

# Sets up a directory for the certs
sudo rm -rf $cert_path
sudo mkdir -p $ca_cert_root
sudo chmod -R go+w $cert_path

cd $ca_cert_root

cat > ca-csr.json <<EOF
{
  "CN": "ACME Company",
  "key": {
    "algo": "rsa",
    "size": 4096
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

cfssl gencert -initca ca-csr.json | cfssljson -bare ca -
check_cert ca.pem ca-key.pem


cat > cfssl.json <<EOF
{
  "signing": {
    "default": {
      "expiry": "8760h"
    },
    "profiles": {
      "intermediate_ca": {
        "expiry": "8760h",
        "usages": [
          "signing",
          "digital signature",
          "cert sign",
          "crl sign",
          "key encipherment",
          "server auth",
          "client auth"
        ],
        "ca_constraint": {
          "is_ca": true
        }
      }
    }
  }
}
EOF

cat > intermediate-ca.json <<EOF
{
  "CN": "OpenStack Helm CA",
  "key": {
    "algo": "rsa",
    "size": 4096
  },
  "names": [
    {
      "C": "GB",
      "L": "Space",
      "ST": "Earth",
      "O": "OSH",
      "OU": "OSH"
    }
  ],
  "ca": {
    "expiry": "8760h"
  }
}
EOF

cfssl gencert -initca intermediate-ca.json | cfssljson -bare intermediate-ca -
cfssl sign -ca ca.pem -ca-key ca-key.pem -config cfssl.json -profile intermediate_ca \
  intermediate-ca.csr | cfssljson -bare intermediate-ca
check_cert intermediate-ca.pem intermediate-ca-key.pem

kubectl create ns cert-manager
helm repo add jetstack https://charts.jetstack.io
helm repo update

# helm 2 command
helm install --name cert-manager --namespace cert-manager \
  --version ${CERT_MANAGER_VERSION} jetstack/cert-manager \
  --set installCRDs=true \
  --set extraArgs[0]="--enable-certificate-owner-ref=true"

# helm 3 command
# helm install cert-manager jetstack/cert-manager --namespace cert-manager \
#   --version ${CERT_MANAGER_VERSION} \
#   --set installCRDs=true \
#   --set extraArgs[0]="--enable-certificate-owner-ref=true"

helm repo remove jetstack

key=$(cat /etc/openstack-helm/certs/ca/ca-key.pem | base64 | tr -d "\n")
crt=$(cat /etc/openstack-helm/certs/ca/ca.pem | base64 | tr -d "\n")

cat > /tmp/ca-issuers.yaml <<EOF
---
apiVersion: v1
kind: Secret
metadata:
  name: ca-key-pair
  namespace: cert-manager
data:
  tls.crt: $crt
  tls.key: $key
---
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: ca-issuer
spec:
  ca:
    secretName: ca-key-pair
EOF


kubectl wait --for=condition=Ready pods --all -n cert-manager --timeout=180s

# Per [0], put a sleep here to guard against the error - failed calling webhook "webhook.cert-manager.io"
# [0] https://github.com/jetstack/cert-manager/issues/2602
sleep 45

kubectl create ns openstack
kubectl apply -f /tmp/ca-issuers.yaml
