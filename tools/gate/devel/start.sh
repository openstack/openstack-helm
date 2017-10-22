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
export MODE=${1:-"local"}

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
      build-essential
  elif [ "x$ID" == "xcentos" ]; then
    sudo yum install -y \
      epel-release
    sudo yum install -y \
      python-pip \
      python-devel \
      redhat-rpm-config \
      gcc
  elif [ "x$ID" == "xfedora" ]; then
    sudo dnf install -y \
      python-devel \
      redhat-rpm-config \
      gcc
  fi

  sudo -H pip install --no-cache-dir --upgrade pip
  sudo -H pip install --no-cache-dir --upgrade setuptools
  sudo -H pip install --no-cache-dir --upgrade pyopenssl
  sudo -H pip install --no-cache-dir ansible
  sudo -H pip install --no-cache-dir ara
  sudo -H pip install --no-cache-dir yq
}
ansible_install

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

INVENTORY=${WORK_DIR}/tools/gate/devel/${MODE}-inventory.yaml
VARS=${WORK_DIR}/tools/gate/devel/${MODE}-vars.yaml
ansible-playbook ${WORK_DIR}/tools/gate/playbooks/zuul-pre.yaml -i ${INVENTORY} --extra-vars=@${VARS} --extra-vars "work_dir=${WORK_DIR}"
ansible-playbook ${WORK_DIR}/tools/gate/playbooks/zuul-run.yaml -i ${INVENTORY} --extra-vars=@${VARS} --extra-vars "work_dir=${WORK_DIR}"
