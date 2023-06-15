#!/usr/bin/env bash

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
      python3-pip \
      libssl-dev \
      python3-dev \
      build-essential \
      jq \
      curl
  elif [ "x$ID" == "xcentos" ]; then
    sudo yum install -y \
      epel-release
    sudo yum install -y \
      python3-pip \
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

  sudo -H -E pip3 install --ignore-installed --upgrade pip
  sudo -H -E pip3 install --ignore-installed --upgrade setuptools
  sudo -H -E pip3 install --ignore-installed --upgrade cmd2
  sudo -H -E pip3 install --ignore-installed --upgrade pyopenssl
  sudo -H -E pip3 install --ignore-installed --upgrade ansible
  sudo -H -E pip3 install --ignore-installed --upgrade \
    ara==0.16.5 \
    yq
}

if [ "x${DEPLOY}" == "xsetup-host" ]; then
  ansible_install
  PLAYBOOKS="osh-infra-deploy-docker"
elif [ "x${DEPLOY}" == "xk8s" ]; then
  ${WORK_DIR}/tools/deployment/common/000-install-packages.sh
  ${WORK_DIR}/tools/gate/deploy-k8s.sh
  exit 0
elif [ "x${DEPLOY}" == "xlogs" ]; then
  PLAYBOOKS="osh-infra-collect-logs"
else
  echo "Unknown Deploy Option Selected"
  exit 1
fi

cd ${WORK_DIR}
export ANSIBLE_CALLBACK_PLUGINS="$(python3 -m ara.setup.callback_plugins)"
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
