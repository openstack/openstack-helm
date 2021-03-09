#!/bin/bash

{{/*
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

  if kubectl get cm -n $pvc_namespace ${pod_name}-bin; then
    kubectl delete cm -n $pvc_namespace ${pod_name}-bin
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
  end=$(($(date +%s) + TEST_POD_WAIT_TIMEOUT))
  while ! kubectl get pvc -n $pvc_namespace $pvc_name | grep Bound; do
    if [ "$(date +%s)" -gt "${end}" ]; then
      kubectl get pvc -n $pvc_namespace $pvc_name
      kubectl get pv
      echo "Storageclass is available but can't create PersistentVolumeClaim."
      exit 1
    fi
    sleep 10
  done

  tee <<EOF | kubectl apply --namespace $pvc_namespace -f -
---
kind: ConfigMap
apiVersion: v1
metadata:
  name: ${pod_name}-bin
data:
  test.sh: |
    #!/bin/bash

    tmpdir=\$(mktemp -d)
    declare -a files_list
    total_files=10

    function check_result ()
    {
      red='\033[0;31m'
      green='\033[0;32m'
      bw='\033[0m'
      if [ "\$1" -ne 0 ]; then
        echo -e "\${red}\$2\${bw}"
        exit 1
      else
        echo -e "\${green}\$3\${bw}"
      fi
    }

    echo "Preparing \${total_objects} files for test"
    for i in \$(seq \$total_files); do
      files_list[\$i]="\$(mktemp -p "$tmpdir" -t XXXXXXXX)"
      echo "Creating \${files_list[\$i]} file"
      dd if=/dev/urandom of="\${files_list[\$i]}" bs=1M count=8

      echo "Writing to /mnt/\${files_list[\$i]##*/}"
      cp "\${files_list[\$i]}" "/mnt/\${files_list[\$i]##*/}"
      check_result \$? "The action failed" "The action succeeded"
    done

    for i in \$(seq \$total_files); do
      echo "Comparing files: \${files_list[\$i]} and /mnt/\${files_list[\$i]##*/}"
      cmp "\${files_list[\$i]}" "/mnt/\${files_list[\$i]##*/}"
      check_result \$? "The files are not equal" "The files are equal"
    done

    touch /mnt/SUCCESS && exit 0 || exit 1

---
kind: Pod
apiVersion: v1
metadata:
  name: $pod_name
spec:
  nodeSelector:
    {{ .Values.labels.test.node_selector_key }}: {{ .Values.labels.test.node_selector_value }}
  containers:
  - name: task-pv-storage
    image: {{ .Values.images.tags.ceph_config_helper }}
    command:
    - /tmp/test.sh
    volumeMounts:
    - name: ceph-cm-test
      mountPath: /tmp/test.sh
      subPath: test.sh
      readOnly: true
    - name: pvc
      mountPath: "/mnt"
      readOnly: false
  restartPolicy: "Never"
  volumes:
  - name: ceph-cm-test
    configMap:
      name: ${pod_name}-bin
      defaultMode: 0555
  - name: pvc
    persistentVolumeClaim:
      claimName: $pvc_name
...
EOF

  # waiting for pod to get completed
  end=$(($(date +%s) + TEST_POD_WAIT_TIMEOUT))
  while ! kubectl get pods -n $pvc_namespace $pod_name | grep -i Completed; do
    if [ "$(date +%s)" -gt "${end}" ]; then
      kubectl get pods -n $pvc_namespace $pod_name
      kubectl logs -n $pvc_namespace $pod_name
      echo "Cannot create POD with rbd storage class $storageclass based PersistentVolumeClaim."
      exit 1
    fi
    sleep 10
  done

  kubectl logs -n $pvc_namespace $pod_name
}


reset_test_env $PVC_NAMESPACE $RBD_TEST_POD_NAME $RBD_TEST_PVC_NAME
reset_test_env $PVC_NAMESPACE $CSI_RBD_TEST_POD_NAME $CSI_RBD_TEST_PVC_NAME
reset_test_env $PVC_NAMESPACE $CEPHFS_TEST_POD_NAME $CEPHFS_TEST_PVC_NAME

{{- range $storageclass, $val := .Values.storageclass }}
if [ {{ $val.provisioner }} == "ceph.com/rbd" ] && [ {{ $val.provision_storage_class }} == true ];
then
  echo "--> Checking RBD storage class."
  storageclass={{ $val.metadata.name }}

  storageclass_validation $PVC_NAMESPACE $RBD_TEST_POD_NAME $RBD_TEST_PVC_NAME $storageclass
  reset_test_env $PVC_NAMESPACE $RBD_TEST_POD_NAME $RBD_TEST_PVC_NAME
fi

if [ {{ $val.provisioner }} == "ceph.rbd.csi.ceph.com" ] && [ {{ $val.provision_storage_class }} == true ];
then
  echo "--> Checking CSI RBD storage class."
  storageclass={{ $val.metadata.name }}
  storageclass_validation $PVC_NAMESPACE $CSI_RBD_TEST_POD_NAME $CSI_RBD_TEST_PVC_NAME $storageclass
  reset_test_env $PVC_NAMESPACE $CSI_RBD_TEST_POD_NAME $CSI_RBD_TEST_PVC_NAME
fi

if [ {{ $val.provisioner }} == "ceph.com/cephfs" ] && [ {{ $val.provision_storage_class }} == true ];
then
  echo "--> Checking cephfs storage class."
  storageclass={{ $val.metadata.name }}
  storageclass_validation $PVC_NAMESPACE $CEPHFS_TEST_POD_NAME $CEPHFS_TEST_PVC_NAME $storageclass
  reset_test_env $PVC_NAMESPACE $CEPHFS_TEST_POD_NAME $CEPHFS_TEST_PVC_NAME
fi
{{- end }}
