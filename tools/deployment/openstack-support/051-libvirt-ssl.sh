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

: ${OSH_INFRA_EXTRA_HELM_ARGS_LIBVIRT:="$(./tools/deployment/common/get-values-overrides.sh libvirt)"}

CERT_DIR=$(mktemp -d)
cd ${CERT_DIR}
openssl req -x509 -new -nodes -days 1 -newkey rsa:2048 -keyout cacert.key -out cacert.pem -subj "/CN=libvirt.org"
openssl req -newkey rsa:2048 -days 1 -nodes -keyout client-key.pem -out client-req.pem -subj "/CN=libvirt.org"
openssl rsa -in client-key.pem -out client-key.pem
openssl x509 -req -in client-req.pem -days 1 \
  -CA cacert.pem -CAkey cacert.key -set_serial 01 \
  -out client-cert.pem
openssl req -newkey rsa:2048 -days 1 -nodes -keyout server-key.pem -out server-req.pem -subj "/CN=libvirt.org"
openssl rsa -in server-key.pem -out server-key.pem
openssl x509 -req -in server-req.pem -days 1 \
  -CA cacert.pem -CAkey cacert.key -set_serial 01 \
  -out server-cert.pem
cd -

cat <<EOF | kubectl apply -f-
apiVersion: v1
kind: Secret
metadata:
  name: libvirt-tls-client
  namespace: openstack
type: Opaque
data:
  cacert.pem: $(cat ${CERT_DIR}/cacert.pem | base64 -w0)
  clientcert.pem: $(cat ${CERT_DIR}/client-cert.pem | base64 -w0)
  clientkey.pem: $(cat ${CERT_DIR}/client-key.pem | base64 -w0)
EOF


cat <<EOF | kubectl apply -f-
apiVersion: v1
kind: Secret
metadata:
  name: libvirt-tls-server
  namespace: openstack
type: Opaque
data:
  cacert.pem: $(cat ${CERT_DIR}/cacert.pem | base64 -w0)
  servercert.pem: $(cat ${CERT_DIR}/server-cert.pem | base64 -w0)
  serverkey.pem: $(cat ${CERT_DIR}/server-key.pem | base64 -w0)
EOF

#NOTE: Lint and package chart
make libvirt

#NOTE: Deploy command
helm upgrade --install libvirt ./libvirt \
  --namespace=openstack \
  --set network.backend="null" \
  ${OSH_INFRA_EXTRA_HELM_ARGS} \
  ${OSH_INFRA_EXTRA_HELM_ARGS_LIBVIRT}

#NOTE: Please be aware that a network backend might affect
#The loadability of this, as some need to be asynchronously
#loaded. See also:
#https://github.com/openstack/openstack-helm-infra/blob/b69584bd658ae5cb6744e499975f9c5a505774e5/libvirt/values.yaml#L151-L172
if [[ "${WAIT_FOR_PODS:=True}" == "True" ]]; then
    ./tools/deployment/common/wait-for-pods.sh openstack
fi
