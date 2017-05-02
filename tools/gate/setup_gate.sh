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

HELM_VERSION=${2:-v2.3.0}
WORK_DIR=$(pwd)

function helm_install {
  TMP_DIR=$(mktemp -d)
  sudo apt-get update -y
  sudo apt-get install -y --no-install-recommends -qq \
    git \
    make \
    curl

  # install helm
  curl -sSL https://storage.googleapis.com/kubernetes-helm/helm-${HELM_VERSION}-linux-amd64.tar.gz | tar -zxv --strip-components=1 -C ${TMP_DIR}
  sudo mv ${TMP_DIR}/helm /usr/local/bin/helm
  rm -rf ${TMP_DIR}
}

function helm_lint {
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

  if [[ -f "$HOME/.helm/repository/stable/index.yaml" ]]; then
     helm repo remove stable
  fi
  if [[ -z $(-f "$HOME/.helm/repository/local/index.yaml") ]]; then
     helm repo add local http://localhost:8879/charts
  fi

  make build-helm-toolkit -C ${WORK_DIR}
  make TASK=lint -C ${WORK_DIR}
}    

helm_install
helm_lint
