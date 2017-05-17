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

helm install local/mariadb --name=mariadb --namespace=openstack
helm install local/memcached --name=memcached --namespace=openstack
helm install local/etcd --name=etcd-rabbitmq --namespace=openstack
helm install local/rabbitmq --name=rabbitmq --namespace=openstack
kube_wait_for_pods openstack 600

helm install local/keystone --name=keystone --namespace=openstack
kube_wait_for_pods openstack 240

# NOTE(portdirect): Temp workaround until module loading is supported by
# OpenStack-Helm in Fedora
if [ "x$HOST_OS" == "xfedora" ]; then
  sudo modprobe openvswitch
  sudo modprobe gre
  sudo modprobe vxlan
fi
helm install local/glance --name=glance --namespace=openstack --values=${WORK_DIR}/tools/overrides/mvp/glance.yaml
helm install local/nova --name=nova --namespace=openstack --values=${WORK_DIR}/tools/overrides/mvp/nova.yaml --set=conf.nova.libvirt.nova.conf.virt_type=qemu
helm install local/neutron --name=neutron --namespace=openstack --values=${WORK_DIR}/tools/overrides/mvp/neutron.yaml
kube_wait_for_pods openstack 600
