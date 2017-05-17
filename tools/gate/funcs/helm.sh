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
set -e

function helm_install {
  TMP_DIR=$(mktemp -d)
  if [ "x$HOST_OS" == "xubuntu" ]; then
    sudo apt-get update -y
    sudo apt-get install -y --no-install-recommends -qq \
      git \
      make \
      curl \
      ca-certificates
  elif [ "x$HOST_OS" == "xcentos" ]; then
    sudo yum install -y \
      git \
      make \
      curl
  elif [ "x$HOST_OS" == "xfedora" ]; then
    sudo dnf install -y \
      git \
      make \
      curl
  fi

  # install helm
  curl -sSL https://storage.googleapis.com/kubernetes-helm/helm-${HELM_VERSION}-linux-amd64.tar.gz | tar -zxv --strip-components=1 -C ${TMP_DIR}
  sudo mv ${TMP_DIR}/helm /usr/local/bin/helm

  rm -rf ${TMP_DIR}
}

function helm_serve {
  if [[ -d "$HOME/.helm" ]]; then
     echo ".helm directory found"
  else
     helm init --client-only
  fi
  if [[ -z $(curl -s 127.0.0.1:8879 | grep 'Helm Repository') ]]; then
     helm serve & > /dev/null
     while [[ -z $(curl -s 127.0.0.1:8879 | grep 'Helm Repository') ]]; do
        sleep 1
        echo "Waiting for Helm Repository"
     done
  else
     echo "Helm serve already running"
  fi

  if helm repo list | grep -q "^stable" ; then
     helm repo remove stable
  fi

  helm repo add local http://localhost:8879/charts

}

function helm_lint {
  make build-helm-toolkit -C ${WORK_DIR}
  make TASK=lint -C ${WORK_DIR}
}

function helm_build {
  make TASK=build -C ${WORK_DIR}
}
