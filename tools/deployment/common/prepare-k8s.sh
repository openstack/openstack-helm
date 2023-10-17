#!/bin/bash
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -ex

# Add labels to the core namespaces & nodes
kubectl label --overwrite namespace default name=default
kubectl label --overwrite namespace kube-system name=kube-system
kubectl label --overwrite namespace kube-public name=kube-public
kubectl label --overwrite nodes --all openstack-control-plane=enabled
kubectl label --overwrite nodes --all openstack-compute-node=enabled
kubectl label --overwrite nodes --all openvswitch=enabled
kubectl label --overwrite nodes --all linuxbridge=enabled
kubectl label --overwrite nodes --all ceph-mon=enabled
kubectl label --overwrite nodes --all ceph-osd=enabled
kubectl label --overwrite nodes --all ceph-mds=enabled
kubectl label --overwrite nodes --all ceph-rgw=enabled
kubectl label --overwrite nodes --all ceph-mgr=enabled
# We deploy l3 agent only on the node where we run test scripts.
# In this case virtual router will be created only on this node
# and we don't need L2 overlay (will be implemented later).
kubectl label --overwrite nodes -l "node-role.kubernetes.io/control-plane" l3-agent=enabled

for NAMESPACE in ceph mariadb-operator openstack osh-infra; do
tee /tmp/${NAMESPACE}-ns.yaml << EOF
apiVersion: v1
kind: Namespace
metadata:
  labels:
    kubernetes.io/metadata.name: ${NAMESPACE}
    name: ${NAMESPACE}
  name: ${NAMESPACE}
EOF

kubectl apply -f /tmp/${NAMESPACE}-ns.yaml
done

make all
