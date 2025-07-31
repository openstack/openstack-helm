#!/bin/bash

# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.

echo "!!!!!!!!!!!!!!!Do not use this script for deployments!!!!!!!!!!!!!"
echo "Please use the Octavia Certificate Configuration guide:"
echo "https://docs.openstack.org/octavia/latest/admin/guides/certificates.html"
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"

# This script produces weak security PKI to save resources in the test gates.
# It should be modified to use stronger encryption (aes256), better pass
# phrases, and longer keys (4096).
# Please see the Octavia Certificate Configuration guide:
# https://docs.openstack.org/octavia/latest/admin/guides/certificates.html

set -x -e

OPENSSL_CONF="$(readlink -f "$(dirname "$0")")"/openssl.cnf

CA_PATH=dual_ca

rm -rf $CA_PATH
mkdir $CA_PATH
chmod 700 $CA_PATH
cd $CA_PATH

mkdir -p etc/octavia/certs
chmod 700 etc/octavia/certs

###### Client Root CA
mkdir client_ca
cd client_ca
mkdir certs crl newcerts private
chmod 700 private
touch index.txt
echo 1000 > serial

# Create the client CA private key
openssl genpkey -algorithm RSA -out private/ca.key.pem -aes-128-cbc -pass pass:not-secure-passphrase
chmod 400 private/ca.key.pem

# Create the client CA root certificate
openssl req -config ${OPENSSL_CONF} -key private/ca.key.pem -new -x509 -sha256 -extensions v3_ca -days 7300 -out certs/ca.cert.pem -subj "/C=US/ST=Oregon/L=Corvallis/O=OpenStack/OU=Octavia/CN=ClientRootCA" -passin pass:not-secure-passphrase

###### Client Intermediate CA
mkdir intermediate_ca
mkdir intermediate_ca/certs intermediate_ca/crl intermediate_ca/newcerts intermediate_ca/private
chmod 700 intermediate_ca/private
touch intermediate_ca/index.txt
echo 1000 > intermediate_ca/serial

# Create the client intermediate CA private key
openssl genpkey -algorithm RSA -out intermediate_ca/private/intermediate.ca.key.pem -aes-128-cbc -pass pass:not-secure-passphrase
chmod 400 intermediate_ca/private/intermediate.ca.key.pem

# Create the client intermediate CA certificate signing request
openssl req -config ${OPENSSL_CONF} -key intermediate_ca/private/intermediate.ca.key.pem -new -sha256 -out intermediate_ca/client_intermediate.csr -subj "/C=US/ST=Oregon/L=Corvallis/O=OpenStack/OU=Octavia/CN=ClientIntermediateCA" -passin pass:not-secure-passphrase

# Create the client intermediate CA certificate
openssl ca -config ${OPENSSL_CONF} -name CA_intermediate -extensions v3_intermediate_ca -days 3650 -notext -md sha256 -in intermediate_ca/client_intermediate.csr -out intermediate_ca/certs/intermediate.cert.pem -passin pass:not-secure-passphrase -batch

# Create the client CA certificate chain
cat intermediate_ca/certs/intermediate.cert.pem certs/ca.cert.pem > intermediate_ca/ca-chain.cert.pem

###### Create the client key and certificate
openssl genpkey -algorithm RSA -out intermediate_ca/private/controller.key.pem -aes-128-cbc -pass pass:not-secure-passphrase
chmod 400 intermediate_ca/private/controller.key.pem

# Create the client controller certificate signing request
openssl req -config ${OPENSSL_CONF} -key intermediate_ca/private/controller.key.pem -new -sha256 -out intermediate_ca/controller.csr -subj "/C=US/ST=Oregon/L=Corvallis/O=OpenStack/OU=Octavia/CN=OctaviaController" -passin pass:not-secure-passphrase

# Create the client controller certificate
openssl ca -config ${OPENSSL_CONF} -name CA_intermediate -extensions usr_cert -days 1825 -notext -md sha256 -in intermediate_ca/controller.csr -out intermediate_ca/certs/controller.cert.pem -passin pass:not-secure-passphrase -batch

# Build the cancatenated client cert and key
openssl rsa -in intermediate_ca/private/controller.key.pem -out intermediate_ca/private/client.cert-and-key.pem -passin pass:not-secure-passphrase

cat intermediate_ca/certs/controller.cert.pem >> intermediate_ca/private/client.cert-and-key.pem

# We are done with the client CA
cd ..

###### Stash the octavia default client CA cert files
cp client_ca/intermediate_ca/ca-chain.cert.pem etc/octavia/certs/client_ca.cert.pem
chmod 444 etc/octavia/certs/client_ca.cert.pem
cp client_ca/intermediate_ca/private/client.cert-and-key.pem etc/octavia/certs/client.cert-and-key.pem
chmod 600 etc/octavia/certs/client.cert-and-key.pem

###### Server Root CA
mkdir server_ca
cd server_ca
mkdir certs crl newcerts private
chmod 700 private
touch index.txt
echo 1000 > serial

# Create the server CA private key
openssl genpkey -algorithm RSA -out private/ca.key.pem -aes-128-cbc -pass pass:not-secure-passphrase
chmod 400 private/ca.key.pem

# Create the server CA root certificate
openssl req -config ${OPENSSL_CONF} -key private/ca.key.pem -new -x509 -sha256 -extensions v3_ca -days 7300 -out certs/ca.cert.pem -subj "/C=US/ST=Oregon/L=Corvallis/O=OpenStack/OU=Octavia/CN=ServerRootCA" -passin pass:not-secure-passphrase

###### Server Intermediate CA
mkdir intermediate_ca
mkdir intermediate_ca/certs intermediate_ca/crl intermediate_ca/newcerts intermediate_ca/private
chmod 700 intermediate_ca/private
touch intermediate_ca/index.txt
echo 1000 > intermediate_ca/serial

# Create the server intermediate CA private key
openssl genpkey -algorithm RSA -out intermediate_ca/private/intermediate.ca.key.pem -aes-128-cbc -pass pass:not-secure-passphrase
chmod 400 intermediate_ca/private/intermediate.ca.key.pem

# Create the server intermediate CA certificate signing request
openssl req -config ${OPENSSL_CONF} -key intermediate_ca/private/intermediate.ca.key.pem -new -sha256 -out intermediate_ca/server_intermediate.csr -subj "/C=US/ST=Oregon/L=Corvallis/O=OpenStack/OU=Octavia/CN=ServerIntermediateCA" -passin pass:not-secure-passphrase

# Create the server intermediate CA certificate
openssl ca -config ${OPENSSL_CONF} -name CA_intermediate -extensions v3_intermediate_ca -days 3650 -notext -md sha256 -in intermediate_ca/server_intermediate.csr -out intermediate_ca/certs/intermediate.cert.pem -passin pass:not-secure-passphrase -batch

# Create the server CA certificate chain
cat intermediate_ca/certs/intermediate.cert.pem certs/ca.cert.pem > intermediate_ca/ca-chain.cert.pem

# We are done with the server CA
cd ..

###### Stash the octavia default server CA cert files
cp server_ca/intermediate_ca/ca-chain.cert.pem etc/octavia/certs/server_ca-chain.cert.pem
chmod 444 etc/octavia/certs/server_ca-chain.cert.pem
cp server_ca/intermediate_ca/certs/intermediate.cert.pem etc/octavia/certs/server_ca.cert.pem
chmod 400 etc/octavia/certs/server_ca.cert.pem
cp server_ca/intermediate_ca/private/intermediate.ca.key.pem etc/octavia/certs/server_ca.key.pem
chmod 400 etc/octavia/certs/server_ca.key.pem

##### Validate the Octavia PKI files
set +x
echo "################# Verifying the Octavia files ###########################"
openssl verify -CAfile etc/octavia/certs/client_ca.cert.pem etc/octavia/certs/client.cert-and-key.pem
openssl verify -CAfile etc/octavia/certs/server_ca-chain.cert.pem etc/octavia/certs/server_ca.cert.pem

# We are done, stop enforcing shell errexit
set +e

echo "!!!!!!!!!!!!!!!Do not use this script for deployments!!!!!!!!!!!!!"
echo "Please use the Octavia Certificate Configuration guide:"
echo "https://docs.openstack.org/octavia/latest/admin/guides/certificates.html"
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
