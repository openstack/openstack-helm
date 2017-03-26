#!/usr/bin/env bash
set -e
# Setting up kubectl creds
mkdir -p ${HOME}/.kube
if [ -f ${HOME}/.kube/config ]; then
    echo "Previous kube config found, backing it up"
    mv -v ${HOME}/.kube/config ${HOME}/.kube/config.$(date "+%F-%T")
fi
echo "Getting kubeconfig from kube1"
vagrant ssh default -c "sudo cat /etc/kubernetes/admin.conf" > ${HOME}/.kube/config

# Setting up helm client if present
if which helm 2>/dev/null; then
  helm init
fi

echo "clients should now be ready to access the Kubernetes cluster"
