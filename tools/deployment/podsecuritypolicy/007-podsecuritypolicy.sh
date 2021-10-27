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

#NOTE: Lint and package chart
make podsecuritypolicy

#NOTE: Create a privileged pod to test with
tee /tmp/psp-test-pod.yaml << EOF
apiVersion: v1
kind: Pod
metadata:
  name: psp-test
spec:
  hostNetwork: true
  containers:
  - name: psp-test
    image: na
EOF

#NOTE: Deploy with host networking off, and test for failure
helm upgrade --install podsecuritypolicy ./podsecuritypolicy \
  --namespace=kube-system \
  --set data.psp-default.spec.hostNetwork=false \
  ${OSH_INFRA_EXTRA_HELM_ARGS} \
  ${OSH_INFRA_EXTRA_HELM_ARGS_PODSECURITYPOLICY}

#NOTE: Wait for deploy
./tools/deployment/common/wait-for-pods.sh kube-system

# Test that host networking is disallowed
if kubectl apply -f /tmp/psp-test-pod.yaml; then
  echo "ERROR: podsecuritypolicy incorrectly admitted a privileged pod"
  kubectl delete pod psp-test
  exit 1
else
  echo "Failure above is expected. Continuing."
fi

#NOTE: Deploy with host networking on, and test for success
helm upgrade --install podsecuritypolicy ./podsecuritypolicy \
  --namespace=kube-system \
  --set data.psp-default.spec.hostNetwork=true \
  ${OSH_INFRA_EXTRA_HELM_ARGS} \
  ${OSH_INFRA_EXTRA_HELM_ARGS_PODSECURITYPOLICY}

#NOTE: Wait for deploy
./tools/deployment/common/wait-for-pods.sh kube-system

# Test that host networking is allowed
kubectl apply -f /tmp/psp-test-pod.yaml

kubectl delete pod psp-test
