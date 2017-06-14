#!/bin/bash
set -ex

ceph_activate_namespace() {
  kube_namespace=$1
  {
  cat <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: "${PVC_CEPH_STORAGECLASS_USER_SECRET_NAME}"
type: kubernetes.io/rbd
data:
  key: |
    $(kubectl get secret ${PVC_CEPH_STORAGECLASS_ADMIN_SECRET_NAME} \
        --namespace=${PVC_CEPH_STORAGECLASS_DEPLOYED_NAMESPACE} \
        -o json | jq -r '.data | .[]')
EOF
  } | kubectl create --namespace ${kube_namespace} -f -
}

ceph_activate_namespace ${DEPLOYMENT_NAMESPACE}
