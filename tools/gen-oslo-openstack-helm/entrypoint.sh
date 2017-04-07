#!/bin/bash
set -xe

git clone --depth 1 --branch ${PROJECT_BRANCH} ${PROJECT_REPO} /tmp/${PROJECT}
cd /tmp/${PROJECT}


TOX_VENV_DIR=$(crudini --get tox.ini testenv:genconfig envdir | sed 's|^{toxworkdir}|.tox|')
if [ -z "$TOX_VENV_DIR" ]
then
      TOX_VENV_DIR=".tox/genconfig"
fi
GENCONFIG_FLAGS=$(crudini --get tox.ini testenv:genconfig commands | sed 's/^oslo-config-generator//')

tox -egenconfig

source ${TOX_VENV_DIR}/bin/activate

python /opt/gen-oslo-openstack-helm/generate.py ${GENCONFIG_FLAGS} \
    --helm_chart ${PROJECT} \
    --helm_namespace ${PROJECT}
