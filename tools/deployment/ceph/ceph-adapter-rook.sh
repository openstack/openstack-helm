
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

make ceph-adapter-rook

tee > /tmp/ceph-adapter-rook-ceph.yaml <<EOF
manifests:
  configmap_bin: true
  configmap_templates: true
  configmap_etc: false
  job_storage_admin_keys: true
  job_namespace_client_key: false
  job_namespace_client_ceph_config: false
  service_mon_discovery: true
EOF

helm upgrade --install ceph-adapter-rook ./ceph-adapter-rook \
  --namespace=ceph \
  --values=/tmp/ceph-adapter-rook-ceph.yaml

#NOTE: Wait for deploy
./tools/deployment/common/wait-for-pods.sh ceph

tee > /tmp/ceph-adapter-rook-openstack.yaml <<EOF
manifests:
  configmap_bin: true
  configmap_templates: false
  configmap_etc: true
  job_storage_admin_keys: false
  job_namespace_client_key: true
  job_namespace_client_ceph_config: true
  service_mon_discovery: false
EOF

helm upgrade --install ceph-adapter-rook ./ceph-adapter-rook \
  --namespace=openstack \
  --values=/tmp/ceph-adapter-rook-openstack.yaml

#NOTE: Wait for deploy
./tools/deployment/common/wait-for-pods.sh openstack
