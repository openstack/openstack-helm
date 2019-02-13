#!/bin/bash

{{/*
Copyright 2019 The Openstack-Helm Authors.

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

function reset_test_env()
{
  pvc_namespace=$1
  pod_name=$2
  pvc_name=$3
  echo "--> Resetting POD and PVC before/after test"
  if kubectl get pod -n $pvc_namespace $pod_name; then
    kubectl delete pod -n $pvc_namespace $pod_name
  fi

  if kubectl get pvc -n $pvc_namespace $pvc_name; then
    kubectl delete pvc -n $pvc_namespace $pvc_name;
  fi
}


function storageclass_validation()
{
  pvc_namespace=$1
  pod_name=$2
  pvc_name=$3
  storageclass=$4
  echo "--> Starting validation"

  # storageclass check
  if ! kubectl get storageclass $storageclass; then
    echo "Storageclass: $storageclass is not provisioned."
    exit 1
  fi

  tee <<EOF | kubectl apply -n $pvc_namespace -f -
---
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: $pvc_name
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: $storageclass
  resources:
    requests:
      storage: 3Gi
EOF

  # waiting for pvc to get create
  sleep 30
  if ! kubectl get pvc -n $pvc_namespace $pvc_name|grep Bound; then
    echo "Storageclass is available but can't create PersistentVolumeClaim."
    exit 1
  fi

  tee <<EOF | kubectl apply --namespace $pvc_namespace -f -
---
kind: Pod
apiVersion: v1
metadata:
  name: $pod_name
spec:
  containers:
  - name: task-pv-storage
    image: {{ .Values.images.tags.ceph_config_helper }}
    command:
    - "/bin/sh"
    args:
    - "-c"
    - "touch /mnt/SUCCESS && exit 0 || exit 1"
    volumeMounts:
    - name: pvc
      mountPath: "/mnt"
      readOnly: false
  restartPolicy: "Never"
  volumes:
  - name: pvc
    persistentVolumeClaim:
      claimName: $pvc_name
EOF

  # waiting for pod to get create
  sleep 60
  if ! kubectl get pods -n $pvc_namespace $pod_name; then
    echo "Can not create POD with rbd storage class $storageclass based PersistentVolumeClaim."
    echo 1
  fi

}


reset_test_env $PVC_NAMESPACE $RBD_TEST_POD_NAME $RBD_TEST_PVC_NAME
reset_test_env $PVC_NAMESPACE $CEPHFS_TEST_POD_NAME $CEPHFS_TEST_PVC_NAME

if [ {{ .Values.storageclass.rbd.provision_storage_class }} == true ];
then
  echo "--> Checking RBD storage class."
  storageclass={{ .Values.storageclass.rbd.metadata.name }}

  storageclass_validation $PVC_NAMESPACE $RBD_TEST_POD_NAME $RBD_TEST_PVC_NAME $storageclass
  reset_test_env $PVC_NAMESPACE $RBD_TEST_POD_NAME $RBD_TEST_PVC_NAME
fi

if [ {{ .Values.storageclass.cephfs.provision_storage_class }} == true ];
then
  echo "--> Checking cephfs storage class."
  storageclass={{ .Values.storageclass.cephfs.metadata.name }}
  storageclass_validation $PVC_NAMESPACE $CEPHFS_TEST_POD_NAME $CEPHFS_TEST_PVC_NAME $storageclass
  reset_test_env $PVC_NAMESPACE $CEPHFS_TEST_POD_NAME $CEPHFS_TEST_PVC_NAME
fi
