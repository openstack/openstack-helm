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
: ${WORK_DIR:="$(pwd)"}
: ${SERVICE_LAUNCH_TIMEOUT:="600"}
: ${SERVICE_TEST_TIMEOUT:="600"}
source ${WORK_DIR}/tools/gate/funcs/helm.sh
source ${WORK_DIR}/tools/gate/funcs/kube.sh
source ${WORK_DIR}/tools/gate/funcs/network.sh

helm_build

helm search

# NOTE(portdirect): Temp workaround until module loading is supported by
# OpenStack-Helm in Fedora
if [ "x$HOST_OS" == "xfedora" ]; then
  sudo modprobe openvswitch
  sudo modprobe gre
  sudo modprobe vxlan
  sudo modprobe ip6_tables
fi

helm install --namespace=openstack ${WORK_DIR}/dns-helper --name=dns-helper
kube_wait_for_pods openstack ${SERVICE_LAUNCH_TIMEOUT}

if [ "x$PVC_BACKEND" == "xceph" ]; then
  kubectl label nodes ceph-mon=enabled --all
  kubectl label nodes ceph-osd=enabled --all
  kubectl label nodes ceph-mds=enabled --all

  if [ "x$INTEGRATION" == "xmulti" ]; then
    SUBNET_RANGE="$(find_multi_subnet_range)"
  else
    SUBNET_RANGE=$(find_subnet_range)
  fi

  export osd_cluster_network=${SUBNET_RANGE}
  export osd_public_network=${SUBNET_RANGE}

  if [ "x$INTEGRATION" == "xaio" ]; then
    helm install --namespace=ceph ${WORK_DIR}/ceph --name=ceph \
      --set manifests_enabled.client_secrets=false \
      --set network.public=$osd_public_network \
      --set network.cluster=$osd_cluster_network \
      --set bootstrap.enabled=true \
      --values=${WORK_DIR}/tools/overrides/mvp/ceph.yaml
  else
    helm install --namespace=ceph ${WORK_DIR}/ceph --name=ceph \
      --set manifests_enabled.client_secrets=false \
      --set network.public=$osd_public_network \
      --set network.cluster=$osd_cluster_network \
      --set bootstrap.enabled=true
  fi

  kube_wait_for_pods ceph ${SERVICE_LAUNCH_TIMEOUT}

  MON_POD=$(kubectl get pods -l application=ceph -l component=mon -n ceph --no-headers | awk '{ print $1; exit }')

  kubectl exec -n ceph ${MON_POD} -- ceph -s

  helm install --namespace=openstack ${WORK_DIR}/ceph --name=ceph-openstack-config \
    --set manifests_enabled.storage_secrets=false \
    --set manifests_enabled.deployment=false \
    --set manifests_enabled.rbd_provisioner=false \
    --set ceph.namespace=ceph \
    --set network.public=$osd_public_network \
    --set network.cluster=$osd_cluster_network

  kube_wait_for_pods openstack ${SERVICE_LAUNCH_TIMEOUT}
fi

helm install --namespace=openstack ${WORK_DIR}/ingress --name=ingress
helm install --namespace=openstack ${WORK_DIR}/mariadb --name=mariadb
helm install --namespace=openstack ${WORK_DIR}/memcached --name=memcached
helm install --namespace=openstack ${WORK_DIR}/etcd --name=etcd-rabbitmq
helm install --namespace=openstack ${WORK_DIR}/rabbitmq --name=rabbitmq
kube_wait_for_pods openstack ${SERVICE_LAUNCH_TIMEOUT}
helm install --namespace=openstack ${WORK_DIR}/keystone --name=keystone
if [ "x$PVC_BACKEND" == "xceph" ]; then
  helm install --namespace=openstack ${WORK_DIR}/glance --name=glance
else
  helm install --namespace=openstack ${WORK_DIR}/glance --name=glance \
      --values=${WORK_DIR}/tools/overrides/mvp/glance.yaml
fi
kube_wait_for_pods openstack ${SERVICE_LAUNCH_TIMEOUT}
helm install --namespace=openstack ${WORK_DIR}/nova --name=nova \
    --values=${WORK_DIR}/tools/overrides/mvp/nova.yaml \
    --set=conf.nova.libvirt.nova.conf.virt_type=qemu
helm install --namespace=openstack ${WORK_DIR}/neutron --name=neutron \
    --values=${WORK_DIR}/tools/overrides/mvp/neutron.yaml
kube_wait_for_pods openstack ${SERVICE_LAUNCH_TIMEOUT}

if [ "x$INTEGRATION" == "xmulti" ]; then
  if [ "x$PVC_BACKEND" == "xceph" ]; then
    helm install --namespace=openstack ${WORK_DIR}/cinder --name=cinder
  else
    helm install --namespace=openstack ${WORK_DIR}/cinder --name=cinder \
        --values=${WORK_DIR}/tools/overrides/mvp/cinder.yaml
  fi
  helm install --namespace=openstack ${WORK_DIR}/heat --name=heat
  helm install --namespace=openstack ${WORK_DIR}/horizon --name=horizon
  kube_wait_for_pods openstack ${SERVICE_LAUNCH_TIMEOUT}

  helm install --namespace=openstack ${WORK_DIR}/barbican --name=barbican
  helm install --namespace=openstack ${WORK_DIR}/magnum --name=magnum
  kube_wait_for_pods openstack ${SERVICE_LAUNCH_TIMEOUT}

  helm install --namespace=openstack ${WORK_DIR}/mistral --name=mistral
  helm install --namespace=openstack ${WORK_DIR}/senlin --name=senlin
  kube_wait_for_pods openstack ${SERVICE_LAUNCH_TIMEOUT}

  helm_test_deployment keystone ${SERVICE_TEST_TIMEOUT}
  helm_test_deployment glance ${SERVICE_TEST_TIMEOUT}
  helm_test_deployment cinder ${SERVICE_TEST_TIMEOUT}
  helm_test_deployment neutron ${SERVICE_TEST_TIMEOUT}
  helm_test_deployment nova ${SERVICE_TEST_TIMEOUT}
fi
