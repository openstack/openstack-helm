#!/bin/bash
#
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

source ${WORK_DIR}/tools/gate/funcs/helm.sh
source ${WORK_DIR}/tools/gate/funcs/kube.sh

helm_build

helm search

# NOTE(portdirect): Temp workaround until module loading is supported by
# OpenStack-Helm in Fedora
if [ "x$HOST_OS" == "xfedora" ]; then
  sudo modprobe openvswitch
  sudo modprobe gre
  sudo modprobe vxlan
fi

helm install --namespace=openstack local/mariadb --name=mariadb
helm install --namespace=openstack local/memcached --name=memcached
helm install --namespace=openstack local/etcd --name=etcd-rabbitmq
helm install --namespace=openstack local/rabbitmq --name=rabbitmq
helm install --namespace=openstack local/keystone --name=keystone
helm install --namespace=openstack local/glance --name=glance \
    --values=${WORK_DIR}/tools/overrides/mvp/glance.yaml
helm install --namespace=openstack local/nova --name=nova \
    --values=${WORK_DIR}/tools/overrides/mvp/nova.yaml \
    --set=conf.nova.libvirt.nova.conf.virt_type=qemu
helm install --namespace=openstack local/neutron --name=neutron \
    --values=${WORK_DIR}/tools/overrides/mvp/neutron.yaml
helm install --namespace=openstack local/cinder --name=cinder
helm install --namespace=openstack local/heat --name=heat
helm install --namespace=openstack local/horizon --name=horizon

kube_wait_for_pods openstack 1200

helm_test_deployment keystone
helm_test_deployment glance
