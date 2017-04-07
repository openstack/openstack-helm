#!/bin/bash

# Copyright 2017 The Openstack-Helm Authors.
#
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.
set -xe

# Shallow clone the Project Repo and desired branch
git clone --depth 1 --branch ${PROJECT_BRANCH} ${PROJECT_REPO} /tmp/${PROJECT}

# Move into the project directory
cd /tmp/${PROJECT}

# Hack the tox.ini to load our oslo-config-generator script
TOX_VENV_DIR=$(crudini --get tox.ini testenv:genconfig envdir | sed 's|^{toxworkdir}|.tox|')
if [ -z "$TOX_VENV_DIR" ]; then
  TOX_VENV_DIR=".tox/genconfig"
fi
echo "mv -f /opt/gen-oslo-openstack-helm/oslo-config-generator $(pwd)/${TOX_VENV_DIR}/bin/oslo-config-generator" > /tmp/oslo-config-generator-cmds
crudini --get tox.ini testenv:genconfig commands >> /tmp/oslo-config-generator-cmds
crudini --set tox.ini testenv:genconfig commands "$(cat /tmp/oslo-config-generator-cmds)"

# Setting up the whitelisted commands to include mv, letting us drop in the
# hacked oslo-config-generator.
(crudini --get tox.ini testenv:genconfig whitelist_externals > /tmp/whitelist_externals) || true
echo "mv" >> /tmp/whitelist_externals
crudini --set tox.ini testenv:genconfig whitelist_externals "$(cat /tmp/whitelist_externals)"

# Setting environment variables for OpenStack-Helm's oslo-config-generator args
echo "HELM_CHART=${PROJECT}" > /opt/gen-oslo-openstack-helm-env
echo "HELM_NAMESPACE=${PROJECT}" >> /opt/gen-oslo-openstack-helm-env

# Run tox to generate the standard config files, and generate the venv
tox -egenconfig

# Drop into a shell in the container.
bash
