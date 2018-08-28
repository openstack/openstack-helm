#!/usr/bin/env bash

# Copyright 2017 The Openstack-Helm Authors.
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

set -e
if [ "x${ACTION}" == "xgenerate-join-cmd" ]; then
: ${TTL:="10m"}
DISCOVERY_TOKEN="$(kubeadm token --kubeconfig /etc/kubernetes/admin.conf create --ttl ${TTL} --usages signing,authentication --groups '')"
TLS_BOOTSTRAP_TOKEN="$(kubeadm token --kubeconfig /etc/kubernetes/admin.conf create --ttl ${TTL} --usages authentication --groups \"system:bootstrappers:kubeadm:default-node-token\")"
DISCOVERY_TOKEN_CA_HASH="$(openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* /sha256:/')"
API_SERVER=$(cat /etc/kubernetes/admin.conf | python -c "import sys, yaml; print yaml.safe_load(sys.stdin)['clusters'][0]['cluster']['server'].split(\"//\",1).pop()")
exec echo "kubeadm join \
--tls-bootstrap-token ${TLS_BOOTSTRAP_TOKEN} \
--discovery-token ${DISCOVERY_TOKEN} \
--discovery-token-ca-cert-hash ${DISCOVERY_TOKEN_CA_HASH} \
${API_SERVER}"
elif [ "x${ACTION}" == "xjoin-kube" ]; then
  exec ansible-playbook /opt/playbooks/kubeadm-aio-deploy-node.yaml \
  --inventory=/opt/playbooks/inventory.ini \
  --extra-vars="kubeadm_join_command=\"${KUBEADM_JOIN_COMMAND}\""
fi

: ${ACTION:="deploy-kube"}
: ${CONTAINER_NAME:="null"}
: ${CONTAINER_RUNTIME:="docker"}
: ${CNI_ENABLED:="calico"}
: ${NET_SUPPORT_LINUXBRIDGE:="true"}
: ${PVC_SUPPORT_CEPH:="false"}
: ${PVC_SUPPORT_NFS:="false"}
: ${HELM_TILLER_IMAGE:="gcr.io/kubernetes-helm/tiller:${HELM_VERSION}"}
: ${KUBE_VERSION:="${KUBE_VERSION}"}
: ${KUBE_IMAGE_REPO:="gcr.io/google_containers"}
: ${KUBE_API_BIND_PORT:="6443"}
: ${KUBE_NET_DNS_DOMAIN:="cluster.local"}
: ${KUBE_NET_POD_SUBNET:="192.168.0.0/16"}
: ${KUBE_NET_SUBNET_SUBNET:="10.96.0.0/12"}
: ${KUBE_BIND_DEVICE:=""}
: ${KUBE_BIND_ADDR:=""}
: ${KUBE_API_BIND_DEVICE:="${KUBE_BIND_DEVICE}"}
: ${KUBE_API_BIND_ADDR:="${KUBE_BIND_ADDR}"}
: ${KUBE_CERTS_DIR:="/etc/kubernetes/pki"}
: ${KUBE_SELF_HOSTED:="false"}
: ${KUBE_KEYSTONE_AUTH:="false"}
: ${KUBELET_NODE_LABELS:=""}
: ${GATE_FQDN_TEST:="false"}
: ${GATE_INGRESS_IP:="127.0.0.1"}
: ${GATE_FQDN_TLD:="openstackhelm.test"}

PLAYBOOK_VARS="{
  \"my_container_name\": \"${CONTAINER_NAME}\",
  \"user\": {
    \"uid\": ${USER_UID},
    \"gid\": ${USER_GID},
    \"home\": \"${USER_HOME}\"
  },
  \"cluster\": {
    \"cni\": \"${CNI_ENABLED}\"
  },
  \"kubelet\": {
    \"container_runtime\": \"${CONTAINER_RUNTIME}\",
    \"net_support_linuxbridge\": ${NET_SUPPORT_LINUXBRIDGE},
    \"pv_support_nfs\": ${PVC_SUPPORT_NFS},
    \"pv_support_ceph\": ${PVC_SUPPORT_CEPH}
  },
  \"helm\": {
    \"tiller_image\": \"${HELM_TILLER_IMAGE}\"
  },
  \"k8s\": {
    \"kubernetesVersion\": \"${KUBE_VERSION}\",
    \"imageRepository\": \"${KUBE_IMAGE_REPO}\",
    \"certificatesDir\": \"${KUBE_CERTS_DIR}\",
    \"selfHosted\": \"${KUBE_SELF_HOSTED}\",
    \"keystoneAuth\": \"${KUBE_KEYSTONE_AUTH}\",
    \"api\": {
      \"bindPort\": ${KUBE_API_BIND_PORT}
    },
    \"networking\": {
      \"dnsDomain\": \"${KUBE_NET_DNS_DOMAIN}\",
      \"podSubnet\": \"${KUBE_NET_POD_SUBNET}\",
      \"serviceSubnet\": \"${KUBE_NET_SUBNET_SUBNET}\"
    }
  },
  \"gate\": {
    \"fqdn_testing\": \"${GATE_FQDN_TEST}\",
    \"ingress_ip\": \"${GATE_INGRESS_IP}\",
    \"fqdn_tld\": \"${GATE_FQDN_TLD}\"
  }
}"

set -x
if [ "x${ACTION}" == "xdeploy-kubelet" ]; then

  if [ "x${KUBE_BIND_ADDR}" != "x" ]; then
    PLAYBOOK_VARS=$(echo $PLAYBOOK_VARS | jq ".kubelet += {\"bind_addr\": \"${KUBE_BIND_ADDR}\"}")
  elif [ "x${KUBE_BIND_DEVICE}" != "x" ]; then
    PLAYBOOK_VARS=$(echo $PLAYBOOK_VARS | jq ".kubelet += {\"bind_device\": \"${KUBE_BIND_DEVICE}\"}")
  fi

  if [ "x${KUBELET_NODE_LABELS}" != "x" ]; then
    PLAYBOOK_VARS=$(echo $PLAYBOOK_VARS | jq ".kubelet += {\"kubelet_labels\": \"${KUBELET_NODE_LABELS}\"}")
  fi

  exec ansible-playbook /opt/playbooks/kubeadm-aio-deploy-kubelet.yaml \
    --inventory=/opt/playbooks/inventory.ini \
    --inventory=/opt/playbooks/vars.yaml \
    --extra-vars="${PLAYBOOK_VARS}"
elif [ "x${ACTION}" == "xdeploy-kube" ]; then
  if [ "x${KUBE_API_BIND_ADDR}" != "x" ]; then
    PLAYBOOK_VARS=$(echo $PLAYBOOK_VARS | jq ".k8s.api += {\"advertiseAddress\": \"${KUBE_API_BIND_ADDR}\"}")
  elif [ "x${KUBE_API_BIND_DEVICE}" != "x" ]; then
    PLAYBOOK_VARS=$(echo $PLAYBOOK_VARS | jq ".k8s.api += {\"advertiseAddressDevice\": \"${KUBE_API_BIND_DEVICE}\"}")
  fi
  exec ansible-playbook /opt/playbooks/kubeadm-aio-deploy-master.yaml \
    --inventory=/opt/playbooks/inventory.ini \
    --inventory=/opt/playbooks/vars.yaml \
    --extra-vars="${PLAYBOOK_VARS}"
elif [ "x${ACTION}" == "xclean-host" ]; then
  exec ansible-playbook /opt/playbooks/kubeadm-aio-clean.yaml \
    --inventory=/opt/playbooks/inventory.ini \
    --inventory=/opt/playbooks/vars.yaml \
    --extra-vars="${PLAYBOOK_VARS}"
else
  exec ${ACTION}
fi
