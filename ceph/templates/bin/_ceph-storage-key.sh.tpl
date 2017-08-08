#!/bin/bash

{{/*
Copyright 2017 The Openstack-Helm Authors.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/}}

set -ex

function ceph_gen_key () {
  python ${CEPH_GEN_DIR}/ceph-key.py
}

function kube_ceph_keyring_gen () {
  CEPH_KEY=$1
  CEPH_KEY_TEMPLATE=$2
  sed "s|{{"{{"}} key {{"}}"}}|${CEPH_KEY}|" ${CEPH_TEMPLATES_DIR}/${CEPH_KEY_TEMPLATE} | base64 | tr -d '\n'
}

CEPH_CLIENT_KEY=$(ceph_gen_key)

function create_kube_key () {
  CEPH_KEYRING=$1
  CEPH_KEYRING_NAME=$2
  CEPH_KEYRING_TEMPLATE=$3
  KUBE_SECRET_NAME=$4

  if ! kubectl get --namespace ${DEPLOYMENT_NAMESPACE} secrets ${KUBE_SECRET_NAME}; then
    {
      cat <<EOF
---
apiVersion: v1
kind: Secret
metadata:
  name: ${KUBE_SECRET_NAME}
type: Opaque
data:
  ${CEPH_KEYRING_NAME}: |
    $( kube_ceph_keyring_gen ${CEPH_KEYRING} ${CEPH_KEYRING_TEMPLATE} )
EOF
    } | kubectl create --namespace ${DEPLOYMENT_NAMESPACE} -f -
  fi
}
#create_kube_key <ceph_key> <ceph_keyring_name> <ceph_keyring_template> <kube_secret_name>
create_kube_key ${CEPH_CLIENT_KEY} ${CEPH_KEYRING_NAME} ${CEPH_KEYRING_TEMPLATE} ${CEPH_KEYRING_ADMIN_NAME}

function create_kube_storage_key () {
  CEPH_KEYRING=$1
  KUBE_SECRET_NAME=$2

  if ! kubectl get --namespace ${DEPLOYMENT_NAMESPACE} secrets ${KUBE_SECRET_NAME}; then
    {
      cat <<EOF
---
apiVersion: v1
kind: Secret
metadata:
  name: ${KUBE_SECRET_NAME}
type: kubernetes.io/rbd
data:
  key: |
    $( echo ${CEPH_KEYRING} | base64 | tr -d '\n' )
EOF
    } | kubectl create --namespace ${DEPLOYMENT_NAMESPACE} -f -
  fi
}
#create_kube_storage_key <ceph_key> <kube_secret_name>
create_kube_storage_key ${CEPH_CLIENT_KEY} ${CEPH_STORAGECLASS_ADMIN_SECRET_NAME}
