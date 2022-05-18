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

#NOTE: Get the over-rides to use
: ${OSH_EXTRA_HELM_ARGS_TRILIOVAULT:="$(./tools/deployment/common/get-values-overrides.sh triliovault)"}
: ${RUN_HELM_TESTS:="yes"}

#NOTE: Lint and package chart
make triliovault

: ${OSH_EXTRA_HELM_ARGS:=""}

#NOTE: Deploy command
tee /tmp/triliovault.yaml << EOF
EOF
helm upgrade --install triliovault ./triliovault \
  --namespace=triliovault \
  --values=/tmp/triliovault.yaml \
  --values=./triliovault/values_overrides/image_pull_secrets.yaml \
  --values=./triliovault/values_overrides/conf_triliovault.yaml \
  --values=./triliovault/values_overrides/victoria-ubuntu_focal.yaml \
  --values=./triliovault/values_overrides/admin_creds.yaml \
  --values=./triliovault/values_overrides/tls_public_endpoint.yaml \
  --values=./triliovault/values_overrides/ceph.yaml
  ${OSH_EXTRA_HELM_ARGS:=} \
  ${OSH_EXTRA_HELM_ARGS_TRILIOVAULT}

#NOTE: Wait for deploy
./tools/deployment/common/wait-for-pods.sh triliovault

#NOTE: Validate Deployment info
export OS_CLOUD=openstack_helm
openstack service list
sleep 30 #NOTE(portdirect): Wait for ingress controller to update rules and restart Nginx
kubectl get pods -n triliovault | grep triliovault
#openstack workloads type list
#openstack workloads type list --default

# Run helm tests
if [ "x${RUN_HELM_TESTS}" != "xno" ]; then
    ./tools/deployment/common/run-helm-tests.sh triliovault
fi
