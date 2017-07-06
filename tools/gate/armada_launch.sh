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
source ${WORK_DIR}/tools/gate/funcs/helm.sh
source ${WORK_DIR}/tools/gate/funcs/kube.sh
source ${WORK_DIR}/tools/gate/funcs/network.sh

# NOTE(portdirect): Temp workaround until module loading is supported by
# OpenStack-Helm in Fedora
if [ "x$HOST_OS" == "xfedora" ]; then
  sudo modprobe openvswitch
  sudo modprobe gre
  sudo modprobe vxlan
  sudo modprobe ip6_tables
fi

helm install --namespace=openstack ${WORK_DIR}/dns-helper --name=dns-helper
kube_wait_for_pods openstack 180

if ! [ "x$PVC_BACKEND" == "xceph" ]; then
  echo "ARMADA LAUNCH only supports ceph currently"
  exit 1
fi

kubectl label nodes ceph-mon=enabled --all
kubectl label nodes ceph-osd=enabled --all
kubectl label nodes ceph-mds=enabled --all
CONTROLLER_MANAGER_POD=$(kubectl get -n kube-system pods -l component=kube-controller-manager --no-headers -o name | awk -F '/' '{ print $NF; exit }')
kubectl exec -n kube-system ${CONTROLLER_MANAGER_POD} -- sh -c "cat > /etc/resolv.conf <<EOF
nameserver 10.96.0.10
nameserver ${UPSTREAM_DNS}
search cluster.local svc.cluster.local
EOF"

ARMADA_MANIFEST=$(mktemp --suffix=.yaml)
if [ "x$INTEGRATION" == "xaio" ]; then
  SUBNET_RANGE=$(find_subnet_range)
  ARMADA_MANIFEST_TEMPLATE=${WORK_DIR}/tools/deployment/armada/openstack-master-aio.yaml
else
  SUBNET_RANGE="$(find_multi_subnet_range)"
  ARMADA_MANIFEST_TEMPLATE=${WORK_DIR}/tools/deployment/armada/openstack-master.yaml
fi
sed "s|192.168.0.0/16|${SUBNET_RANGE}|g" ${ARMADA_MANIFEST_TEMPLATE} > ${ARMADA_MANIFEST}

sudo docker build https://github.com/att-comdev/armada.git#master -t openstackhelm/armada:latest
sudo docker run -d \
  --net=host \
  --name armada \
  -v ${HOME}/.kube/config:/armada/.kube/config \
  -v ${ARMADA_MANIFEST}:${ARMADA_MANIFEST}:ro \
  -v ${WORK_DIR}:/opt/openstack-helm/charts:ro \
  openstackhelm/armada:latest

sudo docker exec armada armada tiller --status
sudo docker exec armada armada apply ${ARMADA_MANIFEST}
kube_wait_for_pods ceph 600
kube_wait_for_pods openstack 1200

MON_POD=$(kubectl get pods -l application=ceph -l component=mon -n ceph --no-headers | awk '{ print $1; exit }')
kubectl exec -n ceph ${MON_POD} -- ceph -s

if [ "x$INTEGRATION" == "xmulti" ]; then
  helm_test_deployment osh-keystone ${SERVICE_TEST_TIMEOUT}
  helm_test_deployment osh-glance ${SERVICE_TEST_TIMEOUT}
  helm_test_deployment osh-cinder ${SERVICE_TEST_TIMEOUT}
  helm_test_deployment osh-neutron ${SERVICE_TEST_TIMEOUT}
  helm_test_deployment osh-nova ${SERVICE_TEST_TIMEOUT}
fi
