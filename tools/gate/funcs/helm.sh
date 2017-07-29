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

function helm_install {
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
  if CURRENT_HELM_LOC=$(type -p helm); then
    CURRENT_HELM_VERSION=$(${CURRENT_HELM_LOC} version --client --short | awk '{ print $NF }' | awk -F '+' '{ print $1 }')
  fi
  [ "x$HELM_VERSION" == "x$CURRENT_HELM_VERSION" ] || ( \
    TMP_DIR=$(mktemp -d)
    curl -sSL https://storage.googleapis.com/kubernetes-helm/helm-${HELM_VERSION}-linux-amd64.tar.gz | tar -zxv --strip-components=1 -C ${TMP_DIR}
    sudo mv ${TMP_DIR}/helm /usr/local/bin/helm
    rm -rf ${TMP_DIR} )
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

function helm_test_deployment {
  DEPLOYMENT=$1
  if [ x$2 == "x" ]; then
    TIMEOUT=300
  else
    TIMEOUT=$2
  fi

  # Get the namespace of the chart via the Helm release
  NAMESPACE=$(helm status ${DEPLOYMENT} |  awk '/^NAMESPACE/ { print $NF }')

  helm test --timeout ${TIMEOUT} ${DEPLOYMENT}
  mkdir -p ${LOGS_DIR}/rally
  kubectl logs -n ${NAMESPACE} ${DEPLOYMENT}-rally-test > ${LOGS_DIR}/rally/${DEPLOYMENT}
  kubectl delete -n ${NAMESPACE} pod ${DEPLOYMENT}-rally-test
}

function helm_plugin_template_install {
  helm plugin install https://github.com/technosophos/helm-template
}

function helm_template_run {
  mkdir -p ${LOGS_DIR}/templates
  set +x
  for CHART in $(helm search | tail -n +2 | awk '{ print $1 }' | awk -F '/' '{ print $NF }'); do
    echo "Running Helm template plugin on chart: $CHART"
    helm template --verbose $CHART > ${LOGS_DIR}/templates/$CHART
  done
  set -x
}
