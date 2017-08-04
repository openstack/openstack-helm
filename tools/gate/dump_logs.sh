#!/bin/bash
set +xe

# if we can't find kubectl, bail immediately because it is likely
# the whitespace linter fails -  no point to collect logs.
if ! type "kubectl" &> /dev/null; then
  exit $1
fi

echo "Capturing logs from environment."
mkdir -p ${LOGS_DIR}/k8s/etc
sudo cp -a /etc/kubernetes ${LOGS_DIR}/k8s/etc
sudo chmod 777 --recursive ${LOGS_DIR}/*

mkdir -p ${LOGS_DIR}/k8s
for OBJECT_TYPE in nodes \
                   namespace \
                   storageclass; do
  kubectl get ${OBJECT_TYPE} -o yaml > ${LOGS_DIR}/k8s/${OBJECT_TYPE}.yaml
done
kubectl describe nodes > ${LOGS_DIR}/k8s/nodes.txt
for OBJECT_TYPE in svc \
                   pods \
                   jobs \
                   deployments \
                   daemonsets \
                   statefulsets \
                   configmaps \
                   secrets; do
  kubectl get --all-namespaces ${OBJECT_TYPE} -o yaml > \
    ${LOGS_DIR}/k8s/${OBJECT_TYPE}.yaml
done

mkdir -p ${LOGS_DIR}/k8s/pods
kubectl get pods -a --all-namespaces -o json | jq -r \
  '.items[].metadata | .namespace + " " + .name' | while read line; do
  NAMESPACE=$(echo $line | awk '{print $1}')
  NAME=$(echo $line | awk '{print $2}')
  kubectl get --namespace $NAMESPACE pod $NAME -o json | jq -r \
    '.spec.containers[].name' | while read line; do
      CONTAINER=$(echo $line | awk '{print $1}')
      kubectl logs $NAME --namespace $NAMESPACE -c $CONTAINER > \
        ${LOGS_DIR}/k8s/pods/$NAMESPACE-$NAME-$CONTAINER.txt
  done
done

mkdir -p ${LOGS_DIR}/k8s/svc
kubectl get svc -o json --all-namespaces | jq -r \
  '.items[].metadata | .namespace + " " + .name' | while read line; do
  NAMESPACE=$(echo $line | awk '{print $1}')
  NAME=$(echo $line | awk '{print $2}')
  kubectl describe svc $NAME --namespace $NAMESPACE > \
    ${LOGS_DIR}/k8s/svc/$NAMESPACE-$NAME.txt
done

mkdir -p ${LOGS_DIR}/k8s/pvc
kubectl get pvc -o json --all-namespaces | jq -r \
  '.items[].metadata | .namespace + " " + .name' | while read line; do
  NAMESPACE=$(echo $line | awk '{print $1}')
  NAME=$(echo $line | awk '{print $2}')
  kubectl describe pvc $NAME --namespace $NAMESPACE > \
    ${LOGS_DIR}/k8s/pvc/$NAMESPACE-$NAME.txt
done

mkdir -p ${LOGS_DIR}/k8s/rbac
for OBJECT_TYPE in clusterroles \
                   roles \
                   clusterrolebindings \
                   rolebindings; do
  kubectl get ${OBJECT_TYPE} -o yaml > ${LOGS_DIR}/k8s/rbac/${OBJECT_TYPE}.yaml
done

mkdir -p ${LOGS_DIR}/k8s/descriptions
for NAMESPACE in $(kubectl get namespaces -o name | awk -F '/' '{ print $NF }') ; do
  for OBJECT in $(kubectl get all --show-all -n $NAMESPACE -o name) ; do
    OBJECT_TYPE=$(echo $OBJECT | awk -F '/' '{ print $1 }')
    OBJECT_NAME=$(echo $OBJECT | awk -F '/' '{ print $2 }')
    mkdir -p ${LOGS_DIR}/k8s/descriptions/${NAMESPACE}/${OBJECT_TYPE}
    kubectl describe -n $NAMESPACE $OBJECT > ${LOGS_DIR}/k8s/descriptions/${NAMESPACE}/$OBJECT_TYPE/$OBJECT_NAME.txt
  done
done

NODE_NAME=$(hostname)
mkdir -p ${LOGS_DIR}/nodes/${NODE_NAME}
echo "${NODE_NAME}" > ${LOGS_DIR}/nodes/master.txt
sudo docker logs kubelet 2> ${LOGS_DIR}/nodes/${NODE_NAME}/kubelet.txt
sudo docker logs kubeadm-aio 2>&1 > ${LOGS_DIR}/nodes/${NODE_NAME}/kubeadm-aio.txt
sudo docker images --digests --no-trunc --all > ${LOGS_DIR}/nodes/${NODE_NAME}/images.txt
sudo iptables-save > ${LOGS_DIR}/nodes/${NODE_NAME}/iptables.txt
sudo ip a > ${LOGS_DIR}/nodes/${NODE_NAME}/ip.txt
sudo route -n > ${LOGS_DIR}/nodes/${NODE_NAME}/routes.txt
sudo arp -a > ${LOGS_DIR}/nodes/${NODE_NAME}/arp.txt
cat /etc/resolv.conf > ${LOGS_DIR}/nodes/${NODE_NAME}/resolv.conf
sudo lshw > ${LOGS_DIR}/nodes/${NODE_NAME}/hardware.txt
if [ "x$INTEGRATION" == "xmulti" ]; then
  : ${SSH_PRIVATE_KEY:="/etc/nodepool/id_rsa"}
  : ${SUB_NODE_IPS:="$(cat /etc/nodepool/sub_nodes_private)"}
  for NODE_IP in $SUB_NODE_IPS ; do
    ssh-keyscan "${NODE_IP}" >> ~/.ssh/known_hosts
    NODE_NAME=$(ssh -i ${SSH_PRIVATE_KEY} $(whoami)@${NODE_IP} hostname)
    mkdir -p ${LOGS_DIR}/nodes/${NODE_NAME}
    ssh -i ${SSH_PRIVATE_KEY} $(whoami)@${NODE_IP} sudo docker logs kubelet 2> ${LOGS_DIR}/nodes/${NODE_NAME}/kubelet.txt
    ssh -i ${SSH_PRIVATE_KEY} $(whoami)@${NODE_IP} sudo docker logs kubeadm-aio 2>&1 > ${LOGS_DIR}/nodes/${NODE_NAME}/kubeadm-aio.txt
    ssh -i ${SSH_PRIVATE_KEY} $(whoami)@${NODE_IP} sudo docker images --digests --no-trunc --all > ${LOGS_DIR}/nodes/${NODE_NAME}/images.txt
    ssh -i ${SSH_PRIVATE_KEY} $(whoami)@${NODE_IP} sudo iptables-save > ${LOGS_DIR}/nodes/${NODE_NAME}/iptables.txt
    ssh -i ${SSH_PRIVATE_KEY} $(whoami)@${NODE_IP} sudo ip a > ${LOGS_DIR}/nodes/${NODE_NAME}/ip.txt
    ssh -i ${SSH_PRIVATE_KEY} $(whoami)@${NODE_IP} sudo route -n > ${LOGS_DIR}/nodes/${NODE_NAME}/routes.txt
    ssh -i ${SSH_PRIVATE_KEY} $(whoami)@${NODE_IP} sudo arp -a > ${LOGS_DIR}/nodes/${NODE_NAME}/arp.txt
    ssh -i ${SSH_PRIVATE_KEY} $(whoami)@${NODE_IP} cat /etc/resolv.conf > ${LOGS_DIR}/nodes/${NODE_NAME}/resolv.conf
    ssh -i ${SSH_PRIVATE_KEY} $(whoami)@${NODE_IP} sudo lshw > ${LOGS_DIR}/nodes/${NODE_NAME}/hardware.txt
  done
fi

source ${WORK_DIR}/tools/gate/funcs/openstack.sh
mkdir -p ${LOGS_DIR}/openstack
$OPENSTACK service list > ${LOGS_DIR}/openstack/service.txt
$OPENSTACK endpoint list > ${LOGS_DIR}/openstack/endpoint.txt
$OPENSTACK extension list > ${LOGS_DIR}/openstack/extension.txt
$OPENSTACK compute service list > ${LOGS_DIR}/openstack/compute_service.txt
$OPENSTACK compute agent list > ${LOGS_DIR}/openstack/compute_agent.txt
$OPENSTACK host list > ${LOGS_DIR}/openstack/host.txt
$OPENSTACK hypervisor list > ${LOGS_DIR}/openstack/hypervisor.txt
$OPENSTACK hypervisor show $(hostname) > ${LOGS_DIR}/openstack/hypervisor-$(hostname).txt
$OPENSTACK network agent list > ${LOGS_DIR}/openstack/network_agent.txt

exit $1
