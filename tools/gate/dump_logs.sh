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

mkdir -p ${LOGS_DIR}/nodes/$(hostname)
sudo docker logs kubelet 2> ${LOGS_DIR}/nodes/$(hostname)/kubelet.txt
sudo iptables-save > ${LOGS_DIR}/nodes/$(hostname)/iptables.txt
sudo ip a > ${LOGS_DIR}/nodes/$(hostname)/ip.txt
sudo route -n > ${LOGS_DIR}/nodes/$(hostname)/routes.txt
sudo arp -a > ${LOGS_DIR}/nodes/$(hostname)/arp.txt
cat /etc/resolv.conf > ${LOGS_DIR}/nodes/$(hostname)/resolv.conf

exit $1
