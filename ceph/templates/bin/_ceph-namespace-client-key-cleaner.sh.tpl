#!/bin/bash
set -ex

kubectl delete secret ${PVC_CEPH_STORAGECLASS_USER_SECRET_NAME} \
--namespace ${DEPLOYMENT_NAMESPACE} --ignore-not-found=true
