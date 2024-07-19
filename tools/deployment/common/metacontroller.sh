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

namespace="metacontroller"
: ${OSH_INFRA_HELM_REPO:="../openstack-helm-infra"}
: ${OSH_INFRA_PATH:="../openstack-helm-infra"}
: ${HELM_ARGS_METACONTROLLER:="$(helm osh get-values-overrides -p ${OSH_INFRA_PATH} -c metacontroller ${FEATURES})"}

#NOTE: Check no crd exists of APIGroup metacontroller.k8s.io
crds=$(kubectl get crd | awk '/metacontroller.k8s.io/{print $1}')

if [ -z "$crds" ]; then
  echo "No crd exists of APIGroup metacontroller.k8s.io"
fi

tee /tmp/${namespace}-ns.yaml << EOF
apiVersion: v1
kind: Namespace
metadata:
  labels:
    kubernetes.io/metadata.name: ${namespace}
    name: ${namespace}
  name: ${namespace}
EOF

kubectl create -f /tmp/${namespace}-ns.yaml

#NOTE: Deploy command
helm upgrade --install metacontroller ${OSH_INFRA_HELM_REPO}/metacontroller \
    --namespace=$namespace \
    --set pod.replicas.metacontroller=3 \
    ${HELM_ARGS_METACONTROLLER}

#NOTE: Wait for deploy
helm osh wait-for-pods metacontroller

#NOTE: Check crds of APIGroup metacontroller.k8s.io successfully created
crds=$(kubectl get crd | awk '/metacontroller.k8s.io/{print $1}')

COUNTER=0
for i in $crds
do
  case $i in
   "compositecontrollers.metacontroller.k8s.io") COUNTER=$((COUNTER+1));;
   "controllerrevisions.metacontroller.k8s.io") COUNTER=$((COUNTER+1));;
   "decoratorcontrollers.metacontroller.k8s.io") COUNTER=$((COUNTER+1));;
   *) echo "This is a wrong crd!!!";;
  esac
done

if test $COUNTER -eq 3; then
  echo "crds created succesfully"
fi
