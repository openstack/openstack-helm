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

set -ex
: ${WORK_DIR:="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../../.."}
export DEPLOY=${1:-"full"}
export MODE=${2:-"local"}
export INVENTORY=${3:-${WORK_DIR}/tools/gate/devel/${MODE}-inventory.yaml}
export VARS=${4:-${WORK_DIR}/tools/gate/devel/${MODE}-vars.yaml}

function ansible_install {
  cd /tmp
  . /etc/os-release
  HOST_OS=${HOST_OS:="${ID}"}
  if [ "x$ID" == "xubuntu" ]; then
    sudo apt-get update -y
    sudo apt-get install -y --no-install-recommends \
      python-pip \
      libssl-dev \
      python-dev \
      build-essential \
      jq \
      curl
  elif [ "x$ID" == "xcentos" ]; then
    sudo yum install -y \
      epel-release
    sudo yum install -y \
      python-pip \
      python-devel \
      redhat-rpm-config \
      gcc \
      curl
    sudo curl -L -o /usr/bin/jq https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64
    sudo chmod +x /usr/bin/jq
  elif [ "x$ID" == "xfedora" ]; then
    sudo dnf install -y \
      python-devel \
      libselinux-python \
      redhat-rpm-config \
      gcc \
      jq
  fi

  sudo -H -E pip install --upgrade pip
  sudo -H -E pip install --upgrade setuptools
  # NOTE(lamt) Preinstalling a capped version of cmd2 to address bug:
  # https://github.com/python-cmd2/cmd2/issues/421
  sudo -H -E pip install --upgrade "cmd2<=0.8.7"
  sudo -H -E pip install --upgrade pyopenssl
  # NOTE(srwilkers): Pinning ansible to 2.5.5, as pip installs 2.6 by default.
  # 2.6 introduces a new command flag (init) for the docker_container module
  # that is incompatible with what we have currently. 2.5.5 ensures we match
  # what's deployed in the gates
  sudo -H -E pip install --upgrade "ansible==2.5.5"
  sudo -H -E pip install --upgrade \
    ara \
    yq
}

if [ "x${DEPLOY}" == "xsetup-host" ]; then
  ansible_install
  PLAYBOOKS="osh-infra-deploy-docker"
elif [ "x${DEPLOY}" == "xk8s" ]; then
  PLAYBOOKS="osh-infra-build osh-infra-deploy-k8s"
elif [ "x${DEPLOY}" == "xlogs" ]; then
  PLAYBOOKS="osh-infra-collect-logs"
elif [ "x${DEPLOY}" == "xfull" ]; then
  ansible_install
  PLAYBOOKS="osh-infra-deploy-docker osh-infra-build osh-infra-deploy-k8s osh-infra-collect-logs"
else
  echo "Unknown Deploy Option Selected"
  exit 1
fi

cd ${WORK_DIR}
export ANSIBLE_CALLBACK_PLUGINS="$(python -c 'import os,ara; print(os.path.dirname(ara.__file__))')/plugins/callbacks"
rm -rf ${HOME}/.ara

function dump_logs () {
  # Setup the logging location: by default use the working dir as the root.
  export LOGS_DIR=${LOGS_DIR:-"${WORK_DIR}/logs"}
  set +e
  rm -rf ${LOGS_DIR} || true
  mkdir -p ${LOGS_DIR}/ara
  ara generate html ${LOGS_DIR}/ara
  exit $1
}
trap 'dump_logs "$?"' ERR

for PLAYBOOK in ${PLAYBOOKS}; do
  ansible-playbook ${WORK_DIR}/playbooks/${PLAYBOOK}.yaml \
    -i ${INVENTORY} \
    --extra-vars=@${VARS} \
    --extra-vars "work_dir=${WORK_DIR}"
done
